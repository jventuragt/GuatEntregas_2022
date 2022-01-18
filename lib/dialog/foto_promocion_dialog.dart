import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';

import '../bloc/agencia_bloc.dart';
import '../bloc/catalogo_bloc.dart';
import '../bloc/foto_bloc.dart';
import '../model/promocion_model.dart';
import '../providers/promocion_provider.dart';
import '../sistema.dart';
import '../utils/cache.dart' as cache;
import '../utils/personalizacion.dart' as prs;
import '../utils/utils.dart' as utils;

class FotoPromocionDialog extends StatefulWidget {
  final String agenica;
  final PromocionModel promocion;

  FotoPromocionDialog(this.agenica, {this.promocion}) : super();

  FotoPromocionDialogState createState() =>
      FotoPromocionDialogState(promocion: promocion);
}

class FotoPromocionDialogState extends State<FotoPromocionDialog>
    with TickerProviderStateMixin {
  final PromocionModel promocion;
  final PromocionProvider _promocionProvider = PromocionProvider();
  final FotoBloc _fotoBloc = FotoBloc();

  FotoPromocionDialogState({this.promocion});

  @override
  void initState() {
    _fotoBloc.imageFile = null;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      title: Text(
        widget.agenica,
        style: TextStyle(fontSize: 16.0, color: Colors.red),
        textAlign: TextAlign.center,
      ),
      contentPadding: EdgeInsets.all(0.0),
      content: Form(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(width: 400.0, height: 10.0),
            StreamBuilder(
              stream: _fotoBloc.fotoStream,
              builder: (BuildContext context, snapshot) {
                return ClipRRect(
                  child: _imagen(),
                );
              },
            ),
            Container(
              padding: EdgeInsets.all(10.0),
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
                  onPressed: () {
                    _subirFoto();
                  }),
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
            onPressed: _cambiarFoto),
      ],
    );
  }

  XFile pickedFile;
  final picker = ImagePicker();
  String _nombreImagen;

  Widget _imgWeb;

  Widget _imagen() {
    if (_imgWeb != null) return _imgWeb;
    if (_fotoBloc.imageFile != null)
      return Image.file(_fotoBloc.imageFile,
          width: 260, height: 260, fit: BoxFit.cover);
    return cache.fadeImage(promocion.imagen, width: 260, height: 260);
  }

  _subirFoto() async {
    try {
      _fotoBloc.fotoSink(true);
      pickedFile =
          await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
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

  final CatalogoBloc _catalogoBloc = CatalogoBloc();
  final AgenciaBloc _agenciaBloc = AgenciaBloc();

  _cambiarFoto() async {
    _nombreImagen =
        '${promocion.idPromocion.toString()}-${DateTime.now().microsecondsSinceEpoch.toString()}.jpg';
    if (Sistema.isWeb) {
      if (_imgWeb == null) return;
      utils.mostrarProgress(context, barrierDismissible: false);
      await _promocionProvider.subirArchivoWeb(await pickedFile.readAsBytes(),
          _nombreImagen, promocion.idPromocion.toString());
    } else {
      if (_fotoBloc.imageFile == null) return;
      utils.mostrarProgress(context, barrierDismissible: false);
      await _promocionProvider.subirArchivoMobil(
          _fotoBloc.imageFile,
          _nombreImagen,
          promocion.idPromocion.toString(),
          promocion.idAgencia,
          promocion.idUrbe,
          Sistema.TARGET_WIDTH_PROMO);
    }
    _catalogoBloc.listarPromociones(_agenciaBloc.agenciaSeleccionada.idAgencia,
        isClean: true);
    Navigator.pop(context);
    Navigator.pop(context);
  }
}
