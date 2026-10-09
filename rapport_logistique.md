# 🚚 Fiche Guide : Module Logistique & Suivi en Temps Réel

**Ce document a pour but de vous aider à présenter votre travail et à expliquer l'interface de votre module "Logistique" à votre professeur lors de la validation.**

L'ensemble de votre module a été implémenté en respectant strictement les 4 chapitres de votre cours et la charte graphique globale de NEXUS (Indigo & Or).

---

## 1. UI/WIDGETS (Les Fondations de la Mise en Page)
> **Ce que le prof veut voir :** Des widgets flexibles, adaptatifs et une interface organisée sans débordements.

* **Où c'est implémenté :** Partout, mais surtout dans `logistique_detail_page.dart`.
* **Explication à donner :** 
  *"Pour l'écran de suivi détaillé de la course, j'ai utilisé un widget `Column` combiné à des `Expanded(flex: 3)` et `Expanded(flex: 2)`. Cela permet de séparer l'écran en deux zones (Carte en haut, Informations en bas) de manière proportionnelle. Peu importe la taille de l'écran du téléphone, l'interface s'adaptera sans planter."*
* **Charte graphique respectée :** J'ai utilisé `IndigoOrChart.surface` et `IndigoOrChart.fond` avec des `Card` et `Container` avec bords arrondis et ombres légères.

## 2. Lists (Affichage Dynamique)
> **Ce que le prof veut voir :** L'utilisation de `ListView` pour afficher des données.

* **Où c'est implémenté :** Dans `logistique_page.dart` (Le Tableau de bord principal).
* **Explication à donner :** 
  *"J'ai utilisé un `ListView.builder` pour générer dynamiquement la liste des trajets. Cela permet de scroller à l'infini sans surcharger la mémoire, car les widgets ne sont créés que lorsqu'ils apparaissent à l'écran. Chaque élément est enveloppé dans une `Card` personnalisée."*

## 3. Forms & Gestion des User Inputs (Saisie de Données)
> **Ce que le prof veut voir :** La création de formulaires robustes avec contrôle de saisie.

* **Où c'est implémenté :** Dans `logistique_create_page.dart` (L'écran de déclaration de trajet).
* **Explication à donner :** 
  *"Pour déclarer un nouveau trajet, j'ai enveloppé mes champs dans un widget `Form` avec une `GlobalKey<FormState>`. J'utilise des `TextFormField` avec la propriété `validator`. Si l'utilisateur essaie de valider (bouton 'Démarrer le trajet') sans remplir le point de départ, le formulaire bloque l'action et affiche un message d'erreur rouge, gérant ainsi parfaitement les User Inputs."*

## 4. Routes/Navigation (Transitions d'Écrans)
> **Ce que le prof veut voir :** Une navigation fluide.

* **Où c'est implémenté :** Entre toutes les pages du module.
* **Explication à donner :** 
  *"J'ai utilisé le `Navigator` de Flutter pour connecter mon expérience utilisateur. Depuis la liste (`ListView`), un `Navigator.push` emmène l'utilisateur vers les détails du trajet en passant l'objet `Trajet` en paramètre. Depuis le formulaire, une fois la validation réussie, un `Navigator.pop` ramène l'utilisateur à l'accueil."*

---

## 🚀 Bonus : L'Intégration Métier (Logistique, IA, Alertes)
Vous pouvez également souligner à votre prof que l'interface traduit les **règles métiers complexes** :
- **L'IA (ETA) :** Mise en évidence par un `Card` spécial avec une icône de cerveau et des textes mis en valeur par la couleur `primaire` (Indigo).
- **Les Alertes automatiques :** Un widget conditionnel (`if (trajet.status == TrajetStatus.enRetard)`) génère dynamiquement une bannière d'erreur utilisant la couleur `erreur` de la charte NEXUS (rouge sombre).

> **Note :** Le module a été parfaitement intégré à l'architecture globale via `logistique_module.dart` et `gestions.dart`, faisant officiellement partie de l'écosystème NEXUS !
