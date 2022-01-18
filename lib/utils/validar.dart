String validarNombre(String nombre) {
  String value = nombre.trim();
  if (value.length < 8) return 'Mínimo 8 caracteres';
  bool nameValid = RegExp(
          r"^([A-Za-zÁÉÍÓÚñáéíóúÑ]{0}[A-Za-zÁÉÍÓÚñáéíóúÑ\']+[\s])+([A-Za-zÁÉÍÓÚñáéíóúÑ]{0}?[A-Za-zÁÉÍÓÚñáéíóúÑ\'])+[\s]?([A-Za-zÁÉÍÓÚñáéíóúÑ]{0}?[A-Za-zÁÉÍÓÚñáéíóúÑ\'])+$")
      .hasMatch(value);
  if (!nameValid) return 'Nombre inválido';
  nameValid = RegExp(r'(.)\1{2}').hasMatch(value);
  if (nameValid) return 'Nombre inválido';
  var split = value.split(' ');
  for (var palabra in split) {
    if (palabra.length <= 1) return 'Nombre inválido';

    nameValid = RegExp(r'[aeiouAEIOUÁÉÍÓÚñáéíóú]').hasMatch(palabra.trim());
    if (!nameValid) return 'Nombre inválido';
  }
  return null;
}

String validarCorreo(String email) {
  String value = email.trim();
  if (value.length < 8) return 'Mínimo 8 caracteres';
  bool emailValid = RegExp(
          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
      .hasMatch(value);

  if (!emailValid) return 'Correo inválido';
  return null;
}

String validarNumero(String email) {
  String value = email.trim();
  if (value.length < 8) return 'Mínimo 8 caracteres';
  bool emailValid = RegExp(r"^[0-9+]").hasMatch(value);
  if (!emailValid) return 'Número inválido';
  return null;
}

String validarDni(String email) {
  String value = email.trim();
  if (value.length < 8) return 'Mínimo 8 caracteres';
  return null;
}

String validarDireccion(String email) {
  String value = email.trim();
  if (value.length < 3) return 'Mínimo 3 caracteres';
  return null;
}

String validarNombreLocal(String email) {
  String value = email.trim();
  if (value.length < 5) return 'Mínimo 5 caracteres';
  return null;
}

String validarMinimo8(String email) {
  String value = email.trim();
  if (value.length < 8) return 'Mínimo 8 caracteres';
  return null;
}

String validarMinimo3(String email) {
  String value = email.trim();
  if (value.length < 3) return 'Mínimo 3 caracteres';
  return null;
}

String validarMonto(String value) {
  value = value.trim();
  value = value.replaceFirst(',', '.');
  if (value.length < 1) return 'Monto incorrecto';
  bool emailValid = RegExp(r"^[0-9+]").hasMatch(value);
  if (!emailValid) return 'Monto incorrecto';
  try {
    double.parse(value).toStringAsFixed(2);
  } catch (err) {
    return 'Monto incorrecto';
  }
  return null;
}
