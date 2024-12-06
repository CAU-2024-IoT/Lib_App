import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:iotlibrary/book_rental.dart'; // 책 대출/반납 기능을 위한 import
import 'seat.dart';
import 'book.dart';
import 'BookListScreen.dart';

String apiKey = 'http://175.113.202.160:2028';
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
        Uri.parse('$apiKey/api/v1/books'), // Replace with your API URL
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
