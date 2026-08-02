import 'package:flutter/material.dart';
import 'dart:io';
import '../services/recent_files_service.dart';

class RecentFilesList extends StatelessWidget {
  final List<String> files;
  final ValueChanged<String> onFileTap;
  final VoidCallback onFilesChanged;

  const RecentFilesList({
    super.key,
    required this.files,
    required this.onFileTap,
    required this.onFilesChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: files.map((path) {
        final name = path.split(Platform.pathSeparator).last;
        final dir = path.split(Platform.pathSeparator)
          ..removeLast();
        final dirPath = dir.join(Platform.pathSeparator);
        final exists = File(path).existsSync();

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Icon(
              Icons.description_outlined,
              color: exists
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outline,
            ),
            title: Text(
              name,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: exists ? null : Theme.of(context).colorScheme.outline,
              ),
            ),
            subtitle: Text(
              dirPath,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!exists)
                  Tooltip(
                    message: 'File not found',
                    child: Icon(
                      Icons.warning_amber_outlined,
                      size: 16,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  tooltip: 'Remove from recent',
                  onPressed: () async {
                    await RecentFilesService.removeRecentFile(path);
                    onFilesChanged();
                  },
                ),
              ],
            ),
            onTap: exists ? () => onFileTap(path) : null,
          ),
        );
      }).toList(),
    );
  }
}
