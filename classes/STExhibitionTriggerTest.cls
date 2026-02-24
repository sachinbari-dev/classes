@IsTest
public class STExhibitionTriggerTest {

    @IsTest
    static void testDeactivateAddressesOnExhibitionInactivation() {

      
        ST_Exhibition__c exhibition = new ST_Exhibition__c(
            Name = 'Test Exhibition',
            ST_Active__c = true
        );
        insert exhibition;

      Account Ac = New Account();
        Ac.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        Ac.Name = 'TITAN COMPANY LIMITED - Billing EQUPNB123K';
        Ac.BVC_Company_Type__c = 'Domestic';        
        Ac.KYC_Indicator_for_Domestic_Flag__c = true;
        Ac.Customer_Status__c = 'Active';
        Ac.Category__c = 'Manufacturer';
        Ac.Type_Of_Customer__c = 'Both';
        Ac.BVC_Legal_Entity__c = 'B.V.C. Logistics Private Limited';
        Ac.Primary_Customer_Email__c = 'abc@sdcn.com';
        Ac.Phone = '+919474636783';
        Ac.First_Name__c = 'billing firstname';               
        Ac.Last_Name__c = 'billing lst name';
        //      Acc.Name_As_Per_PAN__pc = 'EQUPNB123K';
        Ac.Name_As_Per_PAN_Manual_Input__c = 'new cust';
        Ac.PAN_Number_of_Entity__c = 'EQUPNB123K';  
        Ac.BVC_Virtual_Bank_Account_Number__c='ZBVC11566198';
        Insert Ac;
        
        AddressBook__c addrActive1 = new AddressBook__c(
            Name = 'Active Address 1',
            Exhibition__c = exhibition.Id,
            Is_Active__c = true,
             Customer__c =Ac.Id
        );

        AddressBook__c addrInactive = new AddressBook__c(
            Name = 'Inactive Address',
            Exhibition__c = exhibition.Id,
            Is_Active__c = false,
            Customer__c =Ac.Id
        );

        insert new List<AddressBook__c>{ addrActive1, addrInactive };

        
        Test.startTest();
        exhibition.ST_Active__c = false;
        update exhibition;
        Test.stopTest();

       
        Map<Id, AddressBook__c> addrMap = new Map<Id, AddressBook__c>(
            [
                SELECT Id, Is_Active__c
                FROM AddressBook__c
                WHERE Id IN :new List<Id>{ addrActive1.Id, addrInactive.Id }
            ]
        );

        System.assertEquals(
            false,
            addrMap.get(addrActive1.Id).Is_Active__c,
            'Active address should be deactivated when Exhibition becomes inactive'
        );

        System.assertEquals(
            false,
            addrMap.get(addrInactive.Id).Is_Active__c,
            'Already inactive address should remain inactive'
        );
    }

    @IsTest
    static void testTriggerDoesNotFireWhenStillActive() {

       
        ST_Exhibition__c exhibition = new ST_Exhibition__c(
            Name = 'Still Active Exhibition',
            ST_Active__c = true
        );
        insert exhibition;

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
        Acc.Phone = '+919474636783';
        Acc.First_Name__c = 'billing firstname';               
        Acc.Last_Name__c = 'billing lst name';
        //      Acc.Name_As_Per_PAN__pc = 'EQUPNB123K';
        Acc.Name_As_Per_PAN_Manual_Input__c = 'new cust';
        Acc.PAN_Number_of_Entity__c = 'EQUPNB123K';  
        Acc.BVC_Virtual_Bank_Account_Number__c='ZBVC11566198';
        Insert Acc;
        
        
        AddressBook__c addr = new AddressBook__c(
            Name = 'Address',
            Exhibition__c = exhibition.Id,
            Is_Active__c = true,
            Customer__c =Acc.Id
        );
        insert addr;

      
        Test.startTest();
        exhibition.Name = 'Updated Name';
        update exhibition;
        Test.stopTest();

       
        addr = [
            SELECT Is_Active__c
            FROM AddressBook__c
            WHERE Id = :addr.Id
        ];

        System.assertEquals(
            true,
            addr.Is_Active__c,
            'Address should remain active when ST_Active__c is unchanged'
        );
    }
}