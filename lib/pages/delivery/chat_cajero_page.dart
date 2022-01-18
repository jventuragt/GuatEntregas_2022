import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mime_type/mime_type.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../bloc/chat_compra_bloc.dart';
import '../../bloc/compras_bloc.dart';
import '../../bloc/compras_cajero_bloc.dart';
import '../../bloc/preferencias_bloc.dart';
import '../../model/cajero_model.dart';
import '../../model/chat_compra_estado_model.dart';
import '../../model/chat_compra_model.dart';
import '../../model/despacho_model.dart';
import '../../preference/push_provider.dart';
import '../../preference/shared_preferences.dart';
import '../../providers/cajero_provider.dart';
import '../../providers/chat_compra_provider.dart';
import '../../providers/cliente_provider.dart';
import '../../providers/compra_provider.dart';
import '../../providers/despacho_provider.dart';
import '../../sistema.dart';
import '../../utils/button.dart' as btn;
import '../../utils/cache.dart' as cache;
import '../../utils/compra.dart' as compra;
import '../../utils/conf.dart' as conf;
import '../../utils/permisos.dart' as permisos;
import '../../utils/personalizacion.dart' as prs;
import '../../utils/upload.dart' as upload;
import '../../utils/utils.dart' as utils;
import '../../widgets/audio_widget.dart';
import '../../widgets/chat_cajero_widget.dart';
import '../../widgets/en_linea_widget.dart';
import '../../widgets/icon_aument_widget.dart';
import 'calificacioncompra_page.dart';
import 'despacho_page.dart';

class ChatCajeroPage extends StatefulWidget {
  final CajeroModel cajeroModel;

  ChatCajeroPage({Key key, this.cajeroModel}) : super(key: key);

  @override
  _ChatCajeroPageState createState() =>
      _ChatCajeroPageState(cajeroModel: cajeroModel);
}

class _ChatCajeroPageState extends State<ChatCajeroPage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final TextEditingController _textController = TextEditingController();

  final ChatCompraBloc _chatCompraBloc = ChatCompraBloc();
  final ComprasBloc _comprasBloc = ComprasBloc();
  final ComprasCajeroBloc _comprasCajeroBloc = ComprasCajeroBloc();
  final CompraProvider _compraProvider = CompraProvider();
  final _clienteProvider = ClienteProvider();
  final _cajeroProvider = CajeroProvider();
  final _despachoProvider = DespachoProvider();
  final ChatCompraProvider _chatCompraProvider = ChatCompraProvider();
  final PreferenciasUsuario _prefs = PreferenciasUsuario();
  final PushProvider _pushProvider = PushProvider();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  CajeroModel cajeroModel;

  double _presupuestoPrecio = 0.0;
  String _presupuestoDetalle = '';

  StreamController<bool> _cambios;

  _ChatCajeroPageState({this.cajeroModel});

  void disposeStreams() {
    _cambios?.close();
  }

  marcarLeido() {
    print(cajeroModel.idCompra);
    print(cajeroModel.idCliente);
    print(cajeroModel.idCajero);
    _compraProvider.marcarLeido(cajeroModel, conf.TIPO_ASESOR);
    _chatCompraProvider.estadoPush(cajeroModel.idCompra, cajeroModel.idCajero,
        cajeroModel.idCliente, conf.CHAT_LEIDO);
  }

  @override
  void initState() {
    _comprasBloc.listarCompraPromociones(cajeroModel.idCompra);
    _chatCompraBloc.obtener(cajeroModel.idCompra);
    WidgetsBinding.instance.addObserver(this);
    marcarLeido();
    super.initState();
    _cambios = StreamController<bool>.broadcast();
    _cambios.stream.listen((internet) {
      if (internet) {
        _chatCompraBloc.obtener(cajeroModel.idCompra);
      }
    });

    _pushProvider.chatsCompra.listen((ChatCompraModel chatCompraModel) {
      if (!mounted) return;
      if (chatCompraModel.idCompra != cajeroModel.idCompra) return;

      cajeroModel.idCompraEstado = chatCompraModel.idCompraEstado;

      bool _agregarMensaje = true;
      _chatCompraBloc.chats.forEach((chatsCajeros) {
        if (chatsCajeros.idChat == chatCompraModel.idChat) {
          _agregarMensaje = false;
        }
      });
      if (_agregarMensaje) {
        _chatCompraBloc.insert(chatCompraModel);
      }
      marcarLeido();
      _comprasCajeroBloc.actualizarCompras(
          chatCompraModel, 0, 'Compras en despacho');
      if (mounted) setState(() {});
    });

    _pushProvider.estadosCompra
        .listen((ChatCompraEstadoModel chatCompraEstadoModel) {
      if (!mounted) return;
      _chatCompraBloc.chats.forEach((chatsCajeros) {
        if (chatsCajeros.idCompra == chatCompraEstadoModel.idCompra &&
            chatsCajeros.estado < chatCompraEstadoModel.estado) {
          chatsCajeros.estado = chatCompraEstadoModel.estado;
        }
      });
      _chatCompraBloc.chatSink(_chatCompraBloc.chats);
    });

    _pushProvider.objects.listen((despacho) {
      if (!mounted) return;
      DespachoModel despachoModel = despacho;
      cajeroModel.idDespacho = despachoModel.idDespacho;
      if (mounted) setState(() {});
    });

    permisos.getCheckNotificationPermStatus(context);

    _pageController.addListener(() {
      if (_pageController.position.pixels > 10) {
        if (_floatingActionButton) return;
        _floatingActionButton = true;
        if (mounted) setState(() {});
      } else {
        if (!_floatingActionButton) return;
        _floatingActionButton = false;
        if (mounted) setState(() {});
      }
    });
  }

  bool _floatingActionButton = false;

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _cajeroProvider.ver(cajeroModel.idCompra).then((nuevoCajeroModel) {
          if (cajeroModel.idCompraEstado != nuevoCajeroModel.idCompraEstado) {
            cajeroModel = nuevoCajeroModel;
            if (mounted) setState(() {});
          }
        });
        _chatCompraBloc.obtener(cajeroModel.idCompra);
        marcarLeido();
        permisos.getCheckNotificationPermStatus(context);
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_prefs.clienteModel.perfil == '0')
      return Container(child: Center(child: Text('No autorizado')));
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        titleSpacing: 0.0,
        title: _avatar(),
        actions: <Widget>[
          (cajeroModel.idCompraEstado == conf.COMPRA_COMPRADA ||
                  cajeroModel.idCompraEstado == conf.COMPRA_ENTREGADA ||
                  cajeroModel.idCompraEstado == conf.COMPRA_DESPACHADA)
              ? _botonDespachadores()
              : Container(),
          PreferenciasBloc().mensajes.length > 0
              ? _botonMejsajes()
              : Container(),
          (cajeroModel.idCompraEstado == conf.COMPRA_REFERENCIADA)
              ? _botonPresupuesto()
              : Container(),
//          (cajeroModel.idCompraEstado == conf.COMPRA_COMPRADA ||
//                  cajeroModel.idCompraEstado == conf.COMPRA_DESPACHADA)
//              ? _botonCobrar()
//              : Container(),
          (cajeroModel.idCompraEstado == conf.COMPRA_CANCELADA ||
                  cajeroModel.idCompraEstado == conf.COMPRA_ENTREGADA)
              ? Container()
              : _botonCancelar(),
        ],
      ),
      floatingActionButton: _floatingActionButton
          ? Container(
              width: 50.0,
              height: 50.0,
              margin: EdgeInsets.only(bottom: 45.0),
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(50)),
                child: Container(
                  color: prs.colorButtonSecondary,
                  child: IconButton(
                    icon: Icon(FontAwesomeIcons.chevronDown,
                        size: 35.0, color: Colors.white),
                    onPressed: () {
                      _pageController.animateTo(0,
                          duration: new Duration(milliseconds: 900),
                          curve: Curves.ease);
                    },
                  ),
                ),
              ),
            )
          : null,
      body: ModalProgressHUD(
        color: Colors.black,
        opacity: 0.4,
        progressIndicator: utils.progressIndicator(_mensaje),
        inAsyncCall: _saving,
        child: Center(
            child: Container(child: _contenido(), width: prs.anchoFormulario)),
      ),
    );
  }

  bool _saving = false;
  String _mensaje = 'Cargando...';

  Widget _avatar() {
    if (cajeroModel.celularValidado == 1)
      return Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(top: 5.0),
            child: Column(
              children: <Widget>[
                CircleAvatar(
                  child: Container(
                    child: CircleAvatar(
                      child: Text(
                        cajeroModel.acronimo,
                        style: TextStyle(
                            color: prs.colorTextDescription, fontSize: 15.0),
                      ),
                      backgroundColor: Colors.white30,
                    ),
                  ),
                  radius: 17.0,
                ),
                Text(cajeroModel.estado, style: TextStyle(fontSize: 9.0)),
              ],
            ),
          ),
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                  borderRadius: BorderRadius.all(Radius.circular(110)),
                  splashColor: Colors.blueAccent.withOpacity(0.6),
                  onTap: () {
                    _confirmarLlamar(context);
                  }),
            ),
          )
        ],
      );

    return IconButton(
      padding: EdgeInsets.only(right: 30.0),
      icon: IconAumentWidget(Icon(Icons.phone_in_talk, color: Colors.red)),
      onPressed: () => _confirmarLlamar(context),
    );
  }

  Widget _avatarCliente() {
    Widget _tarjeta = ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(100)),
      child: cache.fadeImage(cajeroModel.img, width: 100, height: 100),
    );
    return _tarjeta;
  }

  void _confirmarLlamar(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  _avatarCliente(),
                  Text(
                    '${cajeroModel.nombres}',
                    style: TextStyle(fontSize: 18.0),
                  ),
                  Text(
                    '${cajeroModel.celular}',
                    style: TextStyle(fontSize: 18.0),
                  ),
                  SizedBox(height: 5.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            primary: prs.colorButtonSecondary,
                            elevation: 2.0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0))),
                        label: Text('Whatsapp'),
                        icon: Icon(
                          FontAwesomeIcons.whatsapp,
                          size: 22.0,
                        ),
                        onPressed: () async {
                          String url =
                              'https://api.whatsapp.com/send?phone=${cajeroModel.celular.toString().replaceAll('+', '')}&text=Hola ${cajeroModel.nombres}, somos del APP ${Sistema.aplicativo} ';
                          var encoded = Uri.encodeFull(url);
                          if (await canLaunch(encoded)) {
                            await launch(encoded);
                          } else {
                            print('Could not open the url.');
                          }
                        },
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            primary: prs.colorButtonSecondary,
                            elevation: 2.0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0))),
                        label: Text('Llamar'),
                        icon: Icon(
                          Icons.phone_in_talk,
                          size: 22.0,
                        ),
                        onPressed: () async {
                          String _call = 'tel:${cajeroModel.celular}';
                          if (await canLaunch(_call)) {
                            await launch(_call);
                          } else {
                            throw 'Could not open the tel.';
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('REGRESAR'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              (cajeroModel.celularValidado == 1)
                  ? Container()
                  : ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          primary: prs.colorButtonSecondary,
                          elevation: 2.0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0))),
                      label: Text('Verificar #'),
                      icon: Icon(
                        Icons.phonelink_ring,
                        size: 22.0,
                      ),
                      onPressed: () {
                        _clienteProvider.validadCelular(cajeroModel.celular,
                            idClienteVerificar: cajeroModel.idCliente);
                        cajeroModel.celularValidado = 1;
                        Navigator.of(context).pop();
                        if (mounted) setState(() {});
                      },
                    ),
            ],
          );
        });
  }

  Widget _botonMejsajes() {
    if (cajeroModel.idCompraEstado >= conf.COMPRA_COMPRADA) return Container();
    return IconButton(
      icon: Icon(FontAwesomeIcons.facebookMessenger, color: Colors.white),
      onPressed: () => _confirmarMensajes(),
    );
  }

  Widget setupAlertDialoadContainer() {
    return Container(
      width: 500.0,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: PreferenciasBloc().mensajes.length,
        itemBuilder: (BuildContext context, int index) {
          MensajePreferenciaModel mensaje = PreferenciasBloc().mensajes[index];
          return ListTile(
              dense: true,
              trailing: prs.iconoEnviarMensaje,
              title: Text(mensaje.m),
              onTap: () {
                final ChatCompraModel chatCompraModel = ChatCompraModel(
                    idCompra: cajeroModel.idCompra.toString(),
                    envia: conf.CHAT_ENVIA_CAJERO,
                    mensaje: mensaje.m,
                    tipo: conf.CHAT_TIPO_TEXTO,
                    idClienteRecibe: cajeroModel.idCliente);
                _enviarChat(chatCompraModel, null);
                Navigator.pop(context);
              });
        },
      ),
    );
  }

  void _confirmarMensajes() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            contentPadding: EdgeInsets.all(0.0),
            content: setupAlertDialoadContainer(),
            actions: <Widget>[
              TextButton(
                child: Text('CANCELAR'),
                onPressed: () => Navigator.of(context).pop(),
              )
            ],
          );
        });
  }

  Widget _botonPresupuesto() {
    return IconButton(
      icon: Icon(FontAwesomeIcons.moneyBillWave, color: Colors.green),
      onPressed: () => _confirmarPresupuesto(context),
    );
  }

//  Widget _botonCobrar() {
//    return IconButton(
//      icon: prs.iconoRecibirDinero,
//      onPressed: () {
//        _confirmarPago(context);
//      },
//    );
//  }

//  void _confirmarPago(BuildContext context) {
//    showDialog(
//      context: context,
//      builder: (context) {
//        return AlertDialog(
//          shape:
//              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
//          title: Text('Confirmación de pago'),
//          content: SingleChildScrollView(
//              child: Center(
//            child: Text('${cajeroModel.costo} USD',
//                style: TextStyle(fontSize: 30)),
//          )),
//          actions: <Widget>[
//            TextButton(
//              child: Text('CANCELAR'),
//              onPressed: () => Navigator.of(context).pop(),
//            ),
//            RaisedButton.icon(
//              elevation: 2.0,
//              shape: RoundedRectangleBorder(
//                  borderRadius: BorderRadius.circular(20.0)),
//              color: prs.colorButtonSecondary,
//              textColor: Colors.white,
//              label: Text('CONFIRMAR'),
//              icon: Icon(
//                Icons.monetization_on,
//                size: 18.0,
//              ),
//              onPressed: () {
//                utils.mostrarProgress(context);
//                _enviarConfirmarPago();
//              },
//            ),
//          ],
//        );
//      },
//    );
//  }

  Widget _botonCancelar() {
    return IconButton(
      icon: prs.iconoCancelar,
      onPressed: () {
        _cancelar();
      },
    );
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
    _mensaje = 'Cancelando...';
    if (mounted) setState(() {});
    CajeroModel cajero = await _cajeroProvider.cancelar(cajeroModel,
        cajeroModel.idCliente, cajeroModel.idCajero, conf.CHAT_ENVIA_CAJERO);
    cajeroModel = cajero;
    _comprasCajeroBloc.actualizarPorCajero(cajero);
    cajeroModel.calificarCajero = 1;
    _saving = false;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CalificacioncompraPage(
            cajeroModel: cajeroModel, tipo: conf.TIPO_ASESOR),
      ),
    );
  }

  Container _contenido() {
    return Container(
      child: Column(
        children: <Widget>[
          EnLineaWidget(cambios: _cambios),
          compra.promociones(
              context, _comprasBloc.compraPromocionStream, _scaffoldKey),
          Visibility(
            visible: _subiendoAudio,
            child: FAProgressBar(
              size: 20.0,
              progressColor: Colors.blueAccent,
              animatedDuration: Duration(milliseconds: _durationAudio),
              currentValue: _currentValueAudio,
              displayText: displayTextAudio,
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: _chatCompraBloc.chatStream,
              builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
                if (snapshot.hasData) {
                  return _createListView(context, snapshot);
                } else {
                  return Container(
                      child: Center(child: CircularProgressIndicator()));
                }
              },
            ),
          ),
          Divider(height: 1.0),
          Visibility(
            visible: _subiendoImagen,
            child: FAProgressBar(
              size: 20.0,
              progressColor: prs.colorButtonSecondary,
              animatedDuration: Duration(milliseconds: _duration),
              currentValue: _currentValue,
              displayText: displayText,
            ),
          ),
          Container(child: _pie())
        ],
      ),
    );
  }

  Widget _pie() {
    switch (cajeroModel.idCompraEstado) {
      case conf.COMPRA_COMPRADA:
      case conf.COMPRA_DESPACHADA:
        return _mapa();
      case conf.COMPRA_CANCELADA:
      case conf.COMPRA_DESPACHADA:
      case conf.COMPRA_ENTREGADA:
        return _calificar();
      default:
        return _buildTextComposer();
    }
  }

  _confirmarGenerarDesacpho() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            title: Text('Generar despacho'),
            content: Text('Esto notificará a los despachadores!'),
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
                label: Text('GENERAR'),
                icon: Icon(FontAwesomeIcons.peopleCarry, size: 18.0),
                onPressed: _generarDespacho,
              ),
            ],
          );
        });
  }

  _generarDespacho() async {
    Navigator.of(context).pop();
    _saving = true;
    if (mounted) setState(() {});
    DespachoModel despachoModel = DespachoModel(
        idCompra: cajeroModel.idCompra,
        ltA: cajeroModel.lt,
        lgA: cajeroModel.lg,
        ltB: cajeroModel.ltB,
        lgB: cajeroModel.lgB,
        costo: cajeroModel.costo,
        costoEnvio: cajeroModel.costoEnvio);
    String desde = cajeroModel.sucursal,
        hasta = cajeroModel.nombres,
        detalle = cajeroModel.detalle,
        referencia = cajeroModel.referencia;

    cajeroModel.idDespacho = await _despachoProvider.registrar(
        despachoModel, desde, hasta, detalle, referencia);
    _saving = false;
    if (mounted) setState(() {});
    _verDespacho();
  }

  Widget _mapa() {
    if (cajeroModel.idDespacho == -1)
      return btn.bootonIcon(
          '¡¡¡ GENERAR DESPACHO !!!',
          Icon(FontAwesomeIcons.route, color: Colors.red),
          _confirmarGenerarDesacpho);
    return btn.bootonIcon('VER UBICACIÓN', prs.iconoRuta, _verDespacho);
  }

  Widget _botonDespachadores() {
    return IconButton(
      icon: (cajeroModel.idCompraEstado == conf.COMPRA_COMPRADA)
          ? IconAumentWidget(Icon(FontAwesomeIcons.route, color: Colors.red))
          : prs.iconoDespachar,
      onPressed: _verDespacho,
    );
  }

  _verDespacho() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DespachoPage(
          conf.TIPO_ASESOR,
          cajeroModel: cajeroModel,
          despachoModel: new DespachoModel(
              idDespachoEstado: conf.DESPACHO_BUSCANDO,
              costoEnvio: cajeroModel.costoEnvio,
              costo: double.parse(cajeroModel.costo.toString()),
              nombres: 'Buscando Despachador',
              lt: 0.0,
              lg: 0.0,
              ltA: cajeroModel.lt,
              lgA: cajeroModel.lg,
              ltB: cajeroModel.ltB,
              lgB: cajeroModel.lgB),
        ),
      ),
    );
  }

  String displayText = '% SUBIENDO...';
  String displayTextAudio = '% TAMAÑO MÁXIMO...';
  bool _subiendoImagen = false;
  bool _subiendoAudio = false;
  int _currentValue = 0;
  int _currentValueAudio = 0;
  int _duration = 4000;
  int _durationAudio = 30000;

  _calificarCompra() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CalificacioncompraPage(
            cajeroModel: cajeroModel, tipo: conf.TIPO_ASESOR),
      ),
    );
  }

  _finalizarCompra() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CalificacioncompraPage(
            cajeroModel: cajeroModel, tipo: conf.TIPO_ASESOR),
      ),
    );
  }

  Widget _calificar() {
    if (cajeroModel.calificarCajero == 2)
      return btn.booton('CALIFICAR COMPRA', _calificarCompra);
    return btn.booton('FINALIZAR COMPRA', _finalizarCompra);
  }

  final ScrollController _pageController = ScrollController();

  Widget _createListView(
      BuildContext context, AsyncSnapshot<List<ChatCompraModel>> snapshot) {
    return ListView.builder(
      reverse: true,
      controller: _pageController,
      itemCount: snapshot.data.length,
      itemBuilder: (BuildContext context, int index) {
        return ChatCajeroWidget(
            cajeroModel: cajeroModel,
            chatCompraModel: snapshot.data[index],
            imagen: null);
      },
    );
  }

//  void _enviarConfirmarPago() async {
//    CajeroModel cajero = await _cajeroProvider.confirmarPago(cajeroModel,
//        cajeroModel.idCliente, cajeroModel.idCajero, conf.CHAT_ENVIA_CAJERO);
//    cajeroModel = cajero;
//    _presupuestoPrecio = 0.0;
//    _presupuestoDetalle = '';
//    Navigator.pop(context);
//    cajeroModel.calificarCajero = 1;
//    if (mounted) setState(() {});
//  }

  void _confirmarPresupuesto(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            contentPadding: EdgeInsets.all(10.0),
            title: Text('Presupuesto'),
            content: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    SizedBox(width: 700.0),
                    TextFormField(
                        onSaved: (value) =>
                            _presupuestoPrecio = double.parse(value),
                        validator: (value) {
                          if (utils.isNumeric(value)) {
                            return null;
                          } else {
                            return 'Sólo números';
                          }
                        },
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(hintText: 'Costo total')),
                    TextFormField(
                      onSaved: (value) => _presupuestoDetalle = value,
                      validator: (value) {
                        if (value.length < 4) {
                          return 'Ingrese el detalle del presupuesto';
                        } else {
                          return null;
                        }
                      },
                      keyboardType: TextInputType.multiline,
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: null,
                      decoration:
                          InputDecoration(hintText: 'Detalles del presupuesto'),
                    ),
                  ],
                ),
              ),
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
                label: Text('ENVIAR'),
                icon: Icon(
                  Icons.monetization_on,
                  size: 18.0,
                ),
                onPressed: () {
                  utils.mostrarProgress(context);
                  _enviarConfirmarPresupuesto();
                },
              ),
            ],
          );
        });
  }

  void _enviarConfirmarPresupuesto() {
    if (!_formKey.currentState.validate()) {
      Navigator.of(context).pop();
      return;
    }
    _formKey.currentState.save();
    ChatCompraModel chatCompraModel = ChatCompraModel(
        idCompra: cajeroModel.idCompra.toString(),
        envia: conf.CHAT_ENVIA_CAJERO,
        mensaje: _presupuestoDetalle,
        tipo: conf.CHAT_TIPO_PRESUPUESTO,
        valor: _presupuestoPrecio,
        idClienteRecibe: cajeroModel.idCliente);
    _enviarChat(chatCompraModel, null);
    _presupuestoPrecio = 0.0;
    _presupuestoDetalle = '';
    Navigator.pop(context);
    Navigator.pop(context);
  }

  void _enviarChat(ChatCompraModel chatCompraModel, File imagen) {
    chatCompraModel.idCompra = cajeroModel.idCompra;
    _chatCompraBloc.insert(chatCompraModel);
    _textController.clear();
    _chatCompraProvider.enviar(chatCompraModel, cajeroModel, (idChat, chats) {
      chatCompraModel.idChat = idChat;
      chatCompraModel.estado = conf.CHAT_ENVIADO;
      _chatCompraBloc.chatSink(_chatCompraBloc.chats);
      if (_chatCompraBloc.chats.length + 1 < chats) {
        _chatCompraBloc.obtener(cajeroModel.idCompra).then((respuesta) {
          utils.play('sound.mp3');
        });
      }
    });
    setState(() {
      _audio = true;
    });
    _pageController.animateTo(0,
        duration: new Duration(milliseconds: 900), curve: Curves.ease);
  }

  bool _audio = true;

  Widget _buildTextComposer() {
    return Row(
      children: <Widget>[
        IconButton(
          icon: prs.iconoTomarFoto,
          onPressed: () {
            _tomarFoto(0);
          },
        ),
        Flexible(
          child: TextFormField(
            onChanged: (value) {
              if (value.length > 0)
                _audio = false;
              else
                _audio = true;
              if (mounted) setState(() {});
            },
            maxLines: null,
            controller: _textController,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
                suffixIcon: IconButton(
                  icon: prs.iconoSubirFoto,
                  onPressed: () {
                    _tomarFoto(1);
                  },
                ),
                hintText: "Se breve, agilita el proceso. =)"),
          ),
        ),
        _audio
            ? AudioWidget(_enviarAudio, _onInit, _onFinal, conf.AUDIO_COMPRA)
            : IconButton(
                icon: prs.iconoEnviarMensaje,
                onPressed: () {
                  final mensaje = _textController.text.trim();
                  if (mensaje.length <= 1) return;
                  final ChatCompraModel chatCompraModel = ChatCompraModel(
                      idCompra: cajeroModel.idCompra.toString(),
                      envia: conf.CHAT_ENVIA_CAJERO,
                      mensaje: mensaje,
                      tipo: conf.CHAT_TIPO_TEXTO,
                      idClienteRecibe: cajeroModel.idCliente);
                  _enviarChat(chatCompraModel, null);
                },
              ),
      ],
    );
  }

  _onInit() {
    _currentValueAudio = 100;
    _subiendoAudio = true;
    if (mounted) setState(() {});
  }

  _onFinal() {
    _currentValueAudio = 0;
    _subiendoAudio = false;
    if (mounted) setState(() {});
  }

  final picker = ImagePicker();
  final f = new DateFormat('yyyy-MM-dd');

  Future _tomarFoto(int tipo) async {
    final pickedFile = await picker.pickImage(
        source: tipo == 1 ? ImageSource.gallery : ImageSource.camera);
    File _imageFile = File(pickedFile.path);
    if (_imageFile == null) return _mostrarSnackBar('Foto no tomada');

    final mimeType = mime(_imageFile.path).split('/'); //image/

    int tamanio = await _imageFile.length();
    tamanio = tamanio * 4 ~/ 3000;

    String nombreImagen =
        '${_prefs.idCliente}_${DateTime.now().microsecondsSinceEpoch}.${mimeType[1].toString()}';

    _subiendoImagen = true;
    displayText = '% Subiendo...';
    _currentValue = 99;
    _duration = tamanio;
    if (mounted) setState(() {});

    String nombre = await upload.subirArchivoMobil(
        _imageFile, 'compra/$nombreImagen', Sistema.TARGET_WIDTH_CHAT);

    _subiendoImagen = false;
    _currentValue = 0;
    if (mounted) setState(() {});

    ChatCompraModel chatCompraModel = ChatCompraModel(
        idCompra: cajeroModel.idCompra.toString(),
        envia: conf.CHAT_ENVIA_CAJERO,
        mensaje: nombre,
        tipo: conf.CHAT_TIPO_IMAGEN,
        idClienteRecibe: cajeroModel.idCliente);
    _enviarChat(chatCompraModel, _imageFile);
  }

  Future _enviarAudio(int tamanio, String duration, Function subirAudio) async {
    _subiendoImagen = true;
    _duration = tamanio * 2 ~/ 100;
    _currentValue = 99;
    if (mounted) setState(() {});

    String nombre = await subirAudio();

    if (!mounted) return;
    _subiendoImagen = false;
    _currentValue = 0;
    if (mounted) setState(() {});

    ChatCompraModel chatCompraModel = ChatCompraModel(
        idCompra: cajeroModel.idCompra.toString(),
        envia: conf.CHAT_ENVIA_CAJERO,
        mensaje: nombre,
        tipo: conf.CHAT_TIPO_AUDIO,
        valor: duration,
        idClienteRecibe: cajeroModel.idCliente);
    _enviarChat(chatCompraModel, null);
  }

  _mostrarSnackBar(String mensaje) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensaje)));
  }
}
