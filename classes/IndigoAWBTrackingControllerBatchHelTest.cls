@isTest
public class IndigoAWBTrackingControllerBatchHelTest {

     @isTest
    public static void TestMethod1(){
           Test.setMock(HttpCalloutMock.class, new Indigo_TrackAWB_HelperMock());
        
        string awbNumber= '11234532';
        string status = 'Offloaded';
        string flightNo = '6E6145';
        string flightdate = '17/09/2025';
        string token = 'A34163D8-2EE6-452A-971B-6485CC65E165';
        string sessionId = '54b58c09-36e6-4567-8e1f-6343df06c9d7';
        
        
        Hub__c h = new hub__c();
        h.Hub_Email_ID__c = 'Test@gmail.com';
        
        h.Name = 'HYDERABAD';
        
        insert h;
        
        hub__c h1 = new hub__c();
         h1.Hub_Email_ID__c = 'Test@gmail.com';
        h1.Name = 'AHMEDABAD';
        
        insert h1;
        
        List<linehaul__c>  lList = new List<linehaul__c>();
        
        linehaul__c l = new linehaul__c();
        l.AWB_Number__c = '11234532';
        l.Origin__c = 'HYDERABAD';
        l.Flight_Number__c = '6E3566';
        l.Destination__c = 'AHMEDABAD';
        l.Select_Airline__c = 'Indigo';
        insert l;
        lList.add(l);
        
        
     
             Test.startTest();
             IndigoAWBTrackingControllerBatchHelper.getTrackingDetails(l.AWB_Number__c, token,sessionId);
            
          //  IndigoAWBTrackingControllerBatchHelper.getTrackingDetails(l.AWB_Number__c, token,sessionId);
            IndigoAWBTrackingControllerBatchHelper.sendEmailfOffloaded(lList);
             Test.StopTest();
      
         
        
    }
    @isTest
    public static void testMethod2(){
       Test.setMock(HttpCalloutMock.class, new Indigo_TrackAWB_HelperMock());

        List<linehaul__c>  lList = new List<linehaul__c>();
        
        linehaul__c l = new linehaul__c();
        l.AWB_Number__c = '11234532';
        l.Origin__c = 'HYDERABAD';
        l.Flight_Number__c = '6E3566';
        l.Destination__c = 'AHMEDABAD';
        l.Select_Airline__c = 'Indigo';
        insert l;
     
       
        IndigoAWBTrackingControllerBatch  bc = new IndigoAWBTrackingControllerBatch();
           id jbid =  database.executebatch(bc,5);

    }
}