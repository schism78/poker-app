import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;
  static final _databaseName = 'poker.db';
  static final _databaseVersion = 1;

  static final tableGames = 'Games';
  static final columnGameID = 'gameID';
  static final columnAmountOfPlayers = 'amountOfPlayers';

  static final tablePlayers = 'Players';
  static final columnPlayerID = 'playerID';
  static final columnGameIDPlayers = 'gameID';
  static final columnName = 'name';

  static final tableRounds = 'Rounds';
  static final columnRoundID = 'roundID';
  static final columnGameIDRounds = 'gameID';
  static final columnTypeOfGame = 'typeOfGame';

  static final tableBets = 'Bets';
  static final columnBetID = 'betID';
  static final columnPlayerIDBets = 'playerID';
  static final columnRoundIDBets = 'roundID';
  static final columnAmountOfOrderedTakes = 'amountOfOrderedTakes';
  static final columnAmountOfTakenTakes = 'amountOfTakenTakes';
  static final columnPoints = 'points';

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return openDatabase(path, version: _databaseVersion, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableGames (
        $columnGameID INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnAmountOfPlayers INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tablePlayers (
        $columnPlayerID INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnGameIDPlayers INTEGER NOT NULL,
        $columnName TEXT NOT NULL,
        FOREIGN KEY ($columnGameIDPlayers) REFERENCES $tableGames($columnGameID)
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableRounds (
        $columnRoundID INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnGameIDRounds INTEGER NOT NULL,
        $columnTypeOfGame TEXT NOT NULL,
        FOREIGN KEY ($columnGameIDRounds) REFERENCES $tableGames($columnGameID)
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableBets (
        $columnBetID INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnPlayerIDBets INTEGER,
        $columnRoundIDBets INTEGER,
        $columnAmountOfOrderedTakes INTEGER,
        $columnAmountOfTakenTakes INTEGER,
        $columnPoints INTEGER,
        FOREIGN KEY ($columnPlayerIDBets) REFERENCES $tablePlayers($columnPlayerID),
        FOREIGN KEY ($columnRoundIDBets) REFERENCES $tableRounds($columnRoundID)
      )
    ''');
  }

  Future<int> insertGame(int numberOfPlayers) async {
    final db = await database;
    return await db.insert(
      tableGames,
      {columnAmountOfPlayers: numberOfPlayers},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> insertPlayer(int gameId, String playerName) async {
    final db = await database;
    return await db.insert(
      tablePlayers,
      {
        columnGameIDPlayers: gameId,
        columnName: playerName,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> insertRound(int gameId, String typeOfGame) async {
    final db = await database;
    return await db.insert(
      tableRounds,
      {
        columnGameIDRounds: gameId,
        columnTypeOfGame: typeOfGame,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertBet(int playerId, int roundId, int orderedTakes,
      int takenTakes, int points) async {
    final db = await database;
    await db.insert(
      tableBets,
      {
        columnPlayerIDBets: playerId,
        columnRoundIDBets: roundId,
        columnAmountOfOrderedTakes: orderedTakes,
        columnAmountOfTakenTakes: takenTakes,
        columnPoints: points,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
