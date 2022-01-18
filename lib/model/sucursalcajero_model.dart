import '../utils/cache.dart' as cache;

class SucursalcajeroModel {
  dynamic idCliente;
  dynamic idSucursal;
  String celular;
  String correo;
  String nombres;
  int sexo;
  int likes;
  int onLine;
  String img;
  int activo;
  int calificaciones;
  int calificacion;
  int registros;
  int confirmados;
  int correctos;
  int canceladas;

  SucursalcajeroModel({
    this.idCliente,
    this.idSucursal,
    this.celular,
    this.correo,
    this.nombres,
    this.sexo,
    this.likes,
    this.onLine,
    this.img,
    this.activo,
    this.calificaciones,
    this.calificacion,
    this.registros,
    this.confirmados,
    this.correctos,
    this.canceladas,
  });

  get acronimo {
    var acronimos = nombres.toString().split(' ');
    String first = acronimos.first.substring(0, 1);
    String last = acronimos.length > 1 ? acronimos[1].substring(0, 1) : '';
    return '$first$last';
  }

  factory SucursalcajeroModel.fromJson(Map<String, dynamic> json) =>
      SucursalcajeroModel(
        idCliente: json["id_cliente"],
        idSucursal: json["id_sucursal"],
        celular: json["celular"],
        correo: json["correo"],
        nombres: json["nombres"],
        sexo: json["sexo"],
        likes: json["likes"],
        onLine: json["on_line"],
        img: cache.img(json["img"]),
        activo: json["activo"],
        calificaciones: json["calificaciones"],
        calificacion: json["calificacion"],
        registros: json["registros"],
        confirmados: json["confirmados"],
        correctos: json["correctos"],
        canceladas: json["canceladas"],
      );

  Map<String, dynamic> toJson() => {
        "id_cliente": idCliente,
        "id_sucursal": idSucursal,
        "celular": celular,
        "correo": correo,
        "nombres": nombres,
        "sexo": sexo,
        "likes": likes,
        "on_line": onLine,
        "img": img,
        "activo": activo,
        "calificaciones": calificaciones,
        "calificacion": calificacion,
        "registros": registros,
        "confirmados": confirmados,
        "correctos": correctos,
        "canceladas": canceladas,
      };
}
