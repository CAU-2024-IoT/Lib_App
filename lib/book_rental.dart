import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
String token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjZ9.Vb0IrHYvDaZ2b_YjFFkjnDBbWDnBjaNiQeVTcm_S5wo';
String address = "http://192.168.1.208:2028/";

// 대출 API 호출
Future<void> rentBook(int book_id, BuildContext context) async {
  final response = await http.post(
    Uri.parse('http://192.168.1.208:2028/api/v1/books/rent'),
    headers: {
      'Authorization': 'bearer $token', // 여기에 실제 JWT 토큰을 입력해야 합니다
      'Content-Type': 'application/json',
    },
    body: json.encode({
      'bookId': book_id,
      'rentDurationDays':14, // 예시로 14일 대출
    }),
  );
  print("book id: $book_id");
  print('body ===== ${response.body}');
  print("Response status: ${response.statusCode}");
  print("Response body: ${response.body}");

  if (response.statusCode == 200) {
    final responseData = json.decode(response.body);
    if (responseData['resultType'] == 'SUCCESS') {
      final location = responseData['success']['location'];
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
    print("Error response: $errorResponse");

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
Future<void> returnBook(int book_id, BuildContext context) async {
  final response = await http.post(
    Uri.parse('http://192.168.1.208:2028/api/v1/books/return'),
    headers: {
      'Authorization': 'bearer $token',  // 여기에 실제 JWT 토큰을 입력해야 합니다
    },
    body: json.encode({
      'bookId': book_id,
    }),
  );

  if (response.statusCode == 200) {
    final responseData = json.decode(response.body);
    if (responseData['resultType'] == 'SUCCESS') {
      final location = responseData['success']['location'];
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('반납 실패'),
        content: Text('도서를 반납할 수 없습니다.'),
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
