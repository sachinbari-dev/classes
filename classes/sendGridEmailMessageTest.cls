@isTest
public class sendGridEmailMessageTest {

    @isTest
    public static void TestSendGridEmailMessage(){
        
        List<string>emails =  new List<string>{'test@gmail.com','abc@gamil.com','abd@gmail.com'};
        
        string subject = 'This is Demo Email';
        string body = 'Hi, This is email body of tetsing sendGridemailmessagetest class';
        
        Test.setMock(HttpCalloutMock.class, new sendGridEmailMessageMock());
        
        sendGridEmailMessage.sendGridEmailMessages(emails, subject, body);
            
    }
}