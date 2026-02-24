global class BVC_brinksZohoGetDocumentScheduler implements schedulable {

       global void execute(SchedulableContext sc){
        
        BVC_brinksGetDoumentAPIhelperBatch bc = new BVC_brinksGetDoumentAPIhelperBatch();
          id jobID = Database.ExecuteBatch(bc,2);
    }
}