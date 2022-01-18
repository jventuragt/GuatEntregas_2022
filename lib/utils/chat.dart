import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../sistema.dart';
import '../utils/cache.dart' as cache;
import '../utils/conf.dart' as conf;
import '../utils/personalizacion.dart' as prs;
import '../widgets/audio_play_widget.dart';

Widget archivoParaClienteRecive(BuildContext context, chatCompraModel, imagen) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: <Widget>[
      Expanded(child: Container()),
      (chatCompraModel.tipo == conf.CHAT_TIPO_AUDIO)
          ? ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: AudioPlayWidget(
                chatCompraModel,
                ValueKey(UniqueKey()),
                color: Colors.blueAccent,
                backgroud: prs.colorTextDescription,
              ),
            )
          : Flexible(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: Container(
                  color: prs.colorTextDescription,
                  child: Container(
                    margin: const EdgeInsets.all(5.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(child: Container()),
                        Container(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                                primary: prs.colorButtonPrimary,
                                onPrimary: prs.colorTextDescription,
                                elevation: 2.0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0))),
                            label: Text('Ampliar'),
                            icon: Icon(Icons.zoom_out_map),
                            onPressed: () {
                              mostrarImagen(context,
                                  '${Sistema.storage}${chatCompraModel.mensaje}?alt=media');
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
      estadoChat(chatCompraModel, true),
    ],
  );
}

Widget archivoParaClienteEnvia(
    BuildContext context, cajeroModel, chatCompraModel, imagen) {
  return Row(
    children: <Widget>[
      Container(
        margin: const EdgeInsets.only(left: 1.0, right: 1.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(40.0),
          child: (chatCompraModel.envia == 0)
              ? Container(
                  child: CircleAvatar(
                    child: Text(
                      cajeroModel.acronimo,
                      style: TextStyle(
                          color: prs.colorTextDescription, fontSize: 15.0),
                    ),
                    backgroundColor: Colors.black38,
                  ),
                )
              : cache.fadeImage(cajeroModel.img,
                  width: 40,
                  height: 40,
                  acronimo: cajeroModel.acronimo,
                  color: Colors.grey,
                  fontSize: 18),
        ),
      ),
      (chatCompraModel.tipo == conf.CHAT_TIPO_AUDIO)
          ? ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: AudioPlayWidget(
                chatCompraModel,
                ValueKey(UniqueKey()),
                color: Colors.blueAccent,
                backgroud: Colors.black12,
              ),
            )
          : Flexible(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: Container(
                  color: Colors.black12,
                  child: Container(
                    margin: const EdgeInsets.all(5.0),
                    child: Row(
                      children: <Widget>[
                        Container(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                                primary: prs.colorButtonPrimary,
                                onPrimary: prs.colorTextDescription,
                                elevation: 2.0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0))),
                            label: Text('Ampliar'),
                            icon: Icon(Icons.zoom_out_map),
                            onPressed: () {
                              mostrarImagen(context,
                                  '${Sistema.storage}${chatCompraModel.mensaje}?alt=media');
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
      estadoChat(chatCompraModel, false),
      SizedBox(width: 70.0),
    ],
  );
}

Row chatLinea(chatCompraModel, BuildContext context) {
  final size = MediaQuery.of(context).size;
  return Row(
    children: <Widget>[
      Expanded(child: Container(height: 1, child: Divider())),
      Column(children: <Widget>[
        Container(
          child: Text(chatCompraModel.mensaje.toString(),
              textAlign: TextAlign.center),
          width: size.width - 90,
        ),
        Text(chatCompraModel.fechaRegistro.toString()),
      ]),
      Expanded(child: Container(height: 1, child: Divider())),
    ],
  );
}

Column estadoChat(chatCompraModel, bool mostrarIcono) {
  return Column(
    children: <Widget>[
      mostrarIcono ? _iconoChat(chatCompraModel) : Container(),
      Text(chatCompraModel.hora.toString(), style: TextStyle(fontSize: 11.0)),
    ],
  );
}

void mostrarImagen(BuildContext context, String url) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.transparent,
        content: FadeInImage(
            image: (url == null || url.toString().length <= 10
                ? AssetImage('assets/no-image.png')
                : Image.network(url).image),
            placeholder: AssetImage('assets/no-image.png'),
            fit: BoxFit.cover),
        actions: <Widget>[
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
                primary: prs.colorButtonSecondary,
                elevation: 2.0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0))),
            label: Text('Salir'),
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

Icon _iconoChat(chatCompraModel) {
  switch (chatCompraModel.estado) {
    case 0:
      return Icon(Icons.timer, size: 17.0);
    case 1:
      return Icon(Icons.done, size: 17.0);
    case 2:
      return Icon(Icons.done_all, size: 17.0);
    default:
      return Icon(Icons.done_all, size: 17.0, color: prs.colorIcons);
  }
}
