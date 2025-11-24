import "package:flutter/material.dart";

/// Generic card used across the app:
/// - title (required)
/// - optional subtitle
/// - optional numeric count shown on the right
/// - optional tap handler
class StatCard extends StatelessWidget {
  final String title;
  final int? count;
  final String? subtitle;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.title,
    this.count,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle!) : null,
        trailing: count != null
            ? Text(
                "$count",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}
