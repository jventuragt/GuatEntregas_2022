import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import '../bloc/factura_bloc.dart';
import '../model/cliente_model.dart';
import '../model/factura_model.dart';
import '../preference/shared_preferences.dart';
import '../utils/button.dart' as btn;
import '../utils/personalizacion.dart' as prs;
import '../utils/validar.dart' as val;

class FacturaDialog extends StatefulWidget {
  final FacturaModel facturaModel;

  FacturaDialog({this.facturaModel}) : super();

  FacturaDialogState createState() =>
      FacturaDialogState(facturaModel: facturaModel);
}

class FacturaDialogState extends State<FacturaDialog>
    with TickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _facturaBloc = FacturaBloc();
  final prefs = PreferenciasUsuario();
  ClienteModel cliente = ClienteModel();

  FacturaDialogState({this.facturaModel});

  FacturaModel facturaModel;

  @override
  void initState() {
    cliente = prefs.clienteModel;
    if (facturaModel.idFactura <= 0) {
      facturaModel.nombres = cliente.nombres;
      facturaModel.correo = cliente.correo;
      facturaModel.numero = cliente.celular;
    }
    super.initState();
  }

  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Datos de facturas'),
        ),
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
        btn.confirmar('REGISTRAR', _registrarFactura)
      ],
    );
  }

  Widget _contenido() {
    return Container(
      padding: EdgeInsets.only(left: 20.0, right: 20.0),
      child: Column(
        children: <Widget>[
          Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                SizedBox(height: 20.0),
                _crearDni(),
                SizedBox(height: 10.0),
                _crearNombres(),
                SizedBox(height: 10.0),
                _crearNumero(),
                SizedBox(height: 10.0),
                _crearCorreo(),
                SizedBox(height: 10.0),
                _crearDireccion(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _registrarFactura() async {
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();
    _saving = true;
    if (mounted) setState(() {});
    if (facturaModel.idFactura <= 0)
      facturaModel = await _facturaBloc.crear(facturaModel);
    else
      await _facturaBloc.editar(facturaModel);
    _saving = false;
    if (mounted) setState(() {});
    FocusScope.of(context).requestFocus(new FocusNode());
    Navigator.pop(context);
  }

  Widget _crearDni() {
    return TextFormField(
        initialValue: facturaModel.dni,
        keyboardType: TextInputType.text,
        maxLength: 45,
        decoration: prs.decoration('Cédula o Ruc', null),
        onSaved: (value) => facturaModel.dni = value,
        validator: val.validarDni);
  }

  Widget _crearNombres() {
    return TextFormField(
        initialValue: facturaModel.nombres,
        keyboardType: TextInputType.text,
        textCapitalization: TextCapitalization.words,
        maxLength: 125,
        decoration: prs.decoration('Nombre completo', null),
        onSaved: (value) => facturaModel.nombres = value,
        validator: val.validarNombre);
  }

  Widget _crearNumero() {
    return TextFormField(
        initialValue: facturaModel.numero,
        keyboardType: TextInputType.phone,
        maxLength: 20,
        decoration: prs.decoration('Número', null),
        onSaved: (value) => facturaModel.numero = value,
        validator: val.validarNumero);
  }

  Widget _crearCorreo() {
    return TextFormField(
        initialValue: facturaModel.correo,
        keyboardType: TextInputType.emailAddress,
        maxLength: 60,
        decoration: prs.decoration('Correo', null),
        onSaved: (value) => facturaModel.correo = value,
        validator: val.validarCorreo);
  }

  Widget _crearDireccion() {
    return TextFormField(
        initialValue: facturaModel.direccion,
        minLines: 2,
        maxLines: 4,
        keyboardType: TextInputType.multiline,
        textCapitalization: TextCapitalization.sentences,
        maxLength: 255,
        decoration: prs.decoration('Dirección', null),
        onSaved: (value) => facturaModel.direccion = value,
        validator: val.validarDireccion);
  }
}
