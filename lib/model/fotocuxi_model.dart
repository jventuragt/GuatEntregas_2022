class FotocuxiModel {
  String idFoto;
  String ruta;

  FotocuxiModel({this.idFoto, this.ruta});

  factory FotocuxiModel.fromJson(Map<String, dynamic> json) => FotocuxiModel(
        idFoto: json["id_foto"].toString(),
        ruta: json["ruta"].toString(),
      );
}
