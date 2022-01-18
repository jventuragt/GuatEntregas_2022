import 'dart:async';
import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:flutter_sound_lite/flutter_sound.dart';
import 'package:flutter_sound_lite/public/flutter_sound_recorder.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../preference/shared_preferences.dart';
import '../sistema.dart';
import '../utils/conf.dart' as conf;
import '../utils/dialog.dart' as dlg;
import '../utils/personalizacion.dart' as prs;
import '../utils/upload.dart' as upload;
import 'icon_aument_widget.dart';

class AudioWidget extends StatefulWidget {
  final Function enviarAudio;
  final Function onInit;
  final Function onFinal;
  final int tipo; // 1 Compra 2 Viaje

  AudioWidget(this.enviarAudio, this.onInit, this.onFinal, this.tipo);

  @override
  State<StatefulWidget> createState() =>
      AudioWidgetState(enviarAudio, onInit, onFinal, tipo);
}

class AudioWidgetState extends State<AudioWidget> {
  Function enviarAudio;
  Function onInit;
  Function onFinal;
  int tipo; // 1 Compra 2 Viaje

  AudioWidgetState(this.enviarAudio, this.onInit, this.onFinal, this.tipo);

  bool _grabando = false;
  bool isSuccessful = false;
  double _tamanio = 40.0;

  @override
  void initState() {
    super.initState();
  }

  var _initTime = new DateTime(1989, DateTime.november, 9);

  @override
  Widget build(BuildContext context) {
    return Sistema.isWeb ? Container() : _microfono();
  }

  Widget _microfono() {
    return Stack(
      children: <Widget>[
        (_grabando)
            ? IconAumentWidget(
                Icon(
                  Icons.mic_none,
                  color: prs.colorIcons,
                ),
                size: 70)
            : Icon(
                Icons.mic,
                size: _tamanio,
                color: prs.colorIcons,
              ),
        Positioned.fill(
          child: GestureDetector(
            onLongPressEnd: (_) {
              _stop(true);
            },
            onTap: () async {
              var permissionMicrofono = await Permission.microphone.status;
              var permissionStorage = await Permission.storage.status;
              if (permissionMicrofono == PermissionStatus.granted &&
                  permissionStorage == PermissionStatus.granted) {
                var _initTimeSend = DateTime.now();
                Duration difference = _initTimeSend.difference(_initTime);
                if (difference.inSeconds > 30) {
                  dlg.mostrar(context,
                      'No se permiten audios mayores a los 30 segundos.',
                      mIzquierda: 'ACEPTAR');
                  _stop(false);
                } else if (difference.inSeconds < 1) {
                  Future.delayed(const Duration(milliseconds: 600), () {
                    _stop(false);
                  });
                } else {
                  _stop(true);
                }
              } else {
                dlg.mostrar(context,
                    'Manten presionado para grabar, suelta para enviar. \n\nNo superes los 30 segundos.',
                    mIzquierda: 'ACEPTAR');
              }
            },
            onTapDown: (a) async {
              var permissionMicrofono = await Permission.microphone.status;
              var permissionStorage = await Permission.storage.status;
              if (permissionMicrofono == PermissionStatus.granted &&
                  permissionStorage == PermissionStatus.granted) {
                _initTime = DateTime.now();
                _start();
              } else {
                if (!await Permission.microphone.request().isGranted ||
                    !await Permission.storage.request().isGranted) {
                  dlg.mostrar(context,
                      'Manten presionado para grabar, suelta para enviar. \n\nNo superes los 30 segundos.',
                      mIzquierda: 'ACEPTAR');
                } else if (await Permission.microphone
                        .request()
                        .isPermanentlyDenied ||
                    await Permission.storage.request().isPermanentlyDenied) {
                  openAppSettings();
                }
              }
            },
          ),
        ),
      ],
    );
  }

  FlutterSoundRecorder myRecorder;
  String customPath;
  var _initTimeDuration;

  _init() async {
    var permissionMicrofono = await Permission.microphone.status;
    var permissionStorage = await Permission.storage.status;
    if (permissionMicrofono == PermissionStatus.granted &&
        permissionStorage == PermissionStatus.granted) {
      onInit();
      customPath = '/recorder_';
      io.Directory appDocDirectory;
      if (Sistema.isIOS) {
        appDocDirectory = await getApplicationDocumentsDirectory();
      } else if (Sistema.isAndroid) {
        appDocDirectory = await getExternalStorageDirectory();
      }
      customPath = appDocDirectory.path +
          customPath +
          DateTime.now().millisecondsSinceEpoch.toString();
      myRecorder = await FlutterSoundRecorder().openAudioSession();
      myRecorder.startRecorder(
          toFile: customPath + '.wav', codec: Codec.pcm16WAV, sampleRate: 7000);
      _initTimeDuration = DateTime.now();
    } else {
      dlg.mostrar(context,
          'Manten presionado para grabar, suelta para enviar. \n\nNo superes los 30 segundos.',
          mIzquierda: 'ACEPTAR');
    }
  }

  _start() async {
    _tamanio = 90;
    _grabando = true;
    if (mounted) setState(() {});
    await _init();
  }

  _stop(bool enviar) async {
    _tamanio = 40;
    _grabando = false;
    if (mounted) setState(() {});
    onFinal();
    if (myRecorder == null) return;
    await myRecorder.stopRecorder();
    myRecorder.closeAudioSession();
    if (!enviar) return;
    var _initTimeSend = DateTime.now();
    Duration difference = _initTimeSend.difference(_initTimeDuration);
    String duracion = difference.inSeconds < 10
        ? '0${difference.inSeconds}'
        : difference.inSeconds.toString();
    _empaquetarAduio(
        tipo, io.File(customPath + '.wav'), '00:00:$duracion', enviarAudio);
  }
}

final _prefs = PreferenciasUsuario();

Future _empaquetarAduio(
    tipo, io.File imageFile, String duration, enviarAudio) async {
  String nombreAudio =
      '${_prefs.idCliente}_${DateTime.now().microsecondsSinceEpoch}.mp3';

  Future _subirAudio() async {
    String nombre;
    if (tipo == conf.AUDIO_COMPRA)
      nombre =
          await upload.subirArchivoMobil(imageFile, 'compra/$nombreAudio', 0);
    else if (tipo == conf.AUDIO_VIAJE)
      nombre =
          await upload.subirArchivoMobil(imageFile, 'viaje/$nombreAudio', 0);
    return nombre;
  }

  int tamanio = await imageFile.length();
  enviarAudio(tamanio, duration, _subirAudio);
}
