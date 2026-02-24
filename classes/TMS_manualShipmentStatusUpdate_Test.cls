@isTest
private class TMS_manualShipmentStatusUpdate_Test {

    @TestSetup
    private static void setupTestData(){
        
        Id currentUserId = UserInfo.getUserId();
        User u =[SELECT Id, LastName, FirstName, Name, ProfileId FROM User where id=:currentUserId];

        
        secure_packaging__c sp1 = new secure_packaging__c();
          sp1.Name = 'GS084756';
          sp1.Type_of_Packaging__c = 'Secure Bag';
          sp1.Status__c ='Available';
          sp1.RecordTypeId = Schema.SObjectType.secure_packaging__c.getRecordTypeInfosByName().get('Secure Bag').getRecordTypeId(); 
        
          insert sp1;
        
        secure_packaging__c sp2 = new secure_packaging__c();
          sp2.Name = 'GS084753';
          sp2.Type_of_Packaging__c = 'Secure Bag';
          sp2.Status__c ='Available';
          sp2.RecordTypeId = Schema.SObjectType.secure_packaging__c.getRecordTypeInfosByName().get('Secure Bag').getRecordTypeId();
           
        
          insert sp2;
         secure_packaging__c sp3 = new secure_packaging__c();
          sp3.Name = 'HG86466';
          sp3.Type_of_Packaging__c = 'Secure Seal';
          sp3.Status__c ='Available';
          sp3.RecordTypeId = Schema.SObjectType.secure_packaging__c.getRecordTypeInfosByName().get('Secure Seal').getRecordTypeId();
          
        
          insert sp3;
        
         shipment__c s =  new shipment__c();
          s.tracking_status__c = 'Origin Hub';
          s.Shipping_Note_Number__c = sp3.name;
         s.Delivery_Route_Assigned_To__c = u.id;
        
          insert s;
        
        secure_bag__c sb1 = new secure_bag__c();
         sb1.Secure_Bag__c  = sp1.Id;
         sb1.Shipment__c = s.Id;
         sb1.Current_Scan_Loction__c = 'Origin Hub';
        
        insert sb1;
        
         secure_bag__c sb2 = new secure_bag__c();
         sb2.Secure_Bag__c  = sp2.Id;
         sb2.Shipment__c = s.Id;
         sb2.Current_Scan_Loction__c = 'Picked Up';
        
        insert sb2;
        
             
    }
    
    @isTest
    private static void testmethod1(){
         List<shipment__c> shipmentList  = new  List<shipment__c>();
        shipment__c s =[select id,tracking_status__c,Shipping_Note_Number__c from shipment__c LIMIT 1];
        
        shipmentList.add(s);
        
        system.assertEquals('Origin Hub',s.Tracking_Status__c ,'Tracking status is not same');
        system.assertEquals('HG86466',s.Shipping_Note_Number__c,'Shipping note number is not same');
        
        test.StartTest();
        try{
            TMS_manualShipmentStatusUpdate.validateManualTrackingStatusUpdate(shipmentList);
        
        }catch(exception e){
            system.debug('Error message' + e.getMessage());
        }
         
        Test.StopTest();
        
    }
 @isTest
    Private static void testmethod2(){
        
        List<shipment__c> shipmentList  = new  List<shipment__c>();
        shipment__c s =[select id,tracking_status__c,Shipping_Note_Number__c from shipment__c LIMIT 1];
        
        
         shipmentList.add(s);

           test.StartTest();
        try{
           
            TMS_manualShipmentStatusUpdate.avoidDeliveryAssign(shipmentList);
        }catch(exception e){
            system.debug('Error message' + e.getMessage());
        }
         
        Test.StopTest();
    }
}