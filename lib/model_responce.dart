class ErrorResponse {
  ErrorResponse({this.title, this.details});

  final String? title;
  final String? details;

  Map<String, dynamic> toJson() =>
      {'title': title ?? '', 'details': details ?? ''};
}
