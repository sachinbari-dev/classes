@isTest
public class BVCQuoteLineTriggerHandlerTest 
{
    @isTest
    
    static void testControllerupdateBVCQuoteLineFields()
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
        acrQuote.BVC_Service__c='ValSHIP';
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
        Product2 p2 = [select Id,Name,ProductCode from Product2 where ProductCode='BVC ExhibiSHIP' limit 1];
        
        BVCQuoteLineItem__c bvcLine = new BVCQuoteLineItem__c();
        bvcLine.Product__c =p.id;
        bvcLine.Rate_Amount__c = 3.5;
        bvcline.Minimum_Freight__c = 1500;
        bvcline.BVCQuote__c = acrQuote.Id;
        insert bvcLine;
        
        BVCQuoteLineItem__c bvcLine1 = new BVCQuoteLineItem__c();
        bvcLine1.Product__c =p2.id;
        bvcLine1.Rate_Amount__c = 3.5;
        bvcLine1.Minimum_Freight__c = 1500;
        bvcLine1.BVCQuote__c = acrQuote.Id;
        bvcLine1.Product_Code__c=p2.ProductCode;
        insert bvcLine1;
        
        BVCQuote__c  q = [select Id,Name,(select Id,Name from BVCQuoteLineItems__r) from BVCQuote__c where Id=:acrQuote.Id limit 1];
        System.debug('126 Q:'+q);
        System.debug('126 QL size:'+q.BVCQuoteLineItems__r.size());
        List<BVCQuoteLineItem__c> newLines = new List<BVCQuoteLineItem__c>();
        BVCQuoteLineItem__c newLine= q.BVCQuoteLineItems__r[0];
        q.BVCQuoteLineItems__r[0].Indirect_Location__c=125;
        q.BVCQuoteLineItems__r[0].Fuel_Surcharge__c=123;
        q.BVCQuoteLineItems__r[0].Subrogation_Liability__c=123;
        q.BVCQuoteLineItems__r[0].Offline_Charge__c=123;
        q.BVCQuoteLineItems__r[0].Remote_Location__c=123;
        q.BVCQuoteLineItems__r[0].All_Risk_Liability__c=123;
        newLines.add(q.BVCQuoteLineItems__r[0]);
        
        /*
        q.BVCQuoteLineItems__r[1].Indirect_Location__c=125;
        q.BVCQuoteLineItems__r[1].Fuel_Surcharge__c=123;
        q.BVCQuoteLineItems__r[1].Subrogation_Liability__c=123;
        q.BVCQuoteLineItems__r[1].Offline_Charge__c=123;
        q.BVCQuoteLineItems__r[1].Remote_Location__c=123;
        q.BVCQuoteLineItems__r[1].All_Risk_Liability__c=123;
        newLines.add(q.BVCQuoteLineItems__r[1]);
        */
        
        //update newLines;
        
        BVCQuoteLineTriggerHandler.GetCoverage();
        BVCQuoteLineTriggerHandler.GetCoverage2();
        BVCQuoteLineTriggerHandler.GetCoverage3();
        BVCQuoteLineTriggerHandler.GetCoverage4();
        BVCQuoteLineTriggerHandler.GetCoverage5();
        BVCQuoteLineTriggerHandler.GetCoverage6();
         BVCQuoteLineTriggerHandler.GetCoverage7();
    }
}