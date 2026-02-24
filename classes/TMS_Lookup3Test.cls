@isTest
public class TMS_Lookup3Test 
{
    public static testmethod void lookupTest()
    {
/*
        Account ShipperAcc = BVCL_TestDataFactory.createCustomer('BVCLShipp Customer','Shipping',true);
        Account ShipperAcc1 = BVCL_TestDataFactory.createCustomer('BVCLShipp Customer1','Billing',true); */
        FleetX_AddressBook__c fbb = new FleetX_AddressBook__c(Address_Name__c='test Address name',Address_Details__c='112-addtest',Address_Code__c='11234');
        insert fbb;
        
        // TMS_Lookup2.searchDB('Account', 'name', 'Id', 2, 'name', 'BVCL', 'Shipping', '', '', '','','ST_Pricing_Type__c');      
           TMS_Lookup3.searchDB('FleetX_AddressBook__c', 'name', 'Id', 2, 'Address_Name__c', 'test', '', '', '', '','','');      
    }
}