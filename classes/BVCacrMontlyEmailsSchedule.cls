global class BVCacrMontlyEmailsSchedule implements Schedulable {
    
    global void execute(schedulablecontext SC){
	   // This method sends email to customers who acr report got created today && size is restricted to 25 as it is a future method
	    BVCacrMonthlyReportScheduleHelper.acrmonthlyhealper(); 
         
       //	Send_Report_Attachement.SendEmailToCustomers(); 
       BVCSend_Report_Attachement.SendEmailToCustomers();
      }

}