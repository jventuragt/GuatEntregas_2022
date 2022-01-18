class ReporteModel {
  String fecha;
  int number;
  int total;
  int consultando;
  int comprada;
  int despachada;
  int cancelada;
  int entragda;

  ReporteModel(
      {this.number,
      this.fecha,
      this.total,
      this.consultando,
      this.comprada,
      this.despachada,
      this.cancelada,
      this.entragda});

  factory ReporteModel.fromJson(Map<String, dynamic> json) => ReporteModel(
        fecha: json["fecha"].toString(),
        total: json["total"],
        consultando: json["consultando"],
        comprada: json["comprada"],
        despachada: json["despachada"],
        cancelada: json["cancelada"],
        entragda: json["entragda"],
      );
}
