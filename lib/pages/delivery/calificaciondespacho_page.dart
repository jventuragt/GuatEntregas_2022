import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import '../../model/cliente_model.dart';
import '../../model/despacho_model.dart';
import '../../pages/admin/compras_cajero_page.dart';
import '../../preference/shared_preferences.dart';
import '../../providers/despacho_provider.dart';
import '../../utils/button.dart' as btn;
import '../../utils/conf.dart' as conf;
import '../../utils/personalizacion.dart' as prs;
import '../../utils/utils.dart' as utils;
import 'catalogo_page.dart';
import 'compras_despacho_page.dart';

class CalificaciondespachoPage extends StatefulWidget {
  final DespachoModel despachoModel;

  CalificaciondespachoPage({Key key, this.despachoModel}) : super(key: key);

  @override
  State<CalificaciondespachoPage> createState() =>
      _CalificaciondespachoPageState(despachoModel: despachoModel);
}

class _CalificaciondespachoPageState extends State<CalificaciondespachoPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final DespachoProvider _despachoProvider = DespachoProvider();
  DespachoModel despachoModel;
  int tipo;
  final PreferenciasUsuario _prefs = PreferenciasUsuario();

  _CalificaciondespachoPageState({this.despachoModel, this.tipo});

  ClienteModel cliente = ClienteModel();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Calificar despacho')),
      key: _scaffoldKey,
      body: ModalProgressHUD(
        inAsyncCall: _saving,
        child: Column(
          children: <Widget>[
            Expanded(child: SingleChildScrollView(child: _contenido())),
            btn.confirmar('CALIFICAR', _calificar)
          ],
        ),
      ),
    );
  }

  Widget _crearCosto() {
    double _costo = double.parse(despachoModel.costo.toString());
    return TextFormField(
      enabled: false,
      initialValue: _costo.toStringAsFixed(2),
      decoration:
          InputDecoration(labelText: 'Costo', suffixIcon: prs.iconoComprar),
    );
  }

  Widget _crearSucursal() {
    return TextFormField(
      enabled: false,
      initialValue: despachoModel.sucursalJson,
      decoration:
          InputDecoration(labelText: 'Sucursal', suffixIcon: prs.iconoSucursal),
    );
  }

  Widget _crearAsesor() {
    return TextFormField(
      enabled: false,
      initialValue: despachoModel.nombres,
      decoration: InputDecoration(
          labelText: tipo == conf.TIPO_CLIENTE ? 'Despachador' : 'Cliente',
          suffixIcon: prs.iconoNombres),
    );
  }

  Widget _detalle() {
    return Text(despachoModel.detalleJson);
  }

  Column _contenido() {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            children: <Widget>[
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 10.0),
                    Text(
                        'Solicitud ${despachoModel.idDespachoEstado == conf.DESPACHO_CANCELADA ? 'cancelada' : 'entregada'}',
                        style: TextStyle(fontSize: 24.0),
                        textAlign: TextAlign.center),
                    SizedBox(height: 10.0),
                    _estrellas(),
                    SizedBox(height: 5.0),
                    _crearComentario(),
                  ],
                ),
              ),
              Card(
                child: Container(
                  padding: EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      _crearSucursal(),
                      SizedBox(height: 5.0),
                      _crearAsesor(),
                      SizedBox(height: 5.0),
                      Text('Solicitud',
                          style: TextStyle(fontSize: 12.0, color: Colors.grey)),
                      SizedBox(height: 3.0),
                      _detalle(),
                      SizedBox(height: 5.0),
                      _crearCosto()
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _estrellas() {
    double _initialRating = (tipo == conf.TIPO_CLIENTE
        ? despachoModel.calificacionCliente
        : despachoModel.calificacionConductor);

    return utils.estrellas(_initialRating, (rating) {
      if (tipo == conf.CHAT_ENVIA_CLIENTE)
        despachoModel.calificacionCliente = rating;
      else
        despachoModel.calificacionConductor = rating;
    });
  }

  Widget _crearComentario() {
    return TextFormField(
      minLines: 3,
      maxLength: 180,
      textCapitalization: TextCapitalization.sentences,
      initialValue: (tipo == conf.TIPO_CLIENTE
          ? despachoModel.comentarioCliente
          : despachoModel.comentarioConductor),
      keyboardType: TextInputType.multiline,
      maxLines: null,
      decoration:
          InputDecoration(hintText: 'Comentario', labelText: 'Comentario'),
      onSaved: (value) {
        if (tipo == conf.TIPO_CLIENTE)
          despachoModel.comentarioCliente = value;
        else
          despachoModel.comentarioConductor = value;
      },
      validator: (value) {
        //if (value.length < 4) return 'Mínimo 4 caracteres';
        return null;
      },
    );
  }

  _calificar() {
    FocusScope.of(context).requestFocus(FocusNode());
    _saving = true;
    if (mounted) setState(() {});
    if (!_formKey.currentState.validate()) {
      _saving = false;
      if (mounted) setState(() {});
      return;
    }
    _formKey.currentState.save();
    _despachoProvider.calificar(despachoModel,
        (estado, error, DespachoModel despacho) {
      _saving = false;
      if (!mounted) return;
      if (mounted) setState(() {});
      if (estado == 0) return _mostrarSnackBar(error);
      if (_prefs.clienteModel.perfil.toString() ==
          conf.TIPO_CLIENTE.toString()) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => CatalogoPage()),
            (Route<dynamic> route) {
          return false;
        });
      } else if (_prefs.clienteModel.perfil.toString() ==
          conf.TIPO_ASESOR.toString()) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => ComprasCajeroPage()),
            (Route<dynamic> route) {
          return false;
        });
      } else {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => ComprasDespachoPage()),
            (Route<dynamic> route) {
          return false;
        });
      }
    });
  }

  void _mostrarSnackBar(String mensaje) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensaje)));
  }
}
