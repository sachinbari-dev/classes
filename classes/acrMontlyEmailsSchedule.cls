global class acrMontlyEmailsSchedule implements Schedulable {
      private Boolean isOld;
   // Setter method to set the isOld value
    public void setIsOld(Boolean isOld) {
        this.isOld = isOld;
    }
    global void execute(schedulablecontext SC){
	   // This method sends email to customers who acr report got created today && size is restricted to 25 as it is a future method
	    acrMonthlyReportScheduleHelper.acrmonthlyhealper(); 
         
       //	Send_Report_Attachement.SendEmailToCustomers(); 
       Send_Report_Attachement.SendEmailToCustomers();
      }

}