import '../utils/cache.dart' as img;

class CompraPromocionModel {
  dynamic idCompra;
  dynamic idPromocion;
  dynamic incentivo;
  dynamic producto;
  dynamic descripcion;
  dynamic precio;
  dynamic cantidad;
  dynamic total;
  dynamic imagen;

  CompraPromocionModel({
    this.idCompra,
    this.idPromocion,
    this.incentivo,
    this.producto,
    this.descripcion,
    this.precio,
    this.cantidad,
    this.total,
    this.imagen,
  });

  factory CompraPromocionModel.fromJson(Map<String, dynamic> json) =>
      CompraPromocionModel(
        idCompra: json["id_compra"],
        idPromocion: json["id_promocion"],
        incentivo: json["incentivo"],
        producto: json["producto"],
        descripcion: json["descripcion"],
        precio: json["precio"] == null ? 0.0 : json["precio"].toDouble(),
        cantidad: json["cantidad"],
        total: json["total"].toDouble(),
        imagen: img.img(json["imagen"]),
      );

  Map<String, dynamic> toJson() => {
        "id_compra": idCompra,
        "id_promocion": idPromocion,
        "incentivo": incentivo,
        "producto": producto,
        "descripcion": descripcion,
        "precio": precio,
        "cantidad": cantidad,
        "total": total,
        "imagen": imagen,
      };
}
