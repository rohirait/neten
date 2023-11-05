import 'package:intl/intl.dart';

// String readTimestamp(int timestamp) {
//   var now = DateTime.now();
//   var format = DateFormat('HH:mm a');
//   var date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
//   var diff = now.difference(date);
//   var time = '';
//
//   if (diff.inSeconds <= 0 || diff.inSeconds > 0 && diff.inMinutes == 0 || diff.inMinutes > 0 && diff.inHours == 0 || diff.inHours > 0 && diff.inDays == 0) {
//     time = format.format(date);
//   } else if (diff.inDays > 0 && diff.inDays < 7) {
//     if (diff.inDays == 1) {
//       time = diff.inDays.toString() + ' DAY AGO';
//     } else {
//       time = diff.inDays.toString() + ' DAYS AGO';
//     }
//   } else {
//     if (diff.inDays == 7) {
//       time = (diff.inDays / 7).floor().toString() + ' WEEK AGO';
//     } else {
//
//       time = (diff.inDays / 7).floor().toString() + ' WEEKS AGO';
//     }
//   }
//
//   return time;
// }

String readTimestamp(DateTime timestamp) {
  return DateFormat('dd.MM.yyyy').format(timestamp);
}

extension CapitalizeFirstLetterOfWords on String {
  String capitalizeFirstLetterOfWords() {
    List<String> words = this.split(' ');
    List<String> capitalizedWords = [];

    for (String word in words) {
      if (word.isNotEmpty) {
        String capitalizedWord = word[0].toUpperCase() + word.substring(1);
        capitalizedWords.add(capitalizedWord);
      }
    }

    return capitalizedWords.join(' ');
  }
}
