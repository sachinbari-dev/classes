global class FinanceSnapshotBatch implements Database.Batchable<SObject> {
    
    private Date mockToday;

    public FinanceSnapshotBatch() {}
    
    public FinanceSnapshotBatch(Date mockToday) {
        this.mockToday = mockToday;
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(
            'SELECT Id, Oracle_Account_Code__c, BVC_Contract__c, BVC_Contract__r.Name, ' + 
            'BVC_Contract__r.Contract_Amount__c, BVC_Contract__r.Balance_Amount__c, ' + 
            'BVC_Contract__r.Consumed_Amount__c, BVC_Contract__r.Contract_Start_Date__c,Total_Wallet_Balance__c,Customer_Category__c, ' + 
            'ST_Pricing_Type__c,BVC_Contract__r.Business_Type__c,BVC_Contract__r.Contract_End_Date__c,BVC_Contract__r.BVCinvoice__c FROM Account '+ 
            'WHERE Id IN (\'001Il000003TMFqIAO\')' 
        );
    }
    
    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        Set<Id> accountIds = new Set<Id>();
        for (SObject obj : scope) {
            Account acc = (Account) obj;
            accountIds.add(acc.Id);
        }

        
        Map<Id, Finance_Snapshot__c> lastSnapshots = new Map<Id, Finance_Snapshot__c>();

        for (AggregateResult ar : [
            SELECT Customer__c, MAX(CreatedDate) latestDate
            FROM Finance_Snapshot__c
            WHERE Customer__c IN :accountIds
            GROUP BY Customer__c
        ]) {
            Id customerId = (Id) ar.get('Customer__c');
            DateTime latestDate = (DateTime) ar.get('latestDate');

            
            Finance_Snapshot__c latestSnapshot = [
                SELECT Id, Customer__c, BVC_Contract__c, Contract_Number__c, 
                       Contract_Amount__c, Contract_Balance__c, Contract_Consumed__c,
                       Contract_Start_Date__c, Contract_End_Date__c
                FROM Finance_Snapshot__c
                WHERE Customer__c = :customerId AND CreatedDate = :latestDate
                LIMIT 1
            ];
            lastSnapshots.put(customerId, latestSnapshot);
        }

        List<Finance_Snapshot__c> snapshots = new List<Finance_Snapshot__c>();

        for (SObject obj : scope) {
            Account customer = (Account) obj;
            Finance_Snapshot__c snapshot = new Finance_Snapshot__c();
            
            snapshot.Customer__c = customer.Id;
            snapshot.Customer_Oracle_Number__c = customer.Oracle_Account_Code__c;
            snapshot.BVC_Contract__c = customer.BVC_Contract__c;
            snapshot.Contract_Number__c = customer.BVC_Contract__r.Name;
            snapshot.Contract_Amount__c = customer.BVC_Contract__r.Contract_Amount__c;
            snapshot.Contract_Balance__c = customer.BVC_Contract__r.Balance_Amount__c;
            snapshot.Contract_Consumed__c = customer.BVC_Contract__r.Consumed_Amount__c;
            snapshot.Contract_Start_Date__c = customer.BVC_Contract__r.Contract_Start_Date__c;
            snapshot.Contract_End_Date__c = customer.BVC_Contract__r.Contract_End_Date__c;
            snapshot.BVCInvoice__c= customer.BVC_Contract__r.BVCinvoice__c;
            snapshot.Wallet_Balance__c= customer.Total_Wallet_Balance__c;
            if(customer.BVC_Contract__r.Business_Type__c=='ACR'){
                snapshot.Customer_Type__c= 'ACR'; 
            }if(customer.BVC_Contract__r.Business_Type__c=='Non ACR'){
                snapshot.Customer_Type__c= 'Non ACR'; 
            }if(customer.Customer_Category__c=='Non Contracted' && customer.ST_Pricing_Type__c=='Non ACR' && customer.BVC_Contract__c==null){
                snapshot.Customer_Type__c= 'Non ACR Non Credit'; 
            }
            
            
            
            Finance_Snapshot__c lastSnapshot = lastSnapshots.get(customer.Id);
            
            
            if (lastSnapshot != null && lastSnapshot.BVC_Contract__c != customer.BVC_Contract__c) {
                snapshot.Prev_BVC_Contract__c = lastSnapshot.BVC_Contract__c;
                snapshot.Prev_Contract_Number__c = lastSnapshot.Contract_Number__c;
                snapshot.Prev_BVC_Contract_Amount__c = lastSnapshot.Contract_Amount__c;
                snapshot.Prev_Contract_Balance__c = lastSnapshot.Contract_Balance__c;
                snapshot.Prev_Contract_Consumed__c = lastSnapshot.Contract_Consumed__c;
                snapshot.Prev_Contract_Start_Date__c = lastSnapshot.Contract_Start_Date__c;
                snapshot.Prev_Contract_End_Date__c = lastSnapshot.Contract_End_Date__c;
            }
            
            snapshots.add(snapshot);
        }
        
        if (!snapshots.isEmpty()) {
            insert snapshots;
            system.debug('Inserted records');
        }
        Date today = (mockToday != null) ? mockToday : Date.today();
        Date fromDate = Date.newInstance(today.year(), today.month(), 5).addMonths(-1);
        Date toDate = Date.newInstance(today.year(), today.month(), 4);
        
        Map<String, Id> snapshotMap = new Map<String, Id>();
        for (Finance_Snapshot__c snap : snapshots) {
            if (snap.BVC_Contract__c != null && snap.Customer__c != null && snap.Customer_Type__c == 'Non ACR') {
                snapshotMap.put(snap.BVC_Contract__c + '-' + snap.Customer__c, snap.Id);
            }
        }
        
        List<BVCInvoiceLineitem__c> lineItems = [
            SELECT Id, BVCInvoice__c, BVCInvoice__r.Id, BVCInvoice__r.Finance_Snapshot__c,
            BVCInvoice__r.Account__c, BVC_Order_Product__r.Non_ACR_Contracted_Price__r.BVC_Contract__c
            FROM BVCInvoiceLineitem__c
            WHERE BVCInvoice__r.Account__c IN :accountIds
            AND BVC_Order_Product__r.Non_ACR_Contracted_Price__r.BVC_Contract__c != null 
            AND CreatedDate >= :fromDate AND CreatedDate < :toDate AND  BVCInvoice__r.Account__r.Customer_Category__c !='Non Contracted' 
        ];
        system.debug('lineItems size===='+lineItems.size());
        Map<Id, Id> invoiceIdToSnapshotId = new Map<Id, Id>();
        
        for (BVCInvoiceLineitem__c item : lineItems) {
            Id contractId = item.BVC_Order_Product__r.Non_ACR_Contracted_Price__r.BVC_Contract__c;
            Id customerId = item.BVCInvoice__r.Account__c;
            String key = contractId + '-' + customerId;
            
            if (snapshotMap.containsKey(key)) {
                invoiceIdToSnapshotId.put(item.BVCInvoice__r.Id, snapshotMap.get(key));
            }
        }
        List<BVCInvoice__c> invoicesToUpdate = new List<BVCInvoice__c>();
        for (Id invId : invoiceIdToSnapshotId.keySet()) {
            invoicesToUpdate.add(new BVCInvoice__c(
                Id = invId,
                Finance_Snapshot__c = invoiceIdToSnapshotId.get(invId)
            ));
        }
        
        if (!invoicesToUpdate.isEmpty()) {
            update invoicesToUpdate;
        }
        List<BVCCreditNote__c  > creditNotesToUpdate = [
            SELECT Id, BVCInvoice__c
            FROM BVCCreditNote__c  
            WHERE BVCInvoice__c IN :invoiceIdToSnapshotId.keySet()
        ];
        
        for (BVCCreditNote__c   cn : creditNotesToUpdate) {
            if (invoiceIdToSnapshotId.containsKey(cn.BVCInvoice__c)) {
                cn.Finance_Snapshot__c = invoiceIdToSnapshotId.get(cn.BVCInvoice__c);
            }
        }
        
        if (!creditNotesToUpdate.isEmpty()) {
            update creditNotesToUpdate;
        }
        
    }
    
    global void finish(Database.BatchableContext BC) {
        System.debug('Finance Snapshot Batch Completed');
    }
}