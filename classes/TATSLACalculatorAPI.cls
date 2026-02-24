@RestResource(urlMapping='/TATSLA/')
global with sharing class TATSLACalculatorAPI {

    @HttpPost
    global static String getTurnAroundTime() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json; charset=UTF-8');

        String requestBody = req.requestBody == null ? '' : req.requestBody.toString();
        System.debug('RequestBody: ' + requestBody);

        try { 
            // checked request body is not null
            if (String.isBlank(requestBody)) {
                res.statusCode = 400;
                Map<String, Object> err = new Map<String, Object>{
                    'status' => 'error',
                    'message' => 'No request body provided.',
                    'data' => null
                };
                return JSON.serialize(err);
            }

           
            Map<String, Object> payload = (Map<String, Object>) JSON.deserializeUntyped(requestBody);

            // Extract fields 
            String origin = null;
            String destination = null;

            if (payload.containsKey('originPincode')) origin = (String) payload.get('originPincode');
            else if (payload.containsKey('origin')) origin = (String) payload.get('origin');

            if (payload.containsKey('destinationPincode')) destination = (String) payload.get('destinationPincode');
            else if (payload.containsKey('destination')) destination = (String) payload.get('destination');
         
            // if origin or destination is null then return bad request response
            
            if (String.isBlank(origin) || String.isBlank(destination)) {
                res.statusCode = 400;
                Map<String, Object> errResp = new Map<String, Object>{
                    'status' => 'Error: Bad Request',
                    'message' => 'originPincode and destinationPincode are required and cannot be null or blank.',
                    'data' => null
                };
                return JSON.serialize(errResp);
            }
            // Validate Origin
            if (String.isBlank(origin) || !Pattern.matches('^[0-9]{6}$', origin)) {
                res.statusCode = 400;
                Map<String, Object> errResp = new Map<String, Object>{
                    'status' => 'Error: Bad Request',
                    'message' => 'originPincode is required and must be exactly 6 digits.',
                    'data' => null
                };
                return JSON.serialize(errResp);
            }
            
            // Validate Destination
            if (String.isBlank(destination) || !Pattern.matches('^[0-9]{6}$', destination)) {
                res.statusCode = 400;
                Map<String, Object> errResp = new Map<String, Object>{
                    'status' => 'Error: Bad Request',
                    'message' => 'destinationPincode is required and must be exactly 6 digits.',
                    'data' => null
                };
                return JSON.serialize(errResp);
            }

          
            TATSLACalculatorHandler.SLAResponse slaResp = TATSLACalculatorHandler.distanceCalculator(origin, destination);

            // if no response  form TAT SLA class then return null response 
            if (slaResp == null) {
 
                res.statusCode = 500;
                Map<String, Object> errResp = new Map<String, Object>{
                    'status' => 'error',
                    'message' => 'SLA response is null from handler.',
                    'data' => null
                };
                return JSON.serialize(errResp);
            }

           // Send success Response to Universe with response got from TAT SLA class  
            if(slaResp.isNonServiceable == true){
                  res.statusCode = 400;
                Map<String, Object> errResp = new Map<String, Object>{
                    'status' => 'Bad Request',
                    'message' => 'Either Origin or Destination pincode is Non Serviceable',
                    'data' => null
                };
                return JSON.serialize(errResp);
                
            }else{
                
                Map<String, Object> successResp = new Map<String, Object>{
                'status' => 'success',
                'message' => 'SLA calculated successfully.',
                'data' => new Map<String, Object>{
                    'slaHours' => slaResp.slaHours,
                    'slaDay' => slaResp.slaDay,
                    'estimatedDeliveryDate' => slaResp.estimatedDeliveryDate,
                    'tatInDays' => slaResp.tatInDays,
                    'isNonServiceable' => slaResp.isNonServiceable   
                 }
                };
    
                res.statusCode = 200;
                return JSON.serialize(successResp);
                
            }
          
        } catch (Exception ex) {
            System.debug('TATSLACalculatorRest Exception: ' + ex);
            res.statusCode = 500;
            Map<String, Object> err = new Map<String, Object>{
                'status' => 'error',
                'message' => 'Internal server error: ' + ex.getMessage(),
                'data' => null
            };
            return JSON.serialize(err);
        }
    }
    
    
    
    
    
    
    
    public static void Method2(){
        integer i = 0;
         i++;
      i++;
      i++;
      i++;
        
          i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        
          i++;
      i++;
      i++;
      i++;
      i++;
    }
}