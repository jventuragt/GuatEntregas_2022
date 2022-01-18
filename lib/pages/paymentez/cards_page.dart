import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import '../../bloc/card_bloc.dart';
import '../../card/card_card.dart';
import '../../card/shimmer_card.dart';
import '../../model/card_model.dart';
import '../../model/catalogo_model.dart';
import '../../preference/shared_preferences.dart';
import '../../providers/card_provider.dart';
import '../../providers/catalogo_provider.dart';
import '../../sistema.dart';
import '../../utils/button.dart' as btn;
import '../../utils/cache.dart' as cache;
import '../../utils/dialog.dart' as dlg;
import '../../utils/personalizacion.dart' as prs;
import '../../utils/utils.dart' as utils;
import '../../utils/validar.dart' as val;
import '../delivery/menu_page.dart';
import 'card_page.dart';

class CardsPage extends StatefulWidget {
  final bool isMenu;
  final String title;
  final String idAgencia;
  final String agencia;
  final String img;

  final String monto;
  final String motivo;

  CardsPage(
      {this.idAgencia: '0',
      this.img,
      this.isMenu: false,
      this.title: 'Métodos de pago',
      this.agencia: '',
      this.monto: '',
      this.motivo: ''})
      : super();

  @override
  _CardsPageState createState() => _CardsPageState();
}

class _CardsPageState extends State<CardsPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final CardBloc _cardBloc = CardBloc();
  TextEditingController _textControllerMonto;
  TextEditingController _textControllerMotivo;
  String img;
  bool _saving = false;

  _CardsPageState();

  @override
  void initState() {
    _textControllerMonto = TextEditingController(text: widget.monto);
    _textControllerMotivo = TextEditingController(text: widget.motivo);
    img = cache.img(widget.img);
    _cardBloc.listar(widget.idAgencia);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('${widget.idAgencia == '0' ? '' : 'Pay '}${widget.title}'),
        leading: utils.leading(context),
        actions: [
          Visibility(
            visible: widget.idAgencia == '0',
            child: IconButton(
              icon: prs.iconoObsequio,
              onPressed: _canjearRegalo,
            ),
          ),
        ],
      ),
      key: _scaffoldKey,
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

  void _canjearRegalo() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            contentPadding: EdgeInsets.all(10.0),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 20.0),
                Text('${Sistema.aplicativo} GIFT'),
                SizedBox(height: 10.0),
                Form(
                  key: _formKeyGIFT,
                  child: _crearNombres(),
                ),
                SizedBox(height: 15.0),
                Text('Aplican términos y condiciones.',
                    style: TextStyle(fontSize: 12.0),
                    textAlign: TextAlign.justify),
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
                label: Text('CANJEAR'),
                icon: Icon(
                  FontAwesomeIcons.handHoldingHeart,
                  size: 18.0,
                ),
                onPressed: _canejar,
              ),
            ],
          );
        });
  }

  _canejar() async {
    if (!_formKeyGIFT.currentState.validate()) return;
    FocusScope.of(context).requestFocus(FocusNode());
    _formKeyGIFT.currentState.save();
    Navigator.of(context).pop();
    _saving = true;
    if (mounted) setState(() {});
    await _cardBloc.canejar(_codigo, _analizarRespuesta);
  }

  _analizarRespuesta(estado, String mensaje, CardModel cardModel) {
    _saving = false;
    if (mounted) setState(() {});
    if (estado == 1) {
      fBotonIDerecha() {
        _cardBloc.actualizar(cardModel);
        Navigator.pop(context);
        _irAmenu(cardModel.idAgencia.toString());
      }

      dlg.mostrar(context, mensaje,
          mIzquierda: 'CANCELAR',
          mBotonDerecha: 'VER MENU',
          color: prs.colorButtonSecondary,
          icon: FontAwesomeIcons.store,
          fBotonIDerecha: fBotonIDerecha);
    } else {
      dlg.mostrar(context, mensaje);
    }
  }

  final PreferenciasUsuario _prefs = PreferenciasUsuario();
  final GlobalKey<FormState> _formKeyGIFT = GlobalKey<FormState>();
  String _codigo = '';

  Widget _crearNombres() {
    return TextFormField(
      maxLength: 90,
      autofocus: true,
      textCapitalization: TextCapitalization.characters,
      decoration: prs.decoration('Código GIFT', null),
      onSaved: (value) => _codigo = value,
      validator: val.validarMinimo8,
    );
  }

  final int estadoTarjetaProximamente = 0;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String montoAtrasferir = '0';

  Widget _body() {
    return Column(
      children: <Widget>[
        Expanded(child: SingleChildScrollView(child: _contenido())),
        _prefs.isExplorar || _prefs.isDemo
            ? Container()
            : btn.bootonIcon('AGREGAR NUEVA TARJETA', prs.iconoButtonTarjeta,
                () {
                if (_prefs.estadoTc == estadoTarjetaProximamente)
                  return dlg.mostrar(context, _prefs.mensajeTc);
                showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) {
                      return CardPage(widget.idAgencia, _verificarTarjeta);
                    });
              })
      ],
    );
  }

  Widget _contenido() {
    return Column(
      children: <Widget>[_listaCar()],
    );
  }

  Widget _listaCar() {
    return StreamBuilder(
      stream: _cardBloc.cardStream,
      builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.length > 0)
            return createListView(context, snapshot);
          return Container();
        } else {
          return ShimmerCard();
        }
      },
    );
  }

  Widget createListView(BuildContext context, AsyncSnapshot snapshot) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: snapshot.data.length,
      itemBuilder: (BuildContext context, int index) {
        return _card(context, snapshot.data[index]);
      },
    );
  }

  mostraCargando() {
    _saving = true;
    if (mounted) setState(() {});
  }

  quitarCargando() {
    _saving = false;
    if (mounted) setState(() {});
  }

  CatalogoProvider _catalogoProvider = CatalogoProvider();

  _onTap(CardModel cardModel) async {
    FocusScope.of(context).requestFocus(FocusNode());
    if (cardModel.isValid()) {
      if (widget.idAgencia.toString() == '0') {
        _cardBloc.actualizar(cardModel);
        if (widget.isMenu) {
          if (cardModel.type.toString().toUpperCase() ==
              Sistema.CUPON.toUpperCase()) {
            _irAmenu(cardModel.idAgencia.toString());
          }
        } else {
          Navigator.pop(context);
        }
      } else {
        if (!_formKey.currentState.validate() ||
            cardModel.modo.toUpperCase() != Sistema.TARJETA.toUpperCase())
          return;
        _cardBloc.actualizar(cardModel);
        _formKey.currentState.save();
      }
    } else {
      _cardBloc.listar(widget.idAgencia);
      if (cardModel.isReview()) {
        dlg.mostrar(context,
            'Tarjeta en revisión por favor espera que la misma sea aprobada.');
      } else if (cardModel.isPendig()) {
        _cardBloc.actualizar(cardModel);
        final String idTransaccion =
            '0'; //No hay idTransaccion pues es registro
        _verificarTarjeta(idTransaccion);
      }
    }
  }

  _evaluar(status, idTransaccion, mensaje) async {
    _cardBloc.listar(widget.idAgencia);
    _saving = false;
    if (mounted) setState(() {});
    if (status.toString() == Sistema.IS_ACREDITADO.toString()) {
      print('PROCEDER A COMPRAR');
      _textControllerMonto.text = '';
      _textControllerMotivo.text = '';
      montoAtrasferir = '';
      if (mounted) setState(() {});
      dlg.mostrar(context, mensaje);
    } else if (status == Sistema.IS_TOKEN) {
      print('SOLICITAR OTP PARA VERIFICAR REGISTRO');
      _verificarTarjeta(idTransaccion);
    } else {
      dlg.mostrar(context, mensaje);
    }
  }

  void _verificarTarjeta(dynamic idTransaccion) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            contentPadding: EdgeInsets.all(10.0),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 20.0),
                Text(
                    'Ingresa el código de seguridad OTP que tu banco debió enviarte'),
                SizedBox(height: 10.0),
                Form(
                  key: _formKeyOTP,
                  child: _crearOTP(),
                ),
                SizedBox(height: 15.0),
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
                label: Text('VERIFICAR'),
                icon: Icon(
                  FontAwesomeIcons.handHoldingHeart,
                  size: 18.0,
                ),
                onPressed: () async {
                  if (!_formKeyOTP.currentState.validate()) return;
                  FocusScope.of(context).requestFocus(FocusNode());
                  _formKeyOTP.currentState.save();
                  Navigator.of(context).pop();
                  _saving = true;
                  if (mounted) setState(() {});
                  if (widget.idAgencia.toString() == '0') {
                    await _cardProvider.verificar(
                        _cardBloc.cardSeleccionada, _otp, _evaluar);
                  } else {
                    await _cardProvider.autorizar(_cardBloc.cardSeleccionada,
                        _otp, idTransaccion, _evaluar);
                  }
                },
              ),
            ],
          );
        });
  }

  CardProvider _cardProvider = CardProvider();

  final GlobalKey<FormState> _formKeyOTP = GlobalKey<FormState>();
  String _otp = '';

  Widget _crearOTP() {
    return TextFormField(
      maxLength: 6,
      autofocus: true,
      textCapitalization: TextCapitalization.characters,
      decoration: prs.decoration('Código OTP', null),
      onSaved: (value) => _otp = value,
      validator: val.validarMinimo3,
    );
  }

  _irAmenu(String idAgencia) async {
    _saving = true;
    if (mounted) setState(() {});
    CatalogoModel catalogoModel = await _catalogoProvider.ver(idAgencia);
    _saving = false;
    if (mounted) setState(() {});
    if (catalogoModel == null) return;
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => MenuPage(catalogoModel)));
  }

  Widget _card(BuildContext context, CardModel cardModel) {
    return Slidable(
      key: ValueKey(cardModel.token),
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: CardCard(cardModel: cardModel, onTab: _onTap),
      secondaryActions: <Widget>[
        IconSlideAction(
          color: Colors.red,
          caption: 'Eliminar',
          icon: Icons.delete,
          onTap: () {
            _enviarCancelar() async {
              Navigator.of(context).pop();
              mostraCargando();
              await _cardBloc.eliminar(cardModel);
              quitarCargando();
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Card eliminado correctamente')));
            }

            dlg.mostrar(context, 'Esta acción no se puede revertir!',
                fBotonIDerecha: _enviarCancelar, mBotonDerecha: 'ELIMINAR');
          },
        ),
      ],
    );
  }
}
