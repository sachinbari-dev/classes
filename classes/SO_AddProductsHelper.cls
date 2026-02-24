/**
* @File Name : AddProductsHelper.cls
* @Description : Cotroller Class for AddProducts.cls
* @Author : Sangale Govind
* @Created By : Sangale Govind
* @Created On : March 28, 2025
* @Last Modified By : Sangale Govind
* @Last Modified On : JAN 13, 2026
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | March 28, 2025 |   | Initial Version
* 1.1 | Jan 13, 2026   |   | Modified version
**/


public class SO_AddProductsHelper {

    	@AuraEnabled
	public static List<Product_Master__c> getProductMasterList(String productCat){
        	List<Product_Master__c> pmList = [select Id,Name,Stock_Price__c,Available_Stock__c from Product_Master__c where Category__c=: productCat];
		return pmList;
		
	}
	@AuraEnabled
	public static String saveProducts(String soId,List<Id> wmsIds){
        
            if (soId == null || wmsIds == null || wmsIds.isEmpty()) {
            return 'No WMS products to save';
        }
      List<WMS_Products__c> wpliists = new  List<WMS_Products__c>();
        List<WMS_Products__c> wpliists1 = new  List<WMS_Products__c>();
        
        List<WMS_Products__c> wmsList = [SELECT Id, Sales_Order__c, Status__c FROM WMS_Products__c WHERE Id IN :wmsIds];
    
           for (WMS_Products__c wms : wmsList) {
              wms.Sales_Order__c = soId; 
                
          }

        if(!wmsList.isempty()){  
            try{   
              update wmsList;
              return 'success';   
            }catch(exception e){
                
                 Exception_Log__c  ex = new Exception_Log__c();
                        ex.Name = 'add WMS product on SO';
                        ex.Exception_Error_Message__c = e.getMessage();
                       // ex.Line_Number__c = e.getLineNumber();
                        ex.Sales_Order__c = soId;
                        insert ex;
            }
            
        }
         
         return null;
        
	}	
    
   @AuraEnabled
   public static WMS_Product_DTO validateSerial(String serialNumber,String PmId,Id soId) {
     List<WMS_Products__c> wpliists = new  List<WMS_Products__c>();
        List<WMS_Products__c> wpliists1 = new  List<WMS_Products__c>();
    Sales_Order__c so = [SELECT Shipping_Partner__c, Hub__c FROM Sales_Order__c WHERE Id = :soId LIMIT 1];

   
    List<WMS_Products__c> wmsList = [SELECT Id, Name, Serial_Number__c, Status__c,Sales_Order__c,Customer__c, Hub__c,Product_Master__r.Name,Product_Master__r.Id
                                    FROM WMS_Products__c
                                    WHERE Serial_Number__c = :serialNumber
                                    AND Product_Master__c = :PmId
                                    LIMIT 1
                                ];

   
            if (wmsList.isEmpty()) {
                throw new AuraHandledException( 'No WMS product found for this serial and product');
            }
        
            WMS_Products__c wms = wmsList[0];
         
            if (wms.Status__c != 'Available')
                throw new AuraHandledException('WMS Product is not available');
            if (wms.Sales_Order__c != Null)
                throw new AuraHandledException('WMS Product is allocated to another SO');
             if (wms.Status__c == 'Reserved')
                throw new AuraHandledException('WMS Product is Reserved');
        
            if (wms.Customer__c != so.Shipping_Partner__c)
                throw new AuraHandledException('Customer is mismatch');
        
            if (wms.Hub__c != so.Hub__c)
                throw new AuraHandledException('Hub is mismatch');
        
            return new WMS_Product_DTO(wms);
  }

    public class WMS_Product_DTO {
        @AuraEnabled public Id Id;
        @AuraEnabled public String Name;
        @AuraEnabled public String SerialNumber;
        @AuraEnabled public String productMasterName;

        public WMS_Product_DTO(WMS_Products__c w) {
            Id = w.Id;
            Name = w.Name;
            SerialNumber = w.Serial_Number__c;
            productMasterName = w.Product_Master__r.Name;
        }
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