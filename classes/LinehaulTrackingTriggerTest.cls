@isTest
public class LinehaulTrackingTriggerTest {

    @isTest
    public static void TestLienehaulTracking(){
        Linehaul__c L = new Linehaul__c();
        l.AWB_Number__c = '52474432';
        l.Select_Airline__c = 'Vistara';
        l.Gross_Weight__c = 5465;
        l.Manual__c = True;
        l.Origin__c = 'Mumbai';
        l.Destination__c ='Hyderabad';
    
        insert l;
        
        Linehaul_Tracking__c Lt = new Linehaul_Tracking__c();
         Lt.Linehaul_Name__c = l.id;
         Lt.Finalized_Linehaul_Number__c = 'FL-HYD-MUM-34';
         Lt.Airline__c = 'Vistara';
         Lt.Status__c = 'AWB Finalized';
         Lt.Linehaul_Type__c = 'Air';
         lt.Trunks_Weight_Kgs__c = 65;
         insert Lt;
        
        if(Lt.Linehaul_Name__c == L.Id){
             lt.Trunks_Weight_Kgs__c = 465;
             update lt;
            
        }

    }
}