import '../model/card_model.dart';
import '../preference/shared_preferences.dart';
import '../utils/cache.dart' as cache;

final PreferenciasUsuario _prefs = PreferenciasUsuario();

class CajeroModel {
  double porcentajeTarjeta;
  dynamic idAgencia;

  dynamic idDespacho;
  int onLine;
  dynamic idCajero;
  dynamic idCliente;
  dynamic codigoPais;
  dynamic celular;
  int celularValidado;
  dynamic nombres;
  dynamic apellidos;
  dynamic img;
  dynamic sucursal;
  dynamic idCompraEstado;
  dynamic estado;
  dynamic idCompra;
  dynamic idSucursal;

  dynamic idDireccion;
  dynamic referencia;

  dynamic lt;
  dynamic lg;
  dynamic ltB;
  dynamic lgB;

  double costo;

  double costoFormaPago(bool isEfectivo) {
    if (isEfectivo) return costo;
    return (costo + (costo * porcentajeTarjeta));
  }

  double costoPorcentaje(bool isEfectivo) {
    if (isEfectivo) return 0.0;
    return (costo * porcentajeTarjeta);
  }

  double total() {
    return costo + costoEnvio;
  }

  double costoEnvio;
  dynamic transaccion;
  dynamic idHashtag;
  double descuento; // Valor del hastag

  dynamic calificacionCajero;
  dynamic calificacionCliente;

  dynamic detalle;

  dynamic sinLeerCajero;
  dynamic sinLeerCliente;

  dynamic calificarCliente;
  dynamic calificarCajero;

  dynamic comentarioCliente;
  dynamic comentarioCajero;
  bool isLiked;
  int likes;
  String personalidad;

  int resta;
  dynamic hasta;
  int turno;
  String abiero;

  get acronimo {
    var acronimos = nombres.toString().split(' ');
    String first = acronimos.first.substring(0, 1);
    String last = acronimos.length > 1 ? acronimos[1].substring(0, 1) : '';
    return '$first$last';
  }

  String idCash = '0';
  double pay = 0.0; //Curiosity pay
  double cash = 0.0; //Pago con pay
  double saldoMoney = 0.0;
  double descontado = 0.0; //Valor descontado por money
  double aCobrar = 0.0; //Valor a cobrar al cleinte

  CardModel cardModel = CardModel();

  evaluar(double _money) {
    double _aCobrar = costoEnvio - _money;
    if (_aCobrar <= 0) {
      descontado = costoEnvio;
      aCobrar = 0.0;
    } else {
      descontado = _money;
      aCobrar = _aCobrar;
    }
  }

  double cashConsumido() {
    double _regalo = descontado + descuento;
    if (_regalo > costoEnvio) _regalo = costoEnvio;
    double cashConsumido = cash - _regalo;
    if (cashConsumido <= 0) return 0;
    return cashConsumido;
  }

  get acronimoSucursal {
    var acronimos = sucursal.toString().split(' ');
    String first = acronimos.first.substring(0, 1);
    String last = acronimos.last.substring(0, 1);
    return '$first$last'.toUpperCase();
  }

  get isCajero {
    return _prefs.idCliente.toString() == idCajero.toString();
  }

  int isTarjeta;

  CajeroModel({
    this.isTarjeta: 0,
    this.descuento: 0.0,
    this.porcentajeTarjeta: 0.0,
    this.transaccion: 0.0,
    this.idAgencia,
    this.idDespacho: -1,
    this.turno,
    this.resta: 1,
    this.hasta,
    this.onLine: 1,
    this.personalidad,
    this.likes: 0,
    this.isLiked: false,
    this.idCajero,
    this.idCliente,
    this.codigoPais,
    this.celularValidado: 0,
    this.celular,
    this.nombres,
    this.apellidos,
    this.img,
    this.sucursal,
    this.idCompraEstado: 1,
    this.estado,
    this.idCompra: -1,
    this.idDireccion,
    this.referencia,
    this.lt: 0.0,
    this.lg: 0.0,
    this.ltB: 0.0,
    this.lgB: 0.0,
    this.costo: 0.0,
    this.costoEnvio: 0.0,
    this.calificacionCliente: 5.00,
    this.calificacionCajero: 5.00,
    this.detalle,
    this.idSucursal,
    this.sinLeerCajero,
    this.sinLeerCliente,
    this.calificarCajero,
    this.calificarCliente,
    this.comentarioCliente,
    this.comentarioCajero,
    this.abiero: '1',
    this.credito: 0.0,
    this.creditoProducto: 0.0,
    this.creditoEnvio: 0.0,
  });

  double credito;
  double creditoProducto;
  double creditoEnvio;

  factory CajeroModel.fromJson(Map<String, dynamic> json) => CajeroModel(
        isTarjeta: json["isTarjeta"] == null
            ? 0
            : int.parse(json["isTarjeta"].toString()),
        porcentajeTarjeta: json["pT"] == null ? 0.0 : json["pT"] / 1,
        idAgencia: json["id_agencia"],
        idDespacho: json["id_despacho"] == null ? 0 : json["id_despacho"],
        turno: json["turno"],
        resta: json["resta"],
        hasta: json["hasta"],
        onLine: json["on_line"],
        personalidad: json["personalidad"],
        likes: json["likes"],
        idCajero: json["id_cajero"],
        idCliente: json["id_cliente"],
        codigoPais: json["codigoPais"],
        celular: json["celular"],
        celularValidado: json["celularValidado"],
        nombres: json["nombres"],
        apellidos: json["apellidos"],
        img: cache.img(json["img"]),
        sucursal: json["sucursal"],
        idCompraEstado:
            json["id_compra_estado"] == null ? 1 : json["id_compra_estado"],
        estado: json["estado"],
        idCompra: json["id_compra"],
        idDireccion: json["id_direccion"],
        referencia: json["referencia"],
        lt: json["lt"] == null ? 0.0 : json["lt"].toDouble(),
        lg: json["lg"] == null ? 0.0 : json["lg"].toDouble(),
        ltB: json["ltB"] == null ? 0.0 : json["ltB"].toDouble(),
        lgB: json["lgB"] == null ? 0.0 : json["lgB"].toDouble(),
        costoEnvio: json["costo_envio"] == null
            ? 0.0
            : double.parse(json["costo_envio"].toString()),
        costo: json["costo"] == null ? 0.0 : json["costo"].toDouble(),
        calificacionCajero: json["calificacionCajero"] == null
            ? 5.0
            : json["calificacionCajero"].toDouble(),
        calificacionCliente: json["calificacionCliente"] == null
            ? 5.0
            : json["calificacionCliente"].toDouble(),
        detalle: json["detalle"],
        idSucursal: json["id_sucursal"],
        sinLeerCliente: json["sinLeerCliente"],
        sinLeerCajero: json["sinLeerCajero"],
        calificarCliente: json["calificarCliente"],
        calificarCajero: json["calificarCajero"],
        comentarioCliente:
            json["comentarioCliente"] == null ? '' : json["comentarioCliente"],
        comentarioCajero:
            json["comentarioCajero"] == null ? '' : json["comentarioCajero"],
        abiero: json["abiero"] == null ? '1' : json["abiero"].toString(),
      );

  Map<String, dynamic> toJson() =>
      {"id_agencia": idAgencia, "costo_envio": costoEnvio};
}
