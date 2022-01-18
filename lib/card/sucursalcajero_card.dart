import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../model/sucursalcajero_model.dart';
import '../utils/cache.dart' as cache;
import '../utils/personalizacion.dart' as prs;
import '../utils/utils.dart' as utils;

class SucursalcajeroCard extends StatelessWidget {
  SucursalcajeroCard(
      {@required this.sucursalcajeroModel, this.onTab, this.key});

  final SucursalcajeroModel sucursalcajeroModel;
  final Function onTab;
  final key;
  final double height = 120;

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
            _avatar(context),
            _contenido(),
            (sucursalcajeroModel.activo == 1
                ? prs.iconoActivo
                : prs.iconoDesActivo),
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
                onTap: () => onTab(sucursalcajeroModel)),
          ),
        ),
      ],
    );
  }

  Widget _avatar(BuildContext context) {
    Widget _avatar = Column(
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)),
          child: cache.fadeImage(sucursalcajeroModel.img,
              width: 100,
              height: height - 8,
              acronimo: sucursalcajeroModel.acronimo),
        ),
      ],
    );

    return Stack(
      children: <Widget>[
        _avatar,
        Positioned(
          bottom: 0.0,
          child: Container(
            decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius:
                    BorderRadius.only(bottomLeft: Radius.circular(10.0))),
            child: _estrellas(),
          ),
        ),
      ],
    );
  }

  Widget _estrellas() {
    return utils.estrellas(
        (sucursalcajeroModel.calificacion / sucursalcajeroModel.calificaciones),
        (value) {},
        size: 22.0);
  }

  Widget _contenido() {
    return Expanded(
      child: Container(
        height: height,
        padding: EdgeInsets.only(left: 10.0, top: 5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 4),
            Text('Nombres:', style: TextStyle(fontSize: 9)),
            Text('${sucursalcajeroModel.nombres}',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text('Correctas/Canceladas:', style: TextStyle(fontSize: 9)),
            Text(
                '${sucursalcajeroModel.correctos} / ${sucursalcajeroModel.canceladas}',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Expanded(
              child: Container(),
            ),
            LinearPercentIndicator(
              lineHeight: 8.0,
              animation: true,
              percent: (sucursalcajeroModel.registros > 0)
                  ? (sucursalcajeroModel.correctos /
                      sucursalcajeroModel.registros)
                  : 1.0,
              progressColor: Colors.purple,
            ),
            SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}
