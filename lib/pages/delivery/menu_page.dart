import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:like_button/like_button.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:share/share.dart';

import '../../bloc/catalogo_bloc.dart';
import '../../bloc/promocion_bloc.dart';
import '../../card/shimmer_card.dart';
import '../../model/catalogo_model.dart';
import '../../model/promocion_model.dart';
import '../../providers/catalogo_provider.dart';
import '../../utils/dialog.dart' as dlg;
import '../../utils/personalizacion.dart' as prs;
import '../../utils/utils.dart' as utils;
import '../../widgets/comprar_promo_widget.dart';
import '../../widgets/promociones_promo_widget.dart';

class MenuPage extends StatefulWidget {
  final CatalogoModel catalogoModel;
  final Function verChat;

  MenuPage(
    this.catalogoModel, {
    Key key,
    this.verChat,
  }) : super(key: key);

  @override
  _MenuPageState createState() => _MenuPageState(catalogoModel: catalogoModel);
}

class _MenuPageState extends State<MenuPage>
    with SingleTickerProviderStateMixin {
  final CatalogoBloc _catalogoBloc = CatalogoBloc();
  final CatalogoProvider _catalogoProvider = CatalogoProvider();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final PromocionBloc _promocionBloc = PromocionBloc();
  final CatalogoModel catalogoModel;

  ScrollController pageControllerProductosDestacados = ScrollController();

  _MenuPageState({this.catalogoModel});

  bool _buscando = false;
  TextEditingController _textControllerCredito;

  ScrollController pageControllerProductos = ScrollController();

  @override
  void initState() {
    _catalogoBloc.pagina = 0;
    pageControllerProductos.addListener(() async {
      if (_catalogoBloc.consultando != 0) return;
      if (pageControllerProductos.position.pixels >=
          pageControllerProductos.position.maxScrollExtent - 50) {
        _catalogoBloc.pagina++;
        _catalogoBloc.listarPromociones(catalogoModel.idAgencia.toString(),
            isClean: false);
      }
    });

    _textControllerCredito = TextEditingController(text: '');

    super.initState();
    if (catalogoModel.idPromocion.toString() != '0')
      _catalogoBloc.listarPromociones(catalogoModel.idAgencia.toString(),
          idPromocion: catalogoModel.idPromocion.toString(), isClean: true);
    else
      _catalogoBloc.listarPromociones(catalogoModel.idAgencia.toString());
    _promocionBloc.carrito();
  }

  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        // leading: utils.leading(context),
        centerTitle: true,
        elevation: 0.0,
        title: Text(
          '${catalogoModel.agencia}',
          overflow: TextOverflow.clip,
        ),
        actions: <Widget>[
          IconButton(
            padding: EdgeInsets.only(right: 30.0),
            icon: StreamBuilder(
              stream: _promocionBloc.carritoStream,
              builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                if (snapshot.hasData) return utils.iconoCount(snapshot.data);
                return utils.iconoCount(0);
              },
            ),
            onPressed: irAlCarrito,
          ),
        ],
      ),
      body: ModalProgressHUD(
        color: Colors.black,
        opacity: 0.4,
        progressIndicator: utils.progressIndicator('Consultando...'),
        inAsyncCall: _saving,
        child: Center(
            child: Container(child: _promociones(context), width: prs.ancho)),
      ),
      floatingActionButton: Stack(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 70.0),
            child: Align(
              alignment: Alignment.bottomRight,
              child: FloatingActionButton(
                heroTag: null,
                backgroundColor: Colors.white,
                elevation: 1.0,
                onPressed: compartirAgencia,
                child: Icon(Icons.share, color: prs.colorButtonSecondary),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
              heroTag: null,
              backgroundColor: Colors.white,
              elevation: 1.0,
              onPressed: null,
              child: LikeButton(
                padding: EdgeInsets.only(bottom: 0.0, left: 2.0),
                isLiked: catalogoModel.like == 1,
                bubblesSize: 350.0,
                circleColor: CircleColor(
                    start: Color(0xff00ddff), end: Color(0xff0099cc)),
                bubblesColor: BubblesColor(
                  dotPrimaryColor: Color(0xff33b5e5),
                  dotSecondaryColor: Color(0xff0099cc),
                ),
                likeBuilder: (bool isLiked) {
                  catalogoModel.like = isLiked ? 1 : 0;
                  _catalogoProvider.like(catalogoModel);
                  _catalogoBloc.refrezcarFavoritos();
                  return Icon(
                    isLiked
                        ? FontAwesomeIcons.solidHeart
                        : FontAwesomeIcons.heart,
                    size: 24.0,
                    color: isLiked ? prs.colorIcons : prs.colorButtonSecondary,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  _update() {
    _saving = true;
    if (mounted) if (mounted) setState(() {});
  }

  _complet() {
    _saving = false;
    if (mounted) if (mounted) setState(() {});
  }

  compartirAgencia() async {
    String link =
        await utils.obtenerLinkAgencia(catalogoModel, _update, _complet);
    if (link == null)
      return dlg.mostrar(context,
          'Ups. Lo sentimos ocurrió un problema, intenta de nuevo más tarde.');
    Share.share('$link ');
  }

  compartirPromocion(PromocionModel promocion) async {
    String link = await utils.obtenerLinkAgencia(
        catalogoModel, _update, _complet,
        promocion: promocion);
    if (link == null)
      return dlg.mostrar(context,
          'Ups. Lo sentimos ocurrió un problema, intenta de nuevo más tarde.');
    Share.share('$link ');
  }

  var press = DateTime.now();

  buscar(String value) async {
    if (value.length < 3) return;
    press = DateTime.now();
    Future.delayed(const Duration(milliseconds: 1900), () async {
      final ahora = DateTime.now();
      final difference = ahora.difference(press).inMilliseconds;
      if (difference > 1900) filtrar();
    });
  }

  filtrar() async {
    press = DateTime.now();
    FocusScope.of(context).requestFocus(FocusNode());
    _buscando = true;
    if (mounted) setState(() {});
    await _catalogoBloc.listarPromociones(catalogoModel.idAgencia.toString(),
        alias: _textControllerCredito.text, isClean: true);
    _buscando = false;
    if (mounted) setState(() {});
  }

  Widget _crearBuscador() {
    return Visibility(
      visible: true,
      child: Container(
        padding: EdgeInsets.only(left: 17.0, right: 15.0),
        child: TextField(
            onEditingComplete: filtrar,
            onChanged: (value) {
              buscar(value);
            },
            controller: _textControllerCredito,
            decoration: prs.decorationSearch(
              'Busca en ${catalogoModel.agencia}',
            )),
      ),
    );
  }

  irAlCarrito() {
    Navigator.pushNamed(context, 'carrito');
  }

  List<PromocionModel> _listPromociones = [];
  List<PromocionModel> _listProductos = [];

  Widget _promociones(BuildContext context) {
    return StreamBuilder(
      stream: _catalogoBloc.promocionStream,
      builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
        if (snapshot.hasData) {
          if (_buscando) return Column(children: [ShimmerCard()]);

          _listPromociones.clear();
          _listProductos.clear();

          snapshot.data.forEach((promo) {
            if (promo.promocion <= 0) {
              _listProductos.add(promo);
            } else {
              _listPromociones.add(promo);
            }
          });

          return CustomScrollView(
            controller: pageControllerProductos,
            slivers: <Widget>[
              SliverToBoxAdapter(child: _crearBuscador()),
              SliverToBoxAdapter(
                child: _listPromociones.length > 0
                    ? _label('Promociones')
                    : Container(),
              ),
              SliverToBoxAdapter(
                  child: _listPromociones.length > 0
                      ? ComprarPromoWidget(
                          pageControllerProductosDestacados,
                          promociones: _listPromociones,
                          isOppen: catalogoModel.abiero.toString() == '1',
                          agencia: catalogoModel.abiero.toString(),
                        )
                      : Container()),
              SliverToBoxAdapter(child: _label('Catálogo')),
              SliverGrid(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 500.0,
                    childAspectRatio: 2.4,
                    mainAxisSpacing: 0.0),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return PromocionesPromoWidget(
                        compartirPromocion, catalogoModel, widget.verChat,
                        promocion: _listProductos[index]);
                  },
                  childCount: _listProductos.length,
                ),
              ),
              SliverToBoxAdapter(
                  child: StreamBuilder(
                stream: _catalogoBloc.isConsultandoStream,
                builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                  if (snapshot.hasData && snapshot.data == 1)
                    return ShimmerCard();
                  return SizedBox(height: 80.0);
                },
              )),
              SliverPadding(
                padding: const EdgeInsets.only(bottom: 80.0),
              )
            ],
          );
        } else {
          return Column(
            children: [ShimmerCard(), ShimmerCard()],
          );
        }
      },
    );
  }

  Widget _label(String titulo) {
    return Container(
      padding: EdgeInsets.only(left: 10.0, bottom: 5.0, top: 10.0),
      child: Text('$titulo', style: TextStyle(fontSize: 16.0)),
    );
  }
}
