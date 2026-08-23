// lib/core/database/database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('meu_controle.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.delete(
            'cartoes',
            where: 'id IN (?, ?)',
            whereArgs: ['1', '2'],
          );
        }
      },
    );
  }

  // Criação das tabelas baseadas exatamente nos seus modelos visuais
  Future _createDB(Database db, int version) async {
    // 1. Tabela de Cartões (Alimenta a tela de Perfil e o seletor da tela Lançar)
    await db.execute('''
      CREATE TABLE cartoes (
        id TEXT PRIMARY KEY,
        nome TEXT NOT NULL,
        finalNumero TEXT NOT NULL,
        bandeira TEXT NOT NULL,
        isFamiliar INTEGER NOT NULL
      )
    ''');

    // 2. Tabela de Transações/Gastos (Alimenta a tela Início, Lançar e Histórico)
    await db.execute('''
      CREATE TABLE transacoes (
        id TEXT PRIMARY KEY,
        descricao TEXT NOT NULL,
        valorTotal REAL NOT NULL,
        metodoPagamento TEXT NOT NULL,
        isCartaoFamiliar INTEGER NOT NULL,
        isParcelado INTEGER NOT NULL,
        parcelaAtual INTEGER NOT NULL,
        totalParcelas INTEGER NOT NULL,
        valorParcela REAL NOT NULL,
        categoria TEXT NOT NULL,
        data TEXT NOT NULL
      )
    ''');
  }
}
