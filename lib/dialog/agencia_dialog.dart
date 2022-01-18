import 'package:flutter/material.dart';

import '../bloc/agencia_bloc.dart';
import '../model/agencia_model.dart';
import '../utils/personalizacion.dart' as prs;

class AgenciaDialog extends StatefulWidget {
  final Function onSelectAgencia;

  AgenciaDialog(this.onSelectAgencia);

  @override
  _AgenciaDialogState createState() => _AgenciaDialogState();
}

class _AgenciaDialogState extends State<AgenciaDialog> {
  final AgenciaBloc _agenciaBloc = AgenciaBloc();
  bool _isLineProgress = false;

  @override
  void initState() {
    super.initState();
  }

  Widget _selecAgenciaes() {
    return Column(
      children: [
        Visibility(
            visible: _isLineProgress,
            child: LinearProgressIndicator(
                backgroundColor: prs.colorLinearProgress)),
        StreamBuilder(
          stream: _agenciaBloc.agenciaStream,
          builder: (BuildContext context,
              AsyncSnapshot<List<AgenciaModel>> snapshot) {
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

  Widget createExpanPanel(context, listaAgenciaes) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(0.0),
      itemCount: listaAgenciaes.length,
      itemBuilder: (BuildContext context, int index) {
        final AgenciaModel direccionModel = listaAgenciaes[index];
        Color _color =
            direccionModel.idAgencia <= 0 ? Colors.red : Colors.black;
        return ListTile(
          onTap: () {
            widget.onSelectAgencia(direccionModel);
          },
          dense: true,
          title: Text(direccionModel.agencia),
          subtitle: Text(
            '${direccionModel.direccion}',
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
        await _agenciaBloc.filtrar(value);
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
      title: Text('Busca una agencia'),
      content: Container(
        width: 400.0,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              _crearBuscardor(),
              _selecAgenciaes(),
            ],
          ),
        ),
      ),
    );
  }
}
