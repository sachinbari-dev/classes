trigger BrinksAgreementTrigger on BVC_bulk_Agreement_signing__c (after insert,after update) {

    if(trigger.isAfter){
        if(Trigger.isInsert){
            List<id>  recIdList = new List<id>();
                for (BVC_bulk_Agreement_signing__c rec : Trigger.new) {
                    recIdList.add(rec.id);
      
                if(rec.Customer_Address__c != null && rec.BVC_Brink_s_Office_Address__c != null && rec.Customer_Name__c != null && rec.Customer_GST_No__c !=null && rec.Customer_IEC_No__c !=null ){
                      System.enqueueJob(new BVC_GenerateBrinksPDFQueueable(rec.Id));
                }
              
     }
  }
     // after update context
        
        if(Trigger.isUpdate){
            
              List<id>  recIdList = new List<id>();
                for (BVC_bulk_Agreement_signing__c rec : Trigger.new) {
                      recIdList.add(rec.id);
		              BVC_bulk_Agreement_signing__c oldrec= Trigger.oldMap.get(rec.Id);
                    
                  if(oldrec.APICalled__c == false && rec.APICalled__c == true){
                       System.enqueueJob(new BVC_BrinksZohoSignAPIQueueable(recIdList));
                  }
                }
  
          }
      }
}