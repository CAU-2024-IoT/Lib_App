import 'package:flutter/material.dart';
import 'book.dart';  // Book 클래스를 임포트
import 'package:http/http.dart' as http;  // http 패키지 임포트
import 'dart:convert';  // JSON을 다루기 위한 패키지

class BookListScreen extends StatelessWidget {
  final List<Book> bookList;

  BookListScreen({required this.bookList});

  // 책 상세 정보를 API에서 가져오는 함수
  Future<Map<String, dynamic>> fetchBookDetails(String isbn) async {
    final response = await http.get(Uri.parse('http://175.113.202.160:2028/api/v1/book/$isbn'));

    if (response.statusCode == 200) {
      // 서버에서 책 정보 받아옴
      return json.decode(response.body);
    } else {
      // API 호출이 실패한 경우
      throw Exception('책 정보를 가져오는 데 실패했습니다.');
    }
  }

  // 팝업창에 책 정보를 표시하는 함수
  void showBookDetails(BuildContext context, String isbn) async {
    try {
      // API에서 책 상세 정보 가져오기
      final bookDetails = await fetchBookDetails(isbn);
      // 팝업창으로 책 정보 표시
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(bookDetails['title']),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('저자: ${bookDetails['author']}'),
              Text('출판사: ${bookDetails['publisher']}'),
              Text('ISBN: ${bookDetails['isbn']}'),
              Text('대출 가능 여부: ${bookDetails['availability']}'),
              // 필요한 추가 정보를 여기에 추가
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('닫기'),
            ),
          ],
        ),
      );
    } catch (e) {
      // 오류가 발생했을 때
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('오류'),
          content: Text('책 정보를 불러오는 데 문제가 발생했습니다.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('닫기'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('검색된 책 목록'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: bookList.length,
          itemBuilder: (context, index) {
            final book = bookList[index];
            return ListTile(
              leading: Icon(Icons.book, color: Colors.teal), // 아이콘 추가
              title: Text(book.title),
              subtitle: Text(book.author),
              trailing: Text(book.availability), // 대출 가능 여부 표시
              onTap: () {
                // 책을 클릭하면 BookListScreen에서 상세 정보 팝업
                showBookDetails(context, book.isbn);
              },
            );
          },
        ),
      ),
    );
  }
}
