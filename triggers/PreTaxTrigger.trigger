trigger PreTaxTrigger on BVC_CB_PreTaxBill__c (after update) {
    List<Id> preTaxIds = new List<Id>();
    for (BVC_CB_PreTaxBill__c preTaxRecord : trigger.new) {
        System.debug('4 AAAA for checking preTaxRecord.BVC_CB_PretaxDetails_Inserted__c '+preTaxRecord.BVC_CB_PretaxDetails_Inserted__c);
        System.debug('5 AAAA for checking preTaxRecord.BVC_CB_PretaxDetails_Inserted__cdasda '+Trigger.OldMap.get(preTaxRecord.Id).BVC_CB_PretaxDetails_Inserted__c);
        
        if(preTaxRecord.BVC_CB_PretaxDetails_Inserted__c && !Trigger.OldMap.get(preTaxRecord.Id).BVC_CB_PretaxDetails_Inserted__c){ 
            System.debug('inside condition');
            preTaxIds.add(preTaxRecord.Id);
        }
    }
	System.debug('12 AAAA for checking calling PreTaxTriggerHandler in Tirgger '+ preTaxIds);
    if(preTaxIds.size()>0){
        System.debug('14 AAAA inside condition agian');
        PreTaxTriggerHandler.createOrderFromPreTax(preTaxIds);    
    }
    

}