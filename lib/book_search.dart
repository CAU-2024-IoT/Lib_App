import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:iotlibrary/book_rental.dart'; // 책 대출/반납 기능을 위한 import
import 'seat.dart';
import 'book.dart';
import 'BookListScreen.dart';

// API 및 토큰
String apiKey = 'http://192.168.1.208:2028';
String token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjZ9.Vb0IrHYvDaZ2b_YjFFkjnDBbWDnBjaNiQeVTcm_S5wo';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Autolib',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: BookSearchScreen(),
    );
  }
}

class BookSearchScreen extends StatefulWidget {
  @override
  _BookSearchScreenState createState() => _BookSearchScreenState();
}

class _BookSearchScreenState extends State<BookSearchScreen> {
  TextEditingController _searchController = TextEditingController();
  bool isLoading = false; // Explicit initialization to avoid null errors
  String errorMessage = '';
  List<Book> bookList = [];
  int _selectedIndex = 0;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      BookSearchPage(
        onSearch: (query) => searchBooks(query),
        isLoading: isLoading, // Pass isLoading state
      ),
      SeatReservationPage(),
    ];
  }

  // Update isLoading in setState to ensure it's always passed correctly
  Future<void> searchBooks(String query) async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse('$apiKey/api/v1/books'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['resultType'] == 'SUCCESS') {
          final List<dynamic> books = responseData['success'];
          setState(() {
            bookList = books.map((book) => Book.fromJson(book)).toList();
          });
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookListScreen(
                bookList: bookList,
                onBookUpdated: (updatedBook) {
                  setState(() {
                    // Update the book list with the updated book
                    final index = bookList.indexWhere((book) => book.book_id == updatedBook.book_id);
                    if (index != -1) {
                      bookList[index] = updatedBook;
                    }
                  });
                },
              ),
            ),
          );
        } else {
          setState(() {
            errorMessage = responseData['error']['reason'] ?? '검색 실패';
          });
        }
      } else {
        setState(() {
          errorMessage = '네트워크 오류: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = '오류 발생: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild pages to update isLoading state
    _pages[0] = BookSearchPage(
      onSearch: (query) => searchBooks(query),
      isLoading: isLoading,
    );

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: '책 검색',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chair),
            label: '좌석 검색',
          ),
        ],
      ),
    );
  }
}

class BookSearchPage extends StatelessWidget {
  final Function(String) onSearch;
  final bool isLoading;

  BookSearchPage({required this.onSearch, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    TextEditingController _searchController = TextEditingController();

    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(25, 250, 20, 0),
        child: Column(
          children: [
            Text(
              'Autolib',
              style: TextStyle(fontSize: 80, color: Color.fromRGBO(123, 185, 114, 1.0)),
            ),
            SizedBox(height: 20),
            Image.asset(
              'assets/book_icon.png',
              height: 200,
              width: 200,
            ),
            SizedBox(height: 20),
            if (isLoading)
              CircularProgressIndicator(), // Show loading indicator
            SizedBox(height: 20),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '책 이름을 입력하세요.',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search, color: Colors.teal),
                  onPressed: () {
                    onSearch(_searchController.text);
                  },
                ),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
