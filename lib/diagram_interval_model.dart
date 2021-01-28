class JODiagramTimeInterval {
  int from;
  int to;
  int size;

  JODiagramTimeInterval({this.from, this.to, this.size});

  static const millisecond = 1;
  static const second = 1000;
  static const minute = 60 * second;
  static const hour = 60 * minute;
  static const day = 24 * hour;
  static const six_hours = 6 * hour;
  static const twelve_hours = 12 * hour;
  static const week = 7 * day;
  static const month = 31 * day;
  static const year = 366 * day;

  static int daysOfMonth(int month, [int year]) {
    if (year == null) year = DateTime.now().year;
    month = month + 1;
    return new DateTime(year, month, 0).day;
  }

  static int justifyToMinutes(int time, int minutes) {
    final date = DateTime.fromMillisecondsSinceEpoch(time);
    final minute = date.minute;
    int newMinute = 0;
    for (var i = 0; i <= 60; i += minutes) {
      if (i > minute) break;
      newMinute += minutes;
    }
    return DateTime(date.year, date.month, date.day, date.hour, newMinute - 1, 59, 999).millisecondsSinceEpoch;
  }
}
