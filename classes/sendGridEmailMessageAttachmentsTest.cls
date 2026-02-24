@isTest
public class sendGridEmailMessageAttachmentsTest {

    @isTest
    public static void testSendGridEmailAttachment(){
        
        List<string>emails =  new List<string>{'test@gmail.com','abc@gamil.com','abd@gmail.com'};
        
        string subject = 'This is Demo Email';
        string body = 'Hi, This is email body of tetsing sendGridemailmessagetest class';
        
        List<blob> blobList = new List<blob>();
        
        String attachmentBody = 'Test attachment content file with file type pdf .this is only for testing purpose';
            blobList.add(Blob.valueOf(attachmentBody));
        List<string> attachNames=  new List<string>();
        
         String attachmentName = 'TestAttachment.text';
           attachNames.add(attachmentName);
        
         Test.setMock(HttpCalloutMock.class, new sendGridEmailMessageAttachmentsMock());
         sendGridEmailMessageAttachments.sendGridEmailMessagesAttachment(emails, subject, body, blobList, attachNames);
    }
}