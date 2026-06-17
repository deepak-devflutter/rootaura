# Rootaura — Premium UI Blueprint ("Living Larder")

{
  "brandConcept": "\"Living Larder\" \u2014 Rootaura's design language treats the screen as a sunlit pantry shelf where freeze-dried fruit is presented like preserved specimens under museum glass. Three ideas unify every audit: (1) WARM LAYERED LIGHT \u2014 depth comes from soft, warm-tinted multi-layer shadows and a forest-tinted surface ladder, never flat white-on-white; (2) BOTANICAL MOTION \u2014 everything enters and responds with an organic \"expo-out\" ease and gentle drift, as if settling into place rather than snapping; (3) EDITORIAL RESTRAINT \u2014 Fraunces serif drama, a single gold accent used sparingly as \"light catching an edge,\" and tabular-figure numbers that read receipt-grade. The signature gesture is the \"specimen lift\": cards rest on a warm contact+ambient shadow and rise on a lit surface (radial spotlight + ground shadow) on hover. Gold is always foiled (a 3-stop gradient), never flat. The motif throughout is the leaf/seed and matte-paper grain, replacing every generic dot-grid and Material icon \u2014 so the whole app feels like a curated organic-luxury larder, not a SaaS template.",
  "designLanguage": {
    "palette": "Keep the strong existing hexes (forest #1E6F43, dark #123D2A, mid #2E8B57, soft #7BAE95, gold #B0852F, goldSoft #EADFC6, berry #C0444D, cream #FBF9F4, warm near-black #1C1A17). FIX flatness by adding to BrandColors a TINT LADDER: surfaceRaised (#FFFFFF over e2), surfaceSunken (#F4F0E8), and a forestTintOverlay (primaryGreen @ ~5% alpha) to replace ALL grey sectionAlt fills so warmth reads. Add translucentSurface (light 0xCCFFFFFF / dark 0xCC1A1815) for one BackdropFilter glass header. Gold is FOILED via a 3-stop gradient token (#D8B86A\u2192#B0852F\u2192#8A6520), never flat. RESOLVED CONFLICT across audits on status colours: status_badge.dart must drop ALL foreign blues/indigos (#2563EB,#4F46E5,#0E7C86) and map onto ONE earthy ramp \u2014 placed=gold, confirmed/packed/shipped on the green ladder (softGreen\u2192midGreen\u2192primaryGreen), delivered=darkGreen, cancelled/destructive=berry, paid=primaryGreen, pending=gold; pill = dot + 8% fill + 24% same-hue 1px border + uppercase eyebrow label. Berry is demoted from a loud discount sticker to destructive-only; discounts move to a restrained goldSoft 'save N%' chip.",
    "typography": "Fraunces (serif display), Poppins (UI titles/labels), Inter (body) \u2014 already bundled. CRITICAL RECONCILIATION: multiple audits assume Fraunces variable axes (FontVariation opsz/SOFT) and a Fraunces italic face, but pubspec bundles single static .ttf files (Fraunces.ttf, Inter.ttf; only Poppins has 4 weights). Before adopting opsz/SOFT FontVariation or displayItalic, VERIFY the bundled Fraunces.ttf is the variable font and add an italic asset entry (style: italic) to pubspec; otherwise fall back to weight/letterSpacing for drama. Push hero display 64\u219272 (desktop), letterSpacing \u22121.2\u2192\u22121.6, toward a ~5:1 hero:body ratio. Add to app_text_styles.dart: displayItalic (one hero pull-phrase per page), eyebrowGold (Poppins 13 / ls 2.0 / uppercase / gold \u2014 the signature section label), price/numeric style with fontFeatures:[FontFeature.tabularFigures()] for ALL prices, totals, order IDs and KPI values, and accentNumeral (Fraunces ~120, gold @ low alpha) for number-led 'process' layouts. Promote money on the PDP, order summary, success receipt and order-detail Total to Fraunces.",
    "spacing": "Keep the 4/8/16/24/32/48/64 scale and section/sectionMobile 128/72 \u2014 it is a fine baseline. REFINE radius in app_dimens.dart: drop the odd radiusMd=18; standardise crisp-small radiusSm=10/12 for chips/inputs and soft-organic radiusLg=24/radiusXl=28-32 for cards/images; keep radiusPill=999. Add INTERACTION TOKENS so widgets stop hardcoding transforms: hoverLiftY=-6 (cards) / -4 (rows) / -2 (buttons standardised to one scale), pressedScale=0.97, hoverScale=1.015. Vary maxContentWidth per section for magazine pacing (about narrower, testimonials wider) rather than a uniform 1200 everywhere.",
    "depth": "THE single biggest 'expensive' lever. Replace the lone BrandColors.shadow (one BoxShadow) with a real elevation scale in a NEW lib/core/theme/app_elevation.dart: AppElevation.e0..e4, each returning a List<BoxShadow> of 2 STACKED warm shadows \u2014 a tight contact shadow + a wide soft ambient one (e2 cards \u2248 [0x0F1C1A17 blur2 y1, 0x14241B0A blur28 spread-4 y14]; e4 modals/hero blur60 y30; dark multiplies alpha ~3x). RESOLVED: keep elevation as a separate token file (NOT inside BrandColors) so the ThemeExtension lerp/copyWith stays color-only and clean; every card/button/header/admin surface consumes the same scale, killing the scattered magic-number shadows (product_card 0.16/0.07, app_buttons 0.35/0.22). Rest=e2, hover=e3/e4. Add a page-wide matte FILM-GRAIN overlay (seeded static CustomPainter at ~3-4% alpha) and, for product images, a radial 'spotlight' surface + CustomPainter elliptical contact shadow so products sit on a lit surface instead of floating.",
    "iconography": "Eliminate generic Material glyphs (eco_rounded, ac_unit, verified_user, block, spa, shopping_cart_outlined, g_mobiledata, receipt_long, check_circle). Build ONE cohesive thin-line (1.5px) organic icon set as SVGs under assets/svg (reuse existing leaf, leaf_sprig, sparkle; add seed-basket, parcel, truck, droplet, sun, shield, shopping-bag, user, menu, arrow, gold Google mark) wrapped in a BrandIcons helper rendered via SvgPicture and tinted to brand.textSecondary/gold. The header lockup leaf and footer leaf MUST be the same leaf.svg. Pull-style numerals (01/02/03) in Fraunces replace icon-led process steps where editorial.",
    "imagery": "Art-direct ALL photography through one FramedImage treatment: soft elliptical ground-shadow + radial spotlight behind the hero bowl, a 1px gold ring + cream inner-frame on about/cta images, image overlap past its container edge, and an optional forest-green duotone via ColorFilter.matrix so mixed stock shares one tonal language. Replace the static hero _blob circles with the (currently unused) AnimatedBackground re-themed to organic. Branded shimmer skeletons replace every raw CircularProgressIndicator/broken_image fallback."
  },
  "motionSystem": {
    "principles": [
      "Botanical expo-out: reveals and entrances use AppCurves.entrance = Cubic(0.16,1,0.3,1) \u2014 the 'settles into place' feel that reads expensive; this replaces the 5 stock Material curves that are the #1 reason the app feels basic.",
      "One shared transition vocabulary: every route, hover, press and reveal pulls from app_motion.dart tokens \u2014 never a raw Curves.* or magic ms again \u2014 so the whole app moves like a single deliberate product.",
      "Choreographed, not uniform: grids and lists cascade with index-based stagger (60-90ms steps); nothing enters as one block.",
      "Tactile physicality: every interactive surface has BOTH a hover-lift and the currently-missing press-down (pressedScale 0.97), plus haptics on mobile steppers.",
      "Restraint + accessibility: motion is gentle and gated \u2014 all loops, parallax, confetti and per-frame lerps respect MediaQuery.disableAnimations (extend the pattern AnimatedBackground already uses); dispose every AnimationController."
    ],
    "signatureInteractions": [
      "Specimen lift: a shared PressableCard/LiftCard wrapper drives translateY + scale 1.015 + e2\u2192e4 shadow + synced inner image zoom from ONE AnimationController, so lift/zoom/shadow move together (replaces product_card's disconnected -10px and image_carousel's separate 1.04 zoom).",
      "Progressive glass header: a single ValueNotifier<double> t=(offset/96).clamp(0,1) lerps height/padding/blur/background/shadow/logo-scale every frame via AnimatedBuilder \u2014 replacing the binary _solid bool flip and snapping BackdropFilter.",
      "Magic underline: one sliding gold indicator animates between nav items for hover AND the missing active-section state, with AnimatedDefaultTextStyle colour cross-fade.",
      "Add-to-cart celebration: spring chip flies to the cart icon, then a cart-badge elastic bounce (TweenSequence 1\u21921.3\u21921, elasticOut) \u2014 gated by reduced-motion.",
      "Success peak: order_success medallion scales in (elasticOut), checkmark draws on via CustomPainter PathMetric, then a one-shot organic leaf/gold particle burst, then staggered receipt rows.",
      "Animated fulfilment timeline: vertical order timeline with an animated green rail fill (0\u2192target, entrance curve) and a breathing gold ring on the current node (repeat-reverse ~1600ms).",
      "Odometer values: AnimatedMoney (TweenAnimationBuilder count-up + brief green tint) for every rupee total, and QtyStepper digit roll via AnimatedSwitcher slide+fade."
    ],
    "tokens": [
      "AppCurves.entrance = Cubic(0.16,1,0.3,1) \u2014 reveals/hero",
      "AppCurves.emphasized = Cubic(0.2,0.0,0,1.0) \u2014 page/shared transitions",
      "AppCurves.standard = Curves.easeOutCubic \u2014 hovers/condense",
      "AppCurves.spring = SpringDescription(mass:1, stiffness:180, ratio:0.75) \u2014 cart pops/badge",
      "AppCurves.overshoot = Curves.easeOutBack \u2014 carousel active-dot/chip pops",
      "AppDurations.micro = 120ms (press)",
      "AppDurations.hover = 220ms",
      "hoverOut = 350ms (keep existing medium)",
      "AppDurations.enter = 520ms (stagger item)",
      "AppDurations.page = 600ms (route)",
      "AppDurations.hero = 720ms (keep existing reveal=700)",
      "stagger step = 60-90ms \u00d7 index"
    ]
  },
  "signatureComponents": [
    "app_motion.dart (NEW) \u2014 AppCurves + curve-paired duration tokens: the single source of motion truth replacing all raw Curves.* and the 5 flat ms values.",
    "app_elevation.dart (NEW) \u2014 AppElevation.e0..e4 2-layer warm BoxShadow lists (light+dark), consumed by every card/button/header/admin surface.",
    "app_gradients.dart (NEW) \u2014 heroWash (cream\u2192mintTint), goldFoil (#D8B86A\u2192#B0852F\u2192#8A6520), botanicalGlow RadialGradient.",
    "LiftCard / PressableCard (NEW) \u2014 the 'specimen lift' wrapper (hover lift+scale+shadow + press-down) shared by product_card, content_cards _Tile/InfoCard, admin SurfaceCard, order/account tiles \u2014 ends every widget reinventing transforms.",
    "StaggeredReveal (rewrite of scroll_reveal.dart) \u2014 controller-based opacity+translateY(24)+scale(0.98\u21921) with Interval stagger on AppCurves.entrance; the unused delay finally drives the cascade.",
    "Re-themed AnimatedBackground \u2014 organic forest/gold/mint aurora blobs on sine drift + seeded static film-grain; dot-grid removed; wired into the hero (currently built but unused).",
    "BrandIcons + thin-line SVG set (NEW) \u2014 one organic icon language replacing all Material glyphs across nav, footer, sections, cards, status, admin.",
    "PriceTag / AnimatedMoney (NEW) \u2014 editorial Fraunces price (superscript currency/decimals, tabular figures, goldSoft 'save N%' chip) and count-up money; retires the berry discount pill.",
    "Shimmer / Skeleton (NEW) \u2014 ShaderMask skeletons replacing every raw CircularProgressIndicator (cards, PDP, orders, profile, admin, checkout busy state).",
    "OrganicEmptyState + EmptyState (NEW) \u2014 CustomPainter pouch/leaf illustration + Fraunces title + CTA for cart/checkout/orders-empty/order-not-found.",
    "_BrandLockup (NEW) \u2014 gold-ringed leaf seal + Fraunces wordmark (via context.brand.textPrimary, NOT hardcoded darkGreen) + Poppins 'NATURALS' eyebrow; shared by header AND footer.",
    "OrderTimeline + SuccessCelebration (NEW) \u2014 animated vertical fulfilment journey and the elasticOut medallion + drawn-check + leaf-burst success moment.",
    "KpiStatCard + DataTableShell + AdminTabSwitcher (NEW) \u2014 KPI band with gold top-rule + tabular count-up, responsive aligned-column tables, and a gold-pill tab control that turn the admin from a list-of-tabs into a premium ops console."
  ],
  "prioritizedPlan": [
    {
      "step": 1,
      "title": "Foundation: motion + elevation + gradient token files",
      "files": [
        "/Users/deepaksingh/Documents/Flutter/projects/rootaura/lib/core/theme/app_motion.dart",
        "/Users/deepaksingh/Documents/Flutter/projects/rootaura/lib/core/theme/app_elevation.dart",
        "/Users/deepaksingh/Documents/Flutter/projects/rootaura/lib/core/theme/app_gradients.dart",
        "/Users/deepaksingh/Documents/Flutter/projects/rootaura/lib/core/constants/app_durations.dart",
        "/Users/deepaksingh/Documents/Flutter/projects/rootaura/lib/core/constants/app_dimens.dart"
      ],
      "changes": [
        "CREATE app_motion.dart: AppCurves (entrance Cubic(0.16,1,0.3,1), emphasized Cubic(0.2,0,0,1), standard easeOutCubic, overshoot easeOutBack, spring SpringDescription(mass:1,stiffness:180,ratio:0.75)).",
        "CREATE app_elevation.dart: AppElevation.e0..e4 returning List<BoxShadow> (2-layer contact+ambient, warm-tinted, light+dark variants).",
        "CREATE app_gradients.dart: heroWash, goldFoil (3-stop), botanicalGlow RadialGradient.",
        "EXTEND app_durations.dart with curve-paired tokens micro 120 / hover 220 / enter 520 / page 600 (keep fast/medium/slow/reveal/scrollTo).",
        "REFINE app_dimens.dart: drop radiusMd=18, set radiusSm crisp + radiusLg/Xl soft; add hoverLiftY=-6, rowLiftY=-4, pressedScale=0.97, hoverScale=1.015."
      ],
      "impact": "critical"
    },
    {
      "step": 2,
      "title": "Extend colour + type tokens; verify Fraunces variable/italic",
      "files": [
        "/Users/deepaksingh/Documents/Flutter/projects/rootaura/lib/core/theme/app_colors.dart",
        "/Users/deepaksingh/Documents/Flutter/projects/rootaura/lib/core/theme/app_text_styles.dart",
        "/Users/deepaksingh/Documents/Flutter/projects/rootaura/pubspec.yaml"
      ],
      "changes": [
        "Extend BrandColors with surfaceRaised, surfaceSunken, translucentSurface (light 0xCCFFFFFF / dark 0xCC1A1815) and forestTintOverlay (primaryGreen @5%); update copyWith/lerp; keep elevation OUT of BrandColors.",
        "Add to app_text_styles.dart: eyebrowGold, priceStyle/numeric (FontFeature.tabularFigures), accentNumeral (Fraunces ~120 gold), displayItalic; bump display 64\u219272 / ls \u22121.6 toward 5:1 ratio.",
        "VERIFY assets/fonts/Fraunces.ttf is the variable font before using FontVariation('opsz'/'SOFT'); add an italic asset entry (style: italic) to pubspec for displayItalic \u2014 otherwise fall back to weight/letterSpacing drama. This resolves the audits' unverified variable-axis assumption."
      ],
      "impact": "critical"
    },
    {
      "step": 3,
      "title": "Re-theme background to organic + page-wide grain",
      "files": [
        "/Users/deepaksingh/Documents/Flutter/projects/rootaura/lib/widgets/animated_background.dart",
        "/Users/deepaksingh/Documents/Flutter/projects/rootaura/lib/screens/home_screen.dart"
      ],
      "changes": [
        "REWRITE _BackgroundPainter: remove the pulsing dot-grid (lines 127-145, the SaaS cliche), keep+expand the _glow approach to 3-4 forest/gold/mint blobs on sine drift, add a separate SEEDED static film-grain layer for matte-paper texture; keep RepaintBoundary + reduced-motion gating.",
        "In home_screen.dart wire AnimatedBackground behind the hero region (it is built but currently unused) and add a Positioned.fill GrainOverlay above scroll content."
      ],
      "impact": "high"
    },
    {
      "step": 4,
      "title": "Choreography: rewrite ScrollReveal + shared lift/press + page transition",
      "files": [
        "/Users/deepaksingh/Documents/Flutter/projects/rootaura/lib/widgets/scroll_reveal.dart",
        "/Users/deepaksingh/Documents/Flutter/projects/rootaura/lib/widgets/lift_card.dart",
        "/Users/deepaksingh/Documents/Flutter/projects/rootaura/lib/widgets/responsive_grid.dart",
        "/Users/deepaksingh/Documents/Flutter/projects/rootaura/lib/core/router/app_router.dart"
      ],
      "changes": [
        "REWRITE scroll_reveal.dart to a single AnimationController driving opacity+translateY(24)+scale(0.98\u21921) with Interval stagger on AppCurves.entrance; make the unused delay drive the cascade; add a StaggeredReveal that wraps a child list with index\u00d7~75ms.",
        "CREATE lift_card.dart (LiftCard/PressableCard): one controller mapping hover\u2192translateY+scale 1.015+e2\u2192e4 shadow and tapDown\u2192pressedScale 0.97, all from tokens; reduced-motion aware.",
        "responsive_grid.dart: add optional stagger:true so each cell wraps in StaggeredReveal with its global index.",
        "EDIT app_router.dart _fade (line 130): upgrade the existing CustomTransitionPage to combined fade + 12px slide + 1.01\u21921.0 scale on AppCurves.emphasized over AppDurations.page (NOTE: router lives here, NOT at lib/src/app_router.dart as audits stated)."
      ],
      "impact": "critical"
    },
    {
      "step": 5,
      "title": "Brand primitives: icon set, shimmer, empty-state, status badge",
      "files": [
        "/Users/deepaksingh/Documents/Flutter/projects/rootaura/lib/widgets/brand_icons.dart",
        "/Users/deepaksingh/Documents/Flutter/projects/rootaura/lib/widgets/shimmer.dart",
        "/Users/deepaksingh/Documents/Flutter/projects/rootaura/lib/widgets/organic_empty_state.dart",
        "/Users/deepaksingh/Documents/Flutter/projects/rootaura/lib/widgets/status_badge.dart",
        "/Users/deepaksingh/Documents/Flutter/projects/rootaura/assets/svg/"
      ],
      "changes": [
        "Add thin-line SVGs (seed-basket, parcel, truck, droplet, sun, shield, shopping-bag, user, menu, arrow, gold Google mark) to assets/svg; CREATE brand_icons.dart helper via SvgPicture tinted to brand tokens; register new assets in pubspec.",
        "CREATE shimmer.dart (ShaderMask sweep, ~1400ms loop) + prebuilt skeletons.",
        "CREATE organic_empty_state.dart (CustomPainter pouch+leaf-sprig over mintTint radial + Fraunces title + CTA).",
        "REWRITE status_badge.dart onto the single earthy ramp (placed=gold, confirmed/packed/shipped green ladder, delivered=darkGreen, cancelled=berry, paid=primaryGreen, pending=gold) as dot+8% fill+24% border+uppercase eyebrow; expose a StatusStyle map reused by the order timeline. Removes ALL foreign blue/indigo."
      ],
      "impact": "high"
    },
    {
      "step": 6,
      "title": "Core components consume the system (cards, buttons, price, header, footer)",
      "files": [
        "/Users/deepaksingh/Documents/Flutter/projects/rootaura/lib/widgets/content_cards.dart",
        "/Users/deepaksingh/Documents/Flutter/projects/rootaura/lib/widgets/product_card.dart",
        "/Users/deepaksingh/Documents/Flutter/projects/rootaura/lib/widgets/app_buttons.dart",
        "/Users/deepaksingh/Documents/Flutter/projects/rootaura/lib/widgets/image_carousel.dart",
        "/Users/deepaksingh/Documents/Flutter/projects/rootaura/lib/widgets/app_header.dart",
        "/Users/deepaksingh/Documents/Flutter/projects/rootaura/lib/widgets/app_footer.dart"
      ],
      "changes": [
        "content_cards.dart: replace _cardShadow (lines 10-16) with AppElevation.e2 (raised\u2192e3/e4) and route _Tile/InfoCard through LiftCard; on InfoCard hover scale+gold-tint the IconBadge and switch border to gold.",
        "product_card.dart: replace the lone green shadow (lines 64-72) and -10px translate (line 56) with LiftCard (e2\u2192e4); swap berry discount badge (lines 164-186) for the goldSoft DiscountChip; render name in Fraunces; replace inline _priceRow (124-151) with shared PriceTag; replace full Add-to-Cart PrimaryButton with an icon-only hover-reveal add that runs the fly-to-cart spring.",
        "app_buttons.dart: replace ad-hoc -2px translate + green shadow with tokenised hoverLift + pressedScale (AnimatedScale 0.97 on tapDown); primary CTA uses goldFoil gradient + optional breathing glow (reduced-motion gated).",
        "image_carousel.dart: replace flat 2-stop gradient with RadialGradient spotlight + CustomPainter contact shadow; drive the inner zoom from the parent LiftCard hover; glass arrows (BackdropFilter) + gold-lozenge dots (overshoot); shimmer placeholder replacing raw CircularProgressIndicator; swap Material chevron/eco/broken_image for BrandIcons.",
        "app_header.dart: replace bool _solid flip with ValueNotifier<double> t=(offset/96).clamp(0,1) + AnimatedBuilder lerping height/padding/blur/background(translucentSurface)/shadow/logo-scale; rewrite _logo into _BrandLockup (gold-ring leaf seal + wordmark via context.brand.textPrimary, NOT hardcoded darkGreen); add sliding magic underline for hover+active section; cart-badge TweenAnimationBuilder pop; _PressScale + BrandIcons on all actions; premium staggered mobile drawer; reduced-motion guards.",
        "app_footer.dart: layered canvas (gradient + bleeding leafSprig SVG @6% + goldSoft top hairline); column titles\u2192eyebrowGold; _brand() drops toUpperCase/w800 for native Fraunces w600 and uses leaf.svg (matching header); add 'Stay rooted.' newsletter row + trust/social strip; staggered fade-up reveal on enter."
      ],
      "impact": "high"
    },
    {
      "step": 7,
      "title": "Home + sections: hero showpiece, staggered grids, editorial rhythm",
      "files": [
        "/Users/deepaksingh/Documents/Flutter/projects/rootaura/lib/sections/hero_section.dart",
        "/Users/deepaksingh/Documents/Flutter/projects/rootaura/lib/sections/products_section.dart",
        "/Users/deepaksingh/Documents/Flutter/projects/rootaura/lib/sections/about_section.dart",
        "/Users/deepaksingh/Documents/Flutter/projects/rootaura/lib/sections/usage_section.dart",
        "/Users/deepaksingh/Documents/Flutter/projects/rootaura/lib/sections/testimonials_section.dart",
        "/Users/deepaksingh/Documents/Flutter/projects/rootaura/lib/sections/values_band.dart",
        "/Users/deepaksingh/Documents/Flutter/projects/rootaura/lib/sections/trust_strip.dart",
        "/Users/deepaksingh/Documents/Flutter/projects/rootaura/lib/widgets/section.dart"
      ],
      "changes": [
        "hero_section.dart: rebuild as showpiece \u2014 AnimatedBackground base (drop static _blob circles), ParallaxLayer driven by HomeScreen scroll (aurora 0.15x / bowl 0.35x / sparkle 0.5-0.7x / headline 0.1x), looping \u00b18px float on bowl/sparkles, soft elliptical ground-shadow, display 72/ls \u22121.6 with line-2 as Fraunces italic + primaryGreen, per-word headline stagger, animated scroll-down cue.",
        "products/why/usage/recipes/storage/testimonials: remove the single outer ScrollReveal wrap and pass stagger:true to ResponsiveGrid so cards cascade (index\u00d7~75ms, slide+fade+scale).",
        "section.dart: add a left-aligned EditorialSectionHeader variant + optional oversized Fraunces accentNumeral to break the 9\u00d7 identical centered rhythm; give usage a number-led 01/02/03 layout; vary maxWidth per section.",
        "about_section.dart: FramedImage (gold ring + ground-shadow + optional duotone) + left-aligned header + image overlap.",
        "testimonials_section.dart: promote one quote to a full-bleed forest-green Fraunces-italic PullQuote band.",
        "values_band.dart + trust_strip.dart: swap Material icons for BrandIcons, stagger-reveal the items, one-time gold sweep across the ValuesBand headline."
      ],
      "impact": "high"
    },
    {
      "step": 8,
      "title": "Product detail (PDP): gallery + sticky buy + story",
      "files": [
        "/Users/deepaksingh/Documents/Flutter/projects/rootaura/lib/screens/product_detail_screen.dart"
      ],
      "changes": [
        "Rebuild into a CustomScrollView: left gallery (large ImageCarousel + GalleryThumbnailRail with gold selected ring + AnimatedSwitcher cross-fade), right STICKY buy panel (SliverPersistentHeader desktop / AnimatedSlide bottom bar mobile) with PriceTag + QtyStepper + goldFoil primary CTA; wrap benefit/story/usage in staggered ScrollReveal; replace flat cardSoft benefit box + check_circle with a gold-accented callout; Total in Fraunces."
      ],
      "impact": "high"
    },
    {
      "step": 9,
      "title": "Buying flow: cart, checkout, order summary, success",
      "files": [
        "/Users/deepaksingh/Documents/Flutter/projects/rootaura/lib/widgets/qty_stepper.dart",
        "/Users/deepaksingh/Documents/Flutter/projects/rootaura/lib/widgets/animated_money.dart",
        "/Users/deepaksingh/Documents/Flutter/projects/rootaura/lib/widgets/order_summary.dart",
        "/Users/deepaksingh/Documents/Flutter/projects/rootaura/lib/screens/cart_screen.dart",
        "/Users/deepaksingh/Documents/Flutter/projects/rootaura/lib/screens/checkout_screen.dart",
        "/Users/deepaksingh/Documents/Flutter/projects/rootaura/lib/screens/order_success_screen.dart",
        "/Users/deepaksingh/Documents/Flutter/projects/rootaura/lib/widgets/success_celebration.dart"
      ],
      "changes": [
        "CREATE animated_money.dart (TweenAnimationBuilder count-up + green tint on change); route every rupee value through it.",
        "qty_stepper.dart: AnimatedSwitcher odometer digit roll + AnimatedScale button press + HapticFeedback; brand.textSecondary disabled colour; e2 shadow.",
        "order_summary.dart: AppElevation depth, gold-accent Total band (goldFoil hairline + Fraunces numerals), FreeDeliveryProgress meter, in-button busy spinner (no layout jump).",
        "cart_screen.dart: ScrollReveal stagger rows, AnimatedSize+opacity removal with undo SnackBar, sticky desktop summary + sticky mobile bottom Total+CTA bar, OrganicEmptyState.",
        "checkout_screen.dart: staggered reveals, AnimatedContainer selection on address/payment tiles + gold left-accent bar, pinned desktop summary + MobileCheckoutBar, OrganicEmptyState.",
        "CREATE success_celebration.dart and rebuild order_success_screen.dart: elasticOut medallion + drawn-check CustomPainter + one-shot leaf/gold burst + staggered receipt with AnimatedMoney; all controllers disposed + reduced-motion gated."
      ],
      "impact": "high"
    },
    {
      "step": 10,
      "title": "Account + admin: depth, timeline, KPIs, skeletons",
      "files": [
        "/Users/deepaksingh/Documents/Flutter/projects/rootaura/lib/widgets/order_timeline.dart",
        "/Users/deepaksingh/Documents/Flutter/projects/rootaura/lib/screens/order_detail_screen.dart",
        "/Users/deepaksingh/Documents/Flutter/projects/rootaura/lib/screens/orders_screen.dart",
        "/Users/deepaksingh/Documents/Flutter/projects/rootaura/lib/screens/profile_screen.dart",
        "/Users/deepaksingh/Documents/Flutter/projects/rootaura/lib/screens/sign_in_screen.dart",
        "/Users/deepaksingh/Documents/Flutter/projects/rootaura/lib/widgets/surface_card.dart",
        "/Users/deepaksingh/Documents/Flutter/projects/rootaura/lib/widgets/kpi_stat_card.dart",
        "/Users/deepaksingh/Documents/Flutter/projects/rootaura/lib/screens/admin/admin_screen.dart",
        "/Users/deepaksingh/Documents/Flutter/projects/rootaura/lib/screens/admin/admin_products_tab.dart",
        "/Users/deepaksingh/Documents/Flutter/projects/rootaura/lib/screens/admin/admin_customers_tab.dart",
        "/Users/deepaksingh/Documents/Flutter/projects/rootaura/lib/screens/admin/admin_orders_tab.dart"
      ],
      "changes": [
        "CREATE order_timeline.dart: vertical animated fulfilment journey (animated green rail fill, breathing gold current-node ring, per-step timestamps, BrandIcons step glyphs) reusing StatusStyle.",
        "order_detail_screen.dart: extract timeline, apply e2 to _card, Total in Fraunces + tabular order ID, OrderDetailSkeleton + EmptyState for not-found, press-scale CTAs.",
        "orders_screen.dart: StaggerColumn + ListView.builder, LiftCard tiles, OrderTileSkeleton, premium EmptyState, animated 'view details' chevron.",
        "profile_screen.dart: member hero (gold-ring avatar, Fraunces greeting, 3-stat KpiStatCard strip), branded address cards + edit dialog, ProfileSkeleton, staggered entrance.",
        "sign_in_screen.dart: AnimatedSwitcher fade+slide phone\u2192OTP, segmented OtpField, animated focus ring, gradient scrim + gold bloom on brand panel, in-button busy state, gold Google mark.",
        "CREATE surface_card.dart (shared elevated card with optional interactive lift) + kpi_stat_card.dart (gold top-rule + tabular count-up).",
        "admin_screen.dart: insert 4-card KPI band (count-up) + AdminTabSwitcher gold-pill control + AnimatedSwitcher tab cross-fade.",
        "admin products/customers/orders tabs: SurfaceCard + hover-lift rows, responsive DataTableShell (aligned columns \u2265768px, card fallback below), AppTextStyles.numeric for money/IDs, FilterChipBar, SkeletonList + branded empty/error states, swap indigo 'Admin' tag for gold."
      ],
      "impact": "medium"
    }
  ],
  "antiPatterns": [
    "Do NOT clone Apple \u2014 no frosted-glass-everything, no SF-style geometric sans, no centered hero with a floating product on pure white. The look must read botanical/organic-luxury (warm grain, leaf motif, foiled gold, serif drama), not Cupertino minimalism.",
    "Do NOT keep the SaaS dot-grid background \u2014 it actively fights the natural brand; replace with organic aurora blobs + matte film-grain.",
    "Do NOT leave flat single-layer shadows or hand-rolled magic-number shadows (0.16/0.07/0.35/0.22); every surface must consume the shared 2-layer AppElevation scale.",
    "Do NOT use raw Curves.easeOut/easeOutCubic/easeInOut or loose ms anywhere \u2014 all motion goes through app_motion.dart tokens.",
    "Do NOT introduce foreign status colours (blues/indigos/teal #2563EB/#4F46E5/#0E7C86); keep all semantics inside the forest-green/gold/berry family.",
    "Do NOT keep berry as a loud discount sticker; demote berry to destructive-only and use a restrained goldSoft 'save N%' chip.",
    "Do NOT ship generic Material icons (eco/ac_unit/verified_user/g_mobiledata/receipt_long/check_circle/shopping_cart) \u2014 use the cohesive thin-line BrandIcons SVG set; header and footer leaf must match.",
    "Do NOT reveal everything identically as one block \u2014 grids/lists must stagger; nothing should enter uniformly.",
    "Do NOT animate without a reduced-motion guard or without disposing controllers (parallax, float, confetti, per-frame header lerps) \u2014 extend AnimatedBackground's existing pattern.",
    "Do NOT assume Fraunces variable axes (opsz/SOFT) or an italic face exist \u2014 VERIFY the bundled .ttf and add an italic pubspec asset first; otherwise fall back to weight/letterSpacing. Avoid runtime-fetched fonts (keep everything bundled).",
    "Do NOT trust the audits' file path lib/src/app_router.dart \u2014 the real router is lib/core/router/app_router.dart and it already has a _fade CustomTransitionPage (line 130) to upgrade, not recreate.",
    "Do NOT bloat the BrandColors ThemeExtension lerp/copyWith with non-color elevation lists \u2014 keep elevation in app_elevation.dart so colour tokens stay clean.",
    "Do NOT over-gild: gold is a single accent 'catching the light' (foiled, on CTAs/eyebrows/Total/active states), never a flat fill spread across the UI.",
    "Do NOT replace spinners with more spinners \u2014 use branded shimmer skeletons sized to the real layout for any >300ms load."
  ]
}