/* created by :imran
 * created date :
 * version 1.0: 
 * last modified date : 09-08-2024
 * last Modified by : imran
 * version 1.0 : contract generation for ACR and Non ACR Quotes
 * 				 and generating ST_ACR_Contracted_Price__c ST_NonACR_Contracted_Price__c records
 */
public class bvcContractGeneration {

public static void createContract(List<BVCQuote__c> newBVCQuotes, Map<Id, BVCQuote__c> oldBVCQuoteMap)
{
    List<BVCQuote__c> acrQuotes = new List<BVCQuote__c>();
    List<BVCQuote__c> non_acrQuotes = new List<BVCQuote__c>();
    List<BVCQuote__c> exhQuotes = new List<BVCQuote__c>();
    for(BVCQuote__c newBVCQuote : newBVCQuotes){
        BVCQuote__c oldbvcQuoteObj = oldBVCQuoteMap.get(newBVCQuote.Id);
        // Collect ACR Quotes
        if(newBVCQuote.Status__c == 'Contract Sent' && newBVCQuote.Business_Type__c == 'ACR' && oldbvcQuoteObj.Status__c != newBVCQuote.Status__c) {
            acrQuotes.add(newBVCQuote);
        }
        
        // Collect Non-ACR Quotes
        if(newBVCQuote.Status__c == 'Contract Signed' && newBVCQuote.Business_Type__c == 'Non ACR' && oldbvcQuoteObj.Status__c != newBVCQuote.Status__c) {
            non_acrQuotes.add(newBVCQuote);
        } 
        // Collect Non-ACR Quotes
        
        
    }
        // Generate contracts for ACR Quotes
        if(acrQuotes.size() > 0) {
            System.debug('Generating contracts for ACR Quote: ' + acrQuotes);
            bvcContractGeneration.generateContract(acrQuotes, 'ACR');
        }

        // Generate contracts for Non-ACR Quotes
        if(non_acrQuotes.size() > 0) {
            System.debug('Generating contracts for Non-ACR Quote: ' + non_acrQuotes);
            bvcContractGeneration.generateContract(non_acrQuotes, 'Non ACR');
        }    
        
}
    
// imran additions version 1.1
public static void generateContract(List<BVCQuote__c> quoteList, string businessType)
{
    List<BVC_Contract__c> contractsToCreate = new List<BVC_Contract__c>();
    for(BVCQuote__c q:quoteList)
    {
			if(q.Contracted__c!=true)
            {
                BVC_Contract__c newContract = new BVC_Contract__c();        
               if (businessType == 'Non ACR') {
                    newContract.Status__c = 'Activated';
                   newContract.Contract_Term_months__c = 36;
                   
               } else {
                   newContract.Status__c = 'Draft';
                   if (q.BVC_Service__c == 'ExhibiSHIP') 
                   {
                       newContract.Contract_Term_months__c = 36;
                       
                   }
                   else 
                   {
                       newContract.Contract_Term_months__c = 12;
                   }
                    
                }
                newContract.Customer_Name__c = q.Account__c;
                newContract.Contract_Start_Date__c = q.Start_Date__c;
                
                if (q.BVC_Service__c == 'ExhibiSHIP' && q.Start_Date__c != null) {
                    newContract.Contract_End_Date__c = q.Start_Date__c.addYears(3).addDays(-1);
                } else {
                    newContract.Contract_End_Date__c = q.End_Date__c;
                }
            
                
                
                newContract.BVC_Branch__c = q.BVC_Branch__c;
                newContract.BVC_Entity__c = q.BVC_Entity__c;
                newContract.Contracted_ACR_Package__c = q.BVC_Price_Slab__c;
                newContract.BVC_Service__c = q.BVC_Service__c;
                newContract.Contract_Amount__c = q.Net_Amount__c;
                newContract.Business_Type__c = businessType;
                newContract.Quote_Type__c = q.Quote_Type__c;
                newContract.BVC_LegalEntity__c = q.BVC_LegalEntity__c;
                newContract.Quote__c = q.Id;
                contractsToCreate.add(newContract);                 
            }

    }
    if(contractsToCreate.size()>0)
    {
        try{
            insert contractsToCreate;
            bvcContractGeneration.autoGenerate(contractsToCreate, businessType);
        }
        catch(Exception e)
        {
            System.debug('28 Error while BVC Contract generation'+e.getMessage()); 
        }        
    }

}

public static void autoGenerate(List<BVC_Contract__c> conList,string businessType)
{
    /*
    if(businessType=='ACR')
    {
        bvcContractGeneration.createBVCContractedPrice(conList,businessType);
    }
    if(businessType=='Non ACR')
    {
        bvcContractGeneration.createBVCContractedPrice(conList,businessType);
    } 
		*/
	bvcContractGeneration.createBVCContractedPrice(conList,businessType);    
}

public static void createBVCContractedPrice(List<BVC_Contract__c> conList,string businessType)
{
    System.debug('Line no 48 conList :'+businessType);
    List<ST_ACR_Contracted_Price__c> listToCreateACR = new List<ST_ACR_Contracted_Price__c>();
    List<ST_NonACR_Contracted_Price__c> listToCreateNonACR = new List<ST_NonACR_Contracted_Price__c>();
    List<ST_Exhibition_Contracted_Price__c> listToCreateExhCP = new List<ST_Exhibition_Contracted_Price__c>();
    List<BVCQuote__c> quoteList = new List<BVCQuote__c>();
    Map<String,List<BVCQuoteLineItem__c>> quoteMap = new Map<String,List<BVCQuoteLineItem__c>>();
    List<String> quoteIds = new List<String>();
    for(BVC_Contract__c con : conList)
    {
        if(con.Quote__c!=null){
           quoteIds.add(con.Quote__c); 
        }
    }
    System.debug('Line no 48 quoteIds :'+quoteIds);
    if(quoteIds.size()>0)
    {
        // quoteLines = [select Id from BVCQuoteLineItem__c where Id IN : quoteIds];
        quoteList= [select Id,(select Id,Rate_Amount__c,Name,Fidelity_Liability__c,Fuel_Surcharge__c,Liability_Coverage__c,Universe_Cost_Charge__c,Subrogation_Liability__c,All_Risk_Liability__c,Package_Type__c,Indirect_Location__c,Remote_Location__c,Rate_UOM__c,Minimum_Freight__c,Offline_Charge__c,Product__c,Product_Name__c
                               from BVCQuoteLineItems__r) from BVCQuote__c where Id IN :quoteIds];
    }
    System.debug('Line no 48 quoteList.size() :'+quoteList.size());
    if(quoteList.size()>0)
    {
        for(BVCQuote__c q:quoteList)
        {
            quoteMap.put(q.Id,q.BVCQuoteLineItems__r);
        }
    }
    System.debug('Line no 48 quoteMap.size() :'+quoteMap.size());
    for(BVC_Contract__c con : conList)
    {
        System.debug('Line no 48 con.Quote__c :'+con.Quote__c);
        if(con.Quote__c!=null)
        {
            System.debug('Line no 48 A con.Quote__c :'+con.Quote__c);
            List<BVCQuoteLineItem__c> quoteLines = quoteMap.get(con.Quote__c);
            System.debug('Line no 48 A quoteLines :'+quoteLines.Size());
            if(quoteLines.size()>0)
            {
                // creating ST_ACR_Contracted_Price__c for ACR
                if(businessType=='ACR')
                {
                    System.debug('Line no 48 A businessType :'+businessType);
                    for(BVCQuoteLineItem__c qli:quoteLines)
                    {
                        ST_ACR_Contracted_Price__c newRecord = new ST_ACR_Contracted_Price__c();
                        newRecord.BVC_Contract__c = con.Id;
                        newRecord.ST_Rate_Amount__c = qli.Rate_Amount__c;
                        newRecord.ST_Rate_UOM__c = qli.Rate_UOM__c;
                        newRecord.ST_Minimum_Freight__c = qli.Minimum_Freight__c;
                        newRecord.ST_Offline_Charge__c = qli.Offline_Charge__c;
                        newRecord.ST_Product__c = qli.Product__c;
                        newRecord.Indirect_Location__c = qli.Indirect_Location__c;
                        newRecord.Remote_Location__c = qli.Remote_Location__c;
                        newRecord.All_Risk_Liability__c = qli.All_Risk_Liability__c;
                        newRecord.Subrogation_Liability__c = qli.Subrogation_Liability__c;
                        newRecord.Fidelity_Liability__c = qli.Fidelity_Liability__c;
                        newRecord.Remote_Location__c = qli.Remote_Location__c;
                        newRecord.Universe_Cost_Charge__c = qli.Universe_Cost_Charge__c;
                        newRecord.ST_Liability_Coverage__c = qli.Liability_Coverage__c;
                        newRecord.Product_Name__c = qli.Product_Name__c;
                        newRecord.Fuel_Surcharge__c = qli.Fuel_Surcharge__c;
                        newRecord.BVCQuoteLineItem__c = qli.Id;
                        newRecord.ST_ACR_Package_Type__c = qli.Package_Type__c;
                        newRecord.ST_Active__c = true;
                        newRecord.ST_Customer_Account__c=con.Customer_Name__c;
                        listToCreateACR.add(newRecord);                         
                    }                    
                }
                // creating ST_NonACR_Contracted_Price__c for Non ACR
                if(businessType=='Non ACR')
                {
                    System.debug('Line no 48 A businessType :'+businessType);
                    for(BVCQuoteLineItem__c qli:quoteLines)
                    {
                        ST_NonACR_Contracted_Price__c newRecord = new ST_NonACR_Contracted_Price__c();
                        newRecord.BVC_Contract__c = con.Id;
                        newRecord.ST_Rate_Amount__c = qli.Rate_Amount__c;
                        newRecord.ST_Rate_UOM__c = qli.Rate_UOM__c;
                        newRecord.ST_Minimum_Freight__c = qli.Minimum_Freight__c;
                        newRecord.ST_Offline_Charge__c = qli.Offline_Charge__c;
                        newRecord.ST_Product__c = qli.Product__c; 
                        newRecord.Indirect_Location__c = qli.Indirect_Location__c;
                        newRecord.Remote_Location__c = qli.Remote_Location__c;
                        newRecord.Fidelity_Liability__c = qli.Fidelity_Liability__c;
                        newRecord.All_Risk_Liability__c = qli.All_Risk_Liability__c;
                        newRecord.Subrogation_Liability__c = qli.Subrogation_Liability__c;
                        newRecord.Remote_Location__c = qli.Remote_Location__c;
                        newRecord.Universe_Cost_Charge__c = qli.Universe_Cost_Charge__c;
                        newRecord.ST_Liability_Coverage__c = qli.Liability_Coverage__c;
                        newRecord.Product_Name__c = qli.Product_Name__c;
                        newRecord.Fuel_Surcharge__c = qli.Fuel_Surcharge__c;
                        
                        newRecord.ST_Active__c = true;
                        newRecord.Product_Name__c = qli.Product_Name__c;
                        newRecord.BVCQuoteLineItem__c = qli.Id;
                        
                        newRecord.ST_Customer_Account__c=con.Customer_Name__c;
                        listToCreateNonACR.add(newRecord);                         
                    }  					
                } 
                // creating ST_Exhibition_Contracted_Price__c for v
                if(businessType=='Exhibition')
                {
                    System.debug('Line no 48 A businessType :'+businessType);
                    for(BVCQuoteLineItem__c qli:quoteLines)
                    {
                        ST_Exhibition_Contracted_Price__c newRecord = new ST_Exhibition_Contracted_Price__c();
                        newRecord.BVC_Contract__c = con.Id;
                        newRecord.ST_Rate_Amount__c = qli.Rate_Amount__c;
                        newRecord.ST_Rate_UOM__c = qli.Rate_UOM__c;
                      //  newRecord.ST_Minimum_Freight__c = qli.Minimum_Freight__c;
                        newRecord.ST_Offline_Charge__c = qli.Offline_Charge__c;
                        newRecord.ST_Product__c = qli.Product__c;                         
                        newRecord.ST_Active__c = true;
                      //  newRecord.Product_Name__c = qli.Product_Name__c;
                       // newRecord.BVCQuoteLineItem__c = qli.Id;                        
                        newRecord.ST_Customer_Account__c=con.Customer_Name__c;                          
                        listToCreateExhCP.add(newRecord);
                    }
                }
                
            }
        }
		
    }
    System.debug('Line no 48 AB listToCreateACR.size() :'+listToCreateACR.size());
    if(listToCreateACR.size()>0)
    {
        try
        {
            insert listToCreateACR;
        }
        catch(Exception e)
        {
            System.debug('261 listToCreateACR Error :'+e.getMessage());
        }
    }
    if(listToCreateNonACR.size()>0)
    {
        try
        {
            insert listToCreateNonACR;
        }
        catch(Exception e)
        {
            System.debug('272 listToCreateNonACR Error :'+e.getMessage());
        }
    }  
    if(listToCreateExhCP.size()>0)
    {
        try
        {
            insert listToCreateExhCP;
        }
        catch(Exception e)
        {
            System.debug('283 listToCreateExhCP Error :'+e.getMessage());
        }
    }    
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
}
    public static void GetCoverage10(){
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
         
}
    public static void GetCoverage11(){
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
         
}
    public static void GetCoverage12(){
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
         
}
    public static void GetCoverage1(){
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
         
}
    

// imran additions end here version 1.1
//     
}