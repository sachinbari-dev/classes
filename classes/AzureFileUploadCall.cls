/**
 * Trigger: CDTrigger
 * 
 * Author:  Imran Sheik
 * Created Date: 2025-04-14
 * 
 * Description:
 * - this trigger send the uploaded url to Azure and storing the url on Azure_File_UploadUrl__c
 *  - this can work on Shipment, Securebags,Delivery, Email, CustomerDocument, BVCInvoice__c, BVCCreditNote__c, BVCQuote__c
 * 
 * Usage:
 * - Called from CDTrigger to handle insert logic
 *  
 * Version History:
 * 1.0 - 2025-04-14 - Initial version created by Imran Sheik.
 */
global class AzureFileUploadCall implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful
{
    public String ObjectNameFound;
    public ContentDocumentLink cd = new ContentDocumentLink();
    public AzureFileUploadCall(List<ContentDocumentLink> cd)
    {
        System.debug('Yes');
        Id recordId = cd[0].LinkedEntityId; 
        System.debug('9 recordId: ' + recordId);
        SObjectType objType = recordId.getSObjectType();
        String objectApiName = objType.getDescribe().getName();
        System.debug('12 Object API Name: ' + objectApiName);
        this.ObjectNameFound = objectApiName;        
        this.cd = cd[0];
    }
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        System.debug('30 ObjectNameFound ' + ObjectNameFound);
        String query='SELECT Id from Account limit 1 ';
        System.debug('36 query :'+query);
        return Database.getQueryLocator(query);     
    }
    global void execute(Database.BatchableContext bc,List<Account> fileLinks)
    {
        
        String ObjectName;
        System.debug('28 cd.LinkedEntityId: ' + cd.LinkedEntityId);
        System.debug('29 Object Name: ' + ObjectNameFound);
        System.debug('30 cd.Id: ' + cd.Id);
        if(ObjectNameFound!='User')
        {
            
            if(ObjectNameFound=='Shipment__c'){ ObjectName ='Shipment';}
            if(ObjectNameFound=='Customer_Documents__c'){ ObjectName ='CustomerDocument';}
            if(ObjectNameFound=='Secure_Bag__c'){ ObjectName ='SecureBag';}
            if(ObjectNameFound=='Delivery__c'){ ObjectName ='Delivery';}
            if(ObjectNameFound=='EmailMessage'){ ObjectName ='Email';}
            
            if(ObjectNameFound=='BVCInvoice__c'){ ObjectName ='Invoices';}
            if(ObjectNameFound=='BVCCreditNote__c'){ ObjectName ='CreditNote';}
            if(ObjectNameFound=='BVCQuote__c'){ ObjectName ='Quote';} 
            
            SObject record = Database.query('SELECT Id,Azure_IsFileUpload__c,Azure_File_UploadUrl__c FROM ' + ObjectNameFound + ' WHERE Id = \''+cd.LinkedEntityId+'\' LIMIT 1');
            System.debug('record :'+record);
            Boolean checkBox =(Boolean) record.get('Azure_IsFileUpload__c');
            String fileUrl =(String) record.get('Azure_File_UploadUrl__c');
            System.debug('checkBox :'+checkBox);
            System.debug('fileUrl :'+fileUrl);
            ContentVersion cv = [SELECT Id,ContentDocumentId, VersionData, Title,FileType FROM ContentVersion WHERE ContentDocumentId=:cd.ContentDocumentId limit 1];
            ContentDocumentLink CDLRecord = [ SELECT Id, ContentDocumentId, LinkedEntityId,LinkedEntity.Name from ContentDocumentLink where Id=:cd.Id limit 1];
            System.debug('cv.VersionData :'+cv.VersionData);
            if(cv!=null)
            {
                try {
                    // Generate the Azure Blob Storage URL
                    String fileName= cv.Title;
                    fileName = fileName.replace(' ', '_');                        
                    String parentId = cd.LinkedEntityId;                        
                   // String blobEndpoint = 'https://' + 'bvcstorageos' + '.blob.core.windows.net/ salesforcefiles/' + ObjectName + '/' + parentId + '/' + fileName;
                    fileName = fileName+'_'+cv.Id+'_'+CDLRecord.LinkedEntity.Name;
                    fileName = fileName.replaceAll('[()]','');
                    System.debug('fileName :'+fileName);
                    String endPoint;
                    if(cv.FileType!='PDF')
                    {
                        if(cv.FileType=='EXCEL_X' || cv.FileType=='EXCEL')
                        {
                            //endPoint ='https://bvcstorageos.blob.core.windows.net/salesforcefiles/'+fileName+'.xls'; 
                            endPoint ='https://bvcstorageos.blob.core.windows.net/salesforcefiles/'+ObjectName+'/'+fileName+'.xls'; 
                        }
                        else
                        {
                            //endPoint ='https://bvcstorageos.blob.core.windows.net/salesforcefiles/'+fileName+'.'+cv.FileType;
                            endPoint ='https://bvcstorageos.blob.core.windows.net/salesforcefiles/'+ObjectName+'/'+fileName+'.'+cv.FileType;
                        }                            
                    }
                    else
                    {
                        //endPoint ='https://bvcstorageos.blob.core.windows.net/salesforcefiles/'+fileName;
                        endPoint ='https://bvcstorageos.blob.core.windows.net/salesforcefiles/'+ObjectName+'/'+fileName;
                    }
                    
                    endPoint = endPoint +'?sv=2023-01-03&spr=https%2Chttp&st=2024-10-10T12%3A42%3A27Z&se=2028-05-10T12%3A42%3A00Z&sr=c&sp=racwltf&sig=poyeaQEsl8E8nEZvIA%2F4%2FrAV3Gl97wQRrzaeHy7qLkw%3D';
                    
                    // String data ='@RZltuZFS1/'+fileName+'.pdf'; 
                    HttpRequest req = new HttpRequest();
                    req.setEndpoint(endPoint);
                    
                    req.setMethod('PUT');   
                    req.setHeader('Content-Length','0');
                    req.setHeader('x-ms-blob-type', 'BlockBlob');
                    // req.setHeader('Content-Type', 'application/pdf');
                    req.setHeader('Content-Type', 'application/'+cv.FileType);
                    req.setBodyAsBlob(cv.VersionData);
                    // Send the HTTP request
                    Http http = new Http();
                    HttpResponse res = http.send(req);
                    System.debug('74  req: ' + req);
                    System.debug('71 res.getStatusCode():'+res.getStatusCode());
                    if (res.getStatusCode() == 201) {
                        System.debug('File uploaded successfully to fileName: ' + fileName);
                        System.debug('File uploaded successfully to endPoint: ' + endPoint);
                        System.debug('File uploaded successfully to recordId: ' + parentId);
                        System.debug('File uploaded successfully to objectType: ' + ObjectName);
                       // System.debug('File uploaded successfully to blobEndpoint: ' + blobEndpoint);
                        System.debug('File uploaded successfully to res: ' + res);
                        System.debug('File uploaded successfully to res Body: ' + res.getBody());
                        if(checkBox==false)
                        {
                            record.put('Azure_File_UploadUrl__c',endPoint);
                            record.put('Azure_IsFileUpload__c',true);
                        }
                        else
                        {
                            fileUrl+=' ; '+endPoint;
                            record.put('Azure_File_UploadUrl__c',fileUrl); 
                        }
                        System.debug('111 record:'+record);
                        update record;
                        System.debug('113 record:'+record);
                        // Database.update(record, false);
                    } else {
                        System.debug('Error uploading file to Azure: ' + res.getStatus());
                    }
                } catch (Exception e) {
                    System.debug('Error during file upload: ' + e.getMessage());
                }
            } 
            
        }
    }
    global void finish(Database.BatchableContext bc)
    {
        
    }
}