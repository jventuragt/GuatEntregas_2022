import 'dart:async';

import 'package:flutter/material.dart';

class IconAumentWidget extends StatefulWidget {
  final Icon icon;
  final double size;
  final Color color;

  IconAumentWidget(
    this.icon, {
    this.size = 25.0,
    this.color,
  }) : super();

  @override
  State<IconAumentWidget> createState() => _AnimatedIconState();
}

class _AnimatedIconState extends State<IconAumentWidget>
    with SingleTickerProviderStateMixin {
  final double dx = 10.0;
  Animation<double> animation;
  AnimationController animationController;

  @override
  initState() {
    super.initState();
    animationController = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    animation = Tween(begin: widget.size, end: widget.size + dx)
        .animate(animationController);
    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        animationController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        Future.delayed(const Duration(microseconds: 1000), () {
          if (!mounted) return;
          animationController?.forward();
        });
      }
    });
    animationController?.forward();
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _Animator(
        icon: widget.icon,
        animation: animation,
        color: widget.color,
        size: widget.size + dx);
  }
}

class _Animator extends AnimatedWidget {
  final double size;
  final Icon icon;
  final Color color;

  _Animator({
    Key key,
    this.icon,
    this.size,
    this.color,
    Animation<double> animation,
  }) : super(key: key, listenable: animation);

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = listenable;
    return Container(
      width: size,
      height: size,
      child: Icon(icon.icon, size: animation.value, color: icon.color),
    );
  }
}
