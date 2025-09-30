import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/trusted_device.dart';
import '../models/transfer_model.dart';
import '../utils/encryption_utils.dart';

/// Encrypted SQLite database service for trusted devices and transfer history
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;
  static const String _dbName = 'airdrop_secure.db';

  // Table names
  static const String trustedDevicesTable = 'trusted_devices';
  static const String transferHistoryTable = 'transfer_history';

  /// Initialize the database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize database with tables
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  /// Create tables
  Future<void> _onCreate(Database db, int version) async {
    // Trusted devices table
    await db.execute('''
      CREATE TABLE $trustedDevicesTable (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        avatar TEXT,
        fingerprint TEXT,
        addedAt TEXT NOT NULL,
        isApproved INTEGER NOT NULL DEFAULT 0,
        trustLevel INTEGER NOT NULL DEFAULT 1,
        lastConnected TEXT,
        encryptedData TEXT
      )
    ''');

    // Transfer history table
    await db.execute('''
      CREATE TABLE $transferHistoryTable (
        id TEXT PRIMARY KEY,
        fileName TEXT NOT NULL,
        filePath TEXT NOT NULL,
        fileSize INTEGER NOT NULL,
        mimeType TEXT NOT NULL,
        fromDevice TEXT NOT NULL,
        toDevice TEXT NOT NULL,
        status TEXT NOT NULL,
        direction TEXT NOT NULL,
        startTime TEXT NOT NULL,
        endTime TEXT,
        bytesTransferred INTEGER NOT NULL DEFAULT 0,
        progress REAL NOT NULL DEFAULT 0.0,
        errorMessage TEXT,
        checksum TEXT,
        isEncrypted INTEGER NOT NULL DEFAULT 1,
        encryptedData TEXT
      )
    ''');
  }

  /// Trusted Devices CRUD Operations

  /// Add or update trusted device
  Future<void> saveTrustedDevice(TrustedDevice device) async {
    final db = await database;
    final encryptedData = _encryptDeviceData(device.toJson());

    await db.insert(
      trustedDevicesTable,
      {
        'id': device.id,
        'name': device.name,
        'avatar': device.avatar,
        'fingerprint': device.fingerprint,
        'addedAt': device.addedAt.toIso8601String(),
        'isApproved': device.isApproved ? 1 : 0,
        'trustLevel': device.trustLevel,
        'lastConnected': device.lastConnected?.toIso8601String(),
        'encryptedData': encryptedData,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get all trusted devices
  Future<List<TrustedDevice>> getTrustedDevices() async {
    final db = await database;
    final maps = await db.query(trustedDevicesTable);

    return maps.map((map) {
      final decryptedData = _decryptDeviceData(map['encryptedData'] as String?);
      return TrustedDevice.fromJson(decryptedData ?? map);
    }).toList();
  }

  /// Get trusted device by ID
  Future<TrustedDevice?> getTrustedDevice(String id) async {
    final db = await database;
    final maps = await db.query(
      trustedDevicesTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;

    final map = maps.first;
    final decryptedData = _decryptDeviceData(map['encryptedData'] as String?);
    return TrustedDevice.fromJson(decryptedData ?? map);
  }

  /// Delete trusted device
  Future<void> deleteTrustedDevice(String id) async {
    final db = await database;
    await db.delete(
      trustedDevicesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Secure delete all data (overwrite before delete)
  Future<void> secureDeleteAll() async {
    final db = await database;

    // Overwrite trusted devices data
    final devices = await getTrustedDevices();
    for (final device in devices) {
      final dummyData = Map<String, dynamic>.from(device.toJson());
      dummyData.updateAll((key, value) => 'DELETED');
      final encryptedDummy = _encryptDeviceData(dummyData);
      await db.update(
        trustedDevicesTable,
        {'encryptedData': encryptedDummy},
        where: 'id = ?',
        whereArgs: [device.id],
      );
    }

    // Overwrite transfer history data
    final transfers = await getTransferHistory();
    for (final transfer in transfers) {
      final dummyData = Map<String, dynamic>.from(transfer.toJson());
      dummyData.updateAll((key, value) => 'DELETED');
      final encryptedDummy = _encryptDeviceData(dummyData);
      await db.update(
        transferHistoryTable,
        {'encryptedData': encryptedDummy},
        where: 'id = ?',
        whereArgs: [transfer.id],
      );
    }

    // Delete tables
    await db.delete(trustedDevicesTable);
    await db.delete(transferHistoryTable);
  }

  /// Transfer History CRUD Operations

  /// Save transfer to history
  Future<void> saveTransfer(TransferModel transfer) async {
    final db = await database;
    final encryptedData = _encryptDeviceData(transfer.toJson());

    await db.insert(
      transferHistoryTable,
      {
        'id': transfer.id,
        'fileName': transfer.fileName,
        'filePath': transfer.filePath,
        'fileSize': transfer.fileSize,
        'mimeType': transfer.mimeType,
        'fromDevice': jsonEncode(transfer.fromDevice.toJson()),
        'toDevice': jsonEncode(transfer.toDevice.toJson()),
        'status': transfer.status.toString().split('.').last,
        'direction': transfer.direction.toString().split('.').last,
        'startTime': transfer.startTime.toIso8601String(),
        'endTime': transfer.endTime?.toIso8601String(),
        'bytesTransferred': transfer.bytesTransferred,
        'progress': transfer.progress,
        'errorMessage': transfer.errorMessage,
        'checksum': transfer.checksum,
        'isEncrypted': transfer.isEncrypted ? 1 : 0,
        'encryptedData': encryptedData,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get transfer history
  Future<List<TransferModel>> getTransferHistory(
      {int? limit, int? offset}) async {
    final db = await database;
    final maps = await db.query(
      transferHistoryTable,
      limit: limit,
      offset: offset,
      orderBy: 'startTime DESC',
    );

    return maps.map((map) {
      final decryptedData = _decryptDeviceData(map['encryptedData'] as String?);
      return TransferModel.fromJson(decryptedData ?? map);
    }).toList();
  }

  /// Get transfer by ID
  Future<TransferModel?> getTransfer(String id) async {
    final db = await database;
    final maps = await db.query(
      transferHistoryTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;

    final map = maps.first;
    final decryptedData = _decryptDeviceData(map['encryptedData'] as String?);
    return TransferModel.fromJson(decryptedData ?? map);
  }

  /// Delete transfer from history
  Future<void> deleteTransfer(String id) async {
    final db = await database;
    await db.delete(
      transferHistoryTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Delete old transfers based on retention period
  Future<void> deleteOldTransfers(Duration retentionPeriod) async {
    final db = await database;
    final cutoffDate = DateTime.now().subtract(retentionPeriod);
    await db.delete(
      transferHistoryTable,
      where: 'startTime < ?',
      whereArgs: [cutoffDate.toIso8601String()],
    );
  }

  /// Encryption helpers (using device-specific key for simplicity)
  String _encryptDeviceData(Map<String, dynamic> data) {
    final jsonString = jsonEncode(data);
    final key = EncryptionUtils.deriveKey(
        'device_data_key'); // In production, use secure key
    final encrypted =
        EncryptionUtils.encryptBytes(utf8.encode(jsonString), key);
    return base64Encode(encrypted);
  }

  Map<String, dynamic> _decryptDeviceData(String? encryptedData) {
    if (encryptedData == null) return {};
    try {
      final encrypted = base64Decode(encryptedData);
      final key = EncryptionUtils.deriveKey('device_data_key');
      final decrypted = EncryptionUtils.decryptBytes(encrypted, key);
      final jsonString = utf8.decode(decrypted);
      return Map<String, dynamic>.from(json.decode(jsonString));
    } catch (e) {
      return {};
    }
  }

  /// Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
