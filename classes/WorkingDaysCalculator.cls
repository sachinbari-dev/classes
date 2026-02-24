public class WorkingDaysCalculator {
    
    public static Integer getWorkingDays() {
        Integer year = Date.today().year();
        Integer month = Date.today().month();
        
        Date startDate = Date.newInstance(year, month, 1);
        Date endDate   = startDate.addMonths(1).addDays(-1);
        
        Integer workingDays = 0;
        
        Set<Date> holidays = new Set<Date>();
        holidays.add(Date.newInstance(year, month, 15));
        
        /*List<Holiday_Data__c> bvcHolidaysList = new List<Holiday_Data__c>();
        bvcHolidaysList = [SELECT Date__c FROM Holiday_Data__c WHERE Date__c >= :startDate AND Date__c <= :endDate];
        
        System.debug('for checking bvcHolidaysList '+bvcHolidaysList);
        System.debug('for checking bvcHolidaysList.size() '+bvcHolidaysList.size());

        for (Holiday_Data__c h : bvcHolidaysList) {
            holidays.add(h.Date__c);
        }*/
        
        for (Date d = startDate; d <= endDate; d = d.addDays(1)) {
            String dayName = DateTime.newInstance(d, Time.newInstance(0, 0, 0, 0)).format('E'); 
            
            if (dayName != 'Sun' && !holidays.contains(d)) {
                workingDays++;
            }
        }
        
        Map<Integer, String> monthNames = new Map<Integer, String>();
        for (Integer i = 1; i <= 12; i++) {
            Date sampleDate = Date.newInstance(year, i, 1);
            String monthName = DateTime.newInstance(sampleDate, Time.newInstance(0, 0, 0, 0)).format('MMMM');
            monthNames.put(i, monthName);
        }
        
        System.debug('for checking Working days in ' + monthNames.get(month) + ' ' + year + ' = ' + workingDays);
        
        return workingDays;
    }
    
}