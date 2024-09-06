class PageableResponse<T> {
  final List<T> content;
  final int totalPages;
  final int totalElements;
  final int size;
  final int number;

  PageableResponse({
    required this.content,
    required this.totalPages,
    required this.totalElements,
    required this.size,
    required this.number,
  });

  factory PageableResponse.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJsonT) {
    final List<dynamic> contentJson = json['content'];
    final List<T> content = contentJson.map((item) => fromJsonT(item)).toList();

    return PageableResponse(
      content: content,
      totalPages: json['totalPages'],
      totalElements: json['totalElements'],
      size: json['size'],
      number: json['number'],
    );
  }
}
