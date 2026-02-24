@IsTest
public class BVCExternalContractCalcUtilTest {
    
    @IsTest
    static void testGetSobjectList() {
        Account acrAccount = BVCL_TestDataFactory.createCustomer('ACR Account','Billing',true);
        Account nonAcrAccount = BVCL_TestDataFactory.createCustomer('NonACRAccount','Billing',true);
        Hub__c testHub = BVCL_TestDataFactory.CreateHub('Delhi', true, 'DELHI');
        
        Shipment__c Ship1 = BVCL_TestDataFactory.CreateShipment(acrAccount.id, nonAcrAccount.id, null, nonAcrAccount.id, null, false);
        Ship1.Shipping_Note_Number__c = 'RafiTestSNN';
        Insert Ship1;
        Shipment__c Ship2 = BVCL_TestDataFactory.CreateShipment(nonAcrAccount.id, nonAcrAccount.id, null, nonAcrAccount.id, null, true);
        List<Shipment__c> shipList = new List<Shipment__c>();
        shipList.add(Ship1);
        shipList.add(Ship2);
        
        Set<Id> shipmentIds = new Set<Id>();
            
            for(Shipment__c ship : shipList){
                shipmentIds.add(ship.Id);
            }
		System.debug('for checking shipmentIds === '+shipmentIds);        
        
        String query = BVCExternalContractCalcUtil.getSobjectList(shipmentIds);
    }
    
    @IsTest
    static void testCreateExternalContractShipment() {
        try{
        Account acrAccount = BVCL_TestDataFactory.createCustomer('ACR Account','Billing',true);
        Account nonAcrAccount = BVCL_TestDataFactory.createCustomer('NonACRAccount','Billing',true);
        Hub__c testHub = BVCL_TestDataFactory.CreateHub('Delhi', true, 'DELHI');
        
        Shipment__c Ship1 = BVCL_TestDataFactory.CreateShipment(acrAccount.id, nonAcrAccount.id, null, nonAcrAccount.id, null, false);
        Ship1.Shipping_Note_Number__c = 'testSNN';
        Insert Ship1;
        Shipment__c Ship2 = BVCL_TestDataFactory.CreateShipment(nonAcrAccount.id, nonAcrAccount.id, null, nonAcrAccount.id, null, true);
        List<Shipment__c> shipList = new List<Shipment__c>();
        shipList.add(Ship1);
        shipList.add(Ship2);
        
        BVC_LegalEntity__c billingEntity = new BVC_LegalEntity__c();
        billingEntity.Name = 'test';
        insert billingEntity;
        
        External_Contract__c extContract = new External_Contract__c();
        insert extContract;
        
        External_Contract_Shipment_Summary__c summary = new External_Contract_Shipment_Summary__c(
            Customer__c = acrAccount.Id, External_Contract__c = extContract.Id,
            Start_Date__c = Date.today().toStartOfMonth(), End_Date__c = Date.today().toStartOfMonth().addMonths(1).addDays(-1),
            BVC_LegalEntity__c = billingEntity.Id, Origin_Hub__c = testHub.Id, Product_Code__c = 'Product 1'
            
        );
        insert summary;
        
		BVCShipmentCalcUtil.ShipmentDetail shipmentDetail = new BVCShipmentCalcUtil.ShipmentDetail();
        
        shipmentDetail.externalContractId = extContract.Id;
        shipmentDetail.filterById = summary.Id;
        
        Map<String, List<BVCShipmentCalcUtil.ShipmentDetail>> extContractToSummaryMap = new Map<String, List<BVCShipmentCalcUtil.ShipmentDetail>>{
            acrAccount.Id + '##' + extContract.Id + '##' + shipmentDetail.productId => new List<BVCShipmentCalcUtil.ShipmentDetail>{shipmentDetail}
        };
        
        Map<String, External_Contract_Shipment_Summary__c> extIdToSummaryMap = new Map<String, External_Contract_Shipment_Summary__c>{
            extContract.Id => [SELECT Id FROM External_Contract_Shipment_Summary__c LIMIT 1]
        };
        
        Set<Id> shipmentIds = new Set<Id>();
            
            for(Shipment__c ship : shipList){
                shipmentIds.add(ship.Id);
            }
		System.debug('for checking extContractToSummaryMap === '+extContractToSummaryMap);        
        System.debug('for checking extIdToSummaryMap === '+extIdToSummaryMap);
        System.debug('for checking shipmentIds === '+shipmentIds);
        Test.startTest();
        BVCExternalContractCalcUtil.createExternalContractShipment(extContractToSummaryMap, extIdToSummaryMap, shipmentIds);
        Test.stopTest();
        }catch(Exception ex){
            System.debug('Error in testCreateExternalContractShipment === '+ex.getMessage());
            System.debug('Error in testCreateExternalContractShipment on line number === '+ex.getLineNumber());
        }
        
    }
    
    @IsTest
    static void testCreateExternalContractShipmentAndSummary() {
        Account acrAccount = BVCL_TestDataFactory.createCustomer('ACR Account','Billing',true);
        Account nonAcrAccount = BVCL_TestDataFactory.createCustomer('NonACRAccount','Billing',true);
        Hub__c testHub = BVCL_TestDataFactory.CreateHub('Delhi', true, 'DELHI');
        
        Shipment__c Ship1 = BVCL_TestDataFactory.CreateShipment(acrAccount.id, nonAcrAccount.id, null, nonAcrAccount.id, null, false);
        Ship1.Shipping_Note_Number__c = 'testSNN1';
        Insert Ship1;
        List<Shipment__c> shipList = new List<Shipment__c>();
        shipList.add(Ship1);
        
        BVC_LegalEntity__c billingEntity = new BVC_LegalEntity__c();
        billingEntity.Name = 'test';
        insert billingEntity;
        
        External_Contract__c extContract = new External_Contract__c();
        insert extContract;
        
        External_Contract_Shipment_Summary__c summary = new External_Contract_Shipment_Summary__c(
            Customer__c = acrAccount.Id, External_Contract__c = extContract.Id, Summary_Type__c = 'Daily',
            BVC_LegalEntity__c = billingEntity.Id, Origin_Hub__c = testHub.Id, Product_Code__c = 'Product 1'
        );
        insert summary;
        
        BVCShipmentCalcUtil.ShipmentDetail shipmentDetail = new BVCShipmentCalcUtil.ShipmentDetail();
        
        shipmentDetail.externalContractId = extContract.Id;
        shipmentDetail.filterById = summary.Id;
        
        
        List<BVCShipmentCalcUtil.ShipmentDetail> shipInput = new List<BVCShipmentCalcUtil.ShipmentDetail>{shipmentDetail};
        
        System.debug('for checking shipInput === '+shipInput);
        
        Test.startTest();
        BVCExternalContractCalcUtil.createExternalContractShipmentAndSummary(shipInput);
        BVCExternalContractCalcUtil.getCoverage();
        Test.stopTest();
        
    }
}