import 'dart:convert';

import 'package:http/http.dart' as http;

import '../model/cajero_model.dart';
import '../model/hashtag_model.dart';
import '../preference/shared_preferences.dart';
import '../sistema.dart';
import '../utils/utils.dart' as utils;

class HashtagProvider {
  final PreferenciasUsuario _prefs = PreferenciasUsuario();

  final String _urlVer = 'hashtag/ver';

  Future<HashtagModel> ver(String hashtag, List<CajeroModel> cajeros) async {
    var client = http.Client();
    try {
      final resp = await client.post(Uri.parse(Sistema.dominio + _urlVer),
          headers: utils.headers,
          body: {
            'idCliente': _prefs.idCliente,
            'auth': _prefs.auth,
            'hashtag': hashtag,
            'cajeros': json.encode(cajeros),
          });
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      if (resp.statusCode == 200) return HashtagModel.fromJson(decodedResp);
    } catch (err) {
      print('hashtag_provider error: $err');
    } finally {
      client.close();
    }
    return HashtagModel();
  }
}
