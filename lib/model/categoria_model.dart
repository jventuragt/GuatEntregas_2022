import '../sistema.dart';

class CategoriaModel {
  //id_categoria, nombre, label, estado
  int idCategoria;
  String nombre;
  String label;
  int estado;
  String img;

  CategoriaModel({
    this.idCategoria: 0,
    this.nombre,
    this.label,
    this.estado,
    this.img,
  });

  factory CategoriaModel.fromJson(Map<String, dynamic> json) =>
      new CategoriaModel(
        idCategoria: json["id_categoria"],
        nombre: json["nombre"],
        label: json["label"],
        estado: json["estado"],
        img: '${Sistema.dominio}ic/${json["img"]}.png',
      );
}
