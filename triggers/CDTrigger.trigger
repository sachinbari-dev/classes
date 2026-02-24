/**
 * Trigger: CDTrigger
 * 
 * Author:  Imran Sheik
 * Created Date: 2025-04-14
 * 
 * Description:
 * This trigger runs after an ContentDocumentLink record is inserted.
 * 
 * Trigger Events:
 * - After Insert: Trigger runs after a new File is Uploaded.
 * 
 * Use Cases:
 * - User uploads the Files on Shipment, Securebags,Delivery, Email, CustomerDocument, BVCInvoice__c, BVCCreditNote__c, BVCQuote__c records.
 * 
 * Notes:
 * - this trigger send the uploaded url to Azure and storing the url on Azure_File_UploadUrl__c
 *  - this can work on Shipment, Securebags,Delivery, Email, CustomerDocument, BVCInvoice__c, BVCCreditNote__c, BVCQuote__c
 * 
 * Trigger on:
 * - ContentDocumentLink (after insert)
 * 
 * Version History:
 * 1.0 - 2025-04-14 - Initial version created by Imran Sheik.
 */
trigger CDTrigger on ContentDocumentLink (after insert) 
{       
    if(trigger.isInsert && trigger.isAfter)
    {
        List<ContentDocumentLink> cdl_List =  new List<ContentDocumentLink>();   
        for(ContentDocumentLink cdl:trigger.new)
        {
            
            if(cdl.LinkedEntityId!=null)
            {
                Id recordId = cdl.LinkedEntityId; 
                System.debug('17A recordId: ' + recordId);
                SObjectType objType = recordId.getSObjectType();
                String objectApiName = objType.getDescribe().getName();
                System.debug('20A Object API Name: ' + objectApiName);
                if(objectApiName!='User')
                {                    
                    cdl_List.add(cdl);
                }                                
            }
        }
        if(cdl_List.size()>0)
        {            
            try
            {
               // AzureFileUploadCall afu = new AzureFileUploadCall(cdl_List);
            	//database.executebatch(afu,10); 
            }catch(exception e){
                
            }
            
        }
    }   
}