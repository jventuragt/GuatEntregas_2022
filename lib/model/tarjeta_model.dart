class TarjetaModel {
  String idTarjeta;
  double costo;
  double saldo;
  double promocion;

  TarjetaModel({
    this.idTarjeta,
    this.costo,
    this.saldo,
    this.promocion,
  });

  factory TarjetaModel.fromJson(Map<String, dynamic> json) => TarjetaModel(
        idTarjeta: json["id_tarjeta"].toString(),
        costo: json["costo"].toDouble(),
        saldo: json["saldo"].toDouble(),
        promocion: json["promocion"].toDouble(),
      );
}
