@isTest
public class VistaraTrackAWBCallClassTest {

     @isTest
    public static void testTrackBatch(){

        Test.setMock(HttpCalloutMock.class, new vistaraTrackAWBHelperMock()); 
          
        Test.startTest();
        VistaraTrackAWBCallClass.callBatch();
        Test.stopTest();
    }
}