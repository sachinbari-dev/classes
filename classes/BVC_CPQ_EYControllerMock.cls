@isTest
global class BVC_CPQ_EYControllerMock implements HttpCalloutMock {
 
     global HTTPResponse respond (HTTPrequest request){
         HTTPResponse response = new HTTPResponse();
          response.setHeader('Content-Type','application/json; charset=utf-8');
        string body = '';
         
        if(request.getEndpoint().endswith('api/BVCGSTEngine')){
            body = '{"billingDate":"2024-08-13T00:00:00","billingDocumentNumber":"33TI111687","processingDate":"2024-08-13T12:28:07.0331725+05:30","registrationStatus":"Yes","posTable":"POS_Matrix","posColumn":"State of Bill to Party Location","posCity":"Coimbatore","posState":"Tamilnadu","posStateCode":"33","lospTable":"POS_Matrix","lospColumn":"State of Bill to Party Location","lospCity":"Chennai","lospState":"Tamilnadu","lospStateCode":"33","supplyType":"TAX","irnNumber":"e53d5b7035bbc42a86cfad2fc43ed7fa23c3b79068a4cfe51f8b3e2e7ac27db1","signedQRCode":"eyJhbGciOiJSUzI1NiIsImtpZCI6IkI4RDYzRUNCNThFQTVFNkY0QUFDM0Q1MjQ1NDNCMjI0NjY2OUIwRjgiLCJ4NXQiOiJ1TlkteTFqcVhtOUtyRDFTUlVPeUpHWnBzUGciLCJ0eXAiOiJKV1QifQ.eyJkYXRhIjoie1wiU2VsbGVyR3N0aW5cIjpcIjMzQUFBQ0IyMzUwSDFaOVwiLFwiQnV5ZXJHc3RpblwiOlwiMzNBSEhQQjY2OTlRMVpNXCIsXCJEb2NOb1wiOlwiMzNUSTExMTY4N1wiLFwiRG9jVHlwXCI6XCJJTlZcIixcIkRvY0R0XCI6XCIxMy8wOC8yMDI0XCIsXCJUb3RJbnZWYWxcIjo0MTk2MC44LFwiSXRlbUNudFwiOjEsXCJNYWluSHNuQ29kZVwiOlwiOTk2NTMxXCIsXCJJcm5cIjpcImU1M2Q1YjcwMzViYmM0MmE4NmNmYWQyZmM0M2VkN2ZhMjNjM2I3OTA2OGE0Y2ZlNTFmOGIzZTJlN2FjMjdkYjFcIixcIklybkR0XCI6XCIyMDI0LTA4LTEzIDEyOjI4OjAwXCJ9IiwiaXNzIjoiTklDIn0.U9LJmVgI-MCdE3_VRPeNSy3U7V5mHlrNT40etV-esxXp3J5fpy6LjXSyUFxiD9dPXVA3rWCaDQ5_lvP2o5uD3QlRSilpB3Nl_etKTwqMOFC7GaCPxJeICHBdoDOKsY666uZVrqHPSDlGW0flA0erwwuSvsKO5QpJS_MNAm_qSXNElyRnKg2_gluGSVroaSMMzitDMYZLEe5DWfKM-dcL7ck2A6biNi3PS8bas7tsEAPdTTSvZ8JJVa3Pxb1vL51QYdLgYfRi4qyftnRuHFjXyWU_8WQgWc-gAtclZAp7gyzeNjelThmRPuS0i0IoQ-P53onZTw1KZdb93ihXxbf-tQ","ackNumber":"152418906676304","ackDateTime":"2024-08-13 12:28:00","taxEngineErrorCode":null,"taxEngineErrorMessage":null,"digiGSTErrorCode":null,"digiGSTErrorMessage":null,"lineItems":[{"itemNumber":"1","tax":0,"totalItemValue":41960.8,"materialDescription":"FREIGHT CHARGES","natureOfService":"FREIGHT CHARGES","sacApplicable":"996531","taxApplicablePercentage":0.18,"taxCategory":"CGST/SGST","taxCalculated":6400.8,"taxCalculatedINR":6400.8,"igstPercentage":0,"cgstPercentage":0.09,"sgstPercentage":0.09,"igst":0,"cgst":3200.4,"sgst":3200.4,"igsT_INR":0,"cgsT_INR":3200.4,"sgsT_INR":3200.4}]}';
        }
         
        response.setBody(body);
        response.setStatusCode(200);
       return response;
     }
}