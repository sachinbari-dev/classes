global class BVC_ZohoSignGetDocumentScheduler  implements schedulable{

     global void execute(SchedulableContext sc){
        
        BVC_zohoSignGetDocumentHelperBatch bc = new BVC_zohoSignGetDocumentHelperBatch();
          id jobID = Database.ExecuteBatch(bc,2);
    }
}