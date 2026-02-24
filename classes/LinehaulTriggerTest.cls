@isTest
public class LinehaulTriggerTest {

    @isTest
    public static void testMethod1(){
        
           Hub__c h = new hub__c();
        h.Hub_Email_ID__c = 'Test@gmail.com';
        
        h.Name = 'HYDERABAD';
        
        insert h;
        
        hub__c h1 = new hub__c();
         h1.Hub_Email_ID__c = 'Test@gmail.com';
        h1.Name = 'AHMEDABAD';
        
        insert h1;
        
        linehaul__c l = new linehaul__c();
        l.AWB_Number__c = '11234532';
        l.Origin__c = 'HYDERABAD';
        l.Flight_Number__c = '6E3566';
        l.Destination__c = 'AHMEDABAD';
        
        insert l;
        
        linehaul__c line = [select id,AWB_Tracking_Status__c from linehaul__c where id=:l.id];
        l.AWB_Tracking_Status__c = 'Offloaded';
        
        update l;
        
//         List<String> toEmails = new List<String>{'test@example.com'};
    }
}