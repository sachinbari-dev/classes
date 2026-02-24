@isTest
    global class SpiceJetTrackAwbMock implements HttpCalloutMock {
        global HTTPResponse respond(HTTPRequest req){
            try{
            if(req.getEndpoint()=='https://qa.thespicetag.com/admin/api/requests/awbtrack?tracking_id=775-83991250&mode=BVC'){
                HttpResponse res= new HttpResponse();
                res.setHeader('Content-Type','application/json');
                res.setBody('{"client_status":"ORDER_INITIATED","client_status_id":1,"current_status":1,"task_ref_id":"T1633-20210531163928","awb_number":"775-83991250","id":152448,"pod":null,"estimated_delivery_time":"","delivery_associate_user_id":null,"booking_type":"D2D","booking_date":"2022-05-04 15:51:50","task_tracker":[{"task_id":152448,"status":"Request Initiated","status_details_id":1,"flight_code":"","city":"Mahipalpur","updated_at":"2022-05-04 15:51:50"}],"delivery_boy":"Balaji Reddy","total_weight":0,"total_pieces":0,"is_cold_chain":false,"chart_exist":false,"full_pod_url":"https://spicetag-pdf-dev.s3-ap-south-1.amazonaws.com/151136/do/1-pod_report.pdf","master_airway_bill":"https://spicetag-pdf-dev.s3-ap-south-1.amazonaws.com/master_airway_bill_pdf?task_id=151451","axb_detail":{"task_id":152448,"consignee_name":"648-B, HALPATI COLONY, BOOK N FLY, RING ROAD, OPP KINNARY CINEMA,80 FE","consignee_city":"648-B, HALPATI COLONY, BOOK N FLY, RING ROAD, OPP KINNARY CINEMA,80 FE","commodity_code":"GEN","consignee_address":"648-B, HALPATI COLONY, BOOK N FLY, RING ROAD, OPP KINNARY CINEMA,80 FE","consignee_postal_code":"110037","shipper_name":"Book N Fly","shipper_city":"Mahipalpur","charged_weight":"100","collected_date":"2021-05-31 16:42:26","delivered_date":"2021-05-31 19:04:35","e_way_bill":null,"gross_weight":"100.00","origin":"DL1","destination":"BL1"}}');
                res.setStatusCode(200);
                return res;
            }
        }catch(Exception ex){
                System.debug('ERROR Message>>>'+ex.getMessage()+' Error Line Number>>> '+ex.getLineNumber());
        }
            return null;
         }
    }