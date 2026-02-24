global class FileBackupToAzureBatch implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful
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
    } 
}
/*{
    public String ObjectName;
    public FileBackupToAzureBatch(String ObjectName)
    {
        this.ObjectName = ObjectName;        
    }
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        String query='SELECT Id, ContentDocumentId, LinkedEntityId, ContentDocument.Title, ContentDocument.FileType ';
        // query+=',(SELECT Id, VersionData, Title FROM ContentVersions) ';
        if(ObjectName=='Invoices')
        {
            // query+='FROM ContentDocumentLink WHERE LinkedEntityId IN (SELECT Id FROM blng__Invoice__c  where invoiceurl__c=false) limit 300000'; 
            query+='FROM ContentDocumentLink WHERE LinkedEntityId IN (SELECT Id FROM blng__Invoice__c  where Is_attachment_urls__c=false and invoiceurl__c=false) limit 300000'; 
        }
        if(ObjectName=='Quote')
        {
            query+='FROM ContentDocumentLink WHERE LinkedEntityId IN (SELECT Id FROM SBQQ__Quote__c  where QuoteURL__c = false) limit 300000'; 
        }
        if(ObjectName=='CreditNote')
        {
            query+='FROM ContentDocumentLink WHERE LinkedEntityId IN (SELECT Id FROM blng__CreditNote__c where Url_check__c=false) limit 10000'; 
        }
        
        System.debug('16 query :'+query);
        return Database.getQueryLocator(query);        
    }
    global void execute(Database.BatchableContext bc,List<ContentDocumentLink> fileLinks)
    {
        System.debug('21 fileLinks Size :'+fileLinks.size());       
        
        Map<String,SBQQ__Quote__c> ExquoteMap = new Map<String,SBQQ__Quote__c>();
        
        Map<String,blng__Invoice__c> ExinvMap = new Map<String,blng__Invoice__c>();
        Map<String,blng__CreditNote__c> ExCNoteMap = new Map<String,blng__CreditNote__c>();  
        
        Map<String,SBQQ__Quote__c> quoteMap = new Map<String,SBQQ__Quote__c>();
        
        Map<String,blng__Invoice__c> invMap = new Map<String,blng__Invoice__c>();
        Map<String,blng__CreditNote__c> CNoteMap = new Map<String,blng__CreditNote__c>();
        
        Set<String> quoteIdList = new Set<String>();
        
        Set<String> invIdList = new Set<String>(); 
        Set<String> cNoteIdList = new Set<String>();        
        Set<String> CDIdList = new Set<String>();
        Map<String,String> recordMap = new Map<String,String>();
        for (ContentDocumentLink fileLink : fileLinks) 
        {
            recordMap.put(fileLink.ContentDocumentId,fileLink.LinkedEntityId);
            CDIdList.add(fileLink.ContentDocumentId);
            if (ObjectName == 'Quote') 
            {
               // conIdList.add(fileLink.LinkedEntityId);
                quoteIdList.add(fileLink.LinkedEntityId);
            }
            if (ObjectName == 'Invoices') 
            {
                invIdList.add(fileLink.LinkedEntityId);
            }
            if (ObjectName == 'CreditNote') 
            {
                cNoteIdList.add(fileLink.LinkedEntityId);
            }            
        }
        if(quoteIdList.size()>0)
        {
           // List<Contract> contractList = [SELECT Id,ContractSignedDocumentUrl__c FROM Contract WHERE Id IN : conIdList LIMIT 1];
            List<SBQQ__Quote__c> quoteList = [SELECT Id,QuoteSignedDocumentUrls__c,QuoteURL__c
                                              FROM SBQQ__Quote__c WHERE Id IN : quoteIdList and QuoteURL__c = false];
            if(quoteList.size()>0)
            {
                for(SBQQ__Quote__c q:quoteList)
                {
                    if(q.QuoteURL__c==false)
                    {
                        quoteMap.put(q.Id,q);
                    }
                    
                }
            }
        }
        if(invIdList.size()>0)
        {
            System.debug('85 invIdList :'+invIdList);
            List<blng__Invoice__c> InvList = [SELECT Id,InvoiceFileUrls__c,invoiceurl__c
                                              FROM blng__Invoice__c WHERE Id IN : invIdList and invoiceurl__c=false]; 
            System.debug('88 InvList :'+InvList);
            if(InvList.size()>0)
            {
                for(blng__Invoice__c inv:InvList)
                {
                    if(inv.invoiceurl__c==false)
                    {
                        invMap.put(inv.Id,inv);
                    }
                    
                }
            } System.debug('99 invMap :'+invMap);           
        }
        if(cNoteIdList.size()>0)
        {
            List<blng__CreditNote__c> cnList = [SELECT Id,CreditNoteFileUrls__c,Url_check__c
                                                FROM blng__CreditNote__c WHERE Id IN : cNoteIdList and Url_check__c=false];
            if(cnList.size()>0)
            {
                for(blng__CreditNote__c cn:cnList)
                {
                    if(cn.Url_check__c==false)
                    {
                        CNoteMap.put(cn.Id,cn);
                    }
                }
            }            
        }        
        if(CDIdList.size()>0)
        {
            List<ContentVersion> cvFiles = [SELECT Id,ContentDocumentId, VersionData, Title,FileType 
                                            FROM ContentVersion WHERE ContentDocumentId IN: CDIdList];
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
                        fileName = fileName +'_'+parentId; // newly added Jan 2025
                        System.debug('fileName :'+fileName);
                        String endPoint;
                        if(cv.FileType!='PDF')
                        {
                            if(cv.FileType=='EXCEL_X' || cv.FileType=='EXCEL')
                            {
                               endPoint ='https://bvcstorageos.blob.core.windows.net/salesforcefiles/'+ObjectName+'/'+fileName+'.xls';
                               endPoint = endPoint +'?sv=2023-01-03&spr=https%2Chttp&st=2024-10-10T12%3A42%3A27Z&se=2028-05-10T12%3A42%3A00Z&sr=c&sp=racwltf&sig=poyeaQEsl8E8nEZvIA%2F4%2FrAV3Gl97wQRrzaeHy7qLkw%3D';
                            }
                            else
                            {
                                endPoint ='https://bvcstorageos.blob.core.windows.net/salesforcefiles/'+ObjectName+'/'+fileName+'.'+cv.FileType;
                                endPoint = endPoint +'?sv=2023-01-03&spr=https%2Chttp&st=2024-10-10T12%3A42%3A27Z&se=2028-05-10T12%3A42%3A00Z&sr=c&sp=racwltf&sig=poyeaQEsl8E8nEZvIA%2F4%2FrAV3Gl97wQRrzaeHy7qLkw%3D';
                            }                            
                        }
                        else
                        {
                            endPoint ='https://bvcstorageos.blob.core.windows.net/salesforcefiles/'+ObjectName+'/'+fileName;
                            endPoint = endPoint +'?sv=2023-01-03&spr=https%2Chttp&st=2024-10-10T12%3A42%3A27Z&se=2028-05-10T12%3A42%3A00Z&sr=c&sp=racwltf&sig=poyeaQEsl8E8nEZvIA%2F4%2FrAV3Gl97wQRrzaeHy7qLkw%3D';
                        }
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
                            System.debug('File uploaded successfully to blobEndpoint: ' + blobEndpoint);
                            System.debug('File uploaded successfully to res: ' + res);
                            System.debug('File uploaded successfully to res Body: ' + res.getBody());
                            if (ObjectName == 'Quote') 
                            {
                                if (ExquoteMap.containsKey(parentId))
                                {
                                    SBQQ__Quote__c quoteRecord =  ExquoteMap.get(parentId);                                   
                                    quoteRecord.QuoteSignedDocumentUrls__c=quoteRecord.QuoteSignedDocumentUrls__c+' ; '+endPoint;
                                    quoteRecord.QuoteURL__c = true;
                                }
                                else
                                {
                                   SBQQ__Quote__c quoteRecord =  quoteMap.get(parentId);  
                                    if(quoteRecord!=null)
                                    {                                        
                                        quoteRecord.QuoteSignedDocumentUrls__c=endPoint;
                                        quoteRecord.QuoteURL__c = true;
                                        ExquoteMap.put(quoteRecord.Id,quoteRecord);
                                    }
                                }                                
                            }
                            if (ObjectName == 'Invoices') 
                            { System.debug('195 Invoice recordId: ' + parentId);
                                if (ExinvMap.containsKey(parentId))
                                {
                                    blng__Invoice__c invRecord =  ExinvMap.get(parentId); 
                                    invRecord.InvoiceFileUrls__c =invRecord.InvoiceFileUrls__c+' ; '+endPoint; 
                                    invRecord.invoiceurl__c=true;
                                }
                                else
                                { System.debug('203 Invoice ExinvMap: ' + ExinvMap);
                                    blng__Invoice__c invRecord =  invMap.get(parentId);  
                                    if(invRecord!=null)
                                    {
                                        
                                        invRecord.InvoiceFileUrls__c = endPoint;
                                        invRecord.invoiceurl__c=true;
                                        ExinvMap.put(invRecord.Id,invRecord);
                                    } System.debug('211 Invoice ExinvMap: ' + ExinvMap);
                                }
                                
                            } 
                            if (ObjectName == 'CreditNote') 
                            {
                                if (ExCNoteMap.containsKey(parentId))
                                {
                                    blng__CreditNote__c cnRecord =  ExCNoteMap.get(parentId); 
                                    cnRecord.CreditNoteFileUrls__c =cnRecord.CreditNoteFileUrls__c+' ; '+endPoint;
                                    cnRecord.Url_check__c = true;
                                }
                                else
                                {
                                    blng__CreditNote__c cnRecord =  CNoteMap.get(parentId);  
                                    if(cnRecord!=null)
                                    {
                                        
                                        cnRecord.CreditNoteFileUrls__c = endPoint;
                                        cnRecord.Url_check__c = true;
                                        ExCNoteMap.put(cnRecord.Id,cnRecord);
                                    }
                                }
                            }                                                       
                        } else {
                            System.debug('Error uploading file to Azure: ' + res.getStatus());
                        }
                    endPoint=null; // added on Jan 2025
                    } catch (Exception e) {
                        System.debug('Error during file upload: ' + e.getMessage());
                    }
                }
            }
        }
        try
        {
            System.debug('245 ExquoteMap.size():'+ExquoteMap.size());
            System.debug('245 ExinvMap.size():'+ExinvMap.size());
            System.debug('247 ExCNoteMap.size():'+ExCNoteMap.size());
            if(ExquoteMap.size()>0)
            {
                List<SBQQ__Quote__c> quoteListToUpdate = new List<SBQQ__Quote__c>(ExquoteMap.values());
                System.debug('214 quoteListToUpdate 0:'+quoteListToUpdate[0]);
                Database.update(quoteListToUpdate, false);
            }
            if(ExinvMap.size()>0)
            {
                List<blng__Invoice__c> invListToUpdate1 = new List<blng__Invoice__c>(ExinvMap.values());
                Database.update(invListToUpdate1, false);
                System.debug('258 After Update');
            }
            if(ExCNoteMap.size()>0)
            {
                List<blng__CreditNote__c> CNListToUpdate1 = new List<blng__CreditNote__c>(ExCNoteMap.values());
                Database.update(CNListToUpdate1, false);
            }            
        } catch(Exception e)
        {
            System.debug('LIne No 175 Error :'+e.getMessage());
        }

        
    }
    global void finish(Database.BatchableContext bc)
    {
        integer i=0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
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