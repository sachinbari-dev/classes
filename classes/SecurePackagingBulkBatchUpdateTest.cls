@isTest
public class SecurePackagingBulkBatchUpdateTest {

    @isTest
    public static void testSecurePackagingBatch(){
        
        
         List<Secure_Packaging__c> securePackList = new List<Secure_Packaging__c>();
        
        secure_packaging__C sp1 = new secure_packaging__C();
        sp1.Digital__c = true;
        sp1.Consumed_in_Universe__c = false;
        sp1.Name = 'OS32424';
        sp1.Status__c = 'Available';
        sp1.Type_of_Packaging__c = 'Shipping Label';
        sp1.RecordTypeId = Schema.SObjectType.secure_packaging__c.getRecordTypeInfosByName().get('Shipping Label').getRecordTypeId();
       
       
        securePackList.add(sp1);
        
        insert securePackList;
        
        
        List<Id> recordIds = new List<Id>();
        for (Secure_Packaging__c sp : securePackList) {
            recordIds.add(sp.Id);
        }
        
        
        SecurePackagingBulkBatchUpdate batch = new SecurePackagingBulkBatchUpdate(recordIds);
        
        
        Test.startTest();
        Database.executeBatch(batch, 2); 
        Test.stopTest();
        
       
        List<Secure_Packaging__c> updatedRecords = [SELECT Id, Consumed_In_Universe__c FROM Secure_Packaging__c WHERE Id IN :recordIds];
        for (Secure_Packaging__c record : updatedRecords) {
            System.assertEquals(true, record.Consumed_In_Universe__c, 'The record should be marked as consumed.');
        }
      
    }
}