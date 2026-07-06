import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// The set of device capabilities the app may need. Add new entries here as
/// features grow (e.g. [location] for delivery tracking) — the
/// [PermissionService] flow and the guidance sheet work for all of them
/// without further changes.
enum AppPermission { photos, camera, location, notifications }

extension AppPermissionMeta on AppPermission {
  /// The underlying platform permission (used only on mobile/desktop; the web
  /// never touches this).
  Permission get handlerPermission => switch (this) {
        AppPermission.photos => Permission.photos,
        AppPermission.camera => Permission.camera,
        AppPermission.location => Permission.locationWhenInUse,
        AppPermission.notifications => Permission.notification,
      };

  IconData get icon => switch (this) {
        AppPermission.photos => Icons.photo_library_outlined,
        AppPermission.camera => Icons.photo_camera_outlined,
        AppPermission.location => Icons.location_on_outlined,
        AppPermission.notifications => Icons.notifications_outlined,
      };

  String get label => switch (this) {
        AppPermission.photos => 'Photo access',
        AppPermission.camera => 'Camera access',
        AppPermission.location => 'Location access',
        AppPermission.notifications => 'Notifications',
      };

  /// Why we're asking — shown at the top of the request/guidance sheet.
  String get rationale => switch (this) {
        AppPermission.photos =>
          'Rootaura needs access to your photos so you can choose product '
              'images to upload.',
        AppPermission.camera =>
          'Rootaura needs camera access to take product photos.',
        AppPermission.location =>
          'Rootaura uses your location to speed up delivery address entry.',
        AppPermission.notifications =>
          'Enable notifications to get order and delivery updates.',
      };

  /// Step-by-step instructions to grant this permission from system settings,
  /// tailored to the platform the user is on. Used when they've permanently
  /// denied it and must re-enable it manually.
  List<String> stepsFor(TargetPlatform platform) {
    final name = switch (this) {
      AppPermission.photos => 'Photos',
      AppPermission.camera => 'Camera',
      AppPermission.location => 'Location',
      AppPermission.notifications => 'Notifications',
    };
    switch (platform) {
      case TargetPlatform.android:
        return [
          'Open your phone’s Settings',
          'Go to Apps → Rootaura',
          'Tap Permissions → $name',
          'Choose Allow',
        ];
      case TargetPlatform.iOS:
        return [
          'Open the Settings app',
          'Scroll down and tap Rootaura',
          'Tap $name',
          'Choose Allow',
        ];
      case TargetPlatform.macOS:
        return [
          'Open System Settings → Privacy & Security',
          'Select $name',
          'Enable Rootaura in the list',
        ];
      case TargetPlatform.windows:
        return [
          'Open Windows Settings → Privacy & security',
          'Select $name',
          'Allow apps to access your $name',
        ];
      default:
        return [
          'Open your system Settings',
          'Find Rootaura’s permissions',
          'Enable $name',
        ];
    }
  }

  /// On the web there is no OS-level permission for these actions — the browser
  /// handles file/camera access through its own prompts.
  bool get requiredOnWeb => false;
}
