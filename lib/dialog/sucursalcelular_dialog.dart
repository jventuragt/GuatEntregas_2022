import 'package:flutter/material.dart';

import '../model/sucursal_model.dart';
import '../preference/shared_preferences.dart';
import '../utils/personalizacion.dart' as prs;
import '../utils/utils.dart' as utils;

class SucursalCelularDialog extends StatefulWidget {
  final Function onSucursalCelular;
  final SucursalModel sucursal;

  SucursalCelularDialog(this.sucursal, this.onSucursalCelular);

  @override
  _SucursalCelularDialogState createState() => _SucursalCelularDialogState();
}

class _SucursalCelularDialogState extends State<SucursalCelularDialog> {
  final prefs = PreferenciasUsuario();
  String celular = '';

  @override
  void initState() {
    super.initState();
  }

  _onChangedCelular(phone) {
    celular = phone;
  }

  Widget _crearCelular() {
    return Row(
      children: [
        SizedBox(width: 5.0),
        Expanded(
          child: utils.crearCelular(prefs.simCountryCode, _onChangedCelular,
              celular: widget.sucursal.contacto),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      contentPadding:
          EdgeInsets.only(top: 30.0, left: 5.0, right: 5.0, bottom: 20.0),
      title: Text('Sucursal: ${widget.sucursal.sucursal}',
          textAlign: TextAlign.center),
      content: _crearCelular(),
      actions: [
        TextButton(
          child: Text('CANCELAR'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
              primary: prs.colorButtonSecondary,
              elevation: 2.0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0))),
          label: Text(' GUARDAR '),
          icon: Icon(Icons.save, size: 18.0),
          onPressed: () {
            if (celular.length <= 8) return;
            widget.onSucursalCelular(celular);
          },
        )
      ],
    );
  }
}
