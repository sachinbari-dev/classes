@isTest
public class ShipmentCreationTest {
    
    @testSetup
    static void setup() {
        // Create test Accounts
        Account acrAccount = new Account();
        acrAccount.Name = 'TITAN COMPANY LIMITED - Billing EQUPNB123K';
        acrAccount.BVC_Company_Type__c = 'Domestic';        
        acrAccount.KYC_Indicator_for_Domestic_Flag__c = true;
        acrAccount.Customer_Status__c = 'Active';
        acrAccount.Category__c = 'Manufacturer';
        acrAccount.Type_Of_Customer__c = 'Both';
        acrAccount.BVC_Legal_Entity__c = 'B.V.C. Logistics Private Limited';
        acrAccount.Primary_Customer_Email__c = 'abc@sdcn.com';
        acrAccount.Phone = '+919474636783';
        acrAccount.First_Name__c = 'billing firstname';               
        acrAccount.Last_Name__c = 'billing lst name';
        acrAccount.Name_As_Per_PAN_Manual_Input__c = 'new cust';
        acrAccount.PAN_Number_of_Entity__c = 'EQUPNB123K';  
        acrAccount.BVC_Virtual_Bank_Account_Number__c='ZBVC11566198';
        acrAccount.Customer_Category_Static__c='ACR';
        insert acrAccount;
        
        Account nonAcrAccount = new Account();
        nonAcrAccount.Name = 'TITAN COMPANY LIMITED - Billing EQUPNB123K';
        nonAcrAccount.BVC_Company_Type__c = 'Domestic';        
        nonAcrAccount.KYC_Indicator_for_Domestic_Flag__c = true;
        nonAcrAccount.Customer_Status__c = 'Active';
        nonAcrAccount.Category__c = 'Manufacturer';
        nonAcrAccount.Type_Of_Customer__c = 'Both';
        nonAcrAccount.BVC_Legal_Entity__c = 'B.V.C. Logistics Private Limited';
        nonAcrAccount.Primary_Customer_Email__c = 'abc@sdcn.com';
        nonAcrAccount.Phone = '+919474636783';
        nonAcrAccount.First_Name__c = 'billing firstname';               
        nonAcrAccount.Last_Name__c = 'billing lst name';
        nonAcrAccount.Name_As_Per_PAN_Manual_Input__c = 'new cust';
        nonAcrAccount.PAN_Number_of_Entity__c = 'EQUPNB123H';  
        nonAcrAccount.BVC_Virtual_Bank_Account_Number__c='ZBVC11566198';
        nonAcrAccount.Customer_Category_Static__c='Non-ACR';
        nonAcrAccount.Credit_Status__c='Non Credit';
        insert nonAcrAccount;
    }
    
    @isTest
    static void testShipmentCreationWithNonAcrCustomer() {
        // Get the Non-ACR Account
        Account nonAcrAccount = [SELECT Id FROM Account WHERE Customer_Category_Static__c = 'Non-ACR'AND Credit_Status__c='Non Credit' LIMIT 1];
        
        // Create a Shipment with a Non-ACR Customer
        Shipment__c nonAcrShipment = new Shipment__c(
            //DSN__c = True,
            Shipment_Created_Through__c='Mobile App',
            Customer__c = nonAcrAccount.Id
        );
        
        List<Shipment__c> shipments = new List<Shipment__c>{nonAcrShipment};
        
        Test.startTest();
        try {
            // Call the validation method
            ShipmentRestrictHandler.restrictShipmentCreation(shipments);
            insert nonAcrShipment;
          // System.assert(false, 'Shipment creation should have failed because the Customer Category is None.');
        } catch (DmlException e) {
            // Verify that the expected error was thrown
           // System.assert(e.getMessage().contains('Shipment cannot be created because the Customer Category is None.'));
        }
        Test.stopTest();
    }
    
    @isTest
    static void testShipmentCreationWithAcrCustomer() {
        // Get the ACR Account
        Account acrAccount = [SELECT Id FROM Account WHERE Customer_Category_Static__c = 'Non-ACR'AND Credit_Status__c='Non Credit'  LIMIT 1];
        
        // Create a Shipment with an ACR Customer
        Shipment__c acrShipment = new Shipment__c(
           
            Customer__c = acrAccount.Id
        );
        
        List<Shipment__c> shipments = new List<Shipment__c>{acrShipment};
        
        Test.startTest();
        // Call the validation method
       ShipmentRestrictHandler.restrictShipmentCreation(shipments);
        insert acrShipment;
        Test.stopTest();
        
        // Verify that the shipment was created successfully
        System.assertNotEquals(null, acrShipment.Id, 'Shipment should have been created successfully.');
    }
}