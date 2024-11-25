import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

// 대출 API 호출
Future<void> rentBook(int bookId, BuildContext context) async {
  final response = await http.post(
    Uri.parse('http://175.113.202.160:2028/api/v1/books/rent'),
    headers: {
      'Authorization': 'Bearer {YOUR_JWT_TOKEN}',  // 여기에 실제 JWT 토큰을 입력해야 합니다
    },
    body: json.encode({
      'bookId': bookId,
      'rentDurationDays': 14,  // 예시로 14일 대출
    }),
  );

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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('대출 실패'),
        content: Text('도서를 대출할 수 없습니다.'),
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
Future<void> returnBook(int bookId, BuildContext context) async {
  final response = await http.post(
    Uri.parse('http://175.113.202.160:2028/api/v1/books/${bookId}/return'),
    headers: {
      'Authorization': 'Bearer {YOUR_JWT_TOKEN}',  // 여기에 실제 JWT 토큰을 입력해야 합니다
    },
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
