public class WMSproductDispatchToCancel {

    @invocableMethod
    public static void dispatchToCancel(List<id> WmsID){
        
            
       List<WMS_Products__c> WMSProdList = [SELECT Id, Name,Price__c, Product_Master__c, Hub__c, Quantity__c, Sales_Order__c,Sales_Order__r.Sales_Order_Status__c, Total_Price__c, Batch_Size__c, Serial_Number__c, Weight_UOM__c, Weight__c, Stock_Out_User__c, Stock_in_User__c,Sales_Order__r.id FROM WMS_Products__c where Sales_Order__r.id In:WmsID];
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
            List<Product_Master__c> prodMasList =  new List<Product_Master__c>();
                        
            Map<Id, Product_Master__c> productUpdateMap = new Map<Id, Product_Master__c>();
            set<id> ids = new Set<id>();
           
            List<Product_Master__c> prodMasterList = [ SELECT Id, Name, Stock_Price__c, Sales_Order__c, Stock_Quantity__c, Total_Reserved_Stock__c, Available_Stock__c 
                                                        FROM Product_Master__c WHERE Id IN :prodMaster ];
            
           
            for (Product_Master__c p : prodMasterList) {
                productUpdateMap.put(p.Id, p);
                ids.add(p.id);
            }
            
            // Update values using WMS_Products__c
            for (WMS_Products__c wp : WMSProdList) {
                if (productUpdateMap.containsKey(wp.Product_Master__c)) {
                    Product_Master__c p = productUpdateMap.get(wp.Product_Master__c);
                    p.Stock_Quantity__c += wp.Quantity__c;
                    p.Stock_Price__c += wp.Total_Price__c;
                }
            }
            
            // Update only if the map is not empty
            if (!productUpdateMap.isEmpty()) {
                update productUpdateMap.values();
                updateAvailableCount(ids);
            }
             
        }
    }
    
        @future
    public static void updateAvailableCount(set<id>  ids ){
        
        List<Product_Master__c>  prdList = new List<Product_Master__c>();
         List<Product_Master__c>  prodMasterList = [SELECT Id, Name, Sales_Order__c, Stock_Quantity__c, Total_Reserved_Stock__c, Available_Stock__c FROM Product_Master__c where id IN:ids ];
        for(Product_Master__c p: prodMasterList){
            if(p.Total_Reserved_Stock__c <= 0){
                p.Available_Stock__c = p.Stock_Quantity__c;
            }else{
                p.Available_Stock__c = p.Stock_Quantity__c - p.Total_Reserved_Stock__c;
            }
            prdList.add(p);
        }
        update prdList;
    }
 
}