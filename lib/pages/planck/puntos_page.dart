import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share/share.dart';

import '../../model/cliente_model.dart';
import '../../preference/shared_preferences.dart';
import '../../providers/cliente_provider.dart';
import '../../sistema.dart';
import '../../utils/button.dart' as btn;
import '../../utils/cache.dart' as cache;
import '../../utils/dialog.dart' as dlg;
import '../../utils/personalizacion.dart' as prs;
import '../../utils/utils.dart' as utils;

class PuntosPage extends StatefulWidget {
  PuntosPage({Key key}) : super(key: key);

  @override
  State<PuntosPage> createState() => _PuntosPageState();
}

class _PuntosPageState extends State<PuntosPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final ClienteProvider _clienteProvider = ClienteProvider();
  ClienteModel _cliente = ClienteModel();

  _PuntosPageState();

  final PreferenciasUsuario prefs = PreferenciasUsuario();
  ClienteModel cliente = ClienteModel();
  bool _saving = false;
  TextEditingController _textControllerSaldo;
  TextEditingController _textControllerCash;
  TextEditingController _textControllerCredito;

  @override
  void initState() {
    super.initState();
    _cliente = prefs.clienteModel;
    _textControllerCash = TextEditingController(text: 'Consultando...');
    _textControllerSaldo = TextEditingController(text: 'Consultando...');
    _textControllerCredito = TextEditingController(text: 'Consultando...');

    _clienteProvider.saldo(prefs.idCliente, (saldo, credito, cash) {
      _textControllerSaldo.text = saldo;
      _textControllerCredito.text = credito;
      _textControllerCash.text = cash;
      if (mounted) if (mounted) setState(() {});
    });
    _obtenerLink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text('Insignia'),
        leading: utils.leading(context),
      ),
      body: ModalProgressHUD(
        color: Colors.black,
        opacity: 0.4,
        progressIndicator: utils.progressIndicator('Cargando...'),
        inAsyncCall: _saving,
        child: Center(
            child: Container(child: _body(), width: prs.anchoFormulario)),
      ),
    );
  }

  Widget _body() {
    return Column(
      children: <Widget>[
        Expanded(child: SingleChildScrollView(child: _contenido())),
        btn.booton('INVITAR AMIGOS', _inivtarAmigod)
      ],
    );
  }

  _inivtarAmigod() async {
    String link = await _obtenerLink();
    if (link == null)
      return dlg.mostrar(context,
          'Ups. Lo sentimos ocurrió un problema, intenta de nuevo más tarde.');
    Share.share('$link ${Sistema.MESAJE_SHARE_LINK}');
  }

  Future<String> _obtenerLink() async {
    if (_cliente.link.length > 10) return _cliente.link;
    _saving = true;
    if (mounted) setState(() {});
    String link;
    try {
      final DynamicLinkParameters parameters = DynamicLinkParameters(
        uriPrefix: Sistema.uriPrefix,
        link: Uri.parse(
            '${Sistema.uriDynamic}?auth=${_cliente.idCliente}&token=${DateTime.now().millisecondsSinceEpoch}'),
        androidParameters: AndroidParameters(
            packageName: Sistema.packageName,
            minimumVersion: Sistema.MINUMUN_VERSION),
        iosParameters: IosParameters(
            bundleId: Sistema.packageName, appStoreId: Sistema.appStoreId),
        googleAnalyticsParameters: GoogleAnalyticsParameters(
            campaign: 'ref-${Sistema.aplicativo}',
            medium: 'social',
            source: 'orkut'),
      );

      final Uri dynamicUrl = await parameters.buildUrl();

      link = dynamicUrl
          .toString()
          .replaceFirst('/', '', dynamicUrl.toString().length - 1);

      final ShortDynamicLink shortenedLink =
          await DynamicLinkParameters.shortenUrl(
        Uri.parse(link),
        DynamicLinkParametersOptions(
            shortDynamicLinkPathLength: ShortDynamicLinkPathLength.short),
      );

      link = shortenedLink.shortUrl.toString();

      link = link.toString().replaceFirst('/', '', link.toString().length - 1);

      _clienteProvider.link(_cliente.idCliente, link);
      _cliente.link = link;
      prefs.clienteModel = _cliente;
    } catch (err) {
      print('puntos_page _obtenerLink err $err');
    }
    _saving = false;
    if (mounted) setState(() {});
    return link;
  }

  Widget _avatar() {
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(100)),
      child: cache.fadeImage(_cliente.img, width: 130, height: 130),
    );
  }

  Column _contenido() {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(top: 10.0, right: 20.0, left: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Stack(
                children: <Widget>[
                  CircularPercentIndicator(
                    radius: 150.0,
                    lineWidth: 7.0,
                    animation: true,
                    percent: (_cliente.registros > 0)
                        ? (_cliente.correctos / _cliente.registros)
                        : 1.0,
                    center: _avatar(),
                    circularStrokeCap: CircularStrokeCap.round,
                    progressColor: prs.colorButtonSecondary,
                  ),
                  Positioned(
                    top: 85.0,
                    left: 85.0,
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(100)),
                      child: FadeInImage(
                        placeholder: AssetImage('assets/no-image.png'),
                        fit: BoxFit.cover,
                        image: NetworkImage(
                            '${Sistema.dominio}cliente/insignia/${_cliente.puntos}'),
                        height: 70,
                        width: 70,
                      ),
                    ),
                  )
                ],
              ),
              _estrellas(),
              Text(
                "Correctas: ${_cliente.correctos} - Canceladas: ${_cliente.canceladas}",
                style: TextStyle(fontSize: 12.0),
              ),
              _crearCash(),
              _crearSaldo(),
              _crearCredito(),
              SizedBox(height: 20.0),
              _crearLink(),
              SizedBox(height: 15.0),
              QrImage(data: _cliente.link, version: QrVersions.auto, size: 150),
              SizedBox(height: 15.0),
              Text(Sistema.slogan, textAlign: TextAlign.center),
              SizedBox(height: 20.0),
            ],
          ),
        ),
      ],
    );
  }

  Widget _crearCash() {
    return TextFormField(
      readOnly: true,
      controller: _textControllerCash,
      decoration: InputDecoration(
          suffixIcon: IconButton(
            icon: Icon(Icons.live_help, size: 27.0),
            onPressed: () async {
              if (Sistema.idAplicativo != Sistema.idAplicativoCuriosity) return;
              return dlg.mostrar(
                  context, 'Tu nueva forma de pago sin usar efectivo.',
                  titulo: '${Sistema.aplicativoTitle} Cash.',
                  color: prs.colorButtonSecondary,
                  mBotonDerecha: 'REGRESAR',
                  icon: FontAwesomeIcons.handHoldingUsd);
            },
          ),
          hintText: '${Sistema.aplicativoTitle} Cash',
          labelText: '${Sistema.aplicativoTitle}  Cash',
          icon: prs.iconoCahs),
    );
  }

  Widget _crearSaldo() {
    return Visibility(
      visible: Sistema.idAplicativo == Sistema.idAplicativoCuriosity,
      child: TextFormField(
        readOnly: true,
        controller: _textControllerSaldo,
        decoration: InputDecoration(
            suffixIcon: IconButton(
              icon: Icon(Icons.help_outline, size: 27.0),
              onPressed: () async {
                return dlg.mostrar(context,
                    'Con money puedes pagar el costo o parte del costo de entrega. \n\nAl invitar a tus amigos a usar Curiosity tienes mayor probabilidad de obtener money.',
                    titulo: 'Curiosity Money');
              },
            ),
            hintText: 'Curiosity Money',
            labelText: 'Curiosity Money',
            icon: prs.iconoMoney),
      ),
    );
  }

  Widget _crearCredito() {
    return Visibility(
      visible: prefs.clienteModel.perfil.toString() == '2',
      child: TextFormField(
        readOnly: true,
        controller: _textControllerCredito,
        decoration: InputDecoration(
            suffixIcon: Icon(FontAwesomeIcons.dollarSign,
                color: Colors.green, size: 27.0),
            hintText: 'Crédito',
            labelText: 'Crédito',
            icon: prs.iconoCredito),
      ),
    );
  }

  Widget _crearLink() {
    return TextFormField(
      readOnly: true,
      initialValue: _cliente.nombres,
      decoration: InputDecoration(
          suffixIcon: IconButton(
            icon: Icon(Icons.content_copy),
            onPressed: () async {
              String link = await _obtenerLink();
              if (link == null)
                return dlg.mostrar(context,
                    'Ups. Lo sentimos ocurrió un problema, intenta de nuevo más tarde.');
              Clipboard.setData(new ClipboardData(text: link));
              utils.mostrarSnackBar(context, 'Se copió en el portapapeles');
            },
          ),
          hintText: 'Tu link',
          labelText: 'Tu link',
          icon: prs.iconoLink),
      onSaved: (value) => _cliente.nombres = value,
    );
  }

  Widget _estrellas() {
    return utils.estrellas(
        (_cliente.calificacion / _cliente.calificaciones), (value) {});
  }
}
