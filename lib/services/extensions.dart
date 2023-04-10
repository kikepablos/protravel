extension StringExtension on String {
  String capitalize() {
    List<String> vals = this.split(' ');
    vals = vals
        .map((e) => e.isEmpty
            ? ''
            : "${e[0].toUpperCase()}${e.substring(1).toLowerCase()}")
        .toList();
    return vals.join(' ');
  }
}
