global class ShipmentFileBackupToAzureBatchNew implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful
{
    public String ObjectName;
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        String query='SELECT Id, ContentDocumentId, LinkedEntityId  ';
        query+='FROM ContentDocumentLink WHERE LinkedEntityId IN (SELECT Id FROM Shipment__c  where Azure_IsFileUpload__c=false) LIMIT 100000';     
        System.debug('16 query :'+query);
        return Database.getQueryLocator(query);        
    }
    global void execute(Database.BatchableContext bc,List<ContentDocumentLink> fileLinks)
    {
        ObjectName='Shipment';
        Map<String,Shipment__c> Ex_ShipMap = new Map<String,Shipment__c>();               
        Set<String> Ship_IdList = new Set<String>();        
        Set<String> CDIdList = new Set<String>();
        Map<String,String> recordMap = new Map<String,String>();
        for (ContentDocumentLink fileLink : fileLinks) 
        {
            recordMap.put(fileLink.ContentDocumentId,fileLink.LinkedEntityId);
            CDIdList.add(fileLink.ContentDocumentId);
            Ship_IdList.add(fileLink.LinkedEntityId);            
        }
        
        Map<Id,Shipment__c> ShipMap = new Map<Id,Shipment__c>([select Id,Azure_IsFileUpload__c,Azure_File_UploadUrl__c from Shipment__c where Id IN :Ship_IdList and Azure_IsFileUpload__c=false]);
        
        if(CDIdList.size()>0)
        {
            List<ContentVersion> cvFiles = [SELECT Id,ContentDocumentId, VersionData, Title,FileType FROM ContentVersion WHERE ContentDocumentId IN: CDIdList];
            if(cvFiles.size()>0)
            {
                for(ContentVersion cv:cvFiles)
                { 
                    try {
                        // Generate the Azure Blob Storage URL
                        String fileName= cv.Title;
                        fileName = fileName.replace(' ', '_');                        
                        String parentId = recordMap.get(cv.ContentDocumentId);                        
                        String blobEndpoint = 'https://' + 'bvcstorageos' + '.blob.core.windows.net/ salesforcefiles/' + ObjectName + '/' + parentId + '/' + fileName;
                        System.debug('fileName :'+fileName);
                        fileName = fileName+'_'+parentId; // newly added on Jan 2025
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
                        req.setHeader('Content-Type', 'application/'+cv.FileType);
                        req.setBodyAsBlob(cv.VersionData);
                        // Send the HTTP request
                        Http http = new Http();
                        HttpResponse res = http.send(req);
                        if (res.getStatusCode() == 201) {
                            if (Ex_ShipMap.containsKey(parentId))
                            {
                                Shipment__c singleRecord =  Ex_ShipMap.get(parentId);                                   
                                singleRecord.Azure_File_UploadUrl__c+=' ; '+endPoint;
                                singleRecord.Azure_IsFileUpload__c = true;
                            }
                            else
                            {
                                Shipment__c singleRecord =  ShipMap.get(parentId);  
                                if(singleRecord!=null)
                                {                                        
                                    singleRecord.Azure_File_UploadUrl__c=endPoint;
                                    singleRecord.Azure_IsFileUpload__c = true;
                                    Ex_ShipMap.put(singleRecord.Id,singleRecord);
                                }
                            }                                                         
                        } else {
                        }
                    } catch (Exception e) {
                    }
                }
            }
        }
        try
        {
            if(Ex_ShipMap.size()>0)
            {
                List<Shipment__c> ShipmentToUpdate = new List<Shipment__c>(Ex_ShipMap.values());
                Database.update(ShipmentToUpdate, false);
            }            
        } catch(Exception e)
        {
            
        }     
    }
    global void finish(Database.BatchableContext bc)
    {
    }
}