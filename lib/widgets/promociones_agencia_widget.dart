import 'package:flutter/material.dart';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';

import '../bloc/agencia_bloc.dart';
import '../dialog/foto_promocion_dialog.dart';
import '../model/promocion_model.dart';
import '../pages/admin/productos_page.dart';
import '../utils/cache.dart' as cache;
import '../utils/personalizacion.dart' as prs;

class PromocionesAgenciaWidget extends StatelessWidget {
  final ScrollController _pageController = ScrollController();

  final List<PromocionModel> promociones;
  final AgenciaBloc _agenciaBloc = AgenciaBloc();
  final Function editarPromocion;
  final GlobalKey<ScaffoldState> scaffoldKey;

  PromocionesAgenciaWidget(
      {@required this.promociones,
      @required this.editarPromocion,
      @required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 500.0, childAspectRatio: 0.85),
        padding: EdgeInsets.only(right: 5.0, left: 5.0),
        controller: _pageController,
        itemCount: promociones.length,
        itemBuilder: (context, i) => _tarjeta(context, promociones[i]));
  }

  Widget _tarjeta(BuildContext context, PromocionModel promocion) {
    final tarjeta = Container(
      margin: EdgeInsets.only(top: 5, left: 10.0, right: 10.0, bottom: 10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.white,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black26,
            blurRadius: 1.0,
            spreadRadius: 1.0,
            offset: Offset(1.0, 1.0),
          ),
        ],
      ),
      child: _contenido(promocion, context),
    );

    return Stack(
      children: <Widget>[
        tarjeta,
        etiqueta(context, promocion),
        aprobado(context, promocion),
        Positioned(
            top: 20.0,
            right: 20.0,
            child: GestureDetector(
              onTap: () {
                _cambiarFoto(context, promocion);
              },
              child: Column(
                children: <Widget>[
                  promocion.promocion == 0
                      ? Container()
                      : CircleAvatar(
                          maxRadius: 25.0,
                          backgroundColor: Colors.green,
                          child: Icon(
                            Icons.star,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                  CircleAvatar(
                    maxRadius: 25.0,
                    backgroundColor:
                        promocion.promocion == 0 ? Colors.black : Colors.green,
                    child: Text(
                      promocion.idPromocion.toString(),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            )),
        Positioned(
          top: 10.0,
          left: 20.0,
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  primary: prs.colorButtonPrimary,
                  onPrimary: prs.colorTextDescription,
                  elevation: 2.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0))),
              child: Text('Sub productos'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ProductosPage(promocionModel: promocion),
                  ),
                );
              }),
        ),
        Positioned(
          top: 60.0,
          left: 20.0,
          child: LiteRollingSwitch(
            value: (promocion.promocion == 1 ? true : false),
            textOn: 'Promoción',
            textOff: 'Producto',
            colorOn: Colors.greenAccent[700],
            colorOff: Colors.deepPurple[700],
            iconOn: Icons.card_giftcard,
            iconOff: Icons.add_shopping_cart,
            textSize: 15.0,
            onChanged: (bool state) {
              if (state)
                promocion.promocion = 1;
              else
                promocion.promocion = 0;
            },
          ),
        ),
        Positioned(
          top: 101.0,
          right: 20.0,
          child: LiteRollingSwitch(
            value: (promocion.visible == 1 ? true : false),
            textOn: 'Visible',
            textOff: 'No visible',
            colorOn: Colors.greenAccent[700],
            colorOff: Colors.redAccent[700],
            iconOn: Icons.done,
            iconOff: Icons.remove_circle_outline,
            textSize: 15.0,
            onChanged: (bool state) {
              if (state)
                promocion.visible = 1;
              else
                promocion.visible = 0;
            },
          ),
        ),
        Positioned(
          top: 153.0,
          right: 20.0,
          child: LiteRollingSwitch(
            value: (promocion.activo == 1 ? true : false),
            textOn: 'Disponible',
            textOff: 'Agotado',
            colorOn: Colors.greenAccent[700],
            colorOff: Colors.redAccent[700],
            iconOn: Icons.done,
            iconOff: Icons.remove_circle_outline,
            textSize: 15.0,
            onChanged: (bool state) {
              if (state)
                promocion.activo = 1;
              else
                promocion.activo = 0;
            },
          ),
        )
      ],
    );
  }

  Widget aprobado(BuildContext context, PromocionModel promocionModel) {
    return Positioned(
      top: 120.0,
      left: 10,
      child: Container(
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: promocionModel.aprobado == 1 ? Colors.black : Colors.red,
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(10), bottomRight: Radius.circular(10)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Flexible(
                child: Text(
                    promocionModel.aprobado == 1
                        ? 'Aprobado ✔️'
                        : 'En revisión ⏳',
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center)),
          ],
        ),
      ),
    );
  }

  Widget etiqueta(BuildContext context, PromocionModel promocionModel) {
    if (promocionModel.destacado == 0) return Container();
    return Positioned(
      top: 160.0,
      left: 10,
      child: Container(
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: prs.colorButtonSecondary,
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(10), bottomRight: Radius.circular(10)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Flexible(
                child: Text('Destacado: ${promocionModel.incentivo}',
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center)),
          ],
        ),
      ),
    );
  }

  _cambiarFoto(BuildContext context, PromocionModel promocion) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return FotoPromocionDialog(_agenciaBloc.agenciaSeleccionada.agencia,
              promocion: promocion);
        });
  }

  Widget _contenido(PromocionModel promocion, BuildContext context) {
    final size = MediaQuery.of(context).size;
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    return Form(
      key: formKey,
      child: Column(
        children: <Widget>[
          Container(
            width: size.width - 20.0,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              child: cache.fadeImage(promocion.imagen, height: 200.0),
            ),
          ),
          Container(
            margin: EdgeInsets.all(1.0),
            child: Column(
              children: <Widget>[
                _crearNombre(promocion),
                SizedBox(height: 4.0),
                _crearDescripcion(promocion),
                SizedBox(height: 4.0),
                _crearStonck(context, formKey, promocion),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _crearNombre(PromocionModel promocion) {
    return TextFormField(
        maxLength: 40,
        initialValue: promocion.producto,
        textCapitalization: TextCapitalization.sentences,
        decoration: prs.decoration('Producto', null),
        onSaved: (value) => promocion.producto = value,
        validator: (value) {
          if (value.length < 5) return 'Mínimo 5 caracteres';
          return null;
        });
  }

  Widget _crearDescripcion(PromocionModel promocion) {
    return TextFormField(
      maxLength: 110,
      minLines: 1,
      maxLines: 3,
      initialValue: promocion.descripcion,
      textCapitalization: TextCapitalization.sentences,
      decoration: prs.decoration('Descripción', null),
      onSaved: (value) => promocion.descripcion = value,
    );
  }

  Widget _crearStonck(BuildContext context, GlobalKey<FormState> formKey,
      PromocionModel promocion) {
    double precio = 0.0;
    try {
      precio = double.parse(promocion.precio?.toString());
    } catch (err) {
      print('Eroror');
    }
    return Row(
      children: <Widget>[
        Container(
          width: 120.0,
          child: TextFormField(
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            maxLength: 5,
            initialValue: precio.toStringAsFixed(2),
            onChanged: (value) {
              String precio = value.replaceAll(',', '.');
              promocion.precio = precio;
            },
            decoration: prs.decoration('Precio', Icon(Icons.monetization_on)),
          ),
        ),
        Container(
          width: 140.0,
          child: TextFormField(
            maxLength: 15,
            initialValue: promocion.incentivo,
            onChanged: (value) {
              promocion.incentivo = value;
            },
            decoration: prs.decoration('Incentivo', null),
          ),
        ),
        Expanded(child: Container()),
        CircleAvatar(
          maxRadius: 25.0,
          backgroundColor: prs.colorButtonSecondary,
          child: IconButton(
              icon: Icon(Icons.save, color: Colors.white, size: 30.0),
              color: prs.colorButtonSecondary,
              onPressed: () {
                FocusScope.of(context).requestFocus(FocusNode());
                formKey.currentState.save();
                if (!formKey.currentState.validate()) return;
                editarPromocion(promocion);
              }),
        )
      ],
    );
  }
}
