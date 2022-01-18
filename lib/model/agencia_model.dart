class AgenciaModel {
  dynamic idAgencia;
  String agencia;
  String direccion;
  String observacion;
  dynamic lt;
  dynamic lg;
  String contacto;
  String mail;
  String label;
  int activo;
  int idUrbe;

  AgenciaModel({
    this.label: '',
    this.idAgencia: -1,
    this.agencia,
    this.direccion,
    this.observacion,
    this.lt,
    this.lg,
    this.contacto,
    this.mail,
    this.activo,
    this.idUrbe: 0,
  });

  factory AgenciaModel.fromJson(Map<String, dynamic> json) => AgenciaModel(
        label: json["label"],
        idAgencia: json["id_agencia"],
        agencia: json["agencia"],
        direccion: json["direccion"],
        observacion: json["observacion"],
        lt: json["lt"] == null ? 0.0 : json["lt"].toDouble(),
        lg: json["lg"] == null ? 0.0 : json["lg"].toDouble(),
        contacto: json["contacto"],
        mail: json["mail"],
        activo: json["activo"],
      );

  Map<String, dynamic> toJson() => {
        "id_agencia": idAgencia,
        "agencia": agencia,
        "direccion": direccion,
        "observacion": observacion,
        "lt": lt,
        "lg": lg,
        "contacto": contacto,
        "mail": mail,
        "activo": activo,
      };
}
