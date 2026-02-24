public class BVC_BrinksAgreementController {

     public Id brinksId { get; set; }
    public static List<BVC_bulk_Agreement_signing__c>  brinksBulkList {get;set;}
    
    public BVC_BrinksAgreementController( ){
        
         String brinksId = ApexPages.currentPage().getParameters().get('id');
         String currentDate = String.valueOf(Date.today()).removeEnd(' 00:00:00');
         String fileName = 'BVC Brinks Agreement ' + currentDate + '.pdf';
        
        ApexPages.currentPage().getHeaders().put('content-disposition', 'inline; filename="' + fileName + '"');
        
        if(string.isNotBlank(brinksId)){
            brinksBulkList =[SELECT Name, Id, BVC_Brink_s_Office_Address__c, Customer_Address__c, Customer_GST_No__c, Customer_IEC_No__c, 
                             Customer_Name__c,Customer_Name__r.name, You_are__c,BVC_s_GSTIN_no__c, Customer_Email__c, Document_Type__c FROM BVC_bulk_Agreement_signing__c
                             Where id=:brinksId LIMIT 1]; 
            
            system.debug('brinksBulkList@@@'+brinksBulkList);
        }
        
    }
   
}