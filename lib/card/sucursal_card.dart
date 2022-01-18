import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../model/sucursal_model.dart';
import '../utils/personalizacion.dart' as prs;

class SucursalCard extends StatelessWidget {
  SucursalCard({@required this.sucursalModel, this.onTab, this.key});

  final SucursalModel sucursalModel;
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
            _contenido(),
            prs.iconoSucursal,
            SizedBox(width: 10.0)
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
                onTap: () => onTab(sucursalModel)),
          ),
        ),
      ],
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
            Text('Sucursal:', style: TextStyle(fontSize: 9)),
            Text('${sucursalModel.sucursal}',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text('Direccion:', style: TextStyle(fontSize: 9)),
            Text('${sucursalModel.direccion}',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
