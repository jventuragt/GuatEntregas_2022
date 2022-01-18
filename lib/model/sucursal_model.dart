class SucursalModel {
  String agencia;
  String urbe;
  String ciudad;
  dynamic idSucursal;
  int idAgencia;
  int idUrbe;
  String sucursal;
  String direccion;
  String observacion;
  dynamic lt;
  dynamic lg;
  String contacto;
  String mail;
  int activo;
  dynamic costoArranque;
  dynamic costoKmRecorrido;
  int sessiones;

  SucursalModel(
      {this.agencia,
      this.urbe,
      this.ciudad,
      this.idSucursal,
      this.idAgencia,
      this.idUrbe,
      this.sucursal,
      this.direccion,
      this.observacion,
      this.lt: 0.0,
      this.lg: 0.0,
      this.contacto,
      this.mail,
      this.activo,
      this.costoArranque,
      this.costoKmRecorrido,
      this.sessiones});

  factory SucursalModel.fromJson(Map<String, dynamic> json) => SucursalModel(
        agencia: json["agencia"],
        urbe: json["urbe"],
        ciudad: json["ciudad"],
        idSucursal: json["id_sucursal"],
        idAgencia: json["id_agencia"],
        idUrbe: json["id_urbe"],
        sucursal: json["sucursal"],
        direccion: json["direccion"],
        observacion: json["observacion"],
        lt: json["lt"] == null ? 0.0 : json["lt"].toDouble(),
        lg: json["lg"] == null ? 0.0 : json["lg"].toDouble(),
        contacto: json["contacto"],
        mail: json["mail"],
        activo: json["activo"],
        costoArranque: json["costo_arranque"].toDouble(),
        costoKmRecorrido: json["costo_km_recorrido"].toDouble(),
        sessiones: json["sessiones"],
      );

  Map<String, dynamic> toJson() => {
        "agencia": agencia,
        "urbe": urbe,
        "ciudad": ciudad,
        "id_sucursal": idSucursal,
        "id_agencia": idAgencia,
        "id_urbe": idUrbe,
        "sucursal": sucursal,
        "direccion": direccion,
        "observacion": observacion,
        "lt": lt,
        "lg": lg,
        "contacto": contacto,
        "mail": mail,
        "activo": activo,
        "costo_arranque": costoArranque,
        "costo_km_recorrido": costoKmRecorrido,
        "sessiones": sessiones,
      };
}
