import 'dart:async';
import 'dart:typed_data';

import 'package:badges/badges.dart';
import 'package:blinking_point/blinking_point.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_touch_spin/flutter_touch_spin.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:share/share.dart';
import 'package:slider_button/slider_button.dart';
import 'package:solid_bottom_sheet/solid_bottom_sheet.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../bloc/cajero_bloc.dart';
import '../../bloc/compras_despacho_bloc.dart';
import '../../model/cajero_model.dart';
import '../../model/chat_compra_model.dart';
import '../../model/chat_despacho_model.dart';
import '../../model/cliente_model.dart';
import '../../model/despacho_model.dart';
import '../../preference/push_provider.dart';
import '../../preference/shared_preferences.dart';
import '../../providers/cajero_provider.dart';
import '../../providers/cliente_provider.dart';
import '../../providers/despacho_provider.dart';
import '../../sistema.dart';
import '../../utils/cache.dart' as cache;
import '../../utils/conexion.dart';
import '../../utils/conf.dart' as conf;
import '../../utils/decode.dart' as decode;
import '../../utils/dialog.dart' as dlg;
import '../../utils/marker.dart' as marker;
import '../../utils/personalizacion.dart' as prs;
import '../../utils/rastreo.dart';
import '../../utils/utils.dart' as utils;
import '../../widgets/icon_aument_widget.dart';
import 'calificacioncompra_page.dart';
import 'calificaciondespacho_page.dart';
import 'chat_despacho_page.dart';
import 'compras_despacho_page.dart';

class DespachoPage extends StatefulWidget {
  final DespachoModel despachoModel;
  final CajeroModel cajeroModel;
  final int tipo;

  DespachoPage(this.tipo, {Key key, this.despachoModel, this.cajeroModel})
      : super(key: key);

  @override
  State<DespachoPage> createState() => DespachoPageState(tipo,
      despachoModel: despachoModel, cajeroModel: cajeroModel);
}

class DespachoPageState extends State<DespachoPage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  DespachoModel despachoModel;
  CajeroModel cajeroModel;
  final PreferenciasUsuario _prefs = PreferenciasUsuario();

  final DespachoProvider _despachoProvider = DespachoProvider();
  final PushProvider _pushProvider = PushProvider();
  final _clienteProvider = ClienteProvider();
  final navigatorKey = GlobalKey<NavigatorState>();
  final _cajeroProvider = CajeroProvider();
  final ComprasDespachoBloc _comprasDespachoBloc = ComprasDespachoBloc();
  String preparandose = '15';
  final int tipoNotificacionPreparacion = 1;
  final int tipoNotificacionFuera = 2;

  DespachoPageState(this.tipo, {this.despachoModel, this.cajeroModel});

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _rastrear = false;
  bool _saving = false;
  String _mensajeProgreso = 'Cargando...';
  final int tipo;

  Completer<GoogleMapController> _controller = Completer();

  double _zoom = 18.0, lt = 0.0, lg = 0.0;

  CameraPosition _cameraPosition;

  final Set<Marker> _markers = Set<Marker>();

  Marker markerPool =
      Marker(position: LatLng(0.0, 0.0), markerId: MarkerId('POOL'));

  Marker markerDesde =
      Marker(position: LatLng(0.0, 0.0), markerId: MarkerId('DESDE'));

  Marker markerHasta =
      Marker(position: LatLng(0.0, 0.0), markerId: MarkerId('HASTA'));

  bool _cargando = true;

  Set<Polyline> _polyline = {};
  final Conexion _conexion = Conexion();
  final CajeroBloc _cajeroBloc = CajeroBloc();

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    //Descartamos pues el despacho viene con todos los datos cuando es desde el despachador
    _cameraPosition = CameraPosition(
        target: LatLng(despachoModel.ltA, despachoModel.lgA), zoom: 18.0);
    _conexion.stream.listen(_rastrearVehiculo);
    _markers.add(markerPool);
    _initUbicar();
    super.initState();
    _pushProvider.chatsCompra.listen((ChatCompraModel chatCompra) {
      if (!mounted) return;
      if (cajeroModel.idCompra == chatCompra.idCompra) {
        if (chatCompra.idCompraEstado == conf.COMPRA_CANCELADA) {
          cajeroModel.idCompraEstado = chatCompra.idCompraEstado;
          cajeroModel.calificarCliente = 1;
          cajeroModel.calificarCajero = 1;
          _cajeroBloc.actualizarPorCajero(cajeroModel);
          _irAcalificar();
        }
      }
    });

    _pushProvider.chatsDespacho.listen((ChatDespachoModel chatDespacho) {
      if (!mounted) return;

      if (despachoModel.idDespacho.toString() !=
          chatDespacho.idDespacho.toString()) return;
      despachoModel.sinLeerCliente += 1;
      despachoModel.sinLeerConductor += 1;
      if (chatDespacho.idDespachoEstado == conf.DESPACHO_ENTREGADO) {
        despachoModel.idDespachoEstado = conf.DESPACHO_ENTREGADO;
        cajeroModel.idCompraEstado = conf.COMPRA_ENTREGADA;
        cajeroModel.calificarCliente = 1;
        _cajeroBloc.actualizarPorCajero(cajeroModel);
        _irAcalificar();
      } else if (chatDespacho.idDespachoEstado == conf.DESPACHO_CANCELADA) {
        _irAcalificar();
      } else if (despachoModel.idDespachoEstado !=
          chatDespacho.idDespachoEstado) {
        _ver();
      }
      despachoModel.idDespachoEstado = chatDespacho.idDespachoEstado;
      if (mounted) setState(() {});
    });

    _pushProvider.objects.listen((despacho) {
      if (!mounted) return;
      DespachoModel _despacho = despacho;
      if (cajeroModel.idCompra.toString() == _despacho.idCompra.toString()) {
        despachoModel = despacho;
        cajeroModel.idDespacho = despachoModel.idDespacho;
        _cajeroBloc.actualizarPorDespacho(despacho, conf.COMPRA_DESPACHADA);
        _cargando = false;
        if (mounted) setState(() {});
        _ver();
      }
    });
    _ver();
  }

  _escucharRastreo(dynamic idRastreo) {
    if (tipo == conf.TIPO_CONDCUTOR) return;
    if (despachoModel.idDespachoEstado <= conf.DESPACHO_RECOGIDO) {
      if (idRastreo != null) _clienteProvider.escuchar(idRastreo);
    } else {
      //Nos desuscribimos
      _clienteProvider.escuchar(0);
    }
  }

  _ver() async {
    DespachoModel despacho;
    despacho = await _despachoProvider.ver(cajeroModel.idDespacho, tipo);
    if (tipo != conf.TIPO_CONDCUTOR)
      cajeroModel = await _cajeroProvider.ver(despacho.idCompra);
    if (despacho == null) return;
    despachoModel = despacho;
    _escucharRastreo(despachoModel.idConductor);
    _cargando = false;
    _ubiarVehiculo(despachoModel.lt, despachoModel.lg);
    _initUbicar();
    _irAcalificar();
  }

  _irAcalificar() {
    if (tipo == conf.TIPO_CONDCUTOR) {
      if (despachoModel.calificarConductor == 1 ||
          ((despachoModel.idDespachoEstado == conf.DESPACHO_ENTREGADO ||
                  despachoModel.idDespachoEstado == conf.DESPACHO_CANCELADA) &&
              despachoModel.calificarConductor <= 1)) {
        return _naverACalificar();
      }
    } else if (tipo == conf.TIPO_CLIENTE) {
      if (cajeroModel.calificarCliente == 1 ||
          ((cajeroModel.idCompraEstado == conf.COMPRA_CANCELADA ||
                  cajeroModel.idCompraEstado == conf.COMPRA_ENTREGADA) &&
              cajeroModel.calificarCliente <= 1)) {
        return _naverACalificar();
      }
    } else if (tipo == conf.TIPO_ASESOR) {
      if (cajeroModel.calificarCajero == 1 ||
          ((cajeroModel.idCompraEstado == conf.COMPRA_CANCELADA ||
                  cajeroModel.idCompraEstado == conf.COMPRA_ENTREGADA) &&
              cajeroModel.calificarCajero <= 1)) {
        return _naverACalificar();
      }
    }
  }

  _naverACalificar() {
    if (tipo == conf.TIPO_CONDCUTOR) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) =>
                  CalificaciondespachoPage(despachoModel: despachoModel)),
          (Route<dynamic> route) {
        return route.isFirst;
      });
    } else {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) =>
                  CalificacioncompraPage(cajeroModel: cajeroModel, tipo: tipo)),
          (Route<dynamic> route) {
        return route.isFirst;
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _ver();
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        break;
      default:
        break;
    }
  }

  void _cancelar() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          title: Text('CANCELAR COMPRA'),
          content: SingleChildScrollView(
              child: Center(
            child: Text('¿Seguro deseas cancelar la compra?',
                style: TextStyle(fontSize: 20)),
          )),
          actions: <Widget>[
            TextButton(
              child: Text('NO, REGRESAR'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  primary: prs.colorButtonSecondary,
                  elevation: 2.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0))),
              label: Text('SI, CANCELAR'),
              icon: Icon(Icons.cancel, size: 18.0),
              onPressed: () {
                _enviarCancelar();
              },
            ),
          ],
        );
      },
    );
  }

  void _enviarCancelar() async {
    Navigator.pop(context);
    _saving = true;
    if (mounted) setState(() {});

    int _chatEnvia = conf.CHAT_ENVIA_CAJERO;
    var route;
    if (tipo == conf.TIPO_CLIENTE) {
      _chatEnvia = conf.CHAT_ENVIA_CLIENTE;
      cajeroModel.idCompraEstado = conf.COMPRA_CANCELADA;
      route = CalificacioncompraPage(cajeroModel: cajeroModel, tipo: tipo);
      CajeroModel cajero = await _cajeroProvider.cancelar(
          cajeroModel, cajeroModel.idCliente, cajeroModel.idCajero, _chatEnvia);
      cajeroModel = cajero;
      cajeroModel.calificarCajero = 1;
    } else {
      despachoModel.idDespachoEstado = conf.DESPACHO_CANCELADA;
      route = CalificaciondespachoPage(despachoModel: despachoModel);
      await _despachoProvider.cancelar(despachoModel, despachoModel.idCliente,
          despachoModel.idConductor, tipo);
    }

    _saving = false;

    Navigator.push(context, MaterialPageRoute(builder: (context) => route));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('${despachoModel.estado}'),
        actions: <Widget>[
          tipo != conf.TIPO_ASESOR &&
                  despachoModel.idDespachoEstado > 0 &&
                  despachoModel.idDespachoEstado <= conf.DESPACHO_ASIGNADO &&
                  despachoModel.preparandose <= 0
              ? IconButton(
                  icon: Icon(FontAwesomeIcons.times, size: 26.0),
                  onPressed: _cancelar,
                )
              : Container(),
          (tipo == conf.TIPO_ASESOR)
              ? IconButton(
                  icon: Icon(FontAwesomeIcons.shareAlt, size: 26.0),
                  onPressed: _irRutaGoogleMaps,
                )
              : Container(),
          tipo == conf.TIPO_CONDCUTOR &&
                  despachoModel.idDespachoEstado == conf.DESPACHO_ASIGNADO
              ? ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      primary: Colors.white10, onPrimary: Colors.white),
                  label: Text('P.  RECOGIDA'),
                  icon: cache.fadeImage('assets/pool/ingreso_0.png',
                      height: 40.0),
                  onPressed: _irPuntoRecogida,
                )
              : Container(),
          tipo == conf.TIPO_CONDCUTOR &&
                  despachoModel.idDespachoEstado == conf.DESPACHO_RECOGIDO
              ? ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      primary: Colors.white10, onPrimary: Colors.white),
                  label: Text('P.  ENTREGA'),
                  icon:
                      cache.fadeImage('assets/pool/salida_0.png', height: 40.0),
                  onPressed: _irPuntoEntrega,
                )
              : Container(),
          tipo == conf.TIPO_CONDCUTOR &&
                  despachoModel.idDespachoEstado == conf.DESPACHO_ENTREGADO
              ? ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      primary: Colors.white10, onPrimary: Colors.white),
                  label: Text('REVERSAR'),
                  icon: Icon(Icons.undo_sharp, size: 32.0),
                  onPressed: _reversar,
                )
              : Container(),
        ],
      ),
      body: SafeArea(
        child: ModalProgressHUD(
          color: Colors.black,
          opacity: 0.4,
          progressIndicator: utils.progressIndicator(_mensajeProgreso),
          inAsyncCall: _saving,
          child: _contenido(),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: GestureDetector(
        onVerticalDragEnd: _onVerticalDragEnd,
        onVerticalDragUpdate: _onVerticalDragUpdate,
        child: _avatar(),
      ),
      bottomSheet: SolidBottomSheet(
        canUserSwipe: true,
        autoSwiped: true,
        draggableBody: true,
        showOnAppear: _estadoAvatar,
        controller: _solidController,
        onShow: () {
          _estadoAvatar = true;
        },
        onHide: () {
          _estadoAvatar = false;
        },
        maxHeight: 200.0,
        headerBar: _floatingActionButtonPool(),
        body: _contenidoPool(),
      ),
    );
  }

  _reversar() {
    dlg.mostrar(context,
        'Esta acción conlleva una sanción económica.\n\nPermitiendo obtener los datos del cliente al regresar el despacho al estado recogido.',
        mBotonDerecha: 'REVERSAR',
        mIzquierda: ' CANCELAR ',
        fIzquierda: _cancelarReversar,
        icon: Icons.undo_sharp,
        fBotonIDerecha: _confirarReversar);
  }

  _confirarReversar() async {
    Navigator.pop(context);
    _saving = true;
    if (mounted) setState(() {});
    despachoModel = await _despachoProvider.reversar(despachoModel);
    _saving = false;
    if (mounted) setState(() {});
  }

  _cancelarReversar() {
    Navigator.pop(context);
  }

  void _onVerticalDragUpdate(data) {
    if (((_solidController.height - data.delta.dy) > 0) &&
        ((_solidController.height - data.delta.dy) < 135)) {
      _solidController.height -= data.delta.dy;
    }
  }

  void _onVerticalDragEnd(data) {
    _solidController.isOpened
        ? _solidController.hide()
        : _solidController.show();
  }

  Widget _floatingActionButtonPool() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
        color: prs.colorIcons,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Expanded(child: _botonChat()),
          Spacer(flex: 1),
          Expanded(child: _botonLlamar())
        ],
      ),
    );
  }

  Widget _botonChat() {
    if (despachoModel.idConductor == null ||
        despachoModel.idDespacho <= 0 ||
        despachoModel.idDespachoEstado >= conf.DESPACHO_ENTREGADO ||
        tipo == conf.TIPO_ASESOR) return Container(height: 40.0);

    int sinLeer =
        despachoModel.idConductor.toString() == _prefs.idCliente.toString()
            ? despachoModel.sinLeerConductor
            : despachoModel.sinLeerCliente;

    Widget _sinLeer = Badge(
      position: BadgePosition.topEnd(end: 1),
      badgeColor: Colors.red,
      badgeContent: Text('$sinLeer', style: TextStyle(color: Colors.white)),
      child: IconButton(icon: prs.iconoChatActivo, onPressed: null),
    );

    return RawMaterialButton(
      onPressed: () {
        _chat(despachoModel, null);
      },
      child: (sinLeer > 0 ? _sinLeer : prs.iconoChat),
      shape: CircleBorder(),
      fillColor: prs.colorButtonBackground,
    );
  }

  Widget _botonLlamar() {
    if (tipo == conf.TIPO_CLIENTE ||
        despachoModel.idDespachoEstado >= conf.DESPACHO_ENTREGADO)
      return Container();

    if (despachoModel.correctos > 0)
      return RawMaterialButton(
        onPressed: _llamar,
        child: prs.iconoLlamar,
        shape: CircleBorder(),
        fillColor: prs.colorButtonBackground,
      );

    return RawMaterialButton(
      onPressed: _llamar,
      shape: CircleBorder(),
      child: IconAumentWidget(
        Icon(FontAwesomeIcons.phoneSlash, size: 40.0, color: Colors.red),
        size: 40.0,
      ),
      fillColor: prs.colorButtonBackground,
    );
  }

  _llamar() async {
    String _call = 'tel:${despachoModel.celular}';
    if (await canLaunch(_call)) {
      await launch(_call);
    } else {
      throw 'Could not open the tel.';
    }
  }

  bool _estadoAvatar = true;
  final SolidController _solidController = new SolidController();

  Widget _contenidoPool() {
    return Container(
      color: Colors.white30,
      padding: EdgeInsets.only(left: 30.0, top: 10.0, right: 5.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                despachoModel.iconoFormaPago(),
                Expanded(child: Container()),
                Text(
                  '${(despachoModel.costoProducto).toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 16.0, color: prs.colorIcons),
                ),
                SizedBox(width: 10),
                Icon(FontAwesomeIcons.cartPlus,
                    size: 19.0, color: prs.colorIcons),
                SizedBox(width: 20),
                Text(
                  '${(despachoModel.costoEnvio).toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 16.0, color: prs.colorIcons),
                ),
                SizedBox(width: 10),
                Icon(FontAwesomeIcons.peopleCarry,
                    size: 20, color: prs.colorIcons),
                SizedBox(width: 30),
              ],
            ),
            SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text(
                  '${(despachoModel.costo).toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 16.0, color: prs.colorIcons),
                ),
                SizedBox(width: 10),
                Icon(FontAwesomeIcons.dollarSign,
                    size: 20.0, color: prs.colorIcons),
                SizedBox(width: 30),
              ],
            ),
            SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text(
                  'En efectivo: ${despachoModel.efectivoTotal()}',
                  style: TextStyle(fontSize: 17.0, color: prs.colorIcons),
                ),
                SizedBox(width: 10),
                Icon(FontAwesomeIcons.moneyBillWave,
                    size: 20.0, color: prs.colorIcons),
                SizedBox(width: 30),
              ],
            ),
            Text('Detalle:',
                style: TextStyle(color: prs.colorIcons),
                overflow: TextOverflow.ellipsis),
            SizedBox(height: 4.0),
            Text('${cajeroModel.detalle}',
                maxLines: 30,
                style: TextStyle(color: prs.colorTextDescription),
                overflow: TextOverflow.ellipsis),
            SizedBox(height: 3.0),
            Text('Referencia:',
                style: TextStyle(color: prs.colorIcons),
                overflow: TextOverflow.ellipsis),
            SizedBox(height: 4.0),
            Text('${cajeroModel.referencia}',
                maxLines: 3,
                style: TextStyle(color: prs.colorTextDescription),
                overflow: TextOverflow.ellipsis),
            SizedBox(height: 40.0),
            _crearIdentificacion(),
            SizedBox(height: 10.0),
          ],
        ),
      ),
    );
  }

  Widget _crearIdentificacion() {
    if (despachoModel.idDespachoEstado >= conf.DESPACHO_ENTREGADO &&
        Sistema.idAplicativo == Sistema.idAplicativoCuriosity) {
      String identificacion =
          '${utils.generateMd5(('${despachoModel.idCompra}.J-P.${despachoModel.idDespacho}'))}';
      return TextFormField(
        readOnly: true,
        initialValue: identificacion,
        decoration: InputDecoration(
          suffixIcon: IconButton(
            icon: Icon(FontAwesomeIcons.whatsapp),
            onPressed: () async {
              _notificar(
                  '${despachoModel.idCompra}-$identificacion-${despachoModel.idDespacho}');
            },
          ),
          hintText: 'Identificación',
          labelText: 'Identificación',
        ),
      );
    }
    return Container();
  }

  _notificar(String identificacion) async {
    try {
      String url =
          'https://api.whatsapp.com/send?phone=593968424853&text=Hola, mi identificación es: $identificacion. ';
      var encoded = Uri.encodeFull(url);
      if (await canLaunch(encoded)) {
        await launch(encoded);
      } else {
        print('Could not open the url.');
      }
    } catch (err) {
      print(err);
    }
  }

  _rastrearVehiculo(data) async {
    if (!mounted) return;
    double lt = double.parse(data['lt'].toString());
    double lg = double.parse(data['lg'].toString());
    _ubiarVehiculo(lt, lg);
  }

  _ubiarVehiculo(double lt, double lg) async {
    if (despachoModel.idDespachoEstado == conf.DESPACHO_RECOGIDO ||
        despachoModel.idDespachoEstado == conf.DESPACHO_ASIGNADO) {
      _markers.remove(markerPool);
      final Uint8List salida = await marker.getBytesFromCanvas(
          "assets/pool/car.png", cajeroModel.acronimo);
      var imagSalida = BitmapDescriptor.fromBytes(salida);
      markerPool = Marker(
          icon: imagSalida,
          position: LatLng(lt, lg),
          markerId: MarkerId('POOL'));
      if (_rastrear) {
        _cameraPosition = CameraPosition(target: LatLng(lt, lg), zoom: _zoom);
        _moverCamaraMapa(_cameraPosition);
      }
      _markers.add(markerPool);
      if (!mounted) return;
      if (mounted) setState(() {});
    }
  }

  Widget _avatar() {
    Widget _avatar = CircularPercentIndicator(
      radius: 65.0,
      lineWidth: 3.0,
      animation: true,
      percent: 1.0,
      center: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(60)),
        child: Container(
          color: Colors.white,
          child: cache.fadeImage(despachoModel.img,
              width: 60, height: 60, acronimo: despachoModel.acronimo),
        ),
      ),
      circularStrokeCap: CircularStrokeCap.round,
      progressColor: Colors.purple,
    );
    return Stack(
      children: <Widget>[
        _avatar,
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
                borderRadius: BorderRadius.all(Radius.circular(60)),
                splashColor: Colors.blueAccent.withOpacity(0.6),
                onTap: () async {
                  if (_solidController.isOpened) return _solidController.hide();
                  _solidController.show();
                }),
          ),
        ),
      ],
    );
  }

  Widget _avatarInfo() {
    Widget _avatar = Container(
      width: 60,
      height: 60,
      margin: EdgeInsets.only(left: 10),
      child: ClipOval(
        child: cache.fadeImage(despachoModel.img,
            width: 70, height: 70, acronimo: despachoModel.acronimo),
      ),
    );
    return Stack(
      children: <Widget>[
        _avatar,
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
                borderRadius: BorderRadius.all(Radius.circular(110)),
                splashColor: Colors.blueAccent.withOpacity(0.6),
                onTap: () async {
                  final GoogleMapController controller =
                      await _controller.future;
                  controller.animateCamera(CameraUpdate.newLatLngBounds(
                      despachoModel.latLngBounds, 150.0));
                }),
          ),
        )
      ],
    );
  }

  Widget _infoPool() {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        margin: EdgeInsets.all(20),
        height: 70,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(50)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                  blurRadius: 20,
                  offset: Offset.zero,
                  color: Colors.grey.withOpacity(0.5))
            ]),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _avatarInfo(),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(left: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('${despachoModel.label}'),
                    Text('${despachoModel.estado}')
                  ],
                ),
              ),
            ),
            tipo == conf.TIPO_CLIENTE || despachoModel.idDespacho <= 0
                ? Container()
                : _botonDespachador(),
          ],
        ),
      ),
    );
  }

  Widget _botonDespachador() {
    if (cajeroModel.idCompraEstado == conf.COMPRA_CANCELADA ||
        cajeroModel.idCompraEstado == conf.COMPRA_ENTREGADA) return Container();

    if (tipo == conf.TIPO_ASESOR &&
        despachoModel.idDespachoEstado >= conf.DESPACHO_ASIGNADO) {
      Icon icon = Icon(FontAwesomeIcons.hands, color: Colors.white);
      return Container(
        width: 80.0,
        child: RawMaterialButton(
          padding:
              EdgeInsets.only(left: 10.0, top: 15.0, bottom: 15.0, right: 15.0),
          onPressed: () {},
          child: icon,
          shape: CircleBorder(),
          fillColor: Colors.teal,
        ),
      );
    }

    if (despachoModel.idDespachoEstado == conf.DESPACHO_ASIGNADO)
      return Container(
        width: 80.0,
        child: RawMaterialButton(
          padding:
              EdgeInsets.only(left: 10.0, top: 15.0, bottom: 15.0, right: 15.0),
          onPressed: _confirmarRecogidaDesdeConductor,
          child: prs.iconoRecoger,
          shape: CircleBorder(),
          fillColor: Colors.teal,
        ),
      );
    if (despachoModel.idDespachoEstado == conf.DESPACHO_RECOGIDO)
      return Container(
        width: 80.0,
        child: RawMaterialButton(
          padding:
              EdgeInsets.only(left: 10.0, top: 15.0, bottom: 15.0, right: 15.0),
          onPressed: _confirmarEntrega,
          child: prs.iconoDespachador,
          shape: CircleBorder(),
          fillColor: prs.colorButtonSecondary,
        ),
      );
    return Container();
  }

  void _confirmarRecogidaDesdeConductor() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            contentPadding: EdgeInsets.all(0.0),
            title: Text('RECOGER PEDIDO', textAlign: TextAlign.center),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 20.0),
                Padding(
                  padding: EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Text('${despachoModel.detalleJson}'),
                ),
                SizedBox(height: 10.0),
                _contenidoDialog(),
              ],
            ),
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
                  label: Text('CONFIRMAR'),
                  icon: Icon(FontAwesomeIcons.hands, size: 18.0),
                  onPressed: _enviarConfirmarRecogida),
            ],
          );
        });
  }

  _enviarConfirmarRecogida() async {
    Navigator.pop(context);
    _saving = true;
    _mensajeProgreso = 'Notificando...';
    if (mounted) setState(() {});
    Rastreo().notificarUbicacion();
    DespachoModel _despacho = await _despachoProvider.confirmarRecogida(
        despachoModel,
        despachoModel.idCliente,
        despachoModel.idConductor,
        conf.CHAT_ENVIA_CAJERO);
    despachoModel = _despacho;
    _saving = false;
    if (!mounted) return;
    if (mounted) setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.green,
      content: Text(
        'En hora buena. Se notificó que has recogido el pedido.',
        style: TextStyle(color: Colors.white),
      ),
    ));
  }

  void _confirmarEntrega() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            contentPadding: EdgeInsets.all(0.0),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 20.0),
                Padding(
                  padding: EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Text('${despachoModel.detalleJson}'),
                ),
                SizedBox(height: 10.0),
                _contenidoDialog(),
                SizedBox(height: 5.0),
                utils.estrellas(
                    (tipo == conf.TIPO_CLIENTE
                        ? despachoModel.calificacionCliente
                        : despachoModel.calificacionConductor), (rating) {
                  if (tipo == conf.TIPO_CLIENTE)
                    despachoModel.calificacionCliente = rating;
                  else
                    despachoModel.calificacionConductor = rating;
                }),
              ],
            ),
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
                label: Text('CONFIRMAR'),
                icon: Icon(
                  FontAwesomeIcons.peopleCarry,
                  size: 18.0,
                ),
                onPressed: _enviarConfirmarEntrega,
              ),
            ],
          );
        });
  }

  Widget _contenidoDialog() {
    return DataTable(
      showCheckboxColumn: false,
      columnSpacing: 10.0,
      headingRowHeight: 0.0,
      columns: [
        DataColumn(
          label: Text(''),
          numeric: false,
        ),
        DataColumn(
          label: Text(''),
          numeric: true,
        ),
      ],
      rows: [
        // DataRow(cells: [
        //   DataCell(Text('Productos')),
        //   DataCell(Text('${(despachoModel.costoProducto).toStringAsFixed(2)}')),
        // ]),
        // DataRow(cells: [
        //   DataCell(Text('Envío')),
        //   DataCell(Text('${(despachoModel.costoEnvio).toStringAsFixed(2)}')),
        // ]),
        DataRow(cells: [
          DataCell(Text('Forma de pago')),
          DataCell(Text(
            despachoModel.formaPago,
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          )),
        ]),
        DataRow(cells: [
          DataCell(Text('Efectivo productos')),
          DataCell(Text(
            '${despachoModel.efectivoProdcuto()}',
            style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold),
          )),
        ]),
        DataRow(cells: [
          DataCell(Text('Efectivo envío')),
          DataCell(Text(
            '${despachoModel.efectivoEnvio()}',
            style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold),
          )),
        ]),
        DataRow(cells: [
          DataCell(Text('Total efectivo')),
          DataCell(Text(
            '${despachoModel.efectivoTotal()}',
            style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold),
          )),
        ]),
      ],
    );
  }

  _enviarConfirmarEntrega() async {
    Navigator.pop(context);
    _saving = true;
    _mensajeProgreso = 'Notificando...';
    if (mounted) setState(() {});
    Rastreo().notificarUbicacion();
    await _despachoProvider.entregarProducto(despachoModel);
    _saving = false;
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => ComprasDespachoPage()),
        (Route<dynamic> route) {
      return false;
    });
  }

  _irRutaGoogleMaps() async {
    var ubucacionSucursal =
        'https://www.google.com/maps/dir//${cajeroModel.lt},${cajeroModel.lg}/@${cajeroModel.lt},${cajeroModel.lg},17.82z/';

    var ubucacionCliente =
        'https://www.google.com/maps/dir//${cajeroModel.ltB},${cajeroModel.lgB}/@${cajeroModel.ltB},${cajeroModel.lgB},17.82z/';

    Share.share(
        '*Nueva Compra*  \nSucursal ${cajeroModel.sucursal}: \n$ubucacionSucursal \nCliente ${cajeroModel.nombres}: \n$ubucacionCliente \n*Contacto:* ${cajeroModel.celular} \n*Costo total:* ${cajeroModel.costo} \n*Pedido:* ${cajeroModel.detalle} \n*Referencia:* ${cajeroModel.referencia}');
  }

  _initUbicar() async {
    _markers.remove(markerDesde);

    if (despachoModel.tipo != conf.COMPRA_TIPO_COMPRA) {
      final Uint8List ingreso = await marker.getBytesFromCanvas(
          "assets/pool/ingreso_0.png", cajeroModel.acronimoSucursal);
      var imagIngreso = BitmapDescriptor.fromBytes(ingreso);

      markerDesde = Marker(
          infoWindow: InfoWindow(
              title: '${cajeroModel.sucursal}', onTap: _irPuntoRecogida),
          markerId: MarkerId(despachoModel.ltA.toString()),
          icon: imagIngreso,
          position: LatLng(despachoModel.ltA, despachoModel.lgA));
      _markers.add(markerDesde);
    }

    _markers.remove(markerHasta);
    if (tipo == conf.TIPO_CLIENTE) {
      ClienteModel _clienteModel = _prefs.clienteModel;
      final Uint8List salida = await marker.getBytesFromCanvas(
          "assets/pool/salida_0.png", _clienteModel.acronimo);
      var imagSalida = BitmapDescriptor.fromBytes(salida);
      markerHasta = Marker(
          onTap: () {},
          infoWindow: InfoWindow(title: '${_clienteModel.nombres}'),
          markerId: MarkerId(despachoModel.lgA.toString()),
          icon: imagSalida,
          position: LatLng(despachoModel.ltB, despachoModel.lgB));
    } else {
      if (despachoModel.idDespachoEstado < conf.DESPACHO_ENTREGADO) {
        if (despachoModel.tipo == conf.COMPRA_TIPO_TARIFARIO) {
          circles = Set.from([
            Circle(
              circleId: CircleId('2'),
              center: LatLng(despachoModel.ltB, despachoModel.lgB),
              radius: 850.0,
              fillColor: Colors.blue.withOpacity(0.4),
              strokeWidth: 2,
              strokeColor: prs.colorButtonSecondary,
            )
          ]);
        } else if (despachoModel.tipo == conf.COMPRA_TIPO_MULTIPLE) {
          circles = Set.from([
            Circle(
              circleId: CircleId('2'),
              center: LatLng(despachoModel.ltB, despachoModel.lgB),
              radius: 5350.0,
              fillColor: Colors.blue.withOpacity(0.15),
              strokeWidth: 2,
              strokeColor: prs.colorButtonSecondary,
            )
          ]);
        } else {
          final Uint8List salida = await marker.getBytesFromCanvas(
              "assets/pool/salida_0.png", cajeroModel.acronimo);
          var imagSalida = BitmapDescriptor.fromBytes(salida);

          markerHasta = Marker(
              infoWindow: InfoWindow(
                  title: '${cajeroModel.nombres}', onTap: _irPuntoEntrega),
              markerId: MarkerId(despachoModel.lgA.toString()),
              icon: imagSalida,
              position: LatLng(despachoModel.ltB, despachoModel.lgB));
        }
      } else {
        circles = Set.from([
          Circle(
            circleId: CircleId('1'),
            center: LatLng(despachoModel.ltA, despachoModel.lgA),
            radius: decode.getKilometros(despachoModel.ltA, despachoModel.lgA,
                despachoModel.ltB, despachoModel.lgB),
            fillColor: Colors.blueAccent.withOpacity(0.1),
            strokeWidth: 1,
            strokeColor: prs.colorButtonSecondary,
          )
        ]);
      }
    }

    _markers.add(markerHasta);

    Future.delayed(const Duration(milliseconds: 900), () async {
      final GoogleMapController controller = await _controller.future;
      if (!mounted) return;
      controller.animateCamera(
          CameraUpdate.newLatLngBounds(despachoModel.latLngBounds, 150.0));
    });
    if (!mounted) return;
    if (mounted) setState(() {});
  }

  Set<Circle> circles = Set.from([]);

  _chat(poolModel, rutaModel) {
    if (tipo == conf.TIPO_ASESOR || despachoModel.idDespacho <= 0) return;

    despachoModel.sinLeerCliente = 0;
    despachoModel.sinLeerConductor = 0;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatDespachoPage(despachoModel: despachoModel),
      ),
    );
  }

  _irPuntoEntrega() async {
    var ubucacion =
        'https://www.google.com/maps/dir//${despachoModel.ltB},${despachoModel.lgB}/@${despachoModel.ltB},${despachoModel.lgB},17.82z/';
    if (await canLaunch(ubucacion)) {
      await launch(ubucacion);
    } else {
      throw 'Could not open the map.';
    }
  }

  _irPuntoRecogida() async {
    if (despachoModel.tipo == conf.COMPRA_TIPO_COMPRA)
      return dlg.mostrar(
          context, 'No especificado\n\n ${despachoModel.detalleJson}');
    var ubucacion =
        'https://www.google.com/maps/dir//${despachoModel.ltA},${despachoModel.lgA}/@${despachoModel.ltA},${despachoModel.lgA},17.82z/';
    if (await canLaunch(ubucacion)) {
      await launch(ubucacion);
    } else {
      throw 'Could not open the map.';
    }
  }

  Container _contenido() {
    return Container(
      child: Stack(
        children: <Widget>[
          GoogleMap(
            mapType: MapType.normal,
            minMaxZoomPreference: MinMaxZoomPreference(6, 20),
            compassEnabled: true,
            myLocationEnabled: true,
            indoorViewEnabled: true,
            tiltGesturesEnabled: true,
            myLocationButtonEnabled: false,
            initialCameraPosition: _cameraPosition,
            onCameraMove: (CameraPosition cameraPosition) {
              lt = cameraPosition.target.latitude;
              lg = cameraPosition.target.longitude;
              _zoom = cameraPosition.zoom;
            },
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            circles: circles,
            markers: _markers,
            polylines: _polyline,
          ),
          Visibility(
              visible: tipo == conf.TIPO_CONDCUTOR &&
                  despachoModel.tipo != conf.COMPRA_TIPO_COMPRA,
              child: Positioned(
                top: 110.0,
                right: 25.0,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      primary: despachoModel.tipo == conf.COMPRA_TIPO_ENCOMIENDA
                          ? Colors.green
                          : prs.colorButtonSecondary,
                      elevation: 2.0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0))),
                  label: Icon(
                      despachoModel.tipo == conf.COMPRA_TIPO_ENCOMIENDA
                          ? FontAwesomeIcons.peopleCarry
                          : FontAwesomeIcons.store,
                      size: 27.0),
                  icon: Icon(FontAwesomeIcons.phoneAlt, size: 27.0),
                  onPressed: _llamarLocal,
                ),
              )),
          Visibility(
              visible: tipo == conf.TIPO_CONDCUTOR &&
                  despachoModel.tipo == conf.COMPRA_TIPO_CATALOGO,
              child: Positioned(
                top: 190.0,
                right: 25.0,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      primary: despachoModel.tipo == conf.COMPRA_TIPO_ENCOMIENDA
                          ? Colors.green
                          : prs.colorButtonSecondary,
                      elevation: 2.0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0))),
                  label: Icon(FontAwesomeIcons.store, size: 27.0),
                  icon: Icon(FontAwesomeIcons.whatsapp, size: 27.0),
                  onPressed: () async {
                    String url =
                        'https://api.whatsapp.com/send?phone=${despachoModel.telSuc.toString().replaceAll('+', '')}&text=Hola de ${Sistema.aplicativoTitle} un pedido de: ${cajeroModel.detalle}';
                    var encoded = Uri.encodeFull(url);
                    if (await canLaunch(encoded)) {
                      await launch(encoded);
                    } else {
                      print('Could not open the url.');
                    }
                  },
                ),
              )),
          Visibility(
              visible: _cargando && tipo != conf.TIPO_CONDCUTOR,
              child: LinearProgressIndicator(
                  backgroundColor: prs.colorLinearProgress)),
          _infoPool(),
          _buscando(),
          _productoPreparandose(),
          _enLugar(),
        ],
      ),
    );
  }

  Widget _enLugar() {
    //Si no se carga el despacho o ya se dio tiempo de preparacion no se muestra
    if (despachoModel == null ||
        tipo != conf.TIPO_CONDCUTOR ||
        despachoModel.tipo == conf.COMPRA_TIPO_ENCOMIENDA ||
        despachoModel.tipo == conf.COMPRA_TIPO_TARIFARIO ||
        despachoModel.tipo == conf.COMPRA_TIPO_MULTIPLE) return Container();
    if (despachoModel.idDespachoEstado == conf.DESPACHO_RECOGIDO) {
      return Positioned(
        top: 117.0,
        left: 0.0,
        child: SliderButton(
          dismissible: false,
          boxShadow: BoxShadow(
            color: Colors.black,
            blurRadius: 0.1,
          ),
          baseColor: Colors.white,
          shimmer: false,
          radius: 10.0,
          height: 35.0,
          width: 230.0,
          action: () {
            _enviarConfirmarEnLugar();
          },
          label: Text(
            "Pedir al cliente salir",
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w500, fontSize: 17),
          ),
          backgroundColor: Colors.green,
          buttonSize: 35.0,
          dismissThresholds: 0.6,
          icon: Icon(
            FontAwesomeIcons.bullhorn,
            size: 20.0,
            color: Colors.green,
          ),
        ),
      );
    }
    return Container();
  }

  bool isNotificado = false;
  DateTime notificado = DateTime.now().subtract(Duration(seconds: 28));

  _enviarConfirmarEnLugar() async {
    if (isNotificado || DateTime.now().difference(notificado).inSeconds <= 30) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          'Para volver a notificar deben pasar al menos 30 segundos y solo han transcurrido ${DateTime.now().difference(notificado).inSeconds}',
          style: TextStyle(color: Colors.white),
        ),
      ));

      return;
    }
    isNotificado = true;
    _saving = true;
    _mensajeProgreso = 'Notificando...';
    if (mounted) setState(() {});
    bool isCerca = await Rastreo().notificarUbicacion(
        isEvaluar: true, lt: despachoModel.ltB, lg: despachoModel.lgB);
    if (!isCerca) {
      _saving = false;
      if (!mounted) return;
      if (mounted) setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          'ERROR: ¡Para informar que te encuentras cerca debes estar a menos de 70 metros del punto de entrega! ',
          style: TextStyle(color: Colors.white),
        ),
      ));

      return;
    }
    DespachoModel _despacho = await _despachoProvider.confirmarNoticicacion(
        despachoModel,
        despachoModel.idCliente,
        despachoModel.idConductor,
        conf.CHAT_ENVIA_CAJERO,
        preparandose,
        tipoNotificacionFuera);
    isNotificado = false;
    notificado = DateTime.now();
    despachoModel = _despacho;
    _comprasDespachoBloc.actualizarPorDespacho(_despacho);
    _saving = false;
    if (!mounted) return;
    if (mounted) setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.green,
      content: Text(
        'Notificamos que te encuentras fuera del lugar de entrega.',
        style: TextStyle(color: Colors.white),
      ),
    ));
  }

  Widget _productoPreparandose() {
    //Si no se carga el despacho o ya se dio tiempo de preparacion no se muestra
    if (despachoModel == null ||
        despachoModel.preparandose > 0 ||
        tipo != conf.TIPO_CONDCUTOR ||
        despachoModel.idDespachoEstado >= conf.DESPACHO_RECOGIDO ||
        despachoModel.tipo == conf.COMPRA_TIPO_ENCOMIENDA ||
        despachoModel.tipo == conf.COMPRA_TIPO_TARIFARIO ||
        despachoModel.tipo == conf.COMPRA_TIPO_MULTIPLE) return Container();
    return Stack(
      children: [
        Positioned(
          top: 160.0,
          left: 0.0,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              color: Colors.white,
            ),
            child: TouchSpin(
              displayFormat: NumberFormat.currency(
                  locale: "es_ES", symbol: "min", decimalDigits: 0),
              min: 3,
              max: 120,
              step: 3,
              value: int.parse(preparandose),
              textStyle: TextStyle(fontSize: 30),
              iconSize: 49.0,
              addIcon: Icon(Icons.add_circle_outline),
              subtractIcon: Icon(Icons.remove_circle_outline),
              iconActiveColor: Colors.green,
              iconDisabledColor: Colors.grey,
              iconPadding: EdgeInsets.only(left: 10.0, right: 10.0),
              onChanged: (val) {
                preparandose = val.toString();
              },
            ),
          ),
        ),
        Positioned(
          top: 117.0,
          left: 0.0,
          child: SliderButton(
            dismissible: false,
            boxShadow: BoxShadow(
              color: Colors.black,
              blurRadius: 0.1,
            ),
            baseColor: Colors.white,
            shimmer: false,
            radius: 10.0,
            height: 35.0,
            width: 230.0,
            action: () {
              _enviarConfirmarPreparacion();
            },
            label: Text(
              "Orden preparándose",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 17),
            ),
            backgroundColor: prs.colorButtonSecondary,
            buttonSize: 35.0,
            dismissThresholds: 0.6,
            icon: Icon(
              FontAwesomeIcons.utensils,
              size: 16.0,
              color: prs.colorButtonSecondary,
            ),
          ),
        )
      ],
    );
  }

  _enviarConfirmarPreparacion() async {
    _saving = true;
    _mensajeProgreso = 'Notificando...';
    if (mounted) setState(() {});
    Rastreo().notificarUbicacion();
    DespachoModel _despacho = await _despachoProvider.confirmarNoticicacion(
        despachoModel,
        despachoModel.idCliente,
        despachoModel.idConductor,
        conf.CHAT_ENVIA_CAJERO,
        preparandose,
        tipoNotificacionPreparacion);
    despachoModel = _despacho;
    _comprasDespachoBloc.actualizarPorDespacho(_despacho);
    _saving = false;
    if (!mounted) return;
    if (mounted) setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.green,
      content: Text(
        'Has notificado que la orden se está preparando.',
        style: TextStyle(color: Colors.white),
      ),
    ));
  }

  Widget _botonLlamarUrbe(String zona, String celular, String costo) {
    return Container(
      width: 250.0,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
            primary: despachoModel.tipo == conf.COMPRA_TIPO_ENCOMIENDA
                ? Colors.green
                : prs.colorButtonSecondary,
            elevation: 2.0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0))),
        label: Container(
          width: 150.0,
          child: Text('$celular $costo $zona'),
        ),
        icon: Icon(FontAwesomeIcons.phoneAlt, size: 27.0),
        onPressed: () {
          _call(celular);
        },
      ),
    );
  }

  _call(String tel) async {
    String _call = 'tel:$tel';
    if (await canLaunch(_call)) {
      await launch(_call);
    } else {
      throw 'Could not open the tel.';
    }
  }

  _llamarLocal() async {
    if (despachoModel.tipo == conf.COMPRA_TIPO_MULTIPLE) {
      List<Widget> widgetlist = [];
      for (var i = 0; i < despachoModel.numerosJson.length; i++) {
        widgetlist.add(_botonLlamarUrbe(
          despachoModel.numerosJson[i]['zona'],
          despachoModel.numerosJson[i]['celular'],
          despachoModel.numerosJson[i]['costo'],
        ));
      }
      Widget _contenido = SingleChildScrollView(
        child: Column(
          children: widgetlist,
          mainAxisSize: MainAxisSize.min,
        ),
      );
      dlg.llamar(context, _contenido);
      return;
    }
    String _call = 'tel:${despachoModel.telSuc}';
    if (await canLaunch(_call)) {
      await launch(_call);
    } else {
      throw 'Could not open the tel.';
    }
  }

  Widget _buscando() {
    if (cajeroModel.idDespacho <= 0)
      return Stack(
        children: <Widget>[
          Positioned(
            bottom: 0,
            right: 0,
            child: Opacity(
              opacity: 0.9,
              child: BlinkingPoint(
                xCoor: 1.0,
                yCoor: 1.0,
                pointColor: prs.colorButtonSecondary,
                pointSize: 20.0,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: Opacity(
              opacity: 0.9,
              child: BlinkingPoint(
                xCoor: 1.0,
                yCoor: 1.0,
                pointColor: prs.colorButtonSecondary,
                pointSize: 20.0,
              ),
            ),
          )
        ],
      );
    return Container();
  }

  _moverCamaraMapa(_kLake) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }
}
