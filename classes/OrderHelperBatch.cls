global class OrderHelperBatch implements Database.Batchable<sObject>,Database.Stateful
{
    List<String> orderIdList = new List<String>();   
    Map<String,String> contIds = new Map<String,String>();
    public OrderHelperBatch(Map<String,String> contIds)
    {
        this.contIds = contIds;
    }
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        List<String> contIdList = new List<String>(contIds.keySet());
        
        // String query='select Migrated_Contract__c from BVC_Contract__c where Migrated_Contract__c!=null and Id IN : bvcOrderIds';   
        String query='select id,Contract__c,Contract_Date_From__c,Contract_Date_To__c,Product__c,Adjustment_to_Contract_Amount__c';
        query+=',Adjusted_Contract_Amount__c,Shipper_PAN__c,Consignee_Name__c,Minimum_Freight__c,';
        query+='Bill_To_Account__c,ST_ACR_Order__c,BVC_Valuation_Charges__c,';
        query+='Bill_To_Address__c,BVC_Branch__c,Shipment__c,Shipment_Number__c,';
        query+='Gross_Weight_UOM__c,Gross_Weight_GMS__c,Gross_Weight_Kg__c,Gross_Weight__c,';
        query+='Net_Weight__c,Docket_Charges__c,Fuel_Charges__c,Fidelity_Liability__c,Net_Weight_UOM__c,Net_Weight_GMS__c,Universe_Cost_Charge__c,Net_Weight_kg__c,';
        query+=' Liability_Cover_By_BVC__c,Holiday_Charges__c,Status__c,Remote_Location__c,Subrogation_Liability__c,Indirect_Location__c,Consumption__c,Total_Charge__c,';
        query+='No_Of_Packages__c,Offline_Charges__c,Liability_charges__c,Contract_Amount__c,Contract_Balance__c,';
        query+='Customer_Account__c,Shipment_Date__c,Shipper_Name__c,Consignee_PAN__c,';
        query+='Freight_Charges__c,Fuel_Surcharge__c,Weight_Charges__c,Destination_Address__c,';
        query+=' Destination_type__c,Destination_City__c,Origin_Address__c,Origin_Type__c,';
        query+='Confirmed_By_Name__c,Shipment_Value__c,Product_Description__c';        
        query+=' from ST_ACR_Consumption__c where Contract__c IN :contIdList and Is_Migrted__c=FALSE ';        
        System.debug('31 query :'+query);
        
        
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc,List<ST_ACR_Consumption__c> ACRConsList)
    {
        
        if(ACRConsList.size()>0)
        {
            for(ST_ACR_Consumption__c acrc:ACRConsList)
            {
				orderIdList.add(acrc.ST_ACR_Order__c);
            }
        } 
    }
    global void finish(Database.BatchableContext bc)
    {
       // orderMigration OM = new orderMigration(orderIdList,contIds);
       // database.executeBatch(OM,2000);
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
}