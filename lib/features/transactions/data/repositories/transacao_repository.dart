import 'package:finance/features/transactions/data/models/transacao_model.dart';
import 'package:finance/features/transactions/data/models/gasto_fixo_model.dart';
import 'package:finance/core/database/database_helper.dart';

class TransacaoRepository {
  final DatabaseHelper _databaseHelper;

  TransacaoRepository({DatabaseHelper? databaseHelper})
    : _databaseHelper = databaseHelper ?? DatabaseHelper.instance;

  Future<List<TransacaoModel>> listarTodas({required String usuarioId}) async {
    final db = await _databaseHelper.database;
    final rows = await db.query(
      'transacoes',
      where: 'user_id = ?',
      whereArgs: [usuarioId],
      orderBy: 'data ASC',
    );
    return rows.map(TransacaoModel.fromMap).toList(growable: false);
  }

  Future<void> salvarTodas(
    List<TransacaoModel> transacoes, {
    required String usuarioId,
  }) async {
    final db = await _databaseHelper.database;
    await db.transaction((txn) async {
      for (final transacao in transacoes) {
        await txn.insert('transacoes', {
          ...transacao.toMap(),
          'user_id': usuarioId,
        });
      }
    });
  }

  Future<List<GastoFixoModel>> listarGastosFixos({
    required String usuarioId,
  }) async {
    final db = await _databaseHelper.database;
    final rows = await db.query(
      'gastos_fixos',
      where: 'user_id = ?',
      whereArgs: [usuarioId],
      orderBy: 'descricao COLLATE NOCASE',
    );
    return rows.map(GastoFixoModel.fromMap).toList(growable: false);
  }

  Future<void> salvarGastoFixo(
    GastoFixoModel gasto, {
    required String usuarioId,
  }) async {
    final db = await _databaseHelper.database;
    await db.insert('gastos_fixos', {...gasto.toMap(), 'user_id': usuarioId});
  }

  Future<void> atualizarGastoFixo(
    GastoFixoModel gasto, {
    required String usuarioId,
  }) async {
    final db = await _databaseHelper.database;
    await db.update(
      'gastos_fixos',
      gasto.toMap(),
      where: 'id = ? AND user_id = ?',
      whereArgs: [gasto.id, usuarioId],
    );
  }

  Future<void> excluirGastoFixo(String id, {required String usuarioId}) async {
    final db = await _databaseHelper.database;
    await db.delete(
      'gastos_fixos',
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, usuarioId],
    );
  }

  Future<void> atualizarPagamento(
    String id, {
    required String usuarioId,
    required bool pago,
  }) async {
    final db = await _databaseHelper.database;
    await db.update(
      'transacoes',
      {'pago': pago ? 1 : 0},
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, usuarioId],
    );
  }
}
