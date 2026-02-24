public with sharing class HolidayService {
    private Map<String, Holiday_Data__c> holidayDateStateMap; // key = date.format() + '-' + state

    public HolidayService(Map<String, Holiday_Data__c> holidayDateStateMap) {
        this.holidayDateStateMap = holidayDateStateMap != null ? holidayDateStateMap : new Map<String, Holiday_Data__c>();
    }

    // Get contiguous holiday text starting from pickup date (if any)
    public String getPickupHolidayText(Date pickupDate, String state) {
        if (pickupDate == null || state == null) return '';
        List<String> holidayNames = new List<String>();
        Date checkDate = pickupDate;
        Integer guard = 0;
        while (guard < 10) { // safe guard
            String mapKey = checkDate.format() + '-' + state;
            Holiday_Data__c hd = holidayDateStateMap.get(mapKey);
            if (hd != null) {
                holidayNames.add(hd.Name + ' on ' + hd.Date__c.format() + ' in ' + hd.State__c);
                checkDate = checkDate.addDays(1);
            } else break;
            guard++;
        }
        return holidayNames.isEmpty() ? '' : String.join(holidayNames, ', ');
    }

    // Check if a specific date is holiday for state
    public Boolean isHoliday(Date d, String state) {
        if (d == null || state == null) return false;
        return holidayDateStateMap.containsKey(d.format() + '-' + state);
    }

    // Get Holiday object (if any) by date/state
    public Holiday_Data__c getHoliday(Date d, String state) {
        if (d == null || state == null) return null;
        return holidayDateStateMap.get(d.format() + '-' + state);
    }
}