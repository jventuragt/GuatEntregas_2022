import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../model/cajero_model.dart';
import '../model/chat_compra_model.dart';
import '../providers/compra_provider.dart';
import '../utils/cache.dart' as cache;
import '../utils/chat.dart' as chat;
import '../utils/conf.dart' as conf;
import '../utils/personalizacion.dart' as prs;

class ChatClienteWidget extends StatefulWidget {
  final CajeroModel cajeroModel;
  final ChatCompraModel chatCompraModel;
  final File imagen;
  final CompraProvider compraProvider;

  ChatClienteWidget(
      {this.cajeroModel,
      this.chatCompraModel,
      this.imagen,
      this.compraProvider});

  @override
  _ChatClienteWidgetState createState() => _ChatClienteWidgetState();
}

class _ChatClienteWidgetState extends State<ChatClienteWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 3.0),
        child: (widget.chatCompraModel.tipo == conf.CHAT_TIPO_LINEA)
            ? chat.chatLinea(widget.chatCompraModel, context)
            : (widget.chatCompraModel.envia == conf.CHAT_ENVIA_CLIENTE
                ? _chatOperador(context)
                : _chatCliente(context)));
  }

  Widget _chatOperador(BuildContext context) {
    if (widget.chatCompraModel.tipo == conf.CHAT_TIPO_IMAGEN ||
        widget.chatCompraModel.tipo == conf.CHAT_TIPO_AUDIO)
      return chat.archivoParaClienteRecive(
          context, widget.chatCompraModel, widget.imagen);
    return _chatParaOperador(context);
  }

  Widget _chatCliente(BuildContext context) {
    if (widget.chatCompraModel.tipo == conf.CHAT_TIPO_IMAGEN ||
        widget.chatCompraModel.tipo == conf.CHAT_TIPO_AUDIO)
      return chat.archivoParaClienteEnvia(
          context, widget.cajeroModel, widget.chatCompraModel, widget.imagen);
    return _chatParaCliente(context);
  }

  Row _chatParaOperador(BuildContext context) {
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
        chat.estadoChat(widget.chatCompraModel, true),
      ],
    );
  }

  Widget _textoCajero() {
    if (widget.chatCompraModel.tipo == conf.CHAT_TIPO_CONFIRMACION) {
      widget.cajeroModel.costo = double.parse(widget.chatCompraModel.valor);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Solicitud confirmada',
              style: TextStyle(color: Colors.white, fontSize: 20.0),
              textAlign: TextAlign.right),
          Divider(),
          Text(widget.chatCompraModel.mensaje,
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.justify),
          Divider(),
          Text(
              'Costo: ${(double.parse(widget.chatCompraModel.valor)).toStringAsFixed(2)} USD incluye envío',
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.right),
          Divider(),
          Text('Dirección: ${widget.cajeroModel.referencia}',
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.justify),
          Divider(),
        ],
      );
    }
    return Text(widget.chatCompraModel.mensaje,
        style: TextStyle(color: Colors.white), textAlign: TextAlign.justify);
  }

  Row _chatParaCliente(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          margin: const EdgeInsets.only(left: 1.0, right: 1.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40.0),
            child:
                cache.fadeImage(widget.cajeroModel.img, width: 40, height: 40),
          ),
        ),
        Flexible(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: Container(
              color: Colors.black12,
              child: Container(
                margin: const EdgeInsets.all(10.0),
                child: _textoCliente(context),
              ),
            ),
          ),
        ),
        chat.estadoChat(widget.chatCompraModel, false),
        SizedBox(width: 40.0),
      ],
    );
  }

  Widget _textoCliente(BuildContext context) {
    return Text(widget.chatCompraModel.mensaje,
        style: TextStyle(color: Colors.black), textAlign: TextAlign.justify);
  }
}
