class DatetimeService {
  String getNumberDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  intToMonth(int month) {
    switch (month) {
      case 1:
        return 'Enero';
      case 2:
        return 'Febrebro';
      case 3:
        return 'Marzo';
      case 4:
        return 'Abril';
      case 5:
        return 'Mayo';
      case 6:
        return 'Junio';
      case 7:
        return 'Julio';
      case 8:
        return 'Agosto';
      case 9:
        return 'Septiembre';
      case 10:
        return 'Octubre';
      case 11:
        return 'Noviembre';
      case 12:
        return 'Diciembre';
    }
  }

  DateTime stampToDT(int timeStatp) {
    DateTime dt = DateTime.fromMillisecondsSinceEpoch(timeStatp * 1000);
    return dt;
  }

  DateTime strToDt(String date) {
    var parsedDate = DateTime.parse('$date 00:00:00.000');
    return parsedDate;
  }

  getDate(DateTime date) {
    String month = '';
    String day = '';
    switch (date.weekday) {
      case 1:
        day = 'Lunes';
        break;
      case 2:
        day = 'Martes';
        break;
      case 3:
        day = 'Miercoles';
        break;
      case 4:
        day = 'Jueves';
        break;
      case 5:
        day = 'Viernes';
        break;
      case 6:
        day = 'Sabado';
        break;
      case 7:
        day = 'Domingo';
        break;
    }
    switch (date.month) {
      case 1:
        month = 'Enero';
        break;
      case 2:
        month = 'Febreo';
        break;
      case 3:
        month = 'Marzo';
        break;
      case 4:
        month = 'Abril';
        break;
      case 5:
        month = 'Mayo';
        break;
      case 6:
        month = 'Junio';
        break;
      case 7:
        month = 'Julio';
        break;
      case 8:
        month = 'Agosto';
        break;
      case 9:
        month = 'Septiembre';
        break;
      case 10:
        month = 'Octubre';
        break;
      case 11:
        month = 'Noviembre';
        break;
      case 12:
        month = 'Diciembre';
        break;
    }
    return '$day ${date.day} de $month';
  }

  getShortDate(DateTime date) {
    String month = '';
    String day = '';
    switch (date.weekday) {
      case 1:
        day = 'Lun';
        break;
      case 2:
        day = 'Mar';
        break;
      case 3:
        day = 'Mie';
        break;
      case 4:
        day = 'Jue';
        break;
      case 5:
        day = 'Vie';
        break;
      case 6:
        day = 'Sab';
        break;
      case 7:
        day = 'Dom';
        break;
    }
    switch (date.month) {
      case 1:
        month = 'En';
        break;
      case 2:
        month = 'Feb';
        break;
      case 3:
        month = 'Mar';
        break;
      case 4:
        month = 'Abr';
        break;
      case 5:
        month = 'Amy';
        break;
      case 6:
        month = 'Jun';
        break;
      case 7:
        month = 'Jul';
        break;
      case 8:
        month = 'Ago';
        break;
      case 9:
        month = 'Sep';
        break;
      case 10:
        month = 'Oct';
        break;
      case 11:
        month = 'Nov';
        break;
      case 12:
        month = 'Dic';
        break;
    }
    return '$day, ${date.day} de $month';
  }

  formatHour(DateTime datetime) {
    String ampm = 'A.M';
    int hour = datetime.hour;
    String minute = datetime.minute.toString();
    if (datetime.hour >= 12) {
      ampm = 'P.M.';
      hour = datetime.hour - 12;
    }
    if (datetime.minute.toString().length < 2) {
      minute = "0${datetime.minute}";
    }
    String finalTIme = "$hour:$minute $ampm";
    return finalTIme;
  }
}
