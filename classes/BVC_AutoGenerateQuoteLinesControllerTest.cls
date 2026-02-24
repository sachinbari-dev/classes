@isTest
public class BVC_AutoGenerateQuoteLinesControllerTest {

 @isTest
 static void testControllerACR1()
 {
       test.startTest();
     Hub__c newHub = new Hub__c();
     newHub.Name = 'delhi Acr';
     newHub.Branch__c = 'delhi';
     insert newHub;
     system.assertEquals('delhi Acr', newHub.Name);
     
     Account Acc = New Account();
     Acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
     Acc.Name = 'TITAN COMPANY LIMITED - Billing EQUPNB123K';
     Acc.BVC_Company_Type__c = 'Domestic';        
     Acc.KYC_Indicator_for_Domestic_Flag__c = true;
     Acc.Customer_Status__c = 'Active';
     Acc.Category__c = 'Manufacturer';
     Acc.Type_Of_Customer__c = 'Both';
     Acc.BVC_Legal_Entity__c = 'B.V.C. Logistics Private Limited';
     Acc.Primary_Customer_Email__c = 'abc@sdcn.com';
     Acc.Phone = '+919474636783';
     Acc.First_Name__c = 'billing firstname';               
     Acc.Last_Name__c = 'billing lst name';
     //      Acc.Name_As_Per_PAN__pc = 'EQUPNB123K';
     Acc.Name_As_Per_PAN_Manual_Input__c = 'new cust';
     Acc.PAN_Number_of_Entity__c = 'EQUPNB123K';  
     Acc.BVC_Virtual_Bank_Account_Number__c='ZBVC11566198';
     Insert Acc;   
     String recordTypeId = Schema.SObjectType.BVCQuote__c.getRecordTypeInfosByName().get('ACR').getRecordTypeId();
     BVCQuote__c acrQuote = new BVCQuote__c();
     acrQuote.Account__c = Acc.id;
     acrQuote.status__C = 'Draft';
     acrQuote.Business_Type__c = 'ACR';  
     acrQuote.BVC_Service__c='ValSHIP';
     // acrQuote.RecordTypeId = recordTypeId;
     insert acrQuote; 
         

     list<Product2> prodList = new list<Product2>();
       	Product2 prodBATh = new Product2(Name = 'BATH freight Charge',Family = 'BATH freight Charge',ProductCode='BVC BATH2');
        Product2 prodESHIP = new Product2(Name = 'Eship freight Charge',Family = 'Eship freight Charge',ProductCode='BVC eSHIP2');
        Product2 prodiVALSHIP = new Product2(Name = 'BVC iValSHIP',Family = 'BVC iValSHIP',ProductCode='BVC iValSHIP');
        Product2 prodiEVALSHIP = new Product2(Name = 'BVC ieSHIP',Family = 'BVC ieSHIP',ProductCode='BVC ieSHIP');
        Product2 prodExibiSHIP = new Product2(Name = 'BVC ExhibiSHIP',Family = 'BVC ExhibiSHIP',ProductCode='BVC ExhibiSHIP');
        prodList.add(prodBATh);
        prodList.add(prodESHIP);
        prodList.add(prodiVALSHIP);
        prodList.add(prodiEVALSHIP);
        prodList.add(prodExibiSHIP);
        insert prodList;

     Product2 p = [select Id,Name from Product2 where ProductCode='BVC iValSHIP' limit 1];

     
     BVCQuoteLineItem__c bvcLine = new BVCQuoteLineItem__c();
     bvcLine.Product__c =p.id;
     bvcLine.Rate_Amount__c = 3.5;
     bvcline.Minimum_Freight__c = 1500;
     bvcline.Net_Unit_Price__c = 120;
    // bvcline.BVCQuote__c = acrQuote.Id;
     // insert bvcLine;
                 
     
     BVCQuote__c  q = [select Id,Name,(select Id,Name from BVCQuoteLineItems__r) from BVCQuote__c where Id=:acrQuote.Id limit 1];
     System.debug('126 Q:'+q);
     System.debug('126 QL size:'+q.BVCQuoteLineItems__r.size());
     acrQuote.Status__c='Contract Sent';
     //update acrQuote;
     test.stopTest();   
 }

 @isTest
 static void testControllerACRwithQuoteLines()
 {
     test.startTest();
     Hub__c newHub = new Hub__c();
     newHub.Name = 'delhi Acr';
     newHub.Branch__c = 'delhi';
     insert newHub;
     system.assertEquals('delhi Acr', newHub.Name);
     
     Account Acc = New Account();
     Acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
     Acc.Name = 'TITAN COMPANY LIMITED - Billing EQUPNB123K';
     Acc.BVC_Company_Type__c = 'Domestic';        
     Acc.KYC_Indicator_for_Domestic_Flag__c = true;
     Acc.Customer_Status__c = 'Active';
     Acc.Category__c = 'Manufacturer';
     Acc.Type_Of_Customer__c = 'Both';
     Acc.BVC_Legal_Entity__c = 'B.V.C. Logistics Private Limited';
     Acc.Primary_Customer_Email__c = 'abc@sdcn.com';
     Acc.Phone = '+919474636783';
     Acc.First_Name__c = 'billing firstname';               
     Acc.Last_Name__c = 'billing lst name';
     //      Acc.Name_As_Per_PAN__pc = 'EQUPNB123K';
     Acc.Name_As_Per_PAN_Manual_Input__c = 'new cust';
     Acc.PAN_Number_of_Entity__c = 'EQUPNB123K';  
     Acc.BVC_Virtual_Bank_Account_Number__c='ZBVC11566198';
     Insert Acc;   
     
     
     BVCQuote__c exbQuote = new BVCQuote__c();
     exbQuote.Account__c = Acc.id;
     exbQuote.status__C = 'Contract Signed';
     exbQuote.Business_Type__c = 'ACR';
     exbQuote.BVC_Service__c='ValSHIP';
     insert exbQuote;
     
     BVC_Base_Quote_Settings1__c bvcqs1 = new BVC_Base_Quote_Settings1__c();
     bvcqs1.Quote_Business_Type__c='ACR';
     bvcqs1.Base_QuoteId__c=exbQuote.Id;
     bvcqs1.Name ='Exhibition'; 
     
     list<Product2> prodList = new list<Product2>();
     Product2 prodBATh = new Product2(Name = 'BATH freight Charge',Family = 'BATH freight Charge',ProductCode='BVC BATH2');
     Product2 prodESHIP = new Product2(Name = 'Eship freight Charge',Family = 'Eship freight Charge',ProductCode='BVC eSHIP2');
     Product2 prodiVALSHIP = new Product2(Name = 'BVC iValSHIP',Family = 'BVC iValSHIP',ProductCode='BVC iValSHIP');
     Product2 prodiEVALSHIP = new Product2(Name = 'BVC ieSHIP',Family = 'BVC ieSHIP',ProductCode='BVC ieSHIP');
     Product2 prodExibiSHIP = new Product2(Name = 'BVC ExhibiSHIP',Family = 'BVC ExhibiSHIP',ProductCode='BVC ExhibiSHIP');
     prodList.add(prodBATh);
     prodList.add(prodESHIP);
     prodList.add(prodiVALSHIP);
     prodList.add(prodiEVALSHIP);
     prodList.add(prodExibiSHIP);
     insert prodList;
     
     Product2 p = [select Id,Name from Product2 where ProductCode='BVC iValSHIP' limit 1];
     
     
     BVCQuoteLineItem__c bvcLine = new BVCQuoteLineItem__c();
     bvcLine.Product__c =p.id;
     bvcLine.Rate_Amount__c = 3.5;
     bvcline.Minimum_Freight__c = 1500;
     bvcline.BVCQuote__c = exbQuote.Id;
     insert bvcLine;
     
     
     test.stopTest();
 }
    
 @isTest
 static void testControllerNoQuotes()
 {
     test.startTest();
     Hub__c newHub = new Hub__c();
     newHub.Name = 'delhi Acr';
     newHub.Branch__c = 'delhi';
     insert newHub;
     system.assertEquals('delhi Acr', newHub.Name);
     
     Account Acc = New Account();
     Acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
     Acc.Name = 'TITAN COMPANY LIMITED - Billing EQUPNB123K';
     Acc.BVC_Company_Type__c = 'Domestic';        
     Acc.KYC_Indicator_for_Domestic_Flag__c = true;
     Acc.Customer_Status__c = 'Active';
     Acc.Category__c = 'Manufacturer';
     Acc.Type_Of_Customer__c = 'Both';
     Acc.BVC_Legal_Entity__c = 'B.V.C. Logistics Private Limited';
     Acc.Primary_Customer_Email__c = 'abc@sdcn.com';
     Acc.Phone = '+919474636783';
     Acc.First_Name__c = 'billing firstname';               
     Acc.Last_Name__c = 'billing lst name';
     //      Acc.Name_As_Per_PAN__pc = 'EQUPNB123K';
     Acc.Name_As_Per_PAN_Manual_Input__c = 'new cust';
     Acc.PAN_Number_of_Entity__c = 'EQUPNB123K';  
     Acc.BVC_Virtual_Bank_Account_Number__c='ZBVC11566198';
     Insert Acc;    
     BVC_AutoGenerateQuoteLinesController.checkExistingQuote(Acc.Id,'ACR','ValSHIP',''); 
     test.stopTest();
 }
    
 @isTest
 static void testControllerNonACRandExbhition()
 {
       
     test.startTest();
     Hub__c newHub = new Hub__c();
     newHub.Name = 'delhi Acr';
     newHub.Branch__c = 'delhi';
     insert newHub;
     system.assertEquals('delhi Acr', newHub.Name);
     
     Account Acc = New Account();
     Acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
     Acc.Name = 'TITAN COMPANY LIMITED - Billing EQUPNB123K';
     Acc.BVC_Company_Type__c = 'Domestic';        
     Acc.KYC_Indicator_for_Domestic_Flag__c = true;
     Acc.Customer_Status__c = 'Active';
     Acc.Category__c = 'Manufacturer';
     Acc.Type_Of_Customer__c = 'Both';
     Acc.BVC_Legal_Entity__c = 'B.V.C. Logistics Private Limited';
     Acc.Primary_Customer_Email__c = 'abc@sdcn.com';
     Acc.Phone = '+919474636783';
     Acc.First_Name__c = 'billing firstname';               
     Acc.Last_Name__c = 'billing lst name';
     //      Acc.Name_As_Per_PAN__pc = 'EQUPNB123K';
     Acc.Name_As_Per_PAN_Manual_Input__c = 'new cust';
     Acc.PAN_Number_of_Entity__c = 'EQUPNB123K';  
     Acc.BVC_Virtual_Bank_Account_Number__c='ZBVC11566198';
     Insert Acc;   
     
     BVCQuote__c nonACRQuote = new BVCQuote__c();
     nonACRQuote.Account__c = Acc.id;
     nonACRQuote.status__C = 'Draft';
     nonACRQuote.Business_Type__c = 'Non ACR';
     nonACRQuote.BVC_Service__c='ValSHIP';
     nonACRQuote.Tariff_Plan__c='Standard';
     insert nonACRQuote;

     BVCQuote__c exbQuote = new BVCQuote__c();
     exbQuote.Account__c = Acc.id;
     exbQuote.status__C = 'Draft';
     exbQuote.Business_Type__c = 'ACR';
     exbQuote.BVC_Service__c='ValSHIP';
     insert exbQuote;
     
     BVC_Base_Quote_Settings1__c bvcqs1 = new BVC_Base_Quote_Settings1__c();
     bvcqs1.Quote_Business_Type__c='Exhibition';
     bvcqs1.Base_QuoteId__c=exbQuote.Id;
     bvcqs1.Name ='Exhibition'; 
     
     insert bvcqs1; 

     BVC_Base_Quote_Settings1__c bvcqs = new BVC_Base_Quote_Settings1__c();
     bvcqs.Quote_Business_Type__c='Non ACR';
     bvcqs.Base_QuoteId__c=nonACRQuote.Id;
     bvcqs.Name ='Non ACR';
     insert bvcqs;     
     
     

     list<Product2> prodList = new list<Product2>();
       	Product2 prodBATh = new Product2(Name = 'BATH freight Charge',Family = 'BATH freight Charge',ProductCode='BVC BATH2');
        Product2 prodESHIP = new Product2(Name = 'Eship freight Charge',Family = 'Eship freight Charge',ProductCode='BVC eSHIP2');
        Product2 prodiVALSHIP = new Product2(Name = 'BVC iValSHIP',Family = 'BVC iValSHIP',ProductCode='BVC iValSHIP');
        Product2 prodiEVALSHIP = new Product2(Name = 'BVC ieSHIP',Family = 'BVC ieSHIP',ProductCode='BVC ieSHIP');
        Product2 prodExibiSHIP = new Product2(Name = 'BVC ExhibiSHIP',Family = 'BVC ExhibiSHIP',ProductCode='BVC ExhibiSHIP');
        prodList.add(prodBATh);
        prodList.add(prodESHIP);
        prodList.add(prodiVALSHIP);
        prodList.add(prodiEVALSHIP);
        prodList.add(prodExibiSHIP);
        insert prodList;

     Product2 p = [select Id,Name from Product2 where ProductCode='BVC iValSHIP' limit 1];

     
     BVCQuoteLineItem__c bvcLine = new BVCQuoteLineItem__c();
     bvcLine.Product__c =p.id;
     bvcLine.Rate_Amount__c = 3.5;
     bvcline.Minimum_Freight__c = 1500;
     bvcline.BVCQuote__c = nonACRQuote.Id;
     insert bvcLine;
     
     
         
     Id DecisionMaker = UserInfo.getUserId(); 
     Id AuthorizedSignatory = UserInfo.getUserId(); 
     Id Evaluator;
     String priceSlab='Package 5 : 10L';

        List<ST_ACR_Standard_Price__c> prices = new List<ST_ACR_Standard_Price__c>();
        for(Product2 prod : prodList){
            if(prod.ProductCode != 'ACR'){
                ST_ACR_Standard_Price__c acrStd = new ST_ACR_Standard_Price__c();
                acrStd.ST_Effective_End_Date__c = System.today().adddays(20);
                acrStd.ST_Effective_Start_Date__c = System.today().adddays(-20);
                acrStd.ST_Rate_Amount__c = 2.5;
                acrStd.ST_Minimum_Freight__c = 1000;
                acrStd.ST_ACR_Package_Type__c = 'New Package 5 : 10L';
                acrStd.ST_Offline_Charge__c = 500;
                acrStd.ST_Rate_UOM__c = 'Per Gram';
                acrStd.ST_Liability_Coverage__c = 0.22;
                acrStd.ST_Product__c = prod.Id;
                prices.add(acrStd);
            }  
        }
     insert prices;
     BVCQuote__c  q = [select Id,Name,(select Id,Name from BVCQuoteLineItems__r) from BVCQuote__c where Id=:nonACRQuote.Id limit 1];
     System.debug('126 Q:'+q);
     System.debug('126 QL size:'+q.BVCQuoteLineItems__r.size());
     BVCQuote__c  q1 = [select Id,Name from BVCQuote__c where Id=:nonACRQuote.Id limit 1];
     q1.BVC_Price_Slab__c='New Package 5 : 10L';
     q1.BVC_Service__c = 'ValSHIP'; 
     update q1;
     BVC_Base_Quote_Settings1__c baseQuoteSetting = new BVC_Base_Quote_Settings1__c();
baseQuoteSetting.Quote_Business_Type__c = 'Non ACR';
baseQuoteSetting.BVC_Service__c = 'ValSHIP';
baseQuoteSetting.Base_QuoteId__c = q.Id;
baseQuoteSetting.Name = 'Test Base Quote Setting';
insert baseQuoteSetting;
     //BVC_AutoGenerateQuoteLinesController.cloneBVC_Quotes( Acc.Id, 'Non ACR',newHub.Id,'ValSHIP',System.Today(),true,null,null,null,null,null,null,0.0,null,null,null,null,System.Today(),System.Today(),null,true);
     BVC_AutoGenerateQuoteLinesController.checkExistingQuote(Acc.Id,'Non ACR','ValSHIP','');
          
    
   // BVC_AutoGenerateQuoteLinesController.cloneBVC_Quotes( Acc.Id, 'Non ACR',newHub.Id,'ValSHIP',System.Today(),true,null,null,null,null,null,null,0.0,null,null,null,null,System.Today(),System.Today(),null,true);
      nonACRQuote.Status__c='Contract Signed';
      update nonACRQuote;
     test.stopTest();
 }
 @isTest
 static void testControllerACR()
 {     
     test.startTest();
     Hub__c newHub = new Hub__c();
     newHub.Name = 'delhi Acr';
     newHub.Branch__c = 'delhi';
     insert newHub;
     system.assertEquals('delhi Acr', newHub.Name);
     
     Account Acc = New Account();
     Acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
     Acc.Name = 'TITAN COMPANY LIMITED - Billing EQUPNB123K';
     Acc.BVC_Company_Type__c = 'Domestic';        
     Acc.KYC_Indicator_for_Domestic_Flag__c = true;
     Acc.Customer_Status__c = 'Active';
     Acc.Category__c = 'Manufacturer';
     Acc.Type_Of_Customer__c = 'Both';
     Acc.BVC_Legal_Entity__c = 'B.V.C. Logistics Private Limited';
     Acc.Primary_Customer_Email__c = 'abc@sdcn.com';
     Acc.Phone = '+919474636783';
     Acc.First_Name__c = 'billing firstname';               
     Acc.Last_Name__c = 'billing lst name';
     //      Acc.Name_As_Per_PAN__pc = 'EQUPNB123K';
     Acc.Name_As_Per_PAN_Manual_Input__c = 'new cust';
     Acc.PAN_Number_of_Entity__c = 'EQUPNB123K';  
     Acc.BVC_Virtual_Bank_Account_Number__c='ZBVC11566198';
     Insert Acc;     
       
     
     BVCQuote__c acrQuote = new BVCQuote__c();
     acrQuote.Account__c = Acc.id;
     acrQuote.status__C = 'Draft';
     acrQuote.Business_Type__c = 'ACR';  
     acrQuote.BVC_Service__c='eSHIP';
     acrQuote.Tariff_Plan__c='Custom';
     acrQuote.Package_Amount__c='1000000';
     insert acrQuote;
     list<Product2> prodList = new list<Product2>();
       	Product2 prodBATh = new Product2(Name = 'BATH freight Charge',Family = 'BATH freight Charge',ProductCode='BVC BATH2');
        Product2 prodESHIP = new Product2(Name = 'Eship freight Charge',Family = 'Eship freight Charge',ProductCode='BVC eSHIP2');
        Product2 prodiVALSHIP = new Product2(Name = 'BVC iValSHIP',Family = 'BVC iValSHIP',ProductCode='BVC iValSHIP');
        Product2 prodiEVALSHIP = new Product2(Name = 'BVC ieSHIP',Family = 'BVC ieSHIP',ProductCode='BVC ieSHIP');
        Product2 prodExibiSHIP = new Product2(Name = 'BVC ExhibiSHIP',Family = 'BVC ExhibiSHIP',ProductCode='BVC ExhibiSHIP');
        prodList.add(prodBATh);
        prodList.add(prodESHIP);
        prodList.add(prodiVALSHIP);
        prodList.add(prodiEVALSHIP);
        prodList.add(prodExibiSHIP);
        insert prodList;

        List<ST_ACR_Standard_Price__c> prices = new List<ST_ACR_Standard_Price__c>();
        for(Product2 prod : prodList){
            if(prod.ProductCode != 'ACR'){
                ST_ACR_Standard_Price__c acrStd = new ST_ACR_Standard_Price__c();
                acrStd.ST_Effective_End_Date__c = System.today().adddays(20);
                acrStd.ST_Effective_Start_Date__c = System.today().adddays(-20);
                acrStd.ST_Rate_Amount__c = 2.5;
                acrStd.ST_Minimum_Freight__c = 1000;
                acrStd.ST_ACR_Package_Type__c = 'New Package 5 : 10L';
                acrStd.ST_Offline_Charge__c = 500;
                acrStd.ST_Rate_UOM__c = 'Per Gram';
                acrStd.ST_Liability_Coverage__c = 0.22;
                acrStd.ST_Product__c = prod.Id;
                prices.add(acrStd);
            }  
        }
              
     insert prices;
     String eshipstand3TypeID = Schema.SObjectType.eSHIP_Standard_Pricing__c.getRecordTypeInfosByName().get('Legacy eSHIP Pricing').getRecordTypeId();
	 eSHIP_Standard_Pricing__c eshipstand3= new eSHIP_Standard_Pricing__c(Gross_Weight_Unit_for_Additional_Weight__c=600,  
                                                                          Slab_Criteria__c='Invoice Value INR',
                                                                          RecordTypeId=eshipstand3TypeID,
                                                                          Weight_Covered_Gms__c=700,
                                                                          Weight_Charges__c=900, 
                                                                          Logistice_Charges__c=2, 
                                                                          Liability_Charges__c=1, 
                                                                          Business_Type__c='Non ACR',
                                                                          Lower_Bound__c=31,Upper_Bound__c=100,
                                                                          Shipment_Type__c='Intracity',
                                                                          Package_Amount__c='1000000');
     insert eshipstand3;
     
     Id DecisionMaker = UserInfo.getUserId(); 
     Id AuthorizedSignatory = UserInfo.getUserId(); 
     Id Evaluator=UserInfo.getUserId();
     String priceSlab='New Package 5 : 10L';
     
     BVCQuote__c bvcQ = [SELECT Id,BVC_Price_Slab__c FROM BVCQuote__c WHERE Id=:acrQuote.Id limit 1];
     bvcQ.BVC_Price_Slab__c ='New Package 5 : 10L';
     update bvcQ;


     BVC_Base_Quote_Settings1__c bvcqs = new BVC_Base_Quote_Settings1__c();
     bvcqs.Quote_Business_Type__c='Non ACR';
     bvcqs.Base_QuoteId__c=bvcQ.Id;
     bvcqs.Name ='Non ACR';
     bvcqs.BVC_Service__c = 'ValSHIP';
     insert bvcqs;      
     
     BVC_AutoGenerateQuoteLinesController.cloneBVC_Quotes( Acc.Id, 'Non ACR',newHub.Id,'ValSHIP',
                                                          System.Today(),true,null,'New Package 5 : 10L',null,null,null,null,0.0,
                                                          null,null,null,null,System.Today(),System.Today(),null,true);
     
     
     test.stopTest();
 }
}