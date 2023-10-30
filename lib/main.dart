
//
// import 'package:flutter/material.dart';
//
// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: const HomePage(),
//     );
//   }
// }
//
// class HomePage extends StatefulWidget {
//   const HomePage({Key? key}) : super(key: key);
//
//   @override
//   _HomePageState createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage> {
//   static const int _pageSize = 20;
//   int _currentPage = 1;
//   List<String> _data = [];
//
//   bool _isLoading = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchData();
//   }
//
//   Future<void> _fetchData() async {
//     setState(() {
//       _isLoading = true;
//     });
//
//     // Simulated fetching logic
//     await Future.delayed(const Duration(seconds: 2));
//
//     // Generate data for the current page
//     final newData = List<String>.generate(
//       _pageSize,
//           (index) => 'Item ${(index + 1) + (_currentPage - 1) * _pageSize}',
//     );
//
//     setState(() {
//       _data.addAll(newData);
//       _isLoading = false;
//     });
//   }
//
//   void _loadMoreData() {
//     setState(() {
//       _currentPage++;
//     });
//     _fetchData();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Load More Button'),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               itemCount: _data.length,
//               itemBuilder: (context, index) {
//                 return ListTile(
//                   title: Text(_data[index]),
//                 );
//               },
//             ),
//           ),
//           _isLoading
//               ? const Center(
//             child: CircularProgressIndicator(),
//           )
//               : ElevatedButton(
//             onPressed: _loadMoreData,
//             child: const Text('Load More'),
//           ),
//         ],
//       ),
//     );
//   }
// }
//


import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

//pagination in flutter
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pagination Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _baseUrl =
      'https://newsapi.org/v2/top-headlines?country=in&apiKey=33915d29283d41a2b1b377fa984b5f2f';

  int _page = 1;
  final int _pageSize = 5;

  bool _hasNextPage = true;
  bool _isLoading = false;

  List<dynamic> _articles = [];

  Future<void> _fetchArticles() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final url = '$_baseUrl&page=$_page&pageSize=$_pageSize';
      final response = await http.get(Uri.parse(url));
      final responseData = json.decode(response.body);

      setState(() {
        _articles.addAll(responseData['articles']);
        _hasNextPage = (_page < responseData['totalResults'] ~/ _pageSize);
        _page++;
      });
    } catch (error) {
      print('An error occurred: $error');
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchArticles();
  }

  void _loadMoreData() {
    setState(() {
      _page++;
    });
    _fetchArticles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pagination Demo'),
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _articles.length,
              itemBuilder: (ctx, index) {
                final article = _articles[index];
                final title = article['title'] ?? 'No Title';
                final description =
                    article['description'] ?? 'No Description';

                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: article['urlToImage'] != null
                        ? Image.network(
                      article['urlToImage'],
                      width: 120,
                      height: 80,
                      fit: BoxFit.values.last,
                    )
                        : Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey,
                    ),
                    title: Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              },
            ),
          ),
          if (_hasNextPage)
            ElevatedButton(
              onPressed: _loadMoreData,
              child: const Text('Load More'),
            ),
          if(!_hasNextPage)
            Text('No more data')
        ],
      ),
    );
  }
}

