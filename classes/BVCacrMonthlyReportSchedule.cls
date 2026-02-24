global class BVCacrMonthlyReportSchedule implements Schedulable {

    global void execute(schedulablecontext SC){
		
        // This Method Check the hour of the day and if hour == 23 // 11 PM it will cancel all the acrMonthlyReports jobs
        BVCacrMonthlyReportScheduleHelper.acrmonthlyhealper();        
        // This method creates a ACR reports for all eligible customer && size is restricted to 50 as it is a future method
        BVCSend_Report_Attachement.scheuler();
       
    }


}