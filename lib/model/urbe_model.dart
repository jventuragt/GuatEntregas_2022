class UrbeModel {
  dynamic idUrbe;
  dynamic urbe;

  UrbeModel({
    this.idUrbe: -1,
    this.urbe,
  });

  factory UrbeModel.fromJson(Map<String, dynamic> json) => new UrbeModel(
        idUrbe: json["id_urbe"],
        urbe: json["urbe"],
      );

  Map<String, dynamic> toJson() => {
        "id_urbe": idUrbe,
        "urbe": urbe,
      };
}
