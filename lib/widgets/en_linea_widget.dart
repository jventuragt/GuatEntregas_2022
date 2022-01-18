import 'dart:async';

import 'package:flutter/material.dart';

import '../bloc/connect_bloc.dart';
import '../utils/global.dart';

class EnLineaWidget extends StatefulWidget {
  final StreamController<bool> cambios;

  EnLineaWidget({this.cambios}) : super();

  EnLineaWidgetState createState() => EnLineaWidgetState(cambios: cambios);
}

class EnLineaWidgetState extends State<EnLineaWidget>
    with TickerProviderStateMixin {
  AnimationController animationController;
  StreamController<bool> cambios;

  EnLineaWidgetState({this.cambios}) {
    animationController =
        AnimationController(duration: Duration(milliseconds: 500), vsync: this);
  }

  ConnectBloc _connectBloc = ConnectBloc();

  @override
  void initState() {
    super.initState();
    _connectBloc.connectStream.listen((estado) {
      ejecutarAnimacion(estado);
    });
//    if (GLOBAL.conectado == GLOBAL.DISCONECT || GLOBAL.conectado == GLOBAL.NONE)
//      ejecutarAnimacion(GLOBAL.conectado == GLOBAL.NONE
//          ? GLOBAL.DISCONECT
//          : GLOBAL.conectado);
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  void disposeStreams() {
    cambios?.close();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: cambios.stream,
      builder: (BuildContext context, snapshot) {
        return SizeTransition(
          sizeFactor: CurvedAnimation(
            parent: animationController,
            curve: Curves.easeOut,
          ),
          child: Container(
            width: double.infinity,
            color: GLOBAL.color,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(GLOBAL.mensaje),
                SizedBox(width: 20.0),
                Icon(GLOBAL.icono),
              ],
            ),
          ),
        );
      },
    );
  }

  void ejecutarAnimacion(int estado) {
    if (!mounted) return;
    if (GLOBAL.conectado == GLOBAL.CONECT && estado == GLOBAL.CONECT) return;
    GLOBAL.conectado = estado;
    cambios.add(GLOBAL.conectado == GLOBAL.CONECT);
    animationController?.forward();
    Future.delayed(const Duration(milliseconds: 1100), () {
      if (mounted && GLOBAL.conectado == GLOBAL.CONECT)
        animationController?.reverse();
    });
  }
}
