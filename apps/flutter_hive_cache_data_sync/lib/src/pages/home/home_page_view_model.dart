import 'package:flutter_hive_cache_data_sync/src/database_service/database_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data_models/user.dart';

part 'home_page_view_model.g.dart';

const kKey = 'testKey';

@riverpod
class HomeViewModel extends _$HomeViewModel {
  @override
  User? build() {
    DatabaseService.instance
        .collection('user')
        .key(kKey)
        .asStream()
        .listen((event) {
      state = User.fromJson(event);
    });

    final data = DatabaseService.instance.collection('user').key(kKey).get();
    return data != null ? User.fromJson(data) : null;
  }

  void onChanged(String value) {
    final state = this.state;
    DatabaseService.instance.collection('user').add(
        kKey,
        (state != null ? state.copyWith(name: value) : User(name: value))
            .toJson());
  }
}
