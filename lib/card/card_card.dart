import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../model/card_model.dart';
import '../utils/personalizacion.dart' as prs;

class CardCard extends StatelessWidget {
  CardCard({@required this.cardModel, this.onTab, this.key});

  final CardModel cardModel;
  final Function onTab;
  final key;

  @override
  Widget build(BuildContext context) {
    return _card(context);
  }

  Widget _card(BuildContext context) {
    final card = Container(
      padding: EdgeInsets.only(left: 10.0, right: 10.0),
      height: 115.0,
      child: Card(
        elevation: 0.22,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: Row(
          children: <Widget>[
            _contenido(),
            cardModel.iconoTarjeta(),
            SizedBox(width: 20.0),
          ],
        ),
      ),
    );
    return Stack(
      children: <Widget>[
        card,
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
                splashColor: Colors.blueAccent.withOpacity(0.6),
                onTap: () => onTab(cardModel)),
          ),
        ),
      ],
    );
  }

  Widget _contenido() {
    return Expanded(
      child: Container(
        padding: EdgeInsets.only(left: 30.0, top: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 20.0),
            Row(
              children: [
                cardModel.iconoStatus(),
                SizedBox(width: 5),
                Text('${cardModel.number}',
                    style: TextStyle(
                        fontSize: 14.0, color: prs.colorTextInputLabel))
              ],
            ),
            SizedBox(height: 10),
            Text('${cardModel.holderName.toString().toUpperCase()}',
                style: TextStyle(fontSize: 14.0)),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
