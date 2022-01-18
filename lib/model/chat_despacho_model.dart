class ChatDespachoModel {
  dynamic idChat;
  dynamic idDespacho;
  dynamic
      identificador; //Es el id del despacho correspondiente del cliente el iddespacho sera el del conductor pues con ese se rastrea
  dynamic idClienteEnvia;
  dynamic idClienteRecibe;
  dynamic envia;
  dynamic tipo;
  dynamic estado;
  dynamic mensaje;
  dynamic valor;
  dynamic idDespachoEstado;
  dynamic fechaRegistro;
  dynamic hora;
  String url;

  ChatDespachoModel({
    this.url: 'despacho/',
    this.idChat,
    this.idDespacho,
    this.identificador,
    this.idClienteEnvia,
    this.idClienteRecibe,
    this.envia,
    this.tipo,
    this.estado: 0,
    this.mensaje,
    this.valor,
    this.idDespachoEstado,
    this.fechaRegistro,
    this.hora: 'ahora',
  });

  factory ChatDespachoModel.fromJson(Map<String, dynamic> json) =>
      ChatDespachoModel(
        idChat: json["id_chat"],
        idDespacho: json["id_despacho"],
        identificador: json["identificador"],
        idClienteEnvia: json["id_cliente_envia"],
        idClienteRecibe: json["id_cliente_recibe"],
        envia: json["envia"],
        tipo: json["tipo"],
        estado: json["estado"],
        mensaje: json["mensaje"],
        valor: json["valor"],
        idDespachoEstado: json["id_despacho_estado"],
        fechaRegistro: json["fecha_registro"],
        hora: json["hora"],
      );

  Map<String, dynamic> toJson() => {
        "id_chat": idChat,
        "id_despacho": idDespacho,
        "identificador": identificador,
        "id_cliente_envia": idClienteEnvia,
        "id_cliente_recibe": idClienteRecibe,
        "envia": envia,
        "tipo": tipo,
        "estado": estado,
        "mensaje": mensaje,
        "valor": valor,
        "id_despacho_estado": idDespachoEstado,
        "fecha_registro": fechaRegistro,
        "hora": hora,
      };
}
