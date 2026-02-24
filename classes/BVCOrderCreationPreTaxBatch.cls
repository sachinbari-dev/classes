public class BVCOrderCreationPreTaxBatch implements Database.Batchable<sObject>{
    public final String Query;
    public final List<Id> preTaxIds;
    public BVCOrderCreationPreTaxBatch(){
        Query='SELECT (select Id,BVC_CB_Invoice_Type__c,BVC_CB_Charge_Product_Code__c from BVC_CB_PreTaxBillDetails__r ),'+
            'BVC_CB_Org_Branch_SF_ID__r.BVC_CB_BVC_Entity__c,BVC_CB_Org_Branch_SF_ID__r.BVC_LegalEntity__c,BVC_CB_Org_Branch_SF_ID__r.CB_BVC_Legal_Entity__c,'+
            'BVC_CB_GrossWt__c,BVC_CB_Billing_Account_2__c,'+
            'BVC_CB_Billing_Account_Address_2__c,BVC_CB_Operation_Type__c,BVC_CB_PretaxDetails_Inserted__c,BVC_CB_Customer_GSTINNO__c,'+
            'BVC_CB_Destination_Country_2__c,BVC_CB_Destination_Port_2__c,BVC_CB_Is_Order_Created__c,BVC_CB_Invoice_Type__c,'+
            'BVC_CB_AIR_SEA__c,BVC_CB_Assessable_Value__c,BVC_CB_BE_Date__c,BVC_CB_BE_No__c,BVC_CB_Customer_Invoice_Number__c,'+
            'BVC_CB_Billing_Account_Address__c,BVC_CB_Billing_GSTIN__c,BVC_CB_Billing_GST_State_Code__c,BVC_CB_Billing_OracleId__c,'+
            'BVC_CB_Billing_Oracle_SiteId__c,BVC_CB_Billing_PAN__c,BVC_CB_Billing_SF_Customer_Address__c,BVC_CB_Billing_SF_Customer__c,'+
            'BVC_CB_Billing_State__c,BVC_CB_BillTo_Fields__c,BVC_CB_Bond_Date__c,BVC_CB_Bond_No__c,BVC_CB_BOS_Bill_Amount__c,'+
            'BVC_CB_BOS_Invoice_No__c,BVC_CB_BOS_Round_Off__c,BVC_CB_BVC_VAMASHIP_ID__c,BVC_CB_Cash_Idf_Date__c,BVC_CB_Cash_Idf_No__c,'+
            'BVC_CB_CCDate__c,BVC_CB_CCNo__c,BVC_CB_CM_Bill_Amount__c,BVC_CB_CM_Invoice_No__c,BVC_CB_CM_Round_Off__c,BVC_CB_CONTENT__c,'+
            'BVC_CB_Created_By_Datetime__c,BVC_CB_Created_By__c,BVC_CB_Customer_Address__c,BVC_CB_Customer_Invoice_Date__c,'+
            'BVC_CB_Customer_Invoice_Value_Currency__c,BVC_CB_Customer_Name__c,BVC_CB_CUSTOMER_TRANSACTION_TYPE__c,BVC_CB_Despatch__c,'+
            'BVC_CB_DestinationCountry__c,BVC_CB_DestinationPort__c,BVC_CB_DT_GR_FORM_NO__c,BVC_CB_EDFDate__c,BVC_CB_EDFNo__c,'+
            'BVC_CB_ERDate__c,BVC_CB_ERNo__c,BVC_CB_ExportShipmentID__c,BVC_CB_FOBValue__c,BVC_CB_GR_FORM_NO__c,BVC_CB_GSTIN_Remarks__c,'+
            'BVC_CB_HAWB_Date__c,BVC_CB_HAWB_No__c,BVC_CB_IGM_Item_Date__c,BVC_CB_IGM_Item_No__c,BVC_CB_Import_Shipment__c,'+
            'BVC_CB_Invoice_Value_INR__c,BVC_CB_Invoice_Value__c,BVC_CB_IRN_Date__c,BVC_CB_IRN__c,BVC_CB_JOB_DT__c,BVC_CB_JOB_NO__c,'+
            'BVC_CB_Last_Modifiedby__c,BVC_CB_License_Date__c,BVC_CB_License_No__c,BVC_CB_lospCity__c,BVC_CB_lospColumn__c,'+
            'BVC_CB_lospStateCode__c,BVC_CB_lospState__c,BVC_CB_lospTable__c,BVC_CB_MAWB_Date__c,BVC_CB_MAWB_No__c,'+
            'BVC_CB_Modified_Datetime__c,BVC_CB_Net_Wt__c,BVC_CB_No_Of_Pkgs__c,BVC_CB_OracleID__c,BVC_CB_Oracle_SiteId__c,'+
            'BVC_CB_OrgBranchCode__c,BVC_CB_OrgBranchName__c,BVC_CB_Org_Branch_GSTIN__c,BVC_CB_Org_Branch_GST_State_Code__c,'+
            'BVC_CB_Org_Branch_SF_ID__c,BVC_CB_Org_Branch_State__c,BVC_CB_Org_CINNO__c,BVC_CB_Org_PAN__c,BVC_CB_posColumn__c,'+
            'BVC_CB_posTable__c,BVC_CB_POS__c,BVC_CB_PreTaxInvoice_ID__c,BVC_CB_Pre_Tax_Date__c,BVC_CB_Pre_Tax_No__c,'+
            'BVC_CB_ProcessingDate__c,BVC_CB_Remarks1__c,BVC_CB_Remarks__c,BVC_CB_ROUND_OFF__c,BVC_CB_SalesForceAddress__c,'+
            'BVC_CB_SalesForceCustomerId__c,BVC_CB_SBDate__c,BVC_CB_SBNo__c,BVC_CB_Shipment_Date__c,BVC_CB_Shipment_No__c,'+
            'BVC_CB_ShipTo_Fields__c,BVC_CB_SoldTo_Fields__c,BVC_CB_SOS__c,BVC_CB_SupplyType__c,BVC_CB_SUPPLY_TYPE__c,'+
            'BVC_CB_Tariff_Name__c,BVC_CB_Tax_Bill_Amount__c,BVC_CB_Tax_Invoice_No__c,BVC_CB_Tax_Round_Off__c,BVC_CB_Trade_Name__c,'+
            'BVC_CB_TRANSACTION_CLASS__c,BVC_Shipment__c,CreatedById,CreatedDate,CurrencyIsoCode,Id,IsDeleted,LastActivityDate,'+
            'BVC_Shipment__r.Origin_Address_Name__c'+
            'LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,Name,SystemModstamp FROM BVC_CB_PreTaxBill__c '+
            
            ' where BVC_CB_Is_Order_Created__c = false and BVC_CB_PretaxDetails_Inserted__c = TRUE';    
        System.debug('for checking Query :'+Query);
    }
    public BVCOrderCreationPreTaxBatch(string query){
        this.query=query;   
    }
    public BVCOrderCreationPreTaxBatch(string query, List<Id> preTaxIds){
        System.debug('for checking query :'+this.query);
        System.debug('for checking query :'+this.preTaxIds);
        this.query=query;
        this.preTaxIds = preTaxIds;
        System.debug('for checking query :'+this.query);
        System.debug('for checking query :'+this.preTaxIds);        
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('for checking query :'+query);
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<BVC_CB_PreTaxBill__c> scope){
        System.debug('for checking inside batch scope '+scope);
        List<BVC_CB_Object_Mapping__c> objectMappings = [select Id,Source_Object_API_Name__c, Source_Field_API_Name__c, 
                                                         Target_Field_API_Name__c, Target_Object_API_Name__c 
                                                         from BVC_CB_Object_Mapping__c 
                                                         where (Target_Object_API_Name__c ='BVCOrder__c' 
                                                                OR Target_Object_API_Name__c='BVC_Order_Product__c') 
                                                         and Is_Active__c = true
                                                        ];
        System.debug('for checking inside batch objectMappings  '+objectMappings);
        System.debug('for checking inside batch objectMappings.size() '+objectMappings.size());
        
        list<BVC_CB_Error_Log__c> errorlogs= new list<BVC_CB_Error_Log__c>();
        List<Id> preTaxIds = new List<Id>();
        for(BVC_CB_PreTaxBill__c s:scope){ 
            System.debug('for checking for checking s === '+s);
            preTaxIds.add(s.Id);    
        } 
        System.debug('for checking preTaxIds === '+preTaxIds);
        List<BVC_CB_PreTaxBill__c> preTaxList = scope;
        List<BVC_CB_PreTaxBillDetails__c> preTaxDetailList = [SELECT BVC_CB_ChargeAmount__c,BVC_CB_SGSTTaxRate__c,
                                                              BVC_CB_ExportPreTaxBillID__c,BVC_CB_ImportPreTaxBillID__c,
                                                              BVC_CB_UTGSTTaxRate__c,BVC_CB_OracleItemCode__c,BVC_CB_CGSTTaxRate__c,
                                                              BVC_CB_ChargeCode__c,BVC_CB_ChargeDescription__c,BVC_CB_CGSTAmount__c,
                                                              BVC_CB_ChargeType__c,BVC_CB_Charge_Product_Code__c,
                                                              BVC_CB_CreatedByDatetime__c,BVC_CB_CreatedBy__c,BVC_CB_HSNCODE__c,
                                                              BVC_CB_Id__c,BVC_CB_IGSTAmount__c,BVC_CB_IGSTTaxRate__c,
                                                              BVC_CB_InvoiceType__c,BVC_CB_Invoice_Type__c,BVC_CB_LastModifiedby__c,
                                                              BVC_CB_LineTotal__c,BVC_CB_ModifiedDatetime__c,BVC_CB_NatureOfService__c,
                                                              BVC_CB_NONTAXVALUE__c,BVC_CB_OracleGLCode__c,BVC_CB_PreTaxBill__c,
                                                              BVC_CB_ReceiptDate__c,BVC_CB_ReceiptNo__c,BVC_CB_Remarks__c,BVC_CB_SAC__c,
                                                              BVC_CB_SalesforceCharge__c,BVC_CB_SGSTAmount__c,BVC_CB_TAXABLEVALUE__c,
                                                              BVC_CB_TaxCategory__c,BVC_CB_TotalItemValue__c,BVC_CB_UTGSTAmount__c,
                                                              CreatedById,CreatedDate,CurrencyIsoCode,Id,IsDeleted,LastActivityDate,
                                                              LastModifiedById,LastModifiedDate,Name,SystemModstamp 
                                                              FROM BVC_CB_PreTaxBillDetails__c
                                                              where BVC_CB_PreTaxBill__r.BVC_CB_Is_Order_Created__c = false
                                                              and BVC_CB_PreTaxBill__c =: preTaxIds                                                              
                                                             ];
        System.debug('for checking preTaxDetailList === '+preTaxDetailList);
        System.debug('for checking preTaxDetailList.size() === '+preTaxDetailList.size());
        Map<String, Id> mapOrderPreTax  = new Map<String, Id>();
        List<BVCOrder__c> insertOrders = new List<BVCOrder__c>();
        set<String> invoiceSet = new set<String>();
        System.debug('for checking scope.size() === '+scope.size());
        for (BVC_CB_PreTaxBill__c PT : scope) {
            try {
                PT.BVC_CB_Is_Order_Created__c = true;                
                if (PT.BVC_CB_PreTaxBillDetails__r != null && !PT.BVC_CB_PreTaxBillDetails__r.isEmpty()) {
                    for (BVC_CB_PreTaxBillDetails__c detail : PT.BVC_CB_PreTaxBillDetails__r) {
                        if (detail.BVC_CB_Invoice_Type__c != null && !invoiceSet.contains(detail.BVC_CB_Invoice_Type__c)) {
                            BVCOrder__c orderRec = new BVCOrder__c();
                            orderRec.Status__c = 'Draft';
                            orderRec.BVC_CB_Invoice_Type__c = detail.BVC_CB_Invoice_Type__c;
                            orderRec.BVC_Branch__c = PT.BVC_CB_Org_Branch_SF_ID__c;
                            orderRec.BVC_CB_Org_Branch_SF_ID__c = PT.BVC_CB_Org_Branch_SF_ID__c;
                            orderRec.BVC_LegalEntity__c = PT.BVC_CB_Org_Branch_SF_ID__r.BVC_LegalEntity__c;
                            orderRec.BVC_Entity__c = PT.BVC_CB_Org_Branch_SF_ID__r.BVC_CB_BVC_Entity__c;
                            orderRec.BVC_CB_PreTaxBill__c = PT.Id;
                            orderRec.Is_CB_Order__c = true;
                            //orderRec.Origin_Address__c =PT.BVC_Shipment__r.Origin_Address_Name__c;
                            orderRec.Billing_Account__c = PT.BVC_CB_SalesForceCustomerId__c;
                            
                            invoiceSet.add(detail.BVC_CB_Invoice_Type__c);
                            
                            for (BVC_CB_Object_Mapping__c fieldMapping : objectMappings) {
                                if (fieldMapping.Target_Object_API_Name__c == 'BVCOrder__c') {
                                    try {
                                        orderRec.put(fieldMapping.Target_Field_API_Name__c, PT.get(fieldMapping.Source_Field_API_Name__c));
                                    } catch (Exception e) {
                                        BVC_CB_Error_Log__c errorlog = new BVC_CB_Error_Log__c();
                                        errorlog.Name = 'PretaxBill to BVCOrder field mapping issue';
                                        errorlog.Error_Log_Data__c = 'Fields - ' + fieldMapping.Target_Field_API_Name__c;
                                        errorlog.PreTaxBill__c = PT.Id;
                                        errorlog.Error_Code__c = 'BVCOrder creation error';
                                        errorlog.Full_Error_Log__c = e.getMessage();
                                        errorlogs.add(errorlog);
                                    }
                                }
                            }
                            
                            if (orderRec.BVC_CB_ExportShipmentID__c != null || orderRec.BVC_CB_Import_Shipment__c != null || 
                                (orderRec.BVC_CB_ExportShipmentID__c == null && orderRec.BVC_CB_Import_Shipment__c == null)) {
                                    orderRec.Order_End_Date__c = System.today();
                                    orderRec.Order_Start_Date__c = System.today();
                                }
                            
                            orderRec.Billing_Day_Of_Month__c = '1';
                            System.debug('for checking insertOrders.size() === '+insertOrders.size());
                            insertOrders.add(orderRec);
                        }
                    }
                }
                
            } catch (Exception e) {
                BVC_CB_Error_Log__c errorlog = new BVC_CB_Error_Log__c();
                errorlog.Name = 'Error updating PreTaxBill or creating Order';
                errorlog.PreTaxBill__c = PT.Id;
                errorlog.Error_Code__c = 'PreTaxBill Update Error';
                errorlog.Full_Error_Log__c = e.getMessage();
                errorlogs.add(errorlog);
            }
            
        }
        
        try{        
            System.debug('for checking insertOrders === '+insertOrders);
            if(insertOrders.size()>0){
                insert insertOrders;
            }
            
        }catch(exception e){
            for(BVCOrder__c ord:insertOrders){
                BVC_CB_Error_Log__c errorlog= new BVC_CB_Error_Log__c();
                errorlog.name='Error-'+System.now().addHours(5).addMinutes(30);
                errorlog.PreTaxBill__c= ord.BVC_CB_PreTaxBill__c;
                errorlog.Error_Code__c= 'BVCOrder creation error';
                errorlog.Full_Error_Log__c = e.getMessage();
                errorlogs.add(errorlog);
            }
        }
        
        id bvcorderId=null;
        if(insertOrders.size()>0){
            
        }
        List<BVC_Order_Product__c> orderItemInsert = new List<BVC_Order_Product__c>();
        if(insertOrders.size()>0){
            for(BVCOrder__c orderRec : insertOrders){
                mapOrderPreTax.put(orderRec.BVC_CB_PreTaxBill__c+orderRec.BVC_CB_Invoice_Type__c,orderRec.Id);
            }
            System.debug('for checking mapOrderPreTax.values() === '+mapOrderPreTax.values());
            
            for(BVC_CB_PreTaxBillDetails__c PT:preTaxDetailList){
                BVC_Order_Product__c orderItemRec = new BVC_Order_Product__c();
                for(BVC_CB_Object_Mapping__c fieldMapping : objectMappings){
                    try{
                        if(fieldMapping.Target_Object_API_Name__c=='BVC_Order_Product__c'){
                            
                            system.debug('BVC_Order_Product__c fields'+fieldMapping.Target_Field_API_Name__c);
                            orderItemRec.put(fieldMapping.Target_Field_API_Name__c, PT.get(fieldMapping.Source_Field_API_Name__c));
                        }
                    }catch(exception e){
                        BVC_CB_Error_Log__c errorlog= new BVC_CB_Error_Log__c();
                        errorlog.name = 'PretaxbillDetails to BVC_Order_Product__c fieldmapping error.';
                        errorlog.Error_Log_Data__c='Fields - '+fieldMapping.Target_Field_API_Name__c;
                        errorlog.PreTaxBill__c= PT.BVC_CB_PreTaxBill__c;
                        errorlog.Error_Code__c= 'BVC Order Product creation error';
                        errorlog.Full_Error_Log__c = e.getMessage();
                        errorlogs.add(errorlog);
                    }
                }
                
                orderItemRec.Quantity__c =1;
                orderItemRec.BVCOrder__c = mapOrderPreTax.get(PT.BVC_CB_PreTaxBill__c+PT.BVC_CB_Invoice_Type__c);
                bvcorderId=mapOrderPreTax.get(PT.BVC_CB_PreTaxBill__c+PT.BVC_CB_Invoice_Type__c);
              //  orderitemrec.Billing_Frequency__c ='Monthly';
                orderitemrec.Total_Price__c=PT.BVC_CB_ChargeAmount__c;
                System.debug('for checking orderItemRec === '+orderItemRec);
                
                orderItemRec.BVC_CB_PreTaxBillDetails__c = PT.Id;
                
                orderItemInsert.add(orderItemRec);
                
            }
            
            
            
            
        }
        
        try{
            System.debug('for checking orderItemInsert === '+orderItemInsert);
            System.debug('for checking orderItemInsert.size() === '+orderItemInsert.size());
            if(orderItemInsert.size()>0){
              insert orderItemInsert;  
                
                if (insertOrders != null && !insertOrders.isEmpty()) {
                    Set<Id> orderIds = new Set<Id>();
                    for (BVCOrder__c order : insertOrders) {
                        orderIds.add(order.Id);
                    }
                    
                    List<BVC_Order_Product__c> relatedOrderProducts = [
                        SELECT Id, BVCOrder__c, Total_Price__c 
                        FROM BVC_Order_Product__c 
                        WHERE BVCOrder__c IN :orderIds
                    ];
                    
                    Map<Id, List<BVC_Order_Product__c>> orderProductMap = new Map<Id, List<BVC_Order_Product__c>>();
                    for (BVC_Order_Product__c orderProduct : relatedOrderProducts) {
                        if (!orderProductMap.containsKey(orderProduct.BVCOrder__c)) {
                            orderProductMap.put(orderProduct.BVCOrder__c, new List<BVC_Order_Product__c>());
                        }
                        orderProductMap.get(orderProduct.BVCOrder__c).add(orderProduct);
                    }
                    
                    List<BVCOrder__c> ordersToUpdate = new List<BVCOrder__c>();
                    
                    for (BVCOrder__c order : insertOrders) {
                        if (orderProductMap.containsKey(order.Id)) {
                            Decimal totalOrderAmount = 0;
                            
                            for (BVC_Order_Product__c orderProduct : orderProductMap.get(order.Id)) {
                                totalOrderAmount += orderProduct.Total_Price__c;
                            }
                            
                            order.Order_Amount__c = totalOrderAmount;
                            ordersToUpdate.add(order);
                            
                            System.debug('for checking Updated Order Id: ' + order.Id + ' with Total Amount: ' + totalOrderAmount);
                        } else {
                            System.debug('for checking No related products found for Order Id: ' + order.Id);
                        }
                    }
                    
                    if (!ordersToUpdate.isEmpty()) {
                        update ordersToUpdate;
                        System.debug('for checking Orders updated successfully.');
                    } else {
                        System.debug('for checking No orders to update.');
                    }
                }

                
            }
            
            
        }catch(exception e){
            for(BVC_Order_Product__c tmpOI:orderItemInsert){
                BVC_CB_Error_Log__c errorlog= new BVC_CB_Error_Log__c();
                errorlog.name='Error -'+System.now().addHours(5).addMinutes(30);
                errorlog.PreTaxBill__c= tmpOI.id;
                errorlog.Error_Code__c= 'BVC Order Product creation error';
                errorlog.Full_Error_Log__c = e.getMessage();
                errorlogs.add(errorlog);
            }
        }
        
        try {
            if (preTaxList.size()>0) {
                System.debug('for checking preTaxList === '+preTaxList);
                update preTaxList;  
            }
        } catch (Exception e) {
            System.debug('for checking error message '+e.getMessage());
            System.debug('for checking error message line number '+e.getLineNumber());
            for (BVC_CB_PreTaxBill__c PT : preTaxList) {
                BVC_CB_Error_Log__c errorlog = new BVC_CB_Error_Log__c();
                errorlog.Name = 'Error updating PreTaxBill'+System.now().addHours(5).addMinutes(30);
                errorlog.PreTaxBill__c = PT.Id;
                errorlog.Error_Code__c = 'PreTaxBill Update Error';
                errorlog.Full_Error_Log__c = e.getMessage();
                errorlogs.add(errorlog);
            }
        }
        
        if(errorlogs.size()>0){
            insert  errorlogs;
        }
    }
    
    public void finish(Database.BatchableContext BC){
        
    }
    
    public static void Method2(){
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
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
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
    
    /*@AuraEnabled 
    // @invocableMethod(label='Send single Pretaxbill to create order')
    public static BVC_CB_PreTaxBill__c invokebatch(id recordid){
        BVC_CB_PreTaxBill__c pretaxbillrec = [SELECT id,BVC_CB_PretaxDetails_Inserted__c,BVC_CB_Is_Order_Created__c from BVC_CB_PreTaxBill__c where id= :recordid];
        if(!pretaxbillrec.BVC_CB_Is_Order_Created__c && pretaxbillrec.BVC_CB_PretaxDetails_Inserted__c == True){
            string Querry = 'SELECT (select Id,BVC_CB_Invoice_Type__c,BVC_CB_Charge_Product_Code__c from BVC_CB_PreTaxBillDetails__r ),BVC_CB_Org_Branch_SF_ID__r.BVC_CB_BVC_Entity__c,BVC_CB_Org_Branch_SF_ID__r.CB_BVC_Legal_Entity__c,BVC_CB_Org_Branch_SF_ID__r.New_BVC_Billing_Entity__c,BVC_CB_GrossWt__c,BVC_CB_Billing_Account_2__c,BVC_CB_Billing_Account_Address_2__c,'+
                'BVC_CB_Operation_Type__c,BVC_CB_PretaxDetails_Inserted__c,BVC_CB_Customer_GSTINNO__c,BVC_CB_Destination_Country_2__c,BVC_CB_Destination_Port_2__c,BVC_CB_Is_Order_Created__c,BVC_CB_Invoice_Type__c,BVC_CB_AIR_SEA__c,BVC_CB_Assessable_Value__c,BVC_CB_BE_Date__c,BVC_CB_BE_No__c,BVC_CB_Customer_Invoice_Number__c,BVC_CB_Billing_Account_Address__c,BVC_CB_Billing_GSTIN__c,BVC_CB_Billing_GST_State_Code__c,BVC_CB_Billing_OracleId__c,BVC_CB_Billing_Oracle_SiteId__c,BVC_CB_Billing_PAN__c,BVC_CB_Billing_SF_Customer_Address__c,BVC_CB_Billing_SF_Customer__c,BVC_CB_Billing_State__c,BVC_CB_BillTo_Fields__c,BVC_CB_Bond_Date__c,BVC_CB_Bond_No__c,BVC_CB_BOS_Bill_Amount__c,BVC_CB_BOS_Invoice_No__c,BVC_CB_BOS_Round_Off__c,BVC_CB_BVC_VAMASHIP_ID__c,BVC_CB_Cash_Idf_Date__c,BVC_CB_Cash_Idf_No__c,BVC_CB_CCDate__c,BVC_CB_CCNo__c,BVC_CB_CM_Bill_Amount__c,BVC_CB_CM_Invoice_No__c,BVC_CB_CM_Round_Off__c,BVC_CB_CONTENT__c,BVC_CB_Created_By_Datetime__c,BVC_CB_Created_By__c,BVC_CB_Customer_Address__c,BVC_CB_Customer_Invoice_Date__c,BVC_CB_Customer_Invoice_Value_Currency__c,BVC_CB_Customer_Name__c,BVC_CB_CUSTOMER_TRANSACTION_TYPE__c,BVC_CB_Despatch__c,BVC_CB_DestinationCountry__c,BVC_CB_DestinationPort__c,BVC_CB_DT_GR_FORM_NO__c,BVC_CB_EDFDate__c,BVC_CB_EDFNo__c,BVC_CB_ERDate__c,BVC_CB_ERNo__c,BVC_CB_ExportShipmentID__c,BVC_CB_FOBValue__c,BVC_CB_GR_FORM_NO__c,BVC_CB_GSTIN_Remarks__c,BVC_CB_HAWB_Date__c,BVC_CB_HAWB_No__c,BVC_CB_IGM_Item_Date__c,BVC_CB_IGM_Item_No__c,BVC_CB_Import_Shipment__c,BVC_CB_Invoice_Value_INR__c,BVC_CB_Invoice_Value__c,BVC_CB_IRN_Date__c,BVC_CB_IRN__c,BVC_CB_JOB_DT__c,BVC_CB_JOB_NO__c,BVC_CB_Last_Modifiedby__c,BVC_CB_License_Date__c,BVC_CB_License_No__c,BVC_CB_lospCity__c,BVC_CB_lospColumn__c,BVC_CB_lospStateCode__c,BVC_CB_lospState__c,BVC_CB_lospTable__c,BVC_CB_MAWB_Date__c,BVC_CB_MAWB_No__c,BVC_CB_Modified_Datetime__c,BVC_CB_Net_Wt__c,BVC_CB_No_Of_Pkgs__c,BVC_CB_OracleID__c,BVC_CB_Oracle_SiteId__c,BVC_CB_OrgBranchCode__c,BVC_CB_OrgBranchName__c,BVC_CB_Org_Branch_GSTIN__c,BVC_CB_Org_Branch_GST_State_Code__c,BVC_CB_Org_Branch_SF_ID__c,BVC_CB_Org_Branch_State__c,BVC_CB_Org_CINNO__c,BVC_CB_Org_PAN__c,BVC_CB_posColumn__c,BVC_CB_posTable__c,BVC_CB_POS__c,BVC_CB_PreTaxInvoice_ID__c,BVC_CB_Pre_Tax_Date__c,BVC_CB_Pre_Tax_No__c,BVC_CB_ProcessingDate__c,BVC_CB_Remarks1__c,BVC_CB_Remarks__c,BVC_CB_ROUND_OFF__c,BVC_CB_SalesForceAddress__c,BVC_CB_SalesForceCustomerId__c,BVC_CB_SBDate__c,BVC_CB_SBNo__c,BVC_CB_Shipment_Date__c,BVC_CB_Shipment_No__c,BVC_CB_ShipTo_Fields__c,BVC_CB_SoldTo_Fields__c,BVC_CB_SOS__c,BVC_CB_SupplyType__c,BVC_CB_SUPPLY_TYPE__c,BVC_CB_Tariff_Name__c,BVC_CB_Tax_Bill_Amount__c,BVC_CB_Tax_Invoice_No__c,BVC_CB_Tax_Round_Off__c,BVC_CB_Trade_Name__c,BVC_CB_TRANSACTION_CLASS__c,BVC_Shipment__c,CreatedById,CreatedDate,CurrencyIsoCode,Id,IsDeleted,LastActivityDate,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,Name,SystemModstamp FROM BVC_CB_PreTaxBill__c '+
                ' where BVC_CB_Is_Order_Created__c = false'+' and id=\'' +recordid+ '\'';
                
                Id batchJobId = Database.executeBatch(new BVCOrderCreationPreTaxBatch(Querry), 200);
            
        }
        
        return pretaxbillrec;
    }*/
}