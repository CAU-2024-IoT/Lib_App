import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'book.dart';

String token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjZ9.Vb0IrHYvDaZ2b_YjFFkjnDBbWDnBjaNiQeVTcm_S5wo';
String address = 'http://192.168.1.208:2028';

class BookDetailScreen extends StatefulWidget {
  final Book book;
  final Function(Book) onBookUpdated;  // 책 업데이트 콜백 함수 추가

  BookDetailScreen({required this.book, required this.onBookUpdated});

  @override
  _BookDetailScreenState createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  bool isLoading = false;

  // 대출
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
                Navigator.pop(context); // 창 닫기
              },
              child: Text('확인'),
            ),
          ],
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('$address/api/v1/books/rent'),
        headers: {
          'Authorization': 'bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'bookId': book_id,
          'rentDurationDays': 14,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['resultType'] == 'SUCCESS') {
          final location = responseData['success']['location'];
          final color = responseData['success']['color'];

          setState(() {
            widget.book.status = 'DAEYONG'; // 대출 중 상태로 변경
          });

          // 부모 화면에 상태 업데이트
          widget.onBookUpdated(widget.book);

          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('대출 완료'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Color(int.parse('0xFF${color}')),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text('도서 위치: $location'),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    // 대출 완료 후, location과 bookId를 '/api/v1/books/done'으로 보내기
                    await sendDoneRequest(book_id, location, context);
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
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // 반납
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

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('$address/api/v1/books/return'), // 'done' endpoint used for returning the book
        headers: {
          'Authorization': 'bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'bookId': book_id,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['resultType'] == 'SUCCESS') {
          final location = responseData['success']['location'];
          final color = responseData['success']['color'];

          setState(() {
            widget.book.status = 'BOGAN'; // 대출 가능 상태로 변경
          });

          // 부모 화면에 상태 업데이트
          widget.onBookUpdated(widget.book);

          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('반납 완료'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Color(int.parse('0xFF${color}')),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text('도서 위치: $location'),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    await sendDoneRequest(book_id, location, context);
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
            title: Text('반납 실패'),
            content: Text('도서를 반납할 수 없습니다.\n에러 메시지: ${errorResponse['message'] ?? '알 수 없는 오류'}'),
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
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> sendDoneRequest(int? book_id, String location, BuildContext context) async {
    try {
      final response = await http.post(
        Uri.parse('$address/api/v1/books/done'),
        headers: {
          'Authorization': 'bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'bookId': book_id,
          'location': location,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['resultType'] == 'SUCCESS') {
          print('위치: $location, 책 ID: $book_id 정보 전송 성공');
        }
      }
    } catch (e) {
      print('전송 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.book.title)),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('제목: ${widget.book.title}', style: TextStyle(fontSize: 18)),
                Text('작가: ${widget.book.author}', style: TextStyle(fontSize: 18)),
                Text('장르: ${widget.book.genre}', style: TextStyle(fontSize: 18)),
                Text('출판일: ${widget.book.publishedDate}', style: TextStyle(fontSize: 18)),
                Text('상태: ${widget.book.status == 'BOGAN' ? '대출 가능' : '대출 중'}', style: TextStyle(fontSize: 18)),
                Text('서가 번호: ${widget.book.shelf_id}', style: TextStyle(fontSize: 18)),
                SizedBox(height: 20),
                if (widget.book.status == 'BOGAN')
                  ElevatedButton(
                    onPressed: isLoading ? null : () async {
                      await rentBook(widget.book.book_id, context);
                    },
                    child: Text('대출'),
                  ),
                if (widget.book.status == 'DAEYONG')
                  ElevatedButton(
                    onPressed: isLoading ? null : () async {
                      await returnBook(widget.book.book_id, context);
                    },
                    child: Text('반납'),
                  ),
              ],
            ),
          ),
          if (isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
