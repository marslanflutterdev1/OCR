// widgets/date_time_utils.dart
import 'package:intl/intl.dart';

class DateTimeUtils {
  static String formatDateString(String dateString) {
    try {
      // Parse the string to DateTime
      DateTime dateTime = DateTime.parse(dateString);

      // Format it to a readable string
      return DateFormat('MMM dd, yyyy - HH:mm').format(dateTime);
    } catch (e) {
      // If parsing fails, return the original string or a default message
      return 'Invalid date';
    }
  }

  // Alternative method if your dateString might be a timestamp (int)
  static String formatTimestamp(dynamic timestamp) {
    try {
      DateTime dateTime;

      if (timestamp is int) {
        // Handle milliseconds timestamp
        dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      } else if (timestamp is String) {
        // Try to parse as timestamp string first
        int? ts = int.tryParse(timestamp);
        if (ts != null) {
          dateTime = DateTime.fromMillisecondsSinceEpoch(ts);
        } else {
          // Try to parse as ISO string
          dateTime = DateTime.parse(timestamp);
        }
      } else {
        return 'Invalid date';
      }

      return DateFormat('MMM/dd/yyyy  HH:mm a').format(dateTime);
    } catch (e) {
      return 'Invalid date';
    }
  }
}
