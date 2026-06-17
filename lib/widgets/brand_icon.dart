import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../core/theme/app_colors.dart';

/// Renders one of the cohesive thin-line brand icons from `assets/icons`,
/// tinted to a brand colour (defaults to the secondary text colour). Single
/// source of iconography so the whole app shares one visual language.
class BrandIcon extends StatelessWidget {
  final String name;
  final double size;
  final Color? color;

  const BrandIcon(this.name, {super.key, this.size = 22, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? context.brand.textSecondary;
    return SvgPicture.asset(
      'assets/icons/$name.svg',
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(c, BlendMode.srcIn),
    );
  }

  // Common names as constants to avoid typos at call sites.
  static const cart = 'cart';
  static const bag = 'bag';
  static const heart = 'heart';
  static const search = 'search';
  static const user = 'user';
  static const orders = 'orders';
  static const gift = 'gift';
  static const leaf = 'leaf';
  static const sprout = 'sprout';
  static const snowflake = 'snowflake';
  static const truck = 'truck';
  static const shield = 'shield';
  static const card = 'card';
  static const star = 'star';
  static const nutrition = 'nutrition';
  static const menu = 'menu';
  static const close = 'close';
  static const arrowRight = 'arrow-right';
  static const plus = 'plus';
  static const minus = 'minus';
  static const check = 'check';
  static const filter = 'filter';
  static const location = 'location';
  static const phone = 'phone';
  static const mail = 'mail';
  static const whatsapp = 'whatsapp';
  static const instagram = 'instagram';
  static const droplet = 'droplet';
  static const edit = 'edit';
  static const logout = 'logout';
  static const info = 'info';
}
