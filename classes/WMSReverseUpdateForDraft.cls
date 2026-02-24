public class WMSReverseUpdateForDraft {

    @invocableMethod
    public static void updateProductMaster(List<id> WmsID){
         
       List<WMS_Products__c> WMSProdList = [SELECT Id, Name, Product_Master__c, Hub__c, Quantity__c, Sales_Order__c,Sales_Order__r.Sales_Order_Status__c, Total_Price__c, Batch_Size__c, Serial_Number__c, Weight_UOM__c, Weight__c, Stock_Out_User__c, Stock_in_User__c,Sales_Order__r.id FROM WMS_Products__c where Sales_Order__r.id In:WmsID];
        Set<id>  wmsIds = new Set<id>();
        Set<id> prodMaster = new Set<id>();
      
        for(WMS_Products__c  wp :WMSProdList){
            if(wp.Sales_Order__c  != null && wp.Sales_Order__r.Sales_Order_Status__c == 'Draft' ){
                wmsIds.add(wp.Sales_Order__c);
            }
            if(wp.Product_Master__c  != null){
                prodMaster.add(wp.Product_Master__c);
            }
            
        }
       
        if(!prodMaster.isEmpty()){
            
                 List<Product_Master__c> prodMasList = new List<Product_Master__c>();
                List<Product_Master__c> prodMasterList = [SELECT Id, Name, Sales_Order__c, Stock_Quantity__c, 
                                                         Total_Reserved_Stock__c, Available_Stock__c 
                                                         FROM Product_Master__c WHERE Id IN: prodMaster];
                
               
                Map<Id, Product_Master__c> productUpdatesMap = new Map<Id, Product_Master__c>();
                
                for (Product_Master__c p : prodMasterList) {
                    Decimal stock = 0; 
                    Decimal reserve = 0; 
                
                    for (WMS_Products__c wp : WMSProdList) {
                        if (wp.Product_Master__c == p.Id) { 
                            stock += wp.Quantity__c;
                            reserve += wp.Quantity__c;
                        }
                    }
                
                    
                    if (!productUpdatesMap.containsKey(p.Id)) {
                        productUpdatesMap.put(p.Id, new Product_Master__c(
                            Id = p.Id,
                            Available_Stock__c = p.Available_Stock__c,
                            Total_Reserved_Stock__c = p.Total_Reserved_Stock__c
                        ));
                    }
                
                    Product_Master__c updatedProduct = productUpdatesMap.get(p.Id);
                    
                    updatedProduct.Available_Stock__c += stock;
                    updatedProduct.Total_Reserved_Stock__c = (updatedProduct.Total_Reserved_Stock__c - reserve) < 0 
                                                              ? 0 
                                                              : (updatedProduct.Total_Reserved_Stock__c - reserve);
                
                    productUpdatesMap.put(p.Id, updatedProduct); 
                }
                
                 prodMasList.addAll(productUpdatesMap.values());
                
                if (!prodMasList.isEmpty()) {
                    update prodMasList;
                }
             
        }
          

    }
    

}