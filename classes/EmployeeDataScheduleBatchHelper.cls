public class EmployeeDataScheduleBatchHelper {
    public static List<FleetX_People__c> getDarwinpeople(String Keyset,String datasetKey,String Endpoint){
            List<FleetX_People__c>  DarwinScheduleList =  new List<FleetX_People__c>(); 
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(Endpoint);
        request.setMethod('POST');
        request.setHeader('Content-type', 'application/json');
        
        
        request.setBody('{"api_key":"'+Keyset+'", "datasetKey":"'+datasetKey+'"}');
        HttpResponse response = http.send(request);
        system.debug('response@@@@'+response );
        
        
         if(response.getStatusCode() != 200) {
            System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
        } else {
            system.debug(response.getBody());
            
            EmployeeDataWrapper getFlightResp = EmployeeDataWrapper.parse(response.getBody());
             system.debug(getFlightResp);
            
            if(getFlightResp.Employee_data.size() > 0){
                for(EmployeeDataWrapper.Employee_data darwin : getFlightResp.Employee_data){
                    FleetX_People__c XPerson = new FleetX_People__c();
                    XPerson.Name=darwin.first_name;
                     XPerson.People_lastName__c=darwin.last_name;
                      XPerson.Employee_Code__c= darwin.employee_id;
                       XPerson.People_email__c= darwin.personal_email_id;
                        XPerson.People_userType__c=darwin.designation;
                    DarwinScheduleList.add(XPerson);
                }
            }
            
             }
        
Return DarwinScheduleList;        
        
    }

}