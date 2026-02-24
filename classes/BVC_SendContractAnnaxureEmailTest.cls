@isTest
public class BVC_SendContractAnnaxureEmailTest 
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
        
        Contact cont1 = new Contact();
        cont1.AccountId=Acc.Id;
        cont1.FirstName='im';
        cont1.LastName ='Sheik';
        cont1.Email='samir.shigwan@bvclogistics.com';
        insert cont1;
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
        bvcline.Net_Unit_Price__c = 120;
        bvcline.BVCQuote__c = acrQuote.Id;
        insert bvcLine;
        

        
        BVCQuote__c  q = [select Id,Name,(select Id,Name from BVCQuoteLineItems__r) from BVCQuote__c where Id=:acrQuote.Id limit 1];
        System.debug('126 Q:'+q);
        System.debug('126 QL size:'+q.BVCQuoteLineItems__r.size());
        acrQuote.Status__c='Contract Sent';
        update acrQuote;
		BVC_Contract__c cont = [select Id,Customer_Name__c,Status__c from BVC_Contract__c limit 1];
        System.debug('73 cont :'+cont);
        if(cont!=null)
        {
            List<BVC_ACR_Consumption__c> consumptionList = new List<BVC_ACR_Consumption__c>();
            for(integer i=0;i<=5;i++)
            {
                BVC_ACR_Consumption__c cons = new BVC_ACR_Consumption__c();
                cons.BVC_Contract__c = cont.Id;
                cons.Total_Charge__c = 25000;
                cons.Account__c = cont.Customer_Name__c;
                consumptionList.add(cons);
            }   
            insert consumptionList;
            cont.Status__c='Expired';
            update cont;
            List<Account> sentemailAccounts = [SELECT AccountNumber,Name,Balance_Amount__c,Point_Of_Contact_Email__c,
                                   Annual_Contract_Balance__c,Active_Contract__c,Consumed_ACR_Amount__c,
                                   Active_Contract__r.of_Contract_Consumption__c,Active_Contract__r.Consumed_Amount__c,
                                   Adjusted_Contract_Amount__c,Contract_Start_Date__c,Contract_Amount__c,
                                   Consumed_Amount__c,Contract_End_Date__c,ST_Total_Consumable_ACR_Amount__c,
                                   (SELECT ContactId,AccountId,Contact.Email,Roles FROM AccountContactRelations WHERE Roles includes ('Finance','Invoice Recepient')),
                                   Email_Sent_at_85_Consumption__c,Email_Sent_at_90_Consumption__c,Email_Sent_at_95_Consumption__c,
                                   Email_Sent_at_98_Consumption__c,Email_Sent_at_100_Consumption__c,of_Contract_Consumption__c
                                   FROM Account 
                                   WHERE Id =:cont.Customer_Name__c];
            List<Messaging.SingleEmailMessage> mailingList = BVC_SendEmailUtility.ContractExpiryEmailSender(Label.ContractConsumptionExpiryEmailTemplateName ,sentemailAccounts,false);
        }
       
        
        test.stopTest();   
    }
}