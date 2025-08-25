class DatetimeHelper {
  static DateTime? parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is String && value.isNotEmpty) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        print('Error parsing date: $value - $e');
        return null;
      }
    }
    return null;
  }
}
