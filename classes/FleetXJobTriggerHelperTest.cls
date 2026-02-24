@isTest
public class FleetXJobTriggerHelperTest 
{
    @isTest
    static void FleetXJobMockTest()
    {
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new FleetXjobMockCallout()); 
       // FleetX_Routes__c Route = new FleetX_Routes__c();
        FleetX_People__c Escorter = new FleetX_People__c();
        Escorter.Name='Escorter1';
        Escorter.People_lastName__c='Pandit1';
        Escorter.People_phoneNumber__c='9080308781';
        Escorter.People_email__c='ashok669@bvclogistics.com';
        Escorter.People_userType__c='Escorter';
        insert Escorter;
        
        FleetX_People__c gunmen = new FleetX_People__c();
        gunmen.Name='Ashok';
        gunmen.People_lastName__c='Pandit';
        gunmen.People_phoneNumber__c='9080308781';
        gunmen.People_email__c='ashok669@bvclogistics.com';
        gunmen.People_userType__c='Gunman';
        insert gunmen;
        FleetX_People__c Driver = new FleetX_People__c();
        Driver.Name='Saheb';
        Driver.People_lastName__c='Pandit';
        Driver.People_phoneNumber__c='9080308781';
        Driver.People_email__c='ashok669@bvclogistics.com';
        Driver.People_userType__c='DRIVER';
        insert Driver; 
        
        FleetX_People__c Driver1 = new FleetX_People__c();
        Driver1.Name='Saheb1';
        Driver1.People_lastName__c='Pandit1';
        Driver1.People_phoneNumber__c='9080308781';
        Driver1.People_email__c='ashok669@bvclogistics.com';
        Driver1.People_userType__c='DRIVER';
        insert Driver1;
        
        Route_List__c RL = new Route_List__c();
        RL.Name='Hyd-1';
        insert RL;
        user u = [SELECT Id, Username,Name, ProfileId FROM User 
                  where  isActive=true and Name='ArunKudwalli Test' LIMIT 1];
        System.debug('User Name :'+u.Name);
        List<FleetXPoints__c> fleetxJobPointsList = new List<FleetXPoints__c>();
        FleetXPoints__c fp = new FleetXPoints__c();
         fp.Address_Name__c=RL.Name+'-';
         fp.Route_List__c=RL.Id;
        insert fp;        
        FleetXJob__c FleetxJOB = new FleetXJob__c();
        FleetxJOB.vehicleNumber__c='TN09CV0461';
        FleetxJOB.FleetX_Driver__c=Driver.Id;
        FleetxJOB.FleetX_Gunmen__c=gunmen.Id;
        FleetxJOB.RouteName__c=RL.Id;
        FleetxJOB.FleetX_RouteName__c=RL.Id;
        FleetxJOB.scheduleDeparture__c=System.now();
        FleetxJOB.Escorter1__c=u.id;
        FleetxJOB.Escorter__c=Escorter.id;

        FleetxJOB.Loader_1__c=gunmen.Id;
        FleetxJOB.Driver_2__c=Driver.Id;
		FleetxJOB.Escorter2__c=Escorter.id;
        FleetxJOB.Loader_2__c=gunmen.Id;
        FleetxJOB.Armed_Guard_2__c=gunmen.Id;
        insert FleetxJOB;
		
        FleetXJob__c jobtoUpdate = [select Id,FleetX_Driver__c from FleetXJob__c where Id=:FleetxJOB.Id limit 1];
        jobtoUpdate.FleetX_Driver__c=Driver1.Id;
        jobtoUpdate.Job_Id__c=15936094;
        update jobtoUpdate;        
        FleetXjobCancelCallout.makeCallout(jobtoUpdate.Id);
        test.stopTest();
        
    }
}