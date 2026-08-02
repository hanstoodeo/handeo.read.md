import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../widgets/markdown_viewer.dart';
import '../widgets/recent_files_list.dart';
import '../services/recent_files_service.dart';

class HomeScreen extends StatefulWidget {
  final bool isDark;
  final ValueChanged<bool> onThemeToggle;

  const HomeScreen({
    super.key,
    required this.isDark,
    required this.onThemeToggle,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _filePath;
  String? _fileName;
  String _markdownContent = '';
  List<String> _recentFiles = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRecentFiles();
  }

  Future<void> _loadRecentFiles() async {
    final files = await RecentFilesService.getRecentFiles();
    setState(() => _recentFiles = files);
  }

  Future<void> _pickFile() async {
    setState(() => _isLoading = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['md', 'markdown', 'txt'],
      );

      if (result != null && result.files.single.path != null) {
        final path = result.files.single.path!;
        await _openFile(path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking file: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _openFile(String path) async {
    try {
      final file = File(path);
      final content = await file.readAsString();
      final name = path.split(Platform.pathSeparator).last;

      await RecentFilesService.addRecentFile(path);
      final updated = await RecentFilesService.getRecentFiles();

      setState(() {
        _filePath = path;
        _fileName = name;
        _markdownContent = content;
        _recentFiles = updated;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open file: $e')),
        );
      }
    }
  }

  void _closeFile() {
    setState(() {
      _filePath = null;
      _fileName = null;
      _markdownContent = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasFile = _filePath != null;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.article_outlined, size: 22),
            const SizedBox(width: 8),
            Text(
              hasFile ? (_fileName ?? 'Handeo Read MD') : 'Handeo Read MD',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          // Dark mode toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                const Icon(Icons.light_mode, size: 18),
                Switch(
                  value: widget.isDark,
                  onChanged: widget.onThemeToggle,
                ),
                const Icon(Icons.dark_mode, size: 18),
              ],
            ),
          ),
          if (hasFile)
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Close file',
              onPressed: _closeFile,
            ),
          IconButton(
            icon: const Icon(Icons.folder_open_outlined),
            tooltip: 'Open file',
            onPressed: _isLoading ? null : _pickFile,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: hasFile
          ? MarkdownViewer(content: _markdownContent, filePath: _filePath!)
          : _buildWelcomeScreen(),
    );
  }

  Widget _buildWelcomeScreen() {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.description_outlined,
                      size: 72,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Handeo Read MD',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Open any Markdown file to preview it beautifully.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: _isLoading ? null : _pickFile,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.folder_open_outlined),
                      label: Text(_isLoading ? 'Opening...' : 'Open a .md file'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Recent files
          if (_recentFiles.isNotEmpty) ...[
            const SizedBox(height: 32),
            Text(
              'Recent Files',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            RecentFilesList(
              files: _recentFiles,
              onFileTap: _openFile,
              onFilesChanged: _loadRecentFiles,
            ),
          ],
          // Feature hints
          const SizedBox(height: 32),
          Text(
            'Features',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildFeatureGrid(theme),
        ],
      ),
    );
  }

  Widget _buildFeatureGrid(ThemeData theme) {
    final features = [
      (Icons.format_bold, 'Rich Formatting', 'Headers, bold, italic, lists'),
      (Icons.code, 'Code Highlighting', 'Syntax highlighted code blocks'),
      (Icons.link, 'Clickable Links', 'Tap links to open in browser'),
      (Icons.table_chart_outlined, 'Tables', 'Rendered Markdown tables'),
      (Icons.dark_mode_outlined, 'Dark Mode', 'Easy on the eyes at night'),
      (Icons.history, 'Recent Files', 'Quick access to past files'),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220,
        mainAxisExtent: 100,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: features.length,
      itemBuilder: (context, i) {
        final (icon, title, subtitle) = features[i];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary, size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(title,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text(subtitle,
                          style: theme.textTheme.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
