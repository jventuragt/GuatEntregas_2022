import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../model/factura_model.dart';
import '../utils/cache.dart' as cache;
import '../utils/personalizacion.dart' as prs;

class FacturaCard extends StatelessWidget {
  FacturaCard({@required this.facturaModel, this.onTab, this.key});

  final FacturaModel facturaModel;
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
            facturaModel.idFactura <= 0 ? _avatar() : Container(),
            facturaModel.idFactura <= 0 ? _contenidoAgregar() : _contenido(),
            prs.iconoFactura,
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
                onTap: () => onTab(facturaModel)),
          ),
        ),
      ],
    );
  }

  Widget _avatar() {
    return ClipRRect(
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)),
      child: cache.fadeImage('assets/screen/direcciones.png',
          width: 100, height: 110),
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
            Text('Cédula o Ruc:', style: TextStyle(fontSize: 9)),
            Text('${facturaModel.dni}',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text('Dirección:', style: TextStyle(fontSize: 9)),
            Text('${facturaModel.direccion}',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  Widget _contenidoAgregar() {
    return Expanded(
      child: Container(
        height: 110,
        padding: EdgeInsets.only(left: 10.0, top: 5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 20),
//          Text('Alias:', style: TextStyle(fontSize: 9)),
            Text('Registrar datos de factura',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
//          Text('Referencia:', style: TextStyle(fontSize: 9)),
            Text('Toca para registrar tus datos de factura',
                style: TextStyle(fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
