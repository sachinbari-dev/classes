public class FleetXRouteListExternalQuable implements Queueable, Database.AllowsCallouts 
{
public void execute(QueueableContext context) {
    System.debug('Inside Queue');
    getFleetXRoutes();
}
public static void getFleetXRoutes( )
{
        System.debug('Inside FleetXRouteListExternalQuable Class');
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
            System.debug('<== Trying callout ===>');
            // Send the request and get the response
            HttpResponse response = http.send(request);
            System.debug('<== Trying callout 1===>');
            // Check if the request was successful (HTTP status 200)
            if (response.getStatusCode() == 200) {
                // Parse the response body or perform further processing as needed
                String responseBody = response.getBody();                
                System.debug('<=========== Inside start Method ========>');
                // Database.executeBatch(new FleetXRouteListExternalBatch(responseBody),200);
                Database.executeBatch(new FXRouteCalloutBatch(responseBody),200);
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