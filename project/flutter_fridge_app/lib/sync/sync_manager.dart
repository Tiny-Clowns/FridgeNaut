import "dart:async";
import "package:connectivity_plus/connectivity_plus.dart";
import "package:flutter_fridge_app/api/api_client.dart";
import "package:flutter_fridge_app/data/repository.dart";

class SyncManager {
  final Repo repo;
  SyncManager(this.repo);

  Future<List<ConnectivityResult>> _current() async {
    final r = await Connectivity().checkConnectivity();
    return r;
  }

  Future<bool> _online() async {
    final list = await _current();
    return list.contains(ConnectivityResult.wifi) ||
        list.contains(ConnectivityResult.mobile) ||
        list.contains(ConnectivityResult.ethernet);
  }

  Future<void> syncOnce() async {
    final api = await ApiClient.create();

    final toPush = await repo.unsyncedEvents();
    if (toPush.isNotEmpty) {
      try {
        await api.postEventsBatch(toPush);
        await repo.markEventsSynced(toPush.map((e) => e.id).toList());
      } catch (_) {}
    }

    final since = await repo.lastSync();
    try {
      final items = await api.getItemsSince(since);
      if (items.isNotEmpty) {
        await repo.upsertItems(items);
      }
      await repo.setLastSync(DateTime.now().toUtc());
    } catch (_) {}
  }

  StreamSubscription<dynamic>? _conn;
  StreamSubscription<bool>? _tick;

  void startAutoSync({Duration interval = const Duration(minutes: 5)}) {
    _conn?.cancel();
    _tick?.cancel();

    // Immediate sync on connectivity regain
    _conn = Connectivity().onConnectivityChanged.listen((
      dynamic results,
    ) async {
      final List<ConnectivityResult> list = results is List<ConnectivityResult>
          ? results
          : <ConnectivityResult>[results as ConnectivityResult];
      final ok =
          list.contains(ConnectivityResult.wifi) ||
          list.contains(ConnectivityResult.mobile) ||
          list.contains(ConnectivityResult.ethernet);
      if (!ok) return;
      try {
        await syncOnce();
      } catch (_) {}
    });

    // Periodic sync while online
    _tick = Stream.periodic(interval).asyncMap((_) => _online()).listen((
      ok,
    ) async {
      if (!ok) return;
      try {
        await syncOnce();
      } catch (_) {}
    });
  }

  void stop() {
    _server?.cancel();
    _server = null;
    _conn?.cancel();
    _conn = null;
    _tick?.cancel();
    _tick = null;
  }

  StreamSubscription<bool>? _server;
  void bindServerReachability(Stream<bool> s) {
    _server?.cancel();
    _server = s.listen((ok) async {
      if (ok) {
        try {
          await syncOnce();
        } catch (_) {}
      }
    });
  }
}
