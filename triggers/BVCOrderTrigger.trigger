trigger BVCOrderTrigger on BVCOrder__c (after update) {
    
    if(trigger.isUpdate && trigger.isAfter){
        Map<Id, BVCOrder__c> bvcOrderMap = new Map<Id, BVCOrder__c>();
        
        utilClass.flowSequence++;
        System.debug('flowSequence : Order After Update Trigger ' + utilClass.flowSequence);
        
        for(BVCOrder__c bvcOrderObj : trigger.newMap.values()){
            System.debug('for checking bvcOrderObj.fixed_billing_order__c == '+bvcOrderObj.fixed_billing_order__c);
            if(bvcOrderObj.fixed_billing_order__c == false){
                
                BVCOrder__c oldbvcOrderObj = trigger.oldMap.get(bvcOrderObj.Id);
                System.debug('Rafi debug bvcOrderObj.Status__c ='+bvcOrderObj.Status__c);
                System.debug('Rafi debug oldbvcOrderObj.Status__c ='+oldbvcOrderObj.Status__c);
                System.debug('Rafi debug bvcOrderObj.Business_Type__c ='+bvcOrderObj.Business_Type__c);
                System.debug('Rafi debug bvcOrderObj.Shipment__c '+bvcOrderObj.Shipment__c);
                System.debug('Rafi debug bvcOrderObj.Shipment__r.Customer_Product_Category__c ='+bvcOrderObj.Shipment__r.Customer_Product_Category__c);
                //  System.debug('Rafi debug bvcOrderObj.Shipment__r.Created_through_BVCeSHIP__c ='+bvcOrderObj.Shipment__r.Created_through_BVCeSHIP__c);
                System.debug('Rafi debug bvcOrderObj.BVC_Service__c ='+bvcOrderObj.BVC_Service__c);
                
                if(bvcOrderObj.Business_Type__c == 'Non ACR' && bvcOrderObj.Status__c == 'Activated' && bvcOrderObj.Status__c != oldbvcOrderObj.Status__c /*&& bvcOrderObj.Vault_Shipmet__c==null*/ && bvcOrderObj.fixed_billing_order__c == false ){ // added Vault_Shipmet__c filter by Pratik to stop excecution for Vault flow // added fixed_billing_order__c by Rafi forto stop fixed billing flow
                    UtilClass.triggerLoop = true;
                    bvcOrderMap.put(bvcOrderObj.Id, bvcOrderObj);
                }
                else if((bvcOrderObj.Business_Type__c == 'ACR' || bvcOrderObj.BVC_Service__c == 'eSHIP' || bvcOrderObj.BVC_Service__c == 'BATH') && bvcOrderObj.Status__c == 'Activated' && bvcOrderObj.Status__c != oldbvcOrderObj.Status__c /*&& bvcOrderObj.Vault_Shipmet__c==null*/ && bvcOrderObj.fixed_billing_order__c == false){// added Vault_Shipmet__c filter by Pratik to stop excecution for Vault flow // added fixed_billing_order__c by Rafi forto stop fixed billing flow
                    UtilClass.triggerLoop = true;
                    System.debug('Rafi debug inside if to test');
                    bvcOrderMap.put(bvcOrderObj.Id, bvcOrderObj);
                }
                else if(bvcOrderObj.BVC_CB_PreTaxBill__c != null && bvcOrderObj.Status__c == 'Activated' && bvcOrderObj.Status__c != oldbvcOrderObj.Status__c /* && bvcOrderObj.Vault_Shipmet__c==null*/){
                    UtilClass.triggerLoop = true;
                    bvcOrderMap.put(bvcOrderObj.Id, bvcOrderObj);
                }
                system.debug('status of order before calling Reverse'+bvcOrderObj.Deactivate_Order__c); 
                system.debug('status of Shipment before calling Reverse'+bvcOrderObj.Shipment_Status__c); 
                if(bvcOrderObj.Shipment_Status__c=='ACR Consumed' && bvcOrderObj.Deactivate_Order__c){
                    system.debug('Calling createReverseOrder');
                    BVCOrderTriggerHandler.createReverseOrder(Trigger.oldMap,Trigger.newMap); 
                }
                
                System.debug('Rafi debug bvcOrderMap.size(): ' + bvcOrderMap.size());
                System.debug('Rafi debug bvcOrderMap.values(): ' + bvcOrderMap.values());
                
                // Process the BVC Order records if the map is not empty
                if(bvcOrderMap.size() > 0){
                    System.debug('Calling BVCOrderProcessor with bvcOrderMap: ' + bvcOrderMap);
                    BVCOrderTriggerHandler.BVCOrderProcessor(bvcOrderMap);
                } else {
                    System.debug('No records to process in BVCOrderProcessor');
                }
            }
        }
        
    }
}