@RestResource(urlMapping='/productMaster/')
global with sharing  class BVC_WMSProductMasterAPI {


    global class ProductRequest {
        public String productName;
        public String productCode;
        public String category;
        public String description;
        public Decimal weight;
        public String weightUOM;
        public Decimal length;
        public Decimal height;
        public Decimal breadth;
        public String storage;
    }

   
    global class ProductResponse {
        public Boolean success;
        public String message;
        public Id productId;
    }

    @HttpPost
    global static ProductResponse createProductMaster() {

        ProductResponse response = new ProductResponse();

        try {
            ProductRequest reqData = (ProductRequest) JSON.deserialize(RestContext.request.requestBody.toString(), ProductRequest.class);

            
            if (String.isBlank(reqData.productName)) {
                return buildError('product Name is required');
            }
            if (String.isBlank(reqData.productCode)) {
                return buildError('product Code is required');
            }
            if (String.isBlank(reqData.category)) {
                return buildError('category is required');
            } 

            
            Product_Master__c pm = new Product_Master__c();
            pm.name = reqData.productName;
            pm.Product_Code__c = reqData.productCode;
            pm.Category__c     = reqData.category;
 
            pm.Description__c = reqData.description;
            pm.Weight__c      = reqData.weight;
            pm.Weight_UOM__c  = reqData.weightUOM;
            pm.Length__c      = reqData.length;
            pm.Height__c      = reqData.height;
            pm.Breadth__c     = reqData.breadth;
            pm.Storage__c     = reqData.storage;

            insert pm;

            response.success = true;
            response.message = 'Product Master created successfully';
            response.productId = pm.Id;
            return response;

        } catch (DmlException dmlEx) {
            return buildError('DML Error: ' + dmlEx.getDmlMessage(0));
        } catch (Exception e) {
            return buildError('Error: ' + e.getMessage());
        }
    }

    private static ProductResponse buildError(String msg) {
        ProductResponse r = new ProductResponse();
        r.success = false;
        r.message = msg;
        r.productId = null;
        return r;
    }
}