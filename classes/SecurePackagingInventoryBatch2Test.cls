@isTest
public class SecurePackagingInventoryBatch2Test {

    @isTest
    public static void testSecurePackagingBatch2(){
        
        secure_packaging__c sp = new secure_packaging__c();
         sp.Name = 'DS2000';
         sp.Digital__c = true;
         sp.Status__c = 'Available';
         sp.Type_of_Packaging__c = 'Shipping Label';
         sp.RecordTypeId = Schema.SObjectType.secure_packaging__c.getRecordTypeInfosByName().get('Shipping Label').getRecordTypeId();
         
        insert sp;
        
        String lastRecordName = sp.Name;
        Integer  availableCountThreshold = 20;
        
        try{
            
        Test.StartTest();
            
          SecurePackagingHandler.createShippingLabel(availableCountThreshold, lastRecordName);
            
            SecurePackagingInventoryBatch2 bc = new SecurePackagingInventoryBatch2();
            id jbId = database.executeBatch(bc,10);
                         
        Test.StopTest();
            
        }catch(exception e){
             system.debug('Error message' + e);
        }
        
        
    }
}