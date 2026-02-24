@isTest
public class IndigoAWBTrackingControllerTest {

    @isTest
    public static void TestMethod1(){
           Test.setMock(HttpCalloutMock.class, new Indigo_TrackAWB_HelperMock());
        
        string awbNumber= '14153451';
        string status = 'Offloaded';
        string flightNo = '6E6145';
        string flightdate = '17/09/2025';
        
        linehaul__c l = new linehaul__c();
        l.AWB_Number__c = '14153451';
        l.Origin__c = 'HYDERABAD';
        l.Destination__c = 'AHMEDABAD';
        insert l;
        
        Hub__c h = new hub__c();
        h.Name = 'HYDERABAD';
        
        insert h;
        
        hub__c h1 = new hub__c();
        h1.Name = 'AHMEDABAD';
        
        insert h1;
        
        try{
             Test.startTest();
           IndigoAWBTrackingController.getTrackingDetails(awbNumber);
           
            IndigoAWBTrackingController.getcoverage();
             Test.StopTest();
            
        }catch(exception e){
            
        }
         
        
    }
    
     @isTest
    public static void TestMethod2(){
           Test.setMock(HttpCalloutMock.class, new Indigo_TrackAWB_HelperMock2());
        
           string awbNumber= '26469332';
        
         integration_Log__c intlg = new integration_Log__c();
                      intlg.Status_Code__c =  '201';
                      intlg.Response_JSON__c =  '{"d": "RESPONSE_START:INVALID_OR_EXPIRED_TOKEN:RESPONSE_END"}';
                      intlg.Error_Reason__c = 'Indigo track AWB API Error';
                      insert intlg;
        
        try{
             Test.startTest();
              IndigoAWBTrackingController.getTrackingDetails(awbNumber);
            IndigoAWBTrackingController.getcoverage();
             Test.StopTest();
            
        }catch(exception e){
            
        }
         
        
    }
}