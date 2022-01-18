import 'package:flutter/material.dart';

import '../model/direccion_model.dart';

class DireccionDialog extends StatefulWidget {
  final Function onSelectDireccion;
  final List<DireccionModel> listaDirecciones;

  DireccionDialog(this.listaDirecciones, this.onSelectDireccion);

  @override
  _DireccionDialogState createState() => _DireccionDialogState();
}

class _DireccionDialogState extends State<DireccionDialog> {
  @override
  void initState() {
    super.initState();
  }

  Widget _selecDirecciones() {
    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.all(0.0),
      itemCount: widget.listaDirecciones.length,
      itemBuilder: (BuildContext context, int index) {
        final DireccionModel direccionModel = widget.listaDirecciones[index];
        Color _color =
            direccionModel.idDireccion <= 0 ? Colors.red : Colors.black;
        IconData _ico =
            direccionModel.idDireccion <= 0 ? Icons.add : Icons.my_location;
        return ListTile(
          onTap: () {
            widget.onSelectDireccion(direccionModel);
          },
          dense: true,
          trailing: Icon(_ico, color: _color),
          title: Text(direccionModel.alias),
          subtitle: Text(
            '${direccionModel.referencia}',
            style: TextStyle(color: _color),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      contentPadding: EdgeInsets.only(left: 10.0, right: 5.0, top: 0.0),
      title: Text('Selecciona una dirección'),
      content: Container(
        width: 400.0,
        child: _selecDirecciones(),
      ),
    );
  }
}
