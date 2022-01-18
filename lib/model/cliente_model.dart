import '../utils/cache.dart' as cache;

class ClienteModel {
  String beta;
  int sexo;

  dynamic idCliente;
  String idUrbe;
  dynamic celular;
  dynamic correo;
  dynamic nombres;
  dynamic apellidos;
  dynamic clave;
  dynamic cedula;
  dynamic cambiarClave;
  dynamic celularValidado;
  dynamic correoValidado;
  dynamic img;
  dynamic perfil;
  dynamic codigoPais;
  String link;
  String fechaNacimiento;

  dynamic calificacion;
  int calificaciones, registros, puntos, direcciones, correctos, canceladas;

  get acronimo {
    var acronimos = nombres.toString().split(' ');
    String first = acronimos.first.substring(0, 1);
    String last = acronimos.length > 1 ? acronimos[1].substring(0, 1) : '';
    return '$first$last'.toUpperCase();
  }

  ClienteModel({
    this.beta: 'null',
    this.sexo: 0,
    this.idCliente,
    this.idUrbe: '1',
    this.celular: '',
    this.correo: '',
    this.nombres: '',
    this.apellidos,
    this.clave: '*********',
    this.cedula,
    this.cambiarClave,
    this.celularValidado: 0,
    this.correoValidado: 0,
    this.img,
    this.perfil,
    this.codigoPais,
    this.calificacion: 5.0,
    this.calificaciones: 1,
    this.registros: 0,
    this.puntos: 0,
    this.direcciones: 1,
    this.correctos: 0,
    this.canceladas: 0,
    this.fechaNacimiento: '',
    this.link: '',
  });

  factory ClienteModel.fromJson(Map<String, dynamic> json) => ClienteModel(
        link: json["link"] == null ? '' : json["link"],
        idUrbe: json["id_urbe"] == null ? '1' : json["id_urbe"].toString(),
        beta: json["beta"],
        sexo: json["sexo"],
        idCliente: json["id_cliente"],
        celular: json["celular"] == null ? '' : json["celular"],
        correo: json["correo"],
        nombres: json["nombres"],
        apellidos: json["apellidos"],
        cedula: json["cedula"],
        cambiarClave: json["cambiarClave"],
        celularValidado: json["celularValidado"],
        correoValidado: json["correoValidado"],
        img: cache.img(json["img"]),
        perfil: json["perfil"],
        codigoPais: json["codigoPais"],
        calificacion: json["calificacion"] == null
            ? 0.0
            : json["calificacion"].toDouble(),
        calificaciones: json["calificaciones"],
        registros: json["registros"],
        puntos: json["puntos"],
        direcciones: json["direcciones"],
        correctos: json["correctos"],
        canceladas: json["canceladas"],
        fechaNacimiento: json["fecha_nacimiento"],
      );

  Map<String, dynamic> toJson() => {
        "link": link,
        "beta": beta,
        "sexo": sexo,
        "id_cliente": idCliente,
        "celular": celular,
        "correo": correo,
        "nombres": nombres,
        "apellidos": apellidos,
        "cedula": cedula,
        "cambiarClave": cambiarClave,
        "celularValidado": celularValidado,
        "correoValidado": correoValidado,
        "img": img,
        "perfil": perfil,
        "codigoPais": codigoPais,
        "calificacion": calificacion,
        "calificaciones": calificaciones,
        "registros": registros,
        "puntos": puntos,
        "direcciones": direcciones,
        "correctos": correctos,
        "canceladas": canceladas,
        "fecha_nacimiento": fechaNacimiento,
      };
}
