import 'package:flutter/material.dart';
import 'book_search.dart'; // 검색 관련
import 'book_rental.dart'; // 대출/반납 관련

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Autolib',
      theme: ThemeData(
        // primarySwatch: Colors.teal,
      ),
      home: BookSearchScreen(), // BookSearchScreen을 메인 화면으로 설정
    );
  }
}
