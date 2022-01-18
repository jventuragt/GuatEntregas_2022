import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import '../../bloc/direccion_bloc.dart';
import '../../dialog/direccion_dialog.dart';
import '../../model/agencia_model.dart';
import '../../model/direccion_model.dart';
import '../../preference/shared_preferences.dart';
import '../../providers/agencia_provider.dart';
import '../../utils/button.dart' as btn;
import '../../utils/conf.dart' as config;
import '../../utils/dialog.dart' as dlg;
import '../../utils/permisos.dart' as permisos;
import '../../utils/personalizacion.dart' as prs;
import '../../utils/utils.dart' as utils;
import '../../utils/validar.dart' as val;
import 'direccion_page.dart';

class PreRegistroPage extends StatefulWidget {
  PreRegistroPage({Key key}) : super(key: key);

  _PreRegistroPageState createState() => _PreRegistroPageState();
}

class _PreRegistroPageState extends State<PreRegistroPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final PreferenciasUsuario prefs = PreferenciasUsuario();

  final PreferenciasUsuario _prefs = PreferenciasUsuario();
  final AgenciaProvider _agenciaProvider = AgenciaProvider();
  final DireccionBloc _direccionBloc = DireccionBloc();
  AgenciaModel _agencia = AgenciaModel();
  final TextEditingController _typeControllerDireccion =
      TextEditingController();
  bool _saving = false;
  DireccionModel direccionSeleccionada = DireccionModel();

  @override
  void initState() {
    _typeControllerDireccion.text = direccionSeleccionada.alias;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text('Registra tu comercio'),
        leading: utils.leading(context),
      ),
      body: ModalProgressHUD(
        color: Colors.black,
        opacity: 0.4,
        progressIndicator: _radar
            ? utils.progressRadar()
            : utils.progressIndicator('Cargando...'),
        inAsyncCall: _saving,
        child: Center(
            child: Container(child: _body(), width: prs.anchoFormulario)),
      ),
    );
  }

  Widget _body() {
    return Column(
      children: <Widget>[
        Expanded(child: SingleChildScrollView(child: _contenido())),
        Visibility(
            visible: !_prefs.isExplorar,
            child: btn.booton('REGISTRAR COMERCIO', _guardarCambios))
      ],
    );
  }

  Column _contenido() {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(top: 10.0, right: 20.0, left: 20.0),
          child: Column(
            children: <Widget>[
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 10.0),
                    createExpanPanel(context),
                    SizedBox(height: 20.0),
                    _crearNombres(),
                    SizedBox(height: 20.0),
                    _crearCelular(),
                    SizedBox(height: 20.0),
                    _crearCorreo(),
                  ],
                ),
              ),
              SizedBox(height: 30.0),
              Text(
                'La información que proporciones debe ser tuya. Además debe ser totalmente verídica y real, ya que eres el responsable legal de la manipulación de dicha información.',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10.0),
              Text(
                'Al enviar el formulario aceptas términos y condiciones.',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 100.0),
            ],
          ),
        ),
      ],
    );
  }

  Widget createExpanPanel(BuildContext context) {
    return InkWell(
      onTap: _mostrarDirecciones,
      child: TextFormField(
        validator: (bal) {
          if (direccionSeleccionada.idDireccion <= 0)
            return 'Dirección exacta del comercio.';
          return null;
        },
        enabled: false,
        controller: this._typeControllerDireccion,
        decoration: prs.decoration(
            'Dirección exacta del comercio.', prs.iconoDespachor),
      ),
    );
  }

  _mostrarDirecciones() async {
    if (_direccionBloc.direcciones.isEmpty) {
      utils.mostrarProgress(context, barrierDismissible: false);
      await _direccionBloc.listar();
      Navigator.pop(context);
    }
    showDialog(
        context: context,
        builder: (context) {
          return DireccionDialog(_direccionBloc.direcciones, _onselecDireccion);
        });
  }

  _onselecDireccion(DireccionModel direccion) {
    Navigator.pop(context);
    if (direccion.idDireccion <= 0) {
      _requestGps();
    } else {
      _typeControllerDireccion.text = direccion.alias;
      direccionSeleccionada = direccion;
      _formKey.currentState.validate();
    }
  }

  bool _radar = false;

  _requestGps() async {
    permisos.localizarTo(context, (lt, lg) {
      if (lt == 2.2)
        return; //Este estado significa q se mostro dialogo para localizar
      _irADireccion(lt, lg);
    });
  }

  _irADireccion(lt, lg) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DireccionPage(
            lt: lt,
            lg: lg,
            direccionModel: DireccionModel(),
            cajeroModel: null,
            pagina: config.PAGINA_CARRITO),
      ),
    );
  }

  Widget _crearNombres() {
    return TextFormField(
        maxLength: 90,
        textCapitalization: TextCapitalization.words,
        decoration: prs.decoration(
            'Nombre del comercio que se mostrará a tus clientes',
            prs.iconoCompras),
        onSaved: (value) => _agencia.agencia = value,
        validator: val.validarNombreLocal);
  }

  bool isCelularValido = true;

  _onChangedCelular(phone) {
    _agencia.contacto = phone.toString();
  }

  Widget _crearCelular() {
    return utils.crearCelular(prefs.simCountryCode, _onChangedCelular);
  }

  Widget _crearCorreo() {
    return TextFormField(
        keyboardType: TextInputType.emailAddress,
        maxLength: 60,
        initialValue: _agencia.mail,
        decoration: prs.decoration(
            'Correo del comercio, el correo personal es válido.',
            prs.iconoCorreo),
        onSaved: (value) => _agencia.mail = value,
        validator: val.validarCorreo);
  }

  _guardarCambios() {
    FocusScope.of(context).requestFocus(FocusNode());
    _formKey.currentState.validate();
    _formKey.currentState.save();

    _saving = true;
    if (mounted) setState(() {});

    if (!_formKey.currentState.validate()) {
      _saving = false;
      if (mounted) setState(() {});
      return;
    }

    if (_agencia.contacto.toString().length <= 8) {
      _formKey.currentState.validate();
      _saving = false;
      if (mounted) setState(() {});
      return;
    }

    _agenciaProvider.preRegistro(_agencia, direccionSeleccionada,
        (estado, error) {
      _saving = false;
      _agencia = AgenciaModel();
      if (mounted) setState(() {});
      void fAceptar() {
        Navigator.pop(context);
        Navigator.pop(context);
      }

      return dlg.mostrar(context, error, fIzquierda: fAceptar);
    });
  }
}
