import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:location_permissions/location_permissions.dart';

import '../model/cliente_model.dart';
import '../model/notificacion_model.dart';
import '../preference/shared_preferences.dart';
import '../providers/cliente_provider.dart';
import '../sistema.dart';
import '../utils/cache.dart' as cache;
import '../utils/dialog.dart' as dlg;
import '../utils/personalizacion.dart' as prs;
import '../utils/rastreo.dart';
import '../utils/utils.dart';
import '../utils/utils.dart' as utils;
import 'conexion.dart';

final PreferenciasUsuario _prefs = PreferenciasUsuario();
final ClienteProvider _clienteProvider = ClienteProvider();

Future<ClienteModel> ingresar() async {
  _prefs.idCliente = Sistema.ID_CLIENTE;
  _prefs.auth = Sistema.AUTH_CLIENTE;
  await utils.getDeviceDetails(uuid: Sistema.idUuid);
  ClienteModel clienteModel = ClienteModel();
  clienteModel.img =
      'https://image.freepik.com/vector-gratis/asociacion-afiliados-ganar-dinero-estrategia-mercadeo_115790-146.jpg';
  clienteModel.idCliente = _prefs.idCliente;
  clienteModel.correo = 'explorar@${Sistema.aplicativoTitle.toLowerCase()}.com';
  clienteModel.nombres = 'Invitado ${Sistema.aplicativoTitle}';
  clienteModel.direcciones = 1;
  clienteModel.idUrbe = Sistema.ID_URBE;
  clienteModel.perfil = 0;
  _prefs.clienteModel = clienteModel;
  return clienteModel;
}

cerrasSesion(BuildContext context) {
  Rastreo().stop();
  Conexion().desconectar();
  _prefs.idCliente = '';
  _prefs.auth = '';
  _prefs.sms = '';
  _prefs.empezamos = false;
  _prefs.rastrear = false;
  return Navigator.of(context)
      .pushNamedAndRemoveUntil('principal', (Route<dynamic> route) => false);
}

mostrarNoti(BuildContext context, NotificacionModel notificacion) {
  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          insetPadding:
              EdgeInsets.only(left: 20.0, right: 20.0, top: 70.0, bottom: 40.0),
          contentPadding: EdgeInsets.all(0.0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          title: Text(notificacion.hint,
              overflow: TextOverflow.fade, textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(height: 10.0),
              cache.fadeImage(notificacion.img, days: 1),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text(notificacion.omitir),
              onPressed: () {
                _clienteProvider.mensaje(notificacion.idMensaje, 0);
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  primary: prs.colorButtonSecondary,
                  elevation: 2.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0))),
              label: Text(notificacion.boton),
              icon: Icon(FontAwesomeIcons.handPointUp),
              onPressed: () {
                _clienteProvider.mensaje(notificacion.idMensaje, 1);
                notificacion.accion(context);
              },
            ),
          ],
        );
      });
}

verificarSession(BuildContext context) async {
  if (_prefs.isExplorar) return;
  _clienteProvider.ver((estado, error, push, NotificacionModel notificacion) {
    if (notificacion.idMensaje != '0') {
      return mostrarNoti(context, notificacion);
    }
    if (estado == 1) {
      if (push == 1) getCheckNotificationPermStatus(context);
      return;
    } else {
      cerrasSesion(context);
    }
  });
}

var permGranted = "granted";
var permDenied = "denied";
var permUnknown = "unknown";

String getCheckNotificationPermStatus(BuildContext context) {
  return permGranted;
}

_mostrarConfirmarion(BuildContext context, confirmacion) async {
  if (Sistema.isIOS || !Sistema.IS_BACKGROUND) return confirmacion();
  dlg.mostrar(context,
      'Esta aplicación recopila datos de ubicación para habilitar el módulo de recepción de pedidos incluso cuando la aplicación está cerrada o no está en uso.\n\nSolo si te conviertes en motorizado podrás activar el módulo de recepción de pedidos.',
      fIzquierda: () {
    Navigator.of(context).pop();
    return confirmacion();
  });
}

localizarTo(BuildContext context, Function response,
    {bool isRadar: true, bool isForce: true}) async {
  PermissionStatus status = await LocationPermissions().checkPermissionStatus();
  if (status == PermissionStatus.granted) {
    if (isRadar) mostrarRadar(context, barrierDismissible: false);
    List<double> pos = await Rastreo().localizar();
    if (isRadar) Navigator.of(context).pop();
    return await response(pos[0], pos[1]); //Gps activado
  } else {
    _mostrarConfirmarion(context, () async {
      PermissionStatus permissionStatus =
          await LocationPermissions().requestPermissions();
      switch (permissionStatus) {
        case PermissionStatus.granted:
          ServiceStatus status =
              await LocationPermissions().checkServiceStatus();
          if (status == ServiceStatus.enabled) {
            if (isRadar) mostrarRadar(context, barrierDismissible: false);
            List<double> pos = await Rastreo().localizar();
            if (isRadar) Navigator.of(context).pop();
            return await response(pos[0], pos[1]); //Gps activado
          }
          Rastreo().activarGps(); //Debe ponerce un escucha en la pantalla.
          return response(Sistema.lt, Sistema.lg); //Gps desactivado
        default:
          if (!isForce)
            return response(Sistema.lt, Sistema.lg); //Gps desactivado
          _forzarPermisoGps(context);
          return response(2.2, 2.2); // Se muestra diagol de GPS;
      }
    });
  }
}

toRutaPageCheckLocationPermStatus(BuildContext context,
    {bool principal: false}) async {
//  PermissionStatus permission =
//      await LocationPermissions().requestPermissions();
//  if (permission.index != 2) {
//    permission = await LocationPermissions().requestPermissions();
//  }
//  if (permission.index == 2) {
//    final isGpsActivo = await gps.Location().serviceEnabled();
//    if (!isGpsActivo) {
//      gps.Location().requestService().then((isActive) {
//        if (isActive)
//          return toRutaPageCheckLocationPermStatus(context,
//              principal: principal);
//        return dlg.mostrar(context, 'Activa el GPS por favor!',
//            mensajeRegresar: 'ACEPTAR');
//      });
//      return;
//    }
//    mostrarRadar(context, barrierDismissible: false);
//    var position = await gps.Location()
//        .getLocation()
//        .timeout(Duration(seconds: 10))
//        .catchError((error) {})
//        .whenComplete(() {});
//    double lt = Sistema.lt, lg = Sistema.lg;
//    if (position != null) {
//      lt = position.latitude;
//      lg = position.longitude;
//    }
//    Navigator.of(context).pop();
//    Navigator.push(
//      context,
//      MaterialPageRoute(
//        builder: (context) => RutaPage(rutaModel: RutaModel(), lt: lt, lg: lg),
//      ),
//    );
//  } else {
//    _forzarPermisoGps(context);
//  }
}

void _forzarPermisoGps(BuildContext context) {
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[Text('Alerta')],
          ),
          content: Container(
              child: Text('Para continuar se debe dar permiso de GPS')),
          actions: <Widget>[
            TextButton(
                child: Text('CANCELAR'),
                onPressed: () => Navigator.of(context).pop()),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  primary: prs.colorButtonSecondary,
                  elevation: 2.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0))),
              label: Text('CONFIGURAR'),
              icon: Icon(Icons.settings),
              onPressed: () {
                Navigator.of(context).pop();
                LocationPermissions().openAppSettings();
              },
            ),
          ],
        );
      });
}

localizar(context, moverCamaraMapa) async {
  await localizarTo(context, (lt, lg) {
    if (lt == 2.2) return false;
    if (lt == Sistema.lt && lg == Sistema.lg) return false; //
    moverCamaraMapa(lt, lg);
    return true;
  });
}
