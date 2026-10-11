import 'package:flutter/material.dart';

/// Transition de page : fondu et léger glissement, dans les deux sens.
class TransitionNexus extends PageTransitionsBuilder {
  /// Transition partagée par toutes les plateformes.
  const TransitionNexus();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final courbe = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    return FadeTransition(
      opacity: courbe,
      child: SlideTransition(
        position: Tween(begin: const Offset(0, 0.03), end: Offset.zero).animate(courbe),
        child: child,
      ),
    );
  }
}

/// Apparition d'un bloc : fondu et montée, décalée selon [index].
class Apparition extends StatefulWidget {
  /// Anime [child] une seule fois.
  const Apparition({super.key, required this.child, this.index = 0});

  /// Bloc animé.
  final Widget child;

  /// Place dans la liste. Le décalage est plafonné pour rester bref.
  final int index;

  @override
  State<Apparition> createState() => _ApparitionState();
}

class _ApparitionState extends State<Apparition> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
  );

  @override
  void initState() {
    super.initState();
    final delai = Duration(milliseconds: 40 * widget.index.clamp(0, 6));
    Future<void>.delayed(delai, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final courbe = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    return FadeTransition(
      opacity: courbe,
      child: SlideTransition(
        position: Tween(begin: const Offset(0, 0.08), end: Offset.zero).animate(courbe),
        child: widget.child,
      ),
    );
  }
}

/// Fenêtre qui apparaît en fondu et en léger agrandissement.
class EntreeDialog extends StatelessWidget {
  /// Anime [child].
  const EntreeDialog({super.key, required this.child});

  /// Contenu de la fenêtre.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      builder: (context, valeur, child) {
        return Opacity(
          opacity: valeur,
          child: Transform.scale(scale: 0.94 + 0.06 * valeur, child: child),
        );
      },
      child: child,
    );
  }
}
