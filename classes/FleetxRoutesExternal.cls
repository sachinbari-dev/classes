// @RestResource(urlMapping='/api/v1/routes/*')
global class FleetxRoutesExternal 
{   
    // @future(callout=true)
    global void getFleetXRoutes() {               
        API_Integration_Credential__mdt FleetXRoute = API_Integration_Credential__mdt.getInstance('Fleetx_Route');
        String endpointUrl = FleetXRoute.Server_URL__c;
        Integration_Auth_List__mdt AccToken = Integration_Auth_List__mdt.getInstance('FleetxRoute');
        String acToken = AccToken.auth_token__c;        
        // Create an HTTP request
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpointUrl);
        request.setMethod('GET');
        request.setHeader('Authorization',acToken);
        // Create a new HTTP object to send the request
        Http http = new Http();
        try {
            // Send the request and get the response
            HttpResponse response = http.send(request);
            
            // Check if the request was successful (HTTP status 200)
            if (response.getStatusCode() == 200) {
                // Parse the response body or perform further processing as needed
                String responseBody = response.getBody();
                String modifiedString = responseBody.replace('group','groups');
                System.debug('Original Json :'+responseBody);
                System.debug('modifiedString Json :'+modifiedString);
                Integer strLength = responseBody.length(); 
                System.debug('strLength :'+strLength);
                String starting = responseBody.substring(0, 500);
                System.debug('starting :'+starting);
                String ending1 = responseBody.substring(strLength-200, strLength);
                System.debug('ending1 :'+ending1);                
                System.debug('<=========== Inside start Method ========>');
                Database.executeBatch(new FleetxRoutesExternalBatch(responseBody));
            } else {
                // Handle the error response if needed
                System.debug('HTTP Error: ' + response.getStatusCode() + ' ' + response.getStatus());
               // return null;
            }
        } catch (Exception e) {
            // Handle exceptions
            System.debug('Exception: ' + e.getMessage());
          //  return null;
        } 
    }    
}