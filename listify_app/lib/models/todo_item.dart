import 'package:uuid/uuid.dart';

enum Priority { low, medium, high }

class TodoItem {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final Priority priority;
  final DateTime createdAt;
  final DateTime? completedAt;
  final DateTime? dueDate;
  final DateTime? notificationTime; // When to notify on the due date
  final bool hasNotification; // Whether notification is enabled

  TodoItem({
    String? id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    this.priority = Priority.medium,
    DateTime? createdAt,
    this.completedAt,
    this.dueDate,
    this.notificationTime,
    this.hasNotification = false,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  TodoItem copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    Priority? priority,
    DateTime? createdAt,
    DateTime? completedAt,
    DateTime? dueDate,
    DateTime? notificationTime,
    bool? hasNotification,
  }) {
    return TodoItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      dueDate: dueDate ?? this.dueDate,
      notificationTime: notificationTime ?? this.notificationTime,
      hasNotification: hasNotification ?? this.hasNotification,
    );
  }

  // Get the full notification DateTime by combining due date and notification time
  DateTime? get fullNotificationDateTime {
    if (dueDate == null || notificationTime == null || !hasNotification) {
      return null;
    }
    
    return DateTime(
      dueDate!.year,
      dueDate!.month,
      dueDate!.day,
      notificationTime!.hour,
      notificationTime!.minute,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted ? 1 : 0,
      'priority': priority.index,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'completedAt': completedAt?.millisecondsSinceEpoch,
      'dueDate': dueDate?.millisecondsSinceEpoch,
      'notificationTime': notificationTime?.millisecondsSinceEpoch,
      'hasNotification': hasNotification ? 1 : 0,
    };
  }

  factory TodoItem.fromMap(Map<String, dynamic> map) {
    return TodoItem(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      isCompleted: (map['isCompleted'] ?? 0) == 1,
      priority: Priority.values[map['priority'] ?? 1],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      completedAt: map['completedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['completedAt'])
          : null,
      dueDate: map['dueDate'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['dueDate'])
          : null,
      notificationTime: map['notificationTime'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['notificationTime'])
          : null,
      hasNotification: (map['hasNotification'] ?? 0) == 1,
    );
  }

  @override
  String toString() {
    return 'TodoItem(id: $id, title: $title, isCompleted: $isCompleted, priority: $priority, hasNotification: $hasNotification)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TodoItem &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.isCompleted == isCompleted &&
        other.priority == priority &&
        other.hasNotification == hasNotification;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        description.hashCode ^
        isCompleted.hashCode ^
        priority.hashCode ^
        hasNotification.hashCode;
  }
}