@isTest
public class TMS_ProductCodeHandler_Test {
    public static testmethod void productNameTest(){
        
        Active_Pincode__c pinCode = new Active_Pincode__C();
        pinCode.Name = '400093';
        pinCode.Pincodes__c = '400093';
        pinCode.State__c = 'Maharashtra';
        pinCode.Country__c = 'India';
        pinCode.City__c = 'Mumbai';
        insert pinCode;
            
        Active_Pincode__c pinCode2 = new Active_Pincode__C();
        pinCode2.Name = '600001';
        pinCode2.Pincodes__c = '600001';
        pinCode2.State__c = 'Tamilnadu';
        pinCode2.Country__c = 'India';
        pinCode2.City__c = 'Chennai';
        insert pinCode2;
        
        Hub__c hb = new Hub__c();
        hb.Name = 'name';
        hb.Branch__c= 'Mumbai';
        insert hb;
        
        // Account (ACR)
        Account ACRacc = TestUtility.createnonACRnonContractedAccount();
        ACRacc.Name = 'ACR customer';
        ACRacc.Last_Name__c='Surname';
        ACRacc.ST_Pricing_Type__c='ACR';
        insert ACRacc;
        
        AddressBook__c ACRaddress = new AddressBook__c(Customer__c=ACRacc.id, Active_Pincode__c=pinCode.id);
        insert ACRaddress;
        
        // Contract
        BVC_contract__c con= new BVC_contract__c();
        con.Customer_Name__c=ACRacc.id;
        con.Old_Pricing__c=false; // ensures formula New_Contract__c = true
        con.Status__c='Activated';
        con.Business_Type__c='ACR';
        insert con;
        
        // Link Account to Contract
        ACRacc.BVC_Contract__c=con.id;
        update ACRacc;
        
        // Shipper/Consignee account
        Account ShipperConsigneeAccount = new Account(Name = 'Test Shipper Customer');
        ShipperConsigneeAccount.Last_Name__c='test_ShipperConsigneeAccount_LastName';
        insert ShipperConsigneeAccount;
        
        AddressBook__c origin = new AddressBook__c(Customer__c = ShipperConsigneeAccount.Id, STATE__c = 'Maharashtra', RecordTypeId='0125g0000002Xb1AAE',Active_Pincode__c=pinCode.id);
        AddressBook__c destination = new AddressBook__c(Customer__c = ShipperConsigneeAccount.Id, Active_Pincode__c=pinCode2.id);
        insert new List<AddressBook__c>{origin, destination};
            
        Shipment__c shipment = new Shipment__c(
            Shipper_Name_TMS__c=ShipperConsigneeAccount.id,
            Consignee_Name_TMS__c=ShipperConsigneeAccount.id,
            Origin_Address_Name__c = origin.Id,
            Destination_Address_Name__c = destination.Id,
            Origin_Hub__c=hb.id,
            Customer__c = ACRacc.Id,
            Bill_To_Account__c=ACRacc.Id,
            isExhibition__c=false,
            Gross_Weight__c=12,
            Gross_Weight_UOM_TMS__c='Gram',
            Number_of_Packages__c=0,
            Customer_Product_Category__c='ValSHIP'
        );
        insert shipment;
        
        // 🔑 Re-query shipment with parent account + contract to hydrate formula values
        shipment = [
            SELECT Id, Customer__c, 
                   Customer__r.New_Contract__c,
                   Customer__r.ST_Pricing_Type__c,
                   Customer__r.Customer_Category__c,
                   Customer__r.BVC_Contract__c,
                   Customer__r.BVC_Contract__r.Old_Pricing__c,Origin_Address_City__c,Destination_Address_City__c,IsExhibition__c,Customer_Product_Category__c,State_Logic_Check__c,
            Origin_Address_State__c,Destination_Address_State__c
            FROM Shipment__c
            WHERE Id = :shipment.Id
        ];
        
        system.debug('shipment.customer__c::'+shipment.customer__c);
        system.debug('shipment.customer__r.new_contract__c::'+shipment.customer__r.new_contract__c);
        system.debug('shipment.customer__r.ST_Pricing_Type__c::'+shipment.customer__r.ST_Pricing_Type__c);
        system.debug('shipment.customer__r.Customer_Category__c::'+shipment.customer__r.Customer_Category__c);
        system.debug('shipment.customer__r.bvc_contract__c::'+shipment.customer__r.bvc_contract__c);
        system.debug('shipment.customer__r.bvc_contract__r.Old_Pricing__c::'+shipment.customer__r.bvc_contract__r.Old_Pricing__c);
        
        List<Shipment__c> ShipList = new List<Shipment__c>();
        ShipList.add(shipment);
        
        Set<String> OriginCitySet = new Set<String>{'Mumbai'};
        Set<String> DestinationCitySet = new Set<String>{'Chennai'};
            
        Origin_Destination__c od = new Origin_Destination__c(
            name='Mumbai-Chennai',
            OriginCity__c='Mumbai',
            DestinationCity__c='Chennai',
            Mode_Of_Service__c='Metro To Metro',
            New_Pricing__c=true,
            Is_State_to_State__c=false
        );
        insert od;
        
        Test.startTest();
        TMS_ProductCodeHandler.UpdateProductDetails(ShipList);
        Test.stopTest();
    }
}