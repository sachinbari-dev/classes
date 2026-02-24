@isTest
public class updateAwbHelperTest {
 @isTest
    public static void testupdateAwbHelper(){
        List<Linehaul__c> LinehaulList = new List<Linehaul__c>();
        
        Linehaul__c newLine = new Linehaul__c();
     //   newline.AirLine_Name__c = 'indigo';
         
        LinehaulList.add(newLine);
        insert LinehaulList;
    
    Test.startTest();
     updateAwbHelper.Indigo(LinehaulList);
     updateAwbHelper.Spicejet(LinehaulList);
    Test.stopTest();
    }  
}