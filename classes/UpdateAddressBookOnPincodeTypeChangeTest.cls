@isTest
private class UpdateAddressBookOnPincodeTypeChangeTest {
    @isTest
    static void testBatchExecution() {
        // Create test data
        List<Active_Pincode__c> pincodes = new List<Active_Pincode__c>{
            new Active_Pincode__c(Name = 'Pincode 1'),
            new Active_Pincode__c(Name = 'Pincode 2')
        };
        insert pincodes;
        Map<Id, String> recordTypeMap = new Map<Id, String>();
        recordTypeMap.put(pincodes[0].Id, 'Non-Serviceable');
        recordTypeMap.put(pincodes[1].Id, 'Serviceable');
         Hub__c newHub = new Hub__c();
        newHub.Name = 'delhi Acr';
        newHub.Branch__c = 'delhi';
        insert newHub;
        system.assertEquals('delhi Acr', newHub.Name);
        Hub__c hub1 = new Hub__c();
        hub1.Name='delhi';
        hub1.Branch__c ='delhi';
        insert hub1;
        Zone__c z =  new Zone__c();
        z.Name= 'North';
        insert z;
        system.assertEquals('North', z.Name);
        Active_Pincode__c pin = new Active_Pincode__c();
        pin.Name = '456789';
        pin.City__c = 'Amravati';
        pin.Pincodes__c = '444601';
        pin.City__c = 'Pune';
        pin.District__c = 'pune';
        pin.Online__c = true;
        pin.Pincode_Type__c = 'Serviceable';
        pin.Online_Offline__c = 'Online';
        pin.Country__c = 'India';
        pin.State__c = 'Maha';
        pin.Hub__c = newHub.id;
        pin.Zone__c = z.Id;
        insert pin;
        Account shippingAcc = new Account();
        shippingAcc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Shipping').getRecordTypeId();
        shippingAcc.Name = 'SPARKLEs GOLD RETAIL VENTURES LLP - Shipping GMUUY5467R';
        shippingAcc.PAN_Number_of_Entity__c = 'GMUUY5467R';
      
        shippingAcc.Name_As_Per_PAN_Manual_Input__c = 'new custmers';
        shippingAcc.First_Name__c = 'new customer';
        shippingAcc.Last_Name__c = 'customer account';
        shippingAcc.Primary_Customer_Email__c = 'ravi.e@bvclogistics.com';
        shippingAcc.Phone = '+919877287843';
        insert shippingAcc;
        List<AddressBook__c> addressBooks = new List<AddressBook__c>{
            new AddressBook__c(
                RecordTypeId = '0125g0000002Xb1AAE',
                Is_Active__c = true,
                Active_Pincode__c = pincodes[0].Id ,
                TRADE_NAME__c = shippingAcc.Name,
                Customer__c = shippingAcc.id,
                  GSTIN_Type__c = 'GSN-Individual IEC',
        ADDRESS1__c = 'ABC Street',
        CITY__c = 'Test City',
        STATE__c = 'Test State',
        COUNTRY__c = 'Test Country'
            ),
            new AddressBook__c(
                RecordTypeId = '0125g0000002Xb1AAE',
                Is_Active__c = false,
                Active_Pincode__c = pincodes[1].Id,// Serviceable
                TRADE_NAME__c = shippingAcc.Name,
                Customer__c = shippingAcc.id,
                GSTIN_Type__c = 'GSN-Individual IEC',
        ADDRESS1__c = 'ABC Street',
        CITY__c = 'Test City',
        STATE__c = 'Test State',
        COUNTRY__c = 'Test Country'
            )
        };
        insert addressBooks;
        Set<Id> activePincodeIds = new Set<Id>{pincodes[0].Id, pincodes[1].Id};
        Id userId = UserInfo.getUserId();
       
        Test.startTest();
        UpdateAddressBookBatch batch = new UpdateAddressBookBatch(activePincodeIds, recordTypeMap, userId);
        Database.executeBatch(batch);
        Test.stopTest();
        
        Integer expectedSuccessCount = 2;
        Integer expectedFailureCount = 0;
        
        List<AddressBook__c> updatedAddressBooks = [SELECT Id, Is_Active__c,Active_Pincode__c FROM AddressBook__c WHERE Id IN :addressBooks];
        for (AddressBook__c ab : updatedAddressBooks) {
            if (recordTypeMap.containsKey(ab.Active_Pincode__c)) {
                String expectedPincodeType = recordTypeMap.get(ab.Active_Pincode__c);
                Boolean expectedIsActive = (expectedPincodeType == 'Serviceable');
                System.assertEquals(expectedIsActive, ab.Is_Active__c, 'AddressBook__c record not updated correctly');
            }
        }
    }
}