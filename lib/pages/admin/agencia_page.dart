import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import '../../bloc/agencia_bloc.dart';
import '../../card/agencia_card.dart';
import '../../card/shimmer_card.dart';
import '../../model/agencia_model.dart';
import '../../utils/personalizacion.dart' as prs;
import '../../utils/utils.dart' as utils;
import '../planck/ubicacion_page.dart';

//Agencias que se preregistraron para poder activar
class AngenciaPage extends StatefulWidget {
  AngenciaPage({Key key}) : super(key: key);

  @override
  _AngenciaPageState createState() => _AngenciaPageState();
}

class _AngenciaPageState extends State<AngenciaPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  bool _saving = false;
  String _title = 'Solicitudes';
  int _selectedIndex = 0;
  AgenciaBloc _agenciaBloc = AgenciaBloc();

  _AngenciaPageState();

  @override
  void initState() {
    super.initState();
    _agenciaBloc.listaPreregistros(_selectedIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        leading: utils.leading(context),
      ),
      key: scaffoldKey,
      body: ModalProgressHUD(
        color: Colors.black,
        opacity: 0.4,
        progressIndicator: utils.progressIndicator('Cargando...'),
        inAsyncCall: _saving,
        child: Column(
          children: <Widget>[
            SizedBox(height: 10.0),
            Expanded(child: _listaCar(context)),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.hubspot), label: 'Solicitudes'),
          BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.puzzlePiece), label: 'Pendientes'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: prs.colorButtonSecondary,
        onTap: _onItemTapped,
      ),
    );
  }

  _onItemTapped(int index) async {
    _selectedIndex = index;
    _saving = true;
    if (mounted) setState(() {});
    switch (index) {
      case 0:
        _title = 'Solicitudes';
        break;
      case 1:
        _title = 'Pendientes';
        break;
    }
    await _agenciaBloc.listaPreregistros(_selectedIndex);
    _saving = false;
    if (mounted) setState(() {});
  }

  Widget _listaCar(context) {
    return Container(
      child: StreamBuilder(
        stream: _agenciaBloc.agenciaStream,
        builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.length > 0)
              return createListView(context, snapshot);
            return _img();
          } else {
            return ShimmerCard();
          }
        },
      ),
    );
  }

  Widget _img() {
    return Container(
      margin: EdgeInsets.all(80.0),
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Image(
          image: AssetImage('assets/screen/direcciones.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget createListView(BuildContext context, AsyncSnapshot snapshot) {
    return ListView.builder(
        padding: EdgeInsets.only(right: 5.0, left: 5.0),
        itemCount: snapshot.data.length,
        itemBuilder: (BuildContext context, int index) {
          return _card(context, snapshot.data[index]);
        });
  }

  _onTap(AgenciaModel agenciaModel) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UbicacionPage(agenciaModel: agenciaModel),
      ),
    );
  }

  Widget _card(BuildContext context, AgenciaModel agenciaModel) {
    return AgenciaCard(
        agenciaModel: agenciaModel,
        key: ValueKey(agenciaModel.idAgencia),
        onTab: _onTap);
  }
}
