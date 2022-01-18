import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../bloc/compras_cajero_bloc.dart';
import '../../card/chat_compra_card.dart';
import '../../card/shimmer_card.dart';
import '../../model/cajero_model.dart';
import '../../model/chat_compra_model.dart';
import '../../preference/push_provider.dart';
import '../../preference/shared_preferences.dart';
import '../../providers/cliente_provider.dart';
import '../../utils/conexion.dart';
import '../../utils/permisos.dart' as permisos;
import '../../utils/personalizacion.dart' as prs;
import '../../utils/rastreo.dart';
import '../../widgets/en_linea_widget.dart';
import '../../widgets/menu_widget.dart';
import '../delivery/chat_cajero_page.dart';

//INIT CAJERO ADMIN
class ComprasCajeroPage extends StatefulWidget {
  @override
  _ComprasCajeroPageState createState() => _ComprasCajeroPageState();
}

class _ComprasCajeroPageState extends State<ComprasCajeroPage>
    with WidgetsBindingObserver {
  final ClienteProvider _clienteProvider = ClienteProvider();
  final ComprasCajeroBloc _comprasCajeroBloc = ComprasCajeroBloc();
  final PreferenciasUsuario _prefs = PreferenciasUsuario();
  final PushProvider _pushProvider = PushProvider();

  bool _saving = false;
  StreamController<bool> _cambios = StreamController<bool>.broadcast();

  void disposeStreams() {
    _cambios?.close();
    super.dispose();
  }

  @override
  void initState() {
    bool _init = false;
    _cambios.stream.listen((internet) {
      if (!mounted) return;
      if (internet && _init) {
        _comprasCajeroBloc.listarCompras(_selectedIndex, _dateTime.toString());
      }
      _init = true;
    });

    Conexion();
    WidgetsBinding.instance.addObserver(this);
    _comprasCajeroBloc.listarCompras(_selectedIndex, _dateTime.toString());
    super.initState();

    _pushProvider.context = context;
    _pushProvider.chatsCompra.listen((ChatCompraModel chatCompraModel) {
      if (!mounted) return;
      _comprasCajeroBloc.actualizarCompras(
          chatCompraModel, _selectedIndex, _dateTime.toString());
    });

    _clienteProvider.actualizarToken().then((isActualizo) {
      permisos.verificarSession(context);
    });

    _revisarOptimizacion();
    _pushProvider.cancelAll();
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
        _comprasCajeroBloc.listarCompras(_selectedIndex, _dateTime.toString());
        _revisarOptimizacion();
        _pushProvider.cancelAll();
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        break;
      default:
        break;
    }
  }

  _revisarOptimizacion() async {
    await Rastreo().optimizadoCheck();
    print(_prefs.optimizado);
    if (mounted) setState(() {});
  }

  String title = 'Despachando';

  @override
  Widget build(BuildContext context) {
    if (_prefs.clienteModel.perfil == '0')
      return Container(child: Center(child: Text('Cliente no autorizado')));

    return Scaffold(
      drawer: MenuWidget(),
      appBar: AppBar(
        title: Text(title),
        actions: <Widget>[_optimizado()],
      ),
      body: ModalProgressHUD(
        inAsyncCall: _saving,
        child: Center(
            child: Container(child: _contenido(), width: prs.anchoFormulario)),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.business), label: 'Despachando'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Historial'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: prs.colorButtonSecondary,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _contenido() {
    return Column(
      children: <Widget>[
        EnLineaWidget(cambios: _cambios),
        _crearFecha(context),
        Expanded(child: _listaCar(context))
      ],
    );
  }

  Widget _optimizado() {
    return _prefs.optimizado
        ? Container(
            color: Colors.green,
            child: IconButton(
              icon:
                  Icon(FontAwesomeIcons.check, size: 26.0, color: Colors.white),
              onPressed: null,
            ),
          )
        : Container(
            color: Colors.red,
            child: IconButton(
              icon: Icon(FontAwesomeIcons.bed, size: 26.0, color: Colors.white),
              onPressed: () async {
                await Rastreo().optimizadoCheck();
                if (mounted) setState(() {});
              },
            ),
          );
  }

  int _selectedIndex = 0;
  DateTime _dateTime = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  void _onItemTapped(int index) {
    _dateTime = DateTime.now();
    _selectedIndex = index;
    if (index == 0)
      title = 'Despachando';
    else
      title = 'Historial';
    _onRefresh();
  }

  Widget _crearFecha(BuildContext context) {
    return Visibility(
        visible: _selectedIndex == 1,
        child: TableCalendar(
          calendarFormat: CalendarFormat.week,
          firstDay: DateTime.utc(2019, 1, 1),
          lastDay: DateTime.utc(2069, 1, 1),
          focusedDay: _focusedDay,
          locale: 'es',
          onDaySelected: (selectedDay, focusedDay) {
            _dateTime = selectedDay;
            _focusedDay = focusedDay;
            _onRefresh();
          },
        ));
  }

  Widget _listaCar(context) {
    return Container(
        margin: EdgeInsets.all(5.0),
        child: StreamBuilder(
          stream: _comprasCajeroBloc.comprasStream,
          builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data.length > 0)
                return createListView(context, snapshot);
              return Container(
                margin: EdgeInsets.all(60.0),
                width: double.infinity,
                height: double.infinity,
                child: Center(
                  child: Image(
                      image: AssetImage('assets/icon_.png'),
                      width: 290.0,
                      fit: BoxFit.cover),
                ),
              );
            } else {
              return ShimmerCard();
            }
          },
        ));
  }

  Future _onRefresh() async {
    _saving = true;
    if (mounted) setState(() {});
    await _comprasCajeroBloc.listarCompras(
        _selectedIndex, _dateTime.toString());
    _saving = false;
    if (mounted) setState(() {});
    return;
  }

  Widget createListView(BuildContext context, AsyncSnapshot snapshot) {
    return RefreshIndicator(
      onRefresh: () => _comprasCajeroBloc.listarCompras(
          _selectedIndex, _dateTime.toString()),
      child: ListView.builder(
        itemCount: snapshot.data.length,
        itemBuilder: (BuildContext context, int index) {
          return ChatCompraCard(
              cajeroModel: snapshot.data[index],
              onTab: _onTab,
              isChatCajero: true);
        },
      ),
    );
  }

  _onTab(CajeroModel cajeroModel) {
    cajeroModel.sinLeerCajero = 0;
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ChatCajeroPage(cajeroModel: cajeroModel)));
  }
}
