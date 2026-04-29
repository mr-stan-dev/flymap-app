import 'package:flutter/material.dart';
import 'package:flymap/data/local/app_database.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppVersionFooter extends StatelessWidget {
  const AppVersionFooter({super.key});

  static final Future<PackageInfo> _packageInfoFuture =
      PackageInfo.fromPlatform();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    return FutureBuilder<PackageInfo>(
      future: _packageInfoFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(height: 8);
        }

        final packageInfo = snapshot.data!;
        final version = packageInfo.version.trim();
        final label = 'Version $version';
        final withDb = '$label • db v${AppDatabase.schemaVersion}';

        return Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 8),
          child: Center(
            child: Text(
              withDb,
              style: theme.textTheme.bodySmall?.copyWith(color: muted),
            ),
          ),
        );
      },
    );
  }
}
