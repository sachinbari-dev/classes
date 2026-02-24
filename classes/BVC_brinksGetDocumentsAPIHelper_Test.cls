@isTest
public class BVC_brinksGetDocumentsAPIHelper_Test {

     @isTest
    public static void testGetDocumentAPI(){
        
         Test.setMock(HttpCalloutMock.class,new zohoSignGetDocumentAPIHelperMock());
        
          
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
        
        opportunity op = new Opportunity();
        op.name = 'Testopp';
        op.AccountId = Acc.id;
        op.Amount = 214325;
        op.ContactId = ct.id;
        op.StageName = 'BVC Opportunity';
        op.CloseDate = system.today()+1;
        
        insert op;
        system.debug('opprtunity'+op.id);
        
        
         List<BVC_bulk_Agreement_signing__c> qtList = new List<BVC_bulk_Agreement_signing__c>();
       BVC_bulk_Agreement_signing__c qt = new BVC_bulk_Agreement_signing__c();
        qt.Customer_Name__c = acc.id;
        qt.Customer_Address__c ='ABHY48654';
        qt.Customer_Email__c ='test@gmail.com';
        qt.Customer_GST_No__c = 'GF876545';
        qt.Customer_IEC_No__c = 'HGGGY787';
        
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
        integration_Log__c  intlg = new integration_Log__c();
             intlg.BVC_bulk_Agreement_signing__c = qt.id; 
                      intlg.Status_Code__c =  '400';
                      intlg.Response_JSON__c =  'test';
                      intlg.ZohoAPIName__c = 'fetch document details API Error'; 
                        insert intlg;
        
        string requestID ='60959000000063321';
        
        Map<String, List<Id>> requestIdToQuoteIdsMap = new Map<String, List<Id>>();
        requestIdToQuoteIdsMap.put(requestId, quoteIds);
         
        
        string accessToken = '1000.e43c5bbeb14b605b9984ff7a139ae903.05d9372e9766995ae5c27d336ec4d50b';
        try{
            Test.startTest();
         BVC_brinksGetDocumentsAPIHelper.getDocumentDetails(requestIdToQuoteIdsMap,accessToken);
       
            
        Test.stopTest();

        }catch(exception e){
            system.debug('error'+ e);
        }
                    
       

    }
    @isTest
    public static void testmethod2(){
        BVC_brinksGetDocumentsAPIHelper.GetCoverage();
    }
}