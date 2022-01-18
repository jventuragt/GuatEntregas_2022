import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../pages/paymentez/cards_page.dart';
import '../preference/shared_preferences.dart';
import '../providers/cliente_provider.dart';
import '../sistema.dart';
import '../utils/cache.dart' as cache;
import '../utils/personalizacion.dart' as prs;
import '../utils/utils.dart' as utils;

class MenuWidget extends StatefulWidget {
  @override
  _MenuWidgetState createState() => _MenuWidgetState();
}

class _MenuWidgetState extends State<MenuWidget> {
  final PreferenciasUsuario _prefs = PreferenciasUsuario();

  final ClienteProvider _clienteProvider = ClienteProvider();

  bool _isVentas = false;
  bool _isAgeneciasRegistro = false;

  @override
  void initState() {
    try {
      Map<String, dynamic> decodedResp =
          (jsonDecode(_prefs.clienteModel.beta.toString()));
      if (decodedResp != null) {
        _isVentas = (decodedResp['v'] == '1');
      }
    } catch (err) {
      print('Error menu $err');
    }
    try {
      Map<String, dynamic> decodedResp =
          (jsonDecode(_prefs.clienteModel.beta.toString()));
      if (decodedResp != null) {
        _isAgeneciasRegistro = (decodedResp['ar'] == '1');
      }
    } catch (err) {
      print('Error menu $err');
    }
    if (mounted) setState(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    _encabezado(context),
                    Divider(),
                    Container(
                      padding: EdgeInsets.only(left: 15.0),
                      child: ListTile(
                          dense: true,
                          leading: prs.iconoNotificacion,
                          title: Text('Notificaciones'),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, 'notificacion');
                          }),
                    ),
                    _elementos(),
                    Container(
                      padding: EdgeInsets.only(left: 15.0),
                      child: ListTile(
                          dense: true,
                          leading: prs.iconoPuntos,
                          title: Text('Insignia & Money | Cash'),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, 'puntos');
                          }),
                    ),
                  ],
                ),
              ),
            ),
            _pie(),
          ],
        ),
      ),
    );
  }

  Widget _pie() {
    return Column(
      children: [
        Visibility(
          visible: !_prefs.isExplorar,
          child: ListTile(
              dense: true,
              leading: prs.iconoContactanos,
              title: Text('Contactanos'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, 'contacto');
              }),
        ),
        Visibility(
          visible: !_prefs.isExplorar &&
              Sistema.idAplicativo == Sistema.idAplicativoCuriosity,
          child: ListTile(
              dense: true,
              leading: prs.iconoVentas,
              title: Text('Aumenta tus ventas'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, 'preregistro');
              }),
        ),
        ListTile(
          dense: true,
          leading: prs.iconoAbout,
          title: Text('Nuestra Web'),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, 'about');
          },
        ),
        Divider(),
        SizedBox(height: 4),
        Text('V: ${utils.headers['vs']} Powered by GuatEntregas',
            textScaleFactor: 0.8),
        SizedBox(height: 10),
      ],
    );
  }

  Widget _elementos() {
    switch (_prefs.clienteModel.perfil) {
      case '1':
        return _elementosCajero(context);
      case '2':
        return _elementosDespachador(context);
      default:
        return _elementosCliente(context);
    }
  }

  Widget _encabezado(BuildContext context) {
    Container tarjeta = Container(
      margin: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 10),
          CircularPercentIndicator(
            radius: 70.0,
            lineWidth: 3.0,
            animation: true,
            percent: _prefs.clienteModel.registros > 0
                ? (_prefs.clienteModel.correctos /
                    _prefs.clienteModel.registros)
                : 1.0,
            center: ClipRRect(
              borderRadius: BorderRadius.circular(100.0),
              child: cache.fadeImage(_prefs.clienteModel.img,
                  width: 60, height: 60),
            ),
            circularStrokeCap: CircularStrokeCap.round,
            progressColor: prs.colorButtonSecondary,
          ),
          SizedBox(width: 10.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                  width: 175.0,
                  child: Text(_prefs.clienteModel.nombres,
                      textScaleFactor: 1.4, overflow: TextOverflow.fade)),
              Container(
                  width: 175.0,
                  child: Text(_prefs.clienteModel.correo,
                      textScaleFactor: 0.9,
                      softWrap: false,
                      overflow: TextOverflow.fade,
                      style: TextStyle(color: Colors.indigo))),
            ],
          )
        ],
      ),
    );

    return Stack(
      children: <Widget>[
        tarjeta,
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              splashColor: Colors.blueAccent.withOpacity(0.6),
              onTap: () {
                utils.mostrarProgress(context);
                _clienteProvider.ver((estado, error, push, notificacionModel) {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.pushNamed(context, 'perfil');
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Container _elementosCliente(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 15.0),
      child: Column(
        children: <Widget>[
          ListTile(
              dense: true,
              leading: prs.iconoCompras,
              title: Text('Mi historial'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, 'compras_cliente');
              }),
          Visibility(
            visible: !_prefs.isExplorar,
            child: ListTile(
                dense: true,
                leading: prs.iconoMenuMetodoPago,
                title: Text('Métodos de pago & Gift'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CardsPage(isMenu: true)));
                }),
          ),
          ListTile(
              dense: true,
              leading: prs.iconoDirecciones,
              title: Text('Mis direcciones'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, 'direcciones_cliente');
              }),
          Visibility(
            visible: !_prefs.isExplorar,
            child: ListTile(
                dense: true,
                leading: prs.iconoFactura,
                title: Text('Datos de facturas'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, 'facturas_cliente');
                }),
          ),
        ],
      ),
    );
  }

  Container _elementosCajero(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 12.0),
      child: Column(
        children: <Widget>[
          ListTile(
              dense: true,
              leading: prs.iconoSucursal,
              title: Text('Administración'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, 'sucursales');
              }),
          Visibility(
            visible: _isAgeneciasRegistro,
            child: ListTile(
                dense: true,
                leading: prs.iconoVentas,
                title: Text('Pre registros'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, 'agencia');
                }),
          ),
          Visibility(
            visible: _isVentas,
            child: ListTile(
                dense: true,
                leading: prs.iconoPaquetes,
                title: Text('Ventas'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, 'ventas');
                }),
          ),
          ListTile(
              dense: true,
              leading: prs.iconoCompras,
              title: Text('Solicitar'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, 'catalogo');
              }),
          ListTile(
              dense: true,
              leading: prs.iconoFactura,
              title: Text('Datos de facturas'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, 'facturas_cliente');
              }),
          ListTile(
              dense: true,
              leading: prs.iconoDirecciones,
              title: Text('Mis direcciones'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, 'direcciones_cliente');
              }),
        ],
      ),
    );
  }

  Container _elementosDespachador(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 12.0),
      child: Column(
        children: <Widget>[
          ListTile(
              dense: true,
              leading: prs.iconoCompras,
              title: Text('Solicitar'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, 'catalogo');
              }),
          ListTile(
              dense: true,
              leading: prs.iconoFactura,
              title: Text('Datos de facturas'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, 'facturas_cliente');
              })
        ],
      ),
    );
  }
}
