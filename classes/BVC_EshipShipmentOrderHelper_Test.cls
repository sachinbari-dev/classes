@isTest
private class BVC_EshipShipmentOrderHelper_Test {

    @TestSetup
    private static void setupData(){
        
        Account Acc = New Account();
        Acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        Acc.Name = 'TITAN COMPANY LIMITED - Billing EQUPNB123K';
        Acc.BVC_Company_Type__c = 'Domestic';        
        Acc.KYC_Indicator_for_Domestic_Flag__c = true;
        Acc.Customer_Status__c = 'Active';
        Acc.Category__c = 'Manufacturer';
        Acc.Type_Of_Customer__c = 'Both';
        Acc.BVC_Legal_Entity__c = 'B.V.C. Logistics Private Limited';
        Acc.Primary_Customer_Email__c = 'abc@sdcn.com';
        Acc.Phone = '94746367837';
        Acc.BillingState = 'MH';
        Acc.BillingPostalCode = '431122'; 
        Acc.First_Name__c = 'billing firstname';               
        Acc.Last_Name__c = 'billing lst name';
        Acc.Name_As_Per_PAN_Manual_Input__c = 'new cust';
        Acc.PAN_Number_of_Entity__c = 'EQUPNB123K';   
        
        Insert Acc;
        
        Shipment__c ship = new shipment__c();
        ship.Docket_No__c = 'BG464655';
        ship.From_City__c = 'Pune';
        ship.To_City__c = 'Mumbai';
        ship.No_Of_Attempts__c = 2;
        ship.Declared_Value__c = 6454;
        ship.Shipment_Type__c = 'Intercity';
        ship.Payment_Mode__c = 'COD';
        ship.Customer__c = Acc.id;
        ship.RecordTypeId = Schema.SObjectType.Shipment__c.getRecordTypeInfosByName().get('eSHIP').getRecordTypeId();
        ship.Created_through_BVCeSHIP__c = true;
        ship.COD_Amount__c = 6456;
        ship.Total_Invoice_Value__c = 5655756;
        
        insert ship;
       
       
    }
    
  @isTest
    private static void testMethod1(){
        
        Shipment__c ship =[select id, name from shipment__c LIMIT 1];
        
        try{
            
            Test.startTest();
              BVC_EshipShipmentOrderHelperButton.callEshipOrderGeneratorBatch();
              BVC_EshipShipmentOrderHelper  bc = new BVC_EshipShipmentOrderHelper();
              id jobId = Database.executeBatch(bc,2);
            

            
            Test.stopTest();
            
           system.assertEquals(true,ship.Verified_for_Billing__c);
            
        }catch(exception e){
            
            system.debug('Error Message' +  e.getMessage());
        }
      
    }
}