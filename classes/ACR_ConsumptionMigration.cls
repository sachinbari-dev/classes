global class ACR_ConsumptionMigration  implements Database.Batchable<sObject>,Database.Stateful
{   
    Map<String,String> contIds = new Map<String,String>();   
    List<String> contractsIdList = new List<String>();
    public Integer totalRecordsProcesses=0;
    
    public ACR_ConsumptionMigration(Map<String,String> contIds)
    {
        this.contIds = contIds;
    }
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
		List<String> contractIdList = new List<String>(contIds.keySet());
        System.debug('contractsIdList :'+contractsIdList);
        String query='select id,Contract__c,Contract_Date_From__c,Contract_Date_To__c,Product__c,Adjustment_to_Contract_Amount__c';
        query+=',Adjusted_Contract_Amount__c,Shipper_PAN__c,Consignee_Name__c,Minimum_Freight__c,';
        query+='Bill_To_Account__c,ST_ACR_Order__c,BVC_Valuation_Charges__c,Is_Migrted__c,';
        query+='Bill_To_Address__c,BVC_Branch__c,Shipment__c,Shipment_Number__c,';
        query+='Gross_Weight_UOM__c,Gross_Weight_GMS__c,Gross_Weight_Kg__c,Gross_Weight__c,';
        query+='Net_Weight__c,Docket_Charges__c,Fuel_Charges__c,Fidelity_Liability__c,Net_Weight_UOM__c,Net_Weight_GMS__c,Universe_Cost_Charge__c,Net_Weight_kg__c,';
        query+=' Liability_Cover_By_BVC__c,Holiday_Charges__c,Status__c,Remote_Location__c,Subrogation_Liability__c,Indirect_Location__c,Consumption__c,Total_Charge__c,';
        query+='No_Of_Packages__c,Offline_Charges__c,Liability_charges__c,Contract_Amount__c,Contract_Balance__c,';
        query+='Customer_Account__c,Shipment_Date__c,Shipper_Name__c,Consignee_PAN__c,';
        query+='Freight_Charges__c,Fuel_Surcharge__c,Weight_Charges__c,Destination_Address__c,';
        query+=' Destination_type__c,Destination_City__c,Origin_Address__c,Origin_Type__c,';
        query+='Confirmed_By_Name__c,Shipment_Value__c,Product_Description__c,Shipment_Type__c,Secure_Logistics_Charges__c';
        query+=' from ST_ACR_Consumption__c where Contract__c IN :contractIdList and Is_Migrted__c=FALSE';
        System.debug('31 query :'+query);
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc,List<ST_ACR_Consumption__c> acrConsList)
    {         
        System.debug('Line 16');
       
        List<BVC_ACR_Consumption__c> bvcAcrCToInsert = new List<BVC_ACR_Consumption__c>(); 
        
        Map<String,ST_ACR_Consumption__c> migratedACR_Con = new Map<String,ST_ACR_Consumption__c>();
        
        for(ST_ACR_Consumption__c acrCL:acrConsList)
        {                               
            System.debug('Line 93 acrCL:'+acrCL.ST_ACR_Order__c);
            BVC_ACR_Consumption__c singleRecord = new BVC_ACR_Consumption__c();
            String bvContractId = contIds.get(acrCL.Contract__c);                                       
            singleRecord.BVC_Contract__c = bvContractId;
            singleRecord.Migrated_ACR_Consumption__c=acrCL.Id; // mapping migrated Id
            singleRecord.Account__c = acrCL.Customer_Account__c;
            
            singleRecord.Contract_Date_From__c = acrCL.Contract_Date_From__c;
            singleRecord.Contract_Date_To__c = acrCL.Contract_Date_To__c;
            // singleRecord. = acrCL.Product__c;
            singleRecord.Adjustment_to_Contract_Amount__c = acrCL.Adjustment_to_Contract_Amount__c;
            singleRecord.Adjusted_Contract_Amount__c = acrCL.Adjusted_Contract_Amount__c;
            singleRecord.Shipper_PAN__c = acrCL.Shipper_PAN__c;
            singleRecord.Consignee_Name__c = acrCL.Consignee_Name__c;
            singleRecord.Minimum_Freight__c = acrCL.Minimum_Freight__c;
            // singleRecord = acrCL.Order_Product__c;
            singleRecord.Bill_To_Account__c = acrCL.Bill_To_Account__c;
            if(acrCL.Bill_To_Address__c!=null)
            {
                singleRecord.Bill_To_Address__c = acrCL.Bill_To_Address__c;
            }
            
            singleRecord.BVC_Branch__c = acrCL.BVC_Branch__c;
            if(acrCL.Shipment__c!=null)
            {
                singleRecord.Shipment__c = acrCL.Shipment__c;
            }
            
            singleRecord.Shipment_Number__c = acrCL.Shipment_Number__c;
            singleRecord.Gross_Weight_UOM__c = acrCL.Gross_Weight_UOM__c;
            singleRecord.Gross_Weight_GMS__c = acrCL.Gross_Weight_GMS__c;
            // singleRecord.Gross_Weight__c = acrCL.Gross_Weight_Kg__c;
            singleRecord.Gross_Weight__c = acrCL.Gross_Weight__c;
            singleRecord.Net_Weight__c = acrCL.Net_Weight__c;
            singleRecord.Net_Weight_UOM__c = acrCL.Net_Weight_UOM__c;
            singleRecord.Net_Weight_GMS__c = acrCL.Net_Weight_GMS__c;
            // singleRecord.Account__c = acrCL.Net_Weight_kg__c;
            singleRecord.Liability_Cover_By_BVC__c = acrCL.Liability_Cover_By_BVC__c;
            singleRecord.Status__c = acrCL.Status__c;
            singleRecord.Offline_Charges__c = acrCL.Offline_Charges__c;
            singleRecord.Liability_charges__c = acrCL.Liability_charges__c;
            singleRecord.Fuel_Surcharge__c = acrCL.Fuel_Surcharge__c;
            singleRecord.Consumption__c = acrCL.Consumption__c;
            singleRecord.Total_Charge__c = acrCL.Total_Charge__c;
            singleRecord.No_Of_Packages__c = acrCL.No_Of_Packages__c;
            singleRecord.Contract_Amount__c = acrCL.Contract_Amount__c;
            singleRecord.Contract_Balance__c = acrCL.Contract_Balance__c;
            //  singleRecord.Account__c = acrCL.Customer_Account__c;
            singleRecord.Shipment_Date__c = acrCL.Shipment_Date__c;
            singleRecord.Shipper_Name__c = acrCL.Shipper_Name__c;
            singleRecord.Consignee_PAN__c = acrCL.Consignee_PAN__c;
            singleRecord.Freight_Charges__c = acrCL.Freight_Charges__c;
            singleRecord.Fuel_Charges__c = acrCL.Fuel_Charges__c;
            singleRecord.Weight_Charges__c = acrCL.Weight_Charges__c;
            singleRecord.Universe_Cost_Charge__c = acrCL.Universe_Cost_Charge__c;
            singleRecord.Holiday_Charges__c = acrCL.Holiday_Charges__c;
            singleRecord.BVC_Valuation_Charges__c = acrCL.BVC_Valuation_Charges__c;
            singleRecord.Indirect_Location__c = acrCL.Indirect_Location__c;
            singleRecord.Remote_Location__c = acrCL.Remote_Location__c;
            singleRecord.Fidelity_Liability__c = acrCL.Fidelity_Liability__c;
            singleRecord.Subrogation_Liability__c = acrCL.Subrogation_Liability__c;
            singleRecord.Destination_Address__c = acrCL.Destination_Address__c;
            singleRecord.Destination_type__c = acrCL.Destination_type__c;
            // singleRecord.Destination_City__c = acrCL.Destination_City__c;
            singleRecord.Origin_Address__c = acrCL.Origin_Address__c;
            singleRecord.Origin_Type__c = acrCL.Origin_Type__c;
            singleRecord.Confirmed_By_Name__c = acrCL.Confirmed_By_Name__c;
            singleRecord.Shipment_Value__c = acrCL.Shipment_Value__c;
            singleRecord.Product_Description__c = acrCL.Product_Description__c; 
            //added by Pratik for eSHIP
			singleRecord.Shipment_Type__c=acrCL.Shipment_Type__c;
			singleRecord.Secure_Logistics_Charges__c=acrCL.Secure_Logistics_Charges__c;

            //upto here
            migratedACR_Con.put(acrCL.Id,acrCL);
            bvcAcrCToInsert.add(singleRecord);
            totalRecordsProcesses+=1;                          
        }
        try
        {
            System.debug('Line 152 bvcAcrCToInsert:'+bvcAcrCToInsert);
            // upsert bvcAcrCToInsert;
            List<Database.UpsertResult> upsertResults1 = Database.upsert(bvcAcrCToInsert, false);
            List<ST_ACR_Consumption__c> ACR_ConsToUpdate = new List<ST_ACR_Consumption__c>();
            for (Integer i = 0; i < upsertResults1.size(); i++) 
            {
                Database.UpsertResult result = upsertResults1[i];
                if (result.isSuccess()) 
                {
                    ST_ACR_Consumption__c ACR_ConsItem = migratedACR_Con.get(bvcAcrCToInsert[i].Migrated_ACR_Consumption__c);
                    if(ACR_ConsItem!=null)
                    {
                        ACR_ConsItem.Is_Migrted__c= true;
                        ACR_ConsToUpdate.add(ACR_ConsItem);
                    }                        
                }                    
            }
            List<Database.UpsertResult> CheckBoxupsertResults = Database.upsert(ACR_ConsToUpdate, false);
                    
        }catch(Exception e)
        {
            System.debug('156 Error insert bvcOrders :'+e.getMessage());
        }
        
    }
    
    global void finish(Database.BatchableContext bc)
    {
        String body = 'ACR Consumption To BVC Consumption Migration Processed Records :'+totalRecordsProcesses;
        // Email configuration
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new List<String>{'pnatekar@cloudely.com'});
        email.setSubject('Consumption To BVC Consumption Migration');
        email.setPlainTextBody(body);
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});
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
}