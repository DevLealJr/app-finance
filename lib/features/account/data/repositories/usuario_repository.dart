import 'package:finance/core/database/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class UsuarioRepository {
  final DatabaseHelper _databaseHelper;

  UsuarioRepository({DatabaseHelper? databaseHelper})
    : _databaseHelper = databaseHelper ?? DatabaseHelper.instance;

  Future<Map<String, Object?>?> usuarioAtual() async {
    final db = await _databaseHelper.database;
    final rows = await db.query(
      'usuarios',
      where: 'sessao_ativa = ?',
      whereArgs: [1],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<Map<String, Object?>?> buscarPorEmail(String email) async {
    final db = await _databaseHelper.database;
    final rows = await db.query(
      'usuarios',
      where: 'email = ?',
      whereArgs: [normalizarEmail(email)],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<Map<String, Object?>?> primeiroUsuario() async {
    final db = await _databaseHelper.database;
    final rows = await db.query('usuarios', limit: 1);
    return rows.isEmpty ? null : rows.first;
  }

  Future<bool> existeConta() async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery('SELECT 1 FROM usuarios LIMIT 1');
    return result.isNotEmpty;
  }

  Future<void> criar({
    required String id,
    required String nome,
    required String email,
    required String senhaHash,
  }) async {
    final db = await _databaseHelper.database;
    final agora = DateTime.now().toIso8601String();
    await db.insert('usuarios', {
      'id': id,
      'nome': nome.trim(),
      'email': normalizarEmail(email),
      'senha_hash': senhaHash,
      'sessao_ativa': 1,
      'criado_em': agora,
      'atualizado_em': agora,
    }, conflictAlgorithm: ConflictAlgorithm.abort);
  }

  Future<void> ativarSessao(String id) async {
    final db = await _databaseHelper.database;
    await db.transaction((txn) async {
      await txn.update('usuarios', {'sessao_ativa': 0});
      await txn.update(
        'usuarios',
        {'sessao_ativa': 1, 'atualizado_em': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }

  Future<void> encerrarSessoes() async {
    final db = await _databaseHelper.database;
    await db.update('usuarios', {'sessao_ativa': 0});
  }

  Future<void> atualizarSenha(String id, String senhaHash) async {
    final db = await _databaseHelper.database;
    await db.update(
      'usuarios',
      {
        'senha_hash': senhaHash,
        'atualizado_em': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> salvarConfiguracao(
    String usuarioId,
    String chave,
    String valor,
  ) async {
    final db = await _databaseHelper.database;
    await db.insert('configuracoes_usuario', {
      'usuario_id': usuarioId,
      'chave': chave,
      'valor': valor,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, String>> listarConfiguracoes(String usuarioId) async {
    final db = await _databaseHelper.database;
    final rows = await db.query(
      'configuracoes_usuario',
      where: 'usuario_id = ?',
      whereArgs: [usuarioId],
    );
    return {
      for (final row in rows) row['chave']! as String: row['valor']! as String,
    };
  }

  static String normalizarEmail(String email) => email.trim().toLowerCase();
}
