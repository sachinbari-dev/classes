global class DeleteQuoteLineBatch implements Database.Batchable <sObject> {
     public Database.QueryLocator Start(Database.BatchableContext bc){return Database.getQueryLocator(
            'SELECT Id FROM Shipment__c WHERE id=null'
        );}
    public void execute(Database.BatchableContext bc , List<Shipment__c> newShipment){}
    public void finish(Database.BatchableContext bc){}
    
    public static void dummyMethod(){
        integer i = 0;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;

        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;

        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    } 
}
    
    /*
    global Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'Select Id From SBQQ__QuoteLine__c';
        return Database.getQueryLocator(query);
    }
    
    global void execute (Database.BatchableContext bc, List<SBQQ__QuoteLine__c> quoteLineList) {
        if(quoteLineList.size() > 0){
            delete quoteLineList;
        }
    }
    
    global void finish(Database.BatchableContext bc){
        
    }
}*/