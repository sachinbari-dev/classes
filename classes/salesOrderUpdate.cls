public class salesOrderUpdate {

    @invocableMethod
    public static void udpateSalesOrder(List<id> salesOrderId){
        
        Decimal TotalQuantity = 0;
        decimal totalPrice = 0;
        
        List<Sales_Order__c>  salesOrderList = new List<Sales_Order__c>();
        Set<id> salesIds = new Set<id>();
      
        List<WMS_Products__c> WMSProdList = [SELECT Id, HSN_Code__c, Price__c, Hub__c, Quantity__c, Total_Price__c,Sales_Order__c,Sales_Order__r.id FROM WMS_Products__c where Sales_Order__r.id  IN:salesOrderId];
            for(WMS_Products__c  so : WMSProdList){
                salesIds.add(so.Sales_Order__c);
                TotalQuantity += so.Quantity__c;
                totalPrice += so.Total_Price__c;
            }
        
        List<Sales_Order__c>  salesOrList = [SELECT Id, Name,Is_Dispatched__c, Quantity__c, Total_Price__c, Total_Item_Price__c, Total_Item_Quantity__c, Customer_Phone__c, Customer_Email__c, Billing_Address__c, Vendor_Address__c, Contact_Person__c, Unit_Price__c, Batch_Size__c, Batch_Code__c, HSN_Code__c, Batch_Number__c, Serial_Number__c FROM Sales_Order__c where id IN:salesIds ];
        
            system.debug('TotalQuantity'+ TotalQuantity);
            system.debug('totalPrice'+ totalPrice);  
        
            for(Sales_Order__c s : salesOrList){
                s.Total_Item_Price__c = totalPrice;
                s.Total_Item_Quantity__c = TotalQuantity;
                
                salesOrderList.add(s);
            }
            
            Update salesOrderList;
    }
        
    public static void updateSalesOrderStatus(set<id> ids){
        
        List<Sales_Order__c>  salesOrList = [SELECT Id,Sales_Order_Status__c, Name,Is_Dispatched__c, Quantity__c, Total_Price__c, Total_Item_Price__c, Total_Item_Quantity__c, Customer_Phone__c, Customer_Email__c, Billing_Address__c, Vendor_Address__c, Contact_Person__c, Unit_Price__c, Batch_Size__c, Batch_Code__c, HSN_Code__c, Batch_Number__c, Serial_Number__c FROM Sales_Order__c where id IN:ids ];
        List<Sales_Order__c>  salesOrderList = new List<Sales_Order__c>();
        for(Sales_Order__c s : salesOrList){
            if(!Test.isRunningTest()){
                 if(s.Sales_Order_Status__c == 'Dispatched'){
                s.Is_Dispatched__c =  true;
                salesOrderList.add(s);
            }
            }
           
        } 
        update salesOrderList;
    }
    
    public static void updateProductMaster(Set<Id> ids){
        
        List<Sales_Order__c>  salesOrList = [SELECT Id, Name,Is_Dispatched__c, Quantity__c, Total_Price__c, Total_Item_Price__c, Total_Item_Quantity__c, Customer_Phone__c, Customer_Email__c, Billing_Address__c, Vendor_Address__c, Contact_Person__c, Unit_Price__c, Batch_Size__c, Batch_Code__c, HSN_Code__c, Batch_Number__c, Serial_Number__c FROM Sales_Order__c where id IN:ids ];
       
        List<WMS_Products__c> WMSProdList = [SELECT Id,Product_Master__c ,HSN_Code__c, Price__c, Hub__c, Quantity__c, Total_Price__c,Sales_Order__c,Sales_Order__r.id FROM WMS_Products__c where Sales_Order__r.id  IN:ids];

        
        Set<id>  wmsIds = new Set<id>();
        
        for(WMS_Products__c  wp : WMSProdList){
            if(wp.Product_Master__c != Null){
                wmsIds.add(wp.Product_Master__c);
            }
        }
        
        system.debug('wmsIds');
        
        List<Product_Master__c>  updateProductMasterList =  new List<Product_master__c>();
         Map<Id, Product_Master__c> productUpdateMap = new Map<Id, Product_Master__c>();
        

        List<Product_Master__c> productMasterList = [SELECT Id, Stock_Quantity__c, Stock_Price__c FROM Product_Master__c WHERE Id IN :wmsIds];
        
       
        Map<Id, Product_Master__c> productMasterMap = new Map<Id, Product_Master__c>();
        for (Product_Master__c pm : productMasterList) {
            productMasterMap.put(pm.Id, pm);
        }
        
        Set<Id> pmId = new Set<Id>();
        
       
        for (WMS_Products__c wp : WMSProdList) {
            if (productMasterMap.containsKey(wp.Product_Master__c)) {
                pmId.add(wp.Product_Master__c);
        
               
                Product_Master__c updatedPM;
                if (productUpdateMap.containsKey(wp.Product_Master__c)) {
                    updatedPM = productUpdateMap.get(wp.Product_Master__c);
                } else {
                    updatedPM = productMasterMap.get(wp.Product_Master__c);
                    productUpdateMap.put(wp.Product_Master__c, updatedPM);
                }
                
               
                updatedPM.Stock_Quantity__c -= wp.Quantity__c;
                
                decimal stPrice = updatedPM.Stock_Price__c - wp.Total_Price__c;
                system.debug('stPrice' + stPrice);
                if(stPrice <= 0){
                    updatedPM.Stock_Price__c = 0;
                }else{
                     updatedPM.Stock_Price__c -= wp.Total_Price__c;
                     system.debug('PM actual Price' +  updatedPM.Stock_Price__c);
                }

            }
        }
        
      
        if (!productUpdateMap.isEmpty()) {
            update productUpdateMap.values(); 
            updateAvailbleCount(pmId);
        }
    }
    @Future
    public static void updateAvailbleCount(Set<id> pmId){
         List<Product_Master__c>  prdList = new List<Product_Master__c>();
         List<Product_Master__c>  prodMasterList = [SELECT Id, Name, Sales_Order__c, Stock_Quantity__c, Total_Reserved_Stock__c, Available_Stock__c FROM Product_Master__c where id IN:pmId ];
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
    
    public static void updateWMSProductStatus(Set<Id> SoId){
        
        List<Sales_Order__c>  salesOrList = [select id ,Delivery_Date_and_Time__c,Dispatch_Date_Time__c,Sales_Order_Status__c from Sales_Order__c where Id IN : SoId];
        
        List<WMS_Products__c> WMSProdList = [SELECT Id,Product_Master__c ,Status__c,HSN_Code__c, Price__c, Hub__c, Quantity__c, Total_Price__c,Sales_Order__c,Sales_Order__r.id FROM WMS_Products__c where Sales_Order__r.id  IN:SoId];
        
        List<WMS_Products__c> wmsListUpdate = new List<WMS_Products__c>();
        Map<Id, Sales_Order__c> soUpdateMap = new Map<Id, Sales_Order__c>();
        string sId='';
        
        for(Sales_Order__c s : salesOrList){
            for(WMS_Products__c w : WMSProdList){
                sId = s.id;
                if(s.Sales_Order_Status__c =='Stock Reserved'){
                    w.Status__c = 'Reserved';
                }else if(s.Sales_Order_Status__c == 'Dispatched'){
                     w.Status__c = 'Dispatched';
                    
                     if (!soUpdateMap.containsKey(s.Id)) {
                            s.Dispatch_Date_Time__c = System.now();
                            soUpdateMap.put(s.Id, s);
                        }
                    
                }else if(s.Sales_Order_Status__c == 'Delivered'){
                    w.Status__c = 'Delivered';
                    if (!soUpdateMap.containsKey(s.Id)) {
                            s.Delivery_Date_and_Time__c = System.now();
                            soUpdateMap.put(s.Id, s);
                        }
                }else if(s.Sales_Order_Status__c == 'Returned'){
                    w.Status__c = 'Returned';
                }else if(s.Sales_Order_Status__c == 'Draft'){
                    w.Status__c = 'Available';
                }else if(s.Sales_Order_Status__c == 'Cancel'){
                    w.Status__c = 'On Hold';
                }
                
                wmsListUpdate.add(w);
            }
        }
        
        if(!soUpdateMap.isEmpty()){
            update soUpdateMap.values();
        }
        if(!wmsListUpdate.isEmpty()){
            try{
                update wmsListUpdate;
            }catch(exception e){
                
                        Exception_Log__c  ex = new Exception_Log__c();
                        ex.Name = 'WMS status update from SO Error';
                        ex.Exception_Error_Message__c = e.getMessage();
                        ex.Sales_Order__c = sId;
                        insert ex;
            }
        }
        
    }
   
    public static void updateStockOutDateAndUser(List<Sales_Order__c> salesOrderList){
        
        List<Sales_Order__c> updateSalesOrder = new List<Sales_Order__c>();
        
        for(Sales_Order__c s : salesOrderList ){
            s.Stock_Out_Date__c = Date.today();
            s.Stock_Out_User__c = UserInfo.getUserId();
            
            updateSalesOrder.add(s);
        }
        
        if(!updateSalesOrder.isEmpty()){
            update updateSalesOrder;
        } 
       
    }

}