global class BVC_ZohoSignAccessGenScheculer implements schedulable {
 
    global void execute(SchedulableContext sc){
        
        BVC_zohoSignSchedulerHelper.accesTokenGenerator();
        
    }  
}