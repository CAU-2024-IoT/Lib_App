import 'package:flutter/material.dart';
import 'book.dart';  // Book 클래스를 임포트
import 'bookListscreen.dart'; // BookListScreen 임포트

class BookSearchScreen extends StatefulWidget {
  @override
  _BookSearchScreenState createState() => _BookSearchScreenState();
}

class _BookSearchScreenState extends State<BookSearchScreen> {
  TextEditingController _searchController = TextEditingController();

  List<Book> allBooks = [
    Book(
      title: '책 1',
      author: '저자 1',
      publicationInfo: '출판사 1',
      callNumber: '123',
      isbn: '123456789',
      availability: '대출 가능',
    ),
    Book(
      title: '책 2',
      author: '저자 2',
      publicationInfo: '출판사 2',
      callNumber: '456',
      isbn: '987654321',
      availability: '대출 불가',
    ),
    // 다른 책 추가...
  ];

  String errorMessage = '';

  // 책 검색 기능
  void searchBooks(String query) {
    setState(() {
      final bookList = allBooks
          .where((book) => book.title.toLowerCase().contains(query.toLowerCase()))
          .toList();

      // 검색된 책이 있을 때만 화면을 변경하도록 처리
      if (bookList.isEmpty) {
        errorMessage = '검색한 책이 없습니다.';
      } else {
        errorMessage = '';
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookListScreen(bookList: bookList),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Autolib'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 180, 0, 0),
          child: Column(
            children: [
              // 앱 제목과 이미지 추가
              Text(
                'Autolib',
                style: TextStyle(fontSize: 40, color: Color.fromRGBO(123, 185, 114, 1.0)),
              ),
              SizedBox(height: 20),  // 이미지와 제목 간격 설정
              Image.asset(
                'assets/book_icon.png', // 이미지 경로 설정
                height: 150,  // 이미지 크기 수정
                width: 150,   // 이미지 크기 수정
              ),
              SizedBox(height: 20),  // 이미지와 검색창 간격 설정
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: '책 이름을 입력하세요.',
                    hintStyle: TextStyle(color: Colors.black54),
                    filled: true,
                    fillColor: Colors.white,
                    suffixIcon: IconButton(
                      icon: Icon(Icons.search, color: Colors.teal),
                      onPressed: () {
                        searchBooks(_searchController.text);
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              // 검색된 책 리스트 출력
              if (errorMessage.isNotEmpty)
                Text(
                  errorMessage,
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
