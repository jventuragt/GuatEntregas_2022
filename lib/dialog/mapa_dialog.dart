import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../bloc/mapa_bloc.dart';
import '../utils/personalizacion.dart' as prs;

class MapaDialog extends StatefulWidget {
  final Function onSelectMapa;
  final double lt;
  final double lg;

  MapaDialog(this.onSelectMapa, this.lt, this.lg);

  @override
  _MapaDialogState createState() => _MapaDialogState();
}

class _MapaDialogState extends State<MapaDialog> {
  final MapaBloc _mapaBloc = MapaBloc();
  bool _isLineProgress = false;

  @override
  void initState() {
    super.initState();
  }

  Widget _selecMapaes() {
    return Column(
      children: [
        Visibility(
            visible: _isLineProgress,
            child: LinearProgressIndicator(
                backgroundColor: prs.colorLinearProgress)),
        StreamBuilder(
          stream: _mapaBloc.mapaStream,
          builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
            if (snapshot.hasData) {
              return createExpanPanel(context, snapshot.data);
            } else {
              return Container();
            }
          },
        )
      ],
    );
  }

  Widget createExpanPanel(context, listaMapaes) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(0.0),
      itemCount: listaMapaes.length,
      itemBuilder: (BuildContext context, int index) {
        var suggestion = listaMapaes[index];
        var icon = Icon(Icons.public);
        for (var item in suggestion['types']) {
          if (item == 'park') {
            icon = Icon(Icons.terrain);
            break;
          } else if (item == 'pharmacy') {
            icon = Icon(Icons.local_pharmacy);
            break;
          } else if (item == 'hospital') {
            icon = Icon(FontAwesomeIcons.hospital);
            break;
          } else if (item == 'university' || item == 'school') {
            icon = Icon(Icons.school);
            break;
          } else if (item == 'establishment') {
            icon = Icon(Icons.location_city);
            break;
          } else if (item == 'gas_station') {
            icon = Icon(Icons.local_gas_station);
            break;
          } else if (item == 'bank' || item == 'finance') {
            icon = Icon(Icons.account_balance);
            break;
          } else if (item == 'food' || item == 'store') {
            icon = Icon(Icons.store_mall_directory);
            break;
          } else if (item == 'route') {
            icon = Icon(Icons.view_stream);
            break;
          } else if (item == 'church') {
            icon = Icon(FontAwesomeIcons.church);
            break;
          }
        }
        return ListTile(
          onTap: () {
            widget.onSelectMapa(suggestion);
          },
          dense: true,
          leading: icon,
          title: Text(suggestion['main']),
          subtitle: Text('${suggestion['secondary']}'),
        );
      },
    );
  }

  Widget _crearBuscardor() {
    return TextFormField(
      autofocus: true,
      decoration: prs.decoration(
          'Cerca del marcador central del mapa', prs.iconoLocationCentro),
      onChanged: (criterio) async {
        _isLineProgress = true;
        if (mounted) setState(() {});
        await _mapaBloc.filtrar(widget.lt, widget.lg, criterio);
        _isLineProgress = false;
        if (mounted) setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: EdgeInsets.all(10.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      contentPadding: EdgeInsets.only(left: 10.0, right: 5.0, top: 10.0),
      title: Text(
        'Busca un lugar',
        style: TextStyle(fontSize: 16.0),
        textAlign: TextAlign.center,
      ),
      content: Container(
        width: 400.0,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              _crearBuscardor(),
              _selecMapaes(),
            ],
          ),
        ),
      ),
    );
  }
}
