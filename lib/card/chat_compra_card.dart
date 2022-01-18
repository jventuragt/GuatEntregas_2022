import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../model/cajero_model.dart';
import '../preference/shared_preferences.dart';
import '../utils/cache.dart' as cache;
import '../utils/conf.dart' as conf;
import '../utils/dialog.dart' as dlg;
import '../utils/personalizacion.dart' as prs;
import '../widgets/icon_aument_widget.dart';

class ChatCompraCard extends StatelessWidget {
  ChatCompraCard(
      {@required this.cajeroModel,
      @required this.onTab,
      @required this.isChatCajero});

  final CajeroModel cajeroModel;
  final bool isChatCajero;
  final Function onTab;
  final PreferenciasUsuario _prefs = PreferenciasUsuario();

  @override
  Widget build(BuildContext context) {
    return _card(context);
  }

  Widget _cardContenido() {
    return Row(
      children: <Widget>[
        _avatar(),
        _contenido(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            _icono(),
            SizedBox(height: 8.0),
            Text(cajeroModel.estado,
                style: TextStyle(color: Colors.blueGrey, fontSize: 8.0)),
            SizedBox(height: 8.0),
          ],
        ),
        SizedBox(width: 5.0)
      ],
    );
  }

  Widget modalAgregadoAlCarrito() {
    if (cajeroModel.abiero == '1' ||
        cajeroModel.idCompraEstado > conf.COMPRA_PRESUPUESTANDO)
      return Container();

    return Positioned.fill(
      top: 80.0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.85),
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text('Cerrado',
                style: TextStyle(color: Colors.red, fontSize: 16.0),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _card(BuildContext context) {
    final card = Card(
      elevation: 1.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child:
          (cajeroModel.sucursal == '') ? _contenidoOfline() : _cardContenido(),
    );
    return Stack(
      children: <Widget>[
        card,
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
                splashColor: Colors.blueAccent.withOpacity(0.6),
                onTap: () {
                  if (cajeroModel.sucursal == '') return;
                  if (cajeroModel.abiero == '1' ||
                      cajeroModel.idCompraEstado > conf.COMPRA_PRESUPUESTANDO) {
                    onTab(cajeroModel);
                  } else {
                    dlg.mostrar(context, cajeroModel.abiero);
                  }
                }),
          ),
        ),
        Positioned(
          top: 10.0,
          right: 10.0,
          child: Icon(Icons.radio_button_checked,
              color: (cajeroModel.onLine == 1
                  ? Colors.green
                  : (cajeroModel.abiero == '1'
                      ? prs.colorButtonSecondary
                      : Colors.red)),
              size: 12.0),
        ),
      ],
    );
  }

  Widget _avatar() {
    Widget _avatar = ClipRRect(
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)),
      child: _prefs.clienteModel.perfil.toString() == '0'
          ? cache.fadeImage(cajeroModel.img,
              width: 120, height: 120, acronimo: cajeroModel.acronimo)
          : cache.acronicmo(cajeroModel.acronimo, width: 120, height: 120),
    );
    return Stack(
      children: <Widget>[_avatar, modalAgregadoAlCarrito()],
    );
  }

  Widget _contenido() {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(cajeroModel.sucursal,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            (cajeroModel.referencia == 'null')
                ? Container()
                : Text(
                    'Costo total : ${cajeroModel.costo.toStringAsFixed(2)} USD',
                    style: TextStyle(fontSize: 12, color: Colors.blueGrey)),
            SizedBox(height: 4),
            (cajeroModel.referencia == 'null')
                ? Text('Para consultar se debe seleccionar una dirección',
                    style: TextStyle(fontSize: 12, color: Colors.blueGrey))
                : Text('Referencia: ${cajeroModel.referencia}',
                    style: TextStyle(fontSize: 12, color: Colors.blueGrey)),
            SizedBox(height: 4),
            _horario(),
          ],
        ),
      ),
    );
  }

  Widget _horario() {
    if (cajeroModel.turno == 1)
      return Text('Sucursal de turno',
          style: TextStyle(fontSize: 12, color: Colors.blueGrey));
    if (cajeroModel.resta == null || cajeroModel.resta == 0) return Text('');
    if (cajeroModel.resta <= 10)
      return Text('Cerrará en ${cajeroModel.resta} min',
          style: TextStyle(fontSize: 12, color: Colors.red));
    if (cajeroModel.resta <= 30)
      return Text('Pronto cerrará restan ${cajeroModel.resta} min',
          style: TextStyle(fontSize: 12, color: Colors.redAccent));

    return Text('Abierto hasta las ${cajeroModel.hasta}',
        style: TextStyle(fontSize: 12, color: Colors.blueGrey));
  }

  Container _contenidoOfline() {
    if (cajeroModel.idDireccion == -1)
      return Container(
        padding: EdgeInsets.all(12.0),
        child: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            child: Image(image: AssetImage('assets/screen/ofline.png')),
          ),
        ),
      );
    return Container(
      padding: EdgeInsets.all(10.0),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 20.0),
            Text(
              'Nos alegra verte de nuevo.',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
            ),
            SizedBox(height: 20.0),
            Text(
              'Por favor selecciona una dirección donde enviaremos tu pedido.',
              textAlign: TextAlign.justify,
            ),
            SizedBox(height: 10.0),
            Image(image: AssetImage('assets/screen/direcciones.png')),
          ],
        ),
      ),
    );
  }

  Widget _icono() {
    if (cajeroModel.sinLeerCliente == null) return prs.iconoPresionar;

    if (isChatCajero && cajeroModel.idCompraEstado == conf.COMPRA_COMPRADA)
      return Row(
        children: <Widget>[
          IconAumentWidget(Icon(FontAwesomeIcons.route, color: Colors.red)),
          SizedBox(
            width: 5.0,
          )
        ],
      );

    if (!isChatCajero && cajeroModel.idCompraEstado == conf.COMPRA_COMPRADA)
      return Row(
        children: <Widget>[
          Icon(FontAwesomeIcons.route, color: Colors.green),
          SizedBox(
            width: 5.0,
          )
        ],
      );

    if (isChatCajero && cajeroModel.sinLeerCajero > 0)
      return prs.iconoChatActivo;

    if (!isChatCajero && cajeroModel.sinLeerCliente > 0)
      return prs.iconoChatActivo;

    if (cajeroModel.idCompraEstado == conf.COMPRA_CANCELADA)
      return prs.iconoCancelada;

    if (isChatCajero && cajeroModel.calificarCajero == 2)
      return prs.iconoSolicitarCalificar;

    if (!isChatCajero && cajeroModel.calificarCliente == 2)
      return prs.iconoSolicitarCalificar;

    if (cajeroModel.idCompraEstado == conf.COMPRA_PRESUPUESTANDO)
      return prs.iconoDirecciones;

    if (cajeroModel.idCompraEstado == conf.COMPRA_REFERENCIADA)
      return prs.iconoChat;

    if (cajeroModel.idCompraEstado == conf.COMPRA_DESPACHADA)
      return prs.iconoDespachando;

    return prs.iconoCasa;
  }
}
