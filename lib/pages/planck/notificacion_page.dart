import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import '../../bloc/notificacion_bloc.dart';
import '../../card/notificacion_card.dart';
import '../../card/shimmer_card.dart';
import '../../model/notificacion_model.dart';
import '../../utils/permisos.dart' as permisos;
import '../../utils/personalizacion.dart' as prs;
import '../../utils/utils.dart' as utils;

class NotificacionPage extends StatefulWidget {
  @override
  _NotificacionPageState createState() => _NotificacionPageState();
}

class _NotificacionPageState extends State<NotificacionPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final NotificacionBloc _notificacionBloc = NotificacionBloc();

  bool _isLineProgress = false;

  @override
  void initState() {
    _notificacionBloc.listar();
    super.initState();
  }

  bool _saving = false;
  bool _radar = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Notificaciones'),
        leading: utils.leading(context),
      ),
      key: scaffoldKey,
      body: ModalProgressHUD(
        color: Colors.black,
        opacity: 0.4,
        progressIndicator: _radar
            ? utils.progressRadar()
            : utils.progressIndicator('Cargando...'),
        inAsyncCall: _saving,
        child: Center(
            child: Container(child: _body(), width: prs.anchoFormulario)),
      ),
    );
  }

  Widget _body() {
    return Column(
      children: <Widget>[
        Visibility(
            visible: _isLineProgress,
            child: LinearProgressIndicator(
                backgroundColor: prs.colorLinearProgress)),
        SizedBox(height: 10.0),
        Expanded(child: _listaCar(context)),
      ],
    );
  }

  Widget _listaCar(context) {
    return Container(
      child: StreamBuilder(
        stream: _notificacionBloc.notificacionStream,
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
                  image: AssetImage('assets/screen/notificacion.png'),
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
      onRefresh: () => _notificacionBloc.listar(),
      child: ListView.builder(
        itemCount: snapshot.data.length,
        itemBuilder: (BuildContext context, int index) {
          return NotificacionCard(
              notificacionModel: snapshot.data[index],
              key: ValueKey(snapshot.data[index].idMensaje),
              onTab: _onTap);
        },
      ),
    );
  }

  _onTap(NotificacionModel notificacionModel) async {
    //notificacionModel.accion(context);
    permisos.mostrarNoti(context, notificacionModel);
  }

  mostraCargando() {
    _saving = true;
    if (mounted) setState(() {});
  }

  quitarCargando() {
    _saving = false;
    if (mounted) setState(() {});
  }
}
