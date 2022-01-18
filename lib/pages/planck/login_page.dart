import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart';

import '../../model/cliente_model.dart';
import '../../preference/shared_preferences.dart';
import '../../providers/cliente_provider.dart';
import '../../sistema.dart';
import '../../utils/button.dart' as btn;
import '../../utils/personalizacion.dart' as prs;
import '../../utils/redes_sociales.dart' as rs;
import '../../utils/utils.dart' as utils;

class LoginPage extends StatefulWidget {
  final TabController tabController;

  LoginPage(this.tabController, {Key key}) : super(key: key);

  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ClienteProvider _clienteProvider = ClienteProvider();
  final prefs = PreferenciasUsuario();
  String smn = '';

  final Future<bool> _isAvailableFuture = TheAppleSignIn.isAvailable();

  ClienteModel cliente = ClienteModel();
  bool _saving = false;

  GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  void initState() {
    super.initState();
    _escucharLoginGoogle();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        body: ModalProgressHUD(
          inAsyncCall: _saving,
          child: SingleChildScrollView(
            child: Center(
                child:
                    Container(child: _contenido(), width: prs.anchoFormulario)),
          ),
        ));
  }

  Column _contenido() {
    return Column(
      children: <Widget>[
        SizedBox(height: 5.0),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 90.0),
          child: Column(
            children: <Widget>[
              Container(
                  child: Image(
                      image: AssetImage('assets/icon_.png'), width: 215.0)),
              SizedBox(height: 40.0),
              Row(
                children: [
                  Container(
                    width: 150.0,
                    child: TextButton(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text('Login',
                              style: TextStyle(
                                  color: prs.colorLinearProgress,
                                  fontSize: 20.0)),
                          Divider(
                              color: prs.colorLinearProgress, thickness: 3.0)
                        ],
                      ),
                      onPressed: () {},
                    ),
                  ),
                  Container(
                    width: 150.0,
                    child: TextButton(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text('Registrarse',
                              style: TextStyle(
                                  color: prs.colorTextTitle, fontSize: 20.0)),
                          SizedBox(height: 20.0),
                        ],
                      ),
                      onPressed: () {
                        widget.tabController.animateTo(1,
                            duration: Duration(seconds: 3),
                            curve: Curves.elasticInOut);
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.0),
              Center(
                child: Text('Bienvenido',
                    style: TextStyle(
                        color: prs.colorTextTitle,
                        fontSize: 24,
                        fontWeight: FontWeight.bold)),
              ),
              SizedBox(height: 20.0),
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    _crearCelular(),
                    SizedBox(height: 10.0),
                    _crearPassword(),
                    SizedBox(height: 10.0),
                  ],
                ),
              ),
              SizedBox(height: 10.0),
              btn.booton('INICIAR SESIÓN', _autenticarClave),
              SizedBox(height: 10.0),
              TextButton(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text('¿Olvidaste tu contraseña? ',
                        textAlign: TextAlign.center),
                    Text('¡Recuperar!', style: TextStyle(color: Colors.indigo)),
                  ],
                ),
                onPressed: () => Navigator.pushNamed(context, 'contrasenia'),
              ),
              SizedBox(height: 10.0),
              Center(child: Text('- O -')),
              SizedBox(height: 20.0),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FutureBuilder<bool>(
                    future: _isAvailableFuture,
                    builder: (context, isAvailableSnapshot) {
                      if (!isAvailableSnapshot.hasData) {
                        return Container(
                          width: 0.0,
                        );
                      }
                      return isAvailableSnapshot.data
                          ? rs.buttonApple('Continuar con Apple',
                              prs.iconoApple, _autenticarApple)
                          : Container(
                              width: 0.0,
                            );
                    },
                  ),
                  rs.buttonFacebook('Continuar con Facebook', prs.iconoFacebook,
                      _autenticarFacebook),
                  rs.buttonGoogle('Continuar con Google', prs.iconoGoogle,
                      _iniciarSessionGoogle),
                ],
              ),
              SizedBox(height: 20.0),
              Visibility(
                // visible: Sistema.isIOS,
                child: TextButton(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text('¡EXPLORAR ${Sistema.aplicativo}!',
                          style: TextStyle(color: Colors.indigo)),
                    ],
                  ),
                  onPressed: () async {
                    _saving = true;
                    if (mounted) setState(() {});
                    await rs.autlogin(context);
                    _saving = false;
                    if (mounted) setState(() {});
                  },
                ),
              ),
              SizedBox(height: 20.0),
            ],
          ),
        ),
      ],
    );
  }

  bool isCelularValido = true;
  String codigoPais = '+593';

  _onChangedCelular(phone) {
    cliente.celular = phone;
  }

  Widget _crearCelular() {
    return Row(
      children: [
        SizedBox(width: 5.0),
        Expanded(
          child: utils.crearCelular(prefs.simCountryCode, _onChangedCelular),
        )
      ],
    );
  }

  Widget _crearPassword() {
    return TextFormField(
        obscureText: true,
        maxLength: 12,
        decoration: prs.decoration('Contraseña', null),
        onSaved: (value) => cliente.clave = value,
        validator: (value) {
          if (value.trim().length < 4) return 'Mínimo 4 caracteres';
          return null;
        });
  }

  _autenticarClave() {
    FocusScope.of(context).requestFocus(FocusNode());
    _saving = true;
    if (mounted) setState(() {});
    if (cliente.celular.toString().length <= 8 ||
        cliente.clave.toString().length <= 3) {
      _formKey.currentState.validate();
      _saving = false;
      if (mounted) setState(() {});
      return;
    }
    if (!isCelularValido) {
      _saving = false;
      if (mounted) setState(() {});
      return;
    }
    _formKey.currentState.save();
    _clienteProvider.autenticarClave(codigoPais, cliente.celular.toString(),
        utils.generateMd5(cliente.clave), (estado, clienteModel) {
      _saving = false;
      if (mounted) if (mounted) setState(() {});
      if (estado == 0) return _mostrarSnackBar(clienteModel);
      rs.ingresar(context, clienteModel);
    });
  }

  void _autenticarFacebook() async {
    _saving = true;
    if (mounted) setState(() {});
    await rs.autenticarFacebook(context, codigoPais, smn, (login) {
      _saving = false;
      if (mounted) if (mounted) setState(() {});
    });
  }

  void _autenticarApple() async {
    _saving = true;
    if (mounted) setState(() {});
    bool respuesta = await rs.autenticarApple(context, codigoPais, smn);
    _saving = false;
    if (mounted) if (mounted) setState(() {});
    if (!respuesta)
      _mostrarSnackBar('Necesitamos información del correo electrónico.');
  }

  void _autenticarGoogle(
      context, correo, img, idGoogle, nombres, apellidos) async {
    _saving = true;
    if (mounted) setState(() {});
    await rs.autenticarGoogle(context, _googleSignIn, codigoPais, smn, correo,
        img, idGoogle, nombres, apellidos);
    _saving = false;
    if (mounted) if (mounted) setState(() {});
  }

  Future<void> _iniciarSessionGoogle() async {
    _saving = true;
    if (mounted) setState(() {});
    try {
      await _googleSignIn.signIn();
    } catch (err) {
      print('login_page error: $err');
    } finally {
      _saving = false;
      if (mounted) if (mounted) setState(() {});
    }
  }

  _escucharLoginGoogle() {
    _googleSignIn.onCurrentUserChanged
        .listen((GoogleSignInAccount currentUser) {
      if (currentUser != null) {
        var nombres = currentUser.displayName.split(' ');
        String nombre = '';
        if (nombres.length > 0) {
          nombre = nombres[0];
        }
        String apellido = '';
        if (nombres.length > 1) {
          for (var i = 1; i < nombres.length; i++) {
            apellido += nombres[i] + ' ';
          }
        }
        _autenticarGoogle(context, currentUser.email, currentUser.photoUrl,
            currentUser.id, nombre, apellido);
      }
    });
  }

  void _mostrarSnackBar(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(mensaje),
      action: SnackBarAction(
        label: 'Recuperar cuenta',
        onPressed: () => Navigator.pushNamed(context, 'contrasenia'),
      ),
    ));
  }
}
