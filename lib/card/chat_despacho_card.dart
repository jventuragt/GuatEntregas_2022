import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:slider_button/slider_button.dart';

import '../model/despacho_model.dart';
import '../utils/cache.dart' as cache;
import '../utils/conf.dart' as conf;
import '../utils/personalizacion.dart' as prs;
import '../widgets/icon_aument_widget.dart';

class ChatDespachoCard extends StatelessWidget {
  ChatDespachoCard(
      {@required this.despachoModel,
      @required this.onTab,
      @required this.enviarPostular,
      @required this.isChatDespacho});

  final DespachoModel despachoModel;
  final bool isChatDespacho;
  final Function onTab;
  final Function enviarPostular;

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
            Text(despachoModel.estado,
                style: TextStyle(color: Colors.blueGrey, fontSize: 8.0)),
            SizedBox(height: 8.0),
          ],
        ),
        SizedBox(width: 5.0)
      ],
    );
  }

  Widget _card(BuildContext context) {
    final card = Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: _cardContenido(),
    );
    return Stack(
      children: <Widget>[
        card,
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
                splashColor: Colors.blueAccent.withOpacity(0.6),
                onTap: () => onTab(despachoModel)),
          ),
        ),
        Positioned(
          top: 10.0,
          right: 10.0,
          child: Icon(Icons.radio_button_checked,
              color: (despachoModel.onLine == 1
                  ? Colors.green
                  : prs.colorButtonSecondary),
              size: 10.0),
        ),
        despachoModel.idDespachoEstado == 1
            ? Positioned(
                bottom: 4.0,
                right: 4.0,
                child: SliderButton(
                  dismissible: false,
                  boxShadow: BoxShadow(
                    color: Colors.black,
                    blurRadius: 0.1,
                  ),
                  baseColor: Colors.white,
//                  highlightedColor: Colors.grey,
                  shimmer: false,
                  radius: 10.0,
                  height: 35.0,
                  action: () {
                    enviarPostular(despachoModel);
                  },
                  label: Text(
                    "Desliza para postular",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 17),
                  ),
                  backgroundColor: prs.colorButtonSecondary,
                  buttonSize: 35.0,
                  dismissThresholds: 0.6,
                  icon: Icon(
                    FontAwesomeIcons.arrowRight,
                    size: 16.0,
                    color: prs.colorButtonSecondary,
                  ),
                ))
            : Container(),
      ],
    );
  }

  ClipRRect _avatar() {
    return ClipRRect(
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)),
      child: cache.acronicmo(despachoModel.acronimo, width: 120, height: 120),
    );
  }

  Widget _contenido() {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(despachoModel.sucursalJson,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text(despachoModel.nombres,
                style: TextStyle(fontSize: 12, color: Colors.blueGrey))
          ],
        ),
      ),
    );
  }

  Widget _icono() {
    if (despachoModel.isConductor() && despachoModel.sinLeerConductor > 0)
      return prs.iconoChatActivo;

    if (despachoModel.isCliente() && despachoModel.sinLeerCliente > 0)
      return prs.iconoChatActivo;

    if (despachoModel.idDespachoEstado == conf.DESPACHO_RECOGIDO)
      return prs.iconoDespachando;

    if (despachoModel.idDespachoEstado == conf.DESPACHO_BUSCANDO)
      return Row(
        children: <Widget>[
          IconAumentWidget(Icon(FontAwesomeIcons.route, color: Colors.red)),
          SizedBox(
            width: 5.0,
          )
        ],
      );

    if (despachoModel.idDespachoEstado == conf.DESPACHO_ASIGNADO)
      return Row(
        children: <Widget>[
          Icon(FontAwesomeIcons.route, color: Colors.green),
          SizedBox(
            width: 5.0,
          )
        ],
      );

    if (despachoModel.idDespachoEstado == conf.COMPRA_ENTREGADA)
      return Row(
          children: <Widget>[prs.iconoClienteAbordo, SizedBox(width: 5.0)]);

    if (despachoModel.idDespachoEstado == conf.COMPRA_CANCELADA)
      return prs.iconoCancelada;

    if (despachoModel.idDespachoEstado == conf.COMPRA_ENTREGADA)
      return Row(
          children: <Widget>[prs.iconoClienteAbordo, SizedBox(width: 5.0)]);

    return Row(
        children: <Widget>[prs.iconoClienteAbordo, SizedBox(width: 5.0)]);
  }
}
