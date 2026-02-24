@isTest
public class vistaraTrackAWBHelperTest {
  
    @isTest 
    public static void generateToken_TestUnit() { 
        Test.setMock(HttpCalloutMock.class, new FlightScheduleBatch_HelperMock());
        String response = FlightScheduleBatch_Button_Helper.generateToken();        
        if(response != null && response != ''){
         String response2 = FlightScheduleBatch_Button_Helper.generateSessionId();
        }
        string originfltcode = 'BOM'; 
        string airlineId='';
        string loginName='BVCLBOM';
        string airlinecode = '6E';
        string endpoints = 'http://indigouatwebservice.azurewebsites.net/SKMobilityWS.asmx/GetFlightListV2';
        List<flight_schedule__c> scLisyt = FlightScheduleBatch_Button_Helper.getFlightDetails(originfltcode, airlineId, loginName, airlinecode, endpoints); 
        Test.setMock(HttpCalloutMock.class,new vistaraTrackAWBHelperMock());
        string response4 = vistaraTrackAWBHelper.generateToken();
              
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
        Acc.Phone = '94746367837';
        Acc.First_Name__c = 'billing firstname';               
        Acc.Last_Name__c = 'billing lst name';
  //      Acc.Name_As_Per_PAN__pc = 'EQUPNB123K';
        Acc.Name_As_Per_PAN_Manual_Input__c = 'new cust';
        Acc.PAN_Number_of_Entity__c = 'EQUPNB123K';      
        Insert Acc;
        system.assertEquals('TITAN COMPANY LIMITED - Billing EQUPNB123K', Acc.name);
        system.assertEquals('Active', Acc.Customer_Status__c);
        system.assertEquals('billing firstname', Acc.First_Name__c , 'Account firstNAme is not as expevcted');
        system.assertEquals('billing lst name', Acc.Last_Name__c, 'Account lastName is not as expected');
        system.assertEquals('EQUPNB123K',  Acc.PAN_Number_of_Entity__c, 'PAN entity is not as expected');
        system.assertEquals('new cust',  Acc.Name_As_Per_PAN_Manual_Input__c, 'name as per PAN is not as expected');
        system.assertEquals('94746367837', Acc.Phone, 'phone is not as expected');
        system.assertEquals('abc@sdcn.com',  Acc.Primary_Customer_Email__c , 'email is not same as actual email');
        system.assertEquals('billing firstname', Acc.First_Name__c);

          Hub__c newHub = new Hub__c();
          newHub.Name = 'delhi Acr';
          newHub.Branch__c = 'delhi';
          insert newHub;
        system.debug('Name+++++' + newHub.Name);
        system.debug('branch++++' + newHub.Branch__c);
        system.assertEquals('delhi Acr', newHub.Name);
        system.assertEquals('delhi', newhub.Branch__c, 'hub branch is not as expected');
        
         shipment__c newShip = new Shipment__c();
           newship.Account__c = Acc.id;
           newShip.Tracking_Status__c = 'origin hub';
           newship.Origin_Hub__c = newhub.id;
           insert newShip;
        system.assertEquals('origin hub', newShip.Tracking_Status__c,'tracking status is not'); 
        
        Indigo_Commodity_Master__c commodity = new Indigo_Commodity_Master__c();
        commodity.Commodity_Code__c = 'SIL';
        commodity.Commodity_Description__c= 'SIL';
        commodity.Name = 'SIL';
        commodity.SHC_Code__c = 'SIL';
        insert commodity;
        system.debug('commodity++++'+ commodity);
        system.assertEquals('SIL', commodity.Commodity_Code__c, 'commodity code is not as expected');
        system.assertEquals('SIL', commodity.Name, 'name is not as expected');
        system.assertEquals('SIL', commodity.Commodity_Description__c, 'description is not as expected');
        
       flight_schedule__c  fltschList = new flight_schedule__c();
        fltschList.Origin__c = 'BOM';
        fltschList.Destination__c = 'DEL';   
        fltschList.Is_Inactive__c = false;
        fltschList.Flight_Number__c = '6E5332';
   
        insert fltschList;        
        
        system.debug('fltschList++++++' + fltschList);
        
        system.assertEquals('BOM', fltschList.Origin__c);
        system.assertEquals('DEL', fltschList.Destination__c);
        system.assertEquals(false, fltschList.Is_Inactive__c, 'values are missmatched');
        system.assertEquals('6E5332', fltschList.Flight_Number__c);
        
        List<Linehaul__c> awbList  = new List<Linehaul__c>();
        Linehaul__c linehaulRecord = new Linehaul__c();
        linehaulRecord.AWB_Number__c = '312-26496433';
        linehaulRecord.Flight_Number__c = fltschList.Flight_Number__c;
        linehaulRecord.Select_Airline__c = 'Indigo';
        linehaulRecord.Commodity_Name__c = commodity.Id;
        linehaulRecord.Flight_Date__c = system.today();
        linehaulRecord.Gross_Weight__c = 100;
        linehaulRecord.Origin__c = fltschList.Origin__c;
        linehaulRecord.Destination__c = fltschList.Destination__c;
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
         Insert linehaulRecord;
         awbList.add(linehaulRecord);
        
         system.debug('awbList+++++++' + awbList);
         system.assertEquals('312-26496433', linehaulRecord.AWB_Number__c, 'awb number result is not same');
         system.assertEquals('6E5332', linehaulRecord.Flight_Number__c, 'flight number is not equal as expected');
         system.assertEquals('Indigo', linehaulRecord.Select_Airline__c, 'selected airline is not as expected');
         system.assertEquals('BOM', linehaulRecord.Origin__c, 'origin is not as expected');
         system.assertEquals('DEL', linehaulRecord.Destination__c, 'destination is not as expected');
         system.assertEquals(100, linehaulRecord.Gross_Weight__c, 'gross weight is not as expected');
         system.assertEquals('Mumbai',linehaulRecord.Shipping_City_Picklist__c , 'shipping city is not as expected');
                     
        
         List<Linehaul_tracking__c> LTList = new List<Linehaul_Tracking__c>();
         Linehaul_tracking__c newLTList = new Linehaul_tracking__c();         
              newLTList.Linehaul_Name__c = linehaulRecord.Name;
              newLTList.AWB_Number__c = linehaulRecord.AWB_Number__c;
              newLTList.Destination__c = linehaulRecord.Destination__c;
              newLTList.Origin__c = linehaulRecord.Origin__c;              
              newLTLIst.Flight_Date__c= linehaulRecord.Flight_Date__c;
              newLtList.Status__c = 'AWB Booked';
              LTList.add(newLTList);
              insert LTList; 
            system.debug('LTList++++++++' + LTList); 
            system.assertEquals('312-26496433',newLTList.AWB_Number__c , 'awb number is not as expected');
            system.assertEquals('BOM',newLTList.Origin__c, 'origin is not as expected');
            system.assertEquals('DEL',  newLTList.Destination__c, 'destination is not as expected');
            system.assertEquals('AWB Booked', newLtList.Status__c, 'status is not as expected');
        
        AWB_Number__C  awb = new AWB_Number__c();
               awb.Linehaul_Tracking__c = newLTList.Id;
               awb.AWB_Code__c = '312-26496433';
               awb.Shipment__c = newShip.Id;
               insert awb;
        system.assertEquals('312-26496433', awb.AWB_Code__c, 'awb code is not as expected');
            
        String originFlightCode = 'HYD';
        String indigoLoginName = 'BVCCOKDOM';
        String indigoAirlineCode = 'UK';
        String indigoEndpoint = 'https://uk-uat-api-appservice.azurewebsites.net/SKMobilityWS.asmx/GetTrackingInfoV2';
        
        AirLine1__c airline= new AirLine1__c();
             airline.Airline_Name__c= 'vistara';
             insert airline;
     
        system.debug('airline+++++++++' + airline);
        system.assertEquals('vistara', airline.Airline_Name__c, 'airline name is not as expected');
        
         Map<String,String> awbStatusMap = new Map<String,String>();
         AWB_Tracking_Status__mdt[] awbStatusList = [SELECT MasterLabel,Vistara_AWB_Status__c 
                                                 FROM AWB_Tracking_Status__mdt 
                                                 WHERE 
                                                 DeveloperName = 'AWB_Booked' OR DeveloperName = 'AWB_Finalized' OR DeveloperName = 'Airline_Deposited' OR 
                                                 DeveloperName = 'On_Route_Airport' OR DeveloperName = 'Pre_Flight_at_Airport' OR DeveloperName = 'Flight_Departed'OR
                                                 DeveloperName = 'Flight_Arrived' OR DeveloperName = 'Pre_Retrieval_at_Airport' OR DeveloperName = 'Retrieved'];
        for(AWB_Tracking_Status__mdt awbStatus : awbStatusList){
            if(awbStatus.Vistara_AWB_Status__c != null && awbStatus.Vistara_AWB_Status__c !=''){
                if(awbStatus.MasterLabel != null && awbStatus.MasterLabel != ''){
                    awbStatusMap.put(awbStatus.Vistara_AWB_Status__c,awbStatus.MasterLabel);
                    system.debug('awbStatusMap+++++++' + awbStatusMap);
                }
                
            }
            
        }
               
      
        
        List<Shipment_Tracking__c> newShipTrackList =  new List<Shipment_Tracking__c>();
        
           Shipment_Tracking__c shipTrack = new Shipment_Tracking__c();
            shipTrack.Shipment__c = newShip.id;
            shipTrack.Hub__c = newHub.Id;
            shipTrack.Orgin__c = 'mumbai';
            shipTrack.Location__c ='';
             newShipTrackList.add(shipTrack);
            insert newShipTrackList;
        
        system.assertEquals('mumbai',  shipTrack.Orgin__c, 'shipment tracking origin is not as expected');
                      
        Test.startTest();
        
        List<Linehaul_Tracking__c> insertLineTrack = vistaraTrackAWBHelper.trackAWB(awbList,response,awbStatusMap);     
         List<Linehaul_Tracking__c> updateLineTrack  = vistaraTrackAWBHelper.updateTrackAWB(LTList, response, awbStatusMap);
        VistaraTrackAwbBatch indBatch =  new VistaraTrackAwbBatch();
         database.QueryLocator ql = indBatch.start(null);
         indbatch.execute(null, awbList);
         indbatch.finish(null);      
        system.debug(' insertLineTrack++++++' + insertLineTrack);  
        system.debug('indBatch+++' + indBatch);
     /*
        SpiceJet_TrackAWB_Batch spBatch = new SpiceJet_TrackAWB_Batch();
        database.QueryLocator qls = spBatch.start(null);
        spBatch.execute(null, awbList);
        spBatch.finish(null); */
        Test.stopTest();
    }
}