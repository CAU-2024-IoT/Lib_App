// lib/book.dart
class Book {
  final String title;
  final String author;
  final String publicationInfo;
  final String callNumber;
  final String isbn;
  String availability;

  Book({
    required this.title,
    required this.author,
    required this.publicationInfo,
    required this.callNumber,
    required this.isbn,
    required this.availability,
  });
}
