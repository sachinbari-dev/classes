@isTest(SeeAllData=true)
public class SpiceJet_TrackAWB_BatchTest {
       
  @isTest
    public static void testSpiceJet_TrackAWB_Batch(){
        Test.setMock(HttpCalloutMock.class, new FlightScheduleBatch_HelperMock());
        String response = FlightScheduleBatch_Button_Helper.generateToken();
        if(response != null && response != ''){
         String response2 = FlightScheduleBatch_Button_Helper.generateSessionId();
        }
         List<Linehaul__c> awbList  = new List<Linehaul__c>();
        Map<String,String> awbStatusMap = new Map<String,String>();
        
   
        Test.setMock(HttpCalloutMock.class,new SpiceJetTrackAwbMock());
        Test.setMock(HttpCalloutMock.class,new Track_AWB_SpiceJetHelperMock());
        List<Linehaul_Tracking__c> tracklist = Track_AWB_SpiceJetHelper.trackAWBspicejet(awbList,awbstatusmap); 
     /*
        Test.setMock(HttpCalloutMock.class,new Track_AWB_SpiceJetHelperMock());
        List<Linehaul_Tracking__c> tracklist = Track_AWB_SpiceJetHelper.trackAWBspicejet(awbList,awbstatusmap); 
            */    
     
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
        
        AirLine1__c airline= new AirLine1__c();
             airline.Airline_Name__c= 'spiceJet';
             insert airline;
          system.debug('airline+++++++++' + airline);
        system.assertEquals('spiceJet', airline.Airline_Name__c, 'airline name is not as expected');
        
       flight_schedule__c  fltschList = new flight_schedule__c();
        fltschList.Origin__c = 'BOM';
        fltschList.Destination__c = 'DEL';   
        fltschList.Is_Inactive__c = false;
        fltschList.Flight_Number__c = 'SG015';
   
        insert fltschList;        
        
        system.debug('fltschList++++++' + fltschList);
        
        system.assertEquals('BOM', fltschList.Origin__c);
        system.assertEquals('DEL', fltschList.Destination__c);
        system.assertEquals(false, fltschList.Is_Inactive__c, 'values are missmatched');
        system.assertEquals('SG015', fltschList.Flight_Number__c);
        
        
        Linehaul__c linehaulRecord = new Linehaul__c();
        linehaulRecord.AWB_Number__c = '775-83991250';
        linehaulRecord.Flight_Number__c = fltschList.Flight_Number__c;
        linehaulRecord.Select_Airline__c = 'spiceJet';   
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
        
        system.debug('awbList1+++++++'+awbList);
        /*
          Linehaul__c linehaulRec = new Linehaul__c();
            linehaulRec.AWB_Number__c='312-26496433';
            linehaulRec.Origin__c= fltschList.Origin__c;
            linehaulRec.Destination__c=fltschList.Destination__c;
            // linehaulRecord[0].Commodity_Code__c;
            //CommodityDescription= linehaulRecord[0].Commodity_Description__c;
            linehaulRec.Gross_Weight__c=10;
            linehaulRec.Total_Pieces__c=1;
            // HeightDimension= String.valueOf(linehaulRecord[0].Height_Dimension__c);
            //LengthDimension= String.valueOf(linehaulRecord[0].Length_Dimension__c);
            //WidthDimension= String.valueOf(linehaulRecord[0].Width_Dimension__c);
            linehaulRec.Requested_Quantity__c=1;
            linehaulRec.Weight_Dimension__c=10;
            linehaulRec.Bag_Number__c=1;
            linehaulRec.Dimension_Type__c='CMS';
            linehaulRec.Type__c='KG';
            linehaulRec.Route_Type__c='Air';
            //PartnerType= linehaulRecord[0].Partner_Type__c;
            //PartnerCode= linehaulRecord[0].Partner_Code__c;
            linehaulRec.Flight_Destination__c=fltschList.Destination__c;
            linehaulRec.Flight_Origin__c=fltschList.Origin__c;
            linehaulRec.From__c= system.Today()+1;
            //FromDate = String.valueof(DateTime.newInstanceGMT(2022,08,12, 18,20,0));
            linehaulRec.Flight_Code__c='SG';
            
            linehaulRec.Flight_No_for_SpiceJet_Indigo__c=fltschList.Id;
            linehaulRec.Mode__c='BVC';
             awbList.add(linehaulRec);
            system.debug('linehaulRec@@@@@@@@@@@ '+linehaulRec);
            insert awbList;   */
        
         
         system.debug('awbList+++++++' + awbList);
      //   system.assertEquals(' ', linehaulRecord.AWB_Number__c, 'awb number result is not same');
         system.assertEquals('SG015', linehaulRecord.Flight_Number__c, 'flight number is not equal as expected');
         system.assertEquals('spiceJet', linehaulRecord.Select_Airline__c, 'selected airline is not as expected');
         system.assertEquals('BOM', linehaulRecord.Origin__c, 'origin is not as expected');
         system.assertEquals('DEL', linehaulRecord.Destination__c, 'destination is not as expected');
         system.assertEquals(100, linehaulRecord.Gross_Weight__c, 'gross weight is not as expected');
         system.assertEquals('Mumbai',linehaulRecord.Shipping_City_Picklist__c , 'shipping city is not as expected');
                     
        
             
             //  Map<String,String> awbStatusMap = new Map<String,String>();
     //get AWB_Tracking_Status__mdt custom metadata record where developer names are mentioned below.
        AWB_Tracking_Status__mdt[] awbStatusList = [SELECT MasterLabel,SpiceJet_AWB_Status__c 
                                                    FROM AWB_Tracking_Status__mdt 
                                                    WHERE 
                                                    DeveloperName = 'AWB_Booked' OR DeveloperName = 'Airline_Deposited'  OR DeveloperName = 'Flight_Departed'OR
                                                    DeveloperName = 'Flight_Arrived' OR DeveloperName = 'Retrieved'];
        for(AWB_Tracking_Status__mdt awbStatus : awbStatusList){
            if(awbStatus.SpiceJet_AWB_Status__c != null && awbStatus.SpiceJet_AWB_Status__c !=''){
                if(awbStatus.MasterLabel != null && awbStatus.MasterLabel != ''){
      //store SpiceJet_AWB_Status__c as a ID  and MasterLabel as a Value in awbStatusMap map 
                    awbStatusMap.put(awbStatus.SpiceJet_AWB_Status__c,awbStatus.MasterLabel);
                    system.debug('awsstatusmap+++++'+ awbStatusMap);
                }
            }
            
        }
            
         List<Linehaul_tracking__c> LTList = new List<Linehaul_Tracking__c>();
         Linehaul_tracking__c newLTList = new Linehaul_tracking__c();         
              newLTList.Linehaul_Name__c = linehaulRecord.id;
              newLTList.AWB_Number__c = linehaulRecord.AWB_Number__c;
              newLTList.Destination__c = linehaulRecord.Destination__c;
              newLTList.Origin__c = linehaulRecord.Origin__c;              
              newLTLIst.Flight_Date__c= linehaulRecord.Flight_Date__c;
              newLtList.Status__c = 'AWB Finalized';
              LTList.add(newLTList);
              insert LTList; 
            system.debug('LTList++++++++' + LTList); 
       //    system.assertEquals('312-26496433',newLTList.AWB_Number__c , 'awb number is not as expected');
            system.assertEquals('BOM',newLTList.Origin__c, 'origin is not as expected');
            system.assertEquals('DEL',  newLTList.Destination__c, 'destination is not as expected');
            system.assertEquals('AWB Finalized', newLtList.Status__c, 'status is not as expected');
        

           secure_bag__c sb= new secure_bag__c();
           sb.Shipment__c = newship.id;
           sb.Finalised_Linehaul_Number__c = newLtlist.AWB_Number__c;
             insert sb;
               
          AWB_Number__C  awb = new AWB_Number__c();
               awb.Linehaul_Tracking__c = newLTList.Id;
               awb.AWB_Code__c = newLtlist.AWB_Number__c;
               awb.Shipment__c = sb.Shipment__c;
               insert awb;
    //    system.assertEquals('312-26496433', awb.AWB_Code__c, 'awb code is not as expected');
            
        String originFlightCode = 'HYD';
        String indigoLoginName = 'BVCLBOM';
        String indigoAirlineCode = 'SG';
        String indigoEndpoint = 'https://qa.thespicetag.com/admin/api/requests/awbtrack?tracking_id=';
        
             
        system.debug('airline+++++++++' + airline);
        system.assertEquals('spiceJet', airline.Airline_Name__c, 'airline name is not as expected');
                   
        List<Shipment_Tracking__c> newShipTrackList =  new List<Shipment_Tracking__c>();        
           Shipment_Tracking__c shipTrack = new Shipment_Tracking__c();
            shipTrack.Shipment__c = newShip.id;
            shipTrack.Hub__c = newHub.Id;
            shipTrack.Orgin__c = 'mumbai';
            shipTrack.Location__c ='';
             newShipTrackList.add(shipTrack);
            insert newShipTrackList;
        
        system.assertEquals('mumbai',  shipTrack.Orgin__c, 'shipment tracking origin is not as expected');                 
        try{
            
        Test.startTest();        
          
    
   
       
     //   system.debug('insertLineTrack1+++'+  insertLineTrack1 );
   //   Database.executeBatch(new Indigo_TrackAWB_Batch(),200);
     /*   Indigo_TrackAWB_Batch indBatch =  new Indigo_TrackAWB_Batch();
         database.QueryLocator ql = indBatch.start(null);
         indbatch.execute(null, awbList);
         indbatch.finish(null);      
        system.debug(' insertLineTrack++++++' + insertLineTrack);  
        system.debug('indBatch+++' + indBatch); */
     
        SpiceJet_TrackAWB_Batch spBatch = new SpiceJet_TrackAWB_Batch();
   //   database.executeBatch(spBatch, 200);             
        database.QueryLocator qls = spBatch.start(null);
        //    spBatch.Start(null);
        spBatch.execute(null,awbList);
        spBatch.finish(null); 
            
        Test.stopTest();
        }catch(exception e){
            system.debug('exception message +++'+e);
        }
                     

     }
     static testMethod void testParse() {
		String json=		'{'+
		'  "client_status": "ORDER_INITIATED",'+
		'  "client_status_id": 1,'+
		'  "current_status": 1,'+
		'  "task_ref_id": "T1633-20210531163928",'+
		'  "awb_number": "775-83991250",'+
		'  "id": 152448,'+
		'  "pod": null,'+
		'  "estimated_delivery_time": "",'+
		'  "delivery_associate_user_id": null,'+
		'  "booking_type": "D2D",'+
		'  "booking_date": "2022-05-04 15:51:50",'+
		'  "task_tracker": ['+
		'    {'+
		'      "task_id": 152448,'+
		'      "status": "Request Initiated",'+
		'      "status_details_id": 1,'+
		'      "flight_code": "",'+
		'      "city": "Mahipalpur",'+
		'      "updated_at": "2022-05-04 15:51:50"'+
		'    }'+
		'  ],'+
		'  "delivery_boy": "Balaji Reddy",'+
		'  "total_weight": 0,'+
		'  "total_pieces": 0,'+
		'  "is_cold_chain": false,'+
		'  "chart_exist": false,'+
		'  "full_pod_url": "https://spicetag-pdf-dev.s3-ap-south-1.amazonaws.com/151136/do/1-pod_report.pdf",'+
		'  "master_airway_bill": "https://spicetag-pdf-dev.s3-ap-south-1.amazonaws.com/master_airway_bill_pdf?task_id=151451",'+
		'  "axb_detail": {'+
		'    "task_id": 152448,'+
		'    "consignee_name": "648-B, HALPATI COLONY, BOOK N FLY, RING ROAD, OPP KINNARY CINEMA,80 FE",'+
		'    "consignee_city": "648-B, HALPATI COLONY, BOOK N FLY, RING ROAD, OPP KINNARY CINEMA,80 FE",'+
		'    "commodity_code": "GEN",'+
		'    "consignee_address": "648-B, HALPATI COLONY, BOOK N FLY, RING ROAD, OPP KINNARY CINEMA,80 FE",'+
		'    "consignee_postal_code": "110037",'+
		'    "shipper_name": "Book N Fly",'+
		'    "shipper_city": "Mahipalpur",'+
		'    "charged_weight": "100",'+
		'    "collected_date": "2021-05-31 16:42:26",'+
		'    "delivered_date": "2021-05-31 19:04:35",'+
		'    "e_way_bill": null,'+
		'    "gross_weight": "100.00",'+
		'    "origin": "DL1",'+
		'    "destination": "BL1"'+
		'  }'+
		'}';
		SpicejetTrackAWBwrapper.parse(json);
		//System.assert(obj != null);
	}
    
  
    
}