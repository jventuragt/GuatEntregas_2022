import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class ShimmerCard extends StatelessWidget {
  ShimmerCard();

  @override
  Widget build(BuildContext context) {
    return _card(context);
  }

  Widget _cardContenido() {
    return Row(
      children: <Widget>[
        _avatar(),
        _contenido(),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            _icono(),
          ],
        ),
        SizedBox(width: 5.0)
      ],
    );
  }

  Widget _card(BuildContext context) {
    final card = Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: _cardContenido(),
    );
    return Stack(
      children: <Widget>[card],
    );
  }

  Widget _avatar() {
    return Shimmer(
      duration: Duration(seconds: 3),
      color: Colors.grey[300],
      child: ClipRRect(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)),
        child: Container(width: 100, height: 120, color: Colors.grey[100]),
      ),
    );
  }

  Widget _contenido() {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Shimmer(
              duration: Duration(seconds: 3),
              //Default value
              color: Colors.white,
              //Default value
              enabled: true,
              //Default value
              direction: ShimmerDirection.fromLTRB(),
              //Default Value
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                child:
                    Container(width: 200, height: 12, color: Colors.grey[100]),
              ),
            ),
            SizedBox(height: 4),
            Shimmer(
              duration: Duration(seconds: 3),
              //Default value
              color: Colors.white,
              //Default value
              enabled: true,
              //Default value
              direction: ShimmerDirection.fromLTRB(),
              //Default Value
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                child:
                    Container(width: 200, height: 12, color: Colors.grey[100]),
              ),
            ),
            SizedBox(height: 4),
            Shimmer(
              duration: Duration(seconds: 3),
              //Default value
              color: Colors.white,
              //Default value
              enabled: true,
              //Default value
              direction: ShimmerDirection.fromLTRB(),
              //Default Value
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                child:
                    Container(width: 100, height: 12, color: Colors.grey[100]),
              ),
            ),
            SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  Widget _icono() {
    return Shimmer(
      duration: Duration(seconds: 3),
      color: Colors.grey[300],
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        child: Container(width: 40, height: 40, color: Colors.grey[100]),
      ),
    );
  }
}
