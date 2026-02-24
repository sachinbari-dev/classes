@isTest
public class airlinePackagePDFcontrollerTest {

    @isTest
    public static void testAirlinePackagePDF(){
        
        
         secure_packaging__c sp = new secure_packaging__c();
         sp.Name = 'N023543';
         sp.Status__c = 'Consumed';
         sp.RecordTypeId =Schema.SObjectType.secure_packaging__c.getRecordTypeInfosByName().get('Secure Seal').getRecordTypeId();
         sp.Type_of_Packaging__c = 'White Seal';
          
         insert sp;
        
        
        Trunk__c tr= new Trunk__c();
          tr.Airline_Trunk__c = 'Airline trunk';
        tr.Trunk_weight__c = 45;
          tr.Left_Seal__c = sp.id;
        
        insert tr;
        
         ApexPages.currentPage().getParameters().put('id', tr.Id);
          ApexPages.StandardController sc1 = new ApexPages.StandardController(tr);
          airlinePackagePDFcontroller controller1 = new airlinePackagePDFcontroller(sc1);
        
          Trunk__c tr1= new Trunk__c();
          tr1.OSB__c = 'OSB';
          tr1.Left_Seal__c = sp.id;
        
        insert tr1;
        
        ApexPages.currentPage().getParameters().put('id', tr1.Id);
          ApexPages.StandardController sc = new ApexPages.StandardController(tr1);
          airlinePackagePDFcontroller controller = new airlinePackagePDFcontroller(sc);
        
        Trunk__c tr2= new Trunk__c();
          tr2.OST__c = 'OST';
          tr2.Left_Seal__c = sp.id;
        
        insert tr2;
        
        ApexPages.currentPage().getParameters().put('id', tr2.Id);
          ApexPages.StandardController sc2 = new ApexPages.StandardController(tr2);
          airlinePackagePDFcontroller controller2 = new airlinePackagePDFcontroller(sc2);
        
       
    }
    
}