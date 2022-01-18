import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

import '../../bloc/compras_cliente_bloc.dart';
import '../../card/chat_compra_card.dart';
import '../../card/shimmer_card.dart';
import '../../model/cajero_model.dart';
import '../../model/chat_compra_model.dart';
import '../../preference/push_provider.dart';
import '../../utils/permisos.dart' as permisos;
import '../../utils/personalizacion.dart' as prs;
import '../../utils/utils.dart' as utils;
import '../../widgets/en_linea_widget.dart';
import 'chat_cliente_page.dart';

class ComprasClientePage extends StatefulWidget {
  @override
  _ComprasClientePageState createState() => _ComprasClientePageState();
}

class _ComprasClientePageState extends State<ComprasClientePage>
    with WidgetsBindingObserver {
  final ComprasClienteBloc _comprasClienteBloc = ComprasClienteBloc();
  final PushProvider _pushProvider = PushProvider();

  List<CajeroModel> _listaCajeroModel;

  bool _saving = false;
  StreamController<bool> _cambios;

  PageController pageController =
      PageController(initialPage: DateTime.now().year);

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    _comprasClienteBloc.listar(initialDate.year, initialDate.month);
    super.initState();

    _cambios = StreamController<bool>.broadcast();
    _cambios.stream.listen((internet) {
      if (internet) {
        _comprasClienteBloc.listar(initialDate.year, initialDate.month);
      }
    });

    _pushProvider.context = context;
    _pushProvider.chatsCompra.listen((ChatCompraModel chatCompraModel) {
      if (!mounted) return;
      _comprasClienteBloc.actualizarPorChat(chatCompraModel);
    });

    permisos.getCheckNotificationPermStatus(context);
  }

  void disposeStreams() {
    _cambios?.close();
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
        _comprasClienteBloc.listar(initialDate.year, initialDate.month);
        permisos.getCheckNotificationPermStatus(context);
        break;
      case AppLifecycleState.paused:
        break;
      default:
        break;
    }
  }

  DateTime initialDate = DateTime.now();

  final f = new DateFormat('MMM yyyy', 'es');

  _mostrarCalendario() {
    showMonthPicker(
      context: context,
      firstDate: DateTime(DateTime.now().year - 10, 5),
      lastDate: DateTime(DateTime.now().year, 12),
      initialDate: initialDate,
      locale: Locale("es"),
    ).then((date) {
      if (date != null) {
        setState(() {
          initialDate = date;
        });
        comprasClienteMes(initialDate.year, initialDate.month);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mi historial', overflow: TextOverflow.visible),
        leading: utils.leading(context),
        actions: <Widget>[
          GestureDetector(
            onTap: _mostrarCalendario,
            child: Container(
              padding: EdgeInsets.only(top: 20.0),
              child: Text('${f.format(initialDate)}',
                  style: TextStyle(color: Colors.white)),
            ),
          ),
          IconButton(
            icon: Icon(Icons.calendar_today,
                size: 22.0, color: prs.colorIconsAppBar),
            onPressed: _mostrarCalendario,
          ),
        ],
      ),
      body: ModalProgressHUD(
        inAsyncCall: _saving,
        child: Center(
            child: Container(child: _body(), width: prs.anchoFormulario)),
      ),
    );
  }

  Widget _body() {
    return Column(
      children: <Widget>[
        EnLineaWidget(cambios: _cambios),
        Expanded(child: _listaCar(context)),
      ],
    );
  }

  comprasClienteMes(dynamic anio, dynamic mes) async {
    _saving = true;
    if (mounted) setState(() {});
    await _comprasClienteBloc.listar(anio, mes);
    _saving = false;
    if (mounted) setState(() {});
  }

  Widget _listaCar(context) {
    return Container(
      margin: EdgeInsets.all(5.0),
      child: StreamBuilder(
        stream: _comprasClienteBloc.comprasStream,
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
      ),
    );
  }

  Widget createListView(
      BuildContext context, AsyncSnapshot<List<CajeroModel>> snapshot) {
    _listaCajeroModel = snapshot.data;
    return ListView.builder(
      itemCount: _listaCajeroModel.length,
      itemBuilder: (BuildContext context, int index) {
        return ChatCompraCard(
            cajeroModel: snapshot.data[index],
            onTab: _onTab,
            isChatCajero: false);
      },
    );
  }

  _onTab(CajeroModel cajeroModel) {
    cajeroModel.sinLeerCliente = 0;
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatClientePage(cajeroModel: cajeroModel),
      ),
    );
  }
}
