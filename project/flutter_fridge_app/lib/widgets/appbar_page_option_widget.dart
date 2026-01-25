import "package:flutter/material.dart";
import "package:flutter_fridge_app/models/enums.dart";
import "package:flutter_fridge_app/pages/settings.dart";
import "package:flutter_fridge_app/l10n/generated/app_localizations.dart";

class AppBarPageOptionWidget extends StatelessWidget {
  const AppBarPageOptionWidget({super.key, required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<AppBarPageOptions>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) {
        switch (value) {
          case AppBarPageOptions.settings:
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const SettingsPage()));
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: AppBarPageOptions.settings,
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.only(right: 6),
                child: Icon(Icons.settings_outlined),
              ),
              Text(l10n.settings),
            ],
          ),
        ),
      ],
    );
  }
}
