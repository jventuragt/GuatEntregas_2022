import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl_phone_number_input/src/providers/country_provider.dart'
    show CountryProvider;
import 'package:modal_progress_hud/modal_progress_hud.dart';

import '../../card/shimmer_card.dart';
import '../../model/session_model.dart';
import '../../preference/shared_preferences.dart';
import '../../providers/cliente_provider.dart';
import '../../utils/button.dart' as btn;
import '../../utils/dialog.dart' as dlg;
import '../../utils/permisos.dart' as permisos;
import '../../utils/personalizacion.dart' as prs;
import '../../utils/utils.dart' as utils;

class SessionesPage extends StatefulWidget {
  @override
  _SessionesPageState createState() => _SessionesPageState();
}

class _SessionesPageState extends State<SessionesPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final PreferenciasUsuario prefs = PreferenciasUsuario();
  final _clienteProvider = ClienteProvider();

  bool _saving = false;

  @override
  void initState() {
    _cargarPaises();

    super.initState();
  }

  List listCountries;

  _cargarPaises() async {
    listCountries = CountryProvider.getCountriesData(countries: listCountries);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Donde iniciaste sesión'),
        leading: utils.leading(context),
      ),
      key: scaffoldKey,
      body: ModalProgressHUD(
        color: Colors.black,
        opacity: 0.4,
        progressIndicator: utils.progressIndicator('Cerrando sesión...'),
        inAsyncCall: _saving,
        child: Center(
            child: Container(child: _body(), width: prs.anchoFormulario)),
      ),
    );
  }

  Widget _body() {
    return Column(
      children: <Widget>[
        SizedBox(height: 20.0),
        Expanded(child: _listaCar(context)),
        btn.booton('CERRAR TODAS LAS SESIONES', _cerrarTotas),
      ],
    );
  }

  _cerrarTotas() {
    _enviarCancelar() async {
      Navigator.of(context).pop();
      _saving = true;
      if (mounted) setState(() {});
      await _clienteProvider.cerrarSession((estado, error) {}, all: 1);
      _saving = false;
      if (mounted) setState(() {});
    }

    dlg.mostrar(context,
        '¿Seguro deseas cerrar todas las sesiones?\n\n No se cerrara la sesión actual.',
        icon: FontAwesomeIcons.signOutAlt,
        fBotonIDerecha: _enviarCancelar,
        mBotonDerecha: 'CERRAR TODAS',
        mIzquierda: 'CANCELAR');
  }

  Widget _listaCar(context) {
    return Container(
      child: FutureBuilder(
        future: _clienteProvider.listarSessiones(),
        builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.length > 0)
              return createListView(context, snapshot);
            return Container(
              margin: EdgeInsets.all(80.0),
              width: double.infinity,
              height: double.infinity,
              child: Center(
                child: Image(
                  image: AssetImage('assets/session.png'),
                  fit: BoxFit.cover,
                ),
              ),
            );
          } else {
            return ShimmerCard();
          }
        },
      ),
    );
  }

  Future _onRefresh() async {
    await _clienteProvider.listarSessiones();
    if (mounted) setState(() {});
    return;
  }

  Widget createListView(BuildContext context, AsyncSnapshot snapshot) {
    return RefreshIndicator(
      onRefresh: () => _onRefresh(),
      child: ListView.builder(
        itemCount: snapshot.data.length,
        itemBuilder: (BuildContext context, int index) {
          return _card(context, snapshot.data[index]);
        },
      ),
    );
  }

  Widget _card(BuildContext context, SessionModel sessionModel) {
    var countrie = listCountries.firstWhere(
        (countrie) => countrie.alpha2Code.toString() == sessionModel.pais,
        orElse: () => null);
    var pais = sessionModel.pais;
    if (countrie != null) pais = countrie.name;

    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: Column(
        children: <Widget>[
          ListTile(
            leading: Icon(FontAwesomeIcons.mobileAlt,
                size: 40.0, color: prs.colorIcons),
            trailing: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(FontAwesomeIcons.doorOpen, color: prs.colorIcons),
                (sessionModel.actual == 1)
                    ? Text('  Actual',
                        style: TextStyle(fontSize: 11.0, color: Colors.black))
                    : Text('')
              ],
            ),
            title: Text(sessionModel.marca.toString()),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 6.0),
                Container(
                  margin: EdgeInsets.only(left: 14.0),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Icon(
                            FontAwesomeIcons.globeAmericas,
                            size: 10.0,
                            color: Colors.black54,
                          ),
                          SizedBox(width: 8.0),
                          Text('${sessionModel.ciudad.toString()}, $pais'),
                        ],
                      ),
                      SizedBox(height: 3.0),
                      Row(
                        children: <Widget>[
                          Icon(
                            FontAwesomeIcons.doorOpen,
                            size: 9.0,
                            color: Colors.black54,
                          ),
                          SizedBox(width: 8.0),
                          Text(
                            '${sessionModel.fechaInicio.toString()}  ',
                            style: TextStyle(fontSize: 10.0),
                          ),
                        ],
                      ),
                      SizedBox(height: 3.0),
                      Row(
                        children: <Widget>[
                          Icon(
                            FontAwesomeIcons.sync,
                            size: 9.0,
                            color: Colors.black54,
                          ),
                          SizedBox(width: 8.0),
                          Text(
                            '${sessionModel.fechaActualizo.toString()}  ',
                            style: TextStyle(fontSize: 10.0),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(),
        ],
      ),
      actions: <Widget>[],
      secondaryActions: <Widget>[
        IconSlideAction(
          color: Colors.red,
          caption: 'Cerrar sesión',
          icon: FontAwesomeIcons.signOutAlt,
          onTap: () async {
            _enviarCerrarSession() async {
              Navigator.of(context).pop();
              _saving = true;
              if (mounted) setState(() {});
              await _clienteProvider.cerrarSession((estado, error) {
                if (sessionModel.actual == 1) {
                  if (estado == 1) {
                    permisos.cerrasSesion(context);
                  }
                }
              },
                  idPlataforma: sessionModel.idPlataforma,
                  imei: sessionModel.imei,
                  all: 0);
              _saving = false;
              if (mounted) setState(() {});
            }

            dlg.mostrar(context,
                '¿Seguro deseas cerrar sesión en ${sessionModel.marca}?',
                icon: FontAwesomeIcons.signOutAlt,
                fBotonIDerecha: _enviarCerrarSession,
                mBotonDerecha: 'CERRAR SESIÓN',
                mIzquierda: 'CANCELAR');
          },
        ),
      ],
    );
  }
}
