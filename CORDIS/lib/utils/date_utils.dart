class DateTimeUtils {
  static String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    StringBuffer buffer = StringBuffer();

    if (hours > 0) {
      buffer.write('${hours}h');
    }
    if (buffer.isNotEmpty && minutes > 0) {
      buffer.write(' ');
    }
    if (minutes > 0) {
      buffer.write('${minutes}m');
    }
    if (buffer.isNotEmpty && seconds > 0) {
      buffer.write(' ');
    }
    if (seconds > 0) {
      buffer.write('${seconds}s');
    }

    if (buffer.isEmpty) {
      buffer.write('0s');
    }

    return buffer.toString();
  }
}
