/// Model representing a health tip fetched from the REST API.
/// Parses the response from https://api.adviceslip.com/advice
class HealthTipModel {
  /// Unique identifier returned by the API
  final int id;

  /// The tip/advice content
  final String content;

  const HealthTipModel({
    required this.id,
    required this.content,
  });

  /// Factory constructor from adviceslip JSON:
  /// { "slip": { "id": 1, "advice": "..." } }
  factory HealthTipModel.fromJson(Map<String, dynamic> json) {
    final slip = json['slip'] as Map<String, dynamic>;
    return HealthTipModel(
      id: slip['id'] as int? ?? 0,
      content: slip['advice'] as String? ?? '',
    );
  }

  @override
  String toString() => 'HealthTipModel(id: $id, content: $content)';
}
