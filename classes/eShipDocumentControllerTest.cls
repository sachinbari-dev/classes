@isTest
public class eShipDocumentControllerTest {

  
    private static id setupTestData(){
        
         Account acc = BVCL_TestDataFactory.createCustomer('Test','Billing',True);
      
      
        BVCQuote__c bq = new BVCQuote__c(
            Account__c = acc.Id,
            Business_Type__c = 'ACR',
            BVC_service__c = 'eSHIP',           
             RecordTypeId = Schema.SObjectType.BVCQuote__c.getRecordTypeInfosByName().get('ACR').getRecordTypeId()
          
        );
        insert bq;
        System.debug('BVC quote: ' + bq);
        
        eSHIP_Custom_Pricing__c esp = new eSHIP_Custom_Pricing__c();
          esp.ACR_Amount__c = 43.5;
          esp.BVCQuote__c = bq.id;
          esp.COD_Charges_per_shipment__c = 343;
          esp.COD_Charges_percentage_of_product__c= 4;
         
          esp.Liability_Charges__c = 43;
        
        insert esp;
        
        return bq.id;
    }
    
     @isTest
    static void eShipDocumentController() {
        
          Id quoteId = setupTestData();

        Test.startTest();
        PageReference pageRef = Page.eShipDocument;
        pageRef.getParameters().put('id', quoteId);
        Test.setCurrentPage(pageRef);

        eShipDocumentController controller = new eShipDocumentController();
        Test.stopTest();
    }
}