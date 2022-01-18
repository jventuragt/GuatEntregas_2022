import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import '../bloc/horario_bloc.dart';
import '../card/horario_card.dart';
import '../card/shimmer_card.dart';
import '../dialog/horario_dialog.dart';
import '../model/agencia_model.dart';
import '../model/horario_model.dart';
import '../model/sucursal_model.dart';
import '../utils/personalizacion.dart' as prs;
import '../utils/utils.dart' as utils;

class HorariosView extends StatefulWidget {
  final AgenciaModel agenciaModel;
  final SucursalModel sucursalModel;

  HorariosView({Key key, this.agenciaModel, this.sucursalModel})
      : super(key: key);

  @override
  _HorariosViewState createState() => _HorariosViewState(
      agenciaModel: agenciaModel, sucursalModel: sucursalModel);
}

class _HorariosViewState extends State<HorariosView> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final HorarioBloc _horarioBloc = HorarioBloc();
  final AgenciaModel agenciaModel;
  final SucursalModel sucursalModel;

  bool _saving = false;

  _HorariosViewState({this.agenciaModel, this.sucursalModel});

  @override
  void initState() {
    _horarioBloc.listar(sucursalModel.idSucursal);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Horarios')),
      key: scaffoldKey,
      body: ModalProgressHUD(
        color: Colors.black,
        opacity: 0.4,
        progressIndicator: utils.progressIndicator('Eliminando...'),
        inAsyncCall: _saving,
        child: Column(
          children: <Widget>[
            SizedBox(height: 10.0),
            Container(
              padding: EdgeInsets.only(left: 10.0, bottom: 5.0),
              child: Text('Agencia ${agenciaModel.agencia}',
                  style: TextStyle(color: prs.colorIcons, fontSize: 20.0)),
            ),
            SizedBox(height: 5.0),
            Container(
              padding: EdgeInsets.only(left: 10.0, bottom: 5.0),
              child: Text('Sucursal ${sucursalModel.sucursal}',
                  style: TextStyle(color: prs.colorIcons, fontSize: 18.0)),
            ),
            Expanded(child: _listaCar(context)),
          ],
        ),
      ),
    );
  }

  Widget _listaCar(context) {
    return Container(
      child: StreamBuilder(
        stream: _horarioBloc.horarioStream,
        builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.length > 0)
              return createListView(context, snapshot);
            return Container(
              margin: EdgeInsets.all(80.0),
              width: double.infinity,
              height: double.infinity,
              child: Center(
                child: Image(
                  image: AssetImage('assets/screen/direcciones.png'),
                  fit: BoxFit.cover,
                ),
              ),
            );
          } else {
            return ShimmerCard();
          }
        },
      ),
    );
  }

  Widget createListView(BuildContext context, AsyncSnapshot snapshot) {
    return RefreshIndicator(
        onRefresh: () => _horarioBloc.listar(sucursalModel.idSucursal),
        child: ListView.builder(
            padding: EdgeInsets.only(right: 5.0, left: 5.0),
            itemCount: snapshot.data.length,
            itemBuilder: (BuildContext context, int index) {
              return _card(context, snapshot.data[index]);
            }));
  }

  _onTap(HorarioModel horarioModel) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return HorarioDialog(
            sucursalModel: sucursalModel,
            horarioModel: horarioModel,
          );
        });
  }

  mostraCargando() {
    _saving = true;
    if (mounted) setState(() {});
  }

  quitarCargando() {
    _saving = false;
    if (mounted) setState(() {});
  }

  Widget _card(BuildContext context, HorarioModel horarioModel) {
    return Slidable(
      key: ValueKey(horarioModel.idSucursalHorario),
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: HorarioCard(
          horarioModel: horarioModel,
          key: ValueKey(horarioModel.idSucursalHorario),
          onTab: _onTap),
      actions: <Widget>[],
//      secondaryActions: <Widget>[
//        IconSlideAction(
//          color: Colors.red,
//          caption: 'Eliminar',
//          icon: Icons.delete,
//          onTap: () {
//            _enviarCancelar() async {
//              Navigator.of(context).pop();
//              mostraCargando();
//              await _horarioBloc.eliminar(horarioModel);
//              quitarCargando();
//              Scaffold.of(context).showSnackBar(SnackBar(
//                  content: Text("Horario eliminado correctamente"),
//                  duration: Duration(milliseconds: 1200)));
//            }
//
//            dlg.mostrar(context, 'Esta acción no se puede revertir!',
//                fOk: _enviarCancelar, mensajeConfirmar: 'ELIMINAR');
//          },
//        ),
//      ],
    );
  }
}
