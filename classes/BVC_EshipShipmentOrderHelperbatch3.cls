global class BVC_EshipShipmentOrderHelperbatch3 implements database.batchable<sobject>  {

      
    global Database.querylocator start(Database.BatchableContext bc){
        
      String query = 'SELECT Id, Docket_No__c, Gross_weight_in_Gram__c,Net_weight_in_Gram__c, Verified_for_Billing__c, Created_through_BVCeSHIP__c, Customer_Product_Category__c, Payment_Mode__c, Shipment_Type__c, No_Of_Attempts__c, Declared_Value__c, From_City__c, To_City__c, Name, RecordType.Name ' +
               'FROM Shipment__c WHERE Verified_for_Billing__c = false AND RecordType.Name = \'eSHIP\' AND Customer_Product_Category__c = \'eSHIP\' AND Created_through_BVCeSHIP__c = true AND CreatedDate = TODAY ' + 
               'LIMIT 5000';

        
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc,List<shipment__c> shipList){
        
        List<shipment__c> shipmentList = new List<Shipment__c>();
        system.debug('shipList  size'+ shipList.size());
        for(Shipment__c s : shipList){
            if(s.Docket_No__c != null && s.Declared_Value__c != null && s.No_Of_Attempts__c != null && s.Payment_Mode__c != null && s.Shipment_Type__c != null && s.Gross_weight_in_Gram__c != null && s.From_City__c != null && s.To_City__c != null){
                if(s.Gross_weight_in_Gram__c >= s.Net_weight_in_Gram__c){
                   if(s.Verified_for_Billing__c == false){
                          if(!Test.isRunningTest()){
                        s.Verified_for_Billing__c = true;
                    }

                    }

                    shipmentList.add(s);
                }
                
            }
           
        }
        if(!shipmentList.isEmpty()){
             update shipmentList;
        }
       
    }
    global void finish(Database.BatchableContext bc){
        
             BVC_EshipShipmentOrderHelperbatch4 nextBatch4 = new BVC_EshipShipmentOrderHelperbatch4();
           Id jobId = Database.executeBatch(nextBatch4, 50);
    }
}