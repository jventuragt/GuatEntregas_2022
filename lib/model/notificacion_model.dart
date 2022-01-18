import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../pages/delivery/menu_page.dart';
import '../preference/review.dart';
import '../providers/catalogo_provider.dart';
import '../utils/cache.dart' as cache;
import '../utils/utils.dart' as utils;
import 'catalogo_model.dart';

CatalogoProvider _catalogoProvider = CatalogoProvider();

class NotificacionModel {
  String idMensaje;
  String hint;
  String detalle;
  String img;
  String omitir;
  String boton;
  String datos;

  accion(BuildContext context) async {
    Map<String, dynamic> decodedResp = (jsonDecode(datos));
    if (decodedResp == null) {
      return;
    } else if (decodedResp['tipo']?.toString() == '1') {
      Navigator.pop(context);
      _launchURL(decodedResp['url']?.toString());
    } else if (decodedResp['tipo']?.toString() == '2') {
      Navigator.pop(context);
      Navigator.pushNamed(context, decodedResp['url']?.toString());
    } else if (decodedResp['tipo']?.toString() == '3') {
      utils.mostrarProgress(context);
      CatalogoModel catalogoModel =
          await _catalogoProvider.ver(decodedResp['url']?.toString());
      if (catalogoModel == null) return;
      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => MenuPage(catalogoModel)));
    } else if (decodedResp['tipo']?.toString() == '4') {
      Navigator.pop(context);
      Review().requestReview(decodedResp['url']?.toString());
    } else {
      Navigator.pop(context);
      return;
    }
  }

  _launchURL(String url) async {
    var encoded = Uri.encodeFull(url);
    if (await canLaunch(encoded)) {
      await launch(encoded);
    } else {
      print('Could not open the url.');
    }
  }

  NotificacionModel({
    this.idMensaje: '0',
    this.hint,
    this.detalle,
    this.img,
    this.boton,
    this.omitir,
    this.datos,
  });

  factory NotificacionModel.fromJson(Map<String, dynamic> json) =>
      NotificacionModel(
        omitir: json["omitir"] == null ? 'OMITIR' : json["omitir"].toString(),
        boton: json["boton"] == null ? 'ACEPTAR' : json["boton"].toString(),
        idMensaje:
            json["id_mensaje"] == null ? '0' : json["id_mensaje"].toString(),
        hint: json["hint"],
        detalle: json["detalle"],
        img: cache.img(json["img"]),
        datos: json["datos"],
      );

  Map<String, dynamic> toJson() => {
        "id_mensaje": idMensaje,
        "hint": hint,
        "img": img,
        "datos": datos,
      };
}
