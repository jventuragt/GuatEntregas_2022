import 'package:credit_card_type_detector/credit_card_type_detector.dart' as cr;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import '../../bloc/card_bloc.dart';
import '../../model/card_model.dart';
import '../../preference/shared_preferences.dart';
import '../../providers/card_provider.dart';
import '../../sistema.dart';
import '../../utils/button.dart' as btn;
import '../../utils/dialog.dart' as dlg;
import '../../utils/personalizacion.dart' as prs;
import '../../utils/utils.dart' as utils;
import '../../utils/validar.dart' as val;

class CardPage extends StatefulWidget {
  final String idAgencia;
  final Function verificarTarjetaOtp;

  CardPage(this.idAgencia, this.verificarTarjetaOtp, {Key key})
      : super(key: key);

  @override
  State<CardPage> createState() => _CardPage();
}

class _CardPage extends State<CardPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final CardProvider _cardProvider = CardProvider();
  CardModel _cardModel = CardModel();
  final CardBloc _cardBloc = CardBloc();
  final prefs = PreferenciasUsuario();
  String creditCardNumber = '';
  IconData brandIcon;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Registrar tarjeta'),
        leading: utils.leading(context),
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

  Widget _body() {
    return Column(
      children: <Widget>[
        Expanded(child: SingleChildScrollView(child: _contenido())),
        btn.confirmar('REGISTRAR', _registrarTarjeta)
      ],
    );
  }

  Widget _contenido() {
    return Container(
      padding: EdgeInsets.all(20.0),
      child: Column(
        children: <Widget>[
          SizedBox(height: 5.0),
          Text(
            'Para registrar tu tarjeta realizaremos un cargo de un monto aleatorio, el mismo se REVERSARÁ automáticamente.',
            textAlign: TextAlign.justify,
          ),
          SizedBox(height: 10.0),
          Text(Sistema.MENSAJE_NUEVA_CAR, textAlign: TextAlign.justify),
          SizedBox(height: 10.0),
          Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                _crearNumero(),
                SizedBox(height: 20.0),
                Row(
                  children: [
                    _crearMes(),
                    Text('/'),
                    _crearAnio(),
                    Expanded(child: Container()),
                    _cvv(),
                  ],
                ),
                SizedBox(height: 20.0),
                _crearNombres(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _crearNumero() {
    return TextFormField(
      onChanged: (String str) {
        creditCardNumber = str;
        if (mounted) setState(() {});
        cr.CreditCardType brand = cr.detectCCType(str);

        IconData ccBrandIcon;
        if (brand != null) {
          if (brand == cr.CreditCardType.visa) {
            ccBrandIcon = FontAwesomeIcons.ccVisa;
          } else if (brand == cr.CreditCardType.mastercard) {
            ccBrandIcon = FontAwesomeIcons.ccMastercard;
          } else if (brand == cr.CreditCardType.amex) {
            ccBrandIcon = FontAwesomeIcons.ccAmex;
          } else if (brand == cr.CreditCardType.discover) {
            ccBrandIcon = FontAwesomeIcons.ccDiscover;
          } else if (brand == cr.CreditCardType.dinersclub) {
            ccBrandIcon = FontAwesomeIcons.ccDinersClub;
          } else {
            ccBrandIcon = FontAwesomeIcons.creditCard;
          }
        } else {
          ccBrandIcon = FontAwesomeIcons.creditCard;
        }
        brandIcon = ccBrandIcon;
        if (mounted) setState(() {});
      },
      validator: (value) {
        if (value.length <= 8) return 'Número de tarjeta incorrecto';
        return null;
      },
      onSaved: (value) {
        _cardModel.number = value;
      },
      keyboardType: TextInputType.number,
      decoration: prs.decoration('Número de tarjeta', null,
          suffixIcon: brandIcon != null
              ? Icon(brandIcon, color: prs.colorIcons, size: 34)
              : null),
    );
  }

  Widget _crearNombres() {
    return Container(
      child: TextFormField(
          textCapitalization: TextCapitalization.words,
          onSaved: (value) {
            _cardModel.holderName = value;
          },
          validator: val.validarNombre,
          keyboardType: TextInputType.name,
          decoration: prs.decoration('Nombre del titular impreso', null)),
    );
  }

  Widget _crearMes() {
    return Container(
      width: 70.0,
      child: TextFormField(
        maxLength: 2,
        keyboardType: TextInputType.number,
        decoration: prs.decoration('Mes', null),
        onSaved: (value) {
          _cardModel.expiryMonth = value;
        },
        validator: (value) {
          if (value.trim().length < 1) return 'Vencimiento';
          try {
            if (int.parse(value) > 12) return 'Vencimiento';
          } catch (err) {
            return 'Vencimiento';
          }
          return null;
        },
      ),
    );
  }

  Widget _crearAnio() {
    return Container(
      width: 70.0,
      child: TextFormField(
        maxLength: 2,
        keyboardType: TextInputType.number,
        onSaved: (value) {
          _cardModel.expiryYear = value;
        },
        decoration: prs.decoration('Año', null),
        validator: (value) {
          if (value.trim().length < 2) return 'Vencimiento';
          try {
            if (int.parse(value) <= 19) return 'Vencimiento';
          } catch (err) {
            return 'Vencimiento';
          }
          return null;
        },
      ),
    );
  }

  Widget _cvv() {
    return Container(
      width: 80.0,
      child: TextFormField(
        maxLength: 5,
        keyboardType: TextInputType.number,
        decoration: prs.decoration('CVV', null),
        onSaved: (value) {
          _cardModel.cvv = value;
        },
        validator: (value) {
          if (value.trim().length < 3) return 'Error';
          try {
            if (int.parse(value) < 0) return 'Error';
          } catch (err) {
            return 'Error';
          }
          return null;
        },
      ),
    );
  }

  _registrarTarjeta() async {
    FocusScope.of(context).requestFocus(FocusNode());
    if (!_formKey.currentState.validate()) return;

    _saving = true;
    if (mounted) setState(() {});
    _formKey.currentState.save();
    CardModel cardModel = await _cardProvider.crear(_cardModel);

    _cardModel = CardModel();

    _saving = false;
    if (mounted) setState(() {});

    if (cardModel.isReject()) {
      return dlg.mostrar(context,
          'Tarjeta rechazada.\n\nPor favor comunícate con el banco emisor.');
    } else if (cardModel.isPendig()) {
      Navigator.pop(context);
      _cardBloc.listar(widget.idAgencia);
      _cardBloc.actualizar(cardModel);
      final String idTransaccion = '0'; //No hay idTransaccion pues es registro
      widget.verificarTarjetaOtp(idTransaccion);
    } else if (cardModel.isValid()) {
      await _cargar();
      return dlg.mostrar(context, 'Tarjeta aprovada correctamente.');
    } else if (cardModel.isReview()) {
      await _cargar();
      return dlg.mostrar(context,
          'Tarjeta en revisión por favor espera que la misma sea aprobada.');
    } else {
      return dlg.mostrar(context,
          'Tuvimos un problema al registrar tu tarjeta por favor asegúrate de que los datos enviados sean correctos.');
    }
  }

  _cargar() async {
    _saving = true;
    if (mounted) setState(() {});
    await _cardBloc.listar(widget.idAgencia);
    _saving = false;
    Navigator.pop(context);
  }
}
