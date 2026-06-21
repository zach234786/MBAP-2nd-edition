class Message {
  final String id;
  final String senderName;
  final String senderImage;
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final int unreadCount;
  final bool isOnline;

  Message({
    required this.id,
    required this.senderName,
    required this.senderImage,
    required this.content,
    required this.timestamp,
    required this.isRead,
    required this.unreadCount,
    this.isOnline = false,
  });
}
