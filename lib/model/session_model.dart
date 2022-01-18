class SessionModel {
  int actual;
  dynamic fechaActualizo;
  dynamic fechaInicio;
  dynamic idPlataforma;
  dynamic imei;
  dynamic ciudad;
  dynamic pais;
  dynamic marca;

  SessionModel({
    this.actual,
    this.fechaActualizo,
    this.fechaInicio,
    this.idPlataforma,
    this.imei,
    this.ciudad,
    this.pais,
    this.marca,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) => SessionModel(
        actual: json["actual"],
        fechaActualizo: json["fecha_actualizo"],
        fechaInicio: json["fecha_inicio"],
        idPlataforma: json["id_plataforma"],
        imei: json["imei"],
        ciudad: json["ciudad"],
        pais: json["pais"],
        marca: json["marca"],
      );

  Map<String, dynamic> toJson() => {
        "actual": actual,
        "fecha_actualizo": fechaActualizo,
        "fecha_inicio": fechaInicio,
        "id_plataforma": idPlataforma,
        "imei": imei,
        "ciudad": ciudad,
        "pais": pais,
        "marca": marca,
      };
}
