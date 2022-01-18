import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../model/ruta_model.dart';
import '../utils/cache.dart' as cache;
import '../utils/personalizacion.dart' as prs;

class RutaCard extends StatelessWidget {
  RutaCard({@required this.rutaModel, this.onTab, this.key});

  final RutaModel rutaModel;
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
            _contenido(),
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
                onTap: () => onTab(rutaModel)),
          ),
        ),
      ],
    );
  }

  Widget _avatar() {
    return ClipRRect(
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)),
      child: cache.fadeImage(rutaModel.img, width: 100, height: 110),
    );
  }

  Widget _contenido() {
    Map<String, dynamic> ruta = (jsonDecode(rutaModel.ruta));
    return Expanded(
      child: Container(
        height: 110,
        padding: EdgeInsets.only(left: 10.0, top: 5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 4),
            Text('Desde:', style: TextStyle(fontSize: 9)),
            Text('${rutaModel.desde}',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text('Hasta:', style: TextStyle(fontSize: 9)),
            Text('${rutaModel.hasta}',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text('Ruta estimada:', style: TextStyle(fontSize: 9)),
            Text('${ruta['distance']['text']} ${ruta['duration']['text']}',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
