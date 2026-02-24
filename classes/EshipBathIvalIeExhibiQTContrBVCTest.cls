@isTest
public class EshipBathIvalIeExhibiQTContrBVCTest {
@testSetup static void testDataSetup()
{
        String Uid = UserInfo.getUserId();
        Hub__c hub = new  Hub__c(Name='Test',Branch__c='MUMBAI',Sales_person__c=Uid);
        insert hub;
        List<Hub__c> BVCbranch = [select id,Name from Hub__c where Sales_person__c=:Uid];
        system.debug('hub'+BVCbranch);
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        update standardPricebook;
        Pricebook2 BVCPricebook = new Pricebook2(name='BVC INR Price Book',IsActive = true);
       	insert BVCPricebook;

        list<Product2> prodList = new list<Product2>();
       	Product2 prodBATh = new Product2(Name = 'BVC BATH',Family = 'BVC BATH',ProductCode='BVC BATH');
        Product2 prodESHIP = new Product2(Name = 'BVC eSHIP',Family = 'BVC eSHIP',ProductCode='BVC eSHIP');
        Product2 prodiVALSHIP = new Product2(Name = 'BVC iValSHIP',Family = 'BVC iValSHIP',ProductCode='BVC iValSHIP');
        Product2 prodieSHIP = new Product2(Name = 'BVC ieSHIP',Family = 'BVC ieSHIP',ProductCode='BVC ieSHIP');
        Product2 prodExibiSHIP = new Product2(Name = 'BVC ExhibiSHIP',Family = 'BVC ExhibiSHIP',ProductCode='BVC ExhibiSHIP');
        Product2 prodMarketSHIP = new Product2(Name = 'MarketSHIP',Family = 'BVCMarketSHIP',ProductCode='BVCMarketSHIP');
        prodList.add(prodBATh);
        prodList.add(prodESHIP);
        prodList.add(prodiVALSHIP);
        prodList.add(prodieSHIP);
        prodList.add(prodExibiSHIP);
        prodList.add(prodMarketSHIP);
        insert prodList;
        list<PricebookEntry> PBentry = new list<PricebookEntry>();
        PricebookEntry standardPrice1 = new PricebookEntry(Pricebook2Id = standardPricebook.id, Product2Id = prodBATh.Id,UnitPrice = 0, IsActive = true);
        PricebookEntry standardPrice2 = new PricebookEntry(Pricebook2Id = standardPricebook.id, Product2Id = prodESHIP.Id,UnitPrice = 0, IsActive = true);
        PricebookEntry standardPrice3 = new PricebookEntry(Pricebook2Id = standardPricebook.id, Product2Id = prodiVALSHIP.Id,UnitPrice = 0, IsActive = true);
        PricebookEntry standardPrice4 = new PricebookEntry(Pricebook2Id = standardPricebook.id, Product2Id = prodieSHIP.Id,UnitPrice = 0, IsActive = true);
        PricebookEntry standardPrice5 = new PricebookEntry(Pricebook2Id = standardPricebook.id, Product2Id = prodExibiSHIP.Id,UnitPrice = 0, IsActive = true);
         PricebookEntry standardPrice6 = new PricebookEntry(Pricebook2Id = standardPricebook.id, Product2Id = prodMarketSHIP.Id,UnitPrice = 0, IsActive = true);
        PricebookEntry BVCPrice1 = new PricebookEntry(Pricebook2Id = BVCPricebook.id, Product2Id = prodBATh.Id,UnitPrice = 0, IsActive = true);
        PricebookEntry BVCPrice2 = new PricebookEntry(Pricebook2Id = BVCPricebook.id, Product2Id = prodESHIP.Id,UnitPrice = 0, IsActive = true);
        PricebookEntry BVCPrice3 = new PricebookEntry(Pricebook2Id = BVCPricebook.id, Product2Id = prodiVALSHIP.Id,UnitPrice = 0, IsActive = true);
        PricebookEntry BVCPrice4 = new PricebookEntry(Pricebook2Id = BVCPricebook.id, Product2Id = prodieSHIP.Id,UnitPrice = 0, IsActive = true);
        PricebookEntry BVCPrice5 = new PricebookEntry(Pricebook2Id = BVCPricebook.id, Product2Id = prodExibiSHIP.Id,UnitPrice = 0, IsActive = true);
        PricebookEntry BVCPrice6 = new PricebookEntry(Pricebook2Id = BVCPricebook.id, Product2Id = prodMarketSHIP.Id,UnitPrice = 0, IsActive = true);
        PBentry.add(standardPrice1);
        PBentry.add(standardPrice2);
        PBentry.add(standardPrice3);
        PBentry.add(standardPrice4);
        PBentry.add(standardPrice5);
         PBentry.add(standardPrice6);
        PBentry.add(BVCPrice1);
        PBentry.add(BVCPrice2);
        PBentry.add(BVCPrice3);
        PBentry.add(BVCPrice4);
        PBentry.add(BVCPrice5);
        PBentry.add(BVCPrice6);
        insert PBentry;
        Account acc= new Account();
        acc.Name='Test';
        acc.Last_Name__c='Test';
        acc.RecordTypeId='0125g0000002XavAAE';
        acc.PAN_Number_of_Entity__c='546gtyhu78';
        acc.Primary_Customer_Email__c='test11@gmail.com';
        insert acc;
         
         Account acc1= new Account();
        acc1.Name='Test1';
        acc1.Last_Name__c='Test1';
        acc1.RecordTypeId='0125g0000002XavAAE';
        acc1.PAN_Number_of_Entity__c='546gtyhu78';
        acc1.Primary_Customer_Email__c='test11@gmail.com';
        insert acc1;
        
          Contact cc=new Contact();
        cc.FirstName='Test';
        cc.LastName='Test';
        cc.Title='Customer';
        cc.MobilePhone='77209373737';
        cc.AccountId=acc.id;
        //cc.RecordTypeId='0125g0000002Xb4AAE';
        Insert cc;
    }
@isTest
public static void CreateQuoteTest()
{
        test.startTest();
		Account acc=[SELECT ID FROM Account LIMIT 1];
        Account acc1=[SELECT ID FROM Account where Last_Name__c='Test1' LIMIT 1];
        Product2 prodBATh=[SELECT ID FROM Product2 WHERE Name='BVC BATH'];

        //Insert Oppourtunity ACR Standard
        List<Opportunity> opp1 = new List<Opportunity>();
        Opportunity opp=new Opportunity();
        opp.BVC_Product__c =prodBATh.id;
        opp.Name = 'test1';
        opp.AccountId = acc.Id;
        opp.CloseDate = System.today();
        opp.StageName = 'Inbound Lead';
        opp.Business_Type__c='ACR';
        opp.Tariff_Plan__c='Standard';
        opp.Package_Amount__c='50000';
        insert opp;
        test.stopTest();
    }
}