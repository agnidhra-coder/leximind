enum MessageRole { user, assistant }

class Message {
  final String content;
  final MessageRole role;
  final DateTime timestamp;
  final bool containsKml;

  Message({
    required this.content,
    required this.role,
    DateTime? timestamp,
    this.containsKml = false,
  }) : timestamp = timestamp ?? DateTime.now();

  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Message &&
          content == other.content &&
          role == other.role;

  @override
  int get hashCode => content.hashCode ^ role.hashCode;
}