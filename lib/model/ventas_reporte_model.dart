class VentasReporteModel {
  String formaPago;
  int ventas;
  double credito;
  double creditoProducto;
  double creditoEnvio;
  double costo;
  double costoProducto;
  double hashtag;
  double descontado;
  double transaccion;
  double ingresos;
  double devuelto;

  VentasReporteModel({
    this.formaPago,
    this.ventas,
    this.credito,
    this.creditoProducto,
    this.creditoEnvio,
    this.costo,
    this.hashtag,
    this.descontado,
    this.transaccion,
    this.ingresos,
    this.devuelto,
  });

  factory VentasReporteModel.fromJson(Map<String, dynamic> json) =>
      VentasReporteModel(
        formaPago: json["forma_pago"],
        ventas: int.parse(json["ventas"].toString()),
        credito: double.parse(json["credito"].toString()),
        creditoProducto: double.parse(json["credito_producto"].toString()),
        creditoEnvio: double.parse(json["credito_envio"].toString()),
        costo: double.parse(json["costo"].toString()),
        hashtag: double.parse(json["hashtag"].toString()),
        descontado: double.parse(json["descontado"].toString()),
        transaccion: double.parse(json["transaccion"].toString()),
        ingresos: double.parse(json["ingresos"].toString()),
        devuelto: double.parse(json["devuelto"].toString()),
      );
}
