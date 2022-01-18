import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mime_type/mime_type.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import '../../bloc/cajero_bloc.dart';
import '../../bloc/chat_compra_bloc.dart';
import '../../bloc/compras_bloc.dart';
import '../../bloc/compras_cajero_bloc.dart';
import '../../model/cajero_model.dart';
import '../../model/chat_compra_estado_model.dart';
import '../../model/chat_compra_model.dart';
import '../../model/despacho_model.dart';
import '../../preference/push_provider.dart';
import '../../preference/shared_preferences.dart';
import '../../providers/cajero_provider.dart';
import '../../providers/chat_compra_provider.dart';
import '../../providers/compra_provider.dart';
import '../../sistema.dart';
import '../../utils/button.dart' as btn;
import '../../utils/cache.dart' as cache;
import '../../utils/compra.dart' as compra;
import '../../utils/conf.dart' as conf;
import '../../utils/personalizacion.dart' as prs;
import '../../utils/upload.dart' as upload;
import '../../utils/utils.dart' as utils;
import '../../widgets/audio_widget.dart';
import '../../widgets/chat_cliente_widget.dart';
import '../../widgets/en_linea_widget.dart';
import 'calificacioncompra_page.dart';
import 'despacho_page.dart';

class ChatClientePage extends StatefulWidget {
  final CajeroModel cajeroModel;

  ChatClientePage({Key key, this.cajeroModel}) : super(key: key);

  @override
  _ChatClientePageState createState() =>
      _ChatClientePageState(cajeroModel: cajeroModel);
}

class _ChatClientePageState extends State<ChatClientePage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final TextEditingController _textController = TextEditingController();

  final ChatCompraProvider _chatCompraProvider = ChatCompraProvider();
  final ChatCompraBloc _chatCompraBloc = ChatCompraBloc();
  final ComprasBloc _comprasBloc = ComprasBloc();
  final CajeroBloc _cajeroBloc = CajeroBloc();
  final CompraProvider _compraProvider = CompraProvider();
  final PushProvider _pushProvider = PushProvider();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final PreferenciasUsuario _prefs = PreferenciasUsuario();
  final CajeroProvider _cajeroProvider = CajeroProvider();

  final ComprasCajeroBloc _comprasCajeroBloc = ComprasCajeroBloc();
  bool _saving = false;
  CajeroModel cajeroModel;
  StreamController<bool> _cambios;

  _ChatClientePageState({this.cajeroModel});

  void disposeStreams() {
    _cambios?.close();
  }

  marcarLeido() {
    _compraProvider.marcarLeido(cajeroModel, conf.TIPO_ASESOR);
    print(cajeroModel.idCompra);
    print(cajeroModel.idCliente);
    print(cajeroModel.idCajero);
    _chatCompraProvider.estadoPush(cajeroModel.idCompra, cajeroModel.idCliente,
        cajeroModel.idCajero, conf.CHAT_LEIDO);
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

      if (chatCompraModel.idCompraEstado == conf.COMPRA_ENTREGADA)
        cajeroModel.calificarCliente = 1;

      cajeroModel.idCompraEstado = chatCompraModel.idCompraEstado;
      _cajeroBloc.actualizarPorCajero(cajeroModel);

      if (chatCompraModel.idCompraEstado == conf.COMPRA_CANCELADA)
        _irACalificar();

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

  Widget _botonMapa() {
    if ((cajeroModel.idCompraEstado == conf.COMPRA_CANCELADA ||
            cajeroModel.idCompraEstado <= conf.COMPRA_REFERENCIADA) &&
        cajeroModel.idDespacho <= 0) return Container();
    return IconButton(
      icon:
          Icon(FontAwesomeIcons.route, size: 22.0, color: prs.colorIconsAppBar),
      onPressed: _verDespacho,
    );
  }

  _verDespacho() {
    String mensaje = 'Solicitud confirmada';
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DespachoPage(
          conf.TIPO_CLIENTE,
          cajeroModel: cajeroModel,
          despachoModel: new DespachoModel(
              idCompra: cajeroModel.idCompra,
              idDespachoEstado: 0,
              img: 'assets/screen/compras.png',
              nombres: mensaje,
              costo: cajeroModel.costo,
              costoEnvio: cajeroModel.costoEnvio,
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

  Widget _botonCancelar() {
    return IconButton(
      icon: prs.iconoCancelar,
      onPressed: () {
        _cancelar();
      },
    );
  }

  void _enviarCancelar() async {
    Navigator.pop(context);
    _saving = true;
    if (mounted) setState(() {});
    CajeroModel cajero = await _cajeroProvider.cancelar(cajeroModel,
        cajeroModel.idCliente, cajeroModel.idCajero, conf.CHAT_ENVIA_CLIENTE);
    cajeroModel = cajero;
    _comprasCajeroBloc.actualizarPorCajero(cajero);
    cajeroModel.calificarCajero = 1;
    cajeroModel.calificarCliente = 1;
    _saving = false;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CalificacioncompraPage(
            cajeroModel: cajeroModel, tipo: conf.TIPO_CLIENTE),
      ),
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

  @override
  Widget build(BuildContext context) {
    if (_prefs.clienteModel.perfil == '1')
      return Container(child: Center(child: Text('No autorizado')));
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        titleSpacing: 0.0,
        title: _avatar(),
        actions: <Widget>[
          _botonMapa(),
          (cajeroModel.idCompraEstado == conf.COMPRA_REFERENCIADA)
              ? _botonCancelar()
              : Container(),
        ],
      ),
      body: ModalProgressHUD(
        color: Colors.black,
        opacity: 0.4,
        progressIndicator: utils.progressIndicator('Cargando...'),
        inAsyncCall: _saving,
        child: Center(
            child: Container(child: _contenido(), width: prs.anchoFormulario)),
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
    );
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
        _cajeroProvider.ver(cajeroModel.idCompra).then((cajero) {
          if (cajeroModel.idCompraEstado != cajero.idCompraEstado) {
            cajeroModel.idCompraEstado = cajero.idCompraEstado;
            if (mounted) setState(() {});
          }
        });
        _chatCompraBloc.obtener(cajeroModel.idCompra);
        marcarLeido();
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        break;
      default:
        break;
    }
  }

  Widget _avatar() {
    return Container(
      padding: EdgeInsets.all(5.0),
      child: Column(
        children: <Widget>[
          CircleAvatar(
            backgroundImage: cache.image(cajeroModel.img),
            radius: 17.0,
          ),
          Text(cajeroModel.nombres, style: TextStyle(fontSize: 9.0)),
        ],
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
              )),
          Container(child: _pie()),
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

  Widget _mapa() {
    return btn.bootonIcon('VER UBICACIÓN', prs.iconoRuta, _verDespacho);
  }

  String displayText = '% SUBIENDO...';
  String displayTextAudio = '% TAMAÑO MÁXIMO...';
  bool _subiendoImagen = false;
  bool _subiendoAudio = false;
  int _currentValue = 0;
  int _currentValueAudio = 0;
  int _duration = 4000;
  int _durationAudio = 30000;

  Widget _calificar() {
    return btn.booton('CALIFICAR COMPRA', _irACalificar);
  }

  _irACalificar() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => CalificacioncompraPage(
              cajeroModel: cajeroModel, tipo: conf.TIPO_CLIENTE)),
    );
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
    final ChatCompraModel chatCompraModel = ChatCompraModel(
        idCompra: cajeroModel.idCompra.toString(),
        envia: conf.CHAT_ENVIA_CLIENTE,
        mensaje: nombre,
        tipo: conf.CHAT_TIPO_IMAGEN,
        idClienteRecibe: cajeroModel.idCajero);
    _enviarChat(chatCompraModel, _imageFile);
  }

  Future _enviarAudio(int tamanio, String duration, Function subirAudio) async {
    _subiendoImagen = true;
    _duration = tamanio * 2 ~/ 100;
    displayText = '% Subiendo...';
    _currentValue = 99;
    if (mounted) setState(() {});

    String nombre = await subirAudio();

    if (!mounted) return;
    _subiendoImagen = false;
    _currentValue = 0;
    if (mounted) setState(() {});

    ChatCompraModel chatCompraModel = ChatCompraModel(
        idCompra: cajeroModel.idCompra.toString(),
        envia: conf.CHAT_ENVIA_CLIENTE,
        mensaje: nombre,
        tipo: conf.CHAT_TIPO_AUDIO,
        valor: duration,
        idClienteRecibe: cajeroModel.idCajero);
    _enviarChat(chatCompraModel, null);
  }

  _mostrarSnackBar(String mensaje) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensaje)));
  }

  final ScrollController _pageController = ScrollController();

  Widget _createListView(
      BuildContext context, AsyncSnapshot<List<ChatCompraModel>> snapshot) {
    return ListView.builder(
      reverse: true,
      controller: _pageController,
      itemCount: snapshot.data.length,
      itemBuilder: (BuildContext context, int index) {
        return ChatClienteWidget(
          cajeroModel: cajeroModel,
          chatCompraModel: snapshot.data[index],
          compraProvider: _compraProvider,
          imagen: null,
        );
      },
    );
  }

  void _enviarChat(ChatCompraModel chatCompraModel, File imagen) async {
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
                hintText: "Tienes una receta? Toma una foto."),
          ),
        ),
        _audio
            ? AudioWidget(_enviarAudio, _onInit, _onsFinal, conf.AUDIO_COMPRA)
            : IconButton(
                icon: prs.iconoEnviarMensaje,
                onPressed: () {
                  final mensaje = _textController.text.trim();
                  if (mensaje.length <= 1) return;
                  final ChatCompraModel chatCompraModel = ChatCompraModel(
                      idCompra: cajeroModel.idCompra.toString(),
                      envia: conf.CHAT_ENVIA_CLIENTE,
                      mensaje: mensaje,
                      tipo: conf.CHAT_TIPO_TEXTO,
                      idClienteRecibe: cajeroModel.idCajero);
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

  _onsFinal() {
    _currentValueAudio = 0;
    _subiendoAudio = false;
    if (mounted) setState(() {});
  }
}
