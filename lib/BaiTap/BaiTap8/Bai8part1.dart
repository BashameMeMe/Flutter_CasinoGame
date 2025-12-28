import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/BaiTap/BaiTap8/Bai8part2.dart';


const String _apiKey = '07355ed029d84f41b8e63b81e9e74b93';

class NewsList extends StatefulWidget {
  const NewsList({super.key});

  @override
  State<NewsList> createState() => _NewsListState();
}

class _NewsListState extends State<NewsList> {
  final Dio _dio = Dio();
  List<dynamic> _articles = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    fetchArticles();
  }

  Future<void> fetchArticles() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final url = 'https://newsapi.org/v2/top-headlines?country=us&apiKey=$_apiKey';
      final resp = await _dio.get(url);
      final data = resp.data as Map<String, dynamic>?;
      if (data == null || data['status'] != 'ok') {
        setState(() {
          _error = 'API error';
          _loading = false;
        });
        return;
      }
      setState(() {
        _articles = data['articles'] as List<dynamic>;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('News'),
        actions: [
          IconButton(onPressed: fetchArticles, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : ListView.builder(
                  itemCount: _articles.length,
                  itemBuilder: (context, index) {
                    final a = _articles[index] as Map<String, dynamic>;
                    final title = a['title'] ?? '';
                    final description = a['description'] ?? '';
                    final image = a['urlToImage'];
                    return ListTile(
                      leading: image != null
                          ? SizedBox(
                              width: 80,
                              height: 80,
                              child: Image.network(image, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.broken_image)),
                            )
                          : const SizedBox(width: 80, child: Icon(Icons.article)),
                      title: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis),
                      subtitle: Text(description, maxLines: 2, overflow: TextOverflow.ellipsis),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => NewsDetail(article: a)),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
