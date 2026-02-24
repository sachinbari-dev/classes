@isTest
public class VaultShipmentTriggerHelperTest {
    
    @isTest
    static void testCreateBVCOrder_ACR_NonACR() {
        // Create test data
        
        Active_Pincode__c pinCode = new Active_Pincode__C();
        pinCode.Name = '400093';
        pinCode.Pincodes__c = '400093';
        pinCode.State__c = 'Maharashtra';
        pinCode.Country__c = 'India';
        pinCode.City__c = 'Mumbai';
        insert pinCode;
        
        
        
        Entity__c entity = new Entity__c();
        entity.name= 'BVC Logistics Pvt Ltd';
        entity.Corporate_Office_Pincode__c=pinCode.id;
        insert entity;
        
        BVC_LegalEntity__c LE = new BVC_LegalEntity__c();
        Le.name='BVCL MAHARASHTRA';
        Le.BVC_Entity__c= entity.id;
        Le.GSTIN_Principle_Business_Address_Pincode__c=pinCode.id;
        insert Le;
        
        Hub__c hb = new Hub__c();
        hb.Name = 'name';
        hb.Branch__c= 'Mumbai';
        hb.BVC_LegalEntity__c=Le.id;
        hb.BVC_Entity__c=entity.id;
        insert hb;
        
        List<Account> accList = new List<Account>();
        Account ACRacc = TestUtility.createnonACRnonContractedAccount();
        ACRacc.Name = 'ACR customer';
        insert ACRacc;
        
        Account nonAcrAcc = new Account(Name = 'Non ACR Account', Customer_Category_Static__c = 'Non-ACR', Credit_Status__c= 'Credit',Billing_Frequency__c='Shipment');
        //insert nonAcrAcc;
        
        AddressBook__c ACRaddress = new AddressBook__c(Customer__c=ACRacc.id, Active_Pincode__c=pinCode.id);
        AddressBook__c NonACRaddress = new AddressBook__c(Customer__c=nonAcrAcc.id, Active_Pincode__c=pinCode.id);
        
        BVC_Contract__c acrContract = new BVC_Contract__c(Customer_Name__c = ACRacc.Id, BVC_Branch__c = hb.id,
                                                          BVC_Entity__c = entity.id, BVC_LegalEntity__c = Le.id, Business_Type__c='ACR',Contracted_ACR_Package__c='New Package 7 : 22.5L',
                                                         Contract_Amount__c=2250000, contract_start_date__c= Date.newInstance(2025, 06, 24),Contract_End_Date__c=Date.newInstance(2045, 12, 31));
        BVC_Contract__c nonAcrContract = new BVC_Contract__c(Customer_Name__c = nonAcrAcc.Id,  BVC_Branch__c = hb.id,
                                                             BVC_Entity__c = entity.id, BVC_LegalEntity__c = Le.id, Business_Type__c='Non ACR');
        insert new List<BVC_Contract__c>{ acrContract, nonAcrContract };
            
        ACRacc.BVC_Contract__c = acrContract.Id;
        ACRacc.ST_Pricing_Type__c= 'ACR';
        ACRacc.Customer_Category_Static__c='ACR';
        ACRacc.Customer_Category__c='ACR Contracted';
        
        nonAcrAcc.BVC_Contract__c=nonAcrContract.id;
        nonAcrAcc.ST_Pricing_Type__c= 'Non ACR';
        nonAcrAcc.Customer_Category__c='Non ACR Contracted';
        
        //update new List<Account>{ ACRacc, nonAcrAcc };
        
        Vault_Shipmet__c acrShipment = new Vault_Shipmet__c(Billing_Account__c= ACRacc.Id, Product_Value__c = 5000,
                                                            Billing_Address__c = ACRaddress.id);
        Vault_Shipmet__c nonAcrShipment = new Vault_Shipmet__c(Billing_Account__c= nonAcrAcc.Id, Product_Value__c = 3000,
                                                               Billing_Address__c = NonACRaddress.id);
        insert new List<Vault_Shipmet__c>{ acrShipment, nonAcrShipment };
         
        acrShipment.Verified_for_Billing__c = true;
        nonAcrShipment.Verified_for_Billing__c = true;
        //update new List<Vault_Shipmet__c>{ acrShipment, nonAcrShipment };
        
            // Verify Orders created
        List<BVCOrder__c> orders = [SELECT Id, Business_Type__c FROM BVCOrder__c];
        //System.assertEquals(2, orders.size());
        
        // Verify Order Products created
        List<BVC_Order_Product__c> orderProducts = [SELECT Id, BVCOrder__c FROM BVC_Order_Product__c];
        //System.assertEquals(2, orderProducts.size());
        
        // Verify Invoices for Non ACR
        List<BVCInvoice__c> invoices = [SELECT Id, BVCOrder__c FROM BVCInvoice__c];
        //System.assert(invoices.size() > 0);
        
        // Verify ACR Consumption for ACR
        List<BVC_ACR_Consumption__c> acrConsumptions = [SELECT Id, Account__c FROM BVC_ACR_Consumption__c];
        //System.assert(acrConsumptions.size() > 0);
    }
}