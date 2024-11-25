import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'book_rental.dart'; // book_rental.dart를 import

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
  bool isLoading = false;
  String errorMessage = '';

  // API 호출하여 책 검색
  Future<void> searchBooks(String query) async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse('http://175.113.202.160:2028/api/v1/books'), // Replace with your API URL
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['resultType'] == 'SUCCESS') {
          final List<dynamic> books = responseData['success'];
          final bookList = books.map((book) => Book.fromJson(book)).toList();

          // 검색 결과를 새로운 페이지로 전달
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookListScreen(bookList: bookList),
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
    return Scaffold(
      appBar: AppBar(title: Text('Autolib')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 180, 20, 0),
          child: Column(
            children: [
              Text(
                'Autolib',
                style: TextStyle(fontSize: 40, color: Color.fromRGBO(123, 185, 114, 1.0)),
              ),
              SizedBox(height: 20),
              Image.asset(
                'assets/book_icon.png',
                height: 150,
                width: 150,
              ),
              SizedBox(height: 20),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: '책 이름을 입력하세요.',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search, color: Colors.teal),
                    onPressed: () => searchBooks(_searchController.text),
                  ),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              if (isLoading) CircularProgressIndicator(),
              if (errorMessage.isNotEmpty)
                Text(
                  errorMessage,
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class BookListScreen extends StatelessWidget {
  final List<Book> bookList;

  BookListScreen({required this.bookList});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('검색 결과')),
      body: ListView.builder(
        itemCount: bookList.length,
        itemBuilder: (context, index) {
          final book = bookList[index];
          return ListTile(
            title: Text(book.title),
            subtitle: Text(book.author),
            trailing: Text(book.status == 'BOGAN' ? '대출 가능' : '대출 중'),
            onTap: () => _showBookDetails(context, book),
          );
        },
      ),
    );
  }

  void _showBookDetails(BuildContext context, Book book) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookDetailScreen(book: book),
      ),
    );
  }
}

class BookDetailScreen extends StatelessWidget {
  final Book book;

  BookDetailScreen({required this.book});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(book.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('제목: ${book.title}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('작가: ${book.author}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('장르: ${book.genre}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('출판일: ${book.publishedDate}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('상태: ${book.status == 'BOGAN' ? '대출 가능' : '대출 중'}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('서가 번호: ${book.shelfId}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            // 대출 버튼
            if (book.status == 'BOGAN')
              ElevatedButton(
                onPressed: () => rentBook(book.bookId, context),  // book_rental.dart에서 대출 호출
                child: Text('대출'),
              ),
            // 반납 버튼
            if (book.status == '대출 중')
              ElevatedButton(
                onPressed: () => returnBook(book.bookId, context),  // book_rental.dart에서 반납 호출
                child: Text('반납'),
              ),
          ],
        ),
      ),
    );
  }
}

// Book 데이터 모델
class Book {
  final int bookId;
  final String title;
  final String author;
  final String genre;
  final String publishedDate;
  final String status;
  final int shelfId;

  Book({
    required this.bookId,
    required this.title,
    required this.author,
    required this.genre,
    required this.publishedDate,
    required this.status,
    required this.shelfId,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      bookId: json['bookId'],
      title: json['title'],
      author: json['author'],
      genre: json['genre'],
      publishedDate: json['publishedDate'],
      status: json['status'],
      shelfId: json['shelfId'],
    );
  }
}
