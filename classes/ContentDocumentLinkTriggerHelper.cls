public class ContentDocumentLinkTriggerHelper 
{
    // added on 10-06-2025
     public static void updateAccountLink(List<ContentDocumentLink> cdlList)
    {
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        Boolean isSandBox = baseUrl.contains('.sandbox.')?true:false;
        
        Map<String,ContentDocumentLink> CDLMap = new Map<String,ContentDocumentLink>();        
        Map<String,Account> accountMap = new Map<String,Account>();
        List<Account> AcListToUpdate = new List<Account>();
        Set<String> accountIdList = new Set<String>();
		for(ContentDocumentLink cdl:cdlList)
        {
            CDLMap.put(cdl.ContentDocumentId,cdl);
            accountIdList.add(cdl.LinkedEntityId);
        }
        List<Account> acList = [select Id,Subrogation_File__c from Account where Id IN :accountIdList];
        for(Account ac : acList)
        {
            accountMap.put(ac.Id,ac);
        }
        String policyType = '%policy%';
        String InsuranceType = '%Insurance%';
        
        List<ContentDocument> cdocList = [select Title from ContentDocument 
                                          where Id IN : CDLMap.keySet() and FileType =: 'PDF' and (Title LIKE : policyType OR Title LIKE : InsuranceType) ];        
        
        if(cdocList.size()>0)
        {
            for(ContentDocument cd: cdocList)
            {
                ContentDocumentLink cdLinkRecord = CDLMap.get(cd.Id);
                if(cdLinkRecord!=null)
                {
                    Account accountFRecord = accountMap.get(cdLinkRecord.LinkedEntityId);
                    String sabBoxUrl = 'https://bvc2--bvcuat.sandbox.lightning.force.com/lightning/r/ContentDocument/';
                    String ProductUrl='https://bvc2.lightning.force.com/lightning/r/ContentDocument/';
                    String LinkUrl =isSandBox?sabBoxUrl:ProductUrl;
                    LinkUrl+=cdLinkRecord.ContentDocumentId+'/view';
                    accountFRecord.Subrogation_File__c=LinkUrl;
                    AcListToUpdate.add(accountFRecord);                    
                }
            }
        }
        if(AcListToUpdate.size()>0)
        {
            update AcListToUpdate;
        }
    }
    // upto here added on 10-06-2025
    public static void Perform(List<ContentDocumentLink> cdlList)
    {
        System.debug('<====== Inside ContentDocumentLinkTriggerHelper ======>');
        List<Delivery__c> DList = new List<Delivery__c>();
        List<Shipment__c> ShipList = new List<Shipment__c>();
        for(ContentDocumentLink cdl :cdlList)
        {             
            System.debug('cdl.ContentDocumentId :'+cdl.ContentDocumentId);        
            Delivery__c d = [select Id,POD__c,POD_Link_Url__c,Shipment__c from Delivery__c where Id=:cdl.LinkedEntityId limit 1];
            //Shipment__c ship = [select Id,POD__c from Shipment__c where Id=:d.Shipment__c limit 1];
            //ContentVersion cv = [select ContentDocumentId,Versiondataurl from ContentVersion where ContentDocumentId =: cdl.ContentDocumentId limit 1]  ;
			//System.debug('CV :'+cv.Versiondataurl); 
            //ContentDistribution cd = [select ContentDownloadUrl, DistributionPublicUrl from ContentDistribution where ContentDocumentId=:cv.ContentDocumentId limit 1];                       
           // System.debug('ContentDownloadUrl  :'+cd.ContentDownloadUrl);            
           // System.debug('DistributionPublicUrl :'+cd.DistributionPublicUrl);            
            System.debug('ContentDocumentLinkTriggerHelper D :'+d);            
            //d.POD_Link_Url__c = cd.ContentDownloadurl;
          // d.POD_Link_Url__c = cv.Versiondataurl;
            d.POD__c = true; 
           // ship.POD__c = true;
            DList.add(d);
            //ShipList.add(ship);
        }
        if(DList.size()>0)
        {
            System.debug('28 888888888 Update Ddelivery ob 11');
            try
            {
                update DList;
                System.debug('32 222222222222222 Update DList :'+DList);
            }catch(exception e)
            {
               System.debug('34 4444444444 ERROR :'+e.getMessage()) ;
            }
           
            System.debug('3000000000 Update Ddelivery ob 11');
        }
        if(ShipList.size()>0)
        {
           // update ShipList;
        }
    }
    public static void updateSBPod(List<ContentDocumentLink> cdlList)
    {
        System.debug('<====== Inside ContentDocumentLinkTriggerHelper ======>');
        List<Secure_Bag__c> SBList = new List<Secure_Bag__c>();
        List<Shipment__c> ShipList1 = new List<Shipment__c>();
        for(ContentDocumentLink cdl :cdlList)
        {            
            //ContentDistribution cd = [select ContentDownloadurl from ContentDistribution where ContentDocumentId=: cdl.ContentDocumentId limit 1];
            //System.debug('ContentDocumentLinkTriggerHelper CD :'+cd);    
            System.debug('cdl.ContentDocumentId :'+cdl.ContentDocumentId);        
            Secure_Bag__c sb = [select Id,POD__c,Shipment__c from Secure_Bag__c where Id=:cdl.LinkedEntityId limit 1];
            Shipment__c ship = [select Id,SecurebagPhoto__c from Shipment__c where Id=:sb.Shipment__c limit 1];
            System.debug('ContentDocumentLinkTriggerHelper D :'+sb); 
            System.debug('ContentDocumentLinkTriggerHelper ship :'+ship); 
            // d.POD_Link_Url__c = cd.ContentDownloadurl;
            sb.POD__c = true; 
            SBList.add(sb);
            ship.SecurebagPhoto__c = true;
            ShipList1.add(ship);
            
        }
        if(SBList.size()>0)
        {
            update SBList;
            if(ShipList1.size()>0)
            {
                System.debug('SHIPMENT UPLOAD');
                //update ShipList1;
            } 
        }
        
    }  
    
    public static void updateShip(List<ContentDocumentLink> cdlList)
    {
        System.debug('<====== Inside updateShip ======>');
         System.debug('<====== Inside updateShip ======> cdlList :'+cdlList);
        List<Shipment__c> ShipList1 = new List<Shipment__c>();
        for(ContentDocumentLink cdl :cdlList)
        {   
            System.debug('cdl.ContentDocumentId :'+cdl.ContentDocumentId);             
            ContentDocument cdoc = [select Title from ContentDocument where Id=:cdl.ContentDocumentId limit 1];
            System.debug('cdl.cdoc :'+cdoc);
            if(cdoc.title.contains('Signature'))
            {
                System.debug('Signature Matches Here');                
                Shipment__c ship = [select Id,SignaturePhoto__c from Shipment__c where Id=:cdl.LinkedEntityId limit 1];
                System.debug('ContentDocumentLinkTriggerHelper ship :'+ship); 
                ship.SignaturePhoto__c = true;
                ShipList1.add(ship);                
            }
        }
        if(ShipList1.size()>0)
        {
            System.debug('SHIPMENT UPLOAD');
            update ShipList1;
        }      
    }      
}