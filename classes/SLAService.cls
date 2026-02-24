public with sharing class SLAService {

    public class TimeParts {
        public Integer hours;
        public Integer minutes;
        public Integer seconds;
        public TimeParts(Integer h, Integer m, Integer s) { hours = h; minutes = m; seconds = s; }
    }

    public SLAService() {}

    // Normalize minutes/hours overflow (minutes -> hours etc.)
    public static TimeParts normalize(Integer hours, Integer minutes, Integer seconds) {
        if (seconds >= 60) {
            Integer addMin = seconds / 60;
            minutes += addMin;
            seconds = Math.mod(seconds, 60);
        } else if (seconds < 0) {
            Integer borrow = (Math.abs(seconds) + 59) / 60;
            minutes -= borrow;
            seconds += borrow * 60;
        }

        if (minutes >= 60) {
            Integer addHour = minutes / 60;
            hours += addHour;
            minutes = Math.mod(minutes, 60);
        } else if (minutes < 0) {
            Integer borrow = (Math.abs(minutes) + 59) / 60;
            hours -= borrow;
            minutes += borrow * 60;
        }

        return new TimeParts(hours, minutes, seconds);
    }

    // Format final SLA string like "48H 30M 0S"
    public static String formatFinalTime(Integer hours, Integer minutes, Integer seconds) {
        TimeParts t = normalize(hours, minutes, seconds);
        return String.valueOf(t.hours) + 'H ' + String.valueOf(t.minutes) + 'M ' + String.valueOf(t.seconds) + 'S';
    }

    // Convert hours/minutes to days/hours/minutes if required
    public static Integer calculateTatInDays(Date startDate, Date endDate) {
        if (startDate == null || endDate == null) return 0;
        Integer days = Math.abs(endDate.daysBetween(startDate));
        return days;
    }
}