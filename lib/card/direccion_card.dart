import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../model/direccion_model.dart';
import '../utils/cache.dart' as cache;
import '../utils/personalizacion.dart' as prs;

class DireccionCard extends StatelessWidget {
  DireccionCard({@required this.direccionModel, this.onTab, this.key});

  final DireccionModel direccionModel;
  final Function onTab;
  final key;

  @override
  Widget build(BuildContext context) {
    return _card(context);
  }

  Widget _card(BuildContext context) {
    final card = Container(
      height: 110.0,
      child: Card(
        elevation: 2.0,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: Row(
          children: <Widget>[
            _avatar(),
            direccionModel.idDireccion <= 0
                ? _contenidoAgregar()
                : _contenido(),
            prs.iconoArrastrar,
            SizedBox(width: 5.0)
          ],
        ),
      ),
    );
    return Stack(
      children: <Widget>[
        card,
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
                splashColor: Colors.blueAccent.withOpacity(0.6),
                onTap: () => onTab(direccionModel)),
          ),
        ),
      ],
    );
  }

  Widget _avatar() {
    return ClipRRect(
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)),
      child: cache.fadeImage(direccionModel.img, width: 100, height: 110),
    );
  }

  Widget _contenido() {
    return Expanded(
      child: Container(
        height: 110,
        padding: EdgeInsets.only(left: 10.0, top: 5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 4),
            Text('Alias:', style: TextStyle(fontSize: 9)),
            Text('${direccionModel.alias}',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text('Referencia:', style: TextStyle(fontSize: 9)),
            Text('${direccionModel.referencia}',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _contenidoAgregar() {
    return Expanded(
      child: Container(
        height: 110,
        padding: EdgeInsets.only(left: 10.0, top: 5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 20),
//          Text('Alias:', style: TextStyle(fontSize: 9)),
            Text('${direccionModel.alias}',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
//          Text('Referencia:', style: TextStyle(fontSize: 9)),
            Text('${direccionModel.referencia}',
                style: TextStyle(fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
