import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../../model/cliente_model.dart';
import '../../preference/shared_preferences.dart';
import '../../providers/cliente_provider.dart';
import '../../utils/button.dart' as btn;
import '../../utils/personalizacion.dart' as prs;
import '../../utils/utils.dart' as utils;
import '../../utils/validar.dart' as val;

class ContraseniaPage extends StatefulWidget {
  ContraseniaPage({Key key}) : super(key: key);

  @override
  State<ContraseniaPage> createState() => _ContraseniaPageState();
}

class _ContraseniaPageState extends State<ContraseniaPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ClienteProvider _clienteProvider = ClienteProvider();

  final prefs = PreferenciasUsuario();

  _ContraseniaPageState();

  bool _saving = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Recuperar contraseña'),
          leading: utils.leading(context, path: 'registrar'),
        ),
        key: _scaffoldKey,
        body: ModalProgressHUD(
          inAsyncCall: _saving,
          child: Center(
              child: Container(child: _body(), width: prs.anchoFormulario)),
        ),
      ),
    );
  }

  Widget _body() {
    return Column(
      children: <Widget>[
        Expanded(child: SingleChildScrollView(child: _contenido())),
        btn.booton('Recuperar contraseña', _recuperarContrasenia)
      ],
    );
  }

  Widget _contenido() {
    return Container(
      padding: EdgeInsets.all(20.0),
      child: Column(
        children: <Widget>[
          SizedBox(height: 10.0),
          ToggleSwitch(
            minWidth: 121.0,
            initialLabelIndex: indexSelect,
            activeBgColor: [prs.colorButtonSecondary],
            totalSwitches: 2,
            inactiveBgColor: Colors.black12,
            activeFgColor: Colors.white,
            labels: ['Celular', 'Correo'],
            onToggle: (index) {
              indexSelect = index;
              if (mounted) setState(() {});
            },
          ),
          SizedBox(height: 10.0),
          Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                _crearCelular(),
                _crearCorreo(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _recuperarContrasenia() {
    FocusScope.of(context).requestFocus(FocusNode());
    _saving = true;
    if (mounted) setState(() {});

    _formKey.currentState.validate();
    _formKey.currentState.save();

    if (indexSelect == 0 && !isCelularValido) {
      _saving = false;
      if (mounted) setState(() {});
      return;
    } else if (indexSelect == 1 && val.validarCorreo(cliente.correo) != null) {
      _saving = false;
      if (mounted) setState(() {});
      return;
    }

    _clienteProvider.recuperarContrasenia(cliente, indexSelect,
        (estado, error) {
      _saving = false;
      if (mounted) setState(() {});
      _mostrarMensaje(context, estado, error);
    });
  }

  _mostrarMensaje(BuildContext context, int estado, String mensaje) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            title: Text('Importante'),
            content: Text(mensaje),
            actions: <Widget>[
              ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      primary: prs.colorButtonSecondary,
                      elevation: 2.0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0))),
                  label: Text('ACEPTAR'),
                  icon: Icon(
                    Icons.check,
                    size: 18.0,
                  ),
                  onPressed: () {
                    if (estado == 1)
                      Navigator.pushReplacementNamed(context, 'registrar');
                    else
                      Navigator.pop(context);
                  }),
            ],
          );
        });
  }

  ClienteModel cliente = ClienteModel();
  bool isCelularValido = true;

  int indexSelect = 0;

  _onChangedCelular(phone) {
    cliente.celular = phone;
  }

  Widget _crearCelular() {
    return Visibility(
      visible: indexSelect == 0,
      child: Row(
        children: [
          SizedBox(width: 5.0),
          Expanded(
              child:
                  utils.crearCelular(prefs.simCountryCode, _onChangedCelular))
        ],
      ),
    );
  }

  Widget _crearCorreo() {
    return Visibility(
      visible: indexSelect == 1,
      child: TextFormField(
        keyboardType: TextInputType.emailAddress,
        maxLength: 60,
        decoration: prs.decoration('Correo', prs.iconoCorreo),
        onSaved: (value) => cliente.correo = value,
        validator: val.validarCorreo,
      ),
    );
  }
}
