import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../model/agencia_model.dart';
import '../utils/personalizacion.dart' as prs;

class AgenciaCard extends StatelessWidget {
  AgenciaCard({@required this.agenciaModel, this.onTab, this.key});

  final AgenciaModel agenciaModel;
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
            prs.iconoPreRegistroAgencia,
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
                onTap: () => onTab(agenciaModel)),
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
            Text('Agencia:', style: TextStyle(fontSize: 9)),
            Text('${agenciaModel.agencia}',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text('Direccion:', style: TextStyle(fontSize: 9)),
            Text('${agenciaModel.direccion}',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
