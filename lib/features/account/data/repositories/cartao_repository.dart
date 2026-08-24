import 'package:finance/features/account/data/models/usuario_model.dart';
import 'package:finance/core/database/database_helper.dart';

class CartaoRepository {
  final DatabaseHelper _databaseHelper;

  CartaoRepository({DatabaseHelper? databaseHelper})
    : _databaseHelper = databaseHelper ?? DatabaseHelper.instance;

  Future<List<CartaoModel>> listarTodos({required String usuarioId}) async {
    final db = await _databaseHelper.database;
    final rows = await db.query(
      'cartoes',
      where: 'user_id = ?',
      whereArgs: [usuarioId],
      orderBy: 'nome COLLATE NOCASE',
    );
    return rows.map(CartaoModel.fromMap).toList(growable: false);
  }

  Future<void> salvar(CartaoModel cartao, {required String usuarioId}) async {
    final db = await _databaseHelper.database;
    await db.insert('cartoes', {...cartao.toMap(), 'user_id': usuarioId});
  }
}
