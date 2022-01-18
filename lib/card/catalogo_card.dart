import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../model/catalogo_model.dart';
import '../utils/cache.dart' as cache;
import '../utils/personalizacion.dart' as prs;

class CatalogoCard extends StatelessWidget {
  CatalogoCard(
      {@required this.catalogoModel,
      @required this.onTab,
      @required this.isChatCajero,
      Key key})
      : super(key: key);

  final CatalogoModel catalogoModel;
  final bool isChatCajero;
  final Function onTab;

  @override
  Widget build(BuildContext context) {
    return _card(context);
  }

  Widget _cardContenido() {
    return Column(
      children: <Widget>[
        _avatar(),
        Expanded(
          child: Container(
            padding: EdgeInsets.only(left: 10.0, right: 10.0),
            child: Center(
                child: Text(
              catalogoModel.agencia,
              style: TextStyle(color: Colors.blueGrey, fontSize: 12.0),
              textAlign: TextAlign.center,
            )),
          ),
        ),
      ],
    );
  }

  Widget _card(BuildContext context) {
    final card = Card(
      elevation: 1.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: _cardContenido(),
    );
    return Stack(
      children: <Widget>[
        card,
        catalogoModel.abiero == '1' ? Container() : cerrado(context),
        etiqueta(context),
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
                splashColor: Colors.blueAccent.withOpacity(0.6),
                onTap: () {
                  onTab(catalogoModel);
                }),
          ),
        ),
      ],
    );
  }

  Widget etiqueta(BuildContext context) {
    if (catalogoModel.label == '') return Container();
    return Positioned(
      top: 15.0,
      right: 0,
      child: Container(
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: prs.colorButtonSecondary,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Flexible(
                child: Text(catalogoModel.label,
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center)),
          ],
        ),
      ),
    );
  }

  Widget cerrado(BuildContext context) {
    return Positioned(
      top: 10.0,
      left: -55,
      child: Transform.rotate(
        alignment: FractionalOffset.center,
        angle: 345.0,
        child: Container(
          height: 40.0,
          width: 200.0,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.8),
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text('Cerrado',
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _avatar() {
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      child: cache.fadeImage(catalogoModel.img,
          acronimo: catalogoModel.observacion),
    );
  }
}
