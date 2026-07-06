import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../constants/app_dimens.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../../widgets/app_buttons.dart';
import 'app_permission.dart';

/// Central, platform-aware permission gate.
///
/// Call [ensure] right before the action that needs a capability (e.g. just
/// before picking a photo) — never up front. It:
///  * returns `true` immediately on the **web**, where the browser handles
///    file/camera access itself (no OS permission exists);
///  * on mobile/desktop, checks the status, requests it if undecided, and if
///    the user has permanently denied it, shows a platform-specific guidance
///    sheet with an "Open Settings" shortcut.
class PermissionService {
  PermissionService._();
  static final PermissionService instance = PermissionService._();

  /// Ensures [perm] is usable. Returns `true` if the caller may proceed.
  Future<bool> ensure(BuildContext context, AppPermission perm) async {
    // Web: the browser's own dialog governs access — nothing to request.
    if (kIsWeb) return perm.requiredOnWeb ? false : true;

    final permission = perm.handlerPermission;
    var status = await permission.status;

    if (status.isGranted || status.isLimited) return true;

    if (status.isPermanentlyDenied || status.isRestricted) {
      if (context.mounted) await _showBlockedSheet(context, perm);
      return false;
    }

    // Undetermined / previously denied (but re-askable): request now.
    status = await permission.request();
    if (status.isGranted || status.isLimited) return true;

    if ((status.isPermanentlyDenied || status.isRestricted) &&
        context.mounted) {
      await _showBlockedSheet(context, perm);
    }
    return false;
  }

  Future<void> _showBlockedSheet(
      BuildContext context, AppPermission perm) async {
    final steps = perm.stepsFor(defaultTargetPlatform);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        final brand = ctx.brand;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                AppDimens.lg, 0, AppDimens.lg, AppDimens.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor:
                          AppColors.primaryGreen.withValues(alpha: 0.12),
                      child: Icon(perm.icon, color: AppColors.primaryGreen),
                    ),
                    const SizedBox(width: AppDimens.md),
                    Expanded(
                      child: Text('${perm.label} is off',
                          style: AppTextStyles.h3.copyWith(
                              color: brand.textPrimary, fontSize: 18)),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.md),
                Text(perm.rationale,
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: brand.textSecondary)),
                const SizedBox(height: AppDimens.lg),
                Text('To enable it:',
                    style: AppTextStyles.bodyMedium.copyWith(
                        color: brand.textPrimary,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: AppDimens.sm),
                for (var i = 0; i < steps.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${i + 1}.',
                            style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.primaryGreen,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(width: AppDimens.sm),
                        Expanded(
                          child: Text(steps[i],
                              style: AppTextStyles.bodyMedium
                                  .copyWith(color: brand.textSecondary)),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: AppDimens.lg),
                Row(
                  children: [
                    Expanded(
                      child: SecondaryButton(
                        text: 'Not now',
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ),
                    const SizedBox(width: AppDimens.md),
                    Expanded(
                      child: PrimaryButton(
                        text: 'Open Settings',
                        icon: Icons.settings_outlined,
                        onPressed: () {
                          Navigator.pop(ctx);
                          openAppSettings();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
