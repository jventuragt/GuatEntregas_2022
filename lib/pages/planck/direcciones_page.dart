import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import '../../bloc/direccion_bloc.dart';
import '../../card/direccion_card.dart';
import '../../card/shimmer_card.dart';
import '../../model/cajero_model.dart';
import '../../model/direccion_model.dart';
import '../../providers/direccion_provider.dart';
import '../../utils/dialog.dart' as dlg;
import '../../utils/permisos.dart' as permisos;
import '../../utils/personalizacion.dart' as prs;
import '../../utils/utils.dart' as utils;
import 'direccion_page.dart';

class DireccionesPage extends StatefulWidget {
  @override
  _DireccionesPageState createState() => _DireccionesPageState();
}

class _DireccionesPageState extends State<DireccionesPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final DireccionBloc _direccionBloc = DireccionBloc();
  final DireccionProvider _direccionProvider = DireccionProvider();
  CajeroModel cajeroModel;
  bool _isLineProgress = false;

  @override
  void initState() {
    _direccionBloc.listar();
    super.initState();
  }

  bool _saving = false;
  bool _radar = false;

  @override
  Widget build(BuildContext context) {
    final CajeroModel cajeroData = ModalRoute.of(context).settings.arguments;
    if (cajeroData != null) {
      cajeroModel = cajeroData;
    }
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Mis direcciones'),
        leading: utils.leading(context),
      ),
      key: scaffoldKey,
      body: ModalProgressHUD(
        color: Colors.black,
        opacity: 0.4,
        progressIndicator: _radar
            ? utils.progressRadar()
            : utils.progressIndicator('Eliminando...'),
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
        stream: _direccionBloc.direccionStream,
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

  List<Widget> _list = [];

  Widget createListView(BuildContext context, AsyncSnapshot snapshot) {
    _list.clear();
    for (var item in snapshot.data) _list.add(_card(context, item));
    return RefreshIndicator(
      onRefresh: () => _direccionBloc.listar(),
      child: ReorderableListView(
        children: _list,
        onReorder: (int desde, int hasta) async {
          DireccionModel _direccionAux;
          if (desde < hasta) {
            _direccionAux = _direccionBloc.direcciones[desde];
            _direccionBloc.direcciones.removeAt(desde);
            _direccionBloc.direcciones.insert(hasta - 1, _direccionAux);
          } else {
            _direccionAux = _direccionBloc.direcciones[desde];
            _direccionBloc.direcciones.removeAt(desde);
            _direccionBloc.direcciones.insert(hasta, _direccionAux);
          }
          String ids = '';
          for (var _direccion in _direccionBloc.direcciones)
            ids += '${_direccion.idDireccion}-';
          if (mounted) setState(() {});
          _isLineProgress = true;
          if (mounted) setState(() {});
          await _direccionProvider.ordenar(ids);
          _isLineProgress = false;
          if (!mounted) return;
          if (mounted) setState(() {});
        },
      ),
    );
  }

  _onTap(DireccionModel direccionModel) async {
    if (direccionModel.idDireccion <= 0) return _requestGps();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DireccionPage(
            lt: direccionModel.lt,
            lg: direccionModel.lg,
            direccionModel: direccionModel,
            cajeroModel: cajeroModel),
      ),
    );
  }

  _requestGps() async {
    permisos.localizarTo(context, (lt, lg) {
      if (lt == 2.2)
        return; //Este estado significa q se mostro dialogo para localizar
      _irADireccion(lt, lg);
    });
  }

  _irADireccion(lt, lg) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DireccionPage(
            lt: lt,
            lg: lg,
            direccionModel: DireccionModel(),
            cajeroModel: cajeroModel),
      ),
    );
  }

  mostraCargando() {
    _saving = true;
    if (mounted) setState(() {});
  }

  quitarCargando() {
    _saving = false;
    if (mounted) setState(() {});
  }

  Widget _card(BuildContext context, DireccionModel direccionModel) {
    return Slidable(
      key: ValueKey(direccionModel.idDireccion),
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: DireccionCard(
          direccionModel: direccionModel,
          key: ValueKey(direccionModel.idDireccion),
          onTab: _onTap),
      actions: <Widget>[],
      secondaryActions: <Widget>[
        IconSlideAction(
          color: Colors.red,
          caption: 'Eliminar',
          icon: Icons.delete,
          onTap: () {
            _enviarCancelar() async {
              Navigator.of(context).pop();
              mostraCargando();
              await _direccionBloc.eliminar(direccionModel);
              quitarCargando();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                      "Direccion ${direccionModel.referencia} eliminada")));
            }

            dlg.mostrar(context, 'Esta acción no se puede revertir!',
                fBotonIDerecha: _enviarCancelar, mBotonDerecha: 'ELIMINAR');
          },
        ),
      ],
    );
  }
}
