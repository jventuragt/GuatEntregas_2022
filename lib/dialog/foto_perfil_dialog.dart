import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';

import '../bloc/foto_bloc.dart';
import '../model/cliente_model.dart';
import '../preference/shared_preferences.dart';
import '../providers/cliente_provider.dart';
import '../sistema.dart';
import '../utils/cache.dart' as cache;
import '../utils/personalizacion.dart' as prs;
import '../utils/utils.dart' as utils;

class FotoPerfilDialog extends StatefulWidget {
  final ClienteModel cliente;

  FotoPerfilDialog({this.cliente}) : super();

  FotoPerfilDialogState createState() =>
      FotoPerfilDialogState(cliente: cliente);
}

class FotoPerfilDialogState extends State<FotoPerfilDialog>
    with TickerProviderStateMixin {
  final PreferenciasUsuario _prefs = PreferenciasUsuario();
  final ClienteModel cliente;
  final ClienteProvider _clienteProvider = ClienteProvider();
  final FotoBloc _fotoBloc = FotoBloc();

  FotoPerfilDialogState({this.cliente});

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      title: Text('Cambiar foto'),
      content: Form(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(width: 400.0),
            StreamBuilder(
              stream: _fotoBloc.fotoStream,
              builder: (BuildContext context, snapshot) {
                return ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(100)),
                  child: _imagen(),
                );
              },
            ),
            Sistema.isWeb
                ? Container()
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Container(
                        child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                                primary: prs.colorButtonPrimary,
                                onPrimary: prs.colorTextDescription,
                                elevation: 2.0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0))),
                            icon: Icon(FontAwesomeIcons.image,
                                color: prs.colorIcons, size: 20.0),
                            label: Text('Galería'),
                            onPressed: !_prefs.isExplorar ? _subirFoto : null),
                      ),
                      Container(
                        child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                                primary: prs.colorButtonPrimary,
                                onPrimary: prs.colorTextDescription,
                                elevation: 2.0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0))),
                            icon: Icon(FontAwesomeIcons.camera,
                                color: prs.colorIcons, size: 20.0),
                            label: Text('Cámara'),
                            onPressed: !_prefs.isExplorar ? _tomarFoto : null),
                      ),
                    ],
                  ),
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
            label: Text('CAMBIAR'),
            icon: Icon(FontAwesomeIcons.edit, color: Colors.white, size: 15.0),
            onPressed: () {
              _cambiarFoto();
            }),
      ],
    );
  }

  final picker = ImagePicker();
  String _nombreImagen;

  _tomarFoto() async {
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.camera);
      _fotoBloc.imageFile = File(pickedFile.path);
      if (_fotoBloc.imageFile == null) return;
      _fotoBloc.fotoSink(false);
    } catch (exception) {
      print(exception);
    }
  }

  Widget _imgWeb;

  Widget _imagen() {
    if (_imgWeb != null) return _imgWeb;
    if (_fotoBloc.imageFile != null)
      return Image.file(_fotoBloc.imageFile,
          width: 100, height: 100, fit: BoxFit.cover);
    return cache.fadeImage(cliente.img, width: 100, height: 100);
  }

  XFile pickedFile;

  _subirFoto() async {
    try {
      _fotoBloc.fotoSink(true);
      pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (Sistema.isWeb) {
        _imgWeb = Image.network(pickedFile.path, width: 100.0);
        if (_imgWeb == null) return;
      } else {
        _fotoBloc.imageFile = File(pickedFile.path);
        if (_fotoBloc.imageFile == null) return;
      }
      _fotoBloc.fotoSink(false);
    } catch (exception) {
      print(exception);
    }
  }

  _cambiarFoto() async {
    _nombreImagen =
        '${cliente.idCliente.toString()}-${DateTime.now().microsecondsSinceEpoch.toString()}.jpg';

    String img;
    if (Sistema.isWeb) {
      if (_imgWeb == null) return;
      utils.mostrarProgress(context, barrierDismissible: false);
      img = await _clienteProvider.subirArchivoWeb(
          await pickedFile.readAsBytes(), _nombreImagen);
    } else {
      if (_fotoBloc.imageFile == null) return;
      utils.mostrarProgress(context, barrierDismissible: false);
      img = await _clienteProvider.subirArchivoMobil(
          _fotoBloc.imageFile, _nombreImagen);
    }
    await _clienteProvider.cambiarImagen(img, (estado, error) {});
    ClienteModel _cliente = _prefs.clienteModel;
    _cliente.img = '${Sistema.storage}$img?alt=media';
    _prefs.clienteModel = _cliente;
    _fotoBloc.fotoSink(true);
    Navigator.pop(context);
    Navigator.pop(context);
  }
}
