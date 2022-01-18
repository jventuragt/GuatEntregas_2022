import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:url_launcher/url_launcher.dart';

import '../model/chat_despacho_model.dart';
import '../model/despacho_model.dart';
import '../preference/shared_preferences.dart';
import '../providers/despacho_provider.dart';
import '../utils/cache.dart' as cache;
import '../utils/chat.dart' as chat;
import '../utils/conf.dart' as conf;
import '../utils/personalizacion.dart' as prs;

class ChatDespachoWidget extends StatelessWidget {
  final DespachoModel despachoModel;
  final ChatDespachoModel chatDespachoModel;
  final File imagen;
  final DespachoProvider despachoProvider;

  final PreferenciasUsuario prefs = PreferenciasUsuario();

  ChatDespachoWidget(
      {this.despachoModel,
      this.chatDespachoModel,
      this.imagen,
      this.despachoProvider});

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 3.0),
        child: (chatDespachoModel.tipo == conf.CHAT_TIPO_LINEA)
            ? chat.chatLinea(chatDespachoModel, context)
            : (chatDespachoModel.idClienteRecibe.toString() ==
                    prefs.idCliente.toString()
                ? _chatClienteEnvia(context)
                : _chatClienteRecive(context)));
  }

  Widget _chatClienteRecive(BuildContext context) {
    if (chatDespachoModel.tipo == conf.CHAT_TIPO_IMAGEN ||
        chatDespachoModel.tipo == conf.CHAT_TIPO_AUDIO)
      return chat.archivoParaClienteRecive(context, chatDespachoModel, imagen);
    return _chatParaClienteRecive(context);
  }

  Widget _chatClienteEnvia(BuildContext context) {
    if (chatDespachoModel.tipo == conf.CHAT_TIPO_IMAGEN ||
        chatDespachoModel.tipo == conf.CHAT_TIPO_AUDIO)
      return chat.archivoParaClienteEnvia(
          context, despachoModel, chatDespachoModel, imagen);
    return _chatParaClienteEnvia(context);
  }

  Row _chatParaClienteRecive(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        SizedBox(width: 60.0),
        Flexible(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: Container(
              color: prs.colorTextDescription,
              child: Container(
                margin: const EdgeInsets.all(10.0),
                child: _textoCajero(),
              ),
            ),
          ),
        ),
        chat.estadoChat(chatDespachoModel, true),
      ],
    );
  }

  Widget _textoCajero() {
    if (chatDespachoModel.tipo == conf.CHAT_TIPO_CELULAR)
      return Stack(
        children: <Widget>[
          Text.rich(
            TextSpan(
              text: 'Contacto: ',
              style: TextStyle(color: Colors.white),
              children: <TextSpan>[
                TextSpan(
                    text: chatDespachoModel.valor,
                    style: TextStyle(
                      color: Colors.lightBlueAccent,
                      decoration: TextDecoration.underline,
                    )),
                // can add more TextSpans here...
              ],
            ),
          ),
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                splashColor: Colors.blueAccent.withOpacity(0.6),
                onTap: () async {
                  _llamar(chatDespachoModel.valor);
                },
              ),
            ),
          ),
        ],
      );
    return Text(chatDespachoModel.mensaje,
        style: TextStyle(color: Colors.white), textAlign: TextAlign.justify);
  }

  _llamar(String celular) async {
    String _call = 'tel:${chatDespachoModel.valor}';
    if (await canLaunch(_call)) {
      await launch(_call);
    } else {
      throw 'Could not open the tel.';
    }
  }

  Row _chatParaClienteEnvia(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          margin: const EdgeInsets.only(left: 1.0, right: 1.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40.0),
            child: cache.fadeImage(despachoModel.img,
                width: 40,
                height: 40,
                acronimo: despachoModel.acronimo,
                color: Colors.grey,
                fontSize: 17.0),
          ),
        ),
        Flexible(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: Container(
              color: Colors.black12,
              child: Container(
                margin: const EdgeInsets.all(10.0),
                child: _textoClienteEnvia(context),
              ),
            ),
          ),
        ),
        // utils.estadoChat(chatDespachoModel, false),
        SizedBox(width: 40.0),
      ],
    );
  }

  Widget _textoClienteEnvia(BuildContext context) {
    if (chatDespachoModel.tipo == conf.CHAT_TIPO_CELULAR)
      return Stack(
        children: <Widget>[
          Text.rich(
            TextSpan(
              text: 'Contacto: ',
              style: TextStyle(color: Colors.black),
              children: <TextSpan>[
                TextSpan(
                    text: chatDespachoModel.valor,
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    )),
                // can add more TextSpans here...
              ],
            ),
          ),
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                splashColor: Colors.blueAccent.withOpacity(0.6),
                onTap: () async {
                  _llamar(chatDespachoModel.valor);
                },
              ),
            ),
          ),
        ],
      );

    return Text(chatDespachoModel.mensaje,
        style: TextStyle(color: Colors.black), textAlign: TextAlign.justify);
  }
}
