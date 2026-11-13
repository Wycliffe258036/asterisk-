class Pagination {
  final String? nextCursor;
  final bool hasMore;

  const Pagination({
    this.nextCursor,
    this.hasMore = false,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      nextCursor: json['nextCursor'] as String?,
      hasMore: json['hasMore'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nextCursor': nextCursor,
      'hasMore': hasMore,
    };
  }
}