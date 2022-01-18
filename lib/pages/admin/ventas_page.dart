import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../bloc/horario_bloc.dart';
import '../../card/shimmer_card.dart';
import '../../card/tarjeta_card.dart';
import '../../model/cliente_model.dart';
import '../../model/factura_model.dart';
import '../../model/tarjeta_model.dart';
import '../../preference/shared_preferences.dart';
import '../../providers/cliente_provider.dart';
import '../../providers/factura_provider.dart';
import '../../providers/ventas_provider.dart';
import '../../sistema.dart';
import '../../utils/button.dart' as btn;
import '../../utils/cache.dart' as cache;
import '../../utils/dialog.dart' as dlg;
import '../../utils/personalizacion.dart' as prs;
import '../../utils/utils.dart' as utils;

//Pagina para recargar saldo
class VentasPage extends StatefulWidget {
  VentasPage({Key key}) : super(key: key);

  @override
  State<VentasPage> createState() => _VentasPageState();
}

class _VentasPageState extends State<VentasPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final VentasProvider _ventasProvider = VentasProvider();
  ClienteModel _cliente = ClienteModel();
  FacturaProvider _facturaProvider = FacturaProvider();
  String idTarjetaInscripcion = '1';
  FacturaModel _factura;

  _VentasPageState();

  final ClienteProvider _clienteProvider = ClienteProvider();
  final PreferenciasUsuario prefs = PreferenciasUsuario();

  final HorarioBloc _horarioBloc = HorarioBloc();
  bool _saving = false;
  TextEditingController _textControllerSaldo;
  TextEditingController _textControllerId;
  TextEditingController _textControllerCash;
  TextEditingController _textControllerCredito;
  double _credito = 0.0;

  @override
  void initState() {
    super.initState();
    _horarioBloc.listar(1);
    _textControllerId = TextEditingController(text: '');
    _textControllerCash = TextEditingController(text: 'Consultando...');
    _textControllerSaldo = TextEditingController(text: 'Consultando...');
    _textControllerCredito = TextEditingController(text: 'Consultando...');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Ventas'),
        leading: utils.leading(context),
      ),
      body: ModalProgressHUD(
        color: Colors.black,
        opacity: 0.4,
        progressIndicator: utils.progressIndicator('Consultando...'),
        inAsyncCall: _saving,
        child: Column(
          children: <Widget>[
            Expanded(child: SingleChildScrollView(child: _contenido())),
            btn.booton(
                _identificar ? 'VERIFICAR' : 'LIMPIAR', _verificarButton),
          ],
        ),
      ),
    );
  }

  _verificarButton() {
    _textControllerSaldo.text = 'Consultando...';
    if (_identificar) {
      _verificar(false, '');
    } else {
      _cliente = ClienteModel();
      _identificar = true;
      _saving = false;
      if (mounted) setState(() {});
    }
  }

  _verificar(bool isRecarga, String token) async {
    _saving = true;
    if (mounted) setState(() {});
    await _ventasProvider
        .ver(_cliente.celular.toString(), isRecarga ? token : '',
            (estado, error, clienteresponse) {
      if (estado == 1 && clienteresponse != null) {
        _identificar = false;
        _cliente = clienteresponse;
        _clienteProvider.saldo(_cliente.idCliente, (saldo, credito, cash) {
          _textControllerCash.text = cash;
          _textControllerSaldo.text = saldo;
          _textControllerCredito.text = credito;
          try {
            _credito = double.parse(credito.toString());
          } catch (err) {
            _credito = 0.0;
          }
          if (mounted) setState(() {});
        });
      } else {
        dlg.mostrar(context, 'Cliente no localizado');
      }
      _textControllerId.text = '';
      _saving = false;
      if (mounted) setState(() {});
    });
  }

  Widget _avatar() {
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(90)),
      child: cache.fadeImage(_cliente.img, width: 90, height: 90),
    );
  }

  bool _identificar = true;

  Widget _contenido() {
    return Container(
        padding: EdgeInsets.only(top: 10.0, right: 20.0, left: 20.0),
        child: _identificar
            ? Column(
                children: <Widget>[
                  SizedBox(height: 30.0),
                  Center(child: _crearCelular()),
                  SizedBox(height: 30.0),
                ],
              )
            : _contenidoClieneIdentificado());
  }

  Widget _contenidoClieneIdentificado() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Stack(
          children: <Widget>[
            CircularPercentIndicator(
              radius: 100.0,
              lineWidth: 4.0,
              animation: true,
              percent: (_cliente.registros > 0)
                  ? (_cliente.correctos / _cliente.registros)
                  : 1.0,
              center: _avatar(),
              circularStrokeCap: CircularStrokeCap.round,
              progressColor: Colors.purple,
            ),
            Positioned(
              top: 70.0,
              left: 70.0,
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(50)),
                child: FadeInImage(
                  placeholder: AssetImage('assets/no-image.png'),
                  fit: BoxFit.cover,
                  image: NetworkImage(
                      '${Sistema.dominio}cliente/insignia/${_cliente.puntos}'),
                  height: 40,
                  width: 40,
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
        SizedBox(height: 10.0),
        _crearNombres(),
        SizedBox(height: 10.0),
        Row(children: [
          _crearSaldo(),
          _crearCredito(),
        ]),
        SizedBox(height: 10.0),
        _crearCash(),
        SizedBox(height: 10.0),
        Divider(),
        SizedBox(height: 10.0),
        _hacerDespachador(),
      ],
    );
  }

  bool isCelularValido = true;
  String codigoPais = '+593';

  _onChangedCelular(phone) {
    codigoPais = '+593';
    _cliente.celular = phone;
    _textControllerId.text = '';
    if (mounted) setState(() {});
  }

  Widget _crearCelular() {
    return Container(
        child: utils.crearCelular(prefs.simCountryCode, _onChangedCelular));
  }

  Widget _crearNombres() {
    return TextFormField(
      readOnly: true,
      initialValue: _cliente.nombres,
      decoration: InputDecoration(
          hintText: 'Usuario', labelText: 'Usuario', icon: prs.iconoNombres),
      onSaved: (value) => _cliente.nombres = value,
    );
  }

  Widget _hacerDespachador() {
    if (_cliente.perfil.toString() == '0')
      return btn.bootonIcon('Convertir en Despachador', prs.iconoDespachor,
          _convertirDespachador);
    return _listaTarjetas();
  }

  _convertirDespachador() {
    _verificarFactura(() {
      Navigator.of(context).pop();
      _confirmarConvertirDespachador();
    });
  }

  _confirmarConvertirDespachador() {
    fAceptar() {
      _fAceptarHacerDespachador(idTarjetaInscripcion, 'Sin credito',
          'Recibo registrado en el Sistema');
    }

    dlg.mostrar(context,
        'Presione ACEPTAR solo si esta seguro de querer convertir al usuario ${_cliente.nombres} en un Despachado Curiosity y haya recibido el pago previo acordado.',
        fIzquierda: _cancelar,
        mIzquierda: 'CANCELAR',
        fBotonIDerecha: fAceptar,
        mBotonDerecha: 'ACEPTAR',
        icon: Icons.attach_money);
  }

  _cancelar() {
    Navigator.pop(context);
  }

  Widget _listaTarjetas() {
    return Container(
      height: 350.0,
      child: FutureBuilder(
        future: _ventasProvider.tarjetas(),
        builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.length > 0)
              return createListView(context, snapshot);
            return Container(
              margin: EdgeInsets.all(80.0),
              width: double.infinity,
              height: double.infinity,
              child: Center(
                child: Image(
                  image: AssetImage('assets/screen/direcciones.png'),
                  fit: BoxFit.cover,
                ),
              ),
            );
          } else {
            return ShimmerCard();
          }
        },
      ),
    );
  }

  Widget createListView(BuildContext context, AsyncSnapshot snapshot) {
    return ListView.builder(
        padding: EdgeInsets.only(right: 5.0, left: 5.0),
        itemCount: snapshot.data.length,
        itemBuilder: (BuildContext context, int index) {
          return _card(context, snapshot.data[index]);
        });
  }

  _verificarFactura(Function confirmado) async {
    _factura = null;
    _saving = true;
    if (mounted) setState(() {});
    _factura = await _facturaProvider.ver(_cliente.idCliente);

    _saving = false;
    if (mounted) setState(() {});

    if (_factura == null) {
      return dlg.mostrar(context, 'Solicitar registrar datos de factura');
    }

    String datos =
        'DNI:\n${_factura.dni}\n\nNombres:\n${_factura.nombres}\n\nCorreo:\n${_factura.correo}\n\nNúmero:\n${_factura.numero}\n\nDirección:\n${_factura.direccion}';

    dlg.mostrar(context, datos,
        titulo: 'Datos de factura',
        fIzquierda: _cancelar,
        mIzquierda: 'CANCELAR',
        fBotonIDerecha: confirmado,
        mBotonDerecha: 'ACEPTAR',
        color: prs.colorButtonSecondary,
        icon: Icons.description);
  }

  _comprarPaquete(TarjetaModel tarjetaModel) async {
    _verificarFactura(() {
      Navigator.of(context).pop();
      _confirmarComprarPaquete(tarjetaModel);
    });
  }

  _confirmarComprarPaquete(TarjetaModel tarjetaModel) {
    double _recibo = tarjetaModel.costo - _credito;
    if (_recibo < 0) _recibo = 0;

    String _creditoAconsumir =
        (tarjetaModel.costo - _recibo).toStringAsFixed(2);

    fAceptar() {
      _fAceptarHacerDespachador(tarjetaModel.idTarjeta, _creditoAconsumir,
          _recibo.toStringAsFixed(2));
    }

    dlg.mostrar(
        context,
        'Confirmo recibir: \n\n${(_recibo).toStringAsFixed(2)} USD\n\n'
        'Crédito a consumir: \n\n$_creditoAconsumir USD\n\n'
        'Se acreditará: ${(tarjetaModel.saldo + tarjetaModel.promocion).toStringAsFixed(2)}',
        titulo: _cliente.nombres,
        fIzquierda: _cancelar,
        mIzquierda: 'CANCELAR',
        fBotonIDerecha: fAceptar,
        mBotonDerecha: 'CONFIRMAR',
        icon: Icons.attach_money);
  }

  Widget _card(BuildContext context, TarjetaModel tarjetaModel) {
    return TarjetaCard(
        tarjetaModel: tarjetaModel,
        key: ValueKey(tarjetaModel.idTarjeta),
        onTab: _comprarPaquete);
  }

  _fAceptarHacerDespachador(
      String idTarjeta, String creditoAconsumir, String recibo) async {
    Navigator.pop(context);
    _saving = true;
    if (mounted) setState(() {});
    await _ventasProvider.comprar(
        idTarjeta, _cliente.idCliente, creditoAconsumir, recibo, _factura,
        (estado, error, clienteresponse) {
      _saving = false;
      if (mounted) setState(() {});
      if (clienteresponse == null) {
        dlg.mostrar(context, error);
        return;
      }
      _cliente = clienteresponse;
      _clienteProvider.saldo(_cliente.idCliente, (saldo, credito, cash) {
        _textControllerCash.text = cash;
        _textControllerSaldo.text = saldo;
        _textControllerCredito.text = credito;
        try {
          _credito = double.parse(credito.toString());
        } catch (err) {
          _credito = 0.0;
        }
        if (mounted) setState(() {});
      });
      if (mounted) setState(() {});
      dlg.mostrar(context, error);
    });
  }

  Widget _crearCash() {
    return Visibility(
      visible: Sistema.idAplicativo == Sistema.idAplicativoCuriosity,
      child: TextFormField(
        readOnly: true,
        controller: _textControllerCash,
        decoration: InputDecoration(
            suffixIcon: IconButton(
              icon: Icon(Icons.help_outline, size: 27.0),
              onPressed: () {
                dlg.mostrar(
                    context, 'Este dinero permite pagar productos y envío',
                    titulo: 'Curiosity Cash');
              },
            ),
            hintText: 'Curiosity Cash',
            labelText: 'Curiosity Cash',
            icon: prs.iconoCahs),
      ),
    );
  }

  Widget _crearSaldo() {
    double _width = MediaQuery.of(context).size.width;
    return Container(
      width: _width / 2 - 10,
      child: Visibility(
        visible: Sistema.idAplicativo == Sistema.idAplicativoCuriosity,
        child: TextFormField(
          readOnly: true,
          controller: _textControllerSaldo,
          decoration: InputDecoration(
              suffixIcon: IconButton(
                icon: Icon(Icons.help_outline, size: 27.0),
                onPressed: () async {
                  dlg.mostrar(context,
                      'Con Curiosity Money puedes pagar el costo o parte del costo de entrega. \n\nAl invitar a tus amigos a usar Curiosity tienes mayor probabilidad de obtener money.',
                      titulo: 'Curiosity Money');
                },
              ),
              hintText: 'Curiosity Money',
              labelText: 'Curiosity Money',
              icon: prs.iconoMoney),
        ),
      ),
    );
  }

  Widget _crearCredito() {
    double _width = MediaQuery.of(context).size.width;
    return Container(
      width: _width / 2 - 30,
      child: Visibility(
        visible: Sistema.idAplicativo == Sistema.idAplicativoCuriosity,
        child: TextFormField(
          readOnly: true,
          controller: _textControllerCredito,
          decoration: InputDecoration(
            suffixIcon: IconButton(
              icon: Icon(Icons.help_outline, size: 27.0),
              onPressed: () async {
                dlg.mostrar(context,
                    'Este dinero se puede efectivizar, según los términos y condiciones.',
                    titulo: 'Crédito');
              },
            ),
            hintText: 'Crédito',
            labelText: 'Crédito',
          ),
        ),
      ),
    );
  }

  Widget _estrellas() {
    return utils.estrellas(
        (_cliente.calificacion / _cliente.calificaciones), (value) {});
  }
}
