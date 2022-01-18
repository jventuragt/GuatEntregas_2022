import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../bloc/direccion_bloc.dart';
import '../../dialog/mapa_dialog.dart';
import '../../model/agencia_model.dart';
import '../../providers/agencia_provider.dart';
import '../../providers/mapa_provider.dart';
import '../../providers/urbe_provider.dart';
import '../../utils/dialog.dart' as dlg;
import '../../utils/personalizacion.dart' as prs;
import '../../utils/utils.dart' as utils;
import '../admin/compras_cajero_page.dart';

//Solicita la ubicacion del pre registro de una agencia
class UbicacionPage extends StatefulWidget {
  final AgenciaModel agenciaModel;

  UbicacionPage({Key key, this.agenciaModel}) : super(key: key);

  @override
  State<UbicacionPage> createState() => UbicacionPageState(
        agenciaModel: agenciaModel,
      );
}

class UbicacionPageState extends State<UbicacionPage>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final MapaProvider _mapaProvider = MapaProvider();
  final AgenciaProvider _agenciaProvider = AgenciaProvider();
  final TextEditingController _typeAheadController = TextEditingController();
  bool _saving = false;
  final AgenciaModel agenciaModel;
  bool isLocalizado = true;
  final DireccionBloc _direccionBloc = DireccionBloc();

  UbicacionPageState({this.agenciaModel});

  final Set<Marker> _markers = Set<Marker>();

  Completer<GoogleMapController> _controller = Completer();
  CameraPosition _cameraPosition =
      CameraPosition(target: LatLng(14.3801, -90.3359), zoom: 16);

  @override
  void initState() {
    super.initState();
    _cameraPosition = CameraPosition(
        target: LatLng(agenciaModel.lt, agenciaModel.lg), zoom: 13);
    _moverCamaraMapa(_cameraPosition);
  }

  _llamar() async {
    String _call = 'tel:${agenciaModel.contacto}';
    if (await canLaunch(_call)) {
      await launch(_call);
    } else {
      throw 'Could not open the tel.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(agenciaModel.agencia),
        actions: [
          IconButton(
            icon: Icon(FontAwesomeIcons.phone, color: Colors.white),
            onPressed: _llamar,
          )
        ],
      ),
      body: ModalProgressHUD(
        inAsyncCall: _saving,
        child: _contenido(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          RawMaterialButton(
            onPressed: () {
              _confirmarUbicacion(context);
            },
            child: prs.iconoGuardarDireccion,
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: prs.colorButtonPrimary,
            padding: const EdgeInsets.all(15.0),
          ),
        ],
      ),
    );
  }

  Container _contenido() {
    return Container(
      child: Stack(
        children: <Widget>[
          GoogleMap(
            minMaxZoomPreference: MinMaxZoomPreference(6, 20),
            mapType: MapType.normal,
            initialCameraPosition: _cameraPosition,
            compassEnabled: true,
            myLocationEnabled: true,
            indoorViewEnabled: true,
            tiltGesturesEnabled: true,
            myLocationButtonEnabled: false,
            onCameraMove: (CameraPosition cameraPosition) {
              _typeAheadController.text = '';
              agenciaModel.lt = cameraPosition.target.latitude;
              agenciaModel.lg = cameraPosition.target.longitude;
            },
            markers: _markers,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),
          Center(child: prs.iconoLocationCentro),
          Container(
            margin: EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10)),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                      blurRadius: 20,
                      offset: Offset.zero,
                      color: Colors.grey.withOpacity(0.5))
                ]),
            child: Container(
              margin: EdgeInsets.only(left: 5.0, right: 5.0, bottom: 5.0),
              padding: EdgeInsets.all(1.0),
              color: Colors.white,
              child: createExpanPanel(context),
            ),
          ),
        ],
      ),
    );
  }

  _onSelectMapa(suggestion) {
    Navigator.pop(context);
    this._typeAheadController.text = suggestion['main'];
    _consultarPosision(
        suggestion['place_id'], suggestion['main'], suggestion['secondary']);
  }

  _mostrarDirecciones() async {
    if (_direccionBloc.direcciones.isEmpty) {
      utils.mostrarProgress(context, barrierDismissible: false);
      await _direccionBloc.listar();
      Navigator.pop(context);
    }
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return MapaDialog(_onSelectMapa, agenciaModel.lt, agenciaModel.lg);
        });
  }

  Widget createExpanPanel(BuildContext context) {
    return InkWell(
      onTap: _mostrarDirecciones,
      child: TextFormField(
        enabled: false,
        controller: this._typeAheadController,
        decoration: prs.decoration('Buscar aquí', prs.iconoBuscar),
      ),
    );
  }

  _consultarPosision(String placeId, String main, String secondary) async {
    FocusScope.of(context).requestFocus(FocusNode());
    utils.mostrarRadar(context);
    var local = await _mapaProvider.localizar(placeId, main, secondary);
    if (local.length > 0) {
      double lt = local['lat'];
      double lg = local['lng'];
      _cameraPosition = CameraPosition(target: LatLng(lt, lg), zoom: 18);
      _moverCamaraMapa(_cameraPosition);
    } else {
      utils.mostrarSnackBar(context, 'Lugar $main no localizada',
          milliseconds: 3000);
    }
    Navigator.pop(context);
  }

  final UrbeProvider _urbeProvider = UrbeProvider();

  _localizarUrbe(double lt, double lg) async {
    await _urbeProvider.localizar(lt, lg, (estado, urbe) {
      if (estado == 1) {
        agenciaModel.idUrbe = urbe.idUrbe;
      } else {
        agenciaModel.idUrbe = 0;
      }
      if (!mounted) return;
      if (mounted) setState(() {});
    });
    return;
  }

  void _confirmarUbicacion(context) async {
    _saving = true;
    if (mounted) setState(() {});
    await _localizarUrbe(agenciaModel.lt, agenciaModel.lg);
    _saving = false;
    if (mounted) setState(() {});

    if (agenciaModel.idUrbe <= 0)
      return utils.mostrarSnackBar(
          context, 'Lo sentimos no trabajamos en esta zona');

    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Registrar Agencia', textAlign: TextAlign.center),
            content: Text('${agenciaModel.agencia}'),
            actions: <Widget>[
              TextButton(
                child: Text('CANCELAR'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    primary: prs.colorButtonSecondary,
                    elevation: 2.0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0))),
                label: Text('REGISTRAR'),
                icon: Icon(
                  Icons.local_library,
                  size: 18.0,
                ),
                onPressed: _confirmarRegistro,
              ),
            ],
          );
        });
  }

  _confirmarRegistro() async {
    _saving = true;
    if (mounted) setState(() {});
    Navigator.of(context).pop();
    await _agenciaProvider.registrar(agenciaModel, (estado, error) {
      if (estado == 1) {
        void fAceptar() {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => ComprasCajeroPage()),
              (Route<dynamic> route) {
            return false;
          });
        }

        return dlg.mostrar(context, error, fIzquierda: fAceptar);
      } else {
        return dlg.mostrar(context, error);
      }
    });
    _saving = false;
    if (mounted) setState(() {});
  }

  Future<void> _moverCamaraMapa(_kLake) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
    agenciaModel.lt = _kLake.target.latitude;
    agenciaModel.lg = _kLake.target.longitude;
  }
}
