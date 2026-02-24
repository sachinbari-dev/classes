public class WMSProductTriggerHandler {

       @invocableMethod
    public static void avoidWMSrecordCreation(List<id> WmsID){
       
       List<WMS_Products__c> WMSProdList = [SELECT Id, Name, Product_Master__c, Hub__c, Quantity__c, Sales_Order__c,Sales_Order__r.Sales_Order_Status__c, Total_Price__c, Batch_Size__c, Serial_Number__c, Weight_UOM__c, Weight__c, Stock_Out_User__c, Stock_in_User__c,Sales_Order__r.id FROM WMS_Products__c where Sales_Order__r.id In:WmsID];
        Set<id>  wmsIds = new Set<id>();
        List<id> prodMaster = new List<id>();
        
        for(WMS_Products__c  wp :WMSProdList){
            if(wp.Sales_Order__c  != null && wp.Sales_Order__r.Sales_Order_Status__c == 'Stock Reserved' ){
                wmsIds.add(wp.Sales_Order__c);
            }
            if(wp.Product_Master__c  != null){
                prodMaster.add(wp.Product_Master__c);
            }
            
        }
       
        if(!wmsIds.isEmpty()){
             
              List<sales_Order__c> salesOrderList = [SELECT Id, Name,Sales_Order_Status__c, Product__c, Quantity__c, Unit_Price__c, Total_Item_Quantity__c, Total_Item_Price__c, 
                                               Total_Price__c, Is_Dispatched__c FROM Sales_Order__c where Sales_Order_Status__c = 'Draft' AND ID IN: wmsIds ];
              for(sales_Order__c so: salesOrderList){
                
             }
             
        }
        
        if(!prodMaster.isEmpty()){
           List<Product_Master__c> prodMasList = new List<Product_Master__c>();
            List<Product_Master__c> prodMasterList = [SELECT Id, Name, Sales_Order__c, Stock_Quantity__c, Total_Reserved_Stock__c, Available_Stock__c 
                                                     FROM Product_Master__c WHERE Id IN: prodMaster];
            
            Decimal stock = 0;
            Map<Id, Decimal> stockMap = new Map<Id, Decimal>();
            
            for (WMS_Products__c wp : WMSProdList) {
                if (stockMap.containsKey(wp.Product_Master__c)) {
                    stockMap.put(wp.Product_Master__c, stockMap.get(wp.Product_Master__c) + wp.Quantity__c);
                } else {
                    stockMap.put(wp.Product_Master__c, wp.Quantity__c);
                }
            }
            
            for (Product_Master__c p : prodMasterList) {
                if (stockMap.containsKey(p.Id)) {
                    p.Total_Reserved_Stock__c += stockMap.get(p.Id);
                    prodMasList.add(p); 
                }
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
            decimal avStock = 0;
               avStock = p.Stock_Quantity__c - p.Total_Reserved_Stock__c;
            
            if(avStock <= 0 ){
                p.Available_Stock__c = 0;
            }else{
                p.Available_Stock__c =  p.Stock_Quantity__c - p.Total_Reserved_Stock__c;
            }
            
            
            prdList.add(p);
        }
        update prdList;
    }
}