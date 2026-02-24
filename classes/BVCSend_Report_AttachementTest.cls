@isTest
public class BVCSend_Report_AttachementTest {



    @isTest
    static void testCreateAnnexureAccountNoShipments() {
        // Create test data - Account, Contract, and Order records with no shipments
        Account testAccount = new Account(Name = 'Test Account', PAN_Number_of_Entity__c = 'BUFPG1234H', Primary_Customer_Email__c = 'test1@gmail.com', Phone = '+919874563210', Last_Name__c = 'TestLastName', OwnerId = UserInfo.getUserId(), Sales_Secondary_Owner__c = UserInfo.getUserId(),Customer_Category_Static__c='ACR',Last_ACR_report_generated_date__c = date.today());
        insert testAccount;

        Contact testcontact = new Contact(lastname='Testcontact', Email ='annualcontractreport@bvclogistics.com',accountId=testAccount.Id);
        Insert testcontact;

        BVC_Contract__c testContract = new BVC_Contract__c(Customer_Name__c = testAccount.Id, Status__c = 'Draft', Contract_Start_Date__c = System.today(), Contract_Term_months__c = 11,Contract_End_Date__c = system.today().addMonths(11));
        insert testContract;

        testAccount.BVC_Contract__c = testContract.id;
        update testAccount;

        BVCOrder__c testOrder = new BVCOrder__c(Account__c = testAccount.Id, Contract_Number__c = testContract.Id, Status__c = 'Draft',  Order_Status_Static__c = 'Activated');
        insert testOrder;

        // Define a Savepoint before inserting TestShipment

        // Insert TestShipment
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Datetime mockDateTime = Datetime.newInstance(2024, 4, 18, 12, 0, 0);


        Shipment__c TestShipment = new Shipment__c(Freight_Charges__c = 20, Weight_Charges__c = 20, Liability_Charges__c = 10, Offline_Charges__c = 10, Valuation_Charges__c = 10, Fuel_Surcharge__c = 10,Universe_Cost_Charge__c=10, Holiday_Charges__c = 10, Total_Charge__c = 100, BVCOrder__c = testOrder.Id,Customer__c =testAccount.id,Shipment_Date__c=system.today(),Product_Code__c='VAL-MM-25');
        insert TestShipment;
        Id accountRecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Shipment').getRecordTypeId();

        BVCOrder__c testorder2 = new BVCOrder__c(Account__c = testaccount.Id,Order_Status_Static__c = 'Activated',status__c = 'Draft');
        Insert testorder2 ;
        BVC_ACR_Consumption__c TestACRCon = new BVC_ACR_Consumption__c(Net_Weight_GMS__c = 230,Gross_Weight_GMS__c=1000,Shipment_Value__c=3425,Shipment__c=TestShipment.id,BVC_Contract__c=testContract.id,Account__c=testAccount.id,BVCOrder__c= testorder2.id);
        Insert TestACRCon;
        
        BVCacrMonthlyReportSchedule scheduler  = new BVCacrMonthlyReportSchedule();
        BVCacrMontlyEmailsSchedule  scheduler2 = new BVCacrMontlyEmailsSchedule();
        
        // Call the method under test
        Test.startTest();
        scheduler.execute(null);
        scheduler2.execute(null);
        //Send_Report_Attachement.createAnnexureAccount(new list<id>{testAccount.id});
        BVCSend_Report_Attachement.getShipmentDataOfAccount(testAccount.id,true);
        BVCSend_Report_Attachement.scheuler();
        BVCacrMonthlyReportScheduleHelper.AcrschedulerByUser();
        BVCacrMonthlyReportScheduleHelper.acrmonthlyhealper();
     
       
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
}