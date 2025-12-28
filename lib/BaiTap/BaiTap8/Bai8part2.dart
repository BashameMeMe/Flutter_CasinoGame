import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

class NewsDetail extends StatelessWidget {
  final Map<String, dynamic> article;
  const NewsDetail({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final title = article['title'] ?? '';
    final image = article['urlToImage'];
    final content = article['content'] ?? article['description'] ?? '';
    final author = article['author'] ?? '';
    final publishedAt = article['publishedAt'] ?? '';
    final url = article['url'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Article'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (image != null) ...[
              SizedBox(
                width: double.infinity,
                height: 200,
                child: Image.network(image, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.broken_image, size: 64)),
              ),
              const SizedBox(height: 12),
            ],
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            if (author.isNotEmpty) Text('By $author', style: const TextStyle(fontStyle: FontStyle.italic)),
            if (publishedAt.isNotEmpty) Text(publishedAt, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),
            Text(content, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            if (url.isNotEmpty)
              ElevatedButton.icon(
                onPressed: () async {
                  if (await canLaunchUrlString(url)) {
                    await launchUrlString(url, mode: LaunchMode.externalApplication);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open link')));
                  }
                },
                icon: const Icon(Icons.open_in_browser),
                label: const Text('Open original article'),
              ),
          ],
        ),
      ),
    );
  }
}
