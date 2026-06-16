import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/constants/app_dimens.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../data/models/address.dart';
import '../data/pincode_service.dart';
import '../state/auth_controller.dart';
import 'app_buttons.dart';

/// Opens a bottom sheet to add/edit an address. Returns the [Address] (with a
/// stable id) or null if cancelled. Saving to the profile is the caller's job.
Future<Address?> showAddressSheet(BuildContext context, {Address? existing}) {
  return showModalBottomSheet<Address>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.brand.card,
    shape: const RoundedRectangleBorder(
      borderRadius:
          BorderRadius.vertical(top: Radius.circular(AppDimens.radiusXl)),
    ),
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: _AddressForm(existing: existing),
    ),
  );
}

class _AddressForm extends StatefulWidget {
  final Address? existing;
  const _AddressForm({this.existing});

  @override
  State<_AddressForm> createState() => _AddressFormState();
}

class _AddressFormState extends State<_AddressForm> {
  final _key = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final _line1 = TextEditingController(text: widget.existing?.line1);
  late final _line2 = TextEditingController(text: widget.existing?.line2);
  late final _city = TextEditingController(text: widget.existing?.city);
  late final _state = TextEditingController(text: widget.existing?.state);
  late final _pincode = TextEditingController(text: widget.existing?.pincode);
  late String _label = widget.existing?.label ?? 'Home';

  bool _lookingUp = false;
  List<String> _areas = const [];

  @override
  void initState() {
    super.initState();
    final profile = AuthController.instance.profile;
    // Prefill recipient details for a NEW address from the signed-in user.
    _name = TextEditingController(
        text: widget.existing?.name ?? profile?.name ?? '');
    _phone = TextEditingController(
        text: widget.existing?.phone ?? _last10(profile?.phone));
    if (widget.existing != null) {
      _areas = [widget.existing!.line2].where((s) => s.isNotEmpty).toList();
    }
  }

  /// Keeps only the trailing 10 digits of a stored phone like "+918386915528".
  String _last10(String? phone) {
    final digits = (phone ?? '').replaceAll(RegExp(r'\D'), '');
    return digits.length > 10 ? digits.substring(digits.length - 10) : digits;
  }

  @override
  void dispose() {
    for (final c in [_name, _phone, _line1, _line2, _city, _state, _pincode]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _onPincode(String value) async {
    if (value.length != 6) {
      if (_areas.isNotEmpty) setState(() => _areas = const []);
      return;
    }
    setState(() => _lookingUp = true);
    final info = await PincodeService.instance.lookup(value);
    if (!mounted) return;
    setState(() {
      _lookingUp = false;
      if (info != null) {
        _city.text = info.district;
        _state.text = info.state;
        _areas = info.areas;
      }
    });
  }

  void _save() {
    if (!_key.currentState!.validate()) return;
    final id =
        widget.existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    Navigator.pop(
      context,
      Address(
        id: id,
        label: _label,
        name: _name.text.trim(),
        phone: _phone.text.trim(),
        line1: _line1.text.trim(),
        line2: _line2.text.trim(),
        city: _city.text.trim(),
        state: _state.text.trim(),
        pincode: _pincode.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimens.lg),
        child: Form(
          key: _key,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(widget.existing == null ? 'Add Address' : 'Edit Address',
                  style: AppTextStyles.h3.copyWith(color: brand.textPrimary)),
              const SizedBox(height: AppDimens.md),
              Wrap(
                spacing: AppDimens.sm,
                children: ['Home', 'Work', 'Other']
                    .map((l) => ChoiceChip(
                          label: Text(l),
                          selected: _label == l,
                          onSelected: (_) => setState(() => _label = l),
                        ))
                    .toList(),
              ),
              const SizedBox(height: AppDimens.md),
              _field(brand, _name, 'Full name'),
              _field(brand, _phone, 'Phone number', phone: true, formatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ]),
              _field(brand, _line1, 'Flat / House no., Building'),

              _pincodeField(brand),
              _field(brand, _line2, 'Area / Street (optional)',
                  required: false),
              if (_areas.length > 1) _localityDropdown(brand),
              Row(children: [
                Expanded(child: _field(brand, _city, 'City')),
                const SizedBox(width: AppDimens.md),
                Expanded(child: _field(brand, _state, 'State')),
              ]),
              const SizedBox(height: AppDimens.md),
              PrimaryButton(text: 'Save Address', onPressed: _save),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pincodeField(BrandColors brand) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.md),
      child: TextFormField(
        controller: _pincode,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(6),
        ],
        onChanged: _onPincode,
        validator: (v) =>
            (v == null || v.trim().length != 6) ? 'Enter a 6-digit pincode' : null,
        decoration: _decoration(brand, 'Pincode').copyWith(
          suffixIcon: _lookingUp
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2)),
                )
              : (_state.text.isNotEmpty && _pincode.text.length == 6
                  ? const Icon(Icons.check_circle_rounded,
                      color: AppColors.primaryGreen)
                  : null),
        ),
      ),
    );
  }

  Widget _localityDropdown(BrandColors brand) {
    final selected = _areas.contains(_line2.text) ? _line2.text : null;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.md),
      child: DropdownButtonFormField<String>(
        initialValue: selected,
        isExpanded: true,
        decoration: _decoration(brand, 'Area / Locality'),
        hint: const Text('Select your area'),
        items: _areas
            .map((a) => DropdownMenuItem(value: a, child: Text(a)))
            .toList(),
        onChanged: (v) => setState(() {
          if (v != null) _line2.text = v;
        }),
      ),
    );
  }

  Widget _field(BrandColors brand, TextEditingController c, String label,
      {bool required = true,
      bool phone = false,
      List<TextInputFormatter>? formatters}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.md),
      child: TextFormField(
        controller: c,
        keyboardType: phone ? TextInputType.phone : TextInputType.text,
        inputFormatters: formatters,
        validator: required
            ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null
            : null,
        decoration: _decoration(brand, label),
      ),
    );
  }

  InputDecoration _decoration(BrandColors brand, String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: brand.cardSoft,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: AppDimens.md, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        borderSide: BorderSide(color: brand.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.6),
      ),
    );
  }
}
