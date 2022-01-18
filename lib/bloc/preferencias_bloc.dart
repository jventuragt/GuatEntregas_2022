class PreferenciasBloc {
  static PreferenciasBloc _instancia;

  PreferenciasBloc._internal();

  factory PreferenciasBloc() {
    if (_instancia == null) {
      _instancia = PreferenciasBloc._internal();
    }
    return _instancia;
  }

  List<MensajePreferenciaModel> mensajes = [];
}

class MensajePreferenciaModel {
  dynamic m;

  MensajePreferenciaModel({this.m});

  factory MensajePreferenciaModel.fromJson(Map<String, dynamic> json) =>
      MensajePreferenciaModel(
        m: json["m"],
      );

  Map<String, dynamic> toJson() => {
        "m": m,
      };
}
