import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import '../../bloc/agencia_bloc.dart';
import '../../bloc/catalogo_bloc.dart';
import '../../bloc/reporte_bloc.dart';
import '../../bloc/sucursal_bloc.dart';
import '../../card/shimmer_card.dart';
import '../../card/sucursal_card.dart';
import '../../dialog/agencia_dialog.dart';
import '../../dialog/foto_promocion_dialog.dart';
import '../../model/agencia_model.dart';
import '../../model/promocion_model.dart';
import '../../model/sucursal_model.dart';
import '../../providers/promocion_provider.dart';
import '../../utils/dialog.dart' as dlg;
import '../../utils/personalizacion.dart' as prs;
import '../../utils/utils.dart' as utils;
import '../../widgets/promociones_agencia_widget.dart';
import '../../widgets/ventas_widget.dart';
import 'horarios_page.dart';

class SucursalesPage extends StatefulWidget {
  SucursalesPage({Key key}) : super(key: key);

  @override
  _SucursalesPageState createState() => _SucursalesPageState();
}

class _SucursalesPageState extends State<SucursalesPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final SucursalBloc _sucursalBloc = SucursalBloc();
  final TextEditingController _typeControllerAgerncia = TextEditingController();
  final AgenciaBloc _agenciaBloc = AgenciaBloc();
  final PromocionProvider _promocionProvider = PromocionProvider();
  final TextEditingController _textEditingController = TextEditingController();
  final TextEditingController _textControllerBuscar = TextEditingController();
  bool _saving = false;

  _SucursalesPageState();

  @override
  void initState() {
    _catalogoBloc.pagina = 0;
    _textEditingController.text = '${_catalogoBloc.pagina}';
    _agenciaBloc.listar();
    _typeControllerAgerncia.text = _agenciaBloc.agenciaSeleccionada.agencia;
    _sucursalBloc.listar(_agenciaBloc.agenciaSeleccionada.idAgencia);
    super.initState();
  }

  _subirFoto(PromocionModel promocionModel) {
    if (_agenciaBloc.agenciaSeleccionada.idAgencia <= 1)
      return dlg.mostrar(context,
          'Para crear un producto es necesario seleccionar una agencia.');
    promocionModel.idAgencia = _agenciaBloc.agenciaSeleccionada.idAgencia;
    promocionModel.idUrbe = _agenciaBloc.agenciaSeleccionada.idUrbe;
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return FotoPromocionDialog(_agenciaBloc.agenciaSeleccionada.agencia,
              promocion: promocionModel);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        leading: utils.leading(context),
        actions: [
          IconButton(
            padding: EdgeInsets.only(right: 10.0),
            onPressed: () {
              _subirFoto(PromocionModel(idPromocion: -100));
            },
            icon: Icon(Icons.add_a_photo_outlined, size: 30.0),
          ),
          IconButton(
            icon: Icon(FontAwesomeIcons.broom, color: Colors.white),
            onPressed: () {
              _agenciaBloc.agenciaSeleccionada = AgenciaModel();
              _typeControllerAgerncia.text = '';
              consultarSucursales();
              if (mounted) setState(() {});
            },
          )
        ],
      ),
      key: scaffoldKey,
      body: ModalProgressHUD(
        color: Colors.black,
        opacity: 0.4,
        progressIndicator: utils.progressIndicator('Cargando...'),
        inAsyncCall: _saving,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              SizedBox(height: 10.0),
              _agencias(),
              _contenido(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.hospital), label: 'Sucursales'),
          BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.productHunt), label: 'Productos'),
          BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.moneyCheckAlt), label: 'Ventas'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: prs.colorButtonSecondary,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
      ),
    );
  }

  _contenido() {
    if (_selectedIndex == 2)
      return VentasWidget();
    else if (_selectedIndex == 0)
      return _listaCar(context);
    else
      return _productos(context);
  }

  String _title = 'Sucursales';
  int _selectedIndex = 0;
  final CatalogoBloc _catalogoBloc = CatalogoBloc();

  final ReporteBloc _reporteBloc = ReporteBloc();

  consultarSucursales() async {
    _saving = true;
    if (mounted) setState(() {});
    switch (_selectedIndex) {
      case 0:
        _title = 'Sucursales';
        await _sucursalBloc.listar(_agenciaBloc.agenciaSeleccionada.idAgencia);
        break;
      case 1:
        _title = 'Productos';
        await _catalogoBloc
            .listarPromociones(_agenciaBloc.agenciaSeleccionada.idAgencia);
        break;
      case 2:
        _title = 'Ventas';
        await _reporteBloc
            .listarCompras(_agenciaBloc.agenciaSeleccionada.idAgencia);
        break;
    }
    _saving = false;
    if (mounted) if (mounted) setState(() {});
  }

  _onItemTapped(int index) async {
    _selectedIndex = index;
    if (mounted) setState(() {});
    switch (index) {
      case 0:
        _title = 'Sucursales';
        await _sucursalBloc.listar(_agenciaBloc.agenciaSeleccionada.idAgencia);
        break;
      case 1:
        _title = 'Productos';
        await _catalogoBloc
            .listarPromociones(_agenciaBloc.agenciaSeleccionada.idAgencia);
        break;
      case 2:
        _title = 'Ventas';
        await _reporteBloc
            .listarCompras(_agenciaBloc.agenciaSeleccionada.idAgencia);
        break;
    }
    _saving = false;
    if (mounted) if (mounted) setState(() {});
  }

  Widget _agencias() {
    return Container(
      padding: EdgeInsets.all(10.0),
      child: createExpanPanel(context),
    );
  }

  editarPromocion(PromocionModel promocion) async {
    _confirmarEditarPromocion() async {
      Navigator.pop(context);
      _saving = true;
      if (mounted) setState(() {});
      await _promocionProvider.editar(promocion);
      _saving = false;
      if (mounted) setState(() {});
    }

    if (promocion.incentivo.toString() == promocion.incentivoPrevio) {
      dlg.mostrar(context, '¿Seguro deseas actualizar el producto?',
          fBotonIDerecha: _confirmarEditarPromocion,
          color: prs.colorButtonSecondary,
          icon: Icons.check,
          mBotonDerecha: 'SI, ACEPTAR',
          mIzquierda: 'CANCELAR');
    } else {
      dlg.mostrar(context,
          'Si cambias el incentivo a\n\n(${promocion.incentivo})\n\nel producto pasará a revisión y dejará de ser visible hasta ser aprobado.',
          fBotonIDerecha: _confirmarEditarPromocion,
          icon: Icons.check,
          mBotonDerecha: 'SI, ACEPTAR',
          mIzquierda: 'CANCELAR');
    }
  }

  Future<List<AgenciaModel>> consultar(pattern) async {
    await _agenciaBloc.filtrar(pattern);
    return _agenciaBloc.agenciaes;
  }

  _mostrarAgencias() async {
    FocusScope.of(context).requestFocus(FocusNode());
    showDialog(
        context: context,
        builder: (context) {
          return AgenciaDialog(_onselecAgencia);
        });
  }

  _onselecAgencia(AgenciaModel agencia) {
    Navigator.pop(context);
    _catalogoBloc.pagina = 0;
    _textEditingController.text = '0';
    _typeControllerAgerncia.text = agencia.agencia;
    _agenciaBloc.agenciaSeleccionada = agencia;
    consultarSucursales();
  }

  Widget createExpanPanel(BuildContext context) {
    return InkWell(
      onTap: _mostrarAgencias,
      child: TextFormField(
        enabled: false,
        controller: _typeControllerAgerncia,
        decoration: prs.decoration('Selecciona una agencia', prs.iconoSucursal),
      ),
    );
  }

  Widget _listaCar(context) {
    return StreamBuilder(
      stream: _sucursalBloc.sucursalStream,
      builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.length > 0)
            return createListView(context, snapshot);
          return _img();
        } else {
          if (_agenciaBloc.agenciaSeleccionada.idAgencia <= 0) return _img();
          return ShimmerCard();
        }
      },
    );
  }

  Widget _img() {
    return Container(
      margin: EdgeInsets.all(80.0),
      child: Center(
        child: Image(
          image: AssetImage('assets/screen/direcciones.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buscador() {
    return Container(
      padding: EdgeInsets.only(left: 10.0, right: 10.0),
      child: TextFormField(
        controller: _textControllerBuscar,
        keyboardType: TextInputType.text,
        decoration: prs.decorationSearch('Busca un producto'),
        onFieldSubmitted: (value) async {
          FocusScope.of(context).requestFocus(FocusNode());
          _catalogoBloc.pagina = 0;
          _textEditingController.text = '0';
          filtar();
        },
      ),
    );
  }

  Widget _productos(BuildContext context) {
    return Column(
      children: [
        _buscador(),
        StreamBuilder(
          stream: _catalogoBloc.promocionStream,
          builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data.length <= 0) return _img();
              return PromocionesAgenciaWidget(
                  promociones: snapshot.data,
                  editarPromocion: editarPromocion,
                  scaffoldKey: scaffoldKey);
            } else {
              if (_agenciaBloc.agenciaSeleccionada.idAgencia <= 0)
                return _img();
              return ShimmerCard();
            }
          },
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _catalogoBloc.pagina <= 0
                ? Container()
                : IconButton(
                    icon: Icon(Icons.arrow_back_ios,
                        size: 35.0, color: prs.colorButtonSecondary),
                    onPressed: () async {
                      if (_catalogoBloc.pagina < 0) return;
                      _catalogoBloc.pagina -= 1;
                      _textEditingController.text = '${_catalogoBloc.pagina}';
                      filtar();
                    }),
            Container(
              width: 60.0,
              child: TextFormField(
                readOnly: true,
                controller: _textEditingController,
                keyboardType: TextInputType.numberWithOptions(decimal: false),
                onChanged: (value) {},
                decoration: prs.decoration('Página', null),
              ),
            ),
            _catalogoBloc.promociones.length <= 0 && _catalogoBloc.pagina > 0
                ? Container()
                : IconButton(
                    icon: Icon(Icons.arrow_forward_ios,
                        size: 35.0, color: prs.colorButtonSecondary),
                    onPressed: () async {
                      _catalogoBloc.pagina += 1;
                      _textEditingController.text = '${_catalogoBloc.pagina}';
                      filtar();
                    })
          ],
        ),
        SizedBox(height: 50.0),
      ],
    );
  }

  filtar() async {
    _saving = true;
    if (mounted) setState(() {});
    await _catalogoBloc.listarPromociones(
        _agenciaBloc.agenciaSeleccionada.idAgencia,
        alias: _textControllerBuscar.text,
        isClean: true);
    _saving = false;
    if (mounted) setState(() {});
  }

  Widget createListView(BuildContext context, AsyncSnapshot snapshot) {
    return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.only(right: 5.0, left: 5.0),
        itemCount: snapshot.data.length,
        itemBuilder: (BuildContext context, int index) {
          return SucursalCard(
              sucursalModel: snapshot.data[index],
              key: ValueKey(snapshot.data[index].idSucursal),
              onTab: _onTap);
        });
  }

  _onTap(SucursalModel sucursalModel) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HorariosPage(
          agenciaModel: _agenciaBloc.agenciaSeleccionada,
          sucursalModel: sucursalModel,
        ),
      ),
    );
  }
}
