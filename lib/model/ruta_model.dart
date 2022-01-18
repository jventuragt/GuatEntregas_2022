import '../utils/cache.dart' as cache;

class RutaModel {
  dynamic idRuta;
  dynamic idUrbe;
  dynamic nombre;
  dynamic lt;
  dynamic lg;
  dynamic ruta;
  String img;

  String desde;
  dynamic ltA;
  dynamic lgA;

  String hasta;
  dynamic ltB;
  dynamic lgB;

  List<List<double>> tR;

  RutaModel({
    this.desde,
    this.ltA: 0.0,
    this.lgA: 0.0,
    this.hasta,
    this.ltB: 0.0,
    this.lgB: 0.0,
    this.idRuta: -1,
    this.nombre,
    this.lt: 0.0,
    this.lg: 0.0,
    this.idUrbe: 1,
    this.ruta,
    this.img,
  });

  factory RutaModel.fromJson(Map<String, dynamic> json) => RutaModel(
        desde: json["desde"],
        lt: json["lt"] == null ? 0.0 : json["lt"].toDouble(),
        lg: json["lg"] == null ? 0.0 : json["lg"].toDouble(),
        ltA: json["ltA"] == null ? 0.0 : json["ltA"].toDouble(),
        lgA: json["lgA"] == null ? 0.0 : json["lgA"].toDouble(),
        ltB: json["ltB"] == null ? 0.0 : json["ltB"].toDouble(),
        lgB: json["lgB"] == null ? 0.0 : json["lgB"].toDouble(),
        hasta: json["hasta"],
        idRuta: json["id_ruta"],
        nombre: json["nombre"],
        idUrbe: json["id_urbe"],
        ruta: json["ruta"],
        img: cache.img(json["img"]),
      );

  Map<String, dynamic> toJson() => {
        "desde": desde,
        "ltA": ltA,
        "lgA": lgA,
        "hasta": hasta,
        "ltB": ltB,
        "lgB": lgB,
        "id_ruta": idRuta,
        "nombre": nombre,
        "lt": lt,
        "lg": lg,
        "id_urbe": idUrbe,
        "ruta": ruta,
        "img": img,
      };
}
