// lib/core/database/database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  static Future<Database>? _openingDatabase;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    final opening = _openingDatabase ??= _initDB('meu_controle.db');
    try {
      _database = await opening;
      return _database!;
    } catch (_) {
      if (identical(_openingDatabase, opening)) _openingDatabase = null;
      rethrow;
    }
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 7,
      onCreate: _createDB,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await _createUsersTable(db);
    await _createUserSettingsTable(db);

    await db.execute('''
      CREATE TABLE cartoes (
        id TEXT PRIMARY KEY,
        user_id TEXT,
        nome TEXT NOT NULL,
        finalNumero TEXT NOT NULL,
        bandeira TEXT NOT NULL,
        isFamiliar INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES usuarios (id) ON DELETE CASCADE
      )
    ''');

    // 2. Tabela de Transações/Gastos (Alimenta a tela Início, Lançar e Histórico)
    await db.execute('''
      CREATE TABLE transacoes (
        id TEXT PRIMARY KEY,
        user_id TEXT,
        descricao TEXT NOT NULL,
        valorTotal INTEGER NOT NULL,
        metodoPagamento TEXT NOT NULL,
        cartao_id TEXT,
        isCartaoFamiliar INTEGER NOT NULL,
        isParcelado INTEGER NOT NULL,
        parcelaAtual INTEGER NOT NULL,
        totalParcelas INTEGER NOT NULL,
        valorParcela INTEGER NOT NULL,
        categoria TEXT NOT NULL,
        data TEXT NOT NULL,
        pago INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES usuarios (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE gastos_fixos (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        descricao TEXT NOT NULL,
        valor INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES usuarios(id) ON DELETE CASCADE
      )
    ''');

    await _createRecebimentosTable(db);
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.delete('cartoes', where: 'id IN (?, ?)', whereArgs: ['1', '2']);
    }
    if (oldVersion < 3) {
      await _createUsersTable(db);
      await _createUserSettingsTable(db);
      await db.execute('ALTER TABLE cartoes ADD COLUMN user_id TEXT');
      await db.execute('ALTER TABLE transacoes ADD COLUMN user_id TEXT');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS gastos_fixos (
          id TEXT PRIMARY KEY,
          user_id TEXT NOT NULL,
          descricao TEXT NOT NULL,
          valor REAL NOT NULL,
          FOREIGN KEY (user_id) REFERENCES usuarios(id) ON DELETE CASCADE
        )
      ''');
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_cartoes_user_id ON cartoes(user_id)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_transacoes_user_id ON transacoes(user_id)',
      );
    }
    if (oldVersion < 4) {
      await db.execute(
        'ALTER TABLE transacoes ADD COLUMN pago INTEGER NOT NULL DEFAULT 0',
      );
    }
    if (oldVersion < 5) {
      await db.execute('''
        CREATE TABLE transacoes_centavos (
          id TEXT PRIMARY KEY,
          user_id TEXT,
          descricao TEXT NOT NULL,
          valorTotal INTEGER NOT NULL,
          metodoPagamento TEXT NOT NULL,
          isCartaoFamiliar INTEGER NOT NULL,
          isParcelado INTEGER NOT NULL,
          parcelaAtual INTEGER NOT NULL,
          totalParcelas INTEGER NOT NULL,
          valorParcela INTEGER NOT NULL,
          categoria TEXT NOT NULL,
          data TEXT NOT NULL,
          pago INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY (user_id) REFERENCES usuarios (id) ON DELETE CASCADE
        )
      ''');
      await db.execute('''
        INSERT INTO transacoes_centavos
        SELECT id, user_id, descricao,
          CAST(ROUND(valorTotal * 100) AS INTEGER), metodoPagamento,
          isCartaoFamiliar, isParcelado, parcelaAtual, totalParcelas,
          CAST(ROUND(valorParcela * 100) AS INTEGER), categoria, data, pago
        FROM transacoes
      ''');
      await db.execute('DROP TABLE transacoes');
      await db.execute('ALTER TABLE transacoes_centavos RENAME TO transacoes');
      await db.execute('ALTER TABLE gastos_fixos RENAME TO gastos_fixos_reais');
      await db.execute('''
        CREATE TABLE gastos_fixos (
          id TEXT PRIMARY KEY,
          user_id TEXT NOT NULL,
          descricao TEXT NOT NULL,
          valor INTEGER NOT NULL,
          FOREIGN KEY (user_id) REFERENCES usuarios(id) ON DELETE CASCADE
        )
      ''');
      await db.execute('''
        INSERT INTO gastos_fixos
        SELECT id, user_id, descricao, CAST(ROUND(valor * 100) AS INTEGER)
        FROM gastos_fixos_reais
      ''');
      await db.execute('DROP TABLE gastos_fixos_reais');
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_cartoes_user_id ON cartoes(user_id)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_transacoes_user_id ON transacoes(user_id)',
      );
    }
    if (oldVersion < 6) {
      await db.execute('ALTER TABLE transacoes ADD COLUMN cartao_id TEXT');
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_transacoes_cartao_id ON transacoes(cartao_id)',
      );
    }
    if (oldVersion < 7) {
      await _createRecebimentosTable(db);
    }
  }

  Future<void> _createRecebimentosTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS recebimentos (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        descricao TEXT NOT NULL,
        valor INTEGER NOT NULL,
        categoria TEXT NOT NULL,
        data TEXT NOT NULL,
        recebido INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES usuarios(id) ON DELETE CASCADE
      )
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_recebimentos_user_id ON recebimentos(user_id)',
    );
  }

  Future<void> _createUsersTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS usuarios (
        id TEXT PRIMARY KEY,
        nome TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE COLLATE NOCASE,
        senha_hash TEXT NOT NULL,
        sessao_ativa INTEGER NOT NULL DEFAULT 0,
        criado_em TEXT NOT NULL,
        atualizado_em TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createUserSettingsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS configuracoes_usuario (
        usuario_id TEXT NOT NULL,
        chave TEXT NOT NULL,
        valor TEXT NOT NULL,
        PRIMARY KEY (usuario_id, chave),
        FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
      )
    ''');
  }
}
