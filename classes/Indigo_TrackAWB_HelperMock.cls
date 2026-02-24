@isTest
global class Indigo_TrackAWB_HelperMock implements HttpCalloutMock {
    
   global HTTPResponse respond(HTTPRequest request) {
       HttpResponse response = new HttpResponse();
       
       response.setHeader('Content-Type', 'application/json; charset=utf-8'); 
        String body = '';
        String body1 = '';
       
        if(request.getEndpoint().endswith('SKMobilityWS.asmx/GenerateToken')){
        body = '{"d":"RESULT_START:{\\"Table\\":[{\\"TokenNumber\\":\\"A34163D8-2EE6-452A-971B-6485CC65E165\\"}]}:RESULT_END"}';
       // body1 =  JSON.(Body);
       
        }
        if(request.getEndpoint().endswith('SKMobilityWS.asmx/GetUserDetails')){
            body = '{"d":"RESPONSE_START:SUCCESS:RESPONSE_ENDRESULT_START:{\\"Table\\":[{\\"AgentCode\\":\\"BVCLBOMDOM\\",\\"ControllingLocator\\":null,\\"CreditController\\":\\"BVCLCNTRAL\\",\\"IsActive\\":true,\\"SessionID\\":\\"54b58c09-36e6-4567-8e1f-6343df06c9d7\\",\\"RetStatus\\":\\"Success\\",\\"RoleName\\":\\"Agent\\",\\"AgentName\\":\\"BVC LOGISTICS PRIVATE LIMITED\\",\\"UserType\\":\\"\\",\\"RoleType\\":\\"AGTEXEC\\",\\"AgentBalance\\":2836642.67,\\"AgentEmail\\":\\"\\",\\"AgentContact\\":\\"1111111111\\"}]}:RESULT_END"}';
        }
         if(request.getEndpoint().endswith('SKMobilityWS.asmx/GetFlightListV2')){
             body = '{"d":"RESPONSE_START:SUCCESS:RESPONSE_ENDRESULT_START:{\"Table\":[{\"ErrorCode\":0,\"ErrorDesc\":\"Get Tracking Details successful.\"}],\"Table1\":[],\"Table2\":[{\"AWBNumber\":\"312-11110046\",\"Station\":\"BOM\",\"Milestone\":\"Booked\",\"Pieces\":1,\"PiecesWeight\":\"1000.00 Kgs\",\"UOM\":\"K\",\"FlightNo\":\"6E2775 27/09/2025\",\"FlightDate\":\"26/09/2025 09:01\",\"Origin\":\"BOM\",\"Destination\":\"DEL\",\"ULDNO\":\"\",\"OrderBy\":1,\"UpdatedOn\":\"2025-09-27T00:00:00\"}],\"Table3\":[{\"SrNo\":1,\"AWBNumber\":\"312-11110046\",\"Station\":\"BOM\",\"AirportName\":\"MUMBAI\",\"Milestone1\":null,\"PiecesWeight1\":null,\"FlightNoDate1\":null,\"IconType1\":\"Normal\",\"Origin1\":null,\"Destination1\":null,\"Milestone2\":null,\"PiecesWeight2\":null,\"FlightNoDate2\":null,\"IconType2\":\"Normal\",\"Origin2\":null,\"Destination2\":null,\"Milestone3\":null,\"PiecesWeight3\":null,\"FlightNoDate3\":null,\"IconType3\":\"Normal\",\"Origin3\":null,\"Destination3\":null,\"PrevMilestone\":null,\"PrevPiecesWeight\":null,\"PrevFlightNoDate\":null,\"StationId\":1,\"Milestone4\":null,\"PiecesWeight4\":null,\"FlightNoDate4\":null,\"IconType4\":\"Normal\",\"Milestone5\":null,\"PiecesWeight5\":null,\"FlightNoDate5\":null,\"IconType5\":\"Normal\"},{\"SrNo\":2,\"AWBNumber\":\"312-11110046\",\"Station\":\"DEL\",\"AirportName\":\"DELHI\",\"Milestone1\":null,\"PiecesWeight1\":null,\"FlightNoDate1\":null,\"IconType1\":\"Normal\",\"Origin1\":null,\"Destination1\":null,\"Milestone2\":null,\"PiecesWeight2\":null,\"FlightNoDate2\":null,\"IconType2\":\"Normal\",\"Origin2\":null,\"Destination2\":null,\"Milestone3\":null,\"PiecesWeight3\":null,\"FlightNoDate3\":null,\"IconType3\":\"Normal\",\"Origin3\":null,\"Destination3\":null,\"PrevMilestone\":null,\"PrevPiecesWeight\":null,\"PrevFlightNoDate\":null,\"StationId\":null,\"Milestone4\":null,\"PiecesWeight4\":null,\"FlightNoDate4\":null,\"IconType4\":\"Normal\",\"Milestone5\":null,\"PiecesWeight5\":null,\"FlightNoDate5\":null,\"IconType5\":\"Normal\"}],\"Table4\":[],\"Table5\":[{\"MaxConCount\":0}],\"Table6\":[{\"StationCount\":2}],\"Table7\":[{\"LastActivity\":\"Booked at BOM\",\"Description\":\"1 P / 1000.00 Kgs\"}],\"Table8\":[],\"Table9\":[]}:RESULT_END"}';       
                 }
        if(request.getEndpoint().endswith('SKMobilityWS.asmx/SaveBookingRequestWY')){
            body = '{"d": "RESPONSE_START:SUCCESS:RESPONSE_ENDRESULT_START:{\\"Table6\\":[{\\"ErrorCode\\":0,\\"ErrorDesc\\":\\"AWB booked successfully and is waiting for confirmation\\",\\"AWBNumber\\":\\"11110046\\",\\"DepartureTimeMsg\\":\\"Please tender your shipment 1 hour prior to your requested departure time.\\",\\"CurrentDate\\":\\"2022-10-01T18:26:12.463\\",\\"CommodityName\\":\\"SILSILVER\\",\\"DeptTime\\":\\"01:00\\",\\"FlightRoute\\":\\",6E461,BOM,HYD,02/10/2022,02/10/2022 06:05,02/10/2022 07:30,0@\\",\\"FileUrl\\":\\"\\"}]}:RESULT_END"}';
         }
        if(request.getEndpoint().endswith('SKMobilityWS.asmx/GetTrackingInfoV2')){
            body ='{' +'"d": "RESPONSE_START:SUCCESS:RESPONSE_ENDRESULT_START:{\\\"Table\\\":[{\\\"ErrorCode\\\":0,\\\"ErrorDesc\\\":\\\"Get Tracking Details successful.\\\"}],\\\"Table1\\\":[],\\\"Table2\\\":[{\\\"AWBNumber\\\":\\\"312-11110046\\\",\\\"Station\\\":\\\"BOM\\\",\\\"Milestone\\\":\\\"Booked\\\",\\\"Pieces\\\":1,\\\"PiecesWeight\\\":\\\"1000.00 Kgs\\\",\\\"UOM\\\":\\\"K\\\",\\\"FlightNo\\\":\\\"6E2775 27/09/2025\\\",\\\"FlightDate\\\":\\\"26/09/2025 09:01\\\",\\\"Origin\\\":\\\"BOM\\\",\\\"Destination\\\":\\\"DEL\\\",\\\"ULDNO\\\":\\\"\\\",\\\"OrderBy\\\":1,\\\"UpdatedOn\\\":\\\"2025-09-27T00:00:00\\\"}],\\\"Table3\\\":[],\\\"Table4\\\":[],\\\"Table5\\\":[{\\\"MaxConCount\\\":0}],\\\"Table6\\\":[{\\\"StationCount\\\":2}],\\\"Table7\\\":[{\\\"LastActivity\\\":\\\"Booked at BOM\\\",\\\"Description\\\":\\\"1 P / 1000.00 Kgs\\\"}],\\\"Table8\\\":[],\\\"Table9\\\":[]}:RESULT_END"' +'}'; 
                }
         response.setBody(body);
        response.setStatusCode(200);
       return response;
   }
}