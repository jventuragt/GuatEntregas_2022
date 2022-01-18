import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../preference/shared_preferences.dart';
import '../sistema.dart';
import '../utils/cache.dart' as cache;
import '../utils/conf.dart' as conf;
import '../utils/personalizacion.dart' as prs;

class DespachoModel {
  int onLine;
  int celularValidado;
  int preparandose;

  dynamic lt;
  dynamic lg;
  dynamic ltA;
  dynamic lgA;
  dynamic ltB;
  dynamic lgB;
  dynamic ruta;
  dynamic despacho;
  dynamic idCompra;
  int sinLeerConductor;
  int correctos;
  int sinLeerCliente;
  int calificarCliente;
  int calificarConductor;
  dynamic calificacionCliente;
  dynamic calificacionConductor;
  dynamic comentarioCliente;
  dynamic comentarioConductor;

  double costoEnvio;
  double costo;
  double credito;
  double creditoProducto;
  double creditoEnvio;
  double costoProducto;

  final PreferenciasUsuario _prefs = PreferenciasUsuario();

  int tipoUsuario() {
    if (_prefs.idCliente.toString() == idConductor.toString())
      return conf.TIPO_CONDCUTOR;
    if (_prefs.idCliente.toString() == idCliente.toString())
      return conf.TIPO_CLIENTE;
    return conf.TIPO_ASESOR;
  }

  bool isConductor() {
    return _prefs.idCliente.toString() == idConductor.toString();
  }

  bool isCliente() {
    return _prefs.idCliente.toString() == idCliente.toString();
  }

  String efectivoEnvio() {
    return (costoEnvio - creditoEnvio).toStringAsFixed(2);
  }

  String efectivoProdcuto() {
    return (costoProducto - creditoProducto).toStringAsFixed(2);
  }

  String efectivoTotal() {
    return (costo - credito).toStringAsFixed(2);
  }

  Widget iconoFormaPago() {
    final pago = formaPago.toString().toUpperCase();
    if (pago == Sistema.TARJETA.toUpperCase())
      return prs.iconoPagoTarjeta;
    else if (pago == Sistema.CUPON.toUpperCase())
      return prs.iconoPagoCupon;
    else
      return prs.iconoPagoEfefcivo;
  }

  dynamic idConductor;
  dynamic idCliente;
  String codigoPais;
  String celular;
  String telSuc;
  String nombres;
  String img;
  String formaPago;
  dynamic idDespachoEstado;
  dynamic estado;
  dynamic idDespacho;
  String abiero;

  int tipo; //Tipo de compra

  get label {
    if (idDespacho == -1) return 'Cargando...';
    if (idDespacho == 0) return 'Solicitud confirmada';

    switch (idDespachoEstado) {
      case conf.DESPACHO_BUSCANDO:
        return 'Solicitud confirmada';
      case conf.DESPACHO_CANCELADA:
        return 'Despacho cancelado';
      default:
        return nombres;
    }
  }

  get _parse {
    return json.decode(despacho);
  }

  get numerosJson {
    return _parse['lConE'];
  }

  get detalleJson {
    return _parse['d'];
  }

  get referenciaJson {
    return _parse['r'];
  }

  get sucursalJson {
    return _parse['a'];
  }

  get costoJson {
    return _parse['c'];
  }

  get costoEnvioJson {
    return _parse['ce'];
  }

  get latLngBounds {
    dynamic slt, slg;
    dynamic nlt, nlg;

    if (ltA <= ltB) {
      slt = ltA;
      nlt = ltB;
    } else {
      slt = ltB;
      nlt = ltA;
    }
    if (lgA <= lgB) {
      slg = lgA;
      nlg = lgB;
    } else {
      slg = lgB;
      nlg = lgA;
    }
    return LatLngBounds(
        northeast: LatLng(nlt, nlg), southwest: LatLng(slt, slg));
  }

  get acronimo {
    var acronimos = nombres.toString().split(' ');
    String first = acronimos.first.substring(0, 1);
    String last = acronimos.length > 1 ? acronimos[1].substring(0, 1) : '';
    return '$first$last'.toUpperCase();
  }

  get iconoIngreso {
    return 'assets/pool/ingreso_1.png';
  }

  get iconoSalida {
    return 'assets/pool/salida_1.png';
  }

  DespachoModel({
    this.preparandose: 1,
    this.tipo: -1,
    this.correctos: 0,
    this.onLine,
    this.celularValidado,
    this.lt: 0.0,
    this.lg: 0.0,
    this.ltA: 0.0,
    this.lgA: 0.0,
    this.ltB: 0.0,
    this.lgB: 0.0,
    this.despacho,
    this.formaPago: 'Efectivo',
    this.ruta,
    this.idCompra,
    this.sinLeerConductor,
    this.sinLeerCliente,
    this.calificarCliente,
    this.calificarConductor,
    this.calificacionCliente: 5.0,
    this.calificacionConductor: 5.0,
    this.comentarioCliente,
    this.comentarioConductor,
    this.costoEnvio: 0.0,
    this.costoProducto: 0.0,
    this.costo: 0.0,
    this.credito: 0.0,
    this.creditoProducto: 0.0,
    this.creditoEnvio: 0.0,
    this.idConductor,
    this.idCliente,
    this.codigoPais,
    this.celular,
    this.telSuc,
    this.nombres,
    this.img: 'assets/pool/ingreso_1.png',
    this.idDespachoEstado: 0,
    this.estado: 'Por favor espera',
    this.idDespacho: -1,
    this.abiero: '1',
  });

  factory DespachoModel.fromJson(Map<String, dynamic> json) => DespachoModel(
        preparandose: json["preparandose"] == null
            ? 1
            : int.parse(json["preparandose"]?.toString()),
        formaPago: json["forma_pago"] == null
            ? 'Efectivo'
            : json["forma_pago"].toString(),
        abiero: json["abiero"] == null ? '1' : json["abiero"].toString(),
        telSuc: json["telSuc"] == null ? '' : json["telSuc"].toString(),
        tipo: json["tipo"] == null ? 1 : int.parse(json["tipo"]?.toString()),
        correctos: json["correctos"] == null ? 0 : json["correctos"],
        onLine: json["on_line"],
        celularValidado: json["celularValidado"],
        lt: json["lt"] == null ? 0.0 : json["lt"].toDouble(),
        lg: json["lg"] == null ? 0.0 : json["lg"].toDouble(),
        ltA: json["ltA"] == null ? 0.0 : json["ltA"].toDouble(),
        lgA: json["lgA"] == null ? 0.0 : json["lgA"].toDouble(),
        ltB: json["ltB"] == null ? 0.0 : json["ltB"].toDouble(),
        lgB: json["lgB"] == null ? 0.0 : json["lgB"].toDouble(),
        despacho: json["despacho"],
        ruta: json["ruta"],
        idCompra: json["id_compra"],
        sinLeerConductor: json["sinLeerConductor"],
        sinLeerCliente: json["sinLeerCliente"],
        calificarCliente: json["calificarCliente"],
        calificacionCliente: json["calificacionCliente"] == null
            ? 5.0
            : json["calificacionCliente"].toDouble(),
        calificacionConductor: json["calificacionConductor"] == null
            ? 5.0
            : json["calificacionConductor"].toDouble(),
        calificarConductor: json["calificarConductor"],
        comentarioCliente: json["comentarioCliente"],
        comentarioConductor: json["comentarioConductor"],
        costoEnvio:
            json["costo_envio"] == null ? 0.0 : json["costo_envio"].toDouble(),
        costoProducto: json["costo_producto"] == null
            ? 0.0
            : json["costo_producto"].toDouble(),
        costo: json["costo"] == null ? 0.0 : json["costo"].toDouble(),
        credito: json["credito"] == null ? 0.0 : json["credito"].toDouble(),
        creditoEnvio: json["credito_envio"] == null
            ? 0.0
            : json["credito_envio"].toDouble(),
        creditoProducto: json["credito_producto"] == null
            ? 0.0
            : json["credito_producto"].toDouble(),
        idConductor: json["id_conductor"],
        idCliente: json["id_cliente"],
        codigoPais: json["codigoPais"],
        celular: json["celular"],
        nombres: json["nombres"],
        img: json["img"] == null
            ? 'assets/screen/compras.png'
            : cache.img(json["img"]),
        idDespachoEstado: json["id_despacho_estado"],
        estado: json["estado"] == null ? '' : json["estado"],
        idDespacho: json["id_despacho"],
      );

  Map<String, dynamic> toJson() => {
        "tipo": tipo,
        "abiero": abiero == null ? '1' : abiero,
        "correctos": correctos,
        "on_line": onLine,
        "celularValidado": celularValidado,
        "lt": lt,
        "lg": lg,
        "ltA": ltA,
        "lgA": lgA,
        "ltB": ltB,
        "lgB": lgB,
        "despacho": despacho,
        "ruta": ruta,
        "id_compra": idCompra,
        "sinLeerConductor": sinLeerConductor,
        "sinLeerCliente": sinLeerCliente,
        "calificarCliente": calificarCliente,
        "calificarConductor": calificarConductor,
        "calificacionCliente": calificacionCliente,
        "calificacionConductor": calificacionConductor,
        "comentarioCliente": comentarioCliente,
        "comentarioConductor": comentarioConductor,
        "costo_envio": costoEnvio,
        "costo": costo,
        "id_conductor": idConductor,
        "id_cliente": idCliente,
        "codigoPais": codigoPais,
        "celular": celular,
        "nombres": nombres,
        "img": img,
        "id_despacho_estado": idDespachoEstado,
        "estado": estado,
        "id_despacho": idDespacho,
      };
}
