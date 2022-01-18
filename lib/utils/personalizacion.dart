import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

Color hexToColor(String code) {
  return Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
}

InputDecoration decorationSearch(String labelText) {
  return InputDecoration(
    labelStyle: TextStyle(color: colorTextTitle),
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: colorLineBorder, width: 1.0),
    ),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: colorLinearProgress, width: 1.0),
    ),
    prefixIcon: Icon(Icons.search, size: 27.0, color: colorLinearProgress),
    labelText: labelText,
  );
}

InputDecoration decoration(String labelText, Widget prefixIcon,
    {Widget suffixIcon}) {
  return InputDecoration(
    labelStyle: TextStyle(color: colorTextInputLabel),
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    counterText: '',
    errorStyle: TextStyle(color: Colors.red),
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: colorLineBorder, width: 1.0),
    ),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: colorLinearProgress, width: 1.0),
    ),
    contentPadding: EdgeInsets.only(bottom: 10.0, left: 10.0, right: 10.0),
    labelText: labelText,
  );
}

// const String colorSecondary = '#005b9f'; //Purpura
// get colorAppBar => hexToColor('#005b9f');

const String colorSecondary = '#673AB7'; //Purpura
get colorAppBar => hexToColor('#0B0604');

get colorButtonBackground => hexToColor('#FBF9F7');

get colorButtonSecondary => hexToColor(colorSecondary);

get colorButtonPrimary => hexToColor('#FFFFFF');

get colorTextButtonPrimary => hexToColor(colorSecondary);

get colorTextButton => hexToColor(colorSecondary);

get colorCanvas => hexToColor('#F8F8F8');

get colorLinearProgress => hexToColor(colorSecondary);

get colorTextTitle => hexToColor('#0E0525');

get colorTextDescription => hexToColor('#212A37');

get colorTextInputLabel => hexToColor(colorSecondary);

get colorLineBorder => hexToColor('#DDDDDD');

get colorIcons => hexToColor(colorSecondary);

get colorIconsAppBar => hexToColor("#FFFFFF");

get colorTextAppBar => hexToColor('#FFFFFF');

get iconoFacebook =>
    Icon(FontAwesomeIcons.facebookF, color: Colors.white, size: 30.0);

get iconoGoogle =>
    Icon(FontAwesomeIcons.google, color: Colors.white, size: 30.0);

get iconoApple => Icon(FontAwesomeIcons.apple, color: Colors.white, size: 30.0);

get iconoCorreo => Icon(Icons.email, color: colorIcons);

get iconoNombres => Icon(FontAwesomeIcons.peopleArrows, color: colorIcons);

get anchoFormulario {
  return 500.0;
}

get ancho {
  return 1100.0;
}

get iconoApp => Icon(FontAwesomeIcons.opencart, color: colorIcons, size: 55.0);

get iconoCheck => Icon(FontAwesomeIcons.fingerprint, color: colorIcons);

get iconoCompras => Icon(FontAwesomeIcons.opencart, color: colorIcons);

get iconoPaquetes => Icon(FontAwesomeIcons.handHoldingUsd, color: colorIcons);

get iconoVentas => Icon(FontAwesomeIcons.handHoldingHeart, color: colorIcons);

get iconoRegistrar => Icon(Icons.touch_app, color: colorIcons);

get iconoIngresar => Icon(Icons.beenhere, color: colorIcons);

get iconoCelular => Icon(Icons.phone_android, color: colorIcons);

get iconoLink => Icon(FontAwesomeIcons.link, color: colorIcons);

get iconoCahs => Icon(FontAwesomeIcons.wallet, color: colorIcons, size: 22.0);

get iconoMoney =>
    Icon(FontAwesomeIcons.moneyBillWave, color: colorIcons, size: 22.0);

get iconoCredito =>
    Icon(FontAwesomeIcons.creditCard, color: colorIcons, size: 22.0);

get iconoContrasenia =>
    Icon(FontAwesomeIcons.key, color: colorIcons, size: 22.0);

get iconoPolitica => Icon(FontAwesomeIcons.userLock, color: colorIcons);

get iconoTerminos => Icon(FontAwesomeIcons.book, color: colorIcons);

get iconoContraseniaNueva =>
    Icon(FontAwesomeIcons.unlockAlt, color: colorIcons, size: 22.0);

get iconoCarrito =>
    Icon(Icons.add_shopping_cart, color: Colors.white, size: 35.0);

get iconoCarritoProducto =>
    Icon(Icons.add_shopping_cart, color: Colors.white, size: 25.0);

get iconoAgregarCarrito =>
    Icon(FontAwesomeIcons.cartArrowDown, color: colorIcons, size: 22.0);

get iconoAgregarCarritoPromo =>
    Icon(FontAwesomeIcons.cartArrowDown, color: colorIcons, size: 27.0);

get iconoAgregarCarritoProducto =>
    Icon(FontAwesomeIcons.cartArrowDown, color: colorIcons, size: 16.0);

get iconoCerrarSession => Icon(FontAwesomeIcons.signOutAlt);

get iconoSalir => Icon(FontAwesomeIcons.doorOpen, color: colorIcons);

get iconoBuscar => Icon(FontAwesomeIcons.searchPlus, color: colorIcons);

get iconoDetalle =>
    Icon(FontAwesomeIcons.fileSignature, color: colorIcons, size: 25.0);

get iconoAbout => Icon(FontAwesomeIcons.atlassian, color: colorIcons);

get iconoRegistroFoto => Icon(FontAwesomeIcons.cameraRetro, color: colorIcons);

get iconoPromocion => Icon(Icons.card_giftcard, color: colorIcons, size: 29.0);

get iconoDirecciones =>
    Icon(FontAwesomeIcons.map, color: colorIcons, size: 22.0);

get iconoDespachar => Icon(FontAwesomeIcons.route, color: Colors.white);

get iconoDespachando => Icon(FontAwesomeIcons.rocket, color: Colors.green);

get iconoContactanos =>
    Icon(FontAwesomeIcons.envelopeOpenText, color: colorIcons, size: 21.0);

get iconoPuntos => Icon(FontAwesomeIcons.award, color: colorIcons, size: 25.0);

get iconoNotificacion =>
    Icon(FontAwesomeIcons.bell, color: colorIcons, size: 25.0);

get iconoComprar =>
    Icon(FontAwesomeIcons.moneyBillWave, color: colorIcons, size: 21.0);

get iconoDinero => Icon(Icons.attach_money, color: colorIcons, size: 22.0);

get iconoObsequio =>
    Icon(FontAwesomeIcons.gift, color: colorIconsAppBar, size: 30.0);

get iconoMenuMetodoPago =>
    Icon(FontAwesomeIcons.creditCard, color: colorIcons, size: 22.0);

get iconoPay => Icon(FontAwesomeIcons.qrcode, color: colorIcons, size: 22.0);

get iconoCodigo =>
    Icon(FontAwesomeIcons.hashtag, color: colorIcons, size: 18.0);

get iconoPresionar => Icon(FontAwesomeIcons.handPointUp, color: colorIcons);

get iconoChat => Icon(FontAwesomeIcons.solidCommentDots, color: Colors.green);

get iconoLlamar => Icon(FontAwesomeIcons.phoneAlt, color: Colors.green);

get iconoActivo => Icon(FontAwesomeIcons.userCheck, color: Colors.green);

get iconoDesActivo => Icon(FontAwesomeIcons.userSlash, color: Colors.red);

get iconoChatActivo => Icon(FontAwesomeIcons.commentsDollar, color: Colors.red);

get iconoRuta => Icon(FontAwesomeIcons.route, color: colorIcons);

get iconoArrastrar => Icon(FontAwesomeIcons.bars, color: Colors.black);

get iconoAgencia => Icon(FontAwesomeIcons.city, color: colorIcons);

get iconoPreRegistroAgencia =>
    Icon(FontAwesomeIcons.hubspot, color: colorIcons);

get iconoSucursal =>
    Icon(FontAwesomeIcons.storeAlt, color: colorIcons, size: 20.0);

get iconoTurno => Icon(FontAwesomeIcons.bell, color: colorIcons);

get iconoHorario => Icon(FontAwesomeIcons.calendarDay, color: colorIcons);

get iconoCasa => Icon(Icons.home, color: colorIcons);

get iconoLocationBuscar =>
    Icon(Icons.location_searching, color: colorIcons, size: 25.0);

get iconoLocationCentro =>
    Icon(Icons.location_searching, color: colorIcons, size: 30.0);

get iconoGuardarDireccion => Icon(Icons.save, color: colorIcons);

get iconoGuardarRuta => Icon(Icons.save, color: colorIcons);

get iconoSolicitarCalificar =>
    Icon(FontAwesomeIcons.grinBeam, color: colorIcons);

get iconoCancelada => Icon(FontAwesomeIcons.frown, color: Colors.blueGrey);

get iconoRecibirDinero =>
    Icon(FontAwesomeIcons.handHoldingUsd, color: Colors.white);

get iconoMetodoPago =>
    Icon(FontAwesomeIcons.handHoldingUsd, color: colorIcons, size: 21.0);

get iconoFactura => Icon(FontAwesomeIcons.edit, color: colorIcons, size: 20.0);

get iconoTarjeta =>
    Icon(FontAwesomeIcons.creditCard, color: colorIcons, size: 30.0);

get iconoButtonTarjeta => Icon(FontAwesomeIcons.creditCard, color: colorIcons);

get iconoPagoTarjeta =>
    Icon(FontAwesomeIcons.creditCard, color: Colors.redAccent, size: 35.0);

get iconoPagoCupon =>
    Icon(FontAwesomeIcons.gift, color: Colors.redAccent, size: 35.0);

get iconoPagoEfefcivo =>
    Icon(FontAwesomeIcons.moneyBillWave, color: Colors.green, size: 35.0);

get iconoCompartir => Icon(FontAwesomeIcons.shareAlt, color: colorIcons);

get iconoDespachor => Icon(FontAwesomeIcons.peopleCarry, color: colorIcons);

get iconoDespachador => Icon(FontAwesomeIcons.peopleCarry, color: Colors.white);

get iconoRecoger => Icon(FontAwesomeIcons.hands, color: Colors.white);

get iconoDespachadorGreen =>
    Icon(FontAwesomeIcons.peopleCarry, color: Colors.green);

get iconoCancelar =>
    Icon(FontAwesomeIcons.timesCircle, color: Colors.red, size: 25.0);

get iconoTomarFoto => Icon(Icons.camera_alt, color: colorIcons);

get iconoSubirFoto => Icon(FontAwesomeIcons.image, color: colorIcons);

get iconoEnviarMensaje => Icon(Icons.send, color: colorIcons);

get iconoViajeIniciado =>
    Icon(FontAwesomeIcons.satelliteDish, color: colorIcons);

get iconoViaje => Icon(FontAwesomeIcons.road, color: colorIcons);

get iconoPoolConfirmado =>
    Icon(FontAwesomeIcons.handshake, color: Colors.green, size: 21.0);

get iconoPool =>
    Icon(FontAwesomeIcons.userClock, color: Colors.red, size: 21.0);

get iconoIniciarViaje => Icon(FontAwesomeIcons.car, color: Colors.green);

get iconoClienteAbordo =>
    Icon(FontAwesomeIcons.handsHelping, color: Colors.green);

get iconoClienteLlego =>
    Icon(FontAwesomeIcons.handHoldingUsd, color: Colors.green);
