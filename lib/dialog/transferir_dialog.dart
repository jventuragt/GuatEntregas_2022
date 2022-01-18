import 'package:flutter/material.dart';
import 'package:flutter_touch_spin/flutter_touch_spin.dart';
import 'package:intl/intl.dart';

import '../preference/shared_preferences.dart';
import '../utils/button.dart' as btn;
import '../utils/personalizacion.dart' as prs;

class TransferirDialog extends StatefulWidget {
  final double monto;

  final Function confirmar;

  TransferirDialog(this.monto, this.confirmar) : super();

  TransferirDialogState createState() => TransferirDialogState();
}

class TransferirDialogState extends State<TransferirDialog>
    with TickerProviderStateMixin {
  double trasferir;
  final prefs = PreferenciasUsuario();

  TransferirDialogState();

  @override
  void initState() {
    trasferir = widget.monto;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text('Transferir crédito a Money')),
        body: Center(
            child: Container(child: _body(), width: prs.anchoFormulario)),
      ),
    );
  }

  Widget _body() {
    return Column(
      children: <Widget>[
        Expanded(child: SingleChildScrollView(child: _contenido())),
        btn.confirmar('COMFIRMAR TRANSFERENCIA', _registrarTransferir)
      ],
    );
  }

  Widget _contenido() {
    return Column(
      children: <Widget>[
        Column(
          children: <Widget>[
            SizedBox(height: 30.0),
            Padding(
              padding: EdgeInsets.only(left: 20.0, right: 20.0),
              child: Text('Monto disponible'),
            ),
            SizedBox(height: 10.0),
            Center(
              child: Text(
                '${widget.monto.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 60.0, color: prs.colorIcons),
              ),
            ),
            SizedBox(height: 10.0),
            Padding(
              padding: EdgeInsets.only(left: 20.0, right: 20.0),
              child: Text(
                'Ingrese el monto a transferir',
                style: TextStyle(color: Colors.redAccent, fontSize: 15.0),
              ),
            ),
            SizedBox(height: 30.0),
            TouchSpin(
              displayFormat: NumberFormat.currency(
                  locale: "es_ES", symbol: "USD", decimalDigits: 2),
              value: widget.monto,
              min: 8,
              max: widget.monto,
              step: 0.50,
              textStyle: TextStyle(fontSize: 30),
              iconSize: 49.0,
              addIcon: Icon(Icons.add_circle_outline),
              subtractIcon: Icon(Icons.remove_circle_outline),
              iconActiveColor: Colors.green,
              iconDisabledColor: Colors.grey,
              iconPadding: EdgeInsets.only(left: 25.0, right: 25.0),
              onChanged: (val) {
                trasferir = val;
                if (mounted) setState(() {});
              },
            ),
            SizedBox(height: 30.0),
            Padding(
              padding: EdgeInsets.only(left: 20.0, right: 20.0),
              child: Text(
                'Confirma si deseas transferir ${trasferir.toStringAsFixed(2)} USD',
                style: TextStyle(color: Colors.redAccent, fontSize: 14.0),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 10.0),
          ],
        ),
      ],
    );
  }

  void _registrarTransferir() async {
    if (trasferir < 2 || trasferir > widget.monto) return;
    Navigator.pop(context);
    widget.confirmar(widget.monto, trasferir);
  }
}
