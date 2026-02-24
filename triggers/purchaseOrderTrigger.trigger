trigger purchaseOrderTrigger on Purchase_Order__c (before insert, before update,after insert, after update) {

    if(Trigger.isBefore){
        if(Trigger.isUpdate){
            purchaseOrderTriggerhelper.validatePO(Trigger.new,Trigger.oldMap);
            
            for(Purchase_Order__c p : trigger.new){
                 Purchase_Order__c oldP = Trigger.oldMap.get(p.Id);
                if(p.Shipping_Partner__c == null && p.Verified_PO__c == true){
                    p.addError('Customer is missing');
                }
                 if(p.Hub__c == null && p.Verified_PO__c == true){
                    p.addError('Hub is missing'); 
                }
                if(p.PO_Status__c == 'Draft' && oldP.PO_Status__c == 'Verified'){
                    p.Verified_PO__c = false;
                    purchaseOrderTriggerhelper.restrictStatusChangeByProfile(Trigger.new, Trigger.oldMap);
                    purchaseOrderTriggerhelper.restrictPOStatusRollback(Trigger.new, Trigger.oldMap);
                }
                if(p.PO_Status__c == 'Cancel' && oldP.PO_Status__c == 'Verified'){
                      p.Verified_PO__c = false;
                }
            }
        }
    }
    if(trigger.isAfter){
        if(Trigger.isUpdate){
            
            List<Purchase_Order__c> pList = new List<Purchase_Order__c>();
            set<id> poId = new set<id>();
             set<id> PostatusChange= new set<id>();
            for(Purchase_Order__c po : Trigger.new){
                 Purchase_Order__c oldP = Trigger.oldMap.get(po.Id);
                if(po.Verified_PO__c == true){
                    pList.add(po);
                    poId.add(po.id);
                }
                if(po.PO_Status__c == 'Draft' && oldP.PO_Status__c == 'Verified'){
                  
                    PostatusChange.add(po.id);
                     purchaseOrderTriggerhelper.updateStockOnProductMasterVerifiedToDraft(po.id);
                }
                if(po.PO_Status__c == 'Cancel' && oldP.PO_Status__c == 'Verified'){
                    PostatusChange.add(po.id);
                     purchaseOrderTriggerhelper.updateStockOnProductMasterVerifiedToDraft(po.id);
                }
            }
            
            if(!pList.isEmpty()){
                 purchaseOrderTriggerhelper.updateWMSProduct(pList);
                 purchaseOrderTriggerhelper.updateStockOnProductMaster(poId);
            }
            if(!PostatusChange.isEmpty()){
                purchaseOrderTriggerhelper.updateWMSStatusToPending(PostatusChange);
               
            }
            
            
            
        }
    }
    
}