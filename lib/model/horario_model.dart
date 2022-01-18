class HorarioModel {
  dynamic idSucursalHorario;
  int idSucursal;
  int tipo;
  int dia;
  dynamic fecha;
  String desde;
  String hasta;
  int activo;

  get acronimo {
    switch (dia) {
      case 1:
        return 'Lunes';
      case 2:
        return 'Martes';
      case 3:
        return 'Miercoles';
      case 4:
        return 'Jueves';
      case 5:
        return 'Viernes';
      case 6:
        return 'Sabado';
      case 0:
        return 'Domingo';
      default:
        return '';
    }
  }

  HorarioModel({
    this.idSucursalHorario,
    this.idSucursal,
    this.tipo,
    this.dia,
    this.fecha,
    this.desde,
    this.hasta,
    this.activo,
  });

  factory HorarioModel.fromJson(Map<String, dynamic> json) => HorarioModel(
        idSucursalHorario: json["id_sucursal_horario"],
        idSucursal: json["id_sucursal"],
        tipo: json["tipo"],
        dia: json["dia"],
        fecha: json["fecha"],
        desde: json["desde"],
        hasta: json["hasta"],
        activo: json["activo"],
      );

  Map<String, dynamic> toJson() => {
        "id_sucursal_horario": idSucursalHorario,
        "id_sucursal": idSucursal,
        "tipo": tipo,
        "dia": dia,
        "fecha": fecha,
        "desde": desde,
        "hasta": hasta,
        "activo": activo,
      };
}
