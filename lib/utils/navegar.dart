import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../model/catalogo_model.dart';
import '../pages/delivery/menu_page.dart';
import '../providers/catalogo_provider.dart';

verMenu(BuildContext context, dynamic idCatalogo) async {
  CatalogoProvider _catalogoProvider = CatalogoProvider();
  CatalogoModel catalogoModel = await _catalogoProvider.ver(idCatalogo);
  Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => MenuPage(catalogoModel)),
      (Route<dynamic> route) {
    return route.isFirst;
  });
  return;
}
