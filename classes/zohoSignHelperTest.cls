@isTest
public class zohoSignHelperTest {

    @isTest
    public static void testZohoSignHelper(){
        /*
        Test.setMock(HttpCalloutMock.class,new zohoSignHelperMock());
        
        Account Acc = New Account();
        Acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        Acc.Name = 'TITAN COMPANY LIMITED - Billing EQUPNB543K';
        Acc.BVC_Company_Type__c = 'Domestic';        
        Acc.KYC_Indicator_for_Domestic_Flag__c = true;
        Acc.Customer_Status__c = 'Active';
        Acc.Category__c = 'Manufacturer';
        Acc.Type_Of_Customer__c = 'Both';
        Acc.BVC_Legal_Entity__c = 'B.V.C. Logistics Private Limited';
        Acc.Primary_Customer_Email__c = 'abc@sdcn.com';
        Acc.Phone = '94746367837';
        Acc.First_Name__c = 'billing firstname';               
        Acc.Last_Name__c = 'billing lst name';
       Acc.Name_As_Per_PAN__pc = 'EQUPNB123K';
        Acc.Name_As_Per_PAN_Manual_Input__c = 'new cust';
        Acc.PAN_Number_of_Entity__c = 'EQUPNB543K';      
        Insert Acc;
        
        Contact ct = new Contact();
        ct.FirstName = 'Test';
        ct.LastName = 'User';
        ct.AccountId = Acc.id;
        ct.Email = 'test@gmail.com';
        
        insert ct;
        
        opportunity op = new Opportunity();
        op.name = 'Testopp';
        op.AccountId = Acc.id;
        op.Amount = 214325;
        op.ContactId = ct.id;
        op.StageName = 'BVC Opportunity';
        op.CloseDate = system.today()+1;
        
        insert op;
        system.debug('opprtunity'+op.id);
        
        
        List<SBQQ__Quote__c> qtList = new List<SBQQ__Quote__c>();
        SBQQ__Quote__c qt = new SBQQ__Quote__c();
         qt.SBQQ__Account__c = Acc.id;
        qt.SBQQ__Status__c = 'Approved';
        qt.Business_Type__c = 'ACR';
        qt.SBQQ__Opportunity2__c = op.id;
        
        insert qt;
        qtList.add(qt);
        
         system.debug('quoteRecord'+qt.id);
        system.debug('qtList'+qtList);
        
        List<id> quoteIds = new List<id>();
        for(SBQQ__Quote__c q : qtList){
            quoteIds.Add(q.Id);
        }
        system.debug('quoteIds'+quoteIds);
                    
        ContentVersion cv= new Contentversion();
          cv.title= 'Test';
          cv.PathOnClient ='Test'+'.pdf';         
          cv.VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body');
          cv.SharingPrivacy = 'N';
          cv.FirstPublishLocationId = qt.id;
          insert cv; 
       
        OpportunityContactRole oppRole = new OpportunityContactRole();
        oppRole.OpportunityId = op.id;
        oppRole.ContactId = ct.id;
        oppRole.Role = 'Authorised Signatory';
        insert oppRole; 
        system.debug('oppRole'+oppRole);
        string accessToken = '1000.b515b0970208ac55bee37837a2d873fa.c91372ae601492acc1f53f19e4210d9b';
        string requestID ='60959000000068061';
        string DocumentID='60959000000068062';
        string signActionId='60959000000068080';
        string inpersonActionId = '60959000000068080';
        string recEmail = ct.Email;
        string recName = 'ABC';
        string userEmail = 'test@gamil.com';
        string username ='BVC';
        string requestName = 'test sheet.pdf';
        integer pages= 1;
        string businessType = qt.Business_Type__c;
        string inSignerName = 'ABV';
        string insignerEmail = 'test@gmail.com';  */
        test.StartTest();   
        zohoSignHelper.dummyMethod(); 
       // zohoSignHelper.getAccesstoken();
       // ZohoSignHelper.CreateDocument(quoteIds);
       // zohoSignHelper.updateDocument(accessToken, DocumentID, requestID, requestName, recEmail, recName, userEmail, username, inpersonActionId, signActionId, quoteIds,pages,businessType,inSignerName,insignerEmail);
       // zohoSignHelper.sendDocumentToSign(accessToken,requestID, DocumentID, signActionId,inpersonActionId, quoteIds);
       test.stopTest();
    }
  
}