@isTest
public class eSHIP_SNseriesUpdateHelperTest {

       public static testmethod void test1(){
       
        Secure_Packaging__c securePackaging1 = new Secure_Packaging__c(
            Name = 'ES865674',
            Status__c = 'Available', 
            shipment__c = Null,
            Digital__c = true,
            Type_of_Packaging__c = 'Shipping Label',
            RecordTypeId = '0125g0000003dGBAAY'
        );
        insert securePackaging1;
        
        Secure_Packaging__c securePackaging2 = new Secure_Packaging__c(
            Name = 'ES76456',
            Status__c = 'Available',
            shipment__c = Null,
            Digital__c = true,
            Type_of_Packaging__c = 'Shipping Label',
            RecordTypeId = '0125g0000003dGBAAY'
        );
        insert securePackaging2;
        
        // Add more secure packaging to match the shipment count
        Secure_Packaging__c securePackaging3 = new Secure_Packaging__c(
            Name = 'ES12345',
            Status__c = 'Available',
            shipment__c = Null,
            Digital__c = true,
            Type_of_Packaging__c = 'Shipping Label',
            RecordTypeId = '0125g0000003dGBAAY'
        );
        insert securePackaging3;
        
        Shipment__c shipment1 = new Shipment__c();
        insert shipment1;
        
        Shipment__c shipment2 = new Shipment__c();
        insert shipment2;
           
            Shipment__c shipment3 = new Shipment__c();
        insert shipment3;
        
        // Ensure the shipment count matches the secure packaging count
        List<Shipment__c> shipmentList = new List<Shipment__c>{shipment1, shipment2,shipment3};
        
        Test.startTest();
        eSHIP_SNseriesUpdateHelper.updateShippingNoteNo(shipmentList);
           eSHIP_SNseriesUpdateHelper.testmehod();
        Test.stopTest();
    }
}