import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../bloc/preferencias_bloc.dart';
import '../model/cliente_model.dart';
import '../model/notificacion_model.dart';
import '../model/session_model.dart';
import '../preference/push_provider.dart';
import '../preference/shared_preferences.dart';
import '../sistema.dart';
import '../utils/conf.dart' as config;
import '../utils/upload.dart' as upload;
import '../utils/utils.dart' as utils;

class ClienteProvider {
  final PreferenciasUsuario _prefs = PreferenciasUsuario();

  final String _urlMensaje = 'cliente/mensaje';
  final String _urlVer = 'cliente/ver';
  final String _urlAutenticarClave = 'cliente/autenticar-clave';
  final String _urlAutenticarApple = 'cliente/autenticar-apple';
  final String _urlAutenticarGoogle = 'cliente/autenticar-google';
  final String _urlAutenticarFacebook = 'cliente/autenticar-facebook';
  final String _urlActualizarToken = 'cliente/actualizar-token';
  final String _recuperarContrasenia = 'cliente/recuperar-contrasenia';
  final String _urlCerrarSession = 'cliente/cerrar-session';
  final String _urlEditar = 'cliente/editar';
  final String _urlCambiarContrasenia = 'cliente/cambiar-contrasenia';
  final String _urlCambiarImagen = 'cliente/cambiar-imagen';
  final String _urlLike = 'cliente/like';
  final String _urlUrbe = 'cliente/urbe';
  final String _urlLink = 'cliente/link';
  final String _urlRastrear = 'cliente/rastrear';
  final String _urlSessiones = 'cliente/sessiones';
  final String _urlGenero = 'cliente/genero';
  final String _urlVerificarValidadCelular =
      'cliente/verificar-validar-celular';
  final String _urlValidadCelular = 'cliente/validar-celular';
  final String _urlEscuchar = 'cliente/escuchar';

  final String _urlCanjear = 'cliente/canjear';

  final String _urlSaldo = 'saldo/ver';

  urbe(dynamic idUrbe) async {
    var client = http.Client();
    try {
      await client.post(Uri.parse(Sistema.dominio + _urlUrbe),
          headers: utils.headers,
          body: {
            'idCliente': _prefs.idCliente,
            'idUrbe': idUrbe.toString(),
            'auth': _prefs.auth,
          });
    } catch (err) {
      print('cliente_provider error: $err');
    } finally {
      client.close();
    }
  }

  mensaje(String idMensaje, int accion) async {
    var client = http.Client();
    try {
      await client.post(Uri.parse(Sistema.dominio + _urlMensaje),
          headers: utils.headers,
          body: {
            'idCliente': _prefs.idCliente,
            'auth': _prefs.auth,
            'perfil': _prefs.clienteModel.perfil.toString(),
            'idMensaje': idMensaje,
            'accion': accion.toString(),
          });
    } catch (err) {
      print('cliente_provider error: $err');
    } finally {
      client.close();
    }
  }

  saldo(dynamic idCliente, Function response) async {
    var client = http.Client();

    try {
      final resp = await client.post(Uri.parse(Sistema.dominio + _urlSaldo),
          headers: utils.headers,
          body: {
            'idCliente': _prefs.idCliente,
            'auth': _prefs.auth,
            'perfil': _prefs.clienteModel.perfil.toString(),
            'dir': _prefs.clienteModel.direcciones.toString(),
            'idClienteSaldo': idCliente.toString(),
          });
      Map<String, dynamic> decodedResp = json.decode(resp.body);

      if (decodedResp['estado'] == 1) {
        try {
          return response(
            double.parse(decodedResp['s']['saldo'].toString())
                .toStringAsFixed(2),
            double.parse(decodedResp['s']['credito'].toString())
                .toStringAsFixed(2),
            double.parse(decodedResp['s']['cash'].toString())
                .toStringAsFixed(2),
          );
        } catch (err) {
          print('cliente_provider saldo error: $err');
        }
      }
      return response('0.00', '0.00', '0.00');
    } catch (err) {
      print('cliente_provider error: $err');
    } finally {
      client.close();
    }
    //Retornamos el saldo y el credito
    return response('0.00', '0.00', '0.00');
  }

  canjear(dynamic idClienteRefiere, int tipo) async {
    if (idClienteRefiere.toString() == _prefs.idCliente.toString()) return;
    var client = http.Client();
    try {
      await client.post(Uri.parse(Sistema.dominio + _urlCanjear),
          headers: utils.headers,
          body: {
            'idCliente': _prefs.idCliente,
            'auth': _prefs.auth,
            'idClienteRefiere': idClienteRefiere.toString(),
            'tipo': tipo.toString(),
          });
    } catch (err) {
      print('cliente_provider error: $err');
    } finally {
      client.close();
    }
  }

  link(dynamic idCliente, String link) async {
    var client = http.Client();
    try {
      await client.post(Uri.parse(Sistema.dominio + _urlLink),
          headers: utils.headers,
          body: {
            'idCliente': _prefs.idCliente,
            'auth': _prefs.auth,
            'link': link.toString(),
          });
    } catch (err) {
      print('cliente_provider error: $err');
    } finally {
      client.close();
    }
  }

  Future<bool> escuchar(dynamic idRastreo) async {
    var client = http.Client();
    try {
      final resp = await client.post(Uri.parse(Sistema.dominio + _urlEscuchar),
          headers: utils.headers,
          body: {
            'idCliente': _prefs.idCliente,
            'auth': _prefs.auth,
            'idRastreo': idRastreo.toString(),
          });
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      if (decodedResp['estado'] == 1) return true;
    } catch (err) {
      print('cliente_provider error: $err');
    } finally {
      client.close();
    }
    return false;
  }

  Future rastrear(bool rastrear) async {
    var client = http.Client();
    try {
      final resp = await client.post(Uri.parse(Sistema.dominio + _urlRastrear),
          headers: utils.headers,
          body: {
            'idCliente': _prefs.idCliente,
            'auth': _prefs.auth,
            'rastrear': rastrear ? '1' : '0',
          });
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      if (decodedResp['estado'] == 1) return true;
    } catch (err) {
      print('cliente_provider error: $err');
    } finally {
      client.close();
    }
    return false;
  }

  Future enviarRastreo(double lt, double lg) async {
    var client = http.Client();
    try {
      final resp = await client.post(Uri.parse(Sistema.dominio + 'r'),
          headers: utils.headers,
          body: {
            'idCliente': _prefs.idCliente,
            'auth': _prefs.auth,
            'lt': lt.toString(),
            'lg': lg.toString()
          });
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      if (decodedResp['estado'] == 1) return true;
    } catch (err) {
      print('cliente_provider error: $err');
    } finally {
      client.close();
    }
    return false;
  }

  verificarValidadCelular(dynamic celular, Function response) async {
    var client = http.Client();
    try {
      final resp = await client.post(
          Uri.parse(Sistema.dominio + _urlVerificarValidadCelular),
          headers: utils.headers,
          body: {
            'idCliente': _prefs.idCliente,
            'auth': _prefs.auth,
            'celular': celular.toString(),
          });
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      return response(decodedResp['estado'], decodedResp['error']);
    } catch (err) {
      print('cliente_provider error: $err');
    } finally {
      client.close();
    }
    return response(0, config.MENSAJE_INTERNET);
  }

  validadCelular(dynamic celular, {dynamic idClienteVerificar: 0}) async {
    var client = http.Client();
    try {
      final resp = await client.post(
          Uri.parse(Sistema.dominio + _urlValidadCelular),
          headers: utils.headers,
          body: {
            'idCliente': _prefs.idCliente,
            'idClienteVerificar': idClienteVerificar == 0
                ? _prefs.idCliente
                : idClienteVerificar.toString(),
            'auth': _prefs.auth,
            'celular': celular.toString(),
          });
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      if (idClienteVerificar == 0 && decodedResp['estado'] == 1) {
        ClienteModel clienteModel =
            ClienteModel.fromJson(decodedResp['cliente']);
        _prefs.clienteModel = clienteModel;
        _prefs.sms = '';
      }
    } catch (err) {
      print('cliente_provider error: $err');
    } finally {
      client.close();
    }
  }

  genero(ClienteModel cliente) async {
    var client = http.Client();
    try {
      final resp = await client.post(Uri.parse(Sistema.dominio + _urlGenero),
          headers: utils.headers,
          body: {
            'idCliente': _prefs.idCliente,
            'auth': _prefs.auth,
            'sexo': cliente.sexo.toString(),
          });
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      if (decodedResp['estado'] == 1) _prefs.clienteModel = cliente;
    } catch (err) {
      print('cliente_provider error: $err');
    } finally {
      client.close();
    }
  }

  Future<List<SessionModel>> listarSessiones() async {
    var client = http.Client();
    List<SessionModel> sessionesResponse = [];
    try {
      final resp = await client.post(Uri.parse(Sistema.dominio + _urlSessiones),
          headers: utils.headers,
          body: {
            'idCliente': _prefs.idCliente,
            'auth': _prefs.auth,
          });
      Map<String, dynamic> decodedResp = json.decode(resp.body);

      if (decodedResp['estado'] == 1) {
        for (var item in decodedResp['sessiones']) {
          sessionesResponse.add(SessionModel.fromJson(item));
        }
      }
    } catch (err) {
      print('cliente_provider error: $err');
    } finally {
      client.close();
    }
    return sessionesResponse;
  }

  like(dynamic idCliente, String like) async {
    var client = http.Client();
    try {
      await client.post(Uri.parse(Sistema.dominio + _urlLike),
          headers: utils.headers,
          body: {
            'idCliente': _prefs.idCliente,
            'idClienteLike': idCliente.toString(),
            'auth': _prefs.auth,
            'like': like.toString(),
          });
    } catch (err) {
      print('cliente_provider error: $err');
    } finally {
      client.close();
    }
  }

  cambiarImagen(dynamic img, Function response) async {
    var client = http.Client();
    try {
      final resp = await client.post(
          Uri.parse(Sistema.dominio + _urlCambiarImagen),
          headers: utils.headers,
          body: {
            'idCliente': _prefs.idCliente,
            'auth': _prefs.auth,
            'img': img.toString(),
          });
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      if (decodedResp['estado'] == 1) return response(1, decodedResp['error']);
      return response(0, decodedResp['error']);
    } catch (err) {
      print('cliente_provider error: $err');
    } finally {
      client.close();
    }
    return response(0, config.MENSAJE_INTERNET);
  }

  Future<String> subirArchivoMobil(File imagen, String nombreImagen) async {
    try {
      return await upload.subirArchivoMobil(
          imagen, 'uss/$nombreImagen', Sistema.TARGET_WIDTH_PERFIL);
    } catch (err) {
      print('cliente_provider error: $err');
    }
    return '';
  }

  Future<String> subirArchivoWeb(List<int> value, String nombreImagen) async {
    try {
      return await upload.subirArchivoWeb(value, 'uss/$nombreImagen');
    } catch (err) {
      print('cliente_provider error: $err');
    }
    return '';
  }

  cambiarContrasenia(dynamic contraseniaAnterior, dynamic contraseniaNueva,
      Function response) async {
    var client = http.Client();
    try {
      final resp = await client.post(
          Uri.parse(Sistema.dominio + _urlCambiarContrasenia),
          headers: utils.headers,
          body: {
            'idCliente': _prefs.idCliente,
            'auth': _prefs.auth,
            'contraseniaAnterior': contraseniaAnterior.toString(),
            'contraseniaNueva': contraseniaNueva.toString(),
          });
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      if (decodedResp['estado'] == 1) return response(1, decodedResp['error']);
      return response(0, decodedResp['error']);
    } catch (err) {
      print('cliente_provider error: $err');
    } finally {
      client.close();
    }
    return response(0, config.MENSAJE_INTERNET);
  }

  editar(ClienteModel cliente, Function response) async {
    var client = http.Client();
    try {
      final resp = await client.post(Uri.parse(Sistema.dominio + _urlEditar),
          headers: utils.headers,
          body: {
            'idCliente': _prefs.idCliente,
            'auth': _prefs.auth,
            'celular': cliente.celular.toString(),
            'correo': cliente.correo.toString(),
            'nombres': cliente.nombres.toString(),
            'fechaNacimiento': cliente.fechaNacimiento.toString(),
          });
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      if (decodedResp['estado'] == 1) {
        ClienteModel clienteModel =
            ClienteModel.fromJson(decodedResp['cliente']);
        _prefs.clienteModel = clienteModel;
        return response(1, decodedResp['error']);
      }
      return response(0, decodedResp['error']);
    } catch (err) {
      print('cliente_provider error: $err');
    } finally {
      client.close();
    }
    return response(0, config.MENSAJE_INTERNET);
  }

  Future cerrarSession(Function response,
      {dynamic idPlataforma, dynamic imei, int all: 0}) async {
    var client = http.Client();
    try {
      final resp = await client.post(
          Uri.parse(Sistema.dominio + _urlCerrarSession),
          headers: utils.headers,
          body: {
            'idCliente': _prefs.idCliente,
            'auth': _prefs.auth,
            'idPlataforma': idPlataforma.toString(),
            'imei': imei.toString(),
            'all': all.toString(),
          });

      Map<String, dynamic> decodedResp = json.decode(resp.body);
      if (decodedResp['estado'] == 1) return response(1, decodedResp['error']);
      return response(0, decodedResp['error']);
    } catch (err) {
      print('cliente_provider error: $err');
    } finally {
      client.close();
    }
    return response(0, config.MENSAJE_INTERNET);
  }

  recuperarContrasenia(
      ClienteModel clienteModel, int tipo, Function response) async {
    var client = http.Client();
    try {
      final resp = await client.post(
          Uri.parse(Sistema.dominio + _recuperarContrasenia),
          headers: utils.headers,
          body: {
            'celular': clienteModel.celular.toString(),
            'correo': clienteModel.correo.toString(),
            'tipo': tipo.toString(),
          });
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      if (decodedResp['estado'] == 1) return response(1, decodedResp['error']);
      return response(0, decodedResp['error']);
    } catch (err) {
      print('cliente_provider error: $err');
    } finally {
      client.close();
    }
    return response(0, config.MENSAJE_INTERNET);
  }

  PreferenciasBloc preferenciasBloc = PreferenciasBloc();

  ver(Function response) async {
    var client = http.Client();
    NotificacionModel notificacionModel = NotificacionModel();
    int push = 0;
    try {
      final resp = await client.post(Uri.parse(Sistema.dominio + _urlVer),
          headers: utils.headers,
          body: {
            'idCliente': _prefs.idCliente,
            'auth': _prefs.auth,
            'perfil': _prefs.clienteModel.perfil.toString(),
            'dir': _prefs.clienteModel.direcciones.toString(),
          });
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      try {
        if (decodedResp.containsKey('nt'))
          notificacionModel = NotificacionModel.fromJson(decodedResp['nt']);
      } catch (e) {
        print(';)');
      }
      if (resp.statusCode == 403)
        return response(0, decodedResp['error'], push, notificacionModel);
      if (decodedResp['estado'] == 1) {
        ClienteModel clienteModel =
            ClienteModel.fromJson(decodedResp['cliente']);
        _prefs.clienteModel = clienteModel;
        push = Sistema.isIOS ? decodedResp['c']['p'] : 1;

        try {
          bool _config = false;
          for (var preferencia in decodedResp['c']['preferencias']) {
            if (preferencia['codigo'] == 'P0001') {
              preferenciasBloc.mensajes.clear();
              for (var mensaje in json.decode(preferencia['configuracion'])) {
                preferenciasBloc.mensajes
                    .add(MensajePreferenciaModel.fromJson(mensaje));
              }
            } else if (preferencia['codigo'] == 'P0002') {
              _config = true;
              _prefs.conf = preferencia['configuracion'];
            }
            //Preferencias de tarjeta
            else if (preferencia['codigo'] == 'T0002') {
              var response =
                  jsonDecode(preferencia['configuracion'].toString())[0];
              _prefs.estadoTc = response['e'];
              _prefs.mensajeTc = response['m'];
            }
          }
          if (!_config) _prefs.conf = 'null';
        } catch (err) {
          print('cliente_provider preferencias error: $err');
        }
      }

      try {
        Map<String, dynamic> decodedResp =
            (jsonDecode(_prefs.clienteModel.beta.toString()));
        if (decodedResp != null) {
          _prefs.testig = (decodedResp['testing'] == '1');
        }
      } catch (err) {
        print('Error menu $err');
      }

      return response(1, decodedResp['error'], push, notificacionModel);
    } catch (err) {
      print('cliente_provider error: $err');
    } finally {
      client.close();
    }
    return response(1, config.MENSAJE_INTERNET, push, notificacionModel);
  }

  autenticarClave(String codigoPais, String cliente, String clave,
      Function response) async {
    await utils.getDeviceDetails();
    var client = http.Client();
    try {
      final resp = await client.post(
          Uri.parse(Sistema.dominio + _urlAutenticarClave),
          headers: utils.headers,
          body: {
            'cliente': cliente,
            'clave': clave,
            'token': _prefs.token,
            'simCountryCode': _prefs.simCountryCode,
            'codigoPais': codigoPais,
          });
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      if (decodedResp['estado'] == 1) {
        _prefs.auth = decodedResp['auth'];
        ClienteModel clienteModel =
            ClienteModel.fromJson(decodedResp['cliente']);
        _prefs.idCliente = clienteModel.idCliente.toString();
        _prefs.clienteModel = clienteModel;
        return response(1, clienteModel);
      }
      return response(0, decodedResp['error']);
    } catch (err) {
      print('cliente_provider error: $err');
      //return response(0, 'Lo sentimos ocurrio un problema error: $err');
    } finally {
      client.close();
    }
    return response(0, config.MENSAJE_INTERNET);
  }

  Future<bool> autenticarApple(
      String codigoPais,
      String smn,
      String correo,
      String idApple,
      String nombres,
      String apellidos,
      Function response) async {
    await utils.getDeviceDetails();
    var client = http.Client();
    try {
      final resp = await client.post(
          Uri.parse(Sistema.dominio + _urlAutenticarApple),
          headers: utils.headers,
          body: {
            'nombres': nombres.toString(),
            'apellidos': apellidos.toString(),
            'correo': correo.toString(),
            'idApple': idApple.toString(),
            'token': _prefs.token,
            'simCountryCode': _prefs.simCountryCode,
            'codigoPais': codigoPais,
            'smn': smn.toString(),
          });
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      if (decodedResp['estado'] == 1) {
        _prefs.auth = decodedResp['auth'];
        ClienteModel clienteModel =
            ClienteModel.fromJson(decodedResp['cliente']);
        _prefs.idCliente = clienteModel.idCliente.toString();
        _prefs.clienteModel = clienteModel;
        response(1, clienteModel);
        return true;
      }
      response(0, decodedResp['error']);
      return false;
    } catch (err) {
      print('cliente_provider error: $err');
    } finally {
      client.close();
    }
    response(0, config.MENSAJE_INTERNET);
    return false;
  }

  autenticarGoogle(
      String codigoPais,
      String smn,
      String correo,
      String img,
      String idGoogle,
      String nombres,
      String apellidos,
      Function response) async {
    await utils.getDeviceDetails();
    var client = http.Client();
    try {
      final resp = await client.post(
          Uri.parse(Sistema.dominio + _urlAutenticarGoogle),
          headers: utils.headers,
          body: {
            'nombres': nombres.toString(),
            'apellidos': apellidos.toString(),
            'correo': correo.toString(),
            'img': img.toString(),
            'idGoogle': idGoogle.toString(),
            'token': _prefs.token,
            'simCountryCode': _prefs.simCountryCode,
            'codigoPais': codigoPais,
            'smn': smn.toString()
          });
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      if (decodedResp['estado'] == 1) {
        _prefs.auth = decodedResp['auth'];
        ClienteModel clienteModel =
            ClienteModel.fromJson(decodedResp['cliente']);
        _prefs.idCliente = clienteModel.idCliente.toString();
        _prefs.clienteModel = clienteModel;
        return response(1, clienteModel);
      }
      return response(0, decodedResp['error']);
    } catch (err) {
      print('cliente_provider error: $err');
    } finally {
      client.close();
    }
    return response(0, config.MENSAJE_INTERNET);
  }

  autenticarFacebook(
      String codigoPais,
      String smn,
      String correo,
      String idFacebook,
      String nombres,
      String apellidos,
      Function response) async {
    await utils.getDeviceDetails();
    var client = http.Client();
    try {
      final resp = await client.post(
          Uri.parse(Sistema.dominio + _urlAutenticarFacebook),
          headers: utils.headers,
          body: {
            'nombres': nombres.toString(),
            'apellidos': apellidos.toString(),
            'correo': correo.toString(),
            'idFacebook': idFacebook.toString(),
            'token': _prefs.token,
            'simCountryCode': _prefs.simCountryCode,
            'codigoPais': codigoPais,
            'smn': smn.toString(),
          });
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      if (decodedResp['estado'] == 1) {
        _prefs.auth = decodedResp['auth'];
        ClienteModel clienteModel =
            ClienteModel.fromJson(decodedResp['cliente']);
        _prefs.idCliente = clienteModel.idCliente.toString();
        _prefs.clienteModel = clienteModel;
        return response(1, clienteModel);
      }
      return response(0, decodedResp['error']);
    } catch (err) {
      print('cliente_provider error: $err');
    } finally {
      client.close();
    }
    return response(0, config.MENSAJE_INTERNET);
  }

  Future<bool> actualizarToken() async {
    if (_prefs.idCliente == '') return false;
    if (_prefs.token == '') {
      await PushProvider().obtenerToken();
      return false;
    }
    try {
      final resp = await http.post(
          Uri.parse(Sistema.dominio + _urlActualizarToken),
          headers: utils.headers,
          body: {
            'idCliente': _prefs.idCliente,
            'auth': _prefs.auth,
            'token': _prefs.token
          });
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      if (decodedResp['estado'] == 1) return true;
    } catch (err) {
      print('cliente_provider error: $err');
    }
    return false;
  }
}
