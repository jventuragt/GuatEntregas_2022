import 'package:flutter/material.dart';

import '../bloc/carrito_bloc.dart';
import '../bloc/catalogo_bloc.dart';
import '../bloc/promocion_bloc.dart';
import '../dialog/instruccion_dialog.dart';
import '../model/promocion_model.dart';
import '../preference/db_provider.dart';
import '../utils/cache.dart' as cache;
import '../utils/personalizacion.dart' as prs;
import 'icon_add_widget.dart';

class CarritoWidget extends StatefulWidget {
  final List<PromocionModel> promociones;
  final Function consultarPrecio;
  final Function evaluarCosto;
  final Function verMenu;

  CarritoWidget(this.consultarPrecio, this.evaluarCosto, this.verMenu,
      {@required this.promociones});

  @override
  _CarritoWidgetState createState() => _CarritoWidgetState();
}

class _CarritoWidgetState extends State<CarritoWidget> {
  final PromocionBloc _promocionBloc = PromocionBloc();

  final CarritoBloc _carritoBloc = CarritoBloc();

  final CatalogoBloc _catalogoBloc = CatalogoBloc();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 500.0,
          childAspectRatio: 0.90,
          mainAxisSpacing: 10.0,
          crossAxisSpacing: 10.0),
      padding: EdgeInsets.only(right: 10.0, left: 10.0),
      scrollDirection: Axis.vertical,
      itemCount: widget.promociones.length,
      itemBuilder: (context, i) => _tarjeta(context, widget.promociones[i]),
    );
  }

  Container _tarjeta(BuildContext context, PromocionModel promocion) {
    return Container(
      margin: EdgeInsets.only(top: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.white,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black26,
            blurRadius: 0.05,
            spreadRadius: 0.04,
            offset: Offset(1.0, 1.0),
          ),
        ],
      ),
      child: _card(promocion, context),
    );
  }

  Widget etiqueta(BuildContext context, PromocionModel promocionModel) {
    if (promocionModel.incentivo == '') return Container();
    return Positioned(
      bottom: 10.0,
      left: 0,
      child: Container(
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: prs.colorButtonSecondary,
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(10), bottomRight: Radius.circular(10)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Flexible(
                child: Text(promocionModel.incentivo,
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center)),
          ],
        ),
      ),
    );
  }

  Column _card(PromocionModel promocion, BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Flexible(
          child: Stack(
            children: <Widget>[
              Container(
                width: size.width - 20.0,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                  child: Container(child: cache.fadeImage(promocion.imagen)),
                ),
              ),
              etiqueta(context, promocion),
              Positioned(
                top: 10.0,
                right: 10.0,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      primary: prs.colorButtonPrimary,
                      onPrimary: prs.colorTextDescription,
                      elevation: 1.0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0))),
                  label: Text('Ver catálogo'),
                  icon: Icon(Icons.store, size: 18.0),
                  onPressed: () {
                    widget.verMenu(promocion);
                  },
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 160.0,
          margin: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
          child: _contenido(promocion, context),
        ),
      ],
    );
  }

  Column _contenido(PromocionModel promocion, BuildContext context) {
    return Column(
      children: <Widget>[
        Text(promocion.producto,
            style: TextStyle(
                fontSize: 14.0,
                color: prs.colorIcons,
                fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis),
        SizedBox(height: 7.0),
        Text(promocion.descripcion,
            maxLines: 2,
            textAlign: TextAlign.justify,
            style: TextStyle(color: prs.colorTextDescription),
            overflow: TextOverflow.clip),
        SizedBox(height: 10.0),
        Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              SizedBox(width: 75.0),
              IconAddWidget(widget.evaluarCosto, promocionModel: promocion),
              Row(
                children: [
                  prs.iconoDinero,
                  Text(promocion.precio.toStringAsFixed(2),
                      style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: prs.colorIcons)),
                ],
              )
            ]),
        SizedBox(height: 4.0),
        Row(
          children: <Widget>[
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  primary: prs.colorButtonPrimary,
                  onPrimary: prs.colorTextDescription,
                  elevation: 1.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0))),
              label: Text('Eliminar'),
              icon: Icon(Icons.reply, size: 18.0),
              onPressed: () async {
                await DBProvider.db.eliminarPromocion(promocion);
                promocion.isComprada = false;
                _promocionBloc.actualizar(promocion);
                _catalogoBloc.actualizar(promocion);

                await _carritoBloc.listar(promocion.idUrbe);
                _promocionBloc.carrito();

                widget.evaluarCosto();
              },
            ),
            Expanded(child: Container()),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  primary: prs.colorButtonSecondary,
                  elevation: 2.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0))),
              label: Text('Instrucciones'),
              icon: Icon(Icons.message, size: 18.0),
              onPressed: () {
                showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) {
                      return InstruccionDialog(promocion: promocion);
                    });
              },
            ),
          ],
        ),
      ],
    );
  }
}
