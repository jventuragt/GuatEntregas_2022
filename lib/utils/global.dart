import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GLOBAL {
  static const int NONE = -1;
  static const int CONECT = 1;
  static const int DISCONECT = 0;

  static String mensaje = 'Esperando...';
  static IconData icono = Icons.local_dining;
  static Color color = Colors.black87;
  static int conectado = -1;
  static String connectivityResult = 'x';

  static const int reciboDinero = 1, noReciboDinero = 0;
}
