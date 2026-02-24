//Created By MohammadRafi Khan.
@isTest
public class TEST_TMS_ScanShippingNoteNumber {
    
    @isTest
    static void testGetShipmentRecord() {
        
        Secure_Packaging__c spObj = new Secure_Packaging__c();
        spObj.Name = 'TestSNN';
        spObj.Status__c = 'Available';
        spObj.RecordType = [SELECT Id FROM RecordType WHERE Name = 'Shipping Label' LIMIT 1];
        insert spObj;
        
        Secure_Packaging__c result = TMS_ScanShippingNoteNumber.getShipmentRecord('TestSNN', 'testPickup');
        
        try {
            TMS_ScanShippingNoteNumber.getShipmentRecord('TesttSNN', 'testPickup');
        } catch (AuraHandledException ex) {
            System.assertEquals('Invalid Shipping Note Number', ex.getMessage());
        }
        
    }
    
}