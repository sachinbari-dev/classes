global class acrMonthlyReportSchedule implements Schedulable {
    private Boolean isOld;
   // Setter method to set the isOld value
    public void setIsOld(Boolean isOld) {
        this.isOld = isOld;
    }
    global void execute(schedulablecontext SC){
		
        // This Method Check the hour of the day and if hour == 23 // 11 PM it will cancel all the acrMonthlyReports jobs
        acrMonthlyReportScheduleHelper.acrmonthlyhealper();        
        // This method creates a ACR reports for all eligible customer && size is restricted to 50 as it is a future method
        Send_Report_Attachement.scheuler();
    }

}