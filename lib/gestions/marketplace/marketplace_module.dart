import 'package:flutter/material.dart';

import 'package:flutter_android_app/core/gestion_module.dart';
import 'package:flutter_android_app/gestions/marketplace/back/marketplace_api.dart';
import 'package:flutter_android_app/gestions/marketplace/front/marketplace_page.dart';

const _back = MarketplaceApi();

/// Gestion de la recherche et de la mise en relation.
final marketplaceModule = GestionModule(
  id: 'marketplace',
  title: MarketplacePage.title,
  icon: Icons.storefront_outlined,
  responsibilities: MarketplacePage.responsibilities,
  front: (context) => const MarketplacePage(back: _back),
  back: _back,
);
