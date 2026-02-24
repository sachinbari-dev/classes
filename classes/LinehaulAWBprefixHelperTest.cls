@isTest
public class LinehaulAWBprefixHelperTest {

    @TestSetup
    public static void testSetup(){
        
        linehaul__c l = new linehaul__c();
        l.AWB_Number__c = '11234532';
        l.Origin__c = 'HYDERABAD';
        l.Flight_Number__c = '6E3566';
        l.Destination__c = 'AHMEDABAD';
        l.Select_Airline__c = 'indigo';
        insert l;
        
    }
    
   @isTest
    public static void testMethod1(){
        
        List<Linehaul__c> linehaulList = new List<Linehaul__c>();
        
        Linehaul__c l =[select id,Select_Airline__c from linehaul__c LIMIT 1];
        
        linehaulList.add(l);
        
        test.startTest();
        LinehaulAWBprefixHelper.updateAWBPrefix(linehaulList);
        Test.stopTest();
    }
}