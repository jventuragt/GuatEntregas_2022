import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../model/horario_model.dart';
import '../utils/cache.dart' as cache;
import '../utils/personalizacion.dart' as prs;

class HorarioCard extends StatelessWidget {
  HorarioCard({@required this.horarioModel, this.onTab, this.key});

  final HorarioModel horarioModel;
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
            prs.iconoHorario,
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
                onTap: () => onTab(horarioModel)),
          ),
        ),
      ],
    );
  }

  Widget _avatar() {
    return ClipRRect(
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)),
      child: cache.fadeImage('',
          width: 199, height: height, acronimo: horarioModel.acronimo),
    );
  }

  Widget _contenido() {
    return Expanded(
      child: Container(
        height: height,
        padding: EdgeInsets.only(left: 10.0, top: 3.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 4),
            Text('Desde:', style: TextStyle(fontSize: 9)),
            Text('${horarioModel.desde}',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text('Hasta:', style: TextStyle(fontSize: 9)),
            Text('${horarioModel.hasta}',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}
