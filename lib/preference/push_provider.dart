import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:vibration/vibration.dart';

import '../model/cajero_model.dart';
import '../model/chat_compra_estado_model.dart';
import '../model/chat_compra_model.dart';
import '../model/chat_despacho_estado_model.dart';
import '../model/chat_despacho_model.dart';
import '../model/despacho_model.dart';
import '../pages/delivery/chat_cajero_page.dart';
import '../pages/delivery/chat_cliente_page.dart';
import '../providers/cajero_provider.dart';
import '../providers/chat_compra_provider.dart';
import '../providers/chat_despacho_provider.dart';
import '../providers/cliente_provider.dart';
import '../providers/compra_provider.dart';
import '../utils/conf.dart' as conf;
import '../utils/utils.dart' as utils;
import 'shared_preferences.dart';

const String _PUSH_CHAT_MENSAJE_COMPRA = '1';
const String _PUSH_CHAT_ESTADO_COMPRA = '2';

const String _PUSH_CHAT_MENSAJE_DESPACHO = '5';
const String _PUSH_CHAT_ESTADO_DESPACHO = '6';

const String _PUSH_OBJECT = '100';

class PushProvider {
  static PushProvider _instancia;
  static FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  BuildContext context;

  PushProvider._internal();

  factory PushProvider() {
    if (_instancia == null) {
      _instancia = PushProvider._internal();
      _instancia.initNotifications();
    }
    return _instancia;
  }

  final PreferenciasUsuario _prefs = PreferenciasUsuario();

  final ClienteProvider _clienteProvider = ClienteProvider();
  final CompraProvider _compraProvider = CompraProvider();
  final CajeroProvider _cajeroProvider = CajeroProvider();

  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  final StreamController<ChatCompraModel> _chatsCompraStreamController =
      StreamController<ChatCompraModel>.broadcast();

  Stream<ChatCompraModel> get chatsCompra =>
      _chatsCompraStreamController.stream;
  final StreamController<ChatCompraEstadoModel>
      _chatEstadoCompraStreamController =
      StreamController<ChatCompraEstadoModel>.broadcast();

  Stream<ChatCompraEstadoModel> get estadosCompra =>
      _chatEstadoCompraStreamController.stream;

//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

  final StreamController<ChatDespachoModel> _chatsDespachoStreamController =
      StreamController<ChatDespachoModel>.broadcast();

  Stream<ChatDespachoModel> get chatsDespacho =>
      _chatsDespachoStreamController.stream;
  final StreamController<ChatDespachoEstadoModel>
      _chatEstadoDespachoStreamController =
      StreamController<ChatDespachoEstadoModel>.broadcast();

  Stream<ChatDespachoEstadoModel> get estadosDespacho =>
      _chatEstadoDespachoStreamController.stream;

  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

  final StreamController<Object> _objectStreamController =
      StreamController<Object>.broadcast();

  Stream<Object> get objects => _objectStreamController.stream;

  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

  obtenerToken() async {
    _firebaseMessaging.requestPermission(alert: true, sound: true, badge: true);
    String nuevoToken = await _firebaseMessaging.getToken();
    if (nuevoToken.toString() == _prefs.token.toString()) return;
    _prefs.token = nuevoToken;
    if (_prefs.idCliente == '') {
      return;
    }
    _clienteProvider.actualizarToken().then((isActualizo) {
      _prefs.empezamos = isActualizo;
    });
  }

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future _showNotification(RemoteNotification push) async {
    if (push == null || push.title == null || push.body == null) return;

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
            'Curiosity_CHANNEL_ID', 'Curiosity Notification', 'Curiosity',
            playSound: true,
            importance: Importance.max,
            priority: Priority.high,
            groupKey: 'Curiosity_GROUP_KEY',
            autoCancel: true);
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    flutterLocalNotificationsPlugin.show(
        1682, push.title, push.body, platformChannelSpecifics);
    Vibration.vibrate(amplitude: 75);
  }

  cancelAll() {
    flutterLocalNotificationsPlugin.cancelAll();
  }

  Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(body),
      ),
    );
  }

  initNotifications() {
    final initializationSettingsAndroid =
        AndroidInitializationSettings('launcher_icon');
    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
            onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    final initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
    obtenerToken();
    FirebaseMessaging.onMessage.listen(_onMessageHandler);
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenApp);
    FirebaseMessaging.onBackgroundMessage(_messageHandler);
  }

  Future _onMessageHandler(RemoteMessage message) async {
    if (Platform.isAndroid) {
      if (message.data['PUSH'] == _PUSH_CHAT_MENSAJE_COMPRA) {
        procesarChatCompra(message.data, message.notification);
      } else if (message.data['PUSH'] == _PUSH_CHAT_ESTADO_COMPRA) {
        estadoChatCompra(message.data);
      } else if (message.data['PUSH'] == _PUSH_CHAT_MENSAJE_DESPACHO) {
        procesarChatDespacho(message.data, message.notification);
      } else if (message.data['PUSH'] == _PUSH_CHAT_ESTADO_DESPACHO) {
        estadoChatDespacho(message.data);
      } else if (message.data['PUSH'] == _PUSH_OBJECT) {
        procesarObject(message.data, message.notification);
      }
    } else {
      if (message.data['PUSH'] == _PUSH_CHAT_MENSAJE_COMPRA) {
        procesarChatCompra(message.data, message.notification);
      } else if (message.data['PUSH'] == _PUSH_CHAT_ESTADO_COMPRA) {
        estadoChatCompra(message.data);
      } else if (message.data['PUSH'] == _PUSH_CHAT_MENSAJE_DESPACHO) {
        procesarChatDespacho(message.data, message.notification);
      } else if (message.data['PUSH'] == _PUSH_CHAT_ESTADO_DESPACHO) {
        estadoChatDespacho(message.data);
      } else if (message.data['PUSH'] == _PUSH_OBJECT) {
        procesarObject(message.data, message.notification);
      }
    }
  }

  Future _onMessageOpenApp(RemoteMessage message) async {
    var push = message.data;
    if (Platform.isAndroid) {
      if (message.data['PUSH'] == _PUSH_CHAT_MENSAJE_COMPRA) {
        navegarCompra(message.data);
      }
    } else {
      if (push['PUSH'] == _PUSH_CHAT_MENSAJE_COMPRA) {
        navegarCompra(push);
      }
    }
  }

  navegarCompra(push) async {
    if (context != null) {
      final chatCompraModel =
          ChatCompraModel.fromJson(json.decode(push['chat']));

      if (_prefs.clienteModel.perfil == '0') {
        CajeroModel cajeroModel =
            await _compraProvider.ver(chatCompraModel.idCompra);

        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (context) =>
                    ChatClientePage(cajeroModel: cajeroModel)),
            (Route<dynamic> route) {
          return route.isFirst;
        });
      } else {
        CajeroModel cajeroModel =
            await _cajeroProvider.ver(chatCompraModel.idCompra);
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (context) => ChatCajeroPage(cajeroModel: cajeroModel)),
            (Route<dynamic> route) {
          return route.isFirst;
        });
      }
    }
  }

  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  final ChatCompraProvider _chatCompraProvider = ChatCompraProvider();

  procesarChatCompra(push, RemoteNotification notification) {
    _showNotification(notification);
    utils.play('sound.mp3');
    final chatCompraModel = ChatCompraModel.fromJson(json.decode(push['chat']));
    _chatsCompraStreamController.sink.add(chatCompraModel);
    _chatCompraProvider.estadoPush(
        chatCompraModel.idCompra,
        chatCompraModel.idClienteRecibe,
        chatCompraModel.idClienteEnvia,
        conf.CHAT_ENTREGADO);
  }

  estadoChatCompra(push) {
    dynamic idCompra = json.decode(push['id_compra']);
    dynamic estado = json.decode(push['estado']);
    _chatEstadoCompraStreamController.sink
        .add(ChatCompraEstadoModel(idCompra: idCompra, estado: estado));
  }

  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  final ChatDespachoProvider _chatDespachoProvider = ChatDespachoProvider();

  procesarChatDespacho(push, RemoteNotification notification) {
    _showNotification(notification);
    utils.play('sound.mp3');
    final chatDespachoModel =
        ChatDespachoModel.fromJson(json.decode(push['chat']));
    _chatsDespachoStreamController.sink.add(chatDespachoModel);
    _chatDespachoProvider.estadoPush(
        chatDespachoModel.idDespacho,
        chatDespachoModel.idClienteRecibe,
        chatDespachoModel.idClienteEnvia,
        conf.CHAT_ENTREGADO);
  }

  estadoChatDespacho(push) {
    dynamic idDespacho = json.decode(push['id_despacho']);
    dynamic estado = json.decode(push['estado']);
    _chatEstadoDespachoStreamController.sink
        .add(ChatDespachoEstadoModel(idDespacho: idDespacho, estado: estado));
  }

  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

  procesarObject(push, RemoteNotification notification) {
    if (push['tipo'] == '1') {
      _showNotification(notification);
      DespachoModel despacho =
          DespachoModel.fromJson(json.decode(push['despacho']));
      utils.play('sound.mp3');
      _objectStreamController.sink.add(despacho);
    }
  }

  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

  dispose() {
    _chatsCompraStreamController?.close();
    _chatEstadoCompraStreamController?.close();

    _chatsDespachoStreamController?.close();
    _chatEstadoDespachoStreamController?.close();

    _objectStreamController?.close();
  }
}

final ChatDespachoProvider _chatDespachoProvider = ChatDespachoProvider();
final ChatCompraProvider _chatCompraProvider = ChatCompraProvider();

Future<void> _messageHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await PreferenciasUsuario().init();
  if (message.data['PUSH'] == _PUSH_CHAT_MENSAJE_COMPRA) {
    final chatCompraModel =
        ChatCompraModel.fromJson(json.decode(message.data['chat']));
    _chatCompraProvider.estadoPush(
        chatCompraModel.idCompra,
        chatCompraModel.idClienteRecibe,
        chatCompraModel.idClienteEnvia,
        conf.CHAT_ENTREGADO);
  } else if (message.data['PUSH'] == _PUSH_CHAT_MENSAJE_DESPACHO) {
    final chatDespachoModel =
        ChatDespachoModel.fromJson(json.decode(message.data['chat']));
    _chatDespachoProvider.estadoPush(
        chatDespachoModel.idDespacho,
        chatDespachoModel.idClienteRecibe,
        chatDespachoModel.idClienteEnvia,
        conf.CHAT_ENTREGADO);
  }
  PushProvider()._showNotification(message.notification);
}
