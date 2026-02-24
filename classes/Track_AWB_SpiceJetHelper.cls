public class Track_AWB_SpiceJetHelper {

    public static List<Linehaul_Tracking__c> trackAWBspicejet(List<Linehaul__c> awbList,Map<String,String> awbStatusMap){
         String status = '';
       
        List<Linehaul_Tracking__c> insertLinehaulTrack	= new List<Linehaul_Tracking__c>();
        
      //get Airline_API__mdt  custom metadata where DeveloperName  is Spice_Jet_Track_AWB
            Airline_API__mdt[] spiceJetAirlineTrack = [SELECT Endpoint__c FROM Airline_API__mdt WHERE DeveloperName = 'Spice_Jet_Track_AWB'];
      //create variables to store metadata values
            String endpointtrack = spiceJetAirlineTrack[0].Endpoint__c;
        //    String body = '';
            String mode = 'BVC';
    // send http GET request to the endpoint containing  AWB_Number__c from linehaul record         
            for(Linehaul__c awblinehaul : awbList){
                Http http = new Http();
            Http httptrack = new Http();
        HttpRequest requesttrack = new HttpRequest();
   string body = 'https://qa.thespicetag.com/admin/api/requests/awbtrack?tracking_id='+awblinehaul.AWB_Number__c+'&mode='+mode;
        requesttrack.setEndpoint('body');
        requesttrack.setMethod('GET');
        system.debug('Body of Track AWB=== '+body);
       
            //    string jsonresponse= '{"client_status":"ORDER_INITIATED","client_status_id":1,"current_status":1,"task_ref_id":"T1633-20210531163928","awb_number":"775-83991250","id":152448,"pod":null,"estimated_delivery_time":"","delivery_associate_user_id":null,"booking_type":"D2D","booking_date":"2022-05-04 15:51:50","task_tracker":[{"task_id":152448,"status":"Request Initiated","status_details_id":1,"flight_code":"","city":"Mahipalpur","updated_at":"2022-05-04 15:51:50"}],"delivery_boy":"Balaji Reddy","total_weight":0,"total_pieces":0,"is_cold_chain":false,"chart_exist":false,"full_pod_url":"https://spicetag-pdf-dev.s3-ap-south-1.amazonaws.com/151136/do/1-pod_report.pdf","master_airway_bill":"https://spicetag-pdf-dev.s3-ap-south-1.amazonaws.com/master_airway_bill_pdf?task_id=151451","axb_detail":{"task_id":152448,"consignee_name":"648-B, HALPATI COLONY, BOOK N FLY, RING ROAD, OPP KINNARY CINEMA,80 FE","consignee_city":"648-B, HALPATI COLONY, BOOK N FLY, RING ROAD, OPP KINNARY CINEMA,80 FE","commodity_code":"GEN","consignee_address":"648-B, HALPATI COLONY, BOOK N FLY, RING ROAD, OPP KINNARY CINEMA,80 FE","consignee_postal_code":"110037","shipper_name":"Book N Fly","shipper_city":"Mahipalpur","charged_weight":"100","collected_date":"2021-05-31 16:42:26","delivered_date":"2021-05-31 19:04:35","e_way_bill":null,"gross_weight":"100.00","origin":"DL1","destination":"BL1"}}';
                
        HttpResponse responsetrack= http.send(requesttrack);
                system.debug('responsetrack...'+ responsetrack);
                system.debug('response body...'+ responsetrack.getBody());
            if(responsetrack.getStatusCode() != 200){
               System.debug('The status code returned was not expected: ' + responsetrack.getStatusCode() + ' ' + responsetrack.getStatus());

            }
            else{
        
        // deserialize response stored in  responsetrack  variable and store that deserialized data in trackwrapper  variable of wrapper class      
                SpicejetTrackAWBwrapper trackwrapper =  SpicejetTrackAWBwrapper.parse(responsetrack.getBody());
                   system.debug('trackwrapper==='+trackwrapper);
                   system.debug('trackwrapper11111==='+trackwrapper.Task_tracker);
                  for(SpicejetTrackAWBwrapper.cls_task_tracker getStatus :  trackwrapper.Task_tracker){
        // create Linehaul_Tracking__c record from the repsonse 
                    Linehaul_Tracking__c lineTrackrecord = new Linehaul_Tracking__c();
                    
                    if(awbStatusMap.size() > 0 && awbStatusMap.containsKey(getStatus.status)){
                    lineTrackrecord.Status__c = awbStatusMap.get(getStatus.status);
                    }
                   
                    lineTrackrecord.Status_Id__c = string.valueOf(getStatus.status_details_id);
               //     lineTrackrecord.Airport_Code__c = getStatus.airport_code;
             		lineTrackrecord.Flight_Detail__c = getStatus.flight_code;
        	   //  	 lineTrackrecord.Event_Datetime__c	=	DateTime.valueOf(string.valueof(getStatus.event_date_time));
                //    lineTrackrecord.Weight__c = getStatus.weight;
                    system.debug('Linehaul record found'+awblinehaul.Id);
                  	lineTrackrecord.Linehaul_Name__c = awblinehaul.Id;
                    insertLinehaulTrack.add(lineTrackrecord);
                }
            }
        }
     
        return insertLinehaulTrack;
    }
}