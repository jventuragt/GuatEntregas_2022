import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mime_type/mime_type.dart';

import '../../bloc/chat_despacho_bloc.dart';
import '../../model/chat_despacho_estado_model.dart';
import '../../model/chat_despacho_model.dart';
import '../../model/despacho_model.dart';
import '../../preference/push_provider.dart';
import '../../preference/shared_preferences.dart';
import '../../providers/chat_despacho_provider.dart';
import '../../providers/despacho_provider.dart';
import '../../sistema.dart';
import '../../utils/cache.dart' as cache;
import '../../utils/conf.dart' as conf;
import '../../utils/personalizacion.dart' as prs;
import '../../utils/upload.dart' as upload;
import '../../utils/utils.dart' as utils;
import '../../widgets/audio_widget.dart';
import '../../widgets/chat_despacho_widget.dart';
import '../../widgets/en_linea_widget.dart';

class ChatDespachoPage extends StatefulWidget {
  final DespachoModel despachoModel;

  ChatDespachoPage({Key key, this.despachoModel}) : super(key: key);

  @override
  _ChatDespachoPageState createState() =>
      _ChatDespachoPageState(despachoModel: despachoModel);
}

class _ChatDespachoPageState extends State<ChatDespachoPage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final TextEditingController _textController = TextEditingController();

  final ChatDespachoProvider _chatDespachoProvider = ChatDespachoProvider();
  final ChatDespachoBloc _chatDespachoBloc = ChatDespachoBloc();
  final DespachoProvider _despachoProvider = DespachoProvider();

  // final CajeroBloc _cajeroBloc = CajeroBloc();
  final PushProvider _pushProvider = PushProvider();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final PreferenciasUsuario _prefs = PreferenciasUsuario();

  final DespachoModel despachoModel;

  StreamController<bool> _cambios;

  _ChatDespachoPageState({this.despachoModel});

  void disposeStreams() {
    _cambios?.close();
  }

  marcarLeidoMensaje() {
    _despachoProvider.marcarLeido(despachoModel);
    if (despachoModel.isCliente()) {
      _chatDespachoProvider.estadoPush(despachoModel.idDespacho,
          despachoModel.idCliente, despachoModel.idConductor, conf.CHAT_LEIDO);
    } else {
      _chatDespachoProvider.estadoPush(despachoModel.idDespacho,
          despachoModel.idConductor, despachoModel.idCliente, conf.CHAT_LEIDO);
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    _chatDespachoBloc.obtener(despachoModel);
    marcarLeidoMensaje();
    super.initState();

    _cambios = StreamController<bool>.broadcast();
    _cambios.stream.listen((internet) {
      if (internet) {
        _chatDespachoBloc.obtener(despachoModel);
      }
    });
    _pushProvider.chatsDespacho.listen((ChatDespachoModel chatDespachoModel) {
      if (!mounted) return;
      if (chatDespachoModel.idDespacho.toString() !=
          despachoModel.idDespacho.toString()) return;

      despachoModel.idDespachoEstado = chatDespachoModel.idDespachoEstado;

      bool _agregarMensaje = true;
      _chatDespachoBloc.chats.forEach((chatsCajeros) {
        if (chatsCajeros.idChat == chatDespachoModel.idChat) {
          _agregarMensaje = false;
        }
      });
      if (_agregarMensaje) {
        _chatDespachoBloc.insert(chatDespachoModel);
      }
      marcarLeidoMensaje();
      if (mounted) setState(() {});
    });

    _pushProvider.estadosDespacho
        .listen((ChatDespachoEstadoModel chatDespachoEstadoModel) {
      if (!mounted) return;
      _chatDespachoBloc.chats.forEach((chatsCajeros) {
        if (chatsCajeros.idDespacho == chatDespachoEstadoModel.idDespacho &&
            chatsCajeros.estado < chatDespachoEstadoModel.estado) {
          chatsCajeros.estado = chatDespachoEstadoModel.estado;
        }
      });
      _chatDespachoBloc.chatSink(_chatDespachoBloc.chats);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        titleSpacing: 0.0,
        title: _avatar(),
      ),
      body: Center(
          child: Container(child: _contenido(), width: prs.anchoFormulario)),
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
        _chatDespachoBloc.obtener(despachoModel);
        _despachoProvider.marcarLeido(despachoModel);
        marcarLeidoMensaje();
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
            backgroundImage: cache.image(despachoModel.img),
            radius: 17.0,
          ),
          Text(despachoModel.nombres, style: TextStyle(fontSize: 9.0)),
        ],
      ),
    );
  }

  Container _contenido() {
    return Container(
      child: Column(
        children: <Widget>[
          EnLineaWidget(cambios: _cambios),
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
              stream: _chatDespachoBloc.chatStream,
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
          _buildTextComposer(),
        ],
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

  final picker = ImagePicker();
  final f = new DateFormat('yyyy-MM-dd');

  Future _tomarFoto(int tipo) async {
    final pickedFile = await picker.pickImage(
        source: tipo == 1 ? ImageSource.gallery : ImageSource.camera);
    if (pickedFile == null || pickedFile.path == null) return;
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
        _imageFile, 'despacho/$nombreImagen', Sistema.TARGET_WIDTH_CHAT);

    _subiendoImagen = false;
    _currentValue = 0;
    if (mounted) setState(() {});
    final ChatDespachoModel chatDespachoModel = ChatDespachoModel(
        idDespacho: despachoModel.idDespacho.toString(),
        envia: conf.CHAT_ENVIA_CLIENTE,
        mensaje: nombre,
        tipo: conf.CHAT_TIPO_IMAGEN,
        idClienteRecibe: despachoModel.idCliente);
    _enviarChat(chatDespachoModel, _imageFile);
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

    ChatDespachoModel chatDespachoModel = ChatDespachoModel(
        idDespacho: despachoModel.idDespacho.toString(),
        envia: conf.CHAT_ENVIA_CLIENTE,
        mensaje: nombre,
        tipo: conf.CHAT_TIPO_AUDIO,
        valor: duration,
        idClienteRecibe: despachoModel.idCliente);
    _enviarChat(chatDespachoModel, null);
  }

  _mostrarSnackBar(String mensaje) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensaje)));
  }

  final ScrollController _pageController = ScrollController();

  Widget _createListView(
      BuildContext context, AsyncSnapshot<List<ChatDespachoModel>> snapshot) {
    return ListView.builder(
      reverse: true,
      controller: _pageController,
      itemCount: snapshot.data.length,
      itemBuilder: (BuildContext context, int index) {
        return ChatDespachoWidget(
          despachoModel: despachoModel,
          chatDespachoModel: snapshot.data[index],
          despachoProvider: _despachoProvider,
          imagen: null,
        );
      },
    );
  }

  void _enviarChat(ChatDespachoModel chatDespachoModel, File imagen) async {
    chatDespachoModel.idDespacho = despachoModel.idDespacho;

    chatDespachoModel.idClienteRecibe =
        (despachoModel.idConductor.toString() == _prefs.idCliente.toString())
            ? despachoModel.idCliente.toString()
            : despachoModel.idConductor.toString();

    _chatDespachoBloc.insert(chatDespachoModel);
    _textController.clear();
    _chatDespachoProvider.enviar(chatDespachoModel, despachoModel,
        (idChat, chats) {
      chatDespachoModel.idChat = idChat;
      chatDespachoModel.estado = conf.CHAT_ENVIADO;
      _chatDespachoBloc.chatSink(_chatDespachoBloc.chats);
      if (_chatDespachoBloc.chats.length + 1 < chats) {
        _chatDespachoBloc.obtener(despachoModel).then((respuesta) {
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
                hintText: "La libertad muere si no se usa"),
          ),
        ),
        _audio
            ? AudioWidget(_enviarAudio, _onInit, _onsFinal, conf.AUDIO_VIAJE)
            : IconButton(
                icon: prs.iconoEnviarMensaje,
                onPressed: () {
                  final mensaje = _textController.text.trim();
                  if (mensaje.length <= 1) return;
                  final ChatDespachoModel chatDespachoModel = ChatDespachoModel(
                      idDespacho: despachoModel.idDespacho.toString(),
                      envia: conf.CHAT_ENVIA_CLIENTE,
                      mensaje: mensaje,
                      tipo: conf.CHAT_TIPO_TEXTO,
                      idClienteRecibe: despachoModel.idCliente);
                  _enviarChat(chatDespachoModel, null);
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
