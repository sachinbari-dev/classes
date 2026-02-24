// Test Calss for  BVC_AutoGenerateQuoteLinesTriggerHelper
@isTest
public class BVC_AutoGenerateQuoteLinesHelperTest 
{
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

     
     BVCQuoteLineItem__c bvcLine = new BVCQuoteLineItem__c();
     bvcLine.Product__c =p.id;
     bvcLine.Rate_Amount__c = 3.5;
     bvcline.Minimum_Freight__c = 1500;
     bvcline.BVCQuote__c = acrQuote.Id;
     insert bvcLine;

        List<ST_ACR_Standard_Price__c> prices = new List<ST_ACR_Standard_Price__c>();
        for(Product2 prod : prodList){
            if(prod.ProductCode != 'ACR'){
                ST_ACR_Standard_Price__c acrStd = new ST_ACR_Standard_Price__c();
                acrStd.ST_Effective_End_Date__c = System.today().adddays(20);
                acrStd.ST_Effective_Start_Date__c = System.today().adddays(-20);
                acrStd.ST_Rate_Amount__c = 2.5;
                acrStd.ST_Minimum_Freight__c = 1000;
                acrStd.ST_ACR_Package_Type__c = 'Package 5 : 10L';
                //acrStd.ST_Offline_Charge__c = 500;
                acrStd.ST_Rate_UOM__c = 'Per Gram';
                acrStd.ST_Liability_Coverage__c = 0.22;
                acrStd.ST_Product__c = prod.Id;
                prices.add(acrStd);
            }  
        }
              
     insert prices;     
     
     BVCQuote__c  q = [select Id,Name,BVC_Price_Slab__c from BVCQuote__c where Id=:acrQuote.Id limit 1];
     System.debug('126 Q:'+q);
     System.debug('126 QL size:'+q.BVCQuoteLineItems__r.size());
     q.BVC_Price_Slab__c='Package 5 : 10L';
     update q;
     test.stopTest();   
 }
}