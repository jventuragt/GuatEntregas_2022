import 'dart:async';

import 'package:badges/badges.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import '../../bloc/cajero_bloc.dart';
import '../../bloc/catalogo_bloc.dart';
import '../../bloc/direccion_bloc.dart';
import '../../bloc/promocion_bloc.dart';
import '../../card/catalogo_card.dart';
import '../../card/chat_compra_card.dart';
import '../../card/shimmer_card.dart';
import '../../dialog/direccion_dialog.dart';
import '../../model/cajero_model.dart';
import '../../model/catalogo_model.dart';
import '../../model/categoria_model.dart';
import '../../model/chat_compra_model.dart';
import '../../model/chat_despacho_model.dart';
import '../../model/despacho_model.dart';
import '../../model/direccion_model.dart';
import '../../model/promocion_model.dart';
import '../../preference/deep_link.dart';
import '../../preference/push_provider.dart';
import '../../preference/shared_preferences.dart';
import '../../providers/categoria_provider.dart';
import '../../providers/cliente_provider.dart';
import '../../sistema.dart';
import '../../utils/button.dart' as btn;
import '../../utils/cache.dart' as cache;
import '../../utils/compra.dart' as compra;
import '../../utils/conexion.dart';
import '../../utils/conf.dart' as config;
import '../../utils/conf.dart' as conf;
import '../../utils/dialog.dart' as dlg;
import '../../utils/permisos.dart' as permisos;
import '../../utils/personalizacion.dart' as prs;
import '../../utils/utils.dart' as utils;
import '../../widgets/comprar_catalogo_widget.dart';
import '../../widgets/comprar_promo_widget.dart';
import '../../widgets/en_linea_widget.dart';
import '../../widgets/menu_widget.dart';
import '../planck/direccion_page.dart';
import 'calificacioncompra_page.dart';
import 'chat_cliente_page.dart';
import 'menu_page.dart';
import 'solicitud_page.dart';

//INIT DELIVERY
class CatalogoPage extends StatefulWidget {
  final bool isDeeplink;

  CatalogoPage({this.isDeeplink: false});

  @override
  _CatalogoPageState createState() => _CatalogoPageState();
}

class _CatalogoPageState extends State<CatalogoPage>
    with WidgetsBindingObserver {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final DeepLink deeplink = DeepLink();
  final ClienteProvider _clienteProvider = ClienteProvider();
  final CajeroBloc _cajeroBloc = CajeroBloc();
  final CatalogoBloc _catalogoBloc = CatalogoBloc();
  final DireccionBloc _direccionBloc = DireccionBloc();
  final PromocionBloc _promocionBloc = PromocionBloc();
  final PushProvider _pushProvider = PushProvider();
  final CategoriaProvider _categoriaProvider = CategoriaProvider();
  final PreferenciasUsuario _prefs = PreferenciasUsuario();
  final TextEditingController _typeControllerDireccion =
      TextEditingController();

  bool _saving = false;
  bool _radar = false;
  bool _isBuscar = false;

  ScrollController pageControllerProductosDestacados = ScrollController();
  ScrollController pageControllerProductosPromocion = ScrollController();
  ScrollController pageControllerRecomendado = ScrollController();
  ScrollController pageControllerFavoritos = ScrollController();

  StreamController<bool> _cambios = StreamController<bool>.broadcast();
  int _selectedIndex =
      Sistema.idAplicativo != Sistema.idAplicativoCuriosity ? 0 : 0;
  CategoriaModel _categoriaModelSelect = CategoriaModel();
  bool _direccion = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController _textControllerBuscar;
  String _tituloAgencias = 'Recomendados';
  String _subTituloAgencias = 'Te van a encantar';

  String _tituloProductos = 'Destacados';
  String _subTituloProductos = 'No te los puedes perder';
  double maxCrossAxisExtent = 198.0;
  String _tituloOfertas = 'Ofertas';
  String _subTituloOfertas = 'Te pueden interesar';

  void disposeStreams() {
    _cambios?.close();
  }

  @override
  void initState() {
    _textControllerBuscar = TextEditingController(text: '');
    bool _init = false;
    _cambios.stream.listen((internet) {
      if (!mounted) return;
      if (internet && _init) {
        _catalogoBloc.listarAgencias(_selectedIndex,
            direccionModel: _direccionBloc.direccionSeleccionada);
        _cajeroBloc.listarEnCamino();
      }
      _direccionBloc.listar();
      _init = true;
      _refrezcar();
    });

    _typeControllerDireccion.text = _direccionBloc.direccionSeleccionada.alias;
    Conexion();
    WidgetsBinding.instance.addObserver(this);

    if (_direccionBloc.direccionSeleccionada.idUrbe <= 0) {
      _direccionBloc.direccionSeleccionada.idUrbe = int.parse(_prefs.idUrbe);
    }
    // if (Sistema.idAplicativo == Sistema.idAplicativoCuxi) {
    //   _cajeroBloc.listar(direccionModel: _direccionBloc.direccionSeleccionada);
    // } else {
    _catalogoBloc.listarAgencias(_selectedIndex,
        direccionModel: _direccionBloc.direccionSeleccionada);
    _cajeroBloc.listarEnCamino();
    // }
    _direccionBloc.listar();
    _promocionBloc.listar();
    super.initState();

    _pushProvider.context = context;
    _pushProvider.chatsCompra.listen((ChatCompraModel chatCompraModel) {
      if (!mounted) return;
      _cajeroBloc.actualizarPorChat(chatCompraModel);
    });

    _pushProvider.objects.listen((despacho) {
      if (!mounted) return;
      DespachoModel _despacho = despacho;
      _cajeroBloc.actualizaridDespacho(
          _despacho.idCompra, _despacho.idDespacho, conf.COMPRA_DESPACHADA);
    });

    _pushProvider.chatsDespacho.listen((ChatDespachoModel chatDespacho) {
      if (!mounted) return;

      if (chatDespacho.idDespachoEstado == conf.DESPACHO_ENTREGADO) {
        _cajeroBloc.actualizarPorEntrega(
            chatDespacho.idDespacho, conf.COMPRA_ENTREGADA);
      }
    });

    _clienteProvider.actualizarToken().then((isActualizo) {
      permisos.verificarSession(context);
    });

    _promocionBloc.carrito();
    deeplink.initDynamicLinks(widget.isDeeplink, context, _start, _end);

    _cargarCategorias(_prefs.idUrbe);

    _pushProvider.cancelAll();
  }

  _start() {
    _saving = true;
    if (mounted) setState(() {});
  }

  _end() {
    _saving = false;
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        permisos.verificarSession(context);
        _refrezcar();
        _pushProvider.cancelAll();
        break;
      case AppLifecycleState.paused:
        break;
      default:
        break;
    }
  }

  _refrezcar() {
    _promocionBloc.listar(
        isClena: true,
        idUrbe: _direccionBloc.direccionSeleccionada.idUrbe,
        categoria: _categoriaModelSelect.idCategoria);
    switch (_selectedIndex) {
      case 0:
        _catalogoBloc
            .listarAgencias(_selectedIndex,
                direccionModel: _direccionBloc.direccionSeleccionada,
                categoria: _categoriaModelSelect.idCategoria)
            .then((value) {
          _tituloAgencias = 'Recomendados';
          _subTituloAgencias = 'Te van a encantar';
          if (mounted) if (mounted) setState(() {});
        });
        break;
      case 1:
        _cajeroBloc.listarEnCamino();
        break;
    }
  }

  irAlCarrito() {
    Navigator.pushNamed(context, 'carrito');
  }

  _onselecDireccion(DireccionModel direccion) {
    Navigator.pop(context);

    if (direccion.idDireccion <= 0) {
      return _requestGps();
    }
    String idUrbe = direccion.idUrbe.toString();

    _promocionBloc.listar(idUrbe: idUrbe);

    if (_prefs.idUrbe != idUrbe) {
      _categoriaModelSelect = CategoriaModel();
      _cargarCategorias(idUrbe);
    }

    _prefs.alias = direccion.alias.toString();
    _clienteProvider.urbe(idUrbe);

    _typeControllerDireccion.text = direccion.alias;
    _direccionBloc.direccionSeleccionada = direccion;
    consultarDirecciones();
    _prefs.idUrbe = idUrbe; //Guardamos la urbe en pereferencias
  }

  Widget createExpanPanel(BuildContext context) {
    return Form(
      key: _formKey,
      child: InkWell(
        onTap: _mostrarDirecciones,
        child: Container(
          padding:
              EdgeInsets.only(left: 10, top: 10, right: 10.0, bottom: 10.0),
          child: TextFormField(
            validator: (bal) {
              if (_direccionBloc.direccionSeleccionada.idDireccion <= 0)
                return 'Selecciona una dirección de entrega';
              return null;
            },
            enabled: false,
            controller: this._typeControllerDireccion,
            decoration: prs.decoration(
                'Selecciona una dirección de entrega', prs.iconoDespachor),
          ),
        ),
      ),
    );
  }

  _mostrarDirecciones() async {
    FocusScope.of(context).requestFocus(FocusNode());
    utils.mostrarProgress(context, barrierDismissible: false);
    await _direccionBloc.listar();
    Navigator.pop(context);
    showDialog(
        context: context,
        builder: (context) {
          return DireccionDialog(_direccionBloc.direcciones, _onselecDireccion);
        });
    _direccion = !_direccion;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: _prefs.clienteModel.perfil == '0' ? MenuWidget() : null,
      appBar: AppBar(
        leading: _prefs.clienteModel.perfil.toString() == '0'
            ? null
            : utils.leading(context),
        title: Container(
          child: TextButton(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  child: Text(
                    '¡ Cerca de ${_prefs.alias} !',
                    style:
                        TextStyle(color: prs.colorTextAppBar, fontSize: 16.0),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    softWrap: false,
                  ),
                  width: 150.0,
                ),
                _direccion
                    ? Icon(Icons.arrow_drop_up,
                        color: prs.colorTextAppBar, size: 32.0)
                    : Icon(Icons.arrow_drop_down,
                        color: prs.colorTextAppBar, size: 32.0)
              ],
            ),
            onPressed: _mostrarDirecciones,
          ),
        ),
        actions: <Widget>[
          (_prefs.isExplorar || _prefs.clienteModel.direcciones >= 1)
              ? IconButton(
                  padding: EdgeInsets.only(right: 30.0),
                  icon: StreamBuilder(
                    stream: _promocionBloc.carritoStream,
                    builder:
                        (BuildContext context, AsyncSnapshot<int> snapshot) {
                      if (snapshot.hasData)
                        return utils.iconoCount(snapshot.data);
                      return utils.iconoCount(0);
                    },
                  ),
                  onPressed: irAlCarrito,
                )
              : Container()
        ],
      ),
      body: ModalProgressHUD(
        color: Colors.black,
        opacity: 0.4,
        progressIndicator: _radar
            ? utils.progressRadar()
            : utils.progressIndicator('Consultando...'),
        inAsyncCall: _saving,
        child: Center(child: Container(child: _body(), width: prs.ancho)),
      ),
      bottomNavigationBar: _bottomNavigationBar(),
    );
  }

  _bottomNavigationBar() {
    return StreamBuilder(
      stream: _cajeroBloc.cajeroStream,
      builder:
          (BuildContext context, AsyncSnapshot<List<CajeroModel>> snapshot) {
        if (snapshot.hasData) {
          int compras = 0;
          snapshot.data.forEach((CajeroModel cajeroModel) => compras +=
              cajeroModel.idCompraEstado >= conf.COMPRA_REFERENCIADA &&
                      cajeroModel.idCompraEstado < conf.COMPRA_CANCELADA
                  ? 1
                  : 0);
          return _icono(compras);
        } else {
          return _icono(0);
        }
      },
    );
  }

  List<CategoriaModel> categoriasResponse;

  _cargarCategorias(idUrbe) async {
    categoriasResponse = null;
    if (mounted) setState(() {});
    categoriasResponse = await _categoriaProvider.listar(idUrbe);
    if (mounted) setState(() {});
  }

  Widget _categorias() {
    if (categoriasResponse == null || categoriasResponse.length <= 0)
      return Container();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _label('Categorías', 'Filtrar por categoría'),
        Container(
          padding: EdgeInsets.only(right: 0.0, left: 5.0),
          height: 80.0,
          child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categoriasResponse.length,
              itemBuilder: (context, i) =>
                  _card(context, categoriasResponse[i])),
        )
      ],
    );
  }

  Widget _card(BuildContext context, CategoriaModel categoriaModel) {
    final card = Container(
      width: 80.0,
      height: 80.0,
      child: Card(
        color:
            _categoriaModelSelect.idCategoria == categoriaModel.idCategoria &&
                    !_isBuscar
                ? prs.colorButtonSecondary
                : Colors.white,
        elevation: 1.0,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 2.0),
            Container(
              width: 50.0,
              height: 50.0,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(40)),
              ),
              child: Container(
                child:
                    cache.fadeImage(categoriaModel.img, width: 30, height: 30),
                padding: EdgeInsets.all(10.0),
              ),
            ),
            SizedBox(height: 2.0),
            Container(
              child: Text(categoriaModel.nombre,
                  overflow: TextOverflow.visible,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 12.0,
                    color: _categoriaModelSelect.idCategoria ==
                                categoriaModel.idCategoria &&
                            !_isBuscar
                        ? Colors.white
                        : Colors.black,
                  )),
              width: 40.0,
            ),
            SizedBox(height: 3.0),
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
                onTap: () {
                  _onSpeedDialAction(categoriaModel);
                }),
          ),
        ),
      ],
    );
  }

  _onSpeedDialAction(CategoriaModel categoriaModel,
      {String criterio: '', bool isBuscar: false}) async {
    if (isBuscar) {
      _tituloProductos = 'Productos relacionados';
      _subTituloProductos = '$criterio';

      _tituloAgencias = 'Coincidencias con';
      _subTituloAgencias = '$criterio';
    } else {
      _tituloAgencias = 'Recomendados';
      _subTituloAgencias = 'Te van a encantar';

      _tituloProductos = 'Destacados';
      _subTituloProductos = 'No te los puedes perder';
    }

    _isBuscar = isBuscar;

    if (categoriaModel.idCategoria == 6) return _onItemTapped(2);
    _categoriaModelSelect = categoriaModel;
    _update('Consultando...');

    _catalogoBloc.listarAgencias(_selectedIndex,
        direccionModel: _direccionBloc.direccionSeleccionada,
        categoria: categoriaModel.idCategoria,
        criterio: criterio,
        isBuscar: isBuscar);

    await _promocionBloc.listar(
        idUrbe: _direccionBloc.direccionSeleccionada.idUrbe,
        categoria: categoriaModel.idCategoria,
        criterio: criterio,
        isClena: true);
    try {
      if (_catalogoBloc.favoritos.isEmpty == false) {
        pageControllerProductosDestacados?.animateTo(0,
            duration: new Duration(milliseconds: 900), curve: Curves.ease);
      }
    } catch (err) {}
    try {
      if (_catalogoBloc.favoritos.isEmpty == false) {
        pageControllerProductosPromocion?.animateTo(0,
            duration: new Duration(milliseconds: 900), curve: Curves.ease);
      }
    } catch (err) {}

    try {
      if (_catalogoBloc.recomendados.isEmpty == false) {
        pageControllerRecomendado?.animateTo(0,
            duration: new Duration(milliseconds: 900), curve: Curves.ease);
      }
    } catch (err) {}
    _complet();
  }

  _icono(int element) {
    return BottomNavigationBar(
      items: _elements(element),
      showUnselectedLabels: true,
      unselectedItemColor: prs.colorButtonSecondary,
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.green,
      onTap: _onItemTapped,
    );
  }

  _elements(int element) {
    List<BottomNavigationBarItem> boton = [];
    boton.add(BottomNavigationBarItem(
        icon: Icon(FontAwesomeIcons.thLarge), label: 'Catálogo'));
    boton.add(BottomNavigationBarItem(
      icon: element <= 0
          ? Icon(FontAwesomeIcons.peopleCarry)
          : Badge(
              animationDuration: Duration(milliseconds: 300),
              position: BadgePosition.bottomStart(bottom: 10, start: 30),
              animationType: BadgeAnimationType.slide,
              badgeContent: Text(element.toString(),
                  style: TextStyle(color: Colors.white)),
              child: Icon(FontAwesomeIcons.peopleCarry),
            ),
      label: 'En proceso',
    ));
    return boton;
  }

  verChat(dynamic idAgencia) {
    _onItemTapped(2, idAgencia: idAgencia);
  }

  _onItemTapped(int index, {dynamic idAgencia: -1}) {
    switch (index) {
      case 0:
        _refrezcar();
        _catalogoBloc.listarAgencias(index,
            direccionModel: _direccionBloc.direccionSeleccionada,
            categoria: _categoriaModelSelect.idCategoria,
            isConsultar: _selectedIndex != index);
        break;
      case 1:
        _cajeroBloc.listarEnCamino();
        break;
    }
    _selectedIndex = index;
    if (mounted) setState(() {});
  }

  Widget _body() {
    if (_prefs.clienteModel.direcciones == 0) {
      return Container(
        padding: EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(
                image: AssetImage('assets/screen/direcciones.png'),
                fit: BoxFit.cover,
                width: 170.0),
            SizedBox(height: 20.0),
            Text(
              'Bienvenid@.',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
            ),
            SizedBox(height: 20.0),
            Text('Tu contraseña de acceso la enviamos a'),
            SizedBox(height: 8.0),
            Text('${_prefs.clienteModel.correo}',
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8.0),
            Text('si el correo es incorrecto corrigelo en tu'),
            SizedBox(height: 8.0),
            GestureDetector(
                child: Text('PERFIL',
                    style: TextStyle(
                        color: Colors.indigo,
                        decoration: TextDecoration.underline)),
                onTap: () {
                  Navigator.pushNamed(context, 'perfil');
                }),
            SizedBox(height: 15.0),
            btn.confirmar('REGISTRAR DIRECCIÓN', _requestGps),
            SizedBox(height: 5.0),
            Text(Sistema.MESAJE_CATALOGO, textAlign: TextAlign.justify),
            SizedBox(height: 90.0),
          ],
        ),
      );
    }

    return Column(
      children: <Widget>[
        EnLineaWidget(cambios: _cambios),
        Expanded(child: _tab()),
      ],
    );
  }

  Widget _buscador() {
    return Container(
      padding: EdgeInsets.only(left: 10.0, right: 10.0),
      child: TextFormField(
        controller: _textControllerBuscar,
        keyboardType: TextInputType.text,
        decoration: prs.decorationSearch(Sistema.SEARCH_MENSJAE),
        onFieldSubmitted: (value) async {
          FocusScope.of(context).requestFocus(FocusNode());
          _textControllerBuscar.text = '';
          if (value.length <= 2) {
            if (mounted) setState(() {});
            return;
          }
          CategoriaModel _categoria = CategoriaModel();
          _categoria.idCategoria = 0;
          _onSpeedDialAction(_categoria, criterio: value, isBuscar: true);
        },
      ),
    );
  }

  Widget _tab() {
    if (_selectedIndex == 0) return _tabCatalogo();
    if (_selectedIndex == 1) return _tabCamino();
    return null;
  }

  Widget _tabCamino() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(child: _listaCarCamino(context)),
        _productosPromocion(context)
      ],
    );
  }

  Widget _listaCarCamino(context) {
    return StreamBuilder(
      stream: _cajeroBloc.cajeroStream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.length > 0)
            return createListViewCamino(context, snapshot);
          return Container(
            padding: EdgeInsets.all(50.0),
            child: Center(
              child: Image(
                  image: AssetImage('assets/screen/compras.png'),
                  fit: BoxFit.cover),
            ),
          );
        }
        return ShimmerCard();
      },
    );
  }

  Widget createListViewCamino(
      BuildContext context, AsyncSnapshot<List<CajeroModel>> snapshot) {
    return RefreshIndicator(
      onRefresh: () => _cajeroBloc.listarEnCamino(),
      child: ListView.builder(
        padding: EdgeInsets.only(right: 5.0, left: 5.0),
        itemCount: snapshot.data.length,
        itemBuilder: (BuildContext context, int index) {
          return ChatCompraCard(
              cajeroModel: snapshot.data[index],
              onTab: _onTapCamino,
              isChatCajero: false);
        },
      ),
    );
  }

  _onTapCamino(CajeroModel cajeroModel) {
    FocusScope.of(context)?.requestFocus(FocusNode());
    if (cajeroModel.calificarCliente == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CalificacioncompraPage(
              cajeroModel: cajeroModel, tipo: conf.TIPO_CLIENTE),
        ),
      );
    } else if (cajeroModel.idDespacho <= 0) {
      DireccionModel direccionEntrega = DireccionModel();
      if (_direccionBloc.direccionSeleccionada.idDireccion > 0) {
        direccionEntrega = _direccionBloc.direccionSeleccionada;
      } else {
        direccionEntrega.referencia = cajeroModel.referencia;
        direccionEntrega.lt = cajeroModel.lt;
        direccionEntrega.lg = cajeroModel.lg;
        direccionEntrega.idDireccion = cajeroModel.idDireccion;
      }
      if (cajeroModel.idCompra != null && cajeroModel.idDireccion > 0) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ChatClientePage(cajeroModel: cajeroModel)));
      } else {
        if (!_formKey.currentState.validate()) {
          if (mounted) setState(() {});
          return;
        }
        if (cajeroModel.sucursal == '') return;
//        _confirmarIniciarCompra(context, cajeroModel, direccionEntrega);
        return;
      }
    } else {
      _verDespacho(cajeroModel);
    }
  }

  _verDespacho(CajeroModel cajeroModel) {
    String mensaje = 'Solicitud confirmada';
    compra.despachoPage(context, cajeroModel, mensaje, conf.TIPO_CLIENTE);
  }

  Widget _tabCatalogo() {
    return _listaCarCatalogo(context);
  }

  _requestGps() async {
    permisos.localizarTo(context, (lt, lg) {
      if (lt == 2.2)
        return; //Este estado significa q se mostro dialogo para localizar
      _irADireccion(lt, lg);
    }, isForce: false);
  }

  _update(mensaje) {
    _saving = true;
    if (mounted) setState(() {});
  }

  _complet() {
    _saving = false;
    if (mounted) if (mounted) setState(() {});
  }

  _irADireccion(lt, lg) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DireccionPage(
            lt: lt,
            lg: lg,
            direccionModel: DireccionModel(),
            cajeroModel: null,
            pagina: config.PAGINA_COMPRAS),
      ),
    );
  }

  consultarDirecciones() async {
    _update('Consultando costo');
    switch (_selectedIndex) {
      case 0:
        await _catalogoBloc.listarAgencias(_selectedIndex,
            direccionModel: _direccionBloc.direccionSeleccionada,
            isConsultar: true);
        break;
      case 1:
        break;
    }
    _direccion = false;
    _complet();
  }

  Widget _listaCarCatalogo(context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buscador()),
        SliverToBoxAdapter(
          child: StreamBuilder(
            stream: _catalogoBloc.recomendadoStream,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data.length <= 0) return Container();
                return createListViewOfertasEspeciales(context, snapshot);
              }
              return ShimmerCard();
            },
          ),
        ),
        SliverToBoxAdapter(child: _categorias()),
        SliverToBoxAdapter(child: _productosDestacados(context)),
        SliverToBoxAdapter(
            child: _label('Mejor valorados', 'Las personas los aman')),
        createListViewMejorValorados(1),
        SliverToBoxAdapter(child: _productosPromocion(context)),
        SliverToBoxAdapter(
          child: StreamBuilder(
            stream: _catalogoBloc.favoritoStream,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data.length <= 0) return Container();
                return createListViewTusFavoritos(context, snapshot);
              }
              return ShimmerCard();
            },
          ),
        ),
        SliverToBoxAdapter(
            child: _label('Populares', 'Lo que a las personas les encanta.')),
        createListViewMejorValorados(2),
        SliverToBoxAdapter(child: _label('Principales', Sistema.slogan)),
        createListViewMejorValorados(3),
      ],
    );
  }

  createListViewMejorValorados(int tipo) {
    return StreamBuilder(
      stream: _catalogoBloc.catalogoStream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.length <= 0)
            return SliverToBoxAdapter(child: ShimmerCard());
          int _tamanioLista = snapshot.data.length;
          var _elementos;
          if (tipo == 1) {
            if (_tamanioLista > 8) {
              _elementos = snapshot.data.sublist(0, 8);
            } else {
              _elementos = snapshot.data.sublist(0, _tamanioLista);
            }
          } else if (tipo == 2 && _tamanioLista > 8) {
            if (_tamanioLista > 18) {
              _elementos = snapshot.data.sublist(8, 18);
            } else {
              _elementos = snapshot.data.sublist(8, _tamanioLista);
            }
          } else if (_tamanioLista > 18) {
            _elementos = snapshot.data.sublist(18, _tamanioLista);
          }
          if (_elementos == null || _elementos.length <= 0)
            return SliverToBoxAdapter(child: Container());
          return SliverGrid(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: maxCrossAxisExtent),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return CatalogoCard(
                    catalogoModel: _elementos[index],
                    onTab: _onTapCatalogo,
                    isChatCajero: false);
              },
              childCount: _elementos.length,
            ),
          );
        }
        return SliverToBoxAdapter(child: ShimmerCard());
      },
    );
  }

  Widget createListViewTusFavoritos(
      BuildContext context, AsyncSnapshot<List<CatalogoModel>> snapshot) {
    if (snapshot.data.length <= 0 || snapshot.data[0].idAgencia == -100) {
      return Container();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _label('Tus favoritos', 'Tu ordenas'),
        ComprarCatalogoWidget(pageControllerFavoritos,
            snapshot: snapshot, onTapCatalogo: _onTapCatalogo),
      ],
    );
  }

  Widget createListViewOfertasEspeciales(
      BuildContext context, AsyncSnapshot<List<CatalogoModel>> snapshot) {
    if (snapshot.data.length <= 0 || snapshot.data[0].idAgencia == -100) {
      return Container();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // _crearHoraInicio(),
        _label(_tituloAgencias, _subTituloAgencias),
        ComprarCatalogoWidget(pageControllerRecomendado,
            snapshot: snapshot, onTapCatalogo: _onTapCatalogo),
      ],
    );
  }

  _onTapCatalogo(CatalogoModel catalogoModel) {
    FocusScope.of(context)?.requestFocus(FocusNode());
    //Si es de tipo
    if (catalogoModel.tipo == 1) {
      if (catalogoModel.abiero == '1') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MenuPage(catalogoModel, verChat: verChat),
          ),
        );
      } else {
        _enviarVER() async {
          Navigator.of(context).pop();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MenuPage(catalogoModel, verChat: verChat),
            ),
          );
        }

        dlg.mostrar(context, catalogoModel.abiero,
            icon: Icons.menu,
            color: prs.colorButtonSecondary,
            fBotonIDerecha: _enviarVER,
            titulo: 'Local cerrado',
            mBotonDerecha: 'VER PRODUCTOS',
            mIzquierda: 'REGRESAR');
      }
    } else if (catalogoModel.tipo == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SolicitudPage(
            _prefs.direccionModel.lt,
            _prefs.direccionModel.lg,
            catalogoModel: catalogoModel,
            pagina: config.PAGINA_SOLICITUD,
          ),
        ),
      );
    }
  }

  Widget _productosDestacados(BuildContext context) {
    return Container(
      width: double.infinity,
      child: StreamBuilder(
        initialData: _promocionBloc.promociones,
        stream: _promocionBloc.promocionStream,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) return ShimmerCard();
          if (snapshot.data.length <= 0) return Container();
          List<PromocionModel> _destacados = [];
          //Si esta en oferta se muestra en la lista de abajo
          snapshot.data.forEach((PromocionModel destacado) {
            if (destacado.promocion == 0) _destacados.add(destacado);
          });
          if (_destacados.length <= 0) return Container();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _label(_tituloProductos, _subTituloProductos),
              ComprarPromoWidget(pageControllerProductosDestacados,
                  promociones: _destacados)
            ],
          );
        },
      ),
    );
  }

  Widget _productosPromocion(BuildContext context) {
    return Container(
      width: double.infinity,
      child: StreamBuilder(
        initialData: _promocionBloc.promociones,
        stream: _promocionBloc.promocionStream,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData || snapshot.data.length <= 0)
            return Container();
          List<PromocionModel> _ofertas = [];
          //Si esta en oferta se muestra
          snapshot.data.forEach((PromocionModel oferta) {
            if (oferta.promocion == 1) _ofertas.add(oferta);
          });
          if (_ofertas.length <= 0) return Container();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _label(_tituloOfertas, _subTituloOfertas),
              ComprarPromoWidget(pageControllerProductosPromocion,
                  promociones: _ofertas)
            ],
          );
        },
      ),
    );
  }

  Widget _label(String titulo, String subTitulo) {
    return Container(
      padding: EdgeInsets.only(left: 10.0, bottom: 5.0, top: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text('$titulo', style: TextStyle(fontSize: 16.0)),
          SizedBox(width: 3.0),
          Text(subTitulo, style: TextStyle(color: Colors.blueGrey)),
        ],
      ),
    );
  }
}
