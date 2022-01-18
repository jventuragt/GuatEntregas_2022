import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../model/cliente_model.dart';
import '../providers/cliente_provider.dart';
import '../utils/dialog.dart' as dlg;
import '../utils/personalizacion.dart' as prs;
import '../utils/utils.dart' as utils;

class ContraseniaDialog extends StatefulWidget {
  final ClienteModel cliente;

  ContraseniaDialog({this.cliente}) : super();

  ContraseniaDialogState createState() =>
      ContraseniaDialogState(cliente: cliente);
}

class ContraseniaDialogState extends State<ContraseniaDialog>
    with TickerProviderStateMixin {
  final ClienteModel cliente;
  final ClienteProvider _clienteProvider = ClienteProvider();
  final GlobalKey<FormState> _formKeyContrasenia = GlobalKey<FormState>();

  ContraseniaDialogState({this.cliente});

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      title: Text('Cambiar contraseña'),
      content: Form(
        key: _formKeyContrasenia,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(width: 400.0),
            _contraseniaAnterior(),
            SizedBox(height: 10.0),
            _contraseniaNueva(),
//            Text('Tu contrasenia la enviamos a tu correo'),
          ],
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
            label: Text('CAMBIAR'),
            icon: Icon(FontAwesomeIcons.edit, color: Colors.white, size: 15.0),
            onPressed: () {
              _editarContrasenia(context);
            }),
      ],
    );
  }

  void _editarContrasenia(BuildContext context) {
    FocusScope.of(context).requestFocus(FocusNode());
    utils.mostrarProgress(context, barrierDismissible: false);
    _formKeyContrasenia.currentState.save();
    if (!_formKeyContrasenia.currentState.validate()) {
      Navigator.pop(context);
      return;
    }

    _clienteProvider.cambiarContrasenia(utils.generateMd5(contraseniaAnterior),
        utils.generateMd5(contraseniaNueva), (estado, error) {
      Navigator.pop(context);
      if (estado == 1) {
        Navigator.pop(context);
      }
      dlg.mostrar(context, error);
    });
  }

  String contraseniaAnterior = '', contraseniaNueva = '';

  Widget _contraseniaAnterior() {
    return TextFormField(
        keyboardType: TextInputType.text,
        maxLength: 12,
        decoration: prs.decoration('Contraseña anterior', prs.iconoContrasenia),
        onSaved: (value) => contraseniaAnterior = value,
        validator: (value) {
          if (value.length < 4) return 'Mínimo 4 caracteres';
          return null;
        });
  }

  Widget _contraseniaNueva() {
    return TextFormField(
        keyboardType: TextInputType.text,
        maxLength: 12,
        decoration:
            prs.decoration('Contraseña nueva', prs.iconoContraseniaNueva),
        onSaved: (value) => contraseniaNueva = value,
        validator: (value) {
          if (value.length < 4) return 'Mínimo 4 caracteres';
          return null;
        });
  }
}
