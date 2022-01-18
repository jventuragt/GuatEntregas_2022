import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import '../../bloc/factura_bloc.dart';
import '../../card/factura_card.dart';
import '../../card/shimmer_card.dart';
import '../../dialog/factura_dialog.dart';
import '../../model/factura_model.dart';
import '../../preference/shared_preferences.dart';
import '../../providers/factura_provider.dart';
import '../../utils/dialog.dart' as dlg;
import '../../utils/personalizacion.dart' as prs;
import '../../utils/utils.dart' as utils;

class FacturasPage extends StatefulWidget {
  FacturasPage() : super();

  @override
  _FacturasPageState createState() => _FacturasPageState();
}

class _FacturasPageState extends State<FacturasPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FacturaBloc _facturaBloc = FacturaBloc();
  final PreferenciasUsuario _prefs = PreferenciasUsuario();
  final _facturaProvider = FacturaProvider();
  bool _isLineProgress = false;

  bool _saving = false;

  _FacturasPageState();

  @override
  void initState() {
    _facturaBloc.listar();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Datos de facturas'),
        leading: utils.leading(context),
      ),
      key: _scaffoldKey,
      body: ModalProgressHUD(
        color: Colors.black,
        opacity: 0.4,
        progressIndicator: utils.progressIndicator('Eliminando...'),
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
        stream: _facturaBloc.facturaStream,
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
      onRefresh: () => _facturaBloc.listar(),
      child: ReorderableListView(
        children: _list,
        onReorder: (int desde, int hasta) async {
          FacturaModel _facturaAux;
          if (desde < hasta) {
            _facturaAux = _facturaBloc.facturas[desde];
            _facturaBloc.facturas.removeAt(desde);
            _facturaBloc.facturas.insert(hasta - 1, _facturaAux);
          } else {
            _facturaAux = _facturaBloc.facturas[desde];
            _facturaBloc.facturas.removeAt(desde);
            _facturaBloc.facturas.insert(hasta, _facturaAux);
          }
          String ids = '';
          for (var _factura in _facturaBloc.facturas)
            ids += '${_factura.idFactura}-';
          if (mounted) setState(() {});
          _isLineProgress = true;
          if (mounted) setState(() {});
          await _facturaProvider.ordenar(ids);
          _isLineProgress = false;
          if (!mounted) return;
          if (mounted) setState(() {});
        },
      ),
    );
  }

  _onTap(FacturaModel facturaModel) async {
    if (_prefs.isExplorar) return utils.registrarse(context, _scaffoldKey);
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return FacturaDialog(facturaModel: facturaModel);
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

  Widget _card(BuildContext context, FacturaModel facturaModel) {
    return Slidable(
      key: ValueKey(facturaModel.idFactura),
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: FacturaCard(
          facturaModel: facturaModel,
          key: ValueKey(facturaModel.idFactura),
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
              await _facturaBloc.eliminar(facturaModel);
              quitarCargando();
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Factura eliminado correctamente")));
            }

            dlg.mostrar(context, 'Esta acción no se puede revertir!',
                fBotonIDerecha: _enviarCancelar, mBotonDerecha: 'ELIMINAR');
          },
        ),
      ],
    );
  }
}
