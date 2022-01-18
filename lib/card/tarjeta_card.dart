import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../model/tarjeta_model.dart';
import '../utils/cache.dart' as cache;
import '../utils/personalizacion.dart' as prs;

class TarjetaCard extends StatelessWidget {
  TarjetaCard({@required this.tarjetaModel, this.onTab, this.key});

  final TarjetaModel tarjetaModel;
  final Function onTab;
  final key;
  final double height = 95;

  @override
  Widget build(BuildContext context) {
    return _card(context);
  }

  Widget _card(BuildContext context) {
    final card = Container(
      height: height,
      child: Card(
        elevation: 2.0,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: Row(
          children: <Widget>[
            _avatar(),
            _contenido(),
            prs.iconoActivo,
            SizedBox(width: 20.0)
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
                onTap: () => onTab(tarjetaModel)),
          ),
        ),
      ],
    );
  }

  Widget _avatar() {
    return ClipRRect(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)),
        child: Container(
          height: 300,
          child: Column(
            children: [
              cache.fadeImage('',
                  width: 170,
                  acronimo: '${tarjetaModel.costo.toStringAsFixed(2)}'),
              SizedBox(height: 8.0),
              Text('A acreditar:', style: TextStyle(fontSize: 13)),
              SizedBox(height: 4.0),
              Text(
                  '${(tarjetaModel.saldo + tarjetaModel.promocion).toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 18)),
            ],
          ),
        ));
  }

  Widget _contenido() {
    return Expanded(
      child: Container(
        height: height,
        padding: EdgeInsets.only(left: 10.0, top: 3.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 6.0),
            Text('Promo:', style: TextStyle(fontSize: 12)),
            Text('${tarjetaModel.promocion.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            SizedBox(height: 5.0),
            Text('Saldo:', style: TextStyle(fontSize: 13)),
            Text(' ${(tarjetaModel.saldo).toStringAsFixed(2)}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
