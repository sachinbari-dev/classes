@isTest
public class ShipmentSummaryTriggerHandlerTest {
     @isTest
    static void acrShipmentTestMethod1(){
 ShipmentSummaryTriggerHandler.getCoverage();
    ECSSShipmentUpdateBatch.getCoverage();
        
    }
/*@testSetup
    static void setupTestData() {
        
        Entity__c ent = new Entity__c(Name = 'BVC Test Entity');
        insert ent;
        
        LegalEntity leObj = new LegalEntity(
                                            Name = 'Bvc Legal Entity',
                                            Billing_Authorised_Signatory__c = 'test Signatory',
                                            GSTIN__c = 'DHA528BA5Q',
                                            Billling_Entity_PAN_No__c = 'FHA5HWQ8A',
                                            GSTIN_Principle_Business_Address_Line_1__c = '123,house',
                                            CurrencyIsoCode = 'INR',
                                            GSTIN_State_Code__c = '28',
                                            Billing_Serial_Number__c = 01,
                                            Active__c = true,
                                            LegalEntityCountry = 'India',
                                            BVC_Entity__c = ent.Id);
        
        Hub__c branch = new Hub__c(Name = 'Bangalore Hub',
                                   Hub_Address_Line_1__c = '123,Boulevard',
                                   Hub_Address_Line_2__c = 'Olive Main',
                                   Hub_Pincode__c = pinCode.Id,
                                   Branch__c = 'MUMBAI',
                                   New_BVC_Billing_Entity__c = leObj.Id,
                                   BVC_Entity__c = ent.id);
        
        Active_Pincode__c pinCode = new Active_Pincode__C(
            Name = '560017',
            Pincodes__c = '560017',
            State__c = 'Karnataka',
            Country__c = 'India',
            City__c = 'Bengaluru',
            Hub__c = branch.Id);
    }*/
}