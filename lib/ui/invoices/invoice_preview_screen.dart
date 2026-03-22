import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../config/theme/app_colors.dart';
import 'models/invoice_preview_args.dart';

class InvoicePreviewScreen extends StatefulWidget {
  final InvoicePreviewArgs? args;

  const InvoicePreviewScreen({super.key, this.args});

  @override
  State<InvoicePreviewScreen> createState() => _InvoicePreviewScreenState();
}

class _InvoicePreviewScreenState extends State<InvoicePreviewScreen> {
  WebViewController? _controller;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    // WebView not fully supported on web platform
    if (kIsWeb) {
      setState(() {
        _loading = false;
        // Web will use HtmlElementView or show HTML directly
      });
      return;
    }

    try {
      _controller = WebViewController()
        ..setBackgroundColor(Colors.white)
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageFinished: (_) {
              if (mounted) {
                setState(() => _loading = false);
              }
            },
            onWebResourceError: (error) {
              if (mounted) {
                setState(() {
                  _loading = false;
                  _error = 'Failed to load preview: ${error.description}';
                });
              }
            },
          ),
        );

      _loadContent();
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'WebView not available: $e';
      });
    }
  }

  void _loadContent() {
    if (_controller == null) return;

    if (widget.args?.url != null) {
      final rawUrl = widget.args!.url!;
      final isPdf = rawUrl.toLowerCase().endsWith('.pdf');

      if (isPdf) {
        // For PDFs, use Google Docs viewer for public URLs
        // For private URLs, show a message to download
        if (rawUrl.startsWith('http://') || rawUrl.startsWith('https://')) {
          final viewerUrl = Uri.parse(
            'https://docs.google.com/gview?embedded=true&url=${Uri.encodeComponent(rawUrl)}',
          );
          _controller!.loadRequest(viewerUrl);
        } else {
          setState(() {
            _loading = false;
            _error = 'PDF preview is not available for local files';
          });
        }
      } else {
        _controller!.loadRequest(Uri.parse(rawUrl));
      }
    } else if (widget.args?.html != null) {
      _controller!.loadHtmlString(_wrapHtml(widget.args!.html!));
    } else {
      _controller!.loadHtmlString(_wrapHtml('<p>No preview available.</p>'));
    }
  }

  String _wrapHtml(String content) {
    // Wrap HTML content with proper styling for mobile
    if (content.contains('<html') || content.contains('<!DOCTYPE')) {
      return content;
    }
    return '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0">
  <style>
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      padding: 16px;
      margin: 0;
      font-size: 14px;
      line-height: 1.5;
    }
  </style>
</head>
<body>
$content
</body>
</html>
''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.args?.title ?? 'Preview')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.danger),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.slate500),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _error = null;
                    _loading = true;
                  });
                  _initController();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // For web, show HTML content directly
    if (kIsWeb) {
      return _buildWebPreview();
    }

    // For native platforms, use WebView
    return Stack(
      children: [
        if (_controller != null) WebViewWidget(controller: _controller!),
        if (_loading)
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(),
          ),
      ],
    );
  }

  Widget _buildWebPreview() {
    final html = widget.args?.html;

    // For web with HTML content, show a success message
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.receipt_long, color: AppColors.primary500, size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.args?.title ?? 'Invoice Preview',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            const Text(
                              'Preview generated successfully',
                              style: TextStyle(color: AppColors.slate500, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  if (html != null && html.isNotEmpty) ...[
                    const Text(
                      'The invoice preview has been generated. On web browsers, full HTML preview is limited.',
                      style: TextStyle(color: AppColors.slate500),
                    ),
                    const SizedBox(height: 16),
                    // Show a simplified view
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF86EFAC)),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.check_circle, color: Color(0xFF22C55E), size: 48),
                          SizedBox(height: 8),
                          Text(
                            'Invoice Ready',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Your invoice preview has been generated.\nUse the mobile app for full preview.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.slate500, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    const Center(
                      child: Text(
                        'No preview content available.',
                        style: TextStyle(color: AppColors.slate400),
                      ),
                    ),
                  ],
                  if (widget.args?.url != null) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final url = Uri.parse(widget.args!.url!);
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url, mode: LaunchMode.externalApplication);
                          }
                        },
                        icon: const Icon(Icons.open_in_new),
                        label: const Text('Open in Browser'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
