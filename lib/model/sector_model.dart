class SectorModel {
  dynamic idSector;
  String alias;
  double costoEnvio;

  dynamic lt;
  dynamic lg;

  SectorModel({
    this.idSector: -1,
    this.alias,
    this.costoEnvio,
    this.lt,
    this.lg,
  });

  factory SectorModel.fromJson(Map<String, dynamic> json) => SectorModel(
        idSector: json["id_direccion"],
        alias: json["alias"],
        costoEnvio: json["costo_envio"].toDouble(),
        lt: json["lt"],
        lg: json["lg"],
      );

  Map<String, dynamic> toJson() => {
        "id_direccion": idSector,
        "alias": alias,
      };
}
