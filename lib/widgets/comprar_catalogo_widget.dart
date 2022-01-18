import 'package:flutter/material.dart';

import '../card/catalogo_card.dart';
import '../model/catalogo_model.dart';
import '../utils/utils.dart' as utils;

class ComprarCatalogoWidget extends StatefulWidget {
  final ScrollController pageController;
  final AsyncSnapshot<List<CatalogoModel>> snapshot;
  final Function onTapCatalogo;

  ComprarCatalogoWidget(this.pageController,
      {@required this.snapshot, @required this.onTapCatalogo});

  @override
  _ComprarCatalogoWidgetState createState() => _ComprarCatalogoWidgetState();
}

class _ComprarCatalogoWidgetState extends State<ComprarCatalogoWidget> {
  bool _inicio = true;
  bool _final = false;

  @override
  Widget build(BuildContext context) {
    bool _auxFinal = false;
    bool _auxInicio = true;
    widget.pageController.addListener(() {
      _auxFinal = widget.pageController.position.pixels >=
          widget.pageController.position.maxScrollExtent - 50;
      if (_auxFinal != _final) {
        _final = _auxFinal;
        if (mounted) if (mounted) setState(() {});
      }

      _auxInicio = widget.pageController.position.pixels <= 10;
      if (_auxInicio != _inicio) {
        _inicio = _auxInicio;
        if (mounted) if (mounted) setState(() {});
      }
    });
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.only(right: 0.0, left: 5.0),
          width: double.infinity,
          height: 165.0,
          child: ListView.builder(
            controller: widget.pageController,
            itemCount: widget.snapshot.data.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                child: CatalogoCard(
                    catalogoModel: widget.snapshot.data[index],
                    onTab: widget.onTapCatalogo,
                    isChatCajero: false),
                width: 165,
                height: 165,
              );
            },
          ),
        ),
        utils.bandaIzquierda(_inicio, widget.pageController),
        utils.bandaDerecha(_final, widget.pageController),
      ],
    );
  }
}
