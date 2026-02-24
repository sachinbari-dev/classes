public class WMS_returnSalesOrder {

    public static void returnSalesOrder(List<Sales_order__c> salesOrderList){
        
         List<Sales_order__c> salesOrderListUpdate = new List<Sales_order__c>();
         set<id> salesOrderId = new Set<id>();
         string status ='';
        for(Sales_order__c so : salesOrderList){
            if(so.Sales_Order_Status__c == 'Returned'){
                status = so.Sales_Order_Status__c;
                salesOrderId.add(so.id);
            }
             if(so.Sales_Order_Status__c == 'Cancel'){
                 status = so.Sales_Order_Status__c;
                salesOrderId.add(so.id);
            }
        }  
        
        List<WMS_products__c> WMSProdList = [select id,Quantity__c,Product_Master__c,Total_Price__c,Sales_Order__c,Sales_Order__r.id from WMS_Products__c where Sales_Order__r.id IN:salesOrderId];
       
         Map<Id, Decimal> productQuantityMap = new Map<Id, Decimal>();
        Map<Id, Decimal> productPriceMap = new Map<Id, Decimal>();
        Map<Id, Decimal> availableStockMap = new Map<Id, Decimal>();
         Map<Id, Decimal> availableStockQuantityMap = new Map<Id, Decimal>();
        Map<Id, Decimal> availableStockPriceMap = new Map<Id, Decimal>();
        Map<Id, String> productMasterNameMap = new Map<Id, String>(); // Store Product Master Names
        Set<Id> productMasterIds = new Set<Id>();
        
        for (WMS_Products__c wp : WMSProdList) {
            if (wp.Product_Master__c != null) {
                productMasterIds.add(wp.Product_Master__c);
              productQuantityMap.put(wp.Product_Master__c,(productQuantityMap.containsKey(wp.Product_Master__c) ? productQuantityMap.get(wp.Product_Master__c) : 0)+ wp.Quantity__c);
               productPriceMap.put(wp.Product_Master__c,(productPriceMap.containsKey(wp.Product_Master__c) ? productPriceMap.get(wp.Product_Master__c) : 0)+ wp.Total_Price__c);
            }
        }
        
         if (!productMasterIds.isEmpty()) {
            for (Product_Master__c pm : [SELECT Id, Name,Stock_Price__c,Stock_Quantity__c, Available_Stock__c,Total_Reserved_Stock__c FROM Product_Master__c WHERE Id IN :productMasterIds]) {
                availableStockMap.put(pm.Id, pm.Available_Stock__c);
                availableStockQuantityMap.put(pm.Id, pm.Stock_Quantity__c);
                availableStockPriceMap.put(pm.Id, pm.Stock_Price__c);
                productMasterNameMap.put(pm.Id, pm.Name);
            }
        }
        
        List<Product_Master__c> prodMasterList = [SELECT Id, Name,Stock_Price__c, Available_Stock__c,Stock_Quantity__c,Total_Reserved_Stock__c FROM Product_Master__c WHERE Id IN :productMasterIds];
        List<Product_Master__c> updateProdMasterList = new List<Product_Master__c>();
        
        for (Sales_Order__c so : salesOrderList) {
            for (Id productMasterId : productQuantityMap.keySet()) {
                for(Product_Master__c pm : prodMasterList){
                    if(pm.id == productMasterId){
                        
                        Decimal availableStockQunatity = availableStockQuantityMap.containsKey(productMasterId) ? availableStockQuantityMap.get(productMasterId) : 0;
                        Decimal availableStock = availableStockMap.containsKey(productMasterId) ? availableStockMap.get(productMasterId) : 0;
                        Decimal availableStockPrice = availableStockPriceMap.containsKey(productMasterId) ? availableStockPriceMap.get(productMasterId) : 0;
                        Decimal totalWMSQuantity = productQuantityMap.get(productMasterId);
                        Decimal totalWMSQuantityPrice = productPriceMap.get(productMasterId);
                        String productMasterName = productMasterNameMap.containsKey(productMasterId) ? productMasterNameMap.get(productMasterId) : 'Unknown Product';
                        
                        system.debug('availableStockQunatity'+availableStockQunatity);
                        system.debug('availableStock'+availableStock);
                        system.debug('availableStockPrice'+availableStockPrice);
                        system.debug('totalWMSQuantity'+totalWMSQuantity);
                        system.debug('totalWMSQuantityPrice'+totalWMSQuantityPrice);
                        
                        //pm.Stock_Price__c += totalWMSQuantityPrice;
                        pm.Stock_Quantity__c += totalWMSQuantity;
                        pm.Available_Stock__c += totalWMSQuantity;
                        pm.Stock_Price__c += totalWMSQuantityPrice;
                        if (status == 'Cancel' ) {
                            Decimal reserved = pm.Total_Reserved_Stock__c == null ? 0 : pm.Total_Reserved_Stock__c;
                        
                            pm.Total_Reserved_Stock__c = Math.max(0, reserved - totalWMSQuantity);
                        }
                         if (status == 'Returned' ) {
                            Decimal reserved = pm.Total_Reserved_Stock__c == null ? 0 : pm.Total_Reserved_Stock__c;
                        
                            pm.Total_Reserved_Stock__c = Math.max(0, reserved - totalWMSQuantity);
                        }
                        updateProdMasterList.add(pm);
                    }
                                  
 
                }

            }
        }
        
        if(!updateProdMasterList.isEmpty()){
            update updateProdMasterList;
        }
    }
}