@IsTest
public class DeactivateAddressQueueableTest {

    @IsTest
    static void testDeactivateAddressQueueable() {

      
        	ST_Exhibition__c exh1 = new ST_Exhibition__c(Name = 'Expo 1');
        	ST_Exhibition__c exh2 = new 	ST_Exhibition__c(Name = 'Expo 2');
        insert new List<	ST_Exhibition__c>{ exh1, exh2 };

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
        
            
            
        AddressBook__c addr1 = new AddressBook__c(
            Name = 'Address 1',
            Exhibition__c = exh1.Id,
            Is_Active__c = true,
             Customer__c =Ac.Id
        );

        AddressBook__c addr2 = new AddressBook__c(
            Name = 'Address 2',
            Exhibition__c = exh2.Id,
            Is_Active__c = true,
             Customer__c =Ac.Id
        );

        Account Acc = New Account();
        Acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        Acc.Name = 'TITAN COMPANY LIMITED - Billing EQUPNB123K';
        Acc.BVC_Company_Type__c = 'Domestic';        
        Acc.KYC_Indicator_for_Domestic_Flag__c = true;
        Acc.Customer_Status__c = 'Active';
        Acc.Category__c = 'Manufacturer';
        Acc.Type_Of_Customer__c = 'Both';
        Acc.BVC_Legal_Entity__c = 'B.V.C. Logistics Private Limited';
        Acc.Primary_Customer_Email__c = 'abc@sdcnz.com';
        Acc.Phone = '+919474636781';
        Acc.First_Name__c = 'billing firstname';               
        Acc.Last_Name__c = 'billing lst name';
        //      Acc.Name_As_Per_PAN__pc = 'EQUPNB123K';
        Acc.Name_As_Per_PAN_Manual_Input__c = 'new cust';
        Acc.PAN_Number_of_Entity__c = 'EQUPNB123I';  
        Acc.BVC_Virtual_Bank_Account_Number__c='ZBVC11566198';
        Insert Acc;
        
        
        AddressBook__c addr3 = new AddressBook__c(
            Name = 'Address 3',
            Exhibition__c = exh1.Id,
            Is_Active__c = false,
            Customer__c =Acc.Id
        );

        insert new List<AddressBook__c>{ addr1, addr2, addr3 };

       
        Set<Id> exhibitionIds = new Set<Id>{ exh1.Id, exh2.Id };

        Test.startTest();
        System.enqueueJob(new DeactivateAddressQueueable(exhibitionIds));
        Test.stopTest();

      
        Map<Id, AddressBook__c> addrMap = new Map<Id, AddressBook__c>(
            [
                SELECT Id, Is_Active__c
                FROM AddressBook__c
                WHERE Id IN :new List<Id>{ addr1.Id, addr2.Id, addr3.Id }
            ]
        );

        System.assertEquals(false, addrMap.get(addr1.Id).Is_Active__c,
            'Active address for Exhibition 1 should be deactivated');

        System.assertEquals(false, addrMap.get(addr2.Id).Is_Active__c,
            'Active address for Exhibition 2 should be deactivated');

        System.assertEquals(false, addrMap.get(addr3.Id).Is_Active__c,
            'Inactive address should remain inactive');
    }
}