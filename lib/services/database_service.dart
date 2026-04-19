import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/charging_station.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'charging_stations.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE charging_stations(
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            operator TEXT,
            plug_types TEXT,
            charging_speed TEXT,
            is_available INTEGER DEFAULT 1,
            opening_hours TEXT,
            phone TEXT,
            address TEXT,
            website TEXT,
            fee TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE charging_stations ADD COLUMN opening_hours TEXT',
          );
          await db.execute(
            'ALTER TABLE charging_stations ADD COLUMN phone TEXT',
          );
          await db.execute(
            'ALTER TABLE charging_stations ADD COLUMN address TEXT',
          );
          await db.execute(
            'ALTER TABLE charging_stations ADD COLUMN website TEXT',
          );
          await db.execute('ALTER TABLE charging_stations ADD COLUMN fee TEXT');
        }
      },
    );
  }

  Future<void> insertStation(ChargingStation station) async {
    final db = await database;
    await db.insert(
      'charging_stations',
      station.toDbMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertStations(List<ChargingStation> stations) async {
    final db = await database;
    final batch = db.batch();

    for (final station in stations) {
      batch.insert(
        'charging_stations',
        station.toDbMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  Future<List<ChargingStation>> getAllStations() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('charging_stations');

    return List.generate(maps.length, (i) {
      return ChargingStation.fromDbMap(maps[i]);
    });
  }

  Future<ChargingStation?> getStationById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'charging_stations',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return ChargingStation.fromDbMap(maps.first);
  }

  Future<void> updateStation(ChargingStation station) async {
    final db = await database;
    await db.update(
      'charging_stations',
      station.toDbMap(),
      where: 'id = ?',
      whereArgs: [station.id],
    );
  }

  Future<void> deleteStation(String id) async {
    final db = await database;
    await db.delete('charging_stations', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteAllStations() async {
    final db = await database;
    await db.delete('charging_stations');
  }

  Future<int> getStationCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM charging_stations');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
