import 'package:flutter/material.dart';
import 'book.dart';  // Book 클래스를 임포트
import 'book_rental.dart';
class BookListScreen extends StatefulWidget {
  final List<Book> bookList;  // 책 리스트
  final Function(Book) onBookUpdated;  // 책 정보 업데이트 함수

  // BookListScreen의 생성자에서 bookList와 onBookUpdated를 받음
  BookListScreen({required this.bookList, required this.onBookUpdated});

  @override
  _BookListScreenState createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('책 목록')),
      body: ListView.builder(
        itemCount: widget.bookList.length,
        itemBuilder: (context, index) {
          final book = widget.bookList[index];
          return ListTile(
            title: Text(book.title),
            subtitle: Text(book.author),
            trailing: Text(book.status == 'BOGAN' ? '대출 가능' : '대출 중'),
            onTap: () {
              // 책을 탭하면 책 수정 화면으로 이동 (book_rental.dart에서 수정 화면을 처리)
              _showBookRental(context, book);
            },
          );
        },
      ),
    );
  }

  void _showBookRental(BuildContext context, Book book) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookDetailScreen(
          book: book,
          onBookUpdated: widget.onBookUpdated,  // book_rental.dart에서 수정된 책 정보를 업데이트
        ),
      ),
    );
  }
}
