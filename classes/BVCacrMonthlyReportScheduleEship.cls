global class BVCacrMonthlyReportScheduleEship  implements Schedulable {

  global void execute(schedulablecontext SC){
		
        // This Method Check the hour of the day and if hour == 23 // 11 PM it will cancel all the acrMonthlyReports jobs
        BVCacrMonthlyReportScheduleEshipHelper.acrmonthlyhealper();        
       
        //This Is Used for Eship customers 
       BVCSend_Report_AttachementEship.scheuler();
    }  
    
}