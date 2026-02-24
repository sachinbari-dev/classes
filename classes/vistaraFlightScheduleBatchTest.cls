@isTest(SeeAllData=true)
public class vistaraFlightScheduleBatchTest {
    @isTest
    public static void testFlightScheduleBatch(){
        Test.setMock(HttpCalloutMock.class,new vistaraFlightScheduleBatchHelperMock());
      
        string origin = 'BOM';
        string endpoint = 'https://uk-uat-api-appservice.azurewebsites.net/SKMobilityWS.asmx/GetFlightListV2';
        string LoginName = 'BVCCOKDOM';
        string airlineCode = 'UK';
        
        AirLine1__c  ar = new AirLine1__c();
         ar.Airline_Name__c = 'Vistara';
        
        insert ar;
      
        Test.startTest();
        
         List<Flight_Schedule__c> response3 = vistaraFlightscheduleBatchHelper.getVistaraFlightList(origin, ar.Id, LoginName, airlineCode, endpoint);
          Database.executeBatch(new vistaraFlightScheduleBatch(),10);
        Test.stopTest();
        
    }

}