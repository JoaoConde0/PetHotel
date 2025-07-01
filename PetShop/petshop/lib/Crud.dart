import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'modelos/tutor_model.dart';
import 'modelos/raca_model.dart';
import 'modelos/pet_model.dart';


class DatabaseHelper {
  // Padrão Singleton para garantir que haja apenas uma instância do banco de dados.
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  // Getter para a instância do banco de dados.
  // Se o banco de dados não foi inicializado, ele o inicializa.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  // Inicializa o banco de dados.
  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'pethotel.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate, // Executa o método _onCreate na primeira vez que o DB é criado.
    );
  }

  // Cria as tabelas no banco de dados.
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE Tutor(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        contato TEXT NOT NULL,
        sexo TEXT NOT NULL,
        metodoPagamento TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE Raca(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        especie TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE Pet(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tutorId INTEGER NOT NULL,
        racaId INTEGER NOT NULL,
        especie TEXT NOT NULL,
        dataEntrada TEXT NOT NULL,
        dataSaida TEXT,
        FOREIGN KEY (tutorId) REFERENCES Tutor(id) ON DELETE CASCADE,
        FOREIGN KEY (racaId) REFERENCES Raca(id) ON DELETE RESTRICT
      )
    ''');
  }

  // --- MÉTODOS CRUD PARA TUTOR ---

  Future<int> createTutor(Tutor tutor) async {
    final db = await database;
    return await db.insert('Tutor', tutor.toMap());
  }

  Future<List<Tutor>> getAllTutors() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('Tutor');
    return List.generate(maps.length, (i) => Tutor.fromMap(maps[i]));
  }

  Future<int> updateTutor(Tutor tutor) async {
    final db = await database;
    return await db.update('Tutor', tutor.toMap(), where: 'id = ?', whereArgs: [tutor.id]);
  }

  Future<int> deleteTutor(int id) async {
    final db = await database;
    return await db.delete('Tutor', where: 'id = ?', whereArgs: [id]);
  }

  // --- MÉTODOS CRUD PARA RACA ---

  Future<int> createRaca(Raca raca) async {
    final db = await database;
    return await db.insert('Raca', raca.toMap());
  }

  Future<List<Raca>> getAllRacas() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('Raca');
    return List.generate(maps.length, (i) => Raca.fromMap(maps[i]));
  }
  
  Future<List<Raca>> getRacasByEspecie(String especie) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('Raca', where: 'especie = ?', whereArgs: [especie]);
    return List.generate(maps.length, (i) => Raca.fromMap(maps[i]));
  }

  Future<int> updateRaca(Raca raca) async {
    final db = await database;
    return await db.update('Raca', raca.toMap(), where: 'id = ?', whereArgs: [raca.id]);
  }

  Future<int> deleteRaca(int id) async {
    final db = await database;
    return await db.delete('Raca', where: 'id = ?', whereArgs: [id]);
  }

  // --- MÉTODOS CRUD PARA PET ---

  Future<int> createPet(Pet pet) async {
    final db = await database;
    return await db.insert('Pet', pet.toMap());
  }

  Future<List<Pet>> getAllPets() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('Pet');
    return List.generate(maps.length, (i) => Pet.fromMap(maps[i]));
  }
  
  Future<int> updatePet(Pet pet) async {
    final db = await database;
    return await db.update('Pet', pet.toMap(), where: 'id = ?', whereArgs: [pet.id]);
  }

  Future<int> deletePet(int id) async {
    final db = await database;
    return await db.delete('Pet', where: 'id = ?', whereArgs: [id]);
  }
}