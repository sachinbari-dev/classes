@isTest
global class Track_AWB_SpiceJetHelperMock1 implements HttpCalloutMock {
    
  global HTTPResponse respond(HTTPRequest request) {
       HttpResponse response = new HttpResponse();
      
        response.setHeader('Content-Type', 'application/json; charset=utf-8'); 
  //   String body = '{"client_status":"ORDER_INITIATED","client_status_id":1,"current_status":1,"task_ref_id":"T1633-20210531163928","awb_number":"775-83991250","id":152448,"pod":null,"estimated_delivery_time":"","delivery_associate_user_id":null,"booking_type":"D2D","booking_date":"2022-05-04 15:51:50","task_tracker":[{"task_id":152448,"status":"Request Initiated","status_details_id":1,"flight_code":"","city":"Mahipalpur","updated_at":"2022-05-04 15:51:50"}],"delivery_boy":"Balaji Reddy","total_weight":0,"total_pieces":0,"is_cold_chain":false,"chart_exist":false,"full_pod_url":"https://spicetag-pdf-dev.s3-ap-south-1.amazonaws.com/151136/do/1-pod_report.pdf","master_airway_bill":"https://spicetag-pdf-dev.s3-ap-south-1.amazonaws.com/master_airway_bill_pdf?task_id=151451","axb_detail":{"task_id":152448,"consignee_name":"648-B, HALPATI COLONY, BOOK N FLY, RING ROAD, OPP KINNARY CINEMA,80 FE","consignee_city":"648-B, HALPATI COLONY, BOOK N FLY, RING ROAD, OPP KINNARY CINEMA,80 FE","commodity_code":"GEN","consignee_address":"648-B, HALPATI COLONY, BOOK N FLY, RING ROAD, OPP KINNARY CINEMA,80 FE","consignee_postal_code":"110037","shipper_name":"Book N Fly","shipper_city":"Mahipalpur","charged_weight":"100","collected_date":"2021-05-31 16:42:26","delivered_date":"2021-05-31 19:04:35","e_way_bill":null,"gross_weight":"100.00","origin":"DL1","destination":"BL1"}}';        
      String body = '';
    
      if(request.getEndpoint()=='https://qa.thespicetag.com/admin/api/login'){
         body ='{"status":"success","code":200,"message":"Login Successfully","result":{"access_token":"BearereyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOlwvXC9xYS50aGVzcGljZXRhZy5jb21cL2FkbWluXC9hc","token_type":"bearer","expires_in":7200,"user_data":{"name":"B V C LOGISTICS PRIVATE LIMITED","email":"xyz@gmail.com","contact_number":"9773253883","user_address":"UNIT NO. 1102, SOLITAIR CORPORATE PARK, 167, GURU HARGOVINDJI MARG, ANDHERI (EAST), MUMBAI MAHARASHT","code":"BVCCENDO","country":"IN","city":"BOM","created_at":"2019-05-23T06:45:25.000000Z","role_id":2,"warehouse_code":"BOM","id":19350,"image_path":"","is_active":"1","organization_name":"B V C LOGISTICS PRIVATE LIMITED","customer_station":"","participation_type":"A","latitude":"","longitude":"","state":27,"postal_code":"000000","airport_code":"BOM","type":"A2A","default_password":1,"parent_id":0,"default_station":null,"validate_credit":false,"users_profile_image":null},"user_role":{"role_name":"customer","system_type":"CUSTOM_ROLE"}}}';
      }
      if(request.getEndpoint()=='https://qa.thespicetag.com/admin/api/freighter/list'){
          body='{"result":[{"id":1223,"flight_id":"2687816","departure_date":"2021-04-08","flight_no":"SG8723","registration_no":"VT-SLJ","aircraft_type":"737-800","source":"DEL","destination":"BOM","operational_status":"Operational","dep_bay_no":"D37L","arr_bay_no":"V15 N","atd":"2021-04-08 08:35:00","ata":"2021-04-08 10:40:00","etd":"2021-07-18 20:05:00","eta":"2021-07-18 20:05:00","std":"2021-07-18 20:05:00","sta":"2021-07-18 22:05:00","manufacturer":"BOEING 737","delay_code":"","delay_reason":"","dep_delay":"","is_active":1,"cms_value":"PAX","created_at":"2021-07-15T07:31:16.000000Z","updated_at":"2021-07-15T07:31:16.000000Z"}]}';
     }
      if(request.getEndpoint()=='https://qa.thespicetag.com/admin/api/create-booking'){
          body='{"status":"success","code":200,"message":"AXB Created Successfully","result":{"id":151197,"awb_number":"775-83991250","booking_type":"D2D","mappingrequired":false}}';
      }
      
      if(request.getEndpoint()=='https://qa.thespicetag.com/admin/api/requests/awbtrack?tracking_id=775-83991250&mode=BVC'){
          body ='{"client_status":"ORDER_INITIATED","client_status_id":1,"current_status":1,"task_ref_id":"T1633-20210531163928","awb_number":"775-83991250","id":152448,"pod":null,"estimated_delivery_time":"","delivery_associate_user_id":null,"booking_type":"D2D","booking_date":"2022-05-04 15:51:50","task_tracker":[{"task_id":152448,"status":"Request Initiated","status_details_id":1,"flight_code":"","city":"Mahipalpur","updated_at":"2022-05-04 15:51:50"}],"delivery_boy":"Balaji Reddy","total_weight":0,"total_pieces":0,"is_cold_chain":false,"chart_exist":false,"full_pod_url":"https://spicetag-pdf-dev.s3-ap-south-1.amazonaws.com/151136/do/1-pod_report.pdf","master_airway_bill":"https://spicetag-pdf-dev.s3-ap-south-1.amazonaws.com/master_airway_bill_pdf?task_id=151451","axb_detail":{"task_id":152448,"consignee_name":"648-B, HALPATI COLONY, BOOK N FLY, RING ROAD, OPP KINNARY CINEMA,80 FE","consignee_city":"648-B, HALPATI COLONY, BOOK N FLY, RING ROAD, OPP KINNARY CINEMA,80 FE","commodity_code":"GEN","consignee_address":"648-B, HALPATI COLONY, BOOK N FLY, RING ROAD, OPP KINNARY CINEMA,80 FE","consignee_postal_code":"110037","shipper_name":"Book N Fly","shipper_city":"Mahipalpur","charged_weight":"100","collected_date":"2021-05-31 16:42:26","delivered_date":"2021-05-31 19:04:35","e_way_bill":null,"gross_weight":"100.00","origin":"DL1","destination":"BL1"}}';
     }
      
     response.setBody(body);
      //    response.setBody('{"key": "value"}');
      response.setStatusCode(200);
      return response;
 }
   
}