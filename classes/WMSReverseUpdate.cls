public class WMSReverseUpdate {

    
       @invocableMethod
    public static void avoidWMSrecordCreation(List<id> WmsID){
       
       List<WMS_Products__c> WMSProdList = [SELECT Id, Name, Product_Master__c, Hub__c, Quantity__c, Sales_Order__c,Sales_Order__r.Sales_Order_Status__c, Total_Price__c, Batch_Size__c, Serial_Number__c, Weight_UOM__c, Weight__c, Stock_Out_User__c, Stock_in_User__c,Sales_Order__r.id FROM WMS_Products__c where Sales_Order__r.id In:WmsID];
        Set<id>  wmsIds = new Set<id>();
        Set<id> prodMaster = new Set<id>();
        
        for(WMS_Products__c  wp :WMSProdList){
            if(wp.Sales_Order__c  != null && wp.Sales_Order__r.Sales_Order_Status__c == 'Dispatched' ){
                wmsIds.add(wp.Sales_Order__c);
            }
            if(wp.Product_Master__c  != null){
                prodMaster.add(wp.Product_Master__c);
            }
            
        }
       
        if(!prodMaster.isEmpty()){
        List<Product_Master__c> prodMasList = new List<Product_Master__c>();
     
            
          
            List<Product_Master__c> prodMasterList = [
                SELECT Id, Name, Sales_Order__c, Stock_Quantity__c, 
                       Total_Reserved_Stock__c, Available_Stock__c 
                FROM Product_Master__c 
                WHERE Id IN :prodMaster
            ];
            
        
            Map<Id, Decimal> productStockMap = new Map<Id, Decimal>();
            
           
            for (Product_Master__c p : prodMasterList) {
                productStockMap.put(p.Id, p.Total_Reserved_Stock__c);
            }
            
            
            for (WMS_Products__c wp : WMSProdList) {
                if (productStockMap.containsKey(wp.Product_Master__c)) {
                    Decimal currentStock = productStockMap.get(wp.Product_Master__c);
                    
                 
                    Decimal newStock = currentStock - wp.Quantity__c;
                    productStockMap.put(wp.Product_Master__c, newStock >= 0 ? newStock : 0);
                }
            }
            
      
            for (Id productId : productStockMap.keySet()) {
                Decimal updatedStock = productStockMap.get(productId);
                
                Product_Master__c updatedProduct = new Product_Master__c(
                    Id = productId,
                    Total_Reserved_Stock__c = updatedStock
                );
                
                prodMasList.add(updatedProduct);
            }
            
           
            if (!prodMasList.isEmpty()) {
                update prodMasList;
            }
            
            set<id> prIds = new set<id>();
            
            for(Product_Master__c p : prodMasList){
                prIds.add(p.id);
                
            }
              updateAvailableCount(prIds);
        }
          

    }
    
    @future
    public static void updateAvailableCount(set<id>  ids ){
        
        List<Product_Master__c>  prdList = new List<Product_Master__c>();
         List<Product_Master__c>  prodMasterList = [SELECT Id, Name, Sales_Order__c, Stock_Quantity__c, Total_Reserved_Stock__c, Available_Stock__c FROM Product_Master__c where id IN:ids ];
        for(Product_Master__c p: prodMasterList){
              if(p.Total_Reserved_Stock__c  <= 0 ){
                p.Available_Stock__c = p.Stock_Quantity__c;
            }else{
                 p.Available_Stock__c = p.Stock_Quantity__c - p.Total_Reserved_Stock__c;
            }
            
            prdList.add(p);
        }
        update prdList;
    }  
}