// import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

import '../bloc/agencia_bloc.dart';
import '../bloc/reporte_bloc.dart';
import '../card/shimmer_card.dart';
// import '../model/reporte_model.dart';
import '../model/ventas_reporte_model.dart';
import '../utils/personalizacion.dart' as prs;

class VentasWidget extends StatefulWidget {
  @override
  State<VentasWidget> createState() => VentasWidgetState();
}

class VentasWidgetState extends State<VentasWidget> {
  final AgenciaBloc _agenciaBloc = AgenciaBloc();
  final ReporteBloc _reporteBloc = ReporteBloc();

  var seriesLine;
  var seriesDona;

  TextEditingController _inputFieldDateController;

  VentasWidgetState();

  @override
  void initState() {
    _inputFieldDateController =
        TextEditingController(text: f.format(DateTime.now()));
    super.initState();
  }

  final bool animate = true;

  // Widget _graficar(BuildContext context, List<ReporteModel> compras) {
  //   seriesLine = [
  // new charts.Series<ReporteModel, int>(
  //   id: 'Total',
  //   domainFn: (ReporteModel sales, _) => sales.number,
  //   measureFn: (ReporteModel sales, _) => sales.total,
  //   data: compras,
  //   colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
  // ),
  // new charts.Series<ReporteModel, int>(
  //   id: 'Canceladas',
  //   domainFn: (ReporteModel sales, _) => sales.number,
  //   measureFn: (ReporteModel sales, _) => sales.cancelada,
  //   data: compras,
  //   colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
  // ),
  // new charts.Series<ReporteModel, int>(
  //   id: 'Entregadas',
  //   domainFn: (ReporteModel sales, _) => sales.number,
  //   measureFn: (ReporteModel sales, _) => sales.entragda,
  //   data: compras,
  //   colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
  // ),
  // new charts.Series<ReporteModel, int>(
  //   id: 'Consultando',
  //   domainFn: (ReporteModel sales, _) => sales.number,
  //   measureFn: (ReporteModel sales, _) => sales.consultando,
  //   data: compras,
  //   colorFn: (_, __) => charts.MaterialPalette.cyan.shadeDefault,
  // ),
  //   ];
  //   return Column(
  //     children: [
  //       line(),
  //       dona(),
  //     ],
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _crearFecha(context),
        StreamBuilder(
          stream: _reporteBloc.ventaStream,
          builder: (BuildContext context,
              AsyncSnapshot<List<VentasReporteModel>> snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data.length > 0)
                return _contenidoTabla(context, snapshot.data);
              return Container();
            } else {
              return ShimmerCard();
            }
          },
        ),
        // StreamBuilder(
        //   stream: _reporteBloc.compraStream,
        //   builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
        //     if (snapshot.hasData) {
        //       if (snapshot.data.length > 0)
        //         return _graficar(context, snapshot.data);
        //       return _img();
        //     } else {
        //       return ShimmerCard();
        //     }
        //   },
        // ),
      ],
    );
  }

  DateTime initialDate = DateTime.now();

  final f = new DateFormat('MMMM - yyyy', 'es');
  final fC = new DateFormat('yyyy-MM-dd');

  Widget _crearFecha(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: _mostrarCalendario,
          child: Text('${f.format(initialDate)}',
              style: TextStyle(color: prs.colorTextTitle, fontSize: 18.0)),
        ),
        IconButton(
          icon: Icon(Icons.calendar_today, size: 22.0, color: prs.colorIcons),
          onPressed: _mostrarCalendario,
        )
      ],
    );
  }

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

        _inputFieldDateController.text = f.format(date);

        _reporteBloc.listarCompras(_agenciaBloc.agenciaSeleccionada.idAgencia,
            fecha: fC.format(date));
      }
    });
  }

  // Widget _img() {
  //   return Container(
  //     margin: EdgeInsets.all(80.0),
  //     child: Center(
  //       child: Image(
  //         image: AssetImage('assets/screen/direcciones.png'),
  //         fit: BoxFit.cover,
  //       ),
  //     ),
  //   );
  // }

  line() {
    if (seriesLine == null) return Container();
    // final size = MediaQuery.of(context).size;
    // return Container(
    //   height: size.height / 2 - 130,
    //   child: charts.NumericComboChart(
    //     seriesLine,
    //     animate: animate,
    //     defaultRenderer: new charts.LineRendererConfig(
    //       includeArea: true,
    //       includeLine: true,
    //     ),
    //     selectionModels: [
    //       new charts.SelectionModelConfig(
    //         type: charts.SelectionModelType.info,
    //         updatedListener: _onSelectionChanged,
    //       )
    //     ],
    //     behaviors: [
    //       new charts.LinePointHighlighter(
    //           selectionModelType: charts.SelectionModelType.info,
    //           showHorizontalFollowLine:
    //               charts.LinePointHighlighterFollowLineType.all,
    //           showVerticalFollowLine:
    //               charts.LinePointHighlighterFollowLineType.all),
    //       new charts.SelectNearest(
    //           selectionModelType: charts.SelectionModelType.action,
    //           eventTrigger: charts.SelectionTrigger.tap),
    //     ],
    //   ),
    // );
  }

  String fecha = '', canceladas = '', entregadas = '', consultando = '';

  // _onSelectionChanged(charts.SelectionModel model) {
  //   final selectedDatum = model.selectedDatum;

  //   if (selectedDatum.isNotEmpty && selectedDatum.length >= 2) {
  //     var data = [];

  //     data.add(LinearSales('Entregada', selectedDatum[0].datum.entragda,
  //         selectedDatum[0].datum.entragda));

  //     data.add(LinearSales('Cancelada', selectedDatum[0].datum.cancelada,
  //         selectedDatum[0].datum.cancelada));

  //     fecha = selectedDatum[0].datum.fecha.toString();
  //     entregadas = selectedDatum[0].datum.entragda.toString();
  //     canceladas = selectedDatum[0].datum.cancelada.toString();
  //     consultando = selectedDatum[0].datum.consultando.toString();

  //     seriesDona = [
  //       // new charts.Series<LinearSales, int>(
  //       //   id: 'Total',
  //       //   domainFn: (LinearSales sales, _) => sales.year,
  //       //   measureFn: (LinearSales sales, _) => sales.sales,
  //       //   data: data,
  //       //   labelAccessorFn: (LinearSales row, _) => '${row.sales}: ${row.label}',
  //       // ),
  //     ];
  //     if (mounted) if (mounted) setState(() {});
  //   }
  // }

  dona() {
    if (seriesDona == null) return Container();
    // final size = MediaQuery.of(context).size;
    return Container(
        // height: size.height / 3 - 70,
        // child: charts.PieChart(
        //   seriesDona,
        //   animate: animate,
        //   defaultRenderer: new charts.ArcRendererConfig(
        //       arcWidth: 50,
        //       strokeWidthPx: 1,
        //       arcRendererDecorators: [
        //         new charts.ArcLabelDecorator(
        //             showLeaderLines: false, labelPadding: 0)
        //       ]),
        // ),
        );
  }

  Widget _contenidoTabla(
      BuildContext context, List<VentasReporteModel> reportes) {
    List<DataRow> rows = [];

    int ventas = 0;
    double ingresos = 0.0;
    double devuelto = 0.0;

    reportes.forEach((reporte) {
      ventas = ventas + reporte.ventas;
      ingresos = ingresos + reporte.ingresos;
      devuelto = devuelto + reporte.devuelto;

      rows.add(DataRow(cells: [
        DataCell(Text(reporte.formaPago)),
        DataCell(Text('${reporte.ventas}')),
        DataCell(Text(
            '${double.parse(reporte.ingresos.toString()).toStringAsFixed(2)}')),
        DataCell(Text(
            '${double.parse(reporte.devuelto.toString()).toStringAsFixed(2)}')),
      ]));
    });

    rows.add(DataRow(cells: [
      DataCell(Text(
        'Total',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0),
      )),
      DataCell(Text(
        '$ventas',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0),
      )),
      DataCell(Text(
        '${double.parse(ingresos.toString()).toStringAsFixed(2)}',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0),
      )),
      DataCell(Text(
        '${double.parse(devuelto.toString()).toStringAsFixed(2)}',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0),
      )),
    ]));

    return DataTable(
      showCheckboxColumn: false,
      columnSpacing: 10.0,
      columns: [
        DataColumn(
          label: Text('Razon'),
          numeric: false,
        ),
        DataColumn(
          label: Text('Ventas'),
          numeric: true,
        ),
        DataColumn(
          label: Text('Ingresos'),
          numeric: true,
        ),
        DataColumn(
          label: Text('Acreditado'),
          numeric: true,
        ),
      ],
      rows: rows,
    );
  }
}

class LinearSales {
  final String label;
  final int year;
  final int sales;

  LinearSales(this.label, this.year, this.sales);
}
