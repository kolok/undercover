import 'package:flutter/material.dart';

/// Logo de l'application : un masque de théâtre unique qui réunit la comédie
/// et la tragédie — un œil qui rigole, un œil qui pleure.
///
/// Dessin « flat color » : des aplats sans contour, plus une couleur d'accent
/// pour la larme.
class TheaterMaskLogo extends StatelessWidget {
  const TheaterMaskLogo({
    super.key,
    required this.color,
    this.tearColor = const Color(0xFF57C7FF),
    this.size = 88,
  });

  /// Couleur pleine du masque.
  final Color color;

  /// Couleur de la larme.
  final Color tearColor;

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _TheaterMaskPainter(color, tearColor)),
    );
  }
}

/// Le masque est dessiné dans un repère de 100x100 puis mis à l'échelle.
class _TheaterMaskPainter extends CustomPainter {
  const _TheaterMaskPainter(this.color, this.tearColor);

  final Color color;
  final Color tearColor;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 100, size.height / 100);

    // Les traits du visage sont évidés dans l'aplat du masque.
    final features = Path()
      ..addPath(_laughingEye(), Offset.zero)
      ..addPath(_cryingEye(), Offset.zero)
      ..addPath(_mouth(), Offset.zero);

    canvas.drawPath(
      Path.combine(PathOperation.difference, _face(), features),
      Paint()..color = color,
    );
    canvas.drawPath(_tear(), Paint()..color = tearColor);

    canvas.restore();
  }

  Path _face() => Path()
    ..moveTo(12, 40)
    // Front large, aux tempes marquées.
    ..cubicTo(12, 14, 28, 6, 50, 6)
    ..cubicTo(72, 6, 88, 14, 88, 40)
    // Joue droite qui descend vers le menton.
    ..cubicTo(88, 70, 70, 95, 50, 95)
    // Joue gauche qui remonte vers le front.
    ..cubicTo(30, 95, 12, 70, 12, 40)
    ..close();

  /// Œil de la comédie : arc fermé tourné vers le haut.
  Path _laughingEye() => Path()
    ..moveTo(22, 50)
    ..quadraticBezierTo(34, 28, 46, 50)
    ..quadraticBezierTo(34, 42, 22, 50)
    ..close();

  /// Œil de la tragédie : arc fermé tombant vers le bas.
  Path _cryingEye() => Path()
    ..moveTo(54, 41)
    ..quadraticBezierTo(66, 59, 78, 41)
    ..quadraticBezierTo(66, 47, 54, 41)
    ..close();

  /// Larme qui coule sous le coin de l'œil triste.
  Path _tear() => Path()
    ..moveTo(75, 52)
    ..cubicTo(78, 58, 80, 62, 80, 65)
    ..cubicTo(80, 68, 78, 70, 75, 70)
    ..cubicTo(72, 70, 70, 68, 70, 65)
    ..cubicTo(70, 62, 72, 58, 75, 52)
    ..close();

  /// Bouche ouverte, inclinée : le coin gauche sourit, le coin droit retombe.
  Path _mouth() {
    final mouth = Path()
      ..moveTo(-18, 0)
      ..quadraticBezierTo(0, -5, 18, 0)
      ..quadraticBezierTo(0, 17, -18, 0)
      ..close();
    final transform = Matrix4.identity()
      ..translateByDouble(48, 76, 0, 1)
      ..rotateZ(0.17);
    return mouth.transform(transform.storage);
  }

  @override
  bool shouldRepaint(_TheaterMaskPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.tearColor != tearColor;
}
