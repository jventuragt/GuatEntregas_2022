import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../model/notificacion_model.dart';
import '../utils/cache.dart' as cache;

class NotificacionCard extends StatelessWidget {
  NotificacionCard({@required this.notificacionModel, this.onTab, this.key});

  final NotificacionModel notificacionModel;
  final Function onTab;
  final key;

  @override
  Widget build(BuildContext context) {
    return _card(context);
  }

  Widget _card(BuildContext context) {
    final card = Container(
      height: 120.0,
      child: Card(
        elevation: 2.0,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: Row(
          children: <Widget>[
            _avatar(),
            _contenido(),
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
                onTap: () => onTab(notificacionModel)),
          ),
        ),
      ],
    );
  }

  Widget _avatar() {
    return ClipRRect(
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)),
      child: cache.fadeImage(notificacionModel.img, width: 120, height: 120),
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
            SizedBox(height: 5),
            Text('${notificacionModel.hint}',
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(
              '${notificacionModel.detalle}',
              style: TextStyle(color: Colors.blueGrey, fontSize: 12.0),
              textAlign: TextAlign.start,
              overflow: TextOverflow.visible,
              maxLines: 5,
            ),
          ],
        ),
      ),
    );
  }
}
