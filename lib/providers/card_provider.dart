import 'dart:async';
import 'dart:convert';

// import 'package:flutter_paymentez/flutter_paymentez.dart';
// import 'package:flutter_paymentez/models/addCardResponse.dart';
import 'package:http/http.dart' as http;

import '../model/card_model.dart';
import '../preference/shared_preferences.dart';
import '../sistema.dart';
import '../utils/conf.dart' as conf;
import '../utils/utils.dart' as utils;

class CardProvider {
  final PreferenciasUsuario _prefs = PreferenciasUsuario();

  final String _urlListar = 'card/listar';
  final String _urlCanjear = 'card/canjear';
  final String _urlEliminar = 'card/eliminar';
  final String _urlVerificar = 'card/verificar';
  final String _urlDebitar = 'card/debitar';
  final String _urlAutorizar = 'card/autorizar';

  //Usado cuando se verifica en el registro
  verificar(CardModel cardModel, dynamic otp, Function response) async {
    String idTransaccion =
        '0'; //Cero por que no hay transaccion solo verificacion de registro
    var client = http.Client();
    try {
      final resp = await client.post(Uri.parse(Sistema.dominio + _urlVerificar),
          headers: utils.headers,
          body: {
            'idCliente': _prefs.idCliente,
            'auth': _prefs.auth,
            'token': cardModel.token.toString(),
            'transactionId': cardModel.transactionReference.toString(),
            'type': 'BY_OTP',
            'value': otp.toString(),
          });
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      if (decodedResp['estado'] == 1) {
        return response(decodedResp['status'],
            decodedResp['id_transaccion'].toString(), decodedResp['error']);
      }
      if (decodedResp['estado'] <= 0) {
        return response(500, idTransaccion, decodedResp['error'].toString());
      }
    } catch (err) {
      print('card_provider error: $err');
      return false;
    } finally {
      client.close();
    }
    return response(500, idTransaccion, conf.MENSAJE_INTERNET);
  }

  //Usado cunaod se autoriza en el pago
  autorizar(CardModel cardModel, dynamic otp, dynamic idTransaccion,
      Function response) async {
    var client = http.Client();
    try {
      final resp = await client.post(Uri.parse(Sistema.dominio + _urlAutorizar),
          headers: utils.headers,
          body: {
            'idCliente': _prefs.idCliente,
            'auth': _prefs.auth,
            'token': cardModel.token.toString(),
            'value': otp.toString(),
            'idTransaccion': idTransaccion.toString()
          });
      Map<String, dynamic> decodedResp = json.decode(resp.body);

      if (decodedResp['estado'] == 1) {
        return response(decodedResp['status'],
            decodedResp['id_transaccion'].toString(), decodedResp['error']);
      }
      if (decodedResp['estado'] <= 0) {
        return response(500, idTransaccion, decodedResp['error'].toString());
      }
    } catch (err) {
      print('card_provider error: $err');
      return false;
    } finally {
      client.close();
    }
    return response(500, idTransaccion, conf.MENSAJE_INTERNET);
  }

  debitar(CardModel cardModel, String amount, String cash, dynamic sucursal,
      dynamic costo, dynamic envio, dynamic detalle, Function response,
      {String pin: '', String idAgencia: '0'}) async {
    String idTransaccion = '0';
    final resp = await http.post(Uri.parse(Sistema.dominio + _urlDebitar),
        headers: utils.headers,
        body: {
          'idCliente': _prefs.idCliente,
          'auth': _prefs.auth,
          'token': cardModel.token,
          'amount': amount,
          'cash': cash,
          'detalle': detalle.toString(),
          'envio': envio.toString(),
          'costo': costo.toString(),
          'sucursal': sucursal.toString(),
          'pin': pin,
          'idAgencia': idAgencia,
        });
    Map<String, dynamic> decodedResp = json.decode(resp.body);
    if (decodedResp['estado'] == 1) {
      return response(
          decodedResp['status'],
          decodedResp['id_transaccion'].toString(),
          decodedResp['error'].toString());
    }
    if (decodedResp['estado'] <= 0) {
      return response(500, idTransaccion, decodedResp['error'].toString());
    }
    return response(500, idTransaccion, conf.MENSAJE_INTERNET);
  }

  Future<bool> eliminar(CardModel cardModel) async {
    final resp = await http.post(Uri.parse(Sistema.dominio + _urlEliminar),
        headers: utils.headers,
        body: {
          'idCliente': _prefs.idCliente,
          'auth': _prefs.auth,
          'token': cardModel.token,
        });
    Map<String, dynamic> decodedResp = json.decode(resp.body);
    if (decodedResp['estado'] == 1) {
      return true;
    }
    return false;
  }

  Future<CardModel> crear(CardModel cardModel) async {
    // final FlutterPaymentez _pymntz = FlutterPaymentez();
    // final AddCardResponseModel response = await _pymntz.addCard(
    //   uid: _prefs.clienteModel.idCliente,
    //   email: _prefs.clienteModel.correo,
    //   name: cardModel.holderName,
    //   cardNumber: cardModel.number,
    //   expiryMonth: cardModel.expiryMonth,
    //   expiryYear: cardModel.expiryYear,
    //   cvc: cardModel.cvv,
    //   clientAppCode: Sistema.CLIENT_APP_CODE,
    //   clientAppKey: Sistema.CLIENTE_APP_KEY,
    //   isTestMode: Sistema.isTestMode.toString(),
    // );
    // cardModel.status = response.status;
    // cardModel.token = response.token;
    // cardModel.transactionReference = response.txReference;
    return cardModel;
  }

  Future<List<CardModel>> listar(String idAgencia) async {
    var client = http.Client();
    List<CardModel> cardesResponse = [];
    try {
      final resp = await client.post(Uri.parse(Sistema.dominio + _urlListar),
          headers: utils.headers,
          body: {
            'idCliente': _prefs.idCliente,
            'auth': _prefs.auth,
            'idAgencia': idAgencia,
          });
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      if (decodedResp['estado'] == 1) {
        for (var item in decodedResp['cardes']) {
          cardesResponse.add(CardModel.fromJson(item));
        }
      }
    } catch (err) {
      print('card_provider error: $err');
    } finally {
      client.close();
    }
    return cardesResponse;
  }

  canejar(String codigo, Function response) async {
    var client = http.Client();
    try {
      final resp = await client.post(Uri.parse(Sistema.dominio + _urlCanjear),
          headers: utils.headers,
          body: {
            'idCliente': _prefs.idCliente,
            'auth': _prefs.auth,
            'codigo': codigo,
          });
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      if (decodedResp['estado'] == 1) {
        return response(
            1, decodedResp['error'], CardModel.fromJson(decodedResp['card']));
      }
      return response(0, decodedResp['error'], null);
    } catch (err) {
      print('card_provider error: $err');
    } finally {
      client.close();
    }
    return response(0, conf.MENSAJE_INTERNET, null);
  }
}
