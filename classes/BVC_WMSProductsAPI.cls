@RestResource(urlMapping='/WMSProducts/')
global with sharing class BVC_WMSProductsAPI {

    global class ProductWrapper {
        public String ProductMasterId;           
        public String Name;  
        public String  CreatedThrough;  
        public String SerialNumber;  
        public Integer Quantity;     
        public Decimal Price;        
        public String apendName;     
    }

    global class ProductRequest {
        public String PurchaseOrderId;
        public List<ProductWrapper> Products;
    }

    global class APIResponse {
        public Boolean success;
        public String message;
        public Integer createdCount;
        public List<Id> createdIds = new List<Id>();
        public List<String> errors = new List<String>();
    }

    @HttpPost
    global static APIResponse saveProducts() {

        APIResponse apiRes = new APIResponse();

        try {
            ProductRequest req =(ProductRequest) JSON.deserialize(RestContext.request.requestBody.toString(), ProductRequest.class);

            if (req == null || String.isBlank(req.PurchaseOrderId)) {
                apiRes.success = false;
                apiRes.message = 'PurchaseOrderId is mandatory';
                return apiRes;
            }

            Purchase_Order__c po = [SELECT Id,Shipping_Partner__c,Shipping_Partner__r.Name,Customer_Address__c,Hub__c FROM Purchase_Order__c WHERE Id = :req.PurchaseOrderId LIMIT 1];

            if (po.Shipping_Partner__c == null) {
                apiRes.success = false;
                apiRes.message = 'Customer is mandatory for WMS Product record Creation, plz check customer on Purchase Order.';
                return apiRes;
            }

            if (req.Products == null || req.Products.isEmpty()) {
                apiRes.success = false;
                apiRes.message = 'Products list is mandatory';
                return apiRes;
            }

            List<WMS_Products__c> wmsProductsToInsert = new List<WMS_Products__c>();

            for (ProductWrapper eachProduct : req.Products) {

                if (eachProduct == null) continue;

                if (eachProduct.Quantity == null || eachProduct.Quantity <= 0) {
                    continue;
                }

                if (String.isBlank(eachProduct.SerialNumber)) {
                    apiRes.success = false;
                    apiRes.message = 'Serial Number is mandatory for product: ' + eachProduct.Name;
                    return apiRes;
                }

                String inputSerial = eachProduct.SerialNumber.trim().toUpperCase();

                Pattern p = Pattern.compile('^(.*?)(\\d+)$');
                Matcher m = p.matcher(inputSerial);

                if (!m.matches()) {
                    apiRes.success = false;
                    apiRes.message = 'Invalid serial format for product: ' + eachProduct.Name;
                    return apiRes;
                }

                String prefix = m.group(1);
                Integer startNo = Integer.valueOf(m.group(2));

                Set<String> productSerialSet = new Set<String>();

                for (Integer i = 0; i < eachProduct.Quantity; i++) {
                    productSerialSet.add(prefix + (startNo + i));
                }

          
                List<WMS_Products__c> existing = [SELECT Serial_Number__c, Customer__c FROM WMS_Products__c WHERE Serial_Number__c IN :productSerialSet AND Customer__c = :po.Shipping_Partner__c];

                if (!existing.isEmpty()) {
                    apiRes.success = false;
                    apiRes.message = 'Series is already available in database for product: '+ eachProduct.Name + ' for Customer ' + po.Shipping_Partner__r.Name;
                    return apiRes;
                }

                for (String serial : productSerialSet) {

                    WMS_Products__c productRecord = new WMS_Products__c();

                    productRecord.Name = String.isNotBlank(eachProduct.apendName)
                        ? eachProduct.Name + ' ' + eachProduct.apendName
                        : eachProduct.Name;

                    productRecord.Serial_Number__c = serial;
                    productRecord.Product_Master__c = (id) eachProduct.ProductMasterId;
                    productRecord.Purchase_Order__c = po.Id;
                    productRecord.Hub__c = po.Hub__c;
                    productRecord.WMS_Product_Created_Through__c = eachProduct.CreatedThrough;
                    productRecord.Customer__c = po.Shipping_Partner__c;
                    productRecord.Shipping_Address__c = po.Customer_Address__c;

                    productRecord.Price__c = eachProduct.Price;
                    productRecord.Quantity__c = 1;

                    wmsProductsToInsert.add(productRecord);
                }
            }

            if (!wmsProductsToInsert.isEmpty()) {
                insert wmsProductsToInsert;

                apiRes.success = true;
                apiRes.message = 'WMS Products created successfully';
                apiRes.createdCount = wmsProductsToInsert.size();

                for (WMS_Products__c x : wmsProductsToInsert) {
                    apiRes.createdIds.add(x.Id);
                }
                return apiRes;
            }

            apiRes.success = true;
            apiRes.message = 'No products to insert';
            apiRes.createdCount = 0;
            return apiRes;

        } catch (Exception e) {
            apiRes.success = false;
            apiRes.message = 'Error: ' + e.getMessage();
            apiRes.errors.add(e.getStackTraceString());
            return apiRes;
        }
    }
}