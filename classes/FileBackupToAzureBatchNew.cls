global class FileBackupToAzureBatchNew implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful
{
    public String ObjectName;
    public Integer limitedRecords=0;
    public FileBackupToAzureBatchNew(String ObjectName,Integer limitedRecords)
    {
        this.ObjectName = ObjectName;  
        this.limitedRecords = limitedRecords;
    }
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        String query='SELECT Id, ContentDocumentId, LinkedEntityId,LinkedEntity.Name  ';
        if(ObjectName=='Shipment')
        {
            query+='FROM ContentDocumentLink WHERE LinkedEntityId IN (SELECT Id FROM Shipment__c  where Azure_IsFileUpload__c=false) LIMIT ' + limitedRecords;
        }
        if(ObjectName=='CustomerDocument')
        {
            query+='FROM ContentDocumentLink WHERE LinkedEntityId IN (SELECT Id FROM Customer_Documents__c  where Azure_IsFileUpload__c = false) LIMIT ' + limitedRecords;
        }
        if(ObjectName=='SecureBag')
        {
            query+='FROM ContentDocumentLink WHERE LinkedEntityId IN (SELECT Id FROM Secure_Bag__c where Azure_IsFileUpload__c=false) LIMIT ' + limitedRecords;
        }
        if(ObjectName=='Delivery')
        {
            query+='FROM ContentDocumentLink WHERE LinkedEntityId IN (SELECT Id FROM Delivery__c where Azure_IsFileUpload__c=false) LIMIT ' + limitedRecords;
        }
        if(ObjectName=='Email')
        {
            query+='FROM ContentDocumentLink WHERE LinkedEntityId IN (SELECT Id FROM EmailMessage where Azure_IsFileUpload__c=false) LIMIT ' + limitedRecords;
        }   
        if(ObjectName=='Invoices')
        {
            query+='FROM ContentDocumentLink WHERE LinkedEntityId IN (SELECT Id FROM BVCInvoice__c where Azure_IsFileUpload__c=false) LIMIT ' + limitedRecords; 
        }         
        System.debug('16 query :'+query);
        return Database.getQueryLocator(query);        
    }
    global void execute(Database.BatchableContext bc,List<ContentDocumentLink> fileLinks)
    {
        Map<String,Shipment__c> Ex_ShipMap = new Map<String,Shipment__c>();        
        Map<String,Customer_Documents__c> Ex_CDMap = new Map<String,Customer_Documents__c>();
        Map<String,Secure_Bag__c> Ex_SBMap = new Map<String,Secure_Bag__c>(); 
        Map<String,Delivery__c> Ex_DelMap = new Map<String,Delivery__c>();
        Map<String,EmailMessage> Ex_EMMap = new Map<String,EmailMessage>(); 
        
        Map<String,BVCInvoice__c> Ex_INVMap = new Map<String,BVCInvoice__c>(); 
        
        Set<String> Ship_IdList = new Set<String>(); 
        Set<String> CD_IdList = new Set<String>(); 
        Set<String> SB_IdList = new Set<String>(); 
        Set<String> Del_IdList = new Set<String>(); 
        Set<String> EM_IdList = new Set<String>();
        
        Set<String> INV_IdList = new Set<String>(); 
        
        Set<String> CDIdList = new Set<String>();
        Map<String,String> recordMap = new Map<String,String>();
        
        Map<String,String> ParentRrecordNameMap = new Map<String,String>();
        
        for (ContentDocumentLink fileLink : fileLinks) 
        {
            recordMap.put(fileLink.ContentDocumentId,fileLink.LinkedEntityId);
            CDIdList.add(fileLink.ContentDocumentId);
            ParentRrecordNameMap.put(fileLink.ContentDocumentId,fileLink.LinkedEntity.Name);
            if (ObjectName == 'Shipment') { Ship_IdList.add(fileLink.LinkedEntityId); }
            if (ObjectName == 'CustomerDocument') { CD_IdList.add(fileLink.LinkedEntityId); }
            if (ObjectName == 'SecureBag') { SB_IdList.add(fileLink.LinkedEntityId); }
            if (ObjectName == 'Delivery') { Del_IdList.add(fileLink.LinkedEntityId); }
            if (ObjectName == 'Email') { EM_IdList.add(fileLink.LinkedEntityId); }
            if (ObjectName == 'Invoices') { INV_IdList.add(fileLink.LinkedEntityId); }
            
        }
        
        Map<Id,Shipment__c> ShipMap = new Map<Id,Shipment__c>([select Id,Azure_IsFileUpload__c,Azure_File_UploadUrl__c from Shipment__c where Id IN :Ship_IdList and Azure_IsFileUpload__c=false]);
        Map<Id,Customer_Documents__c> CDMap = new Map<Id,Customer_Documents__c>([select Id,Azure_IsFileUpload__c,Azure_File_UploadUrl__c from Customer_Documents__c where Id IN :CD_IdList and Azure_IsFileUpload__c=false]);
        Map<Id,Secure_Bag__c> SBMap = new Map<Id,Secure_Bag__c>([select Id,Azure_IsFileUpload__c,Azure_File_UploadUrl__c from Secure_Bag__c where Id IN :SB_IdList and Azure_IsFileUpload__c=false]);
        Map<Id,Delivery__c> DelMap = new Map<Id,Delivery__c>([select Id,Azure_IsFileUpload__c,Azure_File_UploadUrl__c from Delivery__c where Id IN :Del_IdList and Azure_IsFileUpload__c=false]);
        Map<Id,EmailMessage> EMMap = new Map<Id,EmailMessage>([select Id,Azure_IsFileUpload__c,Azure_File_UploadUrl__c from EmailMessage where Id IN :EM_IdList and Azure_IsFileUpload__c=false]);
        
        Map<Id,BVCInvoice__c> INVMap = new Map<Id,BVCInvoice__c>([select Id,Azure_IsFileUpload__c,Azure_File_UploadUrl__c from BVCInvoice__c where Id IN :INV_IdList and Azure_IsFileUpload__c=false]);
        
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
						String ParentRecordName = ParentRrecordNameMap.get(cv.ContentDocumentId);                       
                        //String blobEndpoint = 'https://' + 'bvcstorageos' + '.blob.core.windows.net/ salesforcefiles/' + ObjectName + '/' + parentId + '/' + fileName;
                        System.debug('fileName :'+fileName);
                        // fileName = fileName+'_'+parentId;
                        fileName = fileName+'_'+cv.Id+'_'+ParentRecordName;
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
                            if (ObjectName == 'Shipment') 
                            {
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
                            }
                            
                            if (ObjectName == 'Invoices') 
                            {
                                if (Ex_INVMap.containsKey(parentId))
                                {
                                    BVCInvoice__c singleRecord =  Ex_INVMap.get(parentId);                                   
                                    singleRecord.Azure_File_UploadUrl__c+=' ; '+endPoint;
                                    singleRecord.Azure_IsFileUpload__c = true;
                                }
                                else
                                {
                                    BVCInvoice__c singleRecord =  INVMap.get(parentId);  
                                    if(singleRecord!=null)
                                    {                                        
                                        singleRecord.Azure_File_UploadUrl__c=endPoint;
                                        singleRecord.Azure_IsFileUpload__c = true;
                                        Ex_INVMap.put(singleRecord.Id,singleRecord);
                                    }
                                }                                
                            }
                            
                            if (ObjectName == 'CustomerDocument') 
                            {
                                if (Ex_CDMap.containsKey(parentId))
                                {
                                    Customer_Documents__c singleRecord =  Ex_CDMap.get(parentId);                                   
                                    singleRecord.Azure_File_UploadUrl__c+=' ; '+endPoint;
                                    singleRecord.Azure_IsFileUpload__c = true;
                                }
                                else
                                {
                                    Customer_Documents__c singleRecord =  CDMap.get(parentId);  
                                    if(singleRecord!=null)
                                    {                                        
                                        singleRecord.Azure_File_UploadUrl__c=endPoint;
                                        singleRecord.Azure_IsFileUpload__c = true;
                                        Ex_CDMap.put(singleRecord.Id,singleRecord);
                                    }
                                }                                
                            }
                            if (ObjectName == 'SecureBag') 
                            {
                                if (Ex_SBMap.containsKey(parentId))
                                {
                                    Secure_Bag__c singleRecord =  Ex_SBMap.get(parentId);                                   
                                    singleRecord.Azure_File_UploadUrl__c+=' ; '+endPoint;
                                    singleRecord.Azure_IsFileUpload__c = true;
                                }
                                else
                                {
                                    Secure_Bag__c singleRecord =  SBMap.get(parentId);  
                                    if(singleRecord!=null)
                                    {                                        
                                        singleRecord.Azure_File_UploadUrl__c=endPoint;
                                        singleRecord.Azure_IsFileUpload__c = true;
                                        Ex_SBMap.put(singleRecord.Id,singleRecord);
                                    }
                                }                                
                            }
                            if (ObjectName == 'Delivery') 
                            {
                                if (Ex_DelMap.containsKey(parentId))
                                {
                                    Delivery__c singleRecord =  Ex_DelMap.get(parentId);                                   
                                    singleRecord.Azure_File_UploadUrl__c+=' ; '+endPoint;
                                    singleRecord.Azure_IsFileUpload__c = true;
                                }
                                else
                                {
                                    Delivery__c singleRecord =  DelMap.get(parentId);  
                                    if(singleRecord!=null)
                                    {                                        
                                        singleRecord.Azure_File_UploadUrl__c=endPoint;
                                        singleRecord.Azure_IsFileUpload__c = true;
                                        Ex_DelMap.put(singleRecord.Id,singleRecord);
                                    }
                                }                                
                            }
                            if (ObjectName == 'Email') 
                            {
                                if (Ex_EMMap.containsKey(parentId))
                                {
                                    EmailMessage singleRecord =  Ex_EMMap.get(parentId);                                   
                                    singleRecord.Azure_File_UploadUrl__c+=' ; '+endPoint;
                                    singleRecord.Azure_IsFileUpload__c = true;
                                }
                                else
                                {
                                    EmailMessage singleRecord =  EMMap.get(parentId);  
                                    if(singleRecord!=null)
                                    {                                        
                                        singleRecord.Azure_File_UploadUrl__c=endPoint;
                                        singleRecord.Azure_IsFileUpload__c = true;
                                        Ex_EMMap.put(singleRecord.Id,singleRecord);
                                    }
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
            if(Ex_INVMap.size()>0)
            {
                List<BVCInvoice__c> INVToUpdate = new List<BVCInvoice__c>(Ex_INVMap.values());
                Database.update(INVToUpdate, false);
            }
            
            if(Ex_ShipMap.size()>0)
            {
                List<Shipment__c> ShipmentToUpdate = new List<Shipment__c>(Ex_ShipMap.values());
                Database.update(ShipmentToUpdate, false);
            }
            if(Ex_CDMap.size()>0)
            {
                List<Customer_Documents__c> CDListToUpdate1 = new List<Customer_Documents__c>(Ex_CDMap.values());
                Database.update(CDListToUpdate1, false);
            }
            if(Ex_SBMap.size()>0)
            {
                List<Secure_Bag__c> SBListToUpdate1 = new List<Secure_Bag__c>(Ex_SBMap.values());
                Database.update(SBListToUpdate1, false);
            }   
            if(Ex_DelMap.size()>0)
            {
                List<Delivery__c> DLListToUpdate1 = new List<Delivery__c>(Ex_DelMap.values());
                Database.update(DLListToUpdate1, false);
            }
            if(Ex_EMMap.size()>0)
            {
                List<EmailMessage> EMListToUpdate1 = new List<EmailMessage>(Ex_EMMap.values());
                Database.update(EMListToUpdate1, false);
            }             
        } catch(Exception e)
        {

        }     
    }
    global void finish(Database.BatchableContext bc)
    {
    }
}