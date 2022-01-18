import '../utils/conf.dart' as config;

class HashtagModel {
  dynamic idHashtag;
  int estado;
  int idAgencia;
  String error;
  String url;

  String mBotonDerecha;
  String mIzquierda;

  String codigo;
  double promocion;

  bool isBotonDerecha() {
    return url.length > 5;
  }

  HashtagModel(
      {this.idHashtag,
      this.idAgencia,
      this.codigo,
      this.promocion,
      this.estado: -2,
      this.mBotonDerecha: 'ACEPTAR',
      this.mIzquierda: 'DECLINAR',
      this.url: '',
      this.error: config.MENSAJE_INTERNET});

  factory HashtagModel.fromJson(Map<String, dynamic> json) => HashtagModel(
        idHashtag: json["id_hashtag"],
        idAgencia: json["id_agencia"],
        codigo: json["codigo"],
        promocion: json["promocion"] == null ? 0.0 : json["promocion"] / 1,
        estado: json["estado"],
        error: json["error"],
        mBotonDerecha:
            json["mBotonDerecha"] == null ? 'ACEPTAR' : json["mBotonDerecha"],
        mIzquierda:
            json["mIzquierda"] == null ? 'DECLINAR' : json["mIzquierda"],
        url: json["url"] == null ? '' : json["url"],
      );
}
