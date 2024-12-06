import 'package:flutter/material.dart';
import 'book.dart';  // Book 클래스를 임포트
import 'package:http/http.dart' as http;  // http 패키지 임포트
import 'dart:convert';  // JSON을 다루기 위한 패키지
import 'book_rental.dart';

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



