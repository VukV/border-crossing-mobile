class BCError {
  final String message;

  BCError({required this.message});

  factory BCError.fromJson(Map<String, dynamic> json) {
    return BCError(
      message: json['message'] ?? 'An unknown error occurred',
    );
  }

  @override
  String toString() {
    return message;
  }
  
}
