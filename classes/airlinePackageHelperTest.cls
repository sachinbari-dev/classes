@isTest
public class airlinePackageHelperTest {

    @isTest
    public static void TestAirlinePackage(){
        
         secure_packaging__c sp = new secure_packaging__c();
         sp.Name = 'N023543';
         sp.Status__c = 'Consumed';
         sp.RecordTypeId =Schema.SObjectType.secure_packaging__c.getRecordTypeInfosByName().get('Secure Seal').getRecordTypeId();
         sp.Type_of_Packaging__c = 'White Seal';
          
         insert sp;
        
        Linehaul_tracking__c lt= new Linehaul_tracking__c();
        lt.Airline__c  ='Indigo';
        lt.AWB_Number__c = '343221';
        lt.Origin__c = 'Mumbai';
        lt.Destination__c = 'Ahmedabad';
        
        insert lt;
     
        Trunk__c tr= new Trunk__c();
          tr.Airline_Trunk__c = 'Airline trunk';
          tr.Trunk_weight__c = 45;
          tr.Left_Seal__c = sp.id;
          tr.Linehaul_Tracking__c = lt.id;
        
        insert tr;
        
        List<id> AirId = new List<id>();
        airId.add(tr.id);
        
        airlinePackageHelper.airlinePackageUpdate(airId);
    }
}