import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:flutter_android_app/core/theme/indigo_or_chart.dart';

/// Zone où le client trace sa signature.
class ZoneSignature extends StatefulWidget {
  /// Signale [onChanged] dès qu'un trait existe.
  const ZoneSignature({super.key, required this.onChanged});

  /// Reçoit `true` quand la zone n'est plus vide.
  final ValueChanged<bool> onChanged;

  @override
  State<ZoneSignature> createState() => _ZoneSignatureState();
}

class _ZoneSignatureState extends State<ZoneSignature> {
  final List<List<Offset>> _traits = [];
  List<Offset>? _courant;

  var _signale = false;

  void _notifier() {
    final signe = _traits.isNotEmpty || (_courant?.isNotEmpty ?? false);
    if (signe == _signale) return;
    _signale = signe;
    widget.onChanged(signe);
  }

  @override
  Widget build(BuildContext context) {
    final traits = [..._traits, ?_courant];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Zone de signature'),
        const SizedBox(height: 8),
        DecoratedBox(
          decoration: BoxDecoration(
            color: IndigoOrChart.surfaceHaute,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: IndigoOrChart.contour),
          ),
          child: SizedBox(
            height: 140,
            width: double.infinity,
            child: RawGestureDetector(
              gestures: {
                _TraceRecognizer: GestureRecognizerFactoryWithHandlers<_TraceRecognizer>(
                  _TraceRecognizer.new,
                  (recognizer) {
                    recognizer.onStart = (details) {
                      setState(() => _courant = [details.localPosition]);
                      _notifier();
                    };
                    recognizer.onUpdate = (details) {
                      setState(() => _courant?.add(details.localPosition));
                      _notifier();
                    };
                    recognizer.onEnd = (_) {
                      final trait = _courant;
                      setState(() {
                        if (trait != null && trait.isNotEmpty) _traits.add(trait);
                        _courant = null;
                      });
                      _notifier();
                    };
                  },
                ),
              },
              child: CustomPaint(
                painter: _TracePainter(traits),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TraceRecognizer extends PanGestureRecognizer {
  @override
  void addAllowedPointer(PointerDownEvent event) {
    super.addAllowedPointer(event);
    resolve(GestureDisposition.accepted);
  }
}

class _TracePainter extends CustomPainter {
  _TracePainter(this.traits);

  final List<List<Offset>> traits;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = IndigoOrChart.primaire
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (final trait in traits) {
      if (trait.length < 2) {
        if (trait.isNotEmpty) {
          canvas.drawCircle(trait.first, 1.4, paint..style = PaintingStyle.fill);
          paint.style = PaintingStyle.stroke;
        }
        continue;
      }
      final path = Path()..moveTo(trait.first.dx, trait.first.dy);
      for (final point in trait.skip(1)) {
        path.lineTo(point.dx, point.dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_TracePainter oldDelegate) => true;
}
