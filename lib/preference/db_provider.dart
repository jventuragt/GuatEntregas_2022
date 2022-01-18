import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../model/promocion_model.dart';

class DBProvider {
  static Database _database;
  static final DBProvider db = DBProvider._();

  DBProvider._();

  Future<Database> get database async {
    if (_database != null) return _database;

    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'opportunity_5.db');
    return await openDatabase(path, version: 4, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      await db.execute('CREATE TABLE Promocion ('
          ' id_agencia INTEGER,'
          ' id_promocion INTEGER,'
          ' id_producto INTEGER,'
          ' id_urbe INTEGER,'
          ' incentivo TEXT,'
          ' producto TEXT,'
          ' descripcion TEXT,'
          ' precio TEXT,'
          ' imagen TEXT,'
          ' minimo TEXT,'
          ' maximo TEXT,'
          ' cantidad TEXT,'
          ' costoTotal TEXT,'
          ' dt TEXT'
          ')');
    });
  }

  agregarPromocion(PromocionModel pr, {LP producto}) async {
    final db = await database;
    var res;
    if (producto == null) {
      res = await db.rawInsert(
          "INSERT Into Promocion (id_agencia, id_promocion, id_producto, id_urbe, incentivo, producto, descripcion, precio, imagen, minimo, maximo, cantidad, costoTotal, dt) "
          "VALUES ( ${pr.idAgencia}, '${pr.idPromocion}', '${pr.idProducto}', '${pr.idUrbe}', '${pr.incentivo}','${pr.producto}','${pr.descripcion}','${pr.precio}','${pr.imagen}','${pr.minimo}','${pr.maximo}','${pr.cantidad}','${pr.costoTotal}', '' )");
    } else
      res = await db.rawInsert(
          "INSERT Into Promocion (id_agencia, id_promocion, id_producto, id_urbe, incentivo, producto, descripcion, precio, imagen, minimo, maximo, cantidad, costoTotal, dt) "
          "VALUES ( ${pr.idAgencia}, '${pr.idPromocion}', '${pr.idProducto}', '${pr.idUrbe}', '${pr.incentivo}','${pr.producto} (${producto.d})','${pr.descripcion}','${producto.p}','${pr.imagen}','${pr.minimo}','${pr.maximo}','${pr.cantidad}','${pr.costoTotal}', '' )");

    return res;
  }

  Future<int> eliminarPromocion(PromocionModel pr) async {
    final db = await database;
    final res = await db.delete('Promocion',
        where: 'id_promocion = ? AND id_producto = ?',
        whereArgs: [pr.idPromocion, pr.idProducto]);
    return res;
  }

  Future<int> eliminarPromocionPorAgencia(dynamic idAgencia) async {
    final db = await database;
    final res = await db
        .delete('Promocion', where: 'id_agencia = ?', whereArgs: [idAgencia]);
    return res;
  }

  Future<int> eliminarPromocionPorUrbe(dynamic idUrbe) async {
    final db = await database;
    final res =
        await db.delete('Promocion', where: 'id_urbe = ?', whereArgs: [idUrbe]);
    return res;
  }

  Future<int> editarPromocion(PromocionModel pr) async {
    final db = await database;
    int count = await db.update('Promocion',
        {'cantidad': pr.cantidad, 'costoTotal': pr.costoTotal, 'dt': pr.dt},
        where: 'id_promocion = ? AND id_producto = ?',
        whereArgs: [pr.idPromocion, pr.idProducto]);
    return count;
  }

  Future<List<PromocionModel>> listar(dynamic idUrbe) async {
    final db = await database;
    final res =
        await db.query('Promocion', where: 'id_urbe = ?', whereArgs: [idUrbe]);
    List<PromocionModel> list = res.isNotEmpty
        ? res.map((c) => PromocionModel.fromJson(c)).toList()
        : [];
    return list;
  }

  Future<List<PromocionModel>> listarPorPromocion(dynamic idPromocion) async {
    final db = await database;
    final res = await db.query('Promocion',
        where: 'id_promocion = ?', whereArgs: [idPromocion]);
    List<PromocionModel> list = res.isNotEmpty
        ? res.map((c) => PromocionModel.fromJson(c)).toList()
        : [];
    return list;
  }

  Future<List<PromocionModel>> listarPorAgencia(dynamic idAgencia) async {
    final db = await database;
    final res = await db
        .query('Promocion', where: 'id_agencia = ?', whereArgs: [idAgencia]);
    List<PromocionModel> list = res.isNotEmpty
        ? res.map((c) => PromocionModel.fromJson(c)).toList()
        : [];
    return list;
  }

  Future<int> contar() async {
    final db = await database;
    final res = await db.query('Promocion');
    return res.isNotEmpty
        ? res.map((c) => PromocionModel.fromJson(c)).toList().length
        : 0;
  }
}
