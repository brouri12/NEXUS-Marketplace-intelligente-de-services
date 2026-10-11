import 'package:flutter/material.dart';

import 'package:flutter_android_app/core/gestion_module.dart';
import 'package:flutter_android_app/gestions/marketplace/back/marketplace_store.dart';
import 'package:flutter_android_app/gestions/marketplace/front/marketplace_page.dart';

/// Back partagé des produits et des commandes.
final marketplaceStore = MarketplaceStore();

/// Gestion de la boutique de produits des services.
final marketplaceModule = GestionModule(
  id: 'marketplace',
  title: MarketplacePage.title,
  icon: Icons.storefront_outlined,
  responsibilities: MarketplacePage.responsibilities,
  front: (context) => MarketplacePage(store: marketplaceStore),
  back: marketplaceStore,
);
