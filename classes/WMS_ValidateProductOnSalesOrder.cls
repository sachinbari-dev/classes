public class WMS_ValidateProductOnSalesOrder {

    public static void validateSalesOrderUpdate(Set<Id> salesOrderIds, List<Sales_Order__c> salesOrders) {
        if (salesOrderIds.isEmpty()) return;

      
        List<WMS_Products__c> wmsProducts = [SELECT Id,Total_Price__c ,Price__c , Quantity__c, Product_Master__c, Sales_Order__c FROM WMS_Products__c WHERE Sales_Order__c IN :salesOrderIds];
        
        if(wmsProducts.isEmpty()){
            for(Sales_Order__c s : salesOrders){
                s.addError('At least one WMS Product must be added before marking Sales Order as Stock Reserved.');
            }
        }
        
       
        Map<Id, Decimal> productQuantityMap = new Map<Id, Decimal>();
        Map<Id, Decimal> productPriceMap = new Map<Id, Decimal>();
        Map<Id, Decimal> availableStockMap = new Map<Id, Decimal>();
        Map<Id, Decimal> availableStockPriceMap = new Map<Id, Decimal>();
        Map<Id, String> productMasterNameMap = new Map<Id, String>(); 
        Set<Id> productMasterIds = new Set<Id>();

     
        for (WMS_Products__c wp : wmsProducts) {
            if (wp.Product_Master__c != null) {
                productMasterIds.add(wp.Product_Master__c);
              productQuantityMap.put(wp.Product_Master__c,(productQuantityMap.containsKey(wp.Product_Master__c) ? productQuantityMap.get(wp.Product_Master__c) : 0)+ wp.Quantity__c);
               productPriceMap.put(wp.Product_Master__c,(productPriceMap.containsKey(wp.Product_Master__c) ? productPriceMap.get(wp.Product_Master__c) : 0)+ wp.Total_Price__c);
            }
        }

        
        if (!productMasterIds.isEmpty()) {
            for (Product_Master__c pm : [SELECT Id, Name,Stock_Price__c, Available_Stock__c FROM Product_Master__c WHERE Id IN :productMasterIds]) {
                availableStockMap.put(pm.Id, pm.Available_Stock__c);
                availableStockPriceMap.put(pm.Id, pm.Stock_Price__c);
                productMasterNameMap.put(pm.Id, pm.Name);
            }
        }

      
        for (Sales_Order__c so : salesOrders) {
            for (Id productMasterId : productQuantityMap.keySet()) {
                Decimal availableStock = availableStockMap.containsKey(productMasterId) ? availableStockMap.get(productMasterId) : 0;
                Decimal availableStockPrice = availableStockPriceMap.containsKey(productMasterId) ? availableStockPriceMap.get(productMasterId) : 0;
                Decimal totalWMSQuantity = productQuantityMap.get(productMasterId);
                Decimal totalWMSQuantityPrice = productPriceMap.get(productMasterId);
                String productMasterName = productMasterNameMap.containsKey(productMasterId) ? productMasterNameMap.get(productMasterId) : 'Unknown Product';

                
                if (totalWMSQuantity > availableStock) {
                    so.addError('Cannot update Sales Order: Total WMS Products quantity (' + totalWMSQuantity +') exceeds available stock (' + availableStock + ') for Product Master: ' + productMasterName + '.');
                }
                /*
                if(totalWMSQuantityPrice > availableStockPrice){
                     so.addError('Cannot update Sales Order: Total WMS Products price (' + totalWMSQuantityPrice +') exceeds available stock price (' + availableStockPrice + ') for Product Master: ' + productMasterName + '.');
                }  */
            }
        }
    }
  
}