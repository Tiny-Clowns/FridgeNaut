import "dart:async";
import "package:dio/dio.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_fridge_app/api/api_client.dart";

// Emits true when the backend answers GET /health with 200.
class ReachabilityService {
  final _controller = StreamController<bool>.broadcast();
  Stream<bool> get stream => _controller.stream;

  Timer? _timer;
  bool _last = true;

  void start({Duration interval = const Duration(seconds: 20)}) {
    _timer?.cancel();
    _probe(); // immediate
    _timer = Timer.periodic(interval, (_) => _probe());
  }

  Future<void> _probe() async {
    bool ok;
    try {
      final api = await ApiClient.create();
      final r = await api.dio.get(
        "/health",
        options: Options(receiveTimeout: const Duration(seconds: 3)),
      );
      ok = r.statusCode == 200;
    } catch (_) {
      ok = false;
    }
    if (ok != _last) {
      _last = ok;
      _controller.add(ok);
    }
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _controller.close();
  }
}

// Riverpod providers
final reachabilityProvider = Provider<ReachabilityService>((ref) {
  final svc = ReachabilityService();
  svc.start();
  ref.onDispose(svc.stop);
  return svc;
});

final reachabilityStreamProvider = StreamProvider<bool>((ref) {
  return ref.watch(reachabilityProvider).stream;
});
