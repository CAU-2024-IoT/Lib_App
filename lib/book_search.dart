import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:iotlibrary/book_rental.dart'; // 책 대출/반납 기능을 위한 import
import 'seat.dart';
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
  bool isLoading = false;
  String errorMessage = '';
  List<Book> bookList = [];
  int _selectedIndex = 0; // 선택된 페이지 인덱스

  // API 호출하여 책 검색
  Future<void> searchBooks(String query) async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse('http://192.168.0.52:2028/api/v1/books'), // Replace with your API URL
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['resultType'] == 'SUCCESS') {
          final List<dynamic> books = responseData['success'];
          setState(() {
            bookList = books.map((book) => Book.fromJson(book)).toList();
          });
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

  // 페이지 목록
  final List<Widget> _pages = [
    BookSearchPage(), // 책 검색 페이지
    SeatReservationPage(), // 좌석 예약 페이지
  ];

  // 하단탭 클릭 이벤트
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // 선택된 페이지 표시
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
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
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 200, 20, 0),
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
            TextField(
              decoration: InputDecoration(
                hintText: '책 이름을 입력하세요.',
                suffixIcon: Icon(Icons.search, color: Colors.teal),
                border: OutlineInputBorder(),
              ),
            ),
          ],
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
            onTap: () {
              print('선택한 책의 상태: ${book.status}');  // 상태 출력
              _showBookDetails(context, book);
            },
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

class BookDetailScreen extends StatefulWidget {
  final Book book;

  BookDetailScreen({required this.book});

  @override
  _BookDetailScreenState createState() => _BookDetailScreenState();
}

//--------------------------------------------------------//
class _BookDetailScreenState extends State<BookDetailScreen> {
  // 대출 API 호출
  Future<void> rentBook(int? book_id, BuildContext context) async {
    if (book_id == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('대출 실패'),
          content: Text('책 ID가 유효하지 않습니다.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('확인'),
            ),
          ],
        ),
      );
      return;
    }

    final response = await http.post(
      Uri.parse('http://192.168.0.52:2028/api/v1/books/rent'),
      headers: {
        'Authorization': 'bearer $token', // 실제 JWT 토큰 입력
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'bookId': book_id,
        'rentDurationDays': 14, // 예시로 14일 대출
      }),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['resultType'] == 'SUCCESS') {
        final location = responseData['success']['location'];

        // 대출 성공 후 책 상태를 '대출 중'으로 업데이트
        setState(() {
          widget.book.status = 'DAEYONG'; // 대출 중으로 상태 변경
        });

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('대출 완료'),
            content: Text('도서 위치: $location'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('확인'),
              ),
            ],
          ),
        );
      }
    } else {
      final errorResponse = json.decode(response.body);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('대출 실패'),
          content: Text('도서를 대출할 수 없습니다.\n에러 메시지: ${errorResponse['message'] ?? '알 수 없는 오류'}'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('확인'),
            ),
          ],
        ),
      );
    }
  }

// 반납 API 호출
  Future<void> returnBook(int? book_id, BuildContext context) async {
    if (book_id == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('반납 실패'),
          content: Text('책 ID가 유효하지 않습니다.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('확인'),
            ),
          ],
        ),
      );
      return;
    }

    final response = await http.post(
      Uri.parse('http://192.168.0.52:2028/api/v1/books/return'),
      headers: {
        'Authorization': 'bearer $token',  // 실제 JWT 토큰 입력
        'Content-Type': 'application/json', // JSON 타입으로 보내야 함
      },
      body: json.encode({
        'bookId': book_id,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['resultType'] == 'SUCCESS') {
        final location = responseData['success']['location'];

        // 반납 성공 후 책 상태를 '대출 가능'으로 업데이트
        setState(() {
          widget.book.status = 'BOGAN'; // 대출 가능으로 상태 변경
        });

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('반납 완료'),
            content: Text('도서 위치: $location'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('확인'),
              ),
            ],
          ),
        );
      }
    } else {
      final errorResponse = json.decode(response.body);
      String errorMessage = '알 수 없는 오류';

      // 실패 응답 처리
      if (errorResponse['resultType'] == 'FAIL' && errorResponse['error'] != null) {
        errorMessage = errorResponse['error']['reason'] ?? errorMessage;
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('반납 실패'),
          content: Text('도서를 반납할 수 없습니다.\n에러 메시지: $errorMessage'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('확인'),
            ),
          ],
        ),
      );
    }
  }

  //--------------------------------------------------------//

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.book.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('제목: ${widget.book.title}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('작가: ${widget.book.author}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('장르: ${widget.book.genre}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('출판일: ${widget.book.publishedDate}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('상태: ${widget.book.status == 'BOGAN' ? '대출 가능' : '대출 중'}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('서가 번호: ${widget.book.shelf_id}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            // 대출 버튼
            if (widget.book.status == 'BOGAN')
              ElevatedButton(
                onPressed: () async {
                  await rentBook(widget.book.book_id, context);
                },
                child: Text('대출'),
              ),
            // 반납 버튼
            if (widget.book.status == 'DAEYONG')
              ElevatedButton(
                onPressed: () async {
                  await returnBook(widget.book.book_id, context);
                },
                child: Text('반납'),
              ),
          ],
        ),
      ),
    );
  }
}
class Book {
  final int book_id;
  final String title;
  final String author;
  final String genre;
  final String publishedDate;
  String status;  // 상태를 변경할 수 있도록 String으로 변경
  final int shelf_id;

  Book({
    required this.book_id,
    required this.title,
    required this.author,
    required this.genre,
    required this.publishedDate,
    required this.status,
    required this.shelf_id,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      book_id: json['book_id'] ?? 0,
      title: json['title'] ?? '제목 없음',
      author: json['author'] ?? '작가 없음',
      genre: json['genre'] ?? '장르 없음',
      publishedDate: json['publishedDate'] ?? '출판일 없음',
      status: json['status'] ?? '알 수 없음',
      shelf_id: json['shelf_id'] ?? 0,
    );
  }
}