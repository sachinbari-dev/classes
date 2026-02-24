global class ZohoSignGetDocumentScheduler  implements schedulable {

    global void execute(SchedulableContext sc){
        
        zohoSignGetDocumentAPIHelperBatch bc = new zohoSignGetDocumentAPIHelperBatch();
          id jobID = Database.ExecuteBatch(bc,2);
    } 
}