public class BVC_IqlooGetMasterPin {


   @InvocableMethod
    public static void getMasterPin(List<id> recordId){
                    
               List<Pickup__c> pickupList = [SELECT Id, IqlooMasterPIN__c, Lock_ID__c, Lock_ID__r.Name  FROM Pickup__c  WHERE Id IN :recordId  LIMIT 1];
            
                if (!pickupList.isEmpty()) {
                    Pickup__c p = pickupList[0];
                    if (p.Lock_ID__r != null && String.isNotBlank(p.Lock_ID__r.Name)) {
                        if(!Test.isRunningTest()){
                                BVC_IqlooLockAPIHelper.getIqlooMasterPIN(p.Id, p.Lock_ID__r.Name);
                        }
                    
                    }
                }
            
            List<Shipment__c> shipmentList = [SELECT Id, OTP__c, Lock_ID__c FROM Shipment__c  WHERE Id IN :recordId LIMIT 1];
            
                if (!shipmentList.isEmpty()) {
                    Shipment__c s = shipmentList[0];
                    if (s.Lock_ID__c != null) {
                       if(!Test.isRunningTest()){
                                BVC_IqlooLockAPIHelper.getIqlooMasterPIN(s.Id, s.Lock_ID__c);
                        }
                    }
                }
    }
}