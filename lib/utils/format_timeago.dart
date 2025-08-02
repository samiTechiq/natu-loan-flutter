import 'package:timeago/timeago.dart' as timeago;

String formatTimeAgo(String isoString) {
  try {
    DateTime dateTime = DateTime.parse(isoString).toLocal();
    return timeago.format(
      dateTime,
      locale: 'en_short',
      allowFromNow: true,
      clock: DateTime.now(),
    );
  } catch (e) {
    return 'Invalid date';
  }
}
