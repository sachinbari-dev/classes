public class DarwinboxIntegration {
    
    public static void fetchData() {
        System.debug('In the class method');
        Darwinbox_Configuration__mdt config = getConfig();
        if(config == null) {
            System.debug('Darwinbox configuration is missing.');
            return;
        }
        
        String endpoint = config.Endpoint__c;
        String apiKey = config.API_Key__c;
        
        System.debug('for checking endpoint '+endpoint);
        System.debug('for checking apiKey'+apiKey);
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + apiKey);
        
        Http http = new Http();
        HttpResponse res = http.send(req);
        
        if(res.getStatusCode() == 200) {
            String responseData = res.getBody();
            System.debug('for checking responseData '+responseData);
            
        } else {
            System.debug('Error: ' + res.getStatusCode() + ' - ' + res.getStatus());
        }
    }
    
    private static Darwinbox_Configuration__mdt getConfig() {
        return [SELECT Id, API_Key__c, Endpoint__c FROM Darwinbox_Configuration__mdt LIMIT 1];
    }
}