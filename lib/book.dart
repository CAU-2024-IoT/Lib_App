class Book {
  final int book_id;
  final String title;
  final String author;
  final String genre;
  final String publishedDate;
  String status;  // 상태를 변경할 수 있도록 String으로 변경
  final int shelf_id;

  Book({
    required this.book_id,
    required this.title,
    required this.author,
    required this.genre,
    required this.publishedDate,
    required this.status,
    required this.shelf_id,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      book_id: json['book_id'] ?? 0,
      title: json['title'] ?? '제목 없음',
      author: json['author'] ?? '작가 없음',
      genre: json['genre'] ?? '장르 없음',
      publishedDate: json['publishedDate'] ?? '출판일 없음',
      status: json['status'] ?? '알 수 없음',
      shelf_id: json['shelf_id'] ?? 0,
    );
  }
}