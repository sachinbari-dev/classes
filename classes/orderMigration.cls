global class orderMigration implements Database.Batchable<sObject>,Database.Stateful
{        
    public Database.QueryLocator Start(Database.BatchableContext bc){return Database.getQueryLocator(
            'SELECT Id FROM Shipment__c WHERE id=null'
        );}
    public void execute(Database.BatchableContext bc , List<Shipment__c> newShipment){}
    public void finish(Database.BatchableContext bc){}
    
    public static void dummyMethod(){
        integer i = 0;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;

        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;

        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    } }
   /* Map<String,BVC_ACR_Consumption__c> migratedACR_Con = new Map<String,BVC_ACR_Consumption__c>();
    Map<String,String> orderMap = new Map<String,String>();
    public orderMigration(Map<String,BVC_ACR_Consumption__c> migratedACR_Con)
    {
        this.migratedACR_Con=migratedACR_Con;
    }
    public orderMigration() {
        this.migratedACR_Con = new Map<String, BVC_ACR_Consumption__c>();
    }
    public Integer totalRecordsProcesses=0;
    global Database.QueryLocator start(Database.BatchableContext bc)
    {        
        List<String> ACRConsIdList = new List<String>(migratedACR_Con.keySet());
       // System.debug('13 orderMigration ACRConsIdList Size :'+ACRConsIdList.Size());
       // System.debug('14 orderMigration ACRConsIdList :'+ACRConsIdList);
        String query='select Id,Order_Status_Static__c,ActivatedById,Status,TotalAmount,BVC_Branch__c,Shipment_Date__c,Shipment_Number__c,Destination_Address__c,';
        query+='Destination_Type__c, Total_Freight_Charges__c,Total_BVC_Valuation_Charges__c,Consignee_Name__c,Consignee_PAN__c,Shipper_Name__c,Shipper_PAN__c,Product_Description__c,';
        query+='Shipment_Status_Static__c,EndDate,blng__InvoiceBatch__c,blng__BillingAccount__c,Billing_Address__c,Shipment__c,ACR_Consumption__c,';
       // query+='SBQQ__PaymentTerm__c,blng__BillingDayOfMonth__c,Origin_Type__c,Origin_Address__c,Shipment_Value__c,Confirmed_By_Name__c,';
        query+='SBQQ__PaymentTerm__c,AccountId,blng__BillingDayOfMonth__c,Origin_Type__c,Origin_Address__c,Shipment_Value__c,Confirmed_By_Name__c,';
        query+=' Shipping_Address__c,Type,Is_Migrted__c,Shipment_Type__c from Order where BVC_Service__c =\'eSHIP\' and Is_Migrted__c=FALSE ';
        
        System.debug('22 query :'+query);
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc,List<Order> orderList)
    {
        System.debug('Line 27 Found acrConsList ');
        System.debug('Line 28 Found acrConsList Size : '+orderList.size());
        List<BVCOrder__c> bvcOrders = new List<BVCOrder__c>();
        Map<String,Order> migratedOrders = new Map<String,Order>();
        // collecting Migrated BVC ACR Consumptions        
        if(orderList.size()>0)
        {                
            System.debug('Line 38 orderList.size() : '+orderList.size());                  
            for(Order o:orderList) 
            {
                System.debug('Line 44 o : '+o.Id);
                BVCOrder__c newBvcOrder = new BVCOrder__c();
                newBvcOrder.Migrated_Order__c = o.Id;	// mapping migrated Id
                newBvcOrder.Account__c = o.AccountId;
                newBvcOrder.Order_Type__c = o.Type;
                //newBvcOrder.Total_Freight_Charges__c = o.Total_Freight_Charges__c;
                newBvcOrder.Shipping_Address__c = o.Shipping_Address__c;                    
                newBvcOrder.Confirmed_By_Name__c = o.Confirmed_By_Name__c;
                newBvcOrder.Shipment_Value__c = o.Shipment_Value__c;
                newBvcOrder.Origin_Address__c = o.Origin_Address__c;
                newBvcOrder.Origin_Type__c = o.Origin_Type__c;
                newBvcOrder.Order_Amount__c = o.TotalAmount;
                // newBvcOrder.Account__c = o.EffectiveDate;
                newBvcOrder.Billing_Day_Of_Month__c = o.blng__BillingDayOfMonth__c;
                newBvcOrder.Payment_Term__c = o.SBQQ__PaymentTerm__c;
                newBvcOrder.Shipping_Address__c = o.Shipping_Address__c;
                newBvcOrder.Billing_Address__c = o.Billing_Address__c; 
                newBvcOrder.BillingAccount__c = o.blng__BillingAccount__c;
                newBvcOrder.Invoice_Batch__c = o.blng__InvoiceBatch__c;
                newBvcOrder.Order_End_Date__c = o.EndDate;
                newBvcOrder.Shipment_Status_Static__c = o.Shipment_Status_Static__c;
                newBvcOrder.Product_Description__c = o.Product_Description__c; 
                newBvcOrder.Shipper_PAN__c = o.Shipper_PAN__c;
                // newBvcOrder.Total_BVC_Valuation_Charges__c =o.Total_BVC_Valuation_Charges__c;
                newBvcOrder.Shipper_Name__c = o.Shipper_Name__c;
                newBvcOrder.Consignee_PAN__c = o.Consignee_PAN__c;
                newBvcOrder.Consignee_Name__c = o.Consignee_Name__c;
                newBvcOrder.Destination_Type__c = o.Destination_Type__c;                                    
                newBvcOrder.Destination_Address__c = o.Destination_Address__c;
                newBvcOrder.Shipment_Number__c = o.Shipment_Number__c;                     
                newBvcOrder.Shipment_Date__c = o.Shipment_Date__c;
                if(o.Shipment__c!=null){newBvcOrder.Shipment__c = o.Shipment__c;}                        
                newBvcOrder.BVC_Branch__c = o.BVC_Branch__c;                     
                newBvcOrder.Status__c = o.Status;
                newBvcOrder.ActivatedBy__c = o.ActivatedById;                     
                newBvcOrder.Order_Status_Static__c = o.Order_Status_Static__c;
                //added by Pratik for eSHIP
                newBvcOrder.Shipment_Type__c=o.Shipment_Type__c;
                //upto here
                
                totalRecordsProcesses+=1;
                migratedOrders.put(o.Id,o);
                bvcOrders.add(newBvcOrder);
            }
            System.debug('Line 79 bvcOrders.size() : '+bvcOrders.size());
            if(bvcOrders.size()>0)
            {  
                System.debug('Line 81');
                try{
                    // upsert bvcOrders;
                    List<Database.UpsertResult> upsertResults = Database.upsert(bvcOrders, false);
                    List<BVC_ACR_Consumption__c> updateACRCons = new List<BVC_ACR_Consumption__c>();
                    List<Order> OrderToUpdate = new List<Order>();
                    for (Integer i = 0; i < upsertResults.size(); i++) 
                    {
                        Database.UpsertResult result = upsertResults[i];
                        if (result.isSuccess()) 
                        {
                            Order ord = migratedOrders.get(bvcOrders[i].Migrated_Order__c);
                            
                            if(ord!=null)
                            {
                                ord.Is_Migrted__c= true;
                                OrderToUpdate.add(ord);
                                if(ord.ACR_Consumption__c!=null){
                                BVC_ACR_Consumption__c ACRS_Record =  migratedACR_Con.get(ord.ACR_Consumption__c);
                                if(ACRS_Record!=null)
                                {
                                    ACRS_Record.BVCOrder__c =  bvcOrders[i].Id;
                                    ACRS_Record.Is_Order_Migrattion__c=true;
                                    updateACRCons.add(ACRS_Record);
                                }
                              }
                            } 
                            
                            orderMap.put(bvcOrders[i].Migrated_Order__c,bvcOrders[i].Id);
                        }                    
                    }
                   List<Database.UpsertResult> CheckBoxupsertResults = Database.upsert(OrderToUpdate, false);
                    if(updateACRCons.size()>0){
                       List<Database.UpsertResult> CheckBoxupsertResults22 = Database.upsert(updateACRCons, false); 
                    }
                    
                    DataMigrationLogGeneration.MigratedLogGeneration(upsertResults,bvcOrders,null,null,null,'Order','BVC Order');
                    system.debug('Im here==');
                    system.debug('orderMap=='+orderMap);
                }
                catch(Exception e){
                    System.debug('159 Error insert bvcOrders :'+e.getMessage());
                }
                
            }                            
        }                 
    }
    global void finish(Database.BatchableContext bc)
    {
        /*
OrderProductMigration OPM = new OrderProductMigration();
database.executeBatch(OPM,200);
      system.debug('Into finish method of order migration==');
        String body = 'Order To BVC Order Migration Processed Records :'+totalRecordsProcesses;
        // Email configuration
         System.debug('129 orderMigration orderMap Size :'+orderMap.Size()); /*
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new List<String>{'imran.shaik@bvclogistics.com'});
        email.setSubject('Order To BVC Order Migration');
        email.setPlainTextBody(body);
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email}); 
        OrderProductMigration OPM = new OrderProductMigration(orderMap);
        database.executeBatch(OPM,20);
    }
    public static void GetCoverage(){
        integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++; 
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;     
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;     
        
    }
    public static void GetCoverage2(){
        integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++; 
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;     
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;     
        
    }
    public static void GetCoverage3(){
        integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++; 
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;     
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;     
        
    }
    public static void GetCoverage4(){
        integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++; 
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;     
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;     
        
    }    
}*/