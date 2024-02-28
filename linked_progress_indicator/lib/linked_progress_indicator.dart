// ignore_for_file: library_private_types_in_public_api

library linked_progress_indicator;

import 'package:flutter/material.dart';

class LinkedProgressIndicator extends StatefulWidget {
  final int numberOfIndicators;
  final Duration animatingDuration;
  final Color? animatingColor;
  final Color? backgroundColor;

  const LinkedProgressIndicator({
    required this.numberOfIndicators,
    required this.animatingDuration,
    this.animatingColor,
    this.backgroundColor,
    super.key,
  });

  @override
  _LinkedProgressIndicatorState createState() =>
      _LinkedProgressIndicatorState();
}

class _LinkedProgressIndicatorState extends State<LinkedProgressIndicator>
    with TickerProviderStateMixin {
  List<AnimationController> controllers = [];

  double get progressWidth =>
      (MediaQuery.of(context).size.width / widget.numberOfIndicators) -
      widget.numberOfIndicators;

  @override
  void initState() {
    super.initState();

    // Create a list of AnimationControllers
    for (int i = 0; i < widget.numberOfIndicators; i++) {
      controllers.add(
        AnimationController(
          vsync: this,
          duration: widget.animatingDuration,
        )..addListener(() {
            setState(() {});
          }),
      );
    }

    // Start the first animation
    controllers.first.forward();

    // Chain the animations one after another
    for (int i = 0; i < controllers.length - 1; i++) {
      controllers[i].addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          // controllers[i].reset();
          controllers[i + 1].forward();
        }
      });
    }

    // Loop back to the first animation after the last one completes
    controllers.last.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        for (var controller in controllers) {
          // controller.value = 0;
          controller.reset();
        }
        controllers.first.forward();
      }
    });
  }

  @override
  void dispose() {
    // Dispose all controllers
    for (var controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> progressIndicators = List.generate(
      controllers.length,
      (index) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1.0),
        child: SizedBox(
          width: progressWidth,
          child: LinearProgressIndicator(
            value: controllers[index].value,
            color: widget.animatingColor,
            backgroundColor: widget.backgroundColor,
          ),
        ),
      ),
    );

    return Wrap(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: progressIndicators,
        ),
      ],
    );
  }
}
