import 'package:flutter/material.dart';

class BookRentalButton extends StatelessWidget {
  final String availability;

  BookRentalButton({required this.availability});

  @override
  Widget build(BuildContext context) {
    return availability == '대출 가능'
        ? TextButton(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('대출이 완료되었습니다.')));
      },
      child: Text('대출'),
    )
        : TextButton(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('반납이 완료되었습니다.')));
      },
      child: Text('반납'),
    );
  }
}
