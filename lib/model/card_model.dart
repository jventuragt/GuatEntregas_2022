import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../sistema.dart';
import '../utils/cache.dart' as cache;
import '../utils/personalizacion.dart' as prs;

CardModel cardModelFromJson(String str) => CardModel.fromJson(json.decode(str));

String cardModelToJson(CardModel data) => json.encode(data.toJson());

class CardModel {
  CardModel({
    this.idFormaPago: '10',
    this.idCupon: '0',
    this.idAgencia: '0',
    this.cupon: 0.0,
    this.bin: '11111',
    this.status: 'valid',
    this.token,
    this.mensaje,
    this.terminos,
    this.holderName,
    this.expiryYear,
    this.expiryMonth,
    this.transactionReference,
    this.type,
    this.cvv,
    this.number: Sistema.EFECTIVO,
    this.modo: Sistema.EFECTIVO,
  });

  bool isTarjeta() {
    return idFormaPago.toString() == Sistema.ID_FOMRA_PAGO_TARJETA;
  }

  String idFormaPago;
  String idCupon;
  String idAgencia; //Usamos un card para dar cupones
  double cupon;
  String mensaje;
  String terminos;
  String cvv;
  String bin;
  String status;
  String token;
  String holderName;
  String expiryYear;
  String expiryMonth;
  String transactionReference;
  String type;
  String number;
  String modo;

  Widget iconoStatus() {
    if (status.toString().toUpperCase() == 'VALID')
      return Icon(FontAwesomeIcons.check, color: Colors.green, size: 12.0);
    if (status.toString().toUpperCase() == 'REVIEW' ||
        status.toString().toUpperCase() == 'PENDING')
      return Icon(FontAwesomeIcons.clock, color: Colors.deepPurple, size: 15.0);
    return Icon(Icons.clear, color: Colors.red, size: 16.0);
  }

  Widget iconoTarjeta() {
    if (modo.toUpperCase() == Sistema.CUPON.toUpperCase())
      return Container(
        width: 57.0,
        height: 45.0,
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          child: cache.fadeImage(token),
        ),
      );
    else if (modo.toUpperCase() == Sistema.EFECTIVO.toUpperCase())
      return Container(
          margin: EdgeInsets.only(right: 7.0),
          child: Icon(FontAwesomeIcons.moneyBillWave,
              color: prs.colorIcons, size: 30.0));

    IconData ccBrandIcon;

    if (type == 'vi') {
      ccBrandIcon = FontAwesomeIcons.ccVisa;
    } else if (type == 'mc') {
      ccBrandIcon = FontAwesomeIcons.ccMastercard;
    } else if (type == 'ax') {
      ccBrandIcon = FontAwesomeIcons.ccAmex;
    } else if (type == 'dc') {
      ccBrandIcon = FontAwesomeIcons.ccDiscover;
    } else if (type == 'di') {
      ccBrandIcon = FontAwesomeIcons.ccDinersClub;
    }
    // else if (type == 'ms') {
    //   ccBrandIcon = FontAwesomeIcons.creditCard;
    // }
    else {
      ccBrandIcon = FontAwesomeIcons.creditCard;
    }

    return Container(
      margin: EdgeInsets.only(right: 7.0),
      child: Icon(ccBrandIcon, color: prs.colorIcons, size: 36.0),
    );
  }

  bool isValid() {
    return status.toString().toUpperCase() == 'VALID';
  }

  bool isReview() {
    return status.toString().toUpperCase() == 'REVIEW';
  }

  bool isPendig() {
    return status.toString().toUpperCase() == 'PENDING';
  }

  bool isReject() {
    return status.toString().toUpperCase() == 'REJECTED';
  }

  factory CardModel.fromJson(Map<String, dynamic> json) => CardModel(
        idFormaPago: json["id_forma_pago"] == null
            ? '23'
            : json["id_forma_pago"].toString(),
        idAgencia:
            json["id_agencia"] == null ? '0' : json["id_agencia"].toString(),
        idCupon: json["id_cupon"] == null ? '-1' : json["id_cupon"].toString(),
        cupon: json["cupon"] == null
            ? 0.0
            : double.parse(json["cupon"].toString()) / 1,
        bin: json["bin"].toString(),
        status: json["status"] == null ? 'valid' : json["status"].toString(),
        token: json["token"].toString(),
        terminos: json["terminos"] == null ? '' : json["terminos"].toString(),
        mensaje: json["mensaje"] == null ? '' : json["mensaje"].toString(),
        holderName: json["holder_name"].toString(),
        expiryYear: json["expiry_year"].toString(),
        expiryMonth: json["expiry_month"].toString(),
        transactionReference: json["transaction_reference"].toString(),
        modo: json["modo"] == null ? 'Tarjeta' : json["modo"].toString(),
        type: json["type"].toString(),
        number: 'XXXX XXXX ${json["number"]}',
      );

  Map<String, dynamic> toJson() => {
        "bin": bin,
        "status": status,
        "token": token,
        "holder_name": holderName,
        "expiry_year": expiryYear,
        "expiry_month": expiryMonth,
        "transaction_reference": transactionReference,
        "type": type,
        "number": number,
      };
}
