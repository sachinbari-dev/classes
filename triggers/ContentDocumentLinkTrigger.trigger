trigger ContentDocumentLinkTrigger on ContentDocumentLink (after insert,before delete,before insert) 
{
    // storing Delivery Related CDL records
    List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
    // storing SecureBag Related CDL records
    List<ContentDocumentLink> cdlList1 = new List<ContentDocumentLink>();
    
    List<ContentDocumentLink> cdlList3 = new List<ContentDocumentLink>();
    List<ContentDocumentLink> cdlList5 = new List<ContentDocumentLink>();
    
    List<ContentDocumentLink> cdlListForAccount = new List<ContentDocumentLink>();
    if(trigger.isInsert && trigger.isAfter)
    {
        for(ContentDocumentLink cdl:trigger.new)
        {
            System.debug('<====== Inside ContentDocumentLinkTrigger ======>');
            Schema.SObjectType sh = Schema.Delivery__c.getSObjectType();
            Schema.SObjectType record = cdl.LinkedEntityId.getsobjecttype();        
            if(sh==record)
            {
                System.debug('Collecting Delivery Related CDL');
                cdlList.add(cdl);
            }  
            // added on 10-06-2025
            Schema.SObjectType accountType = Schema.Account.getSObjectType();
            Schema.SObjectType AccountRecordType = cdl.LinkedEntityId.getsobjecttype();
            if(accountType == AccountRecordType)
            {
               cdlListForAccount.add(cdl); 
            }
            // upto here added
            Schema.SObjectType sb = Schema.Secure_Bag__c.getSObjectType();
            Schema.SObjectType sbRec = cdl.LinkedEntityId.getsobjecttype();             
            if(sb==sbRec)
            {
                System.debug('<====== Collecting SB Related CDL records ======>');
                cdlList1.add(cdl);
            }              

            Schema.SObjectType ship = Schema.Shipment__c.getSObjectType();
            Schema.SObjectType shipRec = cdl.LinkedEntityId.getsobjecttype();             
            if(ship==shipRec)
            {
                System.debug('<====== Collecting shipRec Related CDL records ======>');
                cdlList3.add(cdl);
            }               
        }

    }
            // added on 10-06-2025

    if(cdlListForAccount.size()>0)
    {        
        System.debug('Found Delivery Related CDL Records');
        ContentDocumentLinkTriggerHelper.updateAccountLink(cdlListForAccount);
    }    
            // upto here added    
    if(cdlList.size()>0)
    {        
        System.debug('Found Delivery Related CDL Records');
        ContentDocumentLinkTriggerHelper.Perform(cdlList);
    }  
    if(cdlList1.size()>0)
    {
        System.debug('Found SB Related CDL Records');
        ContentDocumentLinkTriggerHelper.updateSBPod(cdlList1);
    }
    if(cdlList3.size()>0)
    {
        System.debug('Found SHIP Related CDL Records cdlList3:'+cdlList3);
        ContentDocumentLinkTriggerHelper.updateShip(cdlList1);
    }    
}