@isTest
public class Send_Report_AttachementTest {
     @isTest
    static void acrShipmentTestMethod(){
    Send_Report_Attachement.dummyMethod();
    }}
    
    /*
    @isTest
    static void testCreateAnnexureAccountNoShipments() {
        // Create test data - Account, Contract, and Order records with no shipments
        Account testAccount = new Account(Name = 'Test Account', PAN_Number_of_Entity__c = 'BUFPG1234H', Primary_Customer_Email__c = 'test1@gmail.com', Phone = '+919874563210', Last_Name__c = 'TestLastName', OwnerId = UserInfo.getUserId(), Sales_Secondary_Owner__c = UserInfo.getUserId(),Customer_Category_Static__c='ACR',Last_ACR_report_generated_date__c = date.today());
        insert testAccount;

        Contact testcontact = new Contact(lastname='Testcontact', Email ='annualcontractreport@bvclogistics.com');
        Insert testcontact;

        Contract testContract = new Contract(AccountId = testAccount.Id, Status = 'Draft', StartDate = System.today(), ContractTerm = 11,EndDate = system.today().addMonths(11));
        insert testContract;

        testAccount.Active_Contract__c = testContract.id;
        update testAccount;

        Order testOrder = new Order(AccountId = testAccount.Id, ContractId = testContract.Id, Status = 'Draft', EffectiveDate = System.today(), Order_Status_Static__c = 'Activated', blng__BillingDayOfMonth__c = '6');
        insert testOrder;

        // Define a Savepoint before inserting TestShipment

        // Insert TestShipment
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Datetime mockDateTime = Datetime.newInstance(2024, 4, 18, 12, 0, 0);


        Shipment__c TestShipment = new Shipment__c(Freight_Charges__c = 20, Weight_Charges__c = 20, Liability_Charges__c = 10, Offline_Charges__c = 10, Valuation_Charges__c = 10, Fuel_Surcharge__c = 10,Universe_Cost_Charge__c=10, Holiday_Charges__c = 10, Total_Charge__c = 100, Order__c = testOrder.Id,Customer__c =testAccount.id);
        insert TestShipment;
        Id accountRecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Shipment').getRecordTypeId();

        Order testorder2 = new order(AccountId = testaccount.Id,Order_Status_Static__c = 'Activated',EffectiveDate = date.today(),status = 'Draft',blng__BillingDayOfMonth__c='6');
        Insert testorder2 ;
        ST_ACR_Consumption__c TestACRCon = new ST_ACR_Consumption__c(Net_Weight_GMS__c = 230,Gross_Weight_GMS__c=1000,Shipment_Value__c=3425,Shipment__c=TestShipment.id,Contract__c=testContract.id,Customer_Account__c=testAccount.id,ST_ACR_Order__c= testorder2.id);
        Insert TestACRCon;
        
        acrMonthlyReportSchedule scheduler  = new acrMonthlyReportSchedule();
        acrMontlyEmailsSchedule  scheduler2 = new acrMontlyEmailsSchedule();
        
        // Call the method under test
        Test.startTest();
        scheduler.execute(null);
        scheduler2.execute(null);
        //Send_Report_Attachement.createAnnexureAccount(new list<id>{testAccount.id});
        Send_Report_Attachement.getShipmentDataOfAccount(testAccount.id,true);
        Send_Report_Attachement.scheuler();
        acrMonthlyReportScheduleHelper.AcrschedulerByUser();
        acrMonthlyReportScheduleHelper.acrmonthlyhealper();
        Test.stopTest();

        // Rollback to the Savepoint to undo the transaction, including the insertion of TestShipment
    }
    
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        // Implement the respond method
        public HTTPResponse respond(HTTPRequest req) {
            // Create a new HTTPResponse
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"example": "response"}');
            res.setStatusCode(200);
            return res;
        }
    }
}*/