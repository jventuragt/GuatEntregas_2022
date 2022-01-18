import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../model/cajero_model.dart';
import '../model/chat_compra_model.dart';
import '../utils/chat.dart' as chat;
import '../utils/conf.dart' as conf;
import '../utils/personalizacion.dart' as prs;

class ChatCajeroWidget extends StatelessWidget {
  final CajeroModel cajeroModel;
  final ChatCompraModel chatCompraModel;
  final File imagen;

  ChatCajeroWidget({this.cajeroModel, this.chatCompraModel, this.imagen});

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 3.0),
        child: (chatCompraModel.tipo == conf.CHAT_TIPO_LINEA)
            ? chat.chatLinea(chatCompraModel, context)
            : (chatCompraModel.envia == conf.CHAT_ENVIA_CAJERO
                ? _chatCliente(context)
                : _chatOperador(context)));
  }

  Widget _chatCliente(BuildContext context) {
    if (chatCompraModel.tipo == conf.CHAT_TIPO_IMAGEN ||
        chatCompraModel.tipo == conf.CHAT_TIPO_AUDIO)
      return chat.archivoParaClienteRecive(context, chatCompraModel, imagen);
    return _chatParaCliente(context);
  }

  Widget _chatOperador(BuildContext context) {
    if (chatCompraModel.tipo == conf.CHAT_TIPO_IMAGEN ||
        chatCompraModel.tipo == conf.CHAT_TIPO_AUDIO)
      return chat.archivoParaClienteEnvia(
          context, cajeroModel, chatCompraModel, imagen);
    return _chatParaOperador(context);
  }

  Row _chatParaOperador(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          margin: const EdgeInsets.only(left: 1.0, right: 1.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40.0),
            child: Container(
              child: CircleAvatar(
                child: Text(
                  cajeroModel.acronimo,
                  style: TextStyle(
                      color: prs.colorTextDescription, fontSize: 15.0),
                ),
                backgroundColor: Colors.black38,
              ),
            ),
          ),
        ),
        Flexible(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: Container(
              color: Colors.black12,
              child: Container(
                margin: const EdgeInsets.all(10.0),
                child: _textoCajero(),
              ),
            ),
          ),
        ),
        chat.estadoChat(chatCompraModel, false),
        SizedBox(width: 40.0)
      ],
    );
  }

  Widget _textoCajero() {
    if (chatCompraModel.tipo == conf.CHAT_TIPO_CONFIRMACION) {
      cajeroModel.costo = double.parse(chatCompraModel.valor);
      cajeroModel.detalle = chatCompraModel.mensaje;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Solicitud confirmada',
              style: TextStyle(color: Colors.black, fontSize: 20.0),
              textAlign: TextAlign.left),
          Divider(),
          Text(chatCompraModel.mensaje,
              style: TextStyle(color: Colors.black),
              textAlign: TextAlign.justify),
          Divider(),
          Text(
              'Costo ${(double.parse(chatCompraModel.valor)).toStringAsFixed(2)} USD incluye envío',
              style: TextStyle(color: Colors.black),
              textAlign: TextAlign.left),
        ],
      );
    }
    return Text(chatCompraModel.mensaje,
        style: TextStyle(color: Colors.black), textAlign: TextAlign.justify);
  }

  Row _chatParaCliente(BuildContext context) {
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
                  margin: const EdgeInsets.all(10.0), child: _textoCliente()),
            ),
          ),
        ),
        chat.estadoChat(chatCompraModel, true),
      ],
    );
  }

  Widget _textoCliente() {
    if (chatCompraModel.tipo == conf.CHAT_TIPO_PRESUPUESTO)
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(chatCompraModel.mensaje,
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.justify),
          Divider(),
          Text(
              'Costo: ${double.parse(chatCompraModel.valor.toString()).toStringAsFixed(2)} USD',
              style: TextStyle(color: Colors.white, fontSize: 20.0),
              textAlign: TextAlign.right)
        ],
      );
    if (chatCompraModel.tipo == conf.CHAT_TIPO_CONFIRMACION) {
      cajeroModel.costo = chatCompraModel.valor;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Entregar a: ' + cajeroModel.referencia.toString(),
              style: TextStyle(color: Colors.white, fontSize: 20.0),
              textAlign: TextAlign.right),
          Divider(),
          Text(chatCompraModel.mensaje,
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.justify),
          Divider(),
          Text(
              'Costo ${(double.parse(chatCompraModel.valor)).toStringAsFixed(2)} USD incluye envío',
              style: TextStyle(color: Colors.white, fontSize: 20.0),
              textAlign: TextAlign.right),
        ],
      );
    }
    return Text(chatCompraModel.mensaje,
        style: TextStyle(color: Colors.white), textAlign: TextAlign.justify);
  }
}
