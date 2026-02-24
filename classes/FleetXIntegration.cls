public class FleetXIntegration {
    
  public class FleetXJobRequest {
        public String jobName;
        public String startDateTime;
        public List<FleetXPeople> jobUsers;
        public String vehicleNumber;
        public List<FleetXPoints> points;
    }

    public class FleetXPeople {
        public String phoneNumber;
        public String label;
        public String userId;
        
    }

    public class FleetXPoints {
        public String address;
        public Decimal latitude;
        public Decimal longitude;
    }

    public static void createFleetXJob(List<FleetXJob__c> newFleetXJobs) {
        List<FleetXJobRequest> requests = new List<FleetXJobRequest>();

        for (FleetXJob__c job : newFleetXJobs) {
            FleetXJobRequest request = new FleetXJobRequest();
            request.jobName = job.jobName__c;
            request.startDateTime = String.valueOf(job.startDateTime__c);
            request.vehicleNumber = job.Vehicle_Number__c;

            request.jobUsers = new List<FleetXPeople>();
            request.points = new List<FleetXPoints>();

           
          //for (FleetXPeople__c junction : [SELECT FleetXPeople__r.FleetXPeopleID__c FROM FleetXPeople__c WHERE FleetXJob__c = :job.Id]) {
   // FleetXPeople jobUser = new FleetXPeople();
   // jobUser.phoneNumber = junction.FleetXPeople__r.Phone_Number__c;
    //jobUser.label = junction.FleetXPeople__r.Label__c;
   // jobUser.userId = junction.FleetXPeople__r.FleetXPeopleID__c;
  //  request.jobUsers.add(jobUser);
//}
            //for (FleetXPoints point : job.FleetXPoints__r) {
               // FleetXPoints pt = new FleetXPoints();
               // pt.address = point.Address__c;
               //pt.latitude = point.Latitude__c;
               // pt.longitude = point.Longitude__c;
              //  request.points.add(pt);
           // }

            requests.add(request);
        }

        
        HttpRequest req = new HttpRequest();
        req.setEndpoint('ENDPOINT');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer FLEETX_API_KEY');

        for (FleetXJobRequest r : requests) {
            req.setBody(JSON.serialize(r));
            Http http = new Http();
            HttpResponse res = http.send(req);
           
        }
    }
}