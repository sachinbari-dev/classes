@isTest
public class SecurePackagingESInventoryBatchTest {

      
      @isTest
    public static void securePackagingBatchTest(){
        
        
        Secure_packaging__c sp = new Secure_packaging__c();
            sp.Name = 'DS10000';
            sp.Status__c = 'Available';
            sp.RecordTypeId =  Schema.SObjectType.secure_packaging__c.getRecordTypeInfosByName().get('Shipping Label').getRecordTypeId();
            sp.Type_of_Packaging__c = 'Shipping Label';
            sp.Digital__c = true;
            insert sp;
        
        string lastRecordName = sp.Name ;
        integer i = 0;
        Integer totalRecordToInsert = 20;      
       
        try{
           Test.startTest();
            ES_SecurePackagingHandler.createShippingLabel(totalRecordToInsert, lastRecordName);
            ES_SecurePackagingHandler.genNextNameRecord(lastRecordName,  i);
            SecurePackagingESInventoryBatch bc = new SecurePackagingESInventoryBatch();
             id jobid =  database.executeBatch(bc,10);
          Test.stopTest();
        }catch (exception e){
            system.debug('Error message' + e);
        }
        
    }
}