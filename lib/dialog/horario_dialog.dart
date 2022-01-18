import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../bloc/horario_bloc.dart';
import '../model/horario_model.dart';
import '../model/sucursal_model.dart';
import '../utils/personalizacion.dart' as prs;
import '../utils/utils.dart' as utils;

class HorarioDialog extends StatefulWidget {
  final SucursalModel sucursalModel;
  final HorarioModel horarioModel;

  HorarioDialog({this.sucursalModel, this.horarioModel}) : super();

  HorarioDialogState createState() => HorarioDialogState(
      sucursalModel: sucursalModel, horarioModel: horarioModel);
}

class HorarioDialogState extends State<HorarioDialog>
    with TickerProviderStateMixin {
  final SucursalModel sucursalModel;
  HorarioModel horarioModel;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _horarioBloc = HorarioBloc();

  HorarioDialogState({this.sucursalModel, this.horarioModel});

  TextEditingController _inputFieldTimeInicionController =
      TextEditingController(text: '');

  TextEditingController _inputFieldTimeFinController =
      TextEditingController(text: '');

  @override
  void initState() {
    horarioModel.idSucursal = sucursalModel.idSucursal;
    if (horarioModel.idSucursalHorario > 0) {
      _inputFieldTimeInicionController =
          TextEditingController(text: horarioModel.desde);

      _inputFieldTimeFinController =
          TextEditingController(text: horarioModel.hasta);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      title: Text(
        '${horarioModel.acronimo}',
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(width: 400.0),
            Text('${sucursalModel.sucursal}'),
            _crearHoraInicio(context),
            _crearHoraFin(context),
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
            label: Text('REGISTAR'),
            icon: Icon(FontAwesomeIcons.edit, color: Colors.white, size: 15.0),
            onPressed: _editarHorario),
      ],
    );
  }

  void _editarHorario() async {
    if (!_formKey.currentState.validate()) {
      return;
    }
    utils.mostrarProgress(context, barrierDismissible: false);
    horarioModel.desde = _inputFieldTimeInicionController.text;
    horarioModel.hasta = _inputFieldTimeFinController.text;
    horarioModel = await _horarioBloc.editar(horarioModel);
    FocusScope.of(context).requestFocus(new FocusNode());
    Navigator.pop(context);
    Navigator.pop(context);
  }

  Widget _crearHoraInicio(BuildContext context) {
    return TextFormField(
      enableInteractiveSelection: false,
      controller: _inputFieldTimeInicionController,
      decoration: InputDecoration(
        icon: Icon(
          Icons.access_time,
          color: prs.colorIcons,
        ),
        hintText: 'Hora inico jornada',
        labelText: 'Hora inico jornada',
      ),
      validator: (value) {
        if (value.length < 4) return 'Escoge una hora';
        return null;
      },
      onTap: () {
        _selectTime(context, _inputFieldTimeInicionController, isDesde: true);
      },
    );
  }

  Widget _crearHoraFin(BuildContext context) {
    return TextFormField(
      enableInteractiveSelection: false,
      controller: _inputFieldTimeFinController,
      decoration: InputDecoration(
        icon: Icon(
          Icons.access_time,
          color: prs.colorIcons,
        ),
        hintText: 'Hora fin jornada',
        labelText: 'Hora fin jornada',
      ),
      validator: (value) {
        if (value.length < 4) return 'Escoge una hora';
        return null;
      },
      onTap: () {
        _selectTime(context, _inputFieldTimeFinController);
      },
    );
  }

  _selectTime(BuildContext context, _inputFieldTimeController,
      {bool isDesde: false}) async {
    FocusScope.of(context).requestFocus(new FocusNode());
    TimeOfDay sDate = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(DateTime.now()),
      builder: (BuildContext context, Widget child) {
        return child;
      },
    );
    if (isDesde)
      _inputFieldTimeController.text =
          '${sDate.hour > 9 ? '' : '0'}${sDate.hour}:${sDate.minute > 9 ? '' : '0'}${sDate.minute}:00';
    else
      _inputFieldTimeController.text =
          '${sDate.hour > 9 ? '' : '0'}${sDate.hour}:${sDate.minute > 9 ? '' : '0'}${sDate.minute}:59';
  }
}
