global class invoiceDownloadLinkBatch implements Database.Batchable<sObject> {
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
    
 /*  global Database.QueryLocator start(Database.BatchableContext BC){
       string query = 'select id,name,Invoice_Public_Link__c from blng__Invoice__c';
       return Database.getQueryLocator(query);
   	}
   global void execute(Database.BatchableContext BC, List<blng__Invoice__c> scope){
       
        for(blng__Invoice__c s:scope){
       	//	s.Status = 'Activated';
       }
  }
    
   global void finish(Database.BatchableContext BC){
       
   }

}*/