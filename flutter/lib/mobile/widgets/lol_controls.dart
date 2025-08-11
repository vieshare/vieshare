import 'package:flutter/material.dart';
import 'package:flutter_hbb/models/input_model.dart';
import 'dart:math' as math;

import '../../models/model.dart';

class LoLControlsOverlay extends StatefulWidget {
  final FFI ffi;
  final VoidCallback? onClose;

  const LoLControlsOverlay({
    Key? key,
    required this.ffi,
    this.onClose,
  }) : super(key: key);

  @override
  State<LoLControlsOverlay> createState() => _LoLControlsOverlayState();
}

class _LoLControlsOverlayState extends State<LoLControlsOverlay> {
  InputModel get inputModel => widget.ffi.inputModel;
  
  // Joystick state for movement
  Offset _joystickCenter = Offset.zero;
  Offset _knobPosition = Offset.zero;
  bool _isDragging = false;
  final double _joystickRadius = 50.0;
  final double _knobRadius = 20.0;

  // Screen lock state
  bool _isScreenLocked = false;

  void _sendKey(String key) {
    inputModel.inputKey(key);
  }

  void _toggleScreenLock() {
    setState(() {
      _isScreenLocked = !_isScreenLocked;
    });
    // Send Y key to toggle camera lock in League of Legends
    _sendKey('VK_Y');
  }

  void _handleJoystickUpdate(Offset localPosition) {
    final distance = (localPosition - _joystickCenter).distance;
    if (distance <= _joystickRadius) {
      _knobPosition = localPosition;
    } else {
      final direction = (localPosition - _joystickCenter) / distance;
      _knobPosition = _joystickCenter + direction * _joystickRadius;
    }

    // Convert joystick movement to WASD keys
    final deltaX = _knobPosition.dx - _joystickCenter.dx;
    final deltaY = _knobPosition.dy - _joystickCenter.dy;
    const deadZone = 15.0;

    if (deltaX.abs() > deadZone || deltaY.abs() > deadZone) {
      // Calculate dominant direction
      if (deltaX.abs() > deltaY.abs()) {
        if (deltaX > 0) {
          _sendKey('VK_D'); // Right
        } else {
          _sendKey('VK_A'); // Left
        }
      } else {
        if (deltaY < 0) {
          _sendKey('VK_W'); // Up
        } else {
          _sendKey('VK_S'); // Down
        }
      }
    }
  }

  Widget _buildMovementJoystick() {
    return Container(
      width: _joystickRadius * 2.2,
      height: _joystickRadius * 2.2,
      child: GestureDetector(
        onPanStart: (details) {
          _joystickCenter = details.localPosition;
          _knobPosition = details.localPosition;
          _isDragging = true;
          setState(() {});
        },
        onPanUpdate: (details) {
          if (_isDragging) {
            _handleJoystickUpdate(details.localPosition);
            setState(() {});
          }
        },
        onPanEnd: (details) {
          _isDragging = false;
          _knobPosition = _joystickCenter;
          setState(() {});
        },
        child: CustomPaint(
          painter: JoystickPainter(
            center: _joystickCenter,
            knobPosition: _knobPosition,
            joystickRadius: _joystickRadius,
            knobRadius: _knobRadius,
            isDragging: _isDragging,
          ),
        ),
      ),
    );
  }

  Widget _buildSkillButton(String key, String label, Color color, {bool isUltimate = false}) {
    return GestureDetector(
      onTap: () => _sendKey(key),
      child: Container(
        width: isUltimate ? 60 : 50,
        height: isUltimate ? 60 : 50,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(isUltimate ? 15 : 12),
          border: Border.all(
            color: isUltimate ? Colors.amber : Colors.white.withOpacity(0.4),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isUltimate ? 24 : 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  blurRadius: 2.0,
                  color: Colors.black.withOpacity(0.8),
                  offset: Offset(1.0, 1.0),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScreenLockButton() {
    return GestureDetector(
      onTap: _toggleScreenLock,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: _isScreenLocked ? Colors.green : Colors.grey[700],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isScreenLocked ? Colors.greenAccent : Colors.white.withOpacity(0.4),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          _isScreenLocked ? Icons.lock : Icons.lock_open,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }


  Widget _buildUnifiedSkillArc(double screenWidth, double screenHeight) {
    return Positioned(
      right: 0, // Align tightly to right edge
      bottom: 0, // Align tightly to bottom edge
      child: Container(
        width: 180,
        height: 180,
        child: CustomPaint(
          painter: SkillArcPainter(),
          child: GestureDetector(
            onTapDown: (details) {
              final localPosition = details.localPosition;
              final segmentIndex = _getArcSegmentFromPosition(localPosition, 180, 180);
              
              print('Tapped segment: $segmentIndex at position: $localPosition'); // Debug
              
              if (segmentIndex >= 0) {
                switch (segmentIndex) {
                  case 0:
                    print('Sending Q key');
                    _sendKey('VK_Q');
                    break;
                  case 1:
                    print('Sending W key');
                    _sendKey('VK_W');
                    break;
                  case 2:
                    print('Sending E key');
                    _sendKey('VK_E');
                    break;
                  case 3:
                    print('Sending R key');
                    _sendKey('VK_R');
                    break;
                }
              }
            },
          ),
        ),
      ),
    );
  }

  int _getArcSegmentFromPosition(Offset position, double width, double height) {
    // Arc center is at bottom-right corner of the widget
    final double centerX = width; // Right edge
    final double centerY = height; // Bottom edge
    
    // Calculate angle from center to touch point
    final double dx = position.dx - centerX;
    final double dy = position.dy - centerY;
    double angle = math.atan2(dy, dx);
    
    // Normalize angle to 0-2π range
    if (angle < 0) angle += 2 * math.pi;
    
    // Check if click is within the arc radius range first
    double distance = math.sqrt(dx * dx + dy * dy);
    if (distance < 40 || distance > 90) {
      return -1; // Outside arc ring
    }
    
    // Our arc goes from 180° (π) to 270° (3π/2) - the bottom-left quarter
    // Convert angle to our coordinate system
    if (angle >= math.pi && angle <= 3 * math.pi / 2) {
      // Map angle to 0-3 segments
      double normalizedAngle = angle - math.pi; // 0 to π/2
      int segment = (normalizedAngle / (math.pi / 8)).floor();
      return segment.clamp(0, 3);
    }
    
    return -1; // Outside arc area
  }


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Positioned.fill(
      child: Container(
        child: Stack(
          children: [
            // Movement joystick - fixed bottom left corner for left hand
            Positioned(
              left: 30,
              bottom: 30,
              child: _buildMovementJoystick(),
            ),

            // Unified Q, W, E, R skill arc - single 90-degree segment with 4 parts
            _buildUnifiedSkillArc(screenWidth, screenHeight),

            // D button - upper-right
            Positioned(
              right: 25,
              top: screenHeight * 0.15, // Moved higher for better landscape spacing
              child: _buildSkillButton('VK_D', 'D', Color(0xFFFF9800)),
            ),

            // F button - lower-right (below D with much larger spacing for landscape)
            Positioned(
              right: 25,
              top: screenHeight * 0.15 + 80, // Fixed 80px gap instead of percentage for consistent spacing
              child: _buildSkillButton('VK_F', 'F', Color(0xFFFF5722)),
            ),

            // B (Back/Shop) and Screen lock buttons - bottom center
            Positioned(
              bottom: 25,
              left: screenWidth * 0.5 - 60, // Center horizontally
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildSkillButton('VK_B', 'B', Color(0xFF795548)),
                  SizedBox(width: 15),
                  _buildScreenLockButton(),
                ],
              ),
            ),

            // Close button - top left
            Positioned(
              top: 50,
              left: 25,
              child: GestureDetector(
                onTap: widget.onClose,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class JoystickPainter extends CustomPainter {
  final Offset center;
  final Offset knobPosition;
  final double joystickRadius;
  final double knobRadius;
  final bool isDragging;

  JoystickPainter({
    required this.center,
    required this.knobPosition,
    required this.joystickRadius,
    required this.knobRadius,
    required this.isDragging,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Draw outer circle (joystick base)
    paint.color = Colors.black.withOpacity(0.3);
    canvas.drawCircle(center, joystickRadius, paint);

    // Draw inner circle (boundary)
    paint.color = Colors.white.withOpacity(0.2);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    canvas.drawCircle(center, joystickRadius, paint);

    // Draw knob
    paint.style = PaintingStyle.fill;
    paint.color = isDragging 
        ? Colors.blue.withOpacity(0.8)
        : Colors.white.withOpacity(0.7);
    canvas.drawCircle(knobPosition.isFinite ? knobPosition : center, knobRadius, paint);

    // Draw knob border
    paint.style = PaintingStyle.stroke;
    paint.color = Colors.white.withOpacity(0.9);
    paint.strokeWidth = 1.5;
    canvas.drawCircle(knobPosition.isFinite ? knobPosition : center, knobRadius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class SkillArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint arcPaint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final Paint borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = Colors.white.withOpacity(0.6)
      ..isAntiAlias = true;

    final Paint separatorPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white.withOpacity(0.3)
      ..isAntiAlias = true;

    // Arc center point (at bottom-right corner of the widget)
    final Offset center = Offset(size.width, size.height);
    final double radius = 90; // Increased from 70 for larger tap areas
    final double innerRadius = 40; // Increased from 30 for better proportions

    // Define colors for each segment
    final List<Color> segmentColors = [
      Color(0xFF4A90E2), // Q - Blue
      Color(0xFF9B59B6), // W - Purple  
      Color(0xFF27AE60), // E - Green
      Color(0xFFE74C3C), // R - Red
    ];

    final List<String> segmentLabels = ['Q', 'W', 'E', 'R'];

    // Draw each segment of the arc
    for (int i = 0; i < 4; i++) {
      final double startAngle = math.pi + (i * math.pi / 8); // Start from 180° (π), each segment is π/8 (22.5°)
      final double sweepAngle = math.pi / 8; // 22.5 degrees in radians

      // Create gradient for each segment
      arcPaint.shader = RadialGradient(
        colors: [
          segmentColors[i].withOpacity(0.9),
          segmentColors[i].withOpacity(0.7),
        ],
        stops: [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

      // Draw the arc segment
      final Path arcPath = Path();
      arcPath.moveTo(center.dx + innerRadius * math.cos(startAngle), 
                     center.dy + innerRadius * math.sin(startAngle));
      arcPath.arcTo(
        Rect.fromCircle(center: center, radius: innerRadius),
        startAngle,
        sweepAngle,
        false,
      );
      arcPath.arcTo(
        Rect.fromCircle(center: center, radius: radius),
        startAngle + sweepAngle,
        -sweepAngle,
        false,
      );
      arcPath.close();

      canvas.drawPath(arcPath, arcPaint);

      // Draw separator lines between segments (except after last segment)
      if (i < 3) {
        final double separatorAngle = startAngle + sweepAngle;
        final Offset innerPoint = Offset(
          center.dx + innerRadius * math.cos(separatorAngle),
          center.dy + innerRadius * math.sin(separatorAngle),
        );
        final Offset outerPoint = Offset(
          center.dx + radius * math.cos(separatorAngle),
          center.dy + radius * math.sin(separatorAngle),
        );
        canvas.drawLine(innerPoint, outerPoint, separatorPaint);
      }

      // Draw labels
      final double labelAngle = startAngle + sweepAngle / 2;
      final double labelRadius = (innerRadius + radius) / 2;
      final Offset labelPosition = Offset(
        center.dx + labelRadius * math.cos(labelAngle),
        center.dy + labelRadius * math.sin(labelAngle),
      );

      final TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: segmentLabels[i],
          style: TextStyle(
            color: Colors.white,
            fontSize: i == 3 ? 26 : 22, // R (Ultimate) larger, all buttons bigger
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                blurRadius: 2.0,
                color: Colors.black.withOpacity(0.8),
                offset: Offset(1.0, 1.0),
              ),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(labelPosition.dx - textPainter.width / 2,
               labelPosition.dy - textPainter.height / 2),
      );
    }

    // Draw outer border
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi / 2,
      false,
      borderPaint,
    );

    // Draw inner border
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: innerRadius),
      math.pi,
      math.pi / 2,
      false,
      borderPaint,
    );

    // Draw side borders
    canvas.drawLine(
      Offset(center.dx + innerRadius * math.cos(math.pi), center.dy + innerRadius * math.sin(math.pi)),
      Offset(center.dx + radius * math.cos(math.pi), center.dy + radius * math.sin(math.pi)),
      borderPaint,
    );
    canvas.drawLine(
      Offset(center.dx + innerRadius * math.cos(math.pi / 2), center.dy + innerRadius * math.sin(math.pi / 2)),
      Offset(center.dx + radius * math.cos(math.pi / 2), center.dy + radius * math.sin(math.pi / 2)),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}