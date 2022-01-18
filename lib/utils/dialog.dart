import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/personalizacion.dart' as prs;

mostrar(BuildContext context, String mensaje,
    {Function fIzquierda,
    String mIzquierda: 'ACEPTAR',
    Function fBotonIDerecha,
    String mBotonDerecha: 'CANCELAR',
    String titulo: 'Importante',
    Color color: Colors.redAccent,
    IconData icon: Icons.cancel}) {
  showGeneralDialog(
    barrierColor: Colors.black.withOpacity(0.5),
    transitionBuilder: (context, a1, a2, widget) {
      final curvedValue =
          Curves.fastLinearToSlowEaseIn.transform(a1.value) - 1.0;
      return Transform(
        transform:
            Matrix4.translationValues(curvedValue * 400.0, curvedValue, 0.0),
        child: Opacity(
          opacity: a1.value,
          child: AlertDialog(
            shape: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.0),
                borderSide: BorderSide(width: 0.0, color: Colors.black38)),
            title: Text(titulo.toString(), textAlign: TextAlign.center),
            content: Container(
              width: 350.0,
              child: Text(mensaje.toString()),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(mIzquierda),
                onPressed: () {
                  if (fIzquierda == null) {
                    Navigator.of(context).pop();
                  } else {
                    fIzquierda();
                  }
                },
              ),
              (fBotonIDerecha == null)
                  ? Container()
                  : ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          primary: prs.colorButtonSecondary,
                          elevation: 2.0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0))),
                      label: Text(mBotonDerecha),
                      icon: Icon(icon, size: 18.0),
                      onPressed: fBotonIDerecha,
                    ),
            ],
          ),
        ),
      );
    },
    transitionDuration: Duration(milliseconds: 250),
    barrierDismissible: false,
    barrierLabel: '',
    context: context,
    pageBuilder: (context, animation1, animation2) {
      return;
    },
  );
}

llamar(BuildContext context, Widget contenido) {
  showGeneralDialog(
    barrierColor: Colors.black.withOpacity(0.5),
    transitionBuilder: (context, a1, a2, widget) {
      final curvedValue =
          Curves.fastLinearToSlowEaseIn.transform(a1.value) - 1.0;
      return Transform(
        transform:
            Matrix4.translationValues(curvedValue * 400.0, curvedValue, 0.0),
        child: Opacity(
          opacity: a1.value,
          child: AlertDialog(
              shape: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide(width: 0.0, color: Colors.black38)),
              title: Text('Llamar'),
              content: contenido,
              actions: <Widget>[
                TextButton(
                  child: Text('REGRESAR'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ]),
        ),
      );
    },
    transitionDuration: Duration(milliseconds: 250),
    barrierDismissible: false,
    barrierLabel: '',
    context: context,
    pageBuilder: (context, animation1, animation2) {
      return;
    },
  );
}
