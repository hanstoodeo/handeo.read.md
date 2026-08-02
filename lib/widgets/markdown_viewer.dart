import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:url_launcher/url_launcher.dart';

class MarkdownViewer extends StatelessWidget {
  final String content;
  final String filePath;

  const MarkdownViewer({
    super.key,
    required this.content,
    required this.filePath,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final codeTheme = isDark ? monokaiSublimeTheme : githubTheme;

    return Markdown(
      data: content,
      selectable: true,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      extensionSet: md.ExtensionSet(
        md.ExtensionSet.gitHubFlavored.blockSyntaxes,
        <md.InlineSyntax>[
          md.EmojiSyntax(),
          ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes,
        ],
      ),
      builders: {
        'code': CodeElementBuilder(codeTheme: codeTheme),
      },
      onTapLink: (text, href, title) async {
        if (href != null) {
          final uri = Uri.tryParse(href);
          if (uri != null && await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        }
      },
      styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
        h1: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
        h2: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
        h3: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
        blockquoteDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(4),
          border: Border(
            left: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 4,
            ),
          ),
        ),
        codeblockDecoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E2E) : const Color(0xFFF6F8FA),
          borderRadius: BorderRadius.circular(8),
        ),
        horizontalRuleDecoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Theme.of(context).dividerColor,
              width: 1,
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom code block builder with syntax highlighting
class CodeElementBuilder extends MarkdownElementBuilder {
  final Map<String, TextStyle> codeTheme;

  CodeElementBuilder({required this.codeTheme});

  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    dynamic element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    final String rawCode = element.textContent;
    final String language =
        element.attributes['class']?.replaceFirst('language-', '') ?? '';

    if (language.isEmpty) {
      // Inline code
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          rawCode,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 13,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: codeTheme['root']?.backgroundColor ??
            (Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF1E1E2E)
                : const Color(0xFFF6F8FA)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (language.isNotEmpty)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Text(
                language,
                style: TextStyle(
                  fontSize: 11,
                  fontFamily: 'monospace',
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
            child: Text(
              rawCode,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                color: codeTheme['root']?.color ??
                    Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
