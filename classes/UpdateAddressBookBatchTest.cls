/*Class      : UpdateAddressBookBatchTest  
 *Author     : Sanket.pisal@bvclogistics.com
 *Date       : MAy 2024
 */

@isTest
public class UpdateAddressBookBatchTest {
 @testSetup
    static void setup() {
       
        List<Active_Pincode__c> pincodes = new List<Active_Pincode__c>();
        List<String> validPicklistValues = new List<String>{'Serviceable', 'Non-Serviceable', 'Serviceable', 'Non-Serviceable', 'Serviceable'};

        for (Integer i = 0; i < 5; i++) {
            Active_Pincode__c pincode = new Active_Pincode__c(
                Name = 'Pincode ' + i,
                Pincode_Type__c = validPicklistValues[i]
            );
            pincodes.add(pincode);
        }
        insert pincodes;
    }

    @isTest
    static void testPincodeTypeChange() {
      
        List<Active_Pincode__c> pincodes = [SELECT Id, Pincode_Type__c FROM Active_Pincode__c];
        
       
        for (Active_Pincode__c pincode : pincodes) {
            pincode.Pincode_Type__c = pincode.Pincode_Type__c == 'Serviceable' ? 'Non-Serviceable' : 'Serviceable';
        }
        Test.startTest();
        update pincodes;
        Test.stopTest();

      
    }
}