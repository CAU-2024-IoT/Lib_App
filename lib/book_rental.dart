// book_rental.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> rentBook(String bookId, String token, BuildContext context) async {
  final url = Uri.parse('http://175.113.202.160:2028/books/rent');
  final requestBody = jsonEncode({
    'bookId': bookId,
    'rentDurationDays': 14,
  });

  final headers = {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  };

  try {
    final response = await http.post(url, headers: headers, body: requestBody);

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);

      if (responseData['resultType'] == 'SUCCESS') {
        showMessage(context, '대여가 완료되었습니다. 위치: ${responseData['success']['location']}');
      } else {
        showMessage(context, '대여 실패: ${responseData['error']['reason']}');
      }
    } else {
      showMessage(context, '서버 오류: ${response.statusCode}');
    }
  } catch (e) {
    showMessage(context, '에러 발생: $e');
  }
}

Future<void> returnBook(String bookId, String token, BuildContext context) async {
  final url = Uri.parse('http://175.113.202.160:2028/books/return');
  final requestBody = jsonEncode({
    'bookId': bookId,
  });

  final headers = {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  };

  try {
    final response = await http.post(url, headers: headers, body: requestBody);

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);

      if (responseData['resultType'] == 'SUCCESS') {
        showMessage(context, '반납이 완료되었습니다.');
      } else {
        showMessage(context, '반납 실패: ${responseData['error']['reason']}');
      }
    } else {
      showMessage(context, '서버 오류: ${response.statusCode}');
    }
  } catch (e) {
    showMessage(context, '에러 발생: $e');
  }
}

void showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
