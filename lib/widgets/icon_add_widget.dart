import 'package:flutter/material.dart';

import '../bloc/promocion_bloc.dart';
import '../model/promocion_model.dart';
import '../utils/personalizacion.dart' as prs;

class IconAddWidget extends StatefulWidget {
  final PromocionModel promocionModel;

  final Function evaluarCosto;

  IconAddWidget(this.evaluarCosto, {Key key, @required this.promocionModel})
      : super(key: key);

  @override
  _IconAddWidgetState createState() =>
      _IconAddWidgetState(evaluarCosto, promocionModel: promocionModel);
}

class _IconAddWidgetState extends State<IconAddWidget>
    with SingleTickerProviderStateMixin {
  final PromocionBloc _promocionBloc = PromocionBloc();
  PromocionModel promocionModel;
  Function evaluarCosto;

  _IconAddWidgetState(this.evaluarCosto, {this.promocionModel});

  AnimationController animationController;
  Animation<double> sizeAnimation;

  int signo = 1;

  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(duration: Duration(milliseconds: 100), vsync: this);
    sizeAnimation = Tween<double>(begin: 0, end: 1.3).animate(CurvedAnimation(
        parent: animationController, curve: Curves.fastOutSlowIn))
      ..addListener(() {
        if (mounted) setState(() {});
      });
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Transform.scale(
          scale: sizeAnimation.value - (1 * signo),
          child: CircleAvatar(
            child: IconButton(
              icon: Icon(Icons.remove, color: Colors.white),
              onPressed: () async {
                signo = -1;
                animationController.forward();
                Future.delayed(const Duration(milliseconds: 120), () {
                  animationController?.reverse();
                });
                if (promocionModel.cantidad == 1) return;
                promocionModel.cantidad--;
                await _promocionBloc.actualizar(promocionModel);
                evaluarCosto();
              },
            ),
            backgroundColor: prs.colorButtonSecondary,
          ),
        ),
        SizedBox(width: 20.0),
        Text('${promocionModel.cantidad}',
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
        SizedBox(width: 20.0),
        Transform.scale(
          scale: sizeAnimation.value + (1 * signo),
          child: CircleAvatar(
            child: IconButton(
              icon: Icon(Icons.add, color: Colors.white),
              onPressed: () async {
                signo = 1;
                animationController.forward();
                Future.delayed(const Duration(milliseconds: 120), () {
                  animationController?.reverse();
                });
                if (promocionModel.cantidad.toString() ==
                    promocionModel.maximo.toString()) return;
                promocionModel.cantidad++;
                await _promocionBloc.actualizar(promocionModel);
                evaluarCosto();
              },
            ),
            backgroundColor: prs.colorButtonSecondary,
          ),
        ),
      ],
    );
  }
}
