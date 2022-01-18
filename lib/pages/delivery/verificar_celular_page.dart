import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:pin_input_text_field/pin_input_text_field.dart';
import 'package:timer_builder/timer_builder.dart';

import '../../model/cliente_model.dart';
import '../../preference/shared_preferences.dart';
import '../../providers/cliente_provider.dart';
import '../../utils/button.dart' as btn;
import '../../utils/dialog.dart' as dlg;
import '../../utils/utils.dart' as utils;

class VerificarCelularPage extends StatefulWidget {
  final Function accionConfirmacion;

  VerificarCelularPage(this.accionConfirmacion, {Key key}) : super(key: key);

  @override
  State<VerificarCelularPage> createState() =>
      _VerificarCelularPageState(this.accionConfirmacion);
}

class _VerificarCelularPageState extends State<VerificarCelularPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ClienteProvider _clienteProvider = ClienteProvider();

  ClienteModel cliente = ClienteModel();
  bool isCelularValido = true;
  final TextEditingController _typeControllerCode = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _solicitarCodigo;
  final prefs = PreferenciasUsuario();
  Function accionConfirmacion;

  _VerificarCelularPageState(this.accionConfirmacion);

  bool _saving = false;

  @override
  void initState() {
    _solicitarCodigo = prefs.sms == '';
    cliente = prefs.clienteModel;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Verificar celular'),
        ),
        key: _scaffoldKey,
        body: ModalProgressHUD(
          color: Colors.black,
          opacity: 0.4,
          progressIndicator: utils.progressIndicator('Verificando'),
          inAsyncCall: _saving,
          child: SingleChildScrollView(
            child: _contenido(),
          ),
        ),
      ),
    );
  }

  Widget _numero() {
    return Column(
      children: <Widget>[
        Form(
          key: _formKey,
          child: utils.crearCelular(prefs.simCountryCode, _onChangedCelular,
              celular: cliente.celular),
        ),
        btn.confirmar('VERIFICAR NÚMERO DE CELULAR', _validarVerificarCelular),
        SizedBox(height: 20.0),
        Text(
          'Si el número que proporcionaste es incorrecto corrígelo antes de solicitar la verificación. Ten en cuenta que eres responsable de proporcionar información que te pertenezca y sea verídica.',
          style: TextStyle(fontSize: 14),
          textAlign: TextAlign.justify,
        ),
      ],
    );
  }

  String formatDuration(Duration d) {
    String f(int n) {
      return n.toString().padLeft(2, '0');
    }

    d += Duration(microseconds: 999999);
    return "Solicita un nuevo código en: ${f(d.inMinutes)}:${f(d.inSeconds % 60)}";
  }

  static const int _seconds = 35;

  Widget _timer() {
    DateTime alert =
        DateTime.parse(prefs.fechaCodigo).add(Duration(seconds: _seconds));

    return TimerBuilder.scheduled([alert], builder: (context) {
      var now = DateTime.now();
      bool _inicioTimer = now.compareTo(alert) >= 0;
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            !_inicioTimer
                ? TimerBuilder.periodic(Duration(seconds: 1),
                    alignment: Duration.zero, builder: (context) {
                    // This function will be called every second until the alert time
                    var now = DateTime.now();
                    var remaining = alert.difference(now);
                    return Text(
                      formatDuration(remaining),
                      style: TextStyle(fontSize: 17.0),
                    );
                  })
                : Column(
                    children: <Widget>[
                      TextButton(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text('¿No llega el código? '),
                            Text('¡Soliciar uno nuevo!',
                                style: TextStyle(color: Colors.indigo)),
                          ],
                        ),
                        onPressed: () {
                          _solicitarCodigo = !_solicitarCodigo;
                          if (mounted) setState(() {});
                        },
                      ),
                      SizedBox(height: 10.0),
                      Visibility(
                        visible: prefs.solicitados >= 1,
                        child: TextButton(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text('¿Aún no recibes el código? '),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text('Te llamaremos ',
                                      style: TextStyle(color: Colors.indigo)),
                                  Icon(Icons.phone_in_talk,
                                      color: Colors.indigo),
                                  Text(' ¡Confirmar!',
                                      style: TextStyle(color: Colors.indigo)),
                                ],
                              )
                            ],
                          ),
                          onPressed: () {
                            prefs.solicitados = 0;
                            prefs.sms = '';
                            accionConfirmacion();
                          },
                        ),
                      )
                    ],
                  )
          ],
        ),
      );
    });
  }

  Widget _verificar() {
    return Column(
      children: <Widget>[
        Text('Código enviado a: ${cliente.celular}',
            style: TextStyle(fontSize: 18)),
        SizedBox(height: 10.0),
        PinInputTextField(
          controller: _typeControllerCode,
          pinLength: 6,
          textInputAction: TextInputAction.go,
          onSubmit: (pin) {
            _signInWithPhoneNumber();
          },
        ),
        SizedBox(height: 10.0),
        btn.confirmar('VERIFICAR', _signInWithPhoneNumber),
        SizedBox(height: 20.0),
        _timer(),
        SizedBox(height: 10.0),
      ],
    );
  }

  Column _contenido() {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              SizedBox(height: 30.0),
              Visibility(
                visible: _solicitarCodigo,
                child: _numero(),
              ),
              SizedBox(height: 20.0),
              Visibility(
                visible: !_solicitarCodigo,
                child: _verificar(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _verifyPhoneNumber() async {
    final User currentUser = _auth.currentUser;

    if (currentUser?.phoneNumber == cliente.celular.toString()) {
      print('verificationCompleted for current');
      _clienteProvider.validadCelular(cliente.celular);
      prefs.solicitados = 0;
      accionConfirmacion();
      return;
    }

    final PhoneVerificationCompleted verificationCompleted =
        (AuthCredential phoneAuthCredential) {
      print('verificationCompleted');
      _auth.signInWithCredential(phoneAuthCredential);
      _clienteProvider.validadCelular(cliente.celular);
      prefs.solicitados = 0;
      accionConfirmacion();
    };

    final PhoneVerificationFailed verificationFailed = (authException) {
      _saving = false;
      if (mounted) setState(() {});
      print('verificationFailed');
      print(authException.message);
      String mensaje =
          'Hemos bloqueado todas las solicitudes de este dispositivo debido a una actividad inusual. Intentá nuevamente más tarde.';
      dlg.mostrar(context, mensaje, mIzquierda: 'ACEPTAR');
    };

    final PhoneCodeSent codeSent =
        (String verificationId, [int forceResendingToken]) async {
      print('codeSent');
      print(forceResendingToken);
      print(verificationId);
      prefs.solicitados++;
      prefs.sms = verificationId;
      _solicitarCodigo = false;
      _saving = false;
      if (mounted) setState(() {});
    };

    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      print('codeAutoRetrievalTimeout');
      _solicitarCodigo = true;
      _solicitarCodigo = false;
      _saving = false;
      if (mounted) if (mounted) setState(() {});
      prefs.sms = verificationId;
    };

    await _auth.verifyPhoneNumber(
        phoneNumber: cliente.celular.toString(),
        timeout: const Duration(seconds: _seconds),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
  }

  void _signInWithPhoneNumber() async {
    if (_typeControllerCode.text.length < 6) return;
    print('_signInWithPhoneNumber');
    FocusScope.of(context).requestFocus(FocusNode());
    _saving = true;
    if (mounted) setState(() {});
    final AuthCredential credential = PhoneAuthProvider.credential(
      verificationId: prefs.sms,
      smsCode: _typeControllerCode.text,
    );
    await _auth.signInWithCredential(credential).then((user) {
      _saving = false;
      _clienteProvider.validadCelular(cliente.celular);
      prefs.solicitados = 0;
      accionConfirmacion();
    }).catchError((error) {
      _typeControllerCode.text = '';
      _saving = false;
      if (mounted) setState(() {});
      String mensaje;
      if (error.code == 'ERROR_SESSION_EXPIRED')
        mensaje =
            'El código de verificación a CADUCADO por favor solicita uno nuevo revisando que el número de celular sea el correcto.';
      else
        mensaje = 'El código de verificación es INCORRECTO.';
      dlg.mostrar(context, mensaje, mIzquierda: 'CORREGIR');
    });
  }

  _onChangedCelular(phone) {
    cliente.celular = phone.toString();
  }

  bool _presBerificar = false;

  void _validarVerificarCelular() {
    if (_presBerificar) return;
    prefs.fechaCodigo = DateTime.now().toIso8601String();
    if (mounted) setState(() {});
    _presBerificar = true;
    FocusScope.of(context).requestFocus(FocusNode());
    _formKey.currentState.validate();
    _formKey.currentState.save();
    Future.delayed(const Duration(milliseconds: 400), () async {
      _presBerificar = false;
      _saving = true;
      if (mounted) setState(() {});
      _formKey.currentState.save();
      if (cliente.celular.toString().length <= 8) {
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
      _clienteProvider.verificarValidadCelular(cliente.celular.toString(),
          (estado, error) {
        if (estado == 1) {
          //Verificamos pues no esta verificado el celular
          _verifyPhoneNumber();
        } else if (estado == 0) {
          //Cuando el numero ya fue verificado por el mismo cliente se retorna estado cero
          _clienteProvider.validadCelular(cliente.celular);
          prefs.solicitados = 0;
          accionConfirmacion();
        } else {
          _saving = false;
          if (mounted) setState(() {});
          //Mostramos un mensaje de error esto puede ser por que le celular esta registrado para otro cliente
          dlg.mostrar(context, error, mIzquierda: 'ACEPTAR');
        }
      });
    });
  }
}
