import 'package:flutter/material.dart';

import '../bloc/sucursal_bloc.dart';
import '../model/sucursal_model.dart';
import '../utils/personalizacion.dart' as prs;

class SucursalDialog extends StatefulWidget {
  final Function onSelectSucursal;

  SucursalDialog(this.onSelectSucursal);

  @override
  _SucursalDialogState createState() => _SucursalDialogState();
}

class _SucursalDialogState extends State<SucursalDialog> {
  final SucursalBloc _sucursalBloc = SucursalBloc();
  bool _isLineProgress = false;

  @override
  void initState() {
    super.initState();
  }

  Widget _selecSucursales() {
    return Column(
      children: [
        Visibility(
            visible: _isLineProgress,
            child: LinearProgressIndicator(
                backgroundColor: prs.colorLinearProgress)),
        StreamBuilder(
          stream: _sucursalBloc.sucursalStream,
          builder: (BuildContext context,
              AsyncSnapshot<List<SucursalModel>> snapshot) {
            if (snapshot.hasData) {
              return createExpanPanel(context, snapshot.data);
            } else {
              return Container();
            }
          },
        )
      ],
    );
  }

  Widget createExpanPanel(context, listaSucursales) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(0.0),
      itemCount: listaSucursales.length,
      itemBuilder: (BuildContext context, int index) {
        final SucursalModel sucursalModel = listaSucursales[index];
        Color _color =
            sucursalModel.idSucursal <= 0 ? Colors.red : Colors.black;
        return ListTile(
          onTap: () {
            widget.onSelectSucursal(sucursalModel);
          },
          dense: true,
          title: Text(sucursalModel.sucursal),
          subtitle: Text(
            '${sucursalModel.direccion}',
            style: TextStyle(color: _color),
          ),
        );
      },
    );
  }

  Widget _crearBuscardor() {
    return TextFormField(
      onChanged: (value) async {
        _isLineProgress = true;
        if (mounted) setState(() {});
        await _sucursalBloc.buscar(value);
        _isLineProgress = false;
        if (mounted) if (mounted) setState(() {});
      },
      autofocus: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: EdgeInsets.all(10.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      contentPadding: EdgeInsets.only(left: 10.0, right: 5.0, top: 0.0),
      title: Text('Busca una sucursal'),
      content: Container(
        width: 400.0,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              _crearBuscardor(),
              _selecSucursales(),
            ],
          ),
        ),
      ),
    );
  }
}
