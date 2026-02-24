@isTest
public class BVC_BrinksZohoSignHelper_Test {

    
      @isTest
    public static void testZohoSignHelper(){
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
  //      Acc.Name_As_Per_PAN__pc = 'EQUPNB123K';
        Acc.Name_As_Per_PAN_Manual_Input__c = 'new cust';
        Acc.PAN_Number_of_Entity__c = 'EQUPNB543K';      
        Insert Acc;
        
        Contact ct = new Contact();
        ct.FirstName = 'Test';
        ct.LastName = 'User';
        ct.AccountId = Acc.id;
        ct.Email = 'test@gmail.com';
        
        insert ct;
        

        List<BVC_bulk_Agreement_signing__c> qtList = new List<BVC_bulk_Agreement_signing__c>();
        BVC_bulk_Agreement_signing__c qt = new BVC_bulk_Agreement_signing__c();
         qt.customer_name__c = Acc.id;
        qt.status__C = 'Draft';
        qt.Customer_Email__c = 'test@gmail.com';
        

        insert qt;
        qtList.add(qt);
        
         system.debug('quoteRecord'+qt.id);
        system.debug('qtList'+qtList);
        
        List<id> quoteIds = new List<id>();
        for(BVC_bulk_Agreement_signing__c q : qtList){
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
        string businessType = ' ';
        string inSignerName = 'ABV';
        string insignerEmail = 'test@gmail.com';
        string bvcservice = 'eSHIP';
        
        Zoho_Access_Token__c tokenSetting = new Zoho_Access_Token__c(
            Name = 'Default', // Required Name field for custom settings
            Access_Token__c = '1000.e43c5bbeb14b605b9984ff7a139ae903.05d9372e9766995ae5c27d336ec4d50b'
        );
        upsert tokenSetting;
        
        test.StartTest();   
       
        BVC_BrinksZohoSignHelper.CreateDocument(quoteIds);
        BVC_BrinksZohoSignHelper.updateDocument(accessToken, DocumentID, requestID, requestName, recEmail, recName, userEmail, username, inpersonActionId, signActionId, quoteIds,pages,businessType,inSignerName,insignerEmail,bvcservice);
        BVC_BrinksZohoSignHelper.sendDocumentToSign(accessToken,requestID, DocumentID, signActionId,inpersonActionId, quoteIds);
        BVC_zohoSignSchedulerHelper.accesTokenGenerator();
        BVC_BrinksZohoSignHelper.getBrinksImageFields(signActionId, DocumentID, 400, 500, 70, 30, 5);
       
       test.stopTest();
    }
}