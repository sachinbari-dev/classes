public class AddProductsHelper {

    @AuraEnabled
    public static List<Product_Master__c> getProductMasterList(String productCat) {
        
        return [SELECT Id, Name, Stock_Price__c FROM Product_Master__c WHERE Category__c = :productCat];
    }

    @AuraEnabled
    public static String saveProducts(String poId, String productsList) {

        String res = 'success';
  
        List<ProductWrapper> producRecordstList = (List<ProductWrapper>) JSON.deserialize(productsList, List<ProductWrapper>.class);
        List<Purchase_Order__c> poLists  = new  List<Purchase_Order__c> ();
        Purchase_Order__c po = [SELECT Id,name,Shipping_Partner__r.Id,Customer_Address__r.Id,Shipping_Partner__r.name,hub__c,hub__r.name,hub__r.id FROM Purchase_Order__c WHERE Id = :poId];

        if (producRecordstList == null || producRecordstList.isEmpty()) {
            return res;
        }

        List<WMS_Products__c> wmsProductsToInsert = new List<WMS_Products__c>();
         List<WMS_Products__c> wmsProductsToInsert1 = new List<WMS_Products__c>();
        for (ProductWrapper eachProduct : producRecordstList) {

            if (eachProduct.Quantity == null || eachProduct.Quantity <= 0) {
                continue;
            }

           
            String inputSerial = eachProduct.SerialNumber.trim().toUpperCase();

            Pattern p = Pattern.compile('^(.*?)(\\d+)$');
            Matcher m = p.matcher(inputSerial);

            if (!m.matches()) {
                return 'Invalid serial format for product: ' + eachProduct.Name;
            }

            String prefix = m.group(1);                
            Integer startNo = Integer.valueOf(m.group(2)); 

           
            Set<String> productSerialSet = new Set<String>();

            for (Integer i = 0; i < eachProduct.Quantity; i++) {
                productSerialSet.add(prefix + (startNo + i));
            }

             // check duplicate serial number based on customers
            List<WMS_Products__c> existing = [SELECT Serial_Number__c,Customer__c,Customer__r.id FROM WMS_Products__c WHERE Serial_Number__c IN :productSerialSet AND Customer__c = :po.Shipping_Partner__c];
             List<WMS_Products__c> wmsProductsToInsert2 = new List<WMS_Products__c>();
            if (!existing.isEmpty()) {
                return 'Series is already available in database for product: ' + eachProduct.Name + ' for Customer '+ po.Shipping_Partner__r.name ;
               
            }

           
            for (String serial : productSerialSet) {

                WMS_Products__c productRecord = new WMS_Products__c();
                productRecord.Name =String.isNotBlank(eachProduct.apendName) ? eachProduct.Name + ' ' + eachProduct.apendName: eachProduct.Name +' '+ po.name;
                productRecord.Serial_Number__c = serial;
                productRecord.Product_Master__c = eachProduct.Id;
                productRecord.Purchase_Order__c = po.Id;
                productRecord.hub__c = po.hub__r.id;
                if(po.Shipping_Partner__c != null){
                       productRecord.Customer__c = po.Shipping_Partner__r.Id;
                }else{
                     return 'Customer is mandatory for WMS Product record Creation, plz check customer on Purchase Order.';
                }
             
                productRecord.Shipping_Address__c = po.Customer_Address__r.Id;
                productRecord.Price__c = eachProduct.Price;
                productRecord.Quantity__c = 1;

                wmsProductsToInsert.add(productRecord);
            }
        }

      
        if (!wmsProductsToInsert.isEmpty()) {
            try{
                insert wmsProductsToInsert;
            }catch(Exception e){
                Exception_Log__c  ex = new Exception_Log__c();
                ex.Name = 'Create WMS product Error';
                ex.Exception_Error_Message__c = e.getMessage();
                ex.Purchase_Order__c = po.id;
                insert ex;
            }
            
        }

        return res;
    }

    public class ProductWrapper {
        @AuraEnabled public String Id;
        @AuraEnabled public String Name;
        @AuraEnabled public Decimal Price;
        @AuraEnabled public Decimal TotalPrice;
        @AuraEnabled public String SerialNumber;
        @AuraEnabled public Integer Quantity;
        @AuraEnabled public String apendName;
        @AuraEnabled public String startSL;
        @AuraEnabled public String midSL;
        @AuraEnabled public Integer endSL;
    }
}