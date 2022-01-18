class FacturaModel {
  dynamic idFactura;
  String dni;
  String nombres;
  String direccion;
  String correo;
  String numero;

  FacturaModel({
    this.idFactura: -1,
    this.nombres: '',
    this.dni: '',
    this.direccion: '',
    this.correo: '',
    this.numero: '',
  });

  factory FacturaModel.fromJson(Map<String, dynamic> json) => FacturaModel(
        idFactura: json["id_factura"],
        dni: json["dni"],
        nombres: json["nombres"],
        direccion: json["direccion"],
        correo: json["correo"],
        numero: json["numero"],
      );

  Map<String, dynamic> toJson() => {
        '"idFactura"': '"$idFactura"',
        '"dni"': '"$dni"',
        '"nombres"': '"$nombres"',
        '"direccion"': '"$direccion"',
        '"correo"': '"$correo"',
        '"numero"': '"$numero"'
      };

  @override
  String toString() {
    return '\nCédula/Ruc: $dni\nNombres: $nombres \nCorreo: $correo \nNúmero: $numero \nDirección: $direccion';
  }
}
