import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_fridge_app/services/reachability.dart";

class ServerReachabilityBanner extends ConsumerWidget
    implements PreferredSizeWidget {
  const ServerReachabilityBanner({super.key});
  @override
  Size get preferredSize => const Size.fromHeight(24);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reachabilityStreamProvider);
    return state.when(
      data: (online) => online
          ? const SizedBox.shrink()
          : Container(
              height: preferredSize.height,
              alignment: Alignment.center,
              color: Colors.redAccent,
              child: const Text(
                "Server unreachable",
                style: TextStyle(color: Colors.white),
              ),
            ),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
