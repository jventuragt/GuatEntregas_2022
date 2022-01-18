import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import '../model/cliente_model.dart';
import '../model/promocion_model.dart';
import '../preference/db_provider.dart';
import '../preference/shared_preferences.dart';
import '../utils/personalizacion.dart' as prs;
import '../utils/validar.dart' as val;

class InstruccionDialog extends StatefulWidget {
  final PromocionModel promocion;

  InstruccionDialog({this.promocion}) : super();

  InstruccionDialogState createState() =>
      InstruccionDialogState(promocion: promocion);
}

class InstruccionDialogState extends State<InstruccionDialog>
    with TickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final prefs = PreferenciasUsuario();
  ClienteModel cliente = ClienteModel();

  InstruccionDialogState({this.promocion});

  PromocionModel promocion;

  @override
  void initState() {
    super.initState();
  }

  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
        color: Colors.black,
        opacity: 0.4,
        inAsyncCall: _saving,
        child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          contentPadding: EdgeInsets.only(left: 10.0, right: 5.0, top: 0.0),
          title: Text('Instrucciones'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(width: 400.0),
                  SizedBox(height: 10.0),
                  Text('${promocion.cantidad} ${promocion.producto}'),
                  _crearInstruccion()
                ],
              ),
            ),
          ),
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
                label: Text('REGISTRAR'),
                icon: Icon(FontAwesomeIcons.edit,
                    color: Colors.white, size: 15.0),
                onPressed: _registrarFactura),
          ],
        ));
  }

  void _registrarFactura() async {
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();
    _saving = true;
    if (mounted) setState(() {});
    await DBProvider.db.editarPromocion(promocion);
    _saving = false;
    if (mounted) setState(() {});
    FocusScope.of(context).requestFocus(new FocusNode());
    Navigator.pop(context);
  }

  Widget _crearInstruccion() {
    return TextFormField(
        initialValue: promocion.dt,
        minLines: 3,
        maxLines: 5,
        keyboardType: TextInputType.multiline,
        textCapitalization: TextCapitalization.sentences,
        maxLength: 85,
        decoration: InputDecoration(labelText: 'Instrucciones del producto'),
        onSaved: (value) => promocion.dt = value,
        validator: val.validarDireccion);
  }
}
