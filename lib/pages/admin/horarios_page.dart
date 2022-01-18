import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../model/agencia_model.dart';
import '../../model/sucursal_model.dart';
import '../../utils/personalizacion.dart' as prs;
import '../../view/horarios_view.dart';
import '../../view/sucursalcajero_view.dart';

class HorariosPage extends StatefulWidget {
  final AgenciaModel agenciaModel;
  final SucursalModel sucursalModel;

  HorariosPage({Key key, this.agenciaModel, this.sucursalModel})
      : super(key: key);

  @override
  _HorariosPageState createState() => _HorariosPageState(
      agenciaModel: agenciaModel, sucursalModel: sucursalModel);
}

class _HorariosPageState extends State<HorariosPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  int _selectedIndex = 0;
  final isHistorial = false;
  final AgenciaModel agenciaModel;
  final SucursalModel sucursalModel;

  _HorariosPageState({this.agenciaModel, this.sucursalModel});

  @override
  void initState() {
    super.initState();
    _selectedIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _contenido(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.peopleCarry), label: 'Cajeros'),
          BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.calendarDay), label: 'Horarios'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: prs.colorButtonSecondary,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _contenido() {
    switch (_selectedIndex) {
      case 0:
        return SucursalcajerosView(
            agenciaModel: agenciaModel, sucursalModel: sucursalModel);
      case 1:
        return HorariosView(
            agenciaModel: agenciaModel, sucursalModel: sucursalModel);
    }
    return Container();
  }

  _onItemTapped(int index) {
    _selectedIndex = index;
    if (mounted) setState(() {});
  }
}
