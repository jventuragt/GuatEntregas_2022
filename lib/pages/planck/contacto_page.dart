import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import '../../model/cliente_model.dart';
import '../../providers/contacto_provider.dart';
import '../../utils/button.dart' as btn;
import '../../utils/personalizacion.dart' as prs;
import '../../utils/utils.dart' as utils;

class ContactoPage extends StatefulWidget {
  ContactoPage({Key key}) : super(key: key);

  @override
  State<ContactoPage> createState() => _ContactoPageState();
}

class _ContactoPageState extends State<ContactoPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ContactoProvider _contactoProvider = ContactoProvider();

  _ContactoPageState();

  ClienteModel cliente = ClienteModel();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Contactanos'),
        leading: utils.leading(context),
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
        Expanded(child: SingleChildScrollView(child: _contenido())),
        btn.booton('ENVIAR COMENTARIO', _calificar),
      ],
    );
  }

  Column _contenido() {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              Image(
                  image: AssetImage('assets/screen/calificacion.png'),
                  fit: BoxFit.cover,
                  width: 200.0),
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 15.0),
                    _estrellas(),
                    SizedBox(height: 20.0),
                    _crearComentario(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  double _rating = 4.99;

  Widget _estrellas() {
    return utils.estrellas(_rating, (value) => _rating = value);
  }

  String _contacto = '';

  Widget _crearComentario() {
    return TextFormField(
      minLines: 3,
      maxLength: 500,
      textCapitalization: TextCapitalization.sentences,
      keyboardType: TextInputType.multiline,
      maxLines: null,
      decoration: prs.decoration('Agrega un comentario', null),
      onSaved: (contacto) => _contacto = contacto,
      validator: (value) {
        if (value.length < 20) return 'Mínimo 20 caracteres';
        return null;
      },
    );
  }

  _calificar() {
    FocusScope.of(context).requestFocus(FocusNode());
    _saving = true;
    if (mounted) setState(() {});
    if (!_formKey.currentState.validate()) {
      _saving = false;
      if (mounted) setState(() {});
      return;
    }
    _formKey.currentState.save();
    _contactoProvider.enviar(_contacto, _rating, (estado, error) {
      _saving = false;
      if (mounted) setState(() {});
      _mostrarMensaje(context, estado, error);
    });
  }

  _mostrarMensaje(BuildContext context, int estado, String mensaje) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            title: Text('Importante'),
            content: Text(mensaje),
            actions: <Widget>[
              ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      primary: prs.colorButtonSecondary,
                      elevation: 2.0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0))),
                  label: Text('ACEPTAR'),
                  icon: Icon(Icons.check, size: 18.0),
                  onPressed: () {
                    if (estado == 1) {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    } else {
                      Navigator.pop(context);
                    }
                  }),
            ],
          );
        });
  }
}
