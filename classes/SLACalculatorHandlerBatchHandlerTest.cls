/**
* Test class for SLACalculatorHandlerBatchHandler
*/
@isTest(SeeAllData=true)
public class SLACalculatorHandlerBatchHandlerTest {
    @isTest
    static void testCallbatchHelper() 
    {		
       List<Pickup__c> pickups = [ SELECT Id, Name FROM Pickup__c WHERE Id IN (SELECT Pickup__c FROM Shipment__c) limit 1]; 
        List<String> pickupIdList = new List<String>();
        if(pickups.size()>0)
        {
            for(Pickup__c P: pickups)
            {
               pickupIdList.add(P.Id); 
            }
			 if(pickupIdList.size()>0)           
             {
                  SLACalculatorHandlerBatchHandler.callbatchHelper(pickupIdList);
             }
        }
    }    
}