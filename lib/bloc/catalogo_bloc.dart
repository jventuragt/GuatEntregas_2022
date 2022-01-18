import 'dart:async';

import '../model/catalogo_model.dart';
import '../model/direccion_model.dart';
import '../model/promocion_model.dart';
import '../preference/db_provider.dart';
import '../preference/shared_preferences.dart';
import '../providers/catalogo_provider.dart';

class CatalogoBloc {
  final PreferenciasUsuario _prefs = PreferenciasUsuario();
  final CatalogoProvider _catalogoProvider = CatalogoProvider();
  List<CatalogoModel> catalogos = [];
  List<CatalogoModel> favoritos = [];
  List<CatalogoModel> recomendados = [];

  static CatalogoBloc _instancia;

  CatalogoBloc._internal();

  factory CatalogoBloc() {
    if (_instancia == null) {
      _instancia = CatalogoBloc._internal();
    }
    return _instancia;
  }

  final catalogosStreamController =
      StreamController<List<CatalogoModel>>.broadcast();

  Function(List<CatalogoModel>) get catalogoSink =>
      catalogosStreamController.sink.add;

  Stream<List<CatalogoModel>> get catalogoStream =>
      catalogosStreamController.stream;

  final favoritosStreamController =
      StreamController<List<CatalogoModel>>.broadcast();

  Function(List<CatalogoModel>) get favoritoSink =>
      favoritosStreamController.sink.add;

  Stream<List<CatalogoModel>> get favoritoStream =>
      favoritosStreamController.stream;

  final recomendadoStreamController =
      StreamController<List<CatalogoModel>>.broadcast();

  Function(List<CatalogoModel>) get recomendadoSink =>
      recomendadoStreamController.sink.add;

  Stream<List<CatalogoModel>> get recomendadoStream =>
      recomendadoStreamController.stream;

  Future<bool> listarAgencias(int selectedIndex,
      {DireccionModel direccionModel,
      bool isConsultar: false,
      int categoria: 0,
      String criterio: '',
      bool isBuscar: false}) async {
    if (isConsultar) {
      catalogos.clear();
      favoritos.clear();
      catalogos.add(new CatalogoModel(idAgencia: -100));
      catalogoSink(catalogos);
    }

    _catalogoProvider
        .listarAgencias(3, direccionModel.idUrbe, categoria, criterio)
        .then((favoritosResponse) {
      favoritos.clear();
      favoritos.addAll(favoritosResponse);
      favoritoSink(favoritos);
    });

    _catalogoProvider
        .listarAgencias(4, direccionModel.idUrbe, categoria, criterio)
        .then((recoendadosResponse) {
      recomendados.clear();
      recomendados.addAll(recoendadosResponse);
      recomendadoSink(recomendados);
    });

    if (!isBuscar) {
      final catalogosResponse = await _catalogoProvider.listarAgencias(
          selectedIndex, direccionModel.idUrbe, categoria, criterio);
      catalogos.clear();
      catalogos.addAll(catalogosResponse);
      catalogoSink(catalogos);
    }

    return true;
  }

  refrezcarFavoritos() {
    _catalogoProvider
        .listarAgencias(3, _prefs.idUrbe, 0, '')
        .then((favoritosResponse) {
      favoritos.clear();
      favoritos.addAll(favoritosResponse);
      favoritoSink(favoritos);
    });
  }

  Future refresh() async {
    List<CatalogoModel> old = [];
    old.addAll(catalogos);
    catalogos.clear();
    catalogos.addAll(old);
    catalogoSink(catalogos);
    return;
  }

  List<PromocionModel> promociones = [];
  final promocionesStreamController =
      StreamController<List<PromocionModel>>.broadcast();

  Function(List<PromocionModel>) get promocionSink =>
      promocionesStreamController.sink.add;

  Stream<List<PromocionModel>> get promocionStream =>
      promocionesStreamController.stream;

  int total = 0; //Elemetons que posee en total para paginar
  final isConsultandoStreamController = StreamController<int>.broadcast();

  Function(int) get isConsultandoSink => isConsultandoStreamController.sink.add;

  Stream<int> get isConsultandoStream => isConsultandoStreamController.stream;
  int consultando = 0;
  int pagina = 0;

  Future listarPromociones(dynamic idAgencia,
      {dynamic alias: '', bool isClean: false, dynamic idPromocion: 0}) async {
    if (_prefs.idAgencia.toString() != idAgencia.toString() ||
        isClean ||
        pagina == 0) {
      promociones.clear();
      consultando = 0;
      promocionSink(promociones);
      total = 0;
      pagina = 0;
    }
    if (consultando == 1 && promociones.length > 0) return;
    if (total > 1 && promociones.length >= total) return;
    consultando = 1;
    isConsultandoSink(consultando);
    _prefs.idAgencia = idAgencia.toString();
    await _catalogoProvider
        .listarPromociones(idAgencia, alias, isClean, pagina, idPromocion,
            (_promocionesResponse, _total) async {
      total = _total;
      List<PromocionModel> aux =
          await DBProvider.db.listarPorAgencia(idAgencia);
      aux.forEach((promo) {
        for (var promocion in _promocionesResponse) {
          if (promo.idPromocion.toString() ==
              promocion.idPromocion.toString()) {
            promocion.isComprada = true;
            break;
          }
        }
      });
      if (promociones.length >= total) {
        consultando = -1;
      } else {
        consultando = 0;
      }
      isConsultandoSink(consultando);
      promociones.addAll(_promocionesResponse);
    });
    return promocionSink(promociones);
  }

  void actualizar(PromocionModel promocionModel) async {
    promociones.forEach((promocion) {
      if (promocion.idPromocion.toString() ==
          promocionModel.idPromocion.toString()) {
        promocion.isComprada = promocionModel.isComprada;
        promocion.cantidad = promocionModel.cantidad;
      }
    });
    promocionSink(promociones);
  }

  void disposeStreams() {
    recomendadoStreamController?.close();
    favoritosStreamController?.close();
    catalogosStreamController?.close();
    promocionesStreamController?.close();
    isConsultandoStreamController?.close();
  }
}
