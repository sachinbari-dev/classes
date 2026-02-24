@isTest
public class BVC_IqlooGetMasterPin_Test {

    @isTest
    public static void testMethod1(){
        
        
         Id userId=UserInfo.getUserId();
          secure_packaging__C sp = new secure_packaging__C(
            Name = 'SP2X1889b31c',
            Status__c = 'Available',
            Digital__c = false,
            Consumed_in_Universe__c = false,
            Type_of_Packaging__c = 'Lock',
            RecordTypeId = Schema.SObjectType.secure_packaging__c.getRecordTypeInfosByName().get('Shield Lock').getRecordTypeId()
        );
        insert sp;

        
        Pickup__c p = new Pickup__c(
            pickup_Status__c = 'Created',
            
            Lock_ID__c = sp.Id
        );
        insert p;
          List<id>  idList1 = new List<id>();
        Pickup__c  p2 = [select id, Pickup_Assigned_To__c,Lock_ID__c,Lock_ID__r.name,pickup_Status__c from Pickup__c where  id=: p.id];
        p2.Pickup_Assigned_To__c = userId;
        p2.Pickup_Status__c = 'Assigned';
        
        update p2;
        idList1.add(p2.id);
        
        shipment__c s = new shipment__c();
        s.LOCK_ID__c ='SP2X1889b31c';
        
        insert s;
        List<id>  idList = new List<id>();
        idList.add(s.id);
        
        test.startTest();
        BVC_IqlooGetMasterPin.getMasterPin(idList1);
        BVC_IqlooGetMasterPin.getMasterPin(idList);
        test.stopTest();
    }
}