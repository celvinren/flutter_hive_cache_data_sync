import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DatabaseService {
  DatabaseService._();
  static final DatabaseService _instance = DatabaseService._();
  bool _initialized = false;
  List<String>? collections;
  final StreamController<bool> _connectivityController =
      StreamController<bool>.broadcast();

  /// Get instance.
  static DatabaseService get instance {
    assert(
      _instance._initialized,
      'You must initialize the DatabaseService instance before calling DatabaseService.instance',
    );
    return _instance;
  }

  static Future<DatabaseService> initialize({List<String>? collections}) async {
    assert(
      !_instance._initialized,
      'This instance is already initialized',
    );

    /// Initialize the instance.
    _instance.collections = collections;
    await _instance._init();
    return _instance;
  }

  Future<void> _init() async {
    await _networkConnectivityCheck();
    await _initHiveBox();
    _initialized = true;
  }

  Future<void> _initHiveBox() async {
    await Hive.initFlutter();
    if (collections != null) {
      for (final database in _instance.collections ?? []) {
        await Hive.openBox(database);
      }
    }
  }

  _networkConnectivityCheck() async {
    Connectivity().onConnectivityChanged.listen((result) {
      _connectivityController.add(result != ConnectivityResult.none);
      if (result != ConnectivityResult.none) {
        /// Sync data
      }
    });
  }

  Collection collection(String collectionName) {
    final isCollectionExist = collections?.contains(collectionName) ?? false;
    assert(
      isCollectionExist,
      'Collection name is not registered',
    );
    return Collection(collectionName, Hive.box(collectionName));
  }
}

class Collection {
  final String name;
  final Box box;

  Collection(this.name, this.box);

  Future<void> add(String key, Map<String, dynamic> value) async {
    final connectivity = await Connectivity().checkConnectivity();
    final isConnected = connectivity != ConnectivityResult.none;
    if (isConnected) {
      /// Call api
      print('Call Api');
    } else {
      /// Add to dirty data
      print('No internet');
    }
    await box.put(key, value);
  }

  Document key(String key) {
    return Document(key, box);
  }
}

class Document {
  final String key;
  Box box;

  Document(this.key, this.box);

  Stream asStream() {
    StreamController<dynamic> controller = StreamController<dynamic>();

    box.listenable(keys: [key]).addListener(() {
      controller.add(box.get(key));
    });
    return controller.stream;
  }

  Map<String, dynamic>? get() {
    final data = box.get(key, defaultValue: {});

    return data != null ? Map<String, dynamic>.from(box.get(key)) : null;
  }
}
