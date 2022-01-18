import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import '../bloc/cajero_bloc.dart';
import '../bloc/card_bloc.dart';
import '../bloc/catalogo_bloc.dart';
import '../bloc/factura_bloc.dart';
import '../bloc/promocion_bloc.dart';
import '../model/cajero_model.dart';
import '../model/card_model.dart';
import '../model/catalogo_model.dart';
import '../model/direccion_model.dart';
import '../model/factura_model.dart';
import '../model/hashtag_model.dart';
import '../model/promocion_model.dart';
import '../pages/admin/compras_cajero_page.dart';
import '../pages/delivery/catalogo_page.dart';
import '../pages/delivery/compras_despacho_page.dart';
import '../pages/delivery/menu_page.dart';
import '../pages/delivery/verificar_celular_page.dart';
import '../pages/paymentez/cards_page.dart';
import '../preference/db_provider.dart';
import '../preference/shared_preferences.dart';
import '../providers/card_provider.dart';
import '../providers/catalogo_provider.dart';
import '../providers/cliente_provider.dart';
import '../providers/compra_provider.dart';
import '../providers/hashtag_provider.dart';
import '../sistema.dart';
import '../utils/button.dart' as btn;
import '../utils/cache.dart' as cache;
import '../utils/compra.dart' as compra;
import '../utils/conf.dart' as config;
import '../utils/dialog.dart' as dlg;
import '../utils/personalizacion.dart' as prs;
import '../utils/utils.dart' as utils;
import '../utils/validar.dart' as val;
import 'factura_dialog.dart';

class CarritoDialog extends StatefulWidget {
  final double costoTotal;
  final DireccionModel direccionSeleccionadaEntrega;
  final DireccionModel direccionSeleccionadaCliente;
  final CompraProvider compraProvider;
  final List<CajeroModel> cajeros;
  final PromocionModel promocion;
  final int tipo;

  CarritoDialog(this.tipo,
      {this.promocion,
      this.costoTotal,
      this.direccionSeleccionadaEntrega,
      this.direccionSeleccionadaCliente,
      this.compraProvider,
      this.cajeros})
      : super();

  CarritoDialogState createState() => CarritoDialogState(tipo,
      direccionSeleccionadaCliente: direccionSeleccionadaCliente,
      promocion: promocion,
      cajeros: cajeros,
      costoTotal: costoTotal,
      direccionSeleccionadaEntrega: direccionSeleccionadaEntrega,
      compraProvider: compraProvider);
}

class CarritoDialogState extends State<CarritoDialog>
    with TickerProviderStateMixin {
  CatalogoProvider _catalogoProvider = CatalogoProvider();

  final PromocionModel promocion;
  bool _isLineProgress = false;
  double descuentoPorCupon = 0.0;
  double costoTotal;
  double promocionValor = 0.0;
  int promocionIdAgencia = -1;
  dynamic promocionIdHashtag = -1;
  final List<CajeroModel> cajeros;
  final DireccionModel direccionSeleccionadaCliente;
  final DireccionModel direccionSeleccionadaEntrega;
  final PromocionBloc _promocionBloc = PromocionBloc();
  final CajeroBloc _cajeroBloc = CajeroBloc();
  final _facturaBloc = FacturaBloc();
  final _cardBloc = CardBloc();
  final _cardProvider = CardProvider();
  final CompraProvider compraProvider;
  final CatalogoBloc _catalogoBloc = CatalogoBloc();
  final int tipo;
  final HashtagProvider _hashtagProvider = HashtagProvider();
  final ClienteProvider _clienteProvider = ClienteProvider();
  String _celular = '';

  CarritoDialogState(this.tipo,
      {this.promocion,
      this.costoTotal,
      this.direccionSeleccionadaCliente,
      this.direccionSeleccionadaEntrega,
      this.compraProvider,
      this.cajeros});

  TextEditingController _controllerMetodoPago = TextEditingController();

  @override
  void initState() {
    _celular = _prefs.clienteModel.celular;
    if (_celular.length < 2) _celular = '09';
    super.initState();
    _controllerMetodoPago.text = _cardBloc.cardSeleccionada.number;
    _inputFieldDateController = TextEditingController(text: '');
    _facturaBloc.facturaSeleccionada = FacturaModel();
    _facturaBloc.obtener();
    _cardBloc.cardSeleccionadaStream.listen((CardModel card) {
      descuentoPorCupon = 0.0;
      if (card?.modo.toString().toUpperCase() == Sistema.CUPON.toUpperCase()) {
        if (!mounted) return;
        _evaluarCupon(card);
      } else {
        _agregarFormaPagoCajero(card);
      }
      if (mounted) if (mounted) setState(() {});
    });
    if (_cardBloc.cardSeleccionada.modo.toString().toUpperCase() ==
        Sistema.CUPON.toUpperCase()) {
      _isLineProgress = true;
      if (mounted) setState(() {});
      if (descuentoPorCupon <= 0) {
        Future.delayed(const Duration(milliseconds: 1150), () async {
          _cardBloc.actualizar(_cardBloc.cardSeleccionada);
          _isLineProgress = false;
          if (mounted) setState(() {});
        });
      }
    }
  }

  _agregarFormaPagoCajero(CardModel card) {
    cajeros.forEach((cajero) {
      cajero.cardModel = card;
    });
  }

  _evaluarCupon(CardModel card) {
    if (card?.modo.toString().toUpperCase() == Sistema.CUPON.toUpperCase()) {
      _cardBloc.cardSeleccionada = card;
      bool isCuponvalido = false;
      cajeros.forEach((CajeroModel cajero) {
        if (cajero.idAgencia.toString() == card.idAgencia.toString()) {
          isCuponvalido = true;
          cajero.cardModel = card;
          descuentoPorCupon =
              cajero.total() > card.cupon ? card.cupon : cajero.total();
          cajero.credito = descuentoPorCupon;
          cajero.creditoEnvio = descuentoPorCupon >= cajero.costoEnvio
              ? cajero.costoEnvio
              : descuentoPorCupon;
          double creditoProducto = descuentoPorCupon - cajero.costoEnvio;
          cajero.creditoProducto = descuentoPorCupon >= cajero.total()
              ? cajero.costo
              : creditoProducto <= 0
                  ? 0
                  : creditoProducto;
        } else {
          cajero.cardModel = CardModel();
        }
      });
      if (!isCuponvalido) {
        _cardBloc.actualizar(CardModel());
        fBotonDerecha() async {
          Navigator.of(context).pop();
          _update();
          CatalogoModel catalogoModel =
              await _catalogoProvider.ver(card.idAgencia);
          _cardBloc.cardSeleccionada = card;
          _complet();
          Navigator.of(context).pop();
          if (catalogoModel == null) return;
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => MenuPage(catalogoModel)),
              (Route<dynamic> route) {
            return route.isFirst;
          });
        }

        fIzquierda() async {
          Navigator.of(context).pop();
        }

        dlg.mostrar(context, card.mensaje,
            mBotonDerecha: 'VER CATÁLOGO',
            fBotonIDerecha: fBotonDerecha,
            fIzquierda: fIzquierda,
            mIzquierda: 'CANCELAR',
            icon: Icons.touch_app,
            color: prs.colorButtonSecondary);
      }
    }
  }

  bool _saving = false;
  TextEditingController _inputFieldDateController;

  Widget _crearCodigo() {
    return TextFormField(
      controller: _inputFieldDateController,
      textCapitalization: TextCapitalization.words,
      decoration: prs.decoration('Hashtag promocional', prs.iconoCodigo),
    );
  }

  _canjer(String codigo) async {
    FocusScope.of(context)?.requestFocus(FocusNode());
    promocionIdAgencia = -1;
    promocionValor = 0.0;
    promocionIdHashtag = -1;
    _update();
    HashtagModel _hashtag =
        await _hashtagProvider.ver(codigo.toLowerCase().trim(), cajeros);
    _complet();

    //Cuando no hay internet, paso algo y no se respondio status 200 desde servidor
    if (_hashtag.estado == -2) {
      return dlg.mostrar(context, _hashtag.error);
    }
    //Cuando el codigo es errone pero se respondio desde servidor correctamtnete
    else if (_hashtag.estado == -1) {
      //Cuanod el # es incorrecto y se confirma la compra cerramos el dialog
      dlg.mostrar(context,
          'Por favor revisa su escritura o continua con la compra simplemente tocando de nuevo el botón (COMPRAR)',
          titulo: 'Hashtag incorrecto',
          mIzquierda: 'ACEPTAR',
          color: prs.colorButtonSecondary);
      return;
    }
    //Cuando el codigo es correcto pero de agencia diferente
    else if (_hashtag.estado == 2) {
      fBotonDerecha() async {
        Navigator.of(context).pop();
        _update();

        CatalogoModel catalogoModel =
            await _catalogoProvider.ver(_hashtag.idAgencia);
        Navigator.of(context).pop();
        _complet();
        if (catalogoModel == null) return;
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => MenuPage(catalogoModel)),
            (Route<dynamic> route) {
          return route.isFirst;
        });
      }

      return dlg.mostrar(context, _hashtag.error,
          mBotonDerecha: _hashtag.mBotonDerecha,
          fBotonIDerecha: _hashtag.isBotonDerecha() ? fBotonDerecha : null,
          mIzquierda: _hashtag.mIzquierda,
          icon: Icons.touch_app,
          color: prs.colorButtonSecondary);
    }
    //Codigo correcto
    else if (_hashtag.estado == 1) {
      promocionIdAgencia = _hashtag.idAgencia;
      promocionValor = _hashtag.promocion;
      promocionIdHashtag = _hashtag.idHashtag;
      relizarCompra();
    }
    if (mounted) setState(() {});
  }

  bool _isEfectivo = true;

  String _costoMostrado = '0.00';
  List<String> _compraSucursal = [];
  List<String> _compraCosto = [];
  List<String> _compraEnvio = [];
  List<String> _compraDetalle = [];
  double _pay = 0.0;

  Future<List<DataRow>> _costoProductos(List<CajeroModel> cajeros) async {
    // _isEfectivo = _controllerMetodoPago.text == Sistema.efectivo;
    List<PromocionModel> promocionesAComprar;
    double _saldo = cajeros[0].saldoMoney;
    double _costoTotal = costoTotal;
    double _moneyDescontado = 0.0;
    List<DataRow> rows = [];
    _costoMostrado = '0.00';
    _compraSucursal.clear();
    _compraCosto.clear();
    _compraEnvio.clear();
    _compraDetalle.clear();
    _pay = 0.0;
    for (CajeroModel cajero in cajeros) {
      _pay = cajero.pay; //Guaramos en una variable el pay que posee el cliente.
      cajero.costo = 0.0;
      cajero.evaluar(_saldo);
      _saldo = _saldo - cajero.costoEnvio;
      if (_saldo <= 0) _saldo = 0.0;

      promocionesAComprar =
          await DBProvider.db.listarPorAgencia(cajero.idAgencia);

      _compraDetalle.add('${cajero.sucursal}');

      for (var promocion in promocionesAComprar) {
        cajero.costo += promocion.costoTotal;
        _compraDetalle.add(
            '${promocion.cantidad} ${promocion.producto} ${promocion.costoTotal.toStringAsFixed(2)}');
      }

      _costoTotal =
          _costoTotal - cajero.descontado + cajero.costoPorcentaje(_isEfectivo);

      //Costo en esta linea importante
      _compraSucursal.add('${cajero.sucursal}');
      _compraCosto.add('${cajero.costo.toStringAsFixed(2)}');
      _compraEnvio.add('${cajero.costoEnvio.toStringAsFixed(2)}');

      rows.add(DataRow(cells: [
        DataCell(Text(cajero.sucursal)),
        DataCell(Text(cajero.isTarjeta == 0 ? '💵' : '💳 💵')),
        DataCell(Text(cajero.costoFormaPago(_isEfectivo).toStringAsFixed(2))),
        DataCell(Text('${cajero.costoEnvio.toStringAsFixed(2)}')),
      ]));

      _moneyDescontado = _moneyDescontado + cajero.descontado;
    }

    if (_moneyDescontado > 0) {
      rows.add(DataRow(
          onSelectChanged: (select) {
            return dlg.mostrar(context,
                'Se descuenta automáticamente para cubrir el costo o parte del costo de entrega.\n\nAl invitar a tus amigos a usar Curiosity tienes mayor probabilidad de obtener money.\n\nVe al Menú, (Insignia & Money) para aprender más.',
                titulo: 'Curiosity Money');
          },
          cells: [
            DataCell(Text('Curiosity Money (Descuento exclusivo)')),
            DataCell(Text('')),
            DataCell(Text('')),
            DataCell(Text(
              '-${_moneyDescontado.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            )),
          ]));
    }

    if (_pay > 0) {
      rows.add(DataRow(
          onSelectChanged: (select) {
            return dlg.mostrar(context,
                'Tienes ${_pay.toStringAsFixed(2)} USD de Cash.\n\nEste dinero permite pagar productos y envío',
                titulo: 'Curiosity Cash');
          },
          cells: [
            DataCell(Text('Curiosity Cash')),
            DataCell(Text('')),
            DataCell(Text('')),
            DataCell(Text(
              '-${_pay.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            )),
          ]));
    }

    if (descuentoPorCupon > 0) {
      rows.add(DataRow(
          onSelectChanged: (select) {
            return dlg.mostrar(context, _cardBloc.cardSeleccionada.terminos);
          },
          cells: [
            DataCell(Text(
              _cardBloc.cardSeleccionada.number,
              style: TextStyle(color: Colors.deepPurple),
            )),
            DataCell(Text('')),
            DataCell(Text(
              _cardBloc.cardSeleccionada.holderName,
              style: TextStyle(color: Colors.deepPurple),
            )),
            DataCell(Text(
              '${_cardBloc.cardSeleccionada.cupon.toStringAsFixed(2)}',
              style: TextStyle(
                  fontSize: 17.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple),
            )),
          ]));
      _costoTotal = _costoTotal - descuentoPorCupon;
    }

    _costoTotal = _costoTotal - _pay;
    if (_costoTotal < 0) _costoTotal = 0.0;

    _costoMostrado = _costoTotal.toStringAsFixed(2);
    rows.add(DataRow(cells: [
      DataCell(Text('Total a pagar',
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold))),
      DataCell(Text('')),
      DataCell(Text('')),
      DataCell(Text(
        '$_costoMostrado',
        style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
      )),
    ]));

    return rows;
  }

  Widget _table(List<CajeroModel> cajeros) {
    return FutureBuilder<List<DataRow>>(
      future: _costoProductos(cajeros),
      builder: (context, isAvailableSnapshot) {
        if (!isAvailableSnapshot.hasData) {
          return Container();
        }
        return DataTable(
            dividerThickness: 2.0,
            showCheckboxColumn: false,
            columnSpacing: 10.0,
            columns: [
              DataColumn(
                  label: Text("Local",
                      style: TextStyle(
                        color: prs.colorTextTitle,
                        fontSize: 15.0,
                      ))),
              DataColumn(
                  label: Text(
                    "Acepta",
                    style: TextStyle(
                      color: prs.colorTextTitle,
                      fontSize: 15.0,
                    ),
                  ),
                  numeric: true),
              DataColumn(
                  label: Text(
                    "Prod..",
                    style: TextStyle(
                      color: prs.colorTextTitle,
                      fontSize: 15.0,
                    ),
                  ),
                  numeric: true),
              DataColumn(
                  label: Text(
                    "Envío",
                    style: TextStyle(
                      color: prs.colorTextTitle,
                      fontSize: 15.0,
                    ),
                  ),
                  numeric: true),
            ],
            rows: isAvailableSnapshot.data);
      },
    );
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Referencia: ${direccionSeleccionadaEntrega.alias}'),
      ),
      body: ModalProgressHUD(
        inAsyncCall: _saving,
        child: Center(
            child: Container(child: _body(), width: prs.anchoFormulario)),
      ),
    );
  }

  _comprar() {
    final String codigo = _inputFieldDateController.text;
    _inputFieldDateController.text = '';
    if (codigo.length > 0)
      _canjer(codigo);
    else
      relizarCompra();
  }

  Widget _body() {
    return Column(
      children: <Widget>[
        Visibility(
            visible: _isLineProgress,
            child: LinearProgressIndicator(
                backgroundColor: prs.colorLinearProgress)),
        Expanded(
          child: Container(
            padding: EdgeInsets.only(left: 20.0, right: 20.0),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SizedBox(height: 10.0),
                    _table(cajeros),
                    SizedBox(height: 20.0),
                    _createPanelPago(),
                    _numero(),
                    SizedBox(height: 10.0),
                    _facturas(context),
                    SizedBox(height: 10.0),
                    _crearCodigo(),
                  ],
                ),
              ),
            ),
          ),
        ),
        btn.confirmar('COMPRAR', !_isLineProgress ? _comprar : null)
      ],
    );
  }

  Widget _numero() {
    return _prefs.clienteModel.celularValidado != 1 &&
            _cardBloc.cardSeleccionada.isTarjeta()
        ? Container(
            padding: EdgeInsets.only(top: 10.0),
            child: utils.crearCelular(_prefs.simCountryCode, _onChangedCelular,
                celular: _celular),
          )
        : Container();
  }

  _onChangedCelular(phone) {
    _celular = phone.toString();
  }

  final PreferenciasUsuario _prefs = PreferenciasUsuario();

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

  void _verificarTarjeta(dynamic idTransaccion) {
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
                  await _cardProvider.autorizar(_cardBloc.cardSeleccionada,
                      _otp, idTransaccion, _evaluar);
                },
              ),
            ],
          );
        });
  }

  _evaluar(status, idTransaccion, mensaje) async {
    _saving = false;
    if (mounted) setState(() {});
    if (status == Sistema.IS_ACREDITADO) {
      print('PROCEDER A COMPRAR');

      //Cuanod no es validado el celular pero es de tipo tarjeta enviamos a cervidor el celular ingresado por el cliente
      if (_prefs.clienteModel.celularValidado != 1) {
        _clienteProvider.validadCelular(_celular);
      }

      _agregarCreditoYConfirmarRelaizarCompra(idTransaccion);
    } else if (status == Sistema.IS_TOKEN) {
      print('SOLICITAR OTP');
      print(idTransaccion);
      _verificarTarjeta(idTransaccion);
    } else {
      dlg.mostrar(context, mensaje);
    }
  }

  _agregarCreditoYConfirmarRelaizarCompra(String idCash) {
    for (CajeroModel cajero in cajeros) {
      cajero.cash = cajero
          .total(); //Todo el pago se realiza con cash pues la forma de pago de credito cubre todo.
      cajero.credito = cajero.total();
      cajero.creditoEnvio = cajero.costoEnvio;
      cajero.creditoProducto = cajero.costo;
      cajero.idCash = idCash;
    }
    _confirmarRelizarCompra();
  }

  relizarCompra() async {
    FocusScope.of(context).requestFocus(FocusNode());

    if (_cardBloc.cardSeleccionada.isTarjeta()) {
      if (!_formKey.currentState.validate()) {
        return;
      }

      _update();
      double _costo = double.parse(_costoMostrado);

      double _regalo = 0.0;
      for (CajeroModel cajero in cajeros) {
        if (cajero.idAgencia == promocionIdAgencia) {
          _regalo =
              promocionValor; //El valor del money no se suma por que el valor q se muestra ya lo resta
          if (_regalo > cajero.costoEnvio) _regalo = cajero.costoEnvio;
          _costo = _costo - _regalo + cajero.descontado;
        }
      }

      if (_costo <= 0) _costo = 0.0;
      await _cardProvider.debitar(
          _cardBloc.cardSeleccionada,
          _costo.toStringAsFixed(2),
          _pay.toStringAsFixed(2),
          _compraSucursal,
          _compraCosto,
          _compraEnvio,
          _compraDetalle,
          _evaluar);
    } else {
      _confirmarRelizarCompra();
    }
  }

  _agregarDescuentosYconfirmarCompra() {
    //Asignamos cash en cero para no evaluar en el bucle el credito peusto  esto se hace un recargo al final total con l a tarjeta
    double _auxCash = _cardBloc.cardSeleccionada.isTarjeta() ? 0.0 : _pay;
    for (CajeroModel cajero in cajeros) {
      if (cajero.idAgencia == promocionIdAgencia) {
        cajero.idHashtag = promocionIdHashtag;
        cajero.descuento = promocionValor;
      }
      if (_auxCash > 0) {
        double _usoCash =
            _auxCash >= cajero.total() ? cajero.total() : _auxCash;
        _auxCash = _auxCash - _usoCash;
        _usoCash = _usoCash - cajero.credito - cajero.descontado;
        if (_usoCash < 0) _usoCash = 0.0;
        cajero.cash = _usoCash;
        cajero.credito = _usoCash;
        //Este no necesita validacion por que ya se controla q el credito sea cero y no menor de cero
        cajero.creditoEnvio = cajero.credito >= cajero.costoEnvio
            ? cajero.costoEnvio
            : cajero.credito;
        //En este punto costo mantiene el costo del producto y total es la suma del costo mas envio credito seria lo mismo
        cajero.creditoProducto = cajero.credito >= cajero.total()
            ? cajero.costo
            : cajero.credito - cajero.costoEnvio;
        if (cajero.creditoProducto < 0) cajero.creditoProducto = 0.0;
      }
      _confirmar(cajero, direccionSeleccionadaEntrega);
    }
  }

  _confirmarRelizarCompra() {
    if (_prefs.clienteModel.celularValidado == 1 ||
        _cardBloc.cardSeleccionada.isTarjeta()) {
      _agregarDescuentosYconfirmarCompra();
    } else {
      _accionCelularVerificado() {
        _agregarDescuentosYconfirmarCompra();
      }

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  VerificarCelularPage(_accionCelularVerificado)));
    }
  }

  _update() {
    _saving = true;
    if (mounted) if (mounted) setState(() {});
  }

  _complet() {
    _saving = false;
    if (mounted) if (mounted) setState(() {});
  }

  _confirmar(CajeroModel cajeroModel, DireccionModel direccionEntrega) async {
    _update();

    double costo = 0.0;

    List<PromocionModel> promocionesAComprar;

    //La promocion viende desde serviicois help
    if (promocion == null) {
      promocionesAComprar =
          await DBProvider.db.listarPorAgencia(cajeroModel.idAgencia);
    } else {
      promocionesAComprar = [];
      promocionesAComprar.add(promocion);
    }

    promocionesAComprar.forEach((PromocionModel promocion) {
      costo += promocion.costoTotal;
    });
    _cardBloc.cardSeleccionada = CardModel();
    compraProvider.iniciar(tipo, cajeroModel.idCajero, cajeroModel.idSucursal,
        direccionSeleccionadaEntrega, cajeroModel.costoEnvio.toStringAsFixed(2),
        (estado, mensaje, CajeroModel nuevoCajeroModel) {
      if (estado == -100) {
        _complet();
        if (mounted) dlg.mostrar(context, mensaje);
        return;
      }

      if (estado <= 0) {
        _fAceptar() {
          _complet();
          if (_prefs.clienteModel.perfil.toString() ==
              config.TIPO_CLIENTE.toString()) {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => CatalogoPage()),
                (Route<dynamic> route) {
              return false;
            });
          } else if (_prefs.clienteModel.perfil.toString() ==
              config.TIPO_ASESOR.toString()) {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => ComprasCajeroPage()),
                (Route<dynamic> route) {
              return false;
            });
          } else {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => ComprasDespachoPage()),
                (Route<dynamic> route) {
              return false;
            });
          }
        }

        return dlg.mostrar(context, mensaje,
            fIzquierda: _fAceptar,
            mIzquierda: 'CANCELAR',
            mBotonDerecha: 'COMPRAR',
            color: prs.colorButtonSecondary,
            icon: Icons.monetization_on);
      }
      _limpiarCarrito();
      _verDespacho(nuevoCajeroModel);
    },
        cajero: cajeroModel,
        direccionCliente: direccionSeleccionadaCliente,
        facturaModel: _facturaBloc.facturaSeleccionada,
        promociones: promocionesAComprar,
        costoTotal: costo + cajeroModel.costoEnvio,
        costo: costo);
  }

  _verDespacho(CajeroModel cajeroModel) {
    String mensaje = 'Solicitud confirmada';
    compra.despachoPage(context, cajeroModel, mensaje, config.TIPO_CLIENTE);
  }

  _limpiarCarrito() async {
    for (var i = 0; i < _promocionBloc.promociones.length; i++) {
      if (_promocionBloc.promociones[i].isComprada) {
        _promocionBloc.promociones[i].isComprada = false;
        _promocionBloc.actualizar(_promocionBloc.promociones[i]);
      }
    }

    for (var i = 0; i < _catalogoBloc.promociones.length; i++) {
      if (_catalogoBloc.promociones[i].isComprada) {
        _catalogoBloc.promociones[i].isComprada = false;
        _catalogoBloc.actualizar(_catalogoBloc.promociones[i]);
      }
    }

    await DBProvider.db
        .eliminarPromocionPorUrbe(direccionSeleccionadaEntrega.idUrbe);
    _promocionBloc.carrito();
    _cajeroBloc.listarEnCamino();
  }

  Widget _createPanelPago() {
    return StreamBuilder(
      stream: _cardBloc.cardSeleccionadaStream,
      builder: (BuildContext context, AsyncSnapshot<CardModel> snapshot) {
        if (snapshot.hasData) {
          _controllerMetodoPago.text = snapshot.data.number;
          if (snapshot.data.modo.toString().toUpperCase() ==
              Sistema.CUPON.toUpperCase()) {
            Widget icon = Container(
              width: 57.0,
              height: 45.0,
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                child: cache.fadeImage(snapshot.data.token),
              ),
            );
            return _formaPago(icon);
          }
        }
        return _formaPago(_cardBloc.cardSeleccionada.iconoTarjeta());
      },
    );
  }

  Widget _formaPago(Widget ccBrandIcon) {
    return TextField(
        controller: _controllerMetodoPago,
        readOnly: true,
        onTap: () {
          String agencias = '';
          for (CajeroModel cajero in cajeros) {
            if (cajero.isTarjeta == 0) agencias += ' ${cajero.sucursal}';
          }

          if (agencias != '') {
            return dlg.mostrar(context,
                'Lo sentimos$agencias, solo acepta efectivo.\n\nTiendas con el icono (💳), aceptan tarjeta.');
          } else {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => CardsPage()));
          }
        },
        keyboardType: TextInputType.number,
        decoration: prs.decoration('Método de pago', prs.iconoMetodoPago,
            suffixIcon: ccBrandIcon));
  }

  Widget _facturas(BuildContext context) {
    return StreamBuilder(
      stream: _facturaBloc.facturaStream,
      builder:
          (BuildContext context, AsyncSnapshot<List<FacturaModel>> snapshot) {
        if (snapshot.hasData) {
          return createExpanPanel(snapshot.data);
        } else {
          return Container(child: Center(child: CircularProgressIndicator()));
        }
      },
    );
  }

  Widget createExpanPanel(List<FacturaModel> facturas) {
    return DropdownButtonFormField(
      isDense: true,
      decoration: prs.decoration('', prs.iconoFactura),
      validator: (value) {
        if (_facturaBloc.facturaSeleccionada.idFactura <= 0)
          return 'Datos de factura';
        return null;
      },
      hint: (_facturaBloc.facturaSeleccionada.idFactura <= 0)
          ? Text('Datos de factura')
          : Text(_facturaBloc.facturaSeleccionada.dni),
      items: facturas.map((FacturaModel factura) {
        if (factura.idFactura <= 0)
          return DropdownMenuItem<FacturaModel>(
            value: factura,
            child: Text('Datos de factura'),
          );
        return DropdownMenuItem<FacturaModel>(
          value: factura,
          child: Text('Facturar a: ${factura.dni}'),
        );
      }).toList(),
      onChanged: (FacturaModel value) {
        _facturaBloc.facturaSeleccionada = value;
        if (value.idFactura <= 0)
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return FacturaDialog(facturaModel: value);
              });
      },
    );
  }
}
