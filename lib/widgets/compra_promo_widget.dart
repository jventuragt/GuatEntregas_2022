import 'package:flutter/material.dart';

import '../model/compra_promocion_model.dart';
import '../utils/cache.dart' as cache;
import '../utils/chat.dart' as chat;
import '../utils/personalizacion.dart' as prs;

class CompraPromoWidget extends StatelessWidget {
  final List<CompraPromocionModel> promociones;

  final GlobalKey<ScaffoldState> scaffoldKey;

  CompraPromoWidget({@required this.promociones, @required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140.0,
      padding: EdgeInsets.all(5.0),
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: promociones.length,
          itemBuilder: (context, i) => _tarjeta(context, promociones[i])),
    );
  }

  Widget _tarjeta(BuildContext context, CompraPromocionModel promocion) {
    final tarjeta = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.white,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black26,
            blurRadius: 0.5,
            spreadRadius: 0.5,
            offset: Offset(0.5, 0.5),
          )
        ],
      ),
      width: 110.0,
      margin: EdgeInsets.all(3.0),
      child: Stack(
        children: <Widget>[
          _contenido(promocion),
        ],
      ),
    );

    return Stack(
      children: <Widget>[
        tarjeta,
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              splashColor: Colors.blueAccent.withOpacity(0.6),
              onTap: () {
                chat.mostrarImagen(context, promocion.imagen);
              },
            ),
          ),
        )
      ],
    );
  }

  Column _contenido(CompraPromocionModel promocion) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10), topRight: Radius.circular(10)),
          child: cache.fadeImage(promocion.imagen, width: 110, height: 90),
        ),
        SizedBox(height: 5.0),
        Text(
          promocion.producto,
          style: TextStyle(color: prs.colorIcons),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
