class ChatViajeModel {
  dynamic idChat;
  dynamic idViaje;
  dynamic
      identificador; //Es el id del viaje correspondiente del cliente el idviaje sera el del conductor pues con ese se rastrea
  dynamic idClienteEnvia;
  dynamic idClienteRecibe;
  dynamic envia;
  dynamic tipo;
  dynamic estado;
  dynamic mensaje;
  dynamic valor;
  dynamic idViajeEstado;
  dynamic fechaRegistro;
  dynamic hora;
  String url;

  ChatViajeModel({
    this.url: 'viaje/',
    this.idChat,
    this.idViaje,
    this.identificador,
    this.idClienteEnvia,
    this.idClienteRecibe,
    this.envia,
    this.tipo,
    this.estado: 0,
    this.mensaje,
    this.valor,
    this.idViajeEstado,
    this.fechaRegistro,
    this.hora: 'ahora',
  });

  factory ChatViajeModel.fromJson(Map<String, dynamic> json) => ChatViajeModel(
        idChat: json["id_chat"],
        idViaje: json["id_viaje"],
        identificador: json["identificador"],
        idClienteEnvia: json["id_cliente_envia"],
        idClienteRecibe: json["id_cliente_recibe"],
        envia: json["envia"],
        tipo: json["tipo"],
        estado: json["estado"],
        mensaje: json["mensaje"],
        valor: json["valor"],
        idViajeEstado: json["id_viaje_estado"],
        fechaRegistro: json["fecha_registro"],
        hora: json["hora"],
      );

  Map<String, dynamic> toJson() => {
        "id_chat": idChat,
        "id_viaje": idViaje,
        "identificador": identificador,
        "id_cliente_envia": idClienteEnvia,
        "id_cliente_recibe": idClienteRecibe,
        "envia": envia,
        "tipo": tipo,
        "estado": estado,
        "mensaje": mensaje,
        "valor": valor,
        "id_viaje_estado": idViajeEstado,
        "fecha_registro": fechaRegistro,
        "hora": hora,
      };
}
