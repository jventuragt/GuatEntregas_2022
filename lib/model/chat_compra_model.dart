class ChatCompraModel {
  dynamic idChat;
  dynamic idCompra;
  dynamic idClienteEnvia;
  dynamic idClienteRecibe;
  dynamic envia;
  dynamic tipo;
  dynamic estado;
  dynamic mensaje;
  dynamic valor;
  dynamic idCompraEstado;
  dynamic fechaRegistro;
  dynamic hora;
  String url;

  ChatCompraModel({
    this.url: 'compra/',
    this.idChat,
    this.idCompra,
    this.idClienteEnvia,
    this.idClienteRecibe,
    this.envia,
    this.tipo,
    this.estado: 0,
    this.mensaje,
    this.valor,
    this.idCompraEstado,
    this.fechaRegistro,
    this.hora: 'ahora',
  });

  factory ChatCompraModel.fromJson(Map<String, dynamic> json) =>
      ChatCompraModel(
        idChat: json["id_chat"],
        idCompra: json["id_compra"],
        idClienteEnvia: json["id_cliente_envia"],
        idClienteRecibe: json["id_cliente_recibe"],
        envia: json["envia"],
        tipo: json["tipo"],
        estado: json["estado"],
        mensaje: json["mensaje"],
        valor: json["valor"],
        idCompraEstado: json["id_compra_estado"],
        fechaRegistro: json["fecha_registro"],
        hora: json["hora"],
      );

  Map<String, dynamic> toJson() => {
        "id_chat": idChat,
        "id_compra": idCompra,
        "id_cliente_envia": idClienteEnvia,
        "id_cliente_recibe": idClienteRecibe,
        "envia": envia,
        "tipo": tipo,
        "estado": estado,
        "mensaje": mensaje,
        "valor": valor,
        "id_compra_estado": idCompraEstado,
        "fecha_registro": fechaRegistro,
        "hora": hora,
      };
}
