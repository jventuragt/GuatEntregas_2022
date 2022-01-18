import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import '../../model/promocion_model.dart';
import '../../providers/promocion_provider.dart';
import '../../utils/button.dart' as btn;
import '../../utils/dialog.dart' as dlg;
import '../../utils/personalizacion.dart' as prs;
import '../../utils/utils.dart' as utils;

class ProductosPage extends StatefulWidget {
  final PromocionModel promocionModel;

  ProductosPage({Key key, this.promocionModel}) : super(key: key);

  @override
  _ProductosPageState createState() => _ProductosPageState(promocionModel);
}

class _ProductosPageState extends State<ProductosPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  PromocionProvider _promocionProvider = PromocionProvider();
  final PromocionModel promocionModel;
  List<Widget> _list;
  List<LP> _listProdcutos;

  _ProductosPageState(this.promocionModel);

  bool _isLineProgress = false;

  @override
  void initState() {
    _list = [];
    _listProdcutos = [];
    if (promocionModel.productos?.lP != null &&
        promocionModel.productos.lP.length > 0)
      _listProdcutos.addAll(promocionModel.productos.lP);
    else {
      promocionModel.productos = Productos();
      promocionModel.productos.lP = [];
    }
    super.initState();
  }

  final GlobalKey<FormState> _formKeySubProducto = GlobalKey<FormState>();
  bool _saving = false;
  bool _radar = false;

  LP _aux = LP();

  _dialog() {
    _aux = LP();
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Agregar sub producto'),
            content: Form(
              key: _formKeySubProducto,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(width: 600.0),
                  TextFormField(
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      suffixIcon: Icon(Icons.attach_money, size: 27.0),
                      hintText: 'Precio',
                      labelText: 'Precio',
                    ),
                    validator: (val) {
                      if (val.length <= 0) return 'Precio';
                      try {
                        double.parse(val);
                      } catch (e) {
                        return 'Precio';
                      }
                      return null;
                    },
                    onSaved: (val) {
                      _aux.p = double.parse(val);
                    },
                  ),
                  TextFormField(
                    textCapitalization: TextCapitalization.sentences,
                    keyboardType: TextInputType.text,
                    maxLength: 55,
                    maxLines: 2,
                    minLines: 1,
                    decoration: InputDecoration(
                      hintText: 'Detalle',
                      labelText: 'Detalle',
                    ),
                    validator: (val) {
                      if (val.length <= 4) return 'Detalle';
                      return null;
                    },
                    onSaved: (val) {
                      _aux.d = val;
                    },
                  )
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
                  label: Text('AGREGAR'),
                  icon: Icon(FontAwesomeIcons.edit,
                      color: Colors.white, size: 15.0),
                  onPressed: () {
                    FocusScope.of(context).requestFocus(FocusNode());
                    if (!_formKeySubProducto.currentState.validate()) return;
                    _formKeySubProducto.currentState.save();
                    Navigator.pop(context);
                    _listProdcutos.insert(0, _aux);
                    if (mounted) setState(() {});
                  }),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(promocionModel.producto),
        actions: [
          IconButton(
            padding: EdgeInsets.only(right: 30.0),
            icon: Icon(Icons.add_circle_outline, size: 35.0),
            onPressed: _dialog,
          ),
        ],
      ),
      key: scaffoldKey,
      body: ModalProgressHUD(
        color: Colors.black,
        opacity: 0.4,
        progressIndicator: _radar
            ? utils.progressRadar()
            : utils.progressIndicator('Guardando...'),
        inAsyncCall: _saving,
        child: Column(
          children: <Widget>[
            Visibility(
                visible: _isLineProgress,
                child: LinearProgressIndicator(
                    backgroundColor: prs.colorLinearProgress)),
            SizedBox(height: 10.0),
            Expanded(child: createListView(context)),
            btn.bootonIcon('ESTABLECER CAMBIOS', prs.iconoGuardarDireccion,
                _establecerCambios),
          ],
        ),
      ),
    );
  }

  _establecerCambios() async {
    _saving = true;
    if (mounted) setState(() {});
    promocionModel.productos.lP.clear();
    for (var i = 0; i < _listProdcutos.length; i++) {
      _listProdcutos[i].id = i.toString();
      promocionModel.productos.lP.add(_listProdcutos[i]);
    }
    bool isGuardado =
        await _promocionProvider.editarSubProductos(promocionModel);
    _saving = false;
    if (mounted) setState(() {});
    if (isGuardado) {
      dlg.mostrar(context, 'Datos actualizados correctamente');
    } else {
      dlg.mostrar(context, 'Ups, lo sentimos intenta de nuevo más tarde.');
    }
  }

  Widget createListView(BuildContext context) {
    _list.clear();
    for (var item in _listProdcutos) _list.add(_card(context, item));
    return ReorderableListView(
      children: _list,
      onReorder: (int desde, int hasta) async {
        LP _lpAux;
        if (desde < hasta) {
          _lpAux = _listProdcutos[desde];
          _listProdcutos.removeAt(desde);
          _listProdcutos.insert(hasta - 1, _lpAux);
        } else {
          _lpAux = _listProdcutos[desde];
          _listProdcutos.removeAt(desde);
          _listProdcutos.insert(hasta, _lpAux);
        }
        if (mounted) setState(() {});
      },
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

  Widget _card(BuildContext context, LP lp) {
    return Slidable(
      key: ValueKey(lp.id),
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: ListTile(
        dense: true,
        trailing: Icon(Icons.menu),
        title: Text('${lp.d}'),
        subtitle: Text('\$ ${lp.p.toStringAsFixed(2)}'),
        onTap: () {},
      ),
      actions: <Widget>[],
      secondaryActions: <Widget>[
        IconSlideAction(
          color: Colors.red,
          caption: 'Eliminar',
          icon: Icons.delete,
          onTap: () {
            _listProdcutos.remove(lp);
            if (mounted) setState(() {});
          },
        ),
      ],
    );
  }
}
