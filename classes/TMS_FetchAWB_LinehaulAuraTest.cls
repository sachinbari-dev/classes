@isTest
public class TMS_FetchAWB_LinehaulAuraTest {
 @isTest
    public static void testTMS_FetchAWB_LinehaulAura(){
        List<Linehaul__c> LinehaulList = new List<Linehaul__c>();
        
        Linehaul__c newLine = new Linehaul__c();
        newline.origin__c = 'DEL';
        newline.Destination__c = 'HYD';
     //   newline.Flight_Date__c = 07/07/2023;
        LinehaulList.add(newLine);
        insert LinehaulList;
    
    Test.startTest();
     TMS_FetchAWB_LinehaulAura.getcreatedAWB(newline.Origin__c, newline.Destination__c, newline.Flight_Date__c);
     TMS_FetchAWB_LinehaulAura.createAWB(newline.Origin__c, newline.Destination__c, newline.Flight_Date__c);
    Test.stopTest();
    }  
}