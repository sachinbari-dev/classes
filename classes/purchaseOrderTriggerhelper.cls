public class purchaseOrderTriggerhelper {

    
    public static void updateWMSProduct(List<Purchase_Order__c> poList){
        
        if(!poList.isEmpty()){
            Set<id> poIds = new set<id>();
            string poId = '';
            for(Purchase_Order__c p : poList){
                if(p.Verified_PO__c == true){
                    poId = p.id;
                    poIds.add(p.id);
                    
                }
            }
            
                List<WMS_Products__c> updateWpList = new List<WMS_Products__c>();
                List<WMS_Products__c> wpList = [Select id, name, status__c, customer__c,Purchase_Order__c,Purchase_Order__r.id from WMS_Products__c where Purchase_Order__r.id IN: poIds];
                
            if(!wpList.isEmpty()){
                for(WMS_Products__c wp : wpList){
                        wp.Status__c = 'Available';
                       updateWpList.add(wp);
                    }
                 }
            
            if(!updateWpList.isEmpty()){
                 update updateWpList;
             
            }
            }
                    
    }

    public static void updateStockOnProductMaster(set<id> poId){
        
        List<WMS_Products__c> wmsProductList = [Select id,name,Product_Master__c,Quantity__c,Price__c,Purchase_Order__c,Purchase_Order__r.id from WMS_Products__c where Purchase_Order__r.id IN:PoId];
        
       
        Map<Id, Decimal> productMasterQtyMap = new Map<Id, Decimal>();
        Map<Id, Decimal> productMasterPriceMap = new Map<Id, Decimal>();
        string poIds ='';
         system.debug('wmsProductList'+ wmsProductList);
        system.debug('wmsProductList'+ wmsProductList.size());
        
        for (WMS_Products__c wp : wmsProductList) {
            if (wp.Product_Master__c != null && wp.Quantity__c != null) {
                 poIds = wp.Purchase_Order__r.id;
                if (productMasterQtyMap.containsKey(wp.Product_Master__c)) {
                    productMasterQtyMap.put(wp.Product_Master__c, productMasterQtyMap.get(wp.Product_Master__c) + wp.Quantity__c);
                    productMasterPriceMap.put(wp.Product_Master__c, productMasterPriceMap.get(wp.Product_Master__c) + wp.Price__c);
                } else {
                    productMasterQtyMap.put(wp.Product_Master__c, wp.Quantity__c);
                    productMasterPriceMap.put(wp.Product_Master__c, wp.Price__c);
                }
            }
        }
        
        system.debug('productMasterQtyMap'+ productMasterQtyMap);
        system.debug('productMasterPriceMap'+ productMasterPriceMap);
        
             List<Product_Master__c> pmList = [ SELECT Id, Stock_Quantity__c,Stock_Price__c,Available_Stock__c FROM Product_Master__c WHERE Id IN :productMasterQtyMap.keySet()];
             List<Product_Master__c>updatePmList = new List<Product_Master__c>();
        
              for (Product_Master__c pm : pmList) {
                   Decimal qtyToAdd = productMasterQtyMap.get(pm.Id);
                   Decimal priceToAdd = productMasterPriceMap.get(pm.Id);
                   pm.Stock_Quantity__c = (pm.Stock_Quantity__c == null ? 0 : pm.Stock_Quantity__c) + qtyToAdd;
                   pm.Available_Stock__c = (pm.Available_Stock__c == null ? 0 : pm.Available_Stock__c) + qtyToAdd;
                   pm.Stock_Price__c = (pm.Stock_Price__c == null ? 0 : pm.Stock_Price__c) + priceToAdd; 
                   
                  updatePmList.add(pm);
               }
            
        if(!updatePmList.isEmpty()){
            try{
                update updatePmList;
            }catch (Exception e){
                  Exception_Log__c  ex = new Exception_Log__c();
                    ex.Name = 'update stock quantity and price on Product master';
                    ex.Exception_Error_Message__c = e.getMessage();
                    ex.Purchase_Order__c = poIds;
                    insert ex;
            }
            
        }
       }
    public static void updateStockOnProductMasterVerifiedToDraft(Id poId) {
    
        if (poId == null) return;
    
       
        List<WMS_Products__c> wmsProductList = [SELECT Id,Product_Master__c,Quantity__c,Price__c FROM WMS_Products__c WHERE Purchase_Order__c = :poId];
    
        if (wmsProductList.isEmpty()) return;
    
       
        Map<Id, Decimal> productMasterQtyMap   = new Map<Id, Decimal>();
        Map<Id, Decimal> productMasterPriceMap = new Map<Id, Decimal>();
    
        for (WMS_Products__c wp : wmsProductList) {
            if (wp.Product_Master__c == null || wp.Quantity__c == null) continue;
    
            productMasterQtyMap.put(
                wp.Product_Master__c,
                (productMasterQtyMap.containsKey(wp.Product_Master__c)
                    ? productMasterQtyMap.get(wp.Product_Master__c)
                    : 0) + wp.Quantity__c
            );
    
            productMasterPriceMap.put(
                wp.Product_Master__c,
                (productMasterPriceMap.containsKey(wp.Product_Master__c)
                    ? productMasterPriceMap.get(wp.Product_Master__c)
                    : 0) + (wp.Price__c == null ? 0 : wp.Price__c)
            );
        }
    
        if (productMasterQtyMap.isEmpty()) return;
    
    
        List<Product_Master__c> pmList = [ SELECT Id,Stock_Quantity__c,Available_Stock__c,Stock_Price__c FROM Product_Master__c WHERE Id IN :productMasterQtyMap.keySet()];
    
        List<Product_Master__c> updatePmList = new List<Product_Master__c>();
    
            for (Product_Master__c pm : pmList) {
                Decimal qtyToReduce   = productMasterQtyMap.get(pm.Id);
                Decimal priceToReduce = productMasterPriceMap.get(pm.Id);
        
                  pm.Stock_Quantity__c  = Math.max(0, (pm.Stock_Quantity__c == null ? 0 : pm.Stock_Quantity__c) - qtyToReduce);
        
                  pm.Available_Stock__c = Math.max(0, (pm.Available_Stock__c == null ? 0 : pm.Available_Stock__c) - qtyToReduce);
        
                  pm.Stock_Price__c = Math.max(0, (pm.Stock_Price__c == null ? 0 : pm.Stock_Price__c) - priceToReduce);
        
                updatePmList.add(pm);
            }
    
    
        if (!updatePmList.isEmpty()) {
            try {
                update updatePmList;
            } catch (Exception e) {
                Exception_Log__c ex = new Exception_Log__c();
                ex.Name = 'Revert stock on PO Verified → Draft';
                ex.Exception_Error_Message__c = e.getMessage();
                ex.Purchase_Order__c = poId;
                insert ex;
            }
        }
    }
    
     public static void validatePO(List<Purchase_Order__c> newList,Map<Id, Purchase_Order__c> oldMap) {
        Set<Id> poIdsToCheck = new Set<Id>();

     
        for (Purchase_Order__c po : newList) {
            if (po.Verified_PO__c == true && oldMap.get(po.Id).Verified_PO__c != true) {
                poIdsToCheck.add(po.Id);
            }
        }

        if (poIdsToCheck.isEmpty()) return;

        List<WMS_Products__c> wmsList = [SELECT Id, Purchase_Order__c, Serial_Number__c, Customer__c
                                            FROM WMS_Products__c
                                            WHERE Purchase_Order__c IN :poIdsToCheck];
         if(wmsList.isEmpty()){
             for(Purchase_Order__c p: newList){
                   p.addError('Can not verify without Product');
             }
             
         }
         
        Map<Id, Set<String>> poToSerialSet = new Map<Id, Set<String>>();
        Set<Id> poWithDuplicate = new Set<Id>();
         
         for (WMS_Products__c w : wmsList) {
            if (String.isBlank(w.Serial_Number__c)) continue;

            String serial = w.Serial_Number__c.trim().toUpperCase();

            if (!poToSerialSet.containsKey(w.Purchase_Order__c)) {
                poToSerialSet.put(w.Purchase_Order__c, new Set<String>());
            }

         
            if (!poToSerialSet.get(w.Purchase_Order__c).add(serial)) {
                poWithDuplicate.add(w.Purchase_Order__c);
            }
        }

      
        for (Purchase_Order__c po : newList) {
            if (poIdsToCheck.contains(po.Id)
                && poWithDuplicate.contains(po.Id)) {

                po.addError('Cannot verify PO: duplicate serial numbers found in WMS products.');
            }
        }

    }
     public static void restrictStatusChangeByProfile(List<Purchase_Order__c> newList, Map<Id, Purchase_Order__c> oldMap) {
        
        String profileName = [SELECT Name FROM Profile  WHERE Id = :UserInfo.getProfileId()].Name;

        Boolean isAdmin = (profileName == 'System Administrator');
        set<id>poIds = new set<id>();
         
        for (Purchase_Order__c newPo : newList) {
            poIds.add(newPo.id);
            Purchase_Order__c oldPo = oldMap.get(newPo.Id);

            // Block status change for non-admin
            if (newPo.PO_Status__c =='Draft' && oldPo.PO_Status__c =='Verified' && !isAdmin) {
                newPo.addError(
                    'You are not allowed to change Purchase Order status. Please contact Admin.'
                );
            }
        }
      
    }
    
    
    public static void updateWMSStatusToPending(Set<Id> poIds) {

        if (poIds.isEmpty()) return;
    
        List<WMS_Products__c> wmsToUpdate = [SELECT Id, Status__c FROM WMS_Products__c WHERE Purchase_Order__c IN :poIds AND Status__c != 'Pending'];
    
        for (WMS_Products__c w : wmsToUpdate) {
            w.Status__c = 'Pending';
            
        }
    
        if (!wmsToUpdate.isEmpty()) {
            update wmsToUpdate;
        }
  }
    
    public static void restrictPOStatusRollback(List<Purchase_Order__c> newList, Map<Id, Purchase_Order__c> oldMap) {
        
    Set<Id> poIdsToCheck = new Set<Id>();

   
    for (Purchase_Order__c newPo : newList) {
        Purchase_Order__c oldPo = oldMap.get(newPo.Id);

        if (oldPo.PO_Status__c == 'Verified'&& newPo.PO_Status__c == 'Draft') {
         poIdsToCheck.add(newPo.Id);
        }
    }

    if (poIdsToCheck.isEmpty()) return;

  
    Set<Id> poWithSalesOrder = new Set<Id>();

    for (WMS_Products__c w : [ SELECT Purchase_Order__c FROM WMS_Products__c WHERE Purchase_Order__c IN :poIdsToCheck AND Sales_Order__c != null]) {
            poWithSalesOrder.add(w.Purchase_Order__c);
        }

 
    for (Purchase_Order__c newPo : newList) {
        if (poWithSalesOrder.contains(newPo.Id)) {
            newPo.addError(
                'Cannot move PO back to Draft because Sales Order exists on WMS Products.'
            );
        }
    }
}
   
}