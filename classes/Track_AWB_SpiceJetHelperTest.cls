@isTest
public class Track_AWB_SpiceJetHelperTest {
   @istest
    public static void testTrackAwbSpicejetHelper(){
        List<Linehaul__c> awbList  = new List<Linehaul__c>();
        Map<String,String> awbStatusMap = new Map<String,String>();
        
         
        
      Test.setMock(HttpCalloutMock.class,new Track_AWB_SpiceJetHelperMock());
          List<Linehaul_Tracking__c> LTTrackingList = Track_AWB_SpiceJetHelper.trackAWBspicejet(awbList,awbStatusMap);
   
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
         
    
       flight_schedule__c  fltschList = new flight_schedule__c();
        fltschList.Origin__c = 'BOM';
        fltschList.Destination__c = 'DEL';   
        fltschList.Is_Inactive__c = false;
        fltschList.Flight_Number__c = 'SG015';
   
        insert fltschList;   
        
   
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
        linehaulRecord2.AWB_Number__c ='775-83991250';
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
        linehaulRecord2.Flight_No_for_SpiceJet_Indigo__c = fltschList.Id;
        linehaulRecord2.Shipper_Consignee_Detail_SpiceJet__c = spiceDetail.Id; 
        linehaulRecord2.from__c = system.now();     
         awbList.add(linehaulRecord2);
         system.debug('linehaulRec@@@@@@@@@@@ '+linehaulRecord2);
          insert awbList;
        
        system.debug('awbList:'+ awbList );

        
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
              newLTList.Linehaul_Name__c = linehaulRecord2.Name;
              NewLTList.Airport_Code__c = 'BOM';
              newLTList.AWB_Number__c = linehaulRecord2.AWB_Number__c;
              newLTList.Destination__c = linehaulRecord2.Destination__c;
              newLTList.Origin__c = linehaulRecord2.Origin__c;              
              newLTLIst.Flight_Date__c= linehaulRecord2.Flight_Date__c;
              newLtList.Status__c = 'AWB Booked';
              newLTList.Weight__c = '23';
              
              LTList.add(newLTList);
               insert LTList; 
         //    LTList.addAll(Track_AWB_SpiceJetHelper.trackAWBspicejet(awbList,awbStatusMap));
            system.debug('LTList++++++++' + LTList); 
        
        
       //    system.assertEquals('312-26496433',newLTList.AWB_Number__c , 'awb number is not as expected');
            system.assertEquals('BOM',newLTList.Origin__c, 'origin is not as expected');
            system.assertEquals('DEL',  newLTList.Destination__c, 'destination is not as expected');
            system.assertEquals('AWB Booked', newLtList.Status__c, 'status is not as expected');
        
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
            
      
            
            Test.startTest();
                Track_AWB_SpiceJetHelper.trackAWBspicejet(awbList,awbStatusMap);
         
            Test.stopTest();
     
            
      
      
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