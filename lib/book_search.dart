// book_search.dart
import 'package:flutter/material.dart';
import 'book_rental.dart'; // 대출/반납 기능을 위한 import

class BookSearchScreen extends StatefulWidget {
  @override
  _BookSearchScreenState createState() => _BookSearchScreenState();
}

class _BookSearchScreenState extends State<BookSearchScreen> {
  TextEditingController _searchController = TextEditingController();
  List<Book> bookList = []; // 검색 결과가 저장될 리스트

  void searchBooks(String query) {
    // 검색 로직을 여기에 구현합니다.
    // 예시로 더미 데이터로 검색 결과를 설정
    bookList = [
      Book(
        title: '책 1',
        author: '저자 1',
        publicationInfo: '출판사 1',
        callNumber: '123',
        isbn: '123456789',
        availability: '대출 가능',
        copies: [
          Copy(location: '도서관 1', callNumber: '123', status: '대출 가능'),
        ],
      ),
      Book(
        title: '책 2',
        author: '저자 2',
        publicationInfo: '출판사 2',
        callNumber: '456',
        isbn: '987654321',
        availability: '대출 불가',
        copies: [
          Copy(location: '도서관 2', callNumber: '456', status: '대출 불가'),
        ],
      ),
    ];
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('도서 검색'),
        backgroundColor: Color.fromRGBO(123, 185, 114, 1.0), // 색상 설정
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 앱 제목
              Text(
                'Autolib',
                style: TextStyle(
                  fontSize: 50,
                  color: Color.fromRGBO(123, 185, 114, 1.0), // 색상 설정
                ),
              ),
              // 이미지
              Image.asset(
                'assets/book_icon.png', // 이미지 경로 설정
                height: 100,
                width: 100,
              ),
              SizedBox(height: 20),
              // 검색창
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: '검색어를 입력해주세요.',
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromRGBO(123, 185, 114, 1.0), // 색상 설정
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromRGBO(123, 185, 114, 1.0), // 색상 설정
                      ),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () {
                        searchBooks(_searchController.text);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SearchResultScreen(bookList: bookList),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              if (bookList.isEmpty)
                Text(
                  "검색 결과가 없습니다.",
                  style: TextStyle(fontSize: 20, color: Color.fromRGBO(123, 185, 114, 1.0)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class SearchResultScreen extends StatelessWidget {
  final List<Book> bookList;

  SearchResultScreen({required this.bookList});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('검색 결과'),
        backgroundColor: Color.fromRGBO(123, 185, 114, 1.0), // 색상 설정
      ),
      body: ListView.builder(
        itemCount: bookList.length,
        itemBuilder: (context, index) {
          final book = bookList[index];
          return ListTile(
            title: Text(book.title),
            subtitle: Text(book.author),
            trailing: Text(book.availability),
            onTap: () => showBookDetailPopup(context, book),
          );
        },
      ),
    );
  }

  void showBookDetailPopup(BuildContext context, Book book) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(book.title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('저자: ${book.author}'),
              Text('발행사항: ${book.publicationInfo}'),
              Text('청구기호: ${book.callNumber}'),
              Text('ISBN: ${book.isbn}'),
              ...book.copies.map((copy) => ListTile(
                title: Text(copy.location),
                subtitle: Text(copy.callNumber),
                trailing: Text(copy.status),
              )),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('닫기'),
            ),
          ],
        );
      },
    );
  }
}

class Book {
  final String title;
  final String author;
  final String publicationInfo;
  final String callNumber;
  final String isbn;
  String availability;
  final List<Copy> copies;

  Book({
    required this.title,
    required this.author,
    required this.publicationInfo,
    required this.callNumber,
    required this.isbn,
    required this.availability,
    required this.copies,
  });
}

class Copy {
  final String location;
  final String callNumber;
  String status;

  Copy({
    required this.location,
    required this.callNumber,
    required this.status,
  });
}
