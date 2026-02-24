@isTest
public class sendSignatureControllertest {

    @isTest
    public static void testMethod1(){
       Test.startTest();
        sendSignatureController.validateAndSendEsign('tgds');
        Test.stopTest();
    }
}