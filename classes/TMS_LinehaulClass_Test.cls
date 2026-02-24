@isTest
public class TMS_LinehaulClass_Test {
    Public static testmethod void testShipments(){
         String currentUser1 = UserInfo.getUserId();
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName='testuser@bvcl.com');
        insert u; 
           
        Account BillingAcc = BVCL_TestDataFactory.createCustomer('BVCLBill Customer120','Billing',false);
        BillingAcc.Email__c = 'test120@gmail.com';
        BillingAcc.Phone = '+918956232120';
        BillingAcc.Mobile__c= '+918956232120'; 
        BillingAcc.Last_Name__c='Test Name120';
        insert BillingAcc;
        Account ShipperAcc = BVCL_TestDataFactory.createCustomer('BVCLShipp Customer 121','Shipping',false);
        ShipperAcc.Email__c = 'test121@gmail.com';
        ShipperAcc.Phone = '+918956232121';
        ShipperAcc.Mobile__c= '+918956232121';
        ShipperAcc.Last_Name__c='Test Name121';
        insert ShipperAcc;
        Hub__c DelhiHub = BVCL_TestDataFactory.CreateHub('Delhi', true, 'DELHI');
        FSE_Sales__c fse = BVCL_TestDataFactory.createFSE(DelhiHub.id,u.id,'Manager',true,true);
        Active_Pincode__c DelhiPin = BVCL_TestDataFactory.CreatePincode('110025', DelhiHub.id, 'Delhi', 'South', true);
        AddressBook__c ShipperAddress = BVCL_TestDataFactory.CreateAddress('Shipping',ShipperAcc.id,'Line 1',DelhiPin.id,'Cityyy',true);
        
        Shipment__c Ship1 = BVCL_TestDataFactory.CreateShipment(BillingAcc.id, ShipperAcc.id, ShipperAddress.id, ShipperAcc.id, ShipperAddress.id, false);
        ship1.Product_Description__c = 'Gold Jewellery';
        insert Ship1;
        
        Secure_Packaging__c SP_Bag = BVCL_TestDataFactory.createPackaging('Secure Bag','EZ000333','Available',true); 
        Secure_Packaging__c Seal = BVCL_TestDataFactory.createPackaging('Secure Seal','EZ333','Available',true);
        
        Secure_Packaging__c trunk = BVCL_TestDataFactory.createPackaging('Secure Bag','EZ000334','Available',true);
        
        Secure_Packaging__c sp = new Secure_Packaging__c();
        sp.RecordTypeId = Schema.SObjectType.Secure_Packaging__c.getRecordTypeInfosByName().get('Secure Seal').getRecordTypeId();
        sp.Shipment__c = Ship1.id;
        sp.Name = 'X0737246';
        sp.draft__c = true;
        sp.Status__c = 'Available';
        
        insert sp;
        
        Secure_Bag__c bag1 = new Secure_Bag__c();
        bag1.Shipment__c = Ship1.id;
        bag1.Secure_Bag__c = SP_Bag.id;
        bag1.Linehaul_Type__c = 'Road';
        bag1.Finalised_Linehaul_Number__c = 'sss';
        bag1.Seal_Id__c = Seal.id;
        bag1.Right_Seal_Id__c = sp.Id; 
        bag1.Current_Scan_Loction__c = 'Created';
        bag1.Next_Destination__c = 'DELHI';
        bag1.Draft__c = true;
        //bag1.Current_Scan_Hub__c = DelhiHub.id;
        insert bag1;
        

        
        //update bag1;
        System.runAs(u){
            TMS_LinehaulClass.Shipments('Finalised',DelhiHub.name);
            
            TMS_LinehaulClass.Shipments('Inbound',DelhiHub.name);
            bag1.Current_Scan_Hub__c = DelhiHub.id;
            bag1.Finalised_Linehaul_Number__c = null;
            
            update bag1;
            TMS_LinehaulClass.Shipments('Outbound',DelhiHub.name);
            Transport__c DelhiAir = BVCL_TestDataFactory.CreateAirport('Delhi Airport', false);
            DelhiAir.Airport_Code__c = 'DEL';
            insert DelhiAir;
            Transport__c BOMAir = BVCL_TestDataFactory.CreateAirport('Mumbai Airport', false);
            BOMAir.Airport_Code__c = 'BOM';
            insert BOMAir;
            Flight_Schedule__c flight = BVCL_TestDataFactory.createFlight('Indigo', BOMAir.id, DelhiAir.id, true);
            Flight_Schedule__c flightspice = BVCL_TestDataFactory.createFlight('SPICEJET', BOMAir.id, DelhiAir.id, false);
            flightspice.Schedule_Time_To_Departure__c = system.now();
            insert flightspice;
            Transport__c Vehicle = BVCL_TestDataFactory.CreateVehicle('Honda12',true);
            TMS_DLHN__c dhln = new TMS_DLHN__c();
            
            bag1.Finalised_Linehaul_Number__c = 'FL2222';
            bag1.Flight_Schedule__c = flight.id;
            bag1.Vehicle__c = Vehicle.id;
            //bag1.Name = '';
            update bag1;
            List<Secure_Bag__c> baglist = new List<Secure_Bag__c>();
            baglist.add(bag1);
            Map<string,List<Secure_Bag__c>> BagMap = new Map<string,List<Secure_Bag__c>>();
            BagMap.put(bag1.Finalised_Linehaul_Number__c,new List<Secure_Bag__c>{bag1});
            
            TMS_LinehaulClass.SecureBagWrapper sbWrap = new TMS_LinehaulClass.SecureBagWrapper();
            sbWrap.sb = bag1;
            sbWrap.Seal = Seal.id;
            sbWrap.rseal = sp.id;
            sbWrap.trunk = trunk.id;
            sbWrap.CurrentHub = DelhiHub.id;
            sbWrap.process = true;
                       
            List<TMS_LinehaulClass.SecureBagWrapper> WrapList = new List<TMS_LinehaulClass.SecureBagWrapper>();
            WrapList.add(sbWrap);
            string bagjson = JSON.serialize(WrapList);
            
            
            Indigo_Commodity_Master__c commodity = new Indigo_Commodity_Master__c();
            commodity.Commodity_Code__c = 'SIL';
            commodity.Commodity_Description__c= 'SIL';
            commodity.Name = 'SIL';
            commodity.SHC_Code__c = 'SIL';
            insert commodity;
            
            Indigo_Commodity_Master__c commodity2 = new Indigo_Commodity_Master__c();
            commodity2.Commodity_Code__c = 'VALN';
            commodity2.Commodity_Description__c= 'VALN';
            commodity2.Name = 'VALN';
            commodity2.SHC_Code__c = 'VALN';
            insert commodity2;
            
            
            List<Commodity_Code_List__mdt> commodityList = new List<Commodity_Code_List__mdt>();
            commodityList = [Select Id, DeveloperName,Airline__c,Commodity_Code__c,Commodity_Description__c,Product_Type__c,SCH_Code__c from Commodity_Code_List__mdt where Airline__c= 'Indigo'];
            
            Linehaul__c linehaulRecord = new Linehaul__c();
            linehaulRecord.Select_Airline__c = 'Indigo';
            linehaulRecord.Commodity_Name__c = commodity.Id;
            linehaulRecord.Flight_Date__c = system.today();
            linehaulRecord.Gross_Weight__c = 100;
            linehaulRecord.Origin__c = 'BOM';
            linehaulRecord.Destination__c = 'DEL';
            linehaulRecord.Shipping_City_Picklist__c = 'Mumbai';
            linehaulRecord.Shipping_Agent_Code_Picklist__c = 'BVCLBOMDOM';
            linehaulRecord.Shipping_Account_Code_Picklist__c = 'BOMBVC';
            linehaulRecord.Shipper_Name__c = 'Test Shipper';
            linehaulRecord.Shipper_Contact_Number__c = '8588007113';
            linehaulRecord.Shipper_EmailID__c = 'test@gmail.com';
            linehaulRecord.Consignee_City_Picklist__c = 'HYDERABAD';
            linehaulRecord.Consignee_Account_Code_Picklist__c = 'HYDBVC';
            linehaulRecord.Consignee_Contact_Number__c = '8588007113';
            linehaulRecord.Consignee_Name__c = 'Test Consignee';
            linehaulRecord.Shipping_Address__c = 'Test address';
            linehaulRecord.Shipping_Country_Code__c = 'IN';
            linehaulRecord.Shipping_Pincode__c = '400001';
            linehaulRecord.Shipping_State__c = 'Mahatrastra';
            linehaulRecord.Consignee_Address__c = 'Test address 2';
            linehaulRecord.Consignee_Pincode__c = '500108';
            linehaulRecord.Consignee_State__c = 'Telangana';
            linehaulRecord.AWB_Consumed__c = false;
            Insert linehaulRecord;
            
            Linehaul_Tracking__c  lt=  new Linehaul_Tracking__c();
            lt.Linehaul_Name__c = linehaulRecord.id;
            
            insert lt;
            
             
            
             
            
            
            Shipper_Consignee_Detail_SpiceJet__c spiceDetail = new Shipper_Consignee_Detail_SpiceJet__c();
            spiceDetail.Shipper_State_Code__c ='27';
            spiceDetail.Name = 'MUMBAI-DELHI';
            spiceDetail.Shipper_Pincode__c = '400093';
            spiceDetail.Shipper_Name__c = 'B V C LOGISTICS PRIVATE LIMITED';
            spiceDetail.Shipper_Email__c = 'test@gmail.com';
            spiceDetail.Shipper_Country_Code__c = 'IN';
            spiceDetail.Shipper_Contact_No__c = '9323106410';
            spiceDetail.Shipper_Code__c  = 'BVCBOMDO';  
            spiceDetail.Shipper_City__c = 'MUMBAI';
            spiceDetail.Shipper_Airport_Code__c = 'BOM';
            spiceDetail.Shipper_Address__c = '1102 Solitaire Corporate Park, 167- Guru Hargovindji Marg, Chakala, Andheri (E), Mumbai ? 400 093';
            spiceDetail.Consignee_State_Code__c = '07';
            spiceDetail.Consignee_Pincode__c = '110055';
            spiceDetail.Consignee_Name__c = 'B V C LOGISTICS PRIVATE LIMITED';
            spiceDetail.Consignee_Email__c = 'test2@gmail.com';
            spiceDetail.Consignee_Country_Code__c = 'IN';
            spiceDetail.Consignee_Contact_No__c = '9311983900';
            spiceDetail.Consignee_Code__c = 'BVCDELDO';
            spiceDetail.Consignee_City__c = 'DELHI';
            spiceDetail.Consignee_Airport_Code__c = 'DEL';
            spiceDetail.Consignee_Address__c = '# 2E / 16, Jhandewalan Extension, New Delhi 110 055';
            insert spiceDetail;
            
            
            Linehaul__c linehaulRecord2 = new Linehaul__c();
            linehaulRecord2.Select_Airline__c = 'SPICEJET';
            linehaulRecord2.Commodity_Name__c = commodity2.Id;
            linehaulRecord2.Flight_Date__c = system.today();
            linehaulRecord2.Gross_Weight__c = 100;
            linehaulRecord2.Origin__c = 'BOM';
            linehaulRecord2.Destination__c = 'DEL';
            linehaulRecord2.AWB_Consumed__c = false;
            linehaulRecord2.Width_Dimension__c = 12.00;
            linehaulRecord2.Length_Dimension__c = 12.00;
            linehaulRecord2.Height_Dimension__c = 12.00;
            linehaulRecord2.Weight_Dimension__c = 12.00;
            linehaulRecord2.Flight_No_for_SpiceJet_Indigo__c = flightspice.Id;
            linehaulRecord2.Shipper_Consignee_Detail_SpiceJet__c = spiceDetail.Id; 
            linehaulRecord2.from__c = system.now();
           
            Insert linehaulRecord2;
            
              Linehaul_Tracking__c  lt1=  new Linehaul_Tracking__c();
            lt1.Linehaul_Name__c = linehaulRecord2.id;
            
            insert lt1;
            
            List<id> lineIds = new List<id>{lt.id,lt1.id};
            
            test.startTest(); 
            Integer Index = 1;
            for(string key:BagMap.keyset()){
                TMS_LinehaulClass.DefaultLineHaulWrap dl = new TMS_LinehaulClass.DefaultLineHaulWrap();
                dl.index = Index;
                dl.process = false;
                dl.BagList = BagMap.get(key);
                dl.UniqueBag = BagMap.get(key)[0];
                dl.BagsCount = BagMap.get(key).size();
            }  
            TMS_LinehaulClass.LoggedInUserHub();
            TMS_LinehaulClass.Shipments('Finalised',DelhiHub.Name);
            TMS_LinehaulClass.SecureBagsList(baglist);
            TMS_LinehaulClass.FilteredBagList(baglist, 'Delhi',SP_Bag.Id,sp.Id,'GEN');
            TMS_LinehaulClass.FilteredBagByDest(baglist, 'Del');
            TMS_LinehaulClass.FilteredByBagNo(bagjson,baglist,'Del');
            // TMS_LinehaulClass.AddBox(Seal,Seal.Id,'');
            Secure_Packaging__c Seal2 = BVCL_TestDataFactory.createPackaging('Secure Seal','EZ0023232','Available',true);
              TMS_LinehaulClass.AddBox(bagjson, seal.id, Seal2.id,sp.Id,seal.id,'Delhi',trunk.Id, trunk.Id,'osb','OST','AT-87435',true);
              TMS_LinehaulClass.AddBoxDraft(bagjson, seal.id, Seal2.id,sp.Id,seal.id,'Delhi',trunk.Id, trunk.Id,'osb','OST','AT-87435',true);
              TMS_LinehaulClass.getDraftBagsfiltered('DELHI', seal.id, 'VAL');
            TMS_LinehaulClass.getDraftBags();
            TMS_LinehaulClass.getDraftSeals();
            TMS_LinehaulClass.RemoveDraftSelections(bagjson);
          //  TMS_LinehaulClass.processHub(DelhiHub.id,DelhiHub.Name,'Road');
            
            TMS_LinehaulClass.currentUserHub();
            
            dhln.Name = 'Final Num';
            dhln.Last_Number__c = 1;
            dhln.Finalized_Number__c = 1;
            insert dhln;
            
              String currentUser = UserInfo.getUserId();
            
            Hub__c testHub = new Hub__c(Name = 'Test Hub');
              insert testHub;
            
            FSE_Sales__c testSales = new FSE_Sales__c(Hub__c = testHub.Id, Sales_Person__r =u );
            insert testSales;

             TMS_Air_Series__c testAirSeries = new TMS_Air_Series__c(Finalised_Number__c = 100);
             insert testAirSeries;
            
           
            
            String destID = '001';
            String destName = 'Destination';
            String lineHaulType = 'Air';
            
            TMS_LinehaulClass.SaveProcess(bagjson, 'Air', 'FL1111','FL4654', Flight.id, System.now(),'','','','','','Finalized','Mumbai','Delhi','indigo','GEN',System.now(),true);
            TMS_LinehaulClass.SaveProcess(bagjson, 'Air', 'FL1111','FL4654', Flight.id, System.now(),'','','','','','Finalized','Mumbai','Delhi','indigo','GEN',System.now(),true);
             TMS_LinehaulClass.SaveProcess(bagjson, 'Air', 'FL1111','FL4654$#', Flight.id, System.now(),'','','','','','Finalized','Mumbai','Delhi','indigo','GEN',System.now(),true);
           // TMS_LinehaulClass.AddBagToLineHaul(bagjson);
           // TMS_LinehaulClass.AddBagToLineHaulDraft(bagjson);
          //  TMS_LinehaulClass.processDestAirHub(destID, destName, lineHaulType);
            TMS_LinehaulClass.SecureBagsBVCTrunkList(BagList);
          //  TMS_LinehaulClass.processHub(DelhiHub.id,DelhiHub.Name,'Road');
          //  TMS_LinehaulClass.saveApiResponseToField(linehaulRecord.id, 'success message');
           // TMS_LinehaulClass.processHub('Delhi', 'Hyderabad', 'Road');
            Ship1.Tracking_Status__c = 'Destination Port';
            ship1.Shipment_Date__c = system.today();
            update Ship1;
          //  TMS_linehaulClass.getAirlinesDetails();
        //    TMS_LinehaulClass.getCoverage();
         //   TMS_linehaulClass.getCommodityCode('Indigo');
           // TMS_LinehaulClass.getFlightSchedule('Mumbai', 'delhi', system.today(), 'indigo');
            TMS_LinehaulClass.getCoverage();
            //TMS_LinehaulClass.getIndigoTokenIndigo();
           // List<Shipment__c> shipmentList = new List<Shipment__c>();
            //shipmentList.add(Ship1);
           // string allstring = string.join(shipmentList,',');
           String shipmentList = '[{"BagList":[{"Id":"'+bag1.Id+'","Shipment__c":"'+Ship1.Id+'","Unique_Identifier__c":"MUMBAI -VAL","Cargo_Type__c":"VAL","Linehaul_Type__c":"Air","Finalised_Linehaul_Number__c":"26469144","Seal_Id__c":"'+Seal.Id+'","Next_Destination__c":"AGRA","Destination_Hub__c":"Mumbai","Finalized_Time__c":"2022-09-23T07:16:07.000Z","Shipment__r":{"Number_of_Packages__c":1,"Net_Weight__c":10,"Shipper_Name_TMS__c":"0011y00000SRNJmAAP","Consignee_Name_TMS__c":"0011y00000SRNJmAAP","Gross_Weight_UOM_TMS__c":"KG","Cargo_Type__c":"Valuable","Origin_Address_City__c":"Mumbai","Destination_Address_City__c":"Hyderabad","Destination_Hub__c":"a3m1y0000005vDiAAI","CreatedDate":"2022-09-12T17:48:08.000Z","Id":"a2p1y0000001PAtAAM","Shipper_Name_TMS__r":{"Email__c":"ahireravindra84@gmail.com","Shipping_Address_Fromula__c":"Test Street, Mumbai, Delhi, India, 100210","ShippingPostalCode":"100210","Name":"Ravindra & Co - Shipping ARUPA9695A","ShippingStreet":"Test Street","ShippingState":"Delhi","ShippingCity":"Mumbai","ShippingCountry":"India","Id":"0011y00000SRNJmAAP"},"Consignee_Name_TMS__r":{"ShippingCity":"Mumbai","ShippingState":"Delhi","Name":"Ravindra & Co - Shipping ARUPA9695A","Shipping_Address_Fromula__c":"Test Street, Mumbai, Delhi, India, 100210","ShippingCountry":"India","Email__c":"ahireravindra84@gmail.com","Id":"0011y00000SRNJmAAP"},"Destination_Hub__r":{"Branch__c":"MUMBAI","Id":"a3m1y0000005vDiAAI"}},"Seal_Id__r":{"Name":"SEAL12333","Id":"'+Seal.Id+'"}}],"BagsCount":1,"FinalizedBags":1,"Index":1,"process":false,"ShipCount":1,"UniqueBag":{"Id":"a4D1y0000004bzgEAA","Shipment__c":"'+Ship1.Id+'","Unique_Identifier__c":"MUMBAI -VAL","Cargo_Type__c":"VAL","Linehaul_Type__c":"Air","Finalised_Linehaul_Number__c":"26469144","Seal_Id__c":"'+Seal.Id+'","Next_Destination__c":"AGRA","Destination_Hub__c":"Mumbai","Finalized_Time__c":"2022-09-23T07:16:07.000Z","Shipment__r":{"Number_of_Packages__c":1,"Net_Weight__c":10,"Shipper_Name_TMS__c":"0011y00000SRNJmAAP","Consignee_Name_TMS__c":"0011y00000SRNJmAAP","Gross_Weight_UOM_TMS__c":"KG","Cargo_Type__c":"Valuable","Origin_Address_City__c":"Mumbai","Destination_Address_City__c":"Hyderabad","Destination_Hub__c":"a3m1y0000005vDiAAI","CreatedDate":"2022-09-12T17:48:08.000Z","Id":"a2p1y0000001PAtAAM","Shipper_Name_TMS__r":{"Email__c":"ahireravindra84@gmail.com","Shipping_Address_Fromula__c":"Test Street, Mumbai, Delhi, India, 100210","ShippingPostalCode":"100210","Name":"Ravindra & Co - Shipping ARUPA9695A","ShippingStreet":"Test Street","ShippingState":"Delhi","ShippingCity":"Mumbai","ShippingCountry":"India","Id":"0011y00000SRNJmAAP"},"Consignee_Name_TMS__r":{"ShippingCity":"Mumbai","ShippingState":"Delhi","Name":"Ravindra & Co - Shipping ARUPA9695A","Shipping_Address_Fromula__c":"Test Street, Mumbai, Delhi, India, 100210","ShippingCountry":"India","Email__c":"ahireravindra84@gmail.com","Id":"0011y00000SRNJmAAP"},"Destination_Hub__r":{"Branch__c":"MUMBAI","Id":"a3m1y0000005vDiAAI"}},"Seal_Id__r":{"Name":"SEAL12333","Id":"a3r1y0000004gA1AAI"}},"withoutSealBags":0} ]';
           String bagList2 = JSON.serialize(new List<Secure_Bag__c>{bag1});
          
           // calloutmethod(flight.Id,allstring,bag1.Id,BOMAir.Airport_Code__c,DelhiAir.Airport_Code__c,commodity.Commodity_Code__c); 
         //   calloutmethodSpicejet(flightspice.Id,shipmentList,bagList2); 
               
            Test.stopTest();
        }
        
    } 
    Public static testmethod void testShipments2(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName='testuser@bvcl.com' );
        insert u;
        TMS_LinehaulClass.IsAdminUser();
        Account BillingAcc = BVCL_TestDataFactory.createCustomer('BVCLBill Customer 123','Billing',false);
        BillingAcc.Email__c = 'test123@gmail.com';
        BillingAcc.Phone = '+918956232123';
        BillingAcc.Mobile__c= '+918956232123';
        BillingAcc.Last_Name__c='Test Name123';
        insert BillingAcc;
        
        Account ShipperAcc = BVCL_TestDataFactory.createCustomer('BVCLShipp Customer 124','Shipping',false);
        ShipperAcc.Email__c = 'test124@gmail.com';
        ShipperAcc.Phone = '+918956232124';
        ShipperAcc.Mobile__c= '+918956232124';
        ShipperAcc.Last_Name__c='Test Name124';
        insert ShipperAcc;
        
        Indigo_Commodity_Master__c commodity = new Indigo_Commodity_Master__c();
        commodity.Commodity_Code__c = 'SIL';
        commodity.Commodity_Description__c= 'SIL';
        commodity.Name = 'SIL';
        commodity.SHC_Code__c = 'SIL';
        insert commodity;
        
        Vistara_Commodity_Master__c commodity1 = new Vistara_Commodity_Master__c();
        commodity1.Commodity_Code__c = '10001';
        commodity1.Commodity_Description__c= 'GENERAL CARGO';
        commodity1.Name = 'GENERAL CARGO';
        commodity1.SHC_Code__c = '';
        insert commodity1;
        
        // Account ShipperAcc = BVCL_TestDataFactory.createCustomer('BVCLShipp Customer 119','Shipping',true);
        Hub__c DelhiHub = BVCL_TestDataFactory.CreateHub('HOSUR', true, 'HOSUR');
        FSE_Sales__c fse = BVCL_TestDataFactory.createFSE(DelhiHub.id,u.id,'Manager',true,true);
        Active_Pincode__c DelhiPin = BVCL_TestDataFactory.CreatePincode('110025', DelhiHub.id, 'Hyderabad', 'South', true);
        AddressBook__c ShipperAddress = BVCL_TestDataFactory.CreateAddress('Shipping',ShipperAcc.id,'Line 1',DelhiPin.id,'Cityyy',true);
        
        Shipment__c Ship1 = BVCL_TestDataFactory.CreateShipment(BillingAcc.id, ShipperAcc.id, ShipperAddress.id, ShipperAcc.id, ShipperAddress.id, false);
        ship1.Product_Description__c = 'Gold Jewellery';
        insert Ship1;
        
        Transport__c BOMAir = BVCL_TestDataFactory.CreateAirport('MUMBAI', false);
        BOMAir.Airport_Code__c = 'BOM';
        insert BOMAir;
        Transport__c DelhiAir = BVCL_TestDataFactory.CreateAirport('HYDERABAD', false);
        DelhiAir.Airport_Code__c  = 'HYD';
         insert DelhiAir;                                                          
        Flight_Schedule__c flight = BVCL_TestDataFactory.createFlight('Indigo', BOMAir.id, DelhiAir.id, true);
        Flight_Schedule__c indigoflight = BVCL_TestDataFactory.createFlight('Indigo', BOMAir.id, DelhiAir.id, false);
        indigoflight.Name = 'Indigo 6E461-BOM-HYD-2022-10-02 06:05:00';
        indigoflight.Departure_Date__c = Date.newInstance(2022, 10, 02);
        indigoflight.Origin__c = 'BOM';
        indigoflight.Destination__c = 'HYD';
        insert indigoflight;
        Flight_Schedule__c flightspice = BVCL_TestDataFactory.createFlight('SPICEJET', BOMAir.id, DelhiAir.id, true);
        
        Secure_Packaging__c SP_Bag = BVCL_TestDataFactory.createPackaging('Secure Bag','EZ000333','Available',true);
        Secure_Packaging__c Seal = BVCL_TestDataFactory.createPackaging('Secure Seal','EZ333','Available',true);
        
        
        Secure_Packaging__c trunk = BVCL_TestDataFactory.createPackaging('Secure Bag','EZ000334','Available',true);
        
        Secure_Packaging__c sp = new Secure_Packaging__c();
        sp.RecordTypeId = Schema.SObjectType.Secure_Packaging__c.getRecordTypeInfosByName().get('Secure Seal').getRecordTypeId();
        sp.Shipment__c = Ship1.id;
        sp.Name = 'X0737246';
        sp.Status__c = 'Available';
        
        insert sp;
        
         
        
       List<Secure_Bag__c> baglist1 = new List<Secure_Bag__c>(); 
        Secure_Bag__c bag1 = new Secure_Bag__c();
        bag1.Shipment__c = Ship1.id;
        bag1.Secure_Bag__c = SP_Bag.id;
        bag1.Linehaul_Type__c = 'Air';
        bag1.Finalised_Linehaul_Number__c = '12345';
        bag1.Seal_Id__c = Seal.id;
        bag1.Current_Scan_Loction__c = 'Created';
        bag1.Next_Destination__c = 'Hyderabad';
        //bag1.Current_Scan_Hub__c = DelhiHub.id;
        baglist1.add(bag1);
        insert baglist1;
        
      List<Secure_Bag__c> bglist = new List<Secure_Bag__c>();
         Secure_Bag__c bag2 = new Secure_Bag__c();
        bag2.Shipment__c = Ship1.id;
        bag2.Secure_Bag__c = SP_Bag.id;
        bag2.Linehaul_Type__c = 'Air';
        bag2.Finalised_Linehaul_Number__c = '12345';
        bag2.Seal_Id__c = Seal.id;
        bag2.Right_Seal_Id__c = sp.Id;
        bag2.Trunk_Id__c = trunk.id;
        bag2.Current_Scan_Loction__c = 'Created';
        bag2.Current_Scan_Hub__c = DelhiHub.id;
        bag2.Next_Destination__c = 'RATLAM';
         bglist.add(bag2);
         insert bglist;
        
            
        
     
             
         
        //update bag1;
        System.runAs(u){
            TMS_LinehaulClass.Shipments('Finalised',DelhiHub.name);
            TMS_LinehaulClass.Shipments('Inbound',DelhiHub.name);
            bag1.Current_Scan_Hub__c = DelhiHub.id;
            bag1.Finalised_Linehaul_Number__c = null;
            update bag1;
          //  TMS_LinehaulClass.Shipments('Outbound',DelhiHub.name);
            
            test.startTest();
            Transport__c Vehicle = BVCL_TestDataFactory.CreateVehicle('Honda12',true);
            TMS_DLHN__c dhln = new TMS_DLHN__c();
            
            bag1.Finalised_Linehaul_Number__c = 'FL2222';
            bag1.Flight_Schedule__c = flight.id;
            bag1.Vehicle__c = Vehicle.id;
            update bag1;
            List<Secure_Bag__c> baglist = new List<Secure_Bag__c>();
            baglist.add(bag1);
            TMS_LinehaulClass.SecureBagWrapper sbWrap = new TMS_LinehaulClass.SecureBagWrapper();
            sbWrap.sb = bag1;
            sbWrap.Seal = Seal.id;
            sbWrap.rseal = sp.id;
            sbWrap.trunk = trunk.id;
            sbWrap.CurrentHub = DelhiHub.id;
            sbWrap.process = true;
            
            List<TMS_LinehaulClass.SecureBagWrapper> WrapList = new List<TMS_LinehaulClass.SecureBagWrapper>();
            WrapList.add(sbWrap);
            string bagjson = JSON.serialize(WrapList); 
            
            TMS_LinehaulClass.SecureBagWrapper  sbw = new TMS_LinehaulClass.SecureBagWrapper();
            sbw.sb = bag2;
            sbw.Seal = bag2.Seal_Id__r.id;
            sbw.rseal = bag2.Right_Seal_Id__r.id;
            sbw.trunk = bag2.Trunk_Id__r.id;
            sbw.CurrentHub = delhiHub.Id;
                
            List<TMS_LinehaulClass.SecureBagWrapper> WrapList1 = new List<TMS_LinehaulClass.SecureBagWrapper>(); 
            WrapList1.add(sbw);
            string bagJson1 = JSON.serialize(WrapList1);
            
            Linehaul__c linehaulRecord = new Linehaul__c();
            linehaulRecord.Select_Airline__c = 'Indigo';
            linehaulRecord.Commodity_Name__c = commodity.Id;
            linehaulRecord.Flight_Date__c = system.today();
            linehaulRecord.Gross_Weight__c = 100;
            linehaulRecord.Origin__c = 'BOM';
            linehaulRecord.Destination__c = 'HYD';
            linehaulRecord.Shipping_City_Picklist__c = 'Mumbai';
            linehaulRecord.Shipping_Agent_Code_Picklist__c = 'BVCLBOMDOM';
            linehaulRecord.Shipping_Account_Code_Picklist__c = 'BOMBVC';
            linehaulRecord.Shipper_Name__c = 'Test Shipper';
            linehaulRecord.Shipper_Contact_Number__c = '8588007113';
            linehaulRecord.Shipper_EmailID__c = 'test@gmail.com';
            linehaulRecord.Consignee_City_Picklist__c = 'Hyderabad';
            linehaulRecord.Consignee_Account_Code_Picklist__c = 'HYDBVC';
            linehaulRecord.Consignee_Contact_Number__c = '8588007113';
            linehaulRecord.Consignee_Name__c = 'Test Consignee';
            linehaulRecord.Shipping_Address__c = 'Test address';
            linehaulRecord.Shipping_Country_Code__c = 'IN';
            linehaulRecord.Shipping_Pincode__c = '400001';
            linehaulRecord.Shipping_State__c = 'Mahatrastra';
            linehaulRecord.Consignee_Address__c = 'Test address 2';
            linehaulRecord.Consignee_Pincode__c = '110001';
            linehaulRecord.Consignee_State__c = 'Telangana';
            linehaulRecord.AWB_Consumed__c = false;
            linehaulRecord.Flight_No_for_SpiceJet_Indigo__c =  indigoflight.Id;
            Insert linehaulRecord;
            
            List<Linehaul_Tracking__c> trackingList = new List<Linehaul_Tracking__c>();
               Linehaul_Tracking__c  tracking = new Linehaul_Tracking__c();
                tracking.Linehaul_Name__c = linehaulRecord.Id;
                tracking.Status__c = 'AWB Finalized';
                tracking.AWB_Number__c = linehaulRecord.AWB_Number__c ;
                trackingList.add(tracking);
                insert trackingList;
        
            List<AWB_Number__c> awbList = new List<AWB_Number__c>();
             AWB_Number__c awb = new AWB_Number__c();
                awb.Linehaul_Tracking__c = tracking.Id; 
                awb.Shipment__c = bag1.Shipment__c;
                awb.AWB_Code__c = tracking.AWB_Number__c;
                 awbList.add(awb);
                 insert awbList;
            
            
                                         
            TMS_LinehaulClass.SecureBagsList(baglist);
            TMS_LinehaulClass.FilteredBagList(baglist, 'Delhi',SP_Bag.Id,sp.Id,'GEN');
            TMS_LinehaulClass.FilteredBagByDest(baglist, 'Del');
            Secure_Packaging__c Seal2 = BVCL_TestDataFactory.createPackaging('Secure Seal','EZ0023232','Available',true);
            //TMS_LinehaulClass.AddBox(bagjson, 'EZ333', Seal2.id, 'Delhi');  
            
            TMS_LinehaulClass.currentUserHub();
            
            dhln.Name = 'Final Num';
            dhln.Last_Number__c = 1;
            dhln.Finalized_Number__c = 1;
            insert dhln;
             TMS_LinehaulClass.SaveProcess(bagjson, 'Air', 'FL1111','FL4654', Flight.id, System.now(),'','','','','','Finalized','Mumbai','Delhi','indigo','GEN',System.now(),true);
            TMS_LinehaulClass.SaveProcess(bagjson, 'Air', 'FL1111','FL4654', Flight.id, System.now(),'','','','','','Finalized','Mumbai','Delhi','indigo','GEN',System.now(),true);
            TMS_LinehaulClass.AddBagToLineHaul(bagjson);
            TMS_LinehaulClass.AddBagToLineHaulDraft(bagjson);
            Ship1.Tracking_Status__c = 'Destination Port';
             ship1.Shipment_Date__c = system.today();
            update Ship1;
            TMS_LinehaulClass.LoggedInUserHub();
            TMS_LinehaulClass.FilteredByBagNo(bagJson,baglist,'33');
            TMS_LinehaulClass.upsertLineTracking(baglist1);  
             TMS_LinehaulClass.SaveProcess(bagjson, 'Air', 'FL1111','FL4654', Flight.id, System.now(),'','','','','','Finalized','Mumbai','Delhi','indigo','GEN',System.now(),true);
            TMS_LinehaulClass.SaveProcess(bagjson, 'Air', 'FL1111','FL4654', Flight.id, System.now(),'','','','','','Finalized','Mumbai','Delhi','indigo','GEN',System.now(),true);
            TMS_LinehaulClass.getCoverage();
            TMS_LinehaulClass.AddBagToLineHaul(bagjson);
            TMS_LinehaulClass.AddBagToLineHaulDraft(bagjson);
            Ship1.Tracking_Status__c = 'Destination Port';
            update Ship1;
            //String shipment = String.valueOf(new List<Shipment__c>{Ship1});
            //String shipment = JSON.serialize(new List<Shipment__c>{Ship1});
            String shipmentList = '[{"BagList":[{"Id":"'+bag1.Id+'","Shipment__c":"'+Ship1.Id+'","Unique_Identifier__c":"MUMBAI -VAL","Cargo_Type__c":"VAL","Linehaul_Type__c":"Air","Finalised_Linehaul_Number__c":"26469144","Seal_Id__c":"'+Seal.Id+'","Next_Destination__c":"AGRA","Destination_Hub__c":"Mumbai","Finalized_Time__c":"2022-09-23T07:16:07.000Z","Shipment__r":{"Number_of_Packages__c":1,"Net_Weight__c":10,"Shipper_Name_TMS__c":"0011y00000SRNJmAAP","Consignee_Name_TMS__c":"0011y00000SRNJmAAP","Gross_Weight_UOM_TMS__c":"KG","Cargo_Type__c":"Valuable","Origin_Address_City__c":"Mumbai","Destination_Address_City__c":"Hyderabad","Destination_Hub__c":"a3m1y0000005vDiAAI","CreatedDate":"2022-09-12T17:48:08.000Z","Id":"a2p1y0000001PAtAAM","Shipper_Name_TMS__r":{"Email__c":"ahireravindra84@gmail.com","Shipping_Address_Fromula__c":"Test Street, Mumbai, Delhi, India, 100210","ShippingPostalCode":"100210","Name":"Ravindra & Co - Shipping ARUPA9695A","ShippingStreet":"Test Street","ShippingState":"Delhi","ShippingCity":"Mumbai","ShippingCountry":"India","Id":"0011y00000SRNJmAAP"},"Consignee_Name_TMS__r":{"ShippingCity":"Mumbai","ShippingState":"Delhi","Name":"Ravindra & Co - Shipping ARUPA9695A","Shipping_Address_Fromula__c":"Test Street, Mumbai, Delhi, India, 100210","ShippingCountry":"India","Email__c":"ahireravindra84@gmail.com","Id":"0011y00000SRNJmAAP"},"Destination_Hub__r":{"Branch__c":"MUMBAI","Id":"a3m1y0000005vDiAAI"}},"Seal_Id__r":{"Name":"SEAL12333","Id":"'+Seal.Id+'"}}],"BagsCount":1,"FinalizedBags":1,"Index":1,"process":false,"ShipCount":1,"UniqueBag":{"Id":"a4D1y0000004bzgEAA","Shipment__c":"'+Ship1.Id+'","Unique_Identifier__c":"MUMBAI -VAL","Cargo_Type__c":"VAL","Linehaul_Type__c":"Air","Finalised_Linehaul_Number__c":"26469144","Seal_Id__c":"'+Seal.Id+'","Next_Destination__c":"AGRA","Destination_Hub__c":"Mumbai","Finalized_Time__c":"2022-09-23T07:16:07.000Z","Shipment__r":{"Number_of_Packages__c":1,"Net_Weight__c":10,"Shipper_Name_TMS__c":"0011y00000SRNJmAAP","Consignee_Name_TMS__c":"0011y00000SRNJmAAP","Gross_Weight_UOM_TMS__c":"KG","Cargo_Type__c":"Valuable","Origin_Address_City__c":"Mumbai","Destination_Address_City__c":"Hyderabad","Destination_Hub__c":"a3m1y0000005vDiAAI","CreatedDate":"2022-09-12T17:48:08.000Z","Id":"a2p1y0000001PAtAAM","Shipper_Name_TMS__r":{"Email__c":"ahireravindra84@gmail.com","Shipping_Address_Fromula__c":"Test Street, Mumbai, Delhi, India, 100210","ShippingPostalCode":"100210","Name":"Ravindra & Co - Shipping ARUPA9695A","ShippingStreet":"Test Street","ShippingState":"Delhi","ShippingCity":"Mumbai","ShippingCountry":"India","Id":"0011y00000SRNJmAAP"},"Consignee_Name_TMS__r":{"ShippingCity":"Mumbai","ShippingState":"Delhi","Name":"Ravindra & Co - Shipping ARUPA9695A","Shipping_Address_Fromula__c":"Test Street, Mumbai, Delhi, India, 100210","ShippingCountry":"India","Email__c":"ahireravindra84@gmail.com","Id":"0011y00000SRNJmAAP"},"Destination_Hub__r":{"Branch__c":"MUMBAI","Id":"a3m1y0000005vDiAAI"}},"Seal_Id__r":{"Name":"SEAL12333","Id":"a3r1y0000004gA1AAI"}},"withoutSealBags":0} ]';
            String bagList2 = JSON.serialize(new List<Secure_Bag__c>{bag1});
            
            //TMS_LinehaulClass.getIndigoTokenIndigo();
            calloutmethod('',shipmentList,bagList2,BOMAir.Airport_Code__c,DelhiAir.Airport_Code__c,commodity.Commodity_Code__c); 
            calloutmethod1('',shipmentList,bagList2,BOMAir.Airport_Code__c,DelhiAir.Airport_Code__c,commodity1.Commodity_Code__c); 
            //calloutmethodSpicejet(flightspice.Id,Ship1.Name,bag1.Id); 
        }
        test.stopTest();
    }
    @Future(callout=true)
    public static void calloutmethod(String flight, String Ship1, String bag,String origin,String desti,String commodity){
        Test.setMock(HttpCalloutMock.class, new FlightScheduleBatch_HelperMock());
        Date flightDate = system.today();
        Datetime flightDate2 = system.today();
        List<Commodity_Code_List__mdt> commodityList = new List<Commodity_Code_List__mdt>();
        commodityList = [Select Id, DeveloperName,Airline__c,Commodity_Code__c,Commodity_Description__c,Product_Type__c,SCH_Code__c from Commodity_Code_List__mdt where Airline__c= 'Indigo' LIMIT 1];
        
        
        flight = '';

        TMS_LinehaulClass.getAvailableAwb('MUMBAI','Hyderabad',flightDate,flight,'Indigo');
        String token = TMS_LinehaulClass.getIndigoTokenIndigo();
        String session = TMS_LinehaulClass.getIndigoSessionIdIndigo(token);
        
        TMS_LinehaulClass.getAWBFromAPICalloutIndigo(origin,desti,flightDate2,Ship1,bag,commodity,'FL4654');
       // TMS_LinehaulClass.getAWBNumberfromCallOutIndigo(token,session,origin,'DEL',flightDate2,Ship1,bag,commodityList);
        
        system.debug('token '+token);
        system.debug('session '+session);
        system.debug(' origin '+origin);
        system.debug('destinaion '+desti);
        system.debug('flight date '+flightDate2);
        system.debug('bag '+bag);
        system.debug('commodity '+commodityList);
        system.debug('Ship1 '+Ship1);
        string loginname = 'BVCLBOM';
        //TMS_LinehaulClass.createAWBRequestIndigo(loginname,token,session,origin,desti,flightDate2,Ship1,bag,commodityList);
        //TMS_LinehaulClass.getIndigoTokenIndigo();
        //TMS_LinehaulClass.getIndigoSessionIdIndigo('CEF99B1B-B29A-484A-8583-0A12DBBC1941');
    }
    
 @Future(callout=true)
    public static void calloutmethod1(String flight, String Ship1, String bag,String origin,String desti,String commodity){
        Test.setMock(HttpCalloutMock.class, new FlightScheduleBatch_HelperMock());
        Date flightDate = system.today();
        Datetime flightDate2 = system.today();
        List<Commodity_Code_List__mdt> commodityList = new List<Commodity_Code_List__mdt>();
        commodityList = [Select Id, DeveloperName,Airline__c,Commodity_Code__c,Commodity_Description__c,Product_Type__c,SCH_Code__c from Commodity_Code_List__mdt where Airline__c= 'Vistara' LIMIT 1];
        
        
        flight = '';

        TMS_LinehaulClass.getAvailableAwb('MUMBAI','Hyderabad',flightDate,flight,'Indigo');
        String token = TMS_LinehaulClass.getvistaraTokenNumber();
        String session = TMS_LinehaulClass.getVistaraSessionID(token,origin);
        
        TMS_LinehaulClass.getAWBFromAPICalloutvistara(origin,desti,flightDate2,Ship1,bag,commodity,'FL4654');
       // TMS_LinehaulClass.getAWBNumberfromCallOutIndigo(token,session,origin,'DEL',flightDate2,Ship1,bag,commodityList);
        
        system.debug('token '+token);
        system.debug('session '+session);
        system.debug(' origin '+origin);
        system.debug('destinaion '+desti);
        system.debug('flight date '+flightDate2);
        system.debug('bag '+bag);
        system.debug('commodity '+commodityList);
        system.debug('Ship1 '+Ship1);
        string loginname = 'BVCLBOM';
        //TMS_LinehaulClass.createAWBRequestIndigo(loginname,token,session,origin,desti,flightDate2,Ship1,bag,commodityList);
        //TMS_LinehaulClass.getIndigoTokenIndigo();
        //TMS_LinehaulClass.getIndigoSessionIdIndigo('CEF99B1B-B29A-484A-8583-0A12DBBC1941');
    } 
    @Future(callout=true)
    public static void calloutmethodSpicejet(String flight, String Ship1, String bag){
         Test.setMock(HttpCalloutMock.class, new Track_AWB_SpiceJetHelperMock());
        Date flightDate = system.today();
        Datetime flightDate2 = system.now();
        
        Indigo_Commodity_Master__c commodity = new Indigo_Commodity_Master__c();
        commodity.Commodity_Code__c = 'VAL';
        commodity.Commodity_Description__c= 'VALUABLE CARGO';
        commodity.Name = 'VAL';
        commodity.SHC_Code__c = '';
        insert commodity;
        Transport__c DelhiAir = BVCL_TestDataFactory.CreateAirport('Delhi Airport', false);
        DelhiAir.Airport_Code__c = 'DEL';
        DelhiAir.Name = 'DEL';
        insert DelhiAir;
        Transport__c BOMAir = BVCL_TestDataFactory.CreateAirport('Mumbai Airport', false);
        BOMAir.Airport_Code__c = 'BOM';
        BOMAir.Name = 'BOM';
        insert BOMAir;
        Flight_Schedule__c flight2 = BVCL_TestDataFactory.createFlight('SPICEJET', BOMAir.id, DelhiAir.id, False); 
        flight2.Schedule_Time_To_Departure__c = system.now();
        insert flight2;
                  
        
        Shipper_Consignee_Detail_SpiceJet__c spiceDetail = new Shipper_Consignee_Detail_SpiceJet__c();
        spiceDetail.Shipper_State_Code__c ='27';
        spiceDetail.Name = 'MUMBAI-DELHI';
        spiceDetail.Shipper_Pincode__c = '400093';
        spiceDetail.Shipper_Name__c = 'B V C LOGISTICS PRIVATE LIMITED';
        spiceDetail.Shipper_Email__c = 'test@gmail.com';
        spiceDetail.Shipper_Country_Code__c = 'IN';
        spiceDetail.Shipper_Contact_No__c = '9323106410';
        spiceDetail.Shipper_Code__c  = 'BVCBOMDO';  
        spiceDetail.Shipper_City__c = 'MUMBAI';
        spiceDetail.Shipper_Airport_Code__c = 'BOM';
        spiceDetail.Shipper_Address__c = '1102 Solitaire Corporate Park, 167- Guru Hargovindji Marg, Chakala, Andheri (E), Mumbai ? 400 093';
        spiceDetail.Consignee_State_Code__c = '07';
        spiceDetail.Consignee_Pincode__c = '110055';
        spiceDetail.Consignee_Name__c = 'B V C LOGISTICS PRIVATE LIMITED';
        spiceDetail.Consignee_Email__c = 'test2@gmail.com';
        spiceDetail.Consignee_Country_Code__c = 'IN';
        spiceDetail.Consignee_Contact_No__c = '9311983900';
        spiceDetail.Consignee_Code__c = 'BVCDELDO';
        spiceDetail.Consignee_City__c = 'DELHI';
        spiceDetail.Consignee_Airport_Code__c = 'DEL';
        spiceDetail.Consignee_Address__c = '# 2E / 16, Jhandewalan Extension, New Delhi 110 055';
        insert spiceDetail;
       
        
        
        Linehaul__c linehaulRecord2 = new Linehaul__c();
        linehaulRecord2.Select_Airline__c = 'SPICEJET';
        linehaulRecord2.Commodity_Name__c = commodity.Id;
        linehaulRecord2.Flight_Date__c = system.today();
        linehaulRecord2.Gross_Weight__c = 100;
        linehaulRecord2.Origin__c = 'BOM';
        linehaulRecord2.Destination__c = 'DEL';
        linehaulRecord2.AWB_Consumed__c = false;
        linehaulRecord2.Width_Dimension__c = 12.00;
        linehaulRecord2.Length_Dimension__c = 12.00;
        linehaulRecord2.Height_Dimension__c = 12.00;
        linehaulRecord2.Weight_Dimension__c = 12.00;
        linehaulRecord2.Flight_No_for_SpiceJet_Indigo__c = flight2.Id;
        linehaulRecord2.Shipper_Consignee_Detail_SpiceJet__c = spiceDetail.Id; 
        linehaulRecord2.from__c = system.now();
        
        Insert linehaulRecord2;
   
        /*  Linehaul__c linehaulRecord = new Linehaul__c();
linehaulRecord.Select_Airline__c = 'SPICEJET';
linehaulRecord.Commodity_Name__c = commodity.Id;
linehaulRecord.Flight_Date__c = system.today();
linehaulRecord.Gross_Weight__c = 100;
linehaulRecord.Origin__c = 'BOM';
linehaulRecord.Destination__c = 'DEL';
linehaulRecord.Shipping_City_Picklist__c = 'Mumbai';
linehaulRecord.Shipping_Agent_Code_Picklist__c = 'BVCLBOMDOM';
linehaulRecord.Shipping_Account_Code_Picklist__c = 'BOMBVC';
linehaulRecord.Shipper_Name__c = 'Test Shipper';
linehaulRecord.Shipper_Contact_Number__c = '8588007113';
linehaulRecord.Shipper_EmailID__c = 'test@gmail.com';
linehaulRecord.Consignee_City_Picklist__c = 'HYDERABAD';
linehaulRecord.Consignee_Account_Code_Picklist__c = 'HYDBVC';
linehaulRecord.Consignee_Contact_Number__c = '8588007113';
linehaulRecord.Consignee_Name__c = 'Test Consignee';
linehaulRecord.Shipping_Address__c = 'Test address';
linehaulRecord.Shipping_Country_Code__c = 'IN';
linehaulRecord.Shipping_Pincode__c = '400001';
linehaulRecord.Shipping_State__c = 'Mahatrastra';
linehaulRecord.Consignee_Address__c = 'Test address 2';
linehaulRecord.Consignee_Pincode__c = '500108';
linehaulRecord.Consignee_State__c = 'Telangana';
linehaulRecord.AWB_Consumed__c = false;
linehaulRecord.Flight_No_for_SpiceJet_Indigo__c = flight2.Id;
linehaulRecord.from__c = system.now();
Insert linehaulRecord; */
        string sptoken = 'BearereyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOlwvXC9xYS50aGVzcGljZXRhZy5jb21cL2FkbWluXC9hc';
         calloutmethodSpicejet(flight2.Id,'',''); 
   //     TMS_LinehaulClass.getSpiceJetTokenSpiceJet();
        Test.setMock(HttpCalloutMock.class, new TMS_FlightSchedule_Batch_Mock());
        TMS_LinehaulClass.getAvailableAwb('BOM','DEL',flightDate,flight,'SPICEJET');
        system.debug('origin test class' +BOMAir.Airport_Code__c);
        system.debug('destination test class '+DelhiAir.Airport_Code__c);
        TMS_LinehaulClass.getIndigoTokenIndigo();
        TMS_LinehaulClass.getIndigoSessionIdIndigo('CEF99B1B-B29A-484A-8583-0A12DBBC1941');
      //  TMS_LinehaulClass.getAWBNumberfromCallOutSpiceJet(sptoken, 'Mumbai', 'Delhi', flightDate, Ship1, bag, flightDate, commodity.id);
            
     
        
    } 
}