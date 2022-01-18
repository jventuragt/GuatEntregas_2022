import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../bloc/catalogo_bloc.dart';
import '../bloc/promocion_bloc.dart';
import '../model/promocion_model.dart';
import '../preference/db_provider.dart';
import '../utils/cache.dart' as cache;
import '../utils/personalizacion.dart' as prs;
import '../utils/utils.dart' as utils;

class ProductosDialog extends StatefulWidget {
  final PromocionModel promocion;

  ProductosDialog({this.promocion}) : super();

  ProductosDialogState createState() =>
      ProductosDialogState(promocion: promocion);
}

class ProductosDialogState extends State<ProductosDialog>
    with TickerProviderStateMixin {
  final PromocionModel promocion;
  final CatalogoBloc _catalogoBloc = CatalogoBloc();

  ProductosDialogState({this.promocion});

  @override
  void initState() {
    _cargar();
    super.initState();
  }

  _cargar() async {
    List<PromocionModel> promocionesCarrito =
        await DBProvider.db.listarPorPromocion(promocion.idPromocion);
    promocion.idsProductos.clear();
    for (var i = 0; i < promocion.productos.lP.length; i++) {
      promocion.productos.lP[i].isComprada = false;
      promocionesCarrito.forEach((element) {
        if (promocion.productos.lP[i].id.toString() ==
            element.idProducto.toString()) {
          promocion.idsProductos.add(element.idProducto.toString());
          promocion.productos.lP[i].isComprada = true;
        }
      });
    }
    if (mounted) if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      insetPadding:
          EdgeInsets.only(left: 15.0, right: 15.0, top: 70.0, bottom: 40.0),
      contentPadding: EdgeInsets.only(left: 10.0, right: 10.0, top: 15.0),
      title: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            child: cache.fadeImage(promocion.imagen, width: 60, height: 60),
          ),
          SizedBox(width: 10.0),
          Container(
            width: 200,
            child: Text('${promocion.producto}',
                textAlign: TextAlign.center,
                maxLines: 3,
                style: TextStyle(fontSize: 17.0),
                overflow: TextOverflow.clip),
          ),
        ],
      ),
      content: Form(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[SizedBox(width: 400.0), _contenido()],
          ),
        ),
      ),
      actions: <Widget>[
        ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
                primary: prs.colorButtonSecondary,
                elevation: 2.0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0))),
            label: Text('ACEPTAR'),
            icon: Icon(FontAwesomeIcons.check, color: Colors.white, size: 15.0),
            onPressed: () {
              Navigator.of(context).pop();
            }),
      ],
    );
  }

  _contenido() {
    List<Widget> widgetlist = [];
    for (var i = 0; i < promocion.productos.lP.length; i++) {
      widgetlist.add(_botonProducto(promocion.productos.lP[i]));
    }
    Widget _contenido = SingleChildScrollView(
      child: Column(
        children: widgetlist,
        mainAxisSize: MainAxisSize.min,
      ),
    );

    return _contenido;
  }

  final PromocionBloc _promocionBloc = PromocionBloc();

  Widget _botonProducto(LP producto) {
    Widget _contenido = Container(
      padding: EdgeInsets.only(left: 5.0, right: 6.0, bottom: 3.0, top: 3.0),
      child: Row(
        children: [
          Expanded(child: Text(producto.d)),
          SizedBox(height: 40.0, width: 10.0),
          Column(
            children: [
              Text('${producto.p.toStringAsFixed(2)}'),
              prs.iconoAgregarCarritoProducto,
            ],
          )
        ],
      ),
    );

    final tarjeta = Container(
      margin: EdgeInsets.only(top: 5, left: 2.0, right: 2.0, bottom: 5.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
        color: Colors.white,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black26,
            blurRadius: 0.4,
            spreadRadius: 0.4,
            offset: Offset(0.0, 0.0),
          ),
        ],
      ),
      child: Stack(
        children: <Widget>[
          _contenido,
          producto.isComprada
              ? utils.modalProductoAgregadoAlCarrito()
              : Container()
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
              onTap: () async {
                producto.isComprada = !producto.isComprada;
                promocion.idProducto = producto.id;
                if (producto.isComprada) {
                  promocion.idsProductos.add(producto.id);
                  await DBProvider.db
                      .agregarPromocion(promocion, producto: producto);
                } else {
                  promocion.idsProductos.remove(producto.id);
                  await DBProvider.db.eliminarPromocion(promocion);
                }
                promocion.isComprada = promocion.isComproProductos();
                _promocionBloc.actualizar(promocion);
                _catalogoBloc.actualizar(promocion);
                _promocionBloc.carrito();
                if (mounted) setState(() {});
              },
            ),
          ),
        ),
      ],
    );
  }
}
