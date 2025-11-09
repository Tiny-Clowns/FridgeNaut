import "dart:async";
import "package:connectivity_plus/connectivity_plus.dart";
import "package:flutter_fridge_app/api/api_client.dart";
import "package:flutter_fridge_app/data/repository.dart";

class SyncManager {
  final Repo repo;
  SyncManager(this.repo);

  Future<void> syncOnce() async {
    final api = await ApiClient.create();

    // Push local events
    final toPush = await repo.unsyncedEvents();
    if (toPush.isNotEmpty) {
      await api.postEventsBatch(toPush);
      await repo.markEventsSynced(toPush.map((e) => e.id).toList());
    }

    // Pull items since last sync
    final since = await repo.lastSync();
    final items = await api.getItemsSince(since);
    if (items.isNotEmpty) {
      await repo.upsertItems(items);
    }

    await repo.setLastSync(DateTime.now().toUtc());
  }

  StreamSubscription? _sub;
  void startAutoSync({Duration interval = const Duration(minutes: 5)}) {
    _sub?.cancel();
    _sub = Stream.periodic(interval).listen((_) async {
      final c = await Connectivity().checkConnectivity();
      if (c.contains(ConnectivityResult.wifi) ||
          c.contains(ConnectivityResult.mobile)) {
        try {
          await syncOnce();
        } catch (_) {
          /* ignore transient */
        }
      }
    });
  }

  void stop() {
    _sub?.cancel();
    _sub = null;
  }
}
