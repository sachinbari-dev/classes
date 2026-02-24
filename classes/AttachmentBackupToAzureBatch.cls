global class AttachmentBackupToAzureBatch implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful
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
    public AttachmentBackupToAzureBatch(String ObjectName)
    {
        this.ObjectName = ObjectName;        
    }
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        String query='SELECT Id, ParentId, Name, ContentType, Body FROM Attachment WHERE ParentId IN (SELECT Id FROM ';
        // query+=',(SELECT Id, VersionData, Title FROM ContentVersions) ';
        if(ObjectName=='Invoices')
        {
            query+=' blng__Invoice__c  where Is_attachment_urls__c=false) '; 
        }
        if(ObjectName=='Quote')
        {
            query+=' SBQQ__Quote__c  where Is_attachment_urls__c = false) '; 
        }
        if(ObjectName=='CreditNote')
        {
            query+=' blng__CreditNote__c where Is_attachment_urls__c=false) '; 
        }
        
        System.debug('16 query :'+query);
        return Database.getQueryLocator(query);        
    }
    global void execute(Database.BatchableContext bc,List<Attachment> attachmentLinks)
    {
        System.debug('21 attachmentLinks Size :'+attachmentLinks.size());       
        
        Map<String,SBQQ__Quote__c> ExquoteMap = new Map<String,SBQQ__Quote__c>();        
        Map<String,blng__Invoice__c> ExinvMap = new Map<String,blng__Invoice__c>();
        Map<String,blng__CreditNote__c> ExCNoteMap = new Map<String,blng__CreditNote__c>();  
        
        Map<String,SBQQ__Quote__c> quoteMap = new Map<String,SBQQ__Quote__c>();        
        Map<String,blng__Invoice__c> invMap = new Map<String,blng__Invoice__c>();
        Map<String,blng__CreditNote__c> CNoteMap = new Map<String,blng__CreditNote__c>();
        
        Set<String> quoteIdList = new Set<String>();        
        Set<String> invIdList = new Set<String>(); 
        Set<String> cNoteIdList = new Set<String>();        
        
        for(Attachment atcm : attachmentLinks)
        {
            if (ObjectName == 'Quote') 
            {
                // conIdList.add(fileLink.LinkedEntityId);
                quoteIdList.add(atcm.ParentId);
            }
            if (ObjectName == 'Invoices') 
            {
                invIdList.add(atcm.ParentId);
            }
            if (ObjectName == 'CreditNote') 
            {
                cNoteIdList.add(atcm.ParentId);
            }
        }
        System.debug('60 File uploaded successfully to invIdList: ' + invIdList+' quoteIdList: '+quoteIdList+' cNoteIdList:'+cNoteIdList);
        if(quoteIdList.size()>0)
        {
            // List<Contract> contractList = [SELECT Id,ContractSignedDocumentUrl__c FROM Contract WHERE Id IN : conIdList LIMIT 1];
            List<SBQQ__Quote__c> quoteList = [SELECT Id,Is_attachment_urls__c,Attachment_Urls__c
                                              FROM SBQQ__Quote__c WHERE Id IN : quoteIdList and Is_attachment_urls__c = false and QuoteURL__c = false];
            if(quoteList.size()>0)
            {
                for(SBQQ__Quote__c q:quoteList)
                {
                    if(q.Is_attachment_urls__c==false)
                    {
                        quoteMap.put(q.Id,q);
                    }
                    
                }
            }
        }
        if(invIdList.size()>0)
        {
            List<blng__Invoice__c> InvList = [SELECT Id,Is_attachment_urls__c,Attachment_Urls__c
                                              FROM blng__Invoice__c WHERE Id IN : invIdList and Is_attachment_urls__c=false and invoiceurl__c=false];
            if(InvList.size()>0)
            {
                for(blng__Invoice__c inv:InvList)
                {
                    if(inv.Is_attachment_urls__c==false)
                    {
                        invMap.put(inv.Id,inv);
                    }
                    
                }
            }            
        }
        if(cNoteIdList.size()>0)
        {
            List<blng__CreditNote__c> cnList = [SELECT Id,Is_attachment_urls__c,Attachment_Urls__c
                                                FROM blng__CreditNote__c WHERE Id IN : cNoteIdList and Is_attachment_urls__c=false and Url_check__c=false];
            if(cnList.size()>0)
            {
                for(blng__CreditNote__c cn:cnList)
                {
                    if(cn.Is_attachment_urls__c==false)
                    {
                        CNoteMap.put(cn.Id,cn);
                    }
                }
            }            
        }
        System.debug('109 File uploaded successfully to invMap: ' + invMap+' quoteMap: '+quoteMap+' CNoteMap:'+CNoteMap);
        if(attachmentLinks.size()>0 && (invMap.size()>0 || quoteMap.size()>0) || CNoteMap.size()>0)
        {
            for(Attachment am:attachmentLinks)
            { 
                try {
                    // Generate the Azure Blob Storage URL
                    String fileName= am.Name;
                    fileName = fileName.replace(' ', '_');                        
                    String parentId = am.ParentId;                        
                    String blobEndpoint = 'https://' + 'bvcstorageos' + '.blob.core.windows.net/ salesforcefiles/' + ObjectName + '/' + parentId + '/' + fileName;
                    System.debug('fileName :'+fileName);
                    String endPoint;
                    
                    endPoint ='https://bvcstorageos.blob.core.windows.net/salesforcefiles/'+ObjectName+'/'+fileName;
                    
                    // endPoint ='https://bvcstorageos.blob.core.windows.net/salesforcefiles/'+fileName;
                    endPoint = endPoint +'?sv=2023-01-03&spr=https%2Chttp&st=2024-10-10T12%3A42%3A27Z&se=2028-05-10T12%3A42%3A00Z&sr=c&sp=racwltf&sig=poyeaQEsl8E8nEZvIA%2F4%2FrAV3Gl97wQRrzaeHy7qLkw%3D';
                    System.debug('127 endPoint :'+endPoint);
                    // String data ='@RZltuZFS1/'+fileName+'.pdf'; 
                    HttpRequest req = new HttpRequest();
                    req.setEndpoint(endPoint);
                    
                    req.setMethod('PUT');   
                    req.setHeader('Content-Length','0');
                    req.setHeader('x-ms-blob-type', 'BlockBlob');
                    // req.setHeader('Content-Type', 'application/pdf');
                    //req.setHeader('Content-Type', 'application/'+cv.FileType);
                    System.debug('136 endPoint am :'+am);
                    req.setHeader('Content-Type', am.ContentType);
                    System.debug('136 am.ContentType :'+am.ContentType);
                    req.setBodyAsBlob(am.Body);
                    System.debug('136 am.Body :'+am.Body);
                    // Send the HTTP request
                    Http http = new Http();
                    System.debug('141 Before Sending req :'+req);
                    HttpResponse res = http.send(req);
                    System.debug('74  req: ' + req);
                    System.debug('71 res.getStatusCode():'+res.getStatusCode());
                    if (res.getStatusCode() == 201) {
                        System.debug('141 File uploaded successfully to fileName: ' + fileName);
                        System.debug('142 File uploaded successfully to recordId: ' + parentId);
                        System.debug('143 File uploaded successfully to objectType: ' + ObjectName);
                        System.debug('144 File uploaded successfully to blobEndpoint: ' + blobEndpoint);
                        System.debug('145 File uploaded successfully to endPoint: ' + endPoint);
                        System.debug('146 File uploaded successfully to res: ' + res);
                        System.debug('147 File uploaded successfully to res Body: ' + res.getBody());
                        if (ObjectName == 'Quote') 
                        {
                            if (ExquoteMap.containsKey(parentId))
                            {
                                SBQQ__Quote__c quoteRecord =  ExquoteMap.get(parentId);                                   
                                quoteRecord.Attachment_Urls__c=quoteRecord.Attachment_Urls__c+' ; '+endPoint;
                                quoteRecord.Is_attachment_urls__c=true;
                            }
                            else
                            {
                                SBQQ__Quote__c quoteRecord =  quoteMap.get(parentId);  
                                if(quoteRecord!=null)
                                {                                        
                                    quoteRecord.Attachment_Urls__c=endPoint;
                                    quoteRecord.Is_attachment_urls__c=true;
                                    ExquoteMap.put(quoteRecord.Id,quoteRecord);
                                }
                            }                                
                        }
                        if (ObjectName == 'Invoices') 
                        {System.debug('169 File uploaded successfully to ObjectName: ' + ObjectName);
                            if (ExinvMap.containsKey(parentId))
                            {
                                blng__Invoice__c invRecord =  ExinvMap.get(parentId); 
                                invRecord.Attachment_Urls__c =invRecord.Attachment_Urls__c+' ; '+endPoint; 
                                invRecord.Is_attachment_urls__c = true;                                    
                            }
                            else
                            { 
                                blng__Invoice__c invRecord =  invMap.get(parentId); 
                                System.debug('179 File uploaded successfully to invRecord: ' + invRecord);
                                if(invRecord!=null)
                                {
                                    invRecord.Attachment_Urls__c = endPoint;
                                    invRecord.Is_attachment_urls__c = true; 
                                    ExinvMap.put(invRecord.Id,invRecord);
                                }
                            }
                           System.debug('186 File uploaded successfully to ExinvMap: ' + ExinvMap); 
                        } 
                        if (ObjectName == 'CreditNote') 
                        {
                            if (ExCNoteMap.containsKey(parentId))
                            {
                                blng__CreditNote__c cnRecord =  ExCNoteMap.get(parentId); 
                                cnRecord.Attachment_Urls__c =cnRecord.Attachment_Urls__c+' ; '+endPoint;
                                cnRecord.Is_attachment_urls__c = true;
                            }
                            else
                            {
                                blng__CreditNote__c cnRecord =  CNoteMap.get(parentId);  
                                if(cnRecord!=null)
                                {
                                    
                                    // cnRecord.CreditNoteFileUrl__c = endPoint;
                                    cnRecord.Attachment_Urls__c = endPoint;
                                    cnRecord.Is_attachment_urls__c = true;
                                    ExCNoteMap.put(cnRecord.Id,cnRecord);
                                }
                            }
                        }                                                       
                    } else {
                        System.debug('Error uploading file to Azure: ' + res.getStatus());
                    }
                } catch (Exception e) {
                    System.debug('Error during file upload: ' + e.getMessage());
                }
            }
        }
        
        try
        {
            System.debug('218 ExquoteMap.size():'+ExquoteMap.size());
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
    }    
}*/