import 'package:ahmini/theme.dart';
import 'package:flutter/material.dart';

class MovingLineIndicator extends StatefulWidget {
  const MovingLineIndicator({super.key});
  @override
  _MovingLineIndicatorState createState() => _MovingLineIndicatorState();
}

class _MovingLineIndicatorState extends State<MovingLineIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true); // Repeats smoothly

    _animation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut, // Smooth transition
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 5, // Line thickness
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(10), // Rounds the corners
        ),
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Align(
              alignment:
                  Alignment(_animation.value * 2 - 1, 0), // Moves left to right
              child: Container(
                width: 75, // Line width
                height: 5, // Line height
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
