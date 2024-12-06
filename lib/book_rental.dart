import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'book.dart';
String token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjZ9.Vb0IrHYvDaZ2b_YjFFkjnDBbWDnBjaNiQeVTcm_S5wo';
//String address = "http://192.168.1.208:2028/";
String address = 'http://175.113.202.160:2028';
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
      Uri.parse('$address/api/v1/books/rent'),
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

    bool returnSuccess = false; // 반납 성공 여부 플래그

    while (!returnSuccess) {
      // 항상 대화상자를 띄운 상태로 유지
      await showDialog(
        context: context,
        barrierDismissible: false, // 사용자가 닫을 수 없도록 설정
        builder: (context) => AlertDialog(
          title: Text('반납 진행 중'),
          content: Text('반납하지 않았습니다. 반납 중입니다...'),
        ),
      );

      // API 호출
      final response = await http.post(
        Uri.parse('$address/api/v1/books/return'),
        headers: {
          'Authorization': 'bearer $token', // 실제 JWT 토큰 입력
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

          // 성공 플래그 업데이트 및 완료 메시지 표시
          returnSuccess = true;
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
        // 실패 시 에러 메시지 표시
        final errorResponse = json.decode(response.body);
        String errorMessage = '알 수 없는 오류';

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