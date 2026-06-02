import 'dart:async';
import 'package:flutter/material.dart';

/// CounterButtonWidget
/// Custom widget untuk input jumlah (quantity).
/// - Tap biasa  : +1 / -1
/// - Tap & Hold : auto-increment / decrement selama ditekan (gesture)
class CounterButtonWidget extends StatefulWidget {
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const CounterButtonWidget({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.max = 99,
  });

  @override
  State<CounterButtonWidget> createState() => _CounterButtonWidgetState();
}

class _CounterButtonWidgetState extends State<CounterButtonWidget>
    with SingleTickerProviderStateMixin {
  Timer? _holdTimer;
  bool _isHolding = false;

  // Animasi skala saat tombol ditekan
  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      lowerBound: 0.85,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    _scaleController.dispose();
    super.dispose();
  }

  // ── Logika tap biasa ──────────────────────────────────────────────────
  void _increment() {
    if (widget.value < widget.max) widget.onChanged(widget.value + 1);
  }

  void _decrement() {
    if (widget.value > widget.min) widget.onChanged(widget.value - 1);
  }

  // ── Logika tap & hold (gesture) ───────────────────────────────────────
  void _startHold(bool increment) {
    _isHolding = true;
    // Tembak pertama segera
    if (increment) {
      _increment();
    } else {
      _decrement();
    }
    // Lanjut auto setiap 120 ms selama masih ditekan
    _holdTimer = Timer.periodic(const Duration(milliseconds: 120), (_) {
      if (!_isHolding) return;
      if (increment) {
        _increment();
      } else {
        _decrement();
      }
    });
  }

  void _stopHold() {
    _isHolding = false;
    _holdTimer?.cancel();
    _holdTimer = null;
    _scaleController.forward();
  }

  // ── Builder tombol ─────────────────────────────────────────────────────
  Widget _buildActionButton({
    required IconData icon,
    required bool increment,
  }) {
    return GestureDetector(
      onTap: increment ? _increment : _decrement,
      onLongPressStart: (_) {
        _scaleController.reverse();
        _startHold(increment);
      },
      onLongPressEnd: (_) => _stopHold(),
      onLongPressCancel: _stopHold,
      child: ScaleTransition(
        scale: _scaleController,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF1B2A4A),
            borderRadius: BorderRadius.circular(13),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1B2A4A).withOpacity(0.25),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool atMin = widget.value <= widget.min;
    final bool atMax = widget.value >= widget.max;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Tombol Kurang ─────────────────────────────────────────────
        Opacity(
          opacity: atMin ? 0.4 : 1.0,
          child: _buildActionButton(icon: Icons.remove, increment: false),
        ),

        // ── Tampilan angka ────────────────────────────────────────────
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 58,
          height: 44,
          margin: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: const Color(0xFF1B2A4A).withOpacity(0.18),
              width: 1.5,
            ),
          ),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: Text(
                '${widget.value}',
                key: ValueKey(widget.value),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B2A4A),
                ),
              ),
            ),
          ),
        ),

        // ── Tombol Tambah ─────────────────────────────────────────────
        Opacity(
          opacity: atMax ? 0.4 : 1.0,
          child: _buildActionButton(icon: Icons.add, increment: true),
        ),
      ],
    );
  }
}
