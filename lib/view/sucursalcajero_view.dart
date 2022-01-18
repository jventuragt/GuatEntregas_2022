import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import '../bloc/sucursalcajero_bloc.dart';
import '../card/shimmer_card.dart';
import '../card/sucursalcajero_card.dart';
import '../dialog/sucursalcelular_dialog.dart';
import '../model/agencia_model.dart';
import '../model/sucursal_model.dart';
import '../model/sucursalcajero_model.dart';
import '../providers/sucursal_provider.dart';
import '../utils/personalizacion.dart' as prs;
import '../utils/utils.dart' as utils;

class SucursalcajerosView extends StatefulWidget {
  final AgenciaModel agenciaModel;
  final SucursalModel sucursalModel;

  SucursalcajerosView({Key key, this.agenciaModel, this.sucursalModel})
      : super(key: key);

  @override
  _SucursalcajerosViewState createState() => _SucursalcajerosViewState(
      agenciaModel: agenciaModel, sucursalModel: sucursalModel);
}

class _SucursalcajerosViewState extends State<SucursalcajerosView> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final SucursalcajeroBloc _sucursalcajeroBloc = SucursalcajeroBloc();
  final SucursalProvider _sucursalProvider = SucursalProvider();
  final AgenciaModel agenciaModel;
  final SucursalModel sucursalModel;

  bool _saving = false;

  _SucursalcajerosViewState({this.agenciaModel, this.sucursalModel});

  @override
  void initState() {
    super.initState();
    _sucursalcajeroBloc.listar(sucursalModel.idSucursal);
  }

  onSucursalCelular(String celular) async {
    Navigator.pop(context);
    sucursalModel.contacto = celular;
    mostraCargando();
    await _sucursalProvider.editarSucursal(sucursalModel);
    quitarCargando();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cajeros'),
        actions: [
          IconButton(
            padding: EdgeInsets.only(right: 10.0),
            onPressed: () {
              showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) {
                    return SucursalCelularDialog(
                        sucursalModel, onSucursalCelular);
                  });
            },
            icon: Icon(Icons.phonelink_setup, size: 30.0),
          )
        ],
      ),
      key: scaffoldKey,
      body: ModalProgressHUD(
        color: Colors.black,
        opacity: 0.4,
        progressIndicator: utils.progressIndicator('Cargando...'),
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
            Divider(),
            SizedBox(height: 10.0),
            Expanded(child: _listaCar(context)),
          ],
        ),
      ),
    );
  }

  Widget _listaCar(context) {
    return Container(
      child: StreamBuilder(
        stream: _sucursalcajeroBloc.sucursalcajeroStream,
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
        onRefresh: () => _sucursalcajeroBloc.listar(sucursalModel.idSucursal),
        child: ListView.builder(
            padding: EdgeInsets.only(right: 5.0, left: 5.0),
            itemCount: snapshot.data.length,
            itemBuilder: (BuildContext context, int index) {
              return _card(context, snapshot.data[index]);
            }));
  }

  _onTap(SucursalcajeroModel sucursalcajeroModel) async {
//    showDialog(
//        context: context,
//        barrierDismissible: false,
//        builder: (context) {
//          return SucursalcajeroDialog(
//            sucursalModel: sucursalModel,
//            sucursalcajeroModel: sucursalcajeroModel,
//          );
//        });
  }

  mostraCargando() {
    _saving = true;
    if (mounted) setState(() {});
  }

  quitarCargando() {
    _saving = false;
    if (mounted) setState(() {});
  }

  Widget _card(BuildContext context, SucursalcajeroModel sucursalcajeroModel) {
    return SucursalcajeroCard(
        sucursalcajeroModel: sucursalcajeroModel,
        key: ValueKey(sucursalcajeroModel.idCliente),
        onTab: _onTap);
  }
}
