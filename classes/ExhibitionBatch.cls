/*Class      : SendEmailController
 *Author     : Sanket.pisal@bvclogistics.com
 *Date       : Jan 2024
 */

global class ExhibitionBatch implements Database.Batchable<sobject>,Database.stateful{

    
    global Database.Querylocator start(database.batchableContext bc){
        
        string query = 'Select id, Origin_Address_Name__c,Destination_Address_Name__c from shipment__c where Origin_Address_Name__c != null AND Destination_Address_Name__c != null ';
        system.debug('query@@@@'+ query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(database.batchableContext bc, List<shipment__c> shipList){
        set<id> addressIDs = new set<id>();
        
        
        for(Shipment__c sp:shipList ){
            addressIDs.add(sp.Origin_Address_Name__c);
            addressIDs.add(sp.Destination_Address_Name__c);
        }
        set<id> exihibtionAddressids = new set<id>();
        set<id>  exhibiId = new set<id>();
        
        List<AddressBook__c> addList = [select id,Is_Exhibitions__c,Exhibition__c from AddressBook__c where ID IN :addressIDs AND Is_Exhibitions__c = true ];
        system.debug('addressbook@@@'+ addList);
         
     
        for(AddressBook__c ad : addList ){
            exihibtionAddressids.add(ad.id);
            exhibiId.add(ad.Exhibition__c);
        }
        
        ST_Exhibition__c ex =[select id from ST_Exhibition__c where id IN :exhibiId LIMIT 1];
        
        for(shipment__c s : shipList){
            if(exihibtionAddressids.contains(s.Origin_Address_Name__c) ){
                s.IsExhibition__c = true;
               s.Exhibition_Movement_Type__c = 'Outward';
               s.Exhibition__c = ex.id;
            }
            if(exihibtionAddressids.contains(s.Destination_Address_Name__c)){
                s.IsExhibition__c = true;
                s.Exhibition_Movement_Type__c = 'Inward';
                s.Exhibition__c = ex.id;
            }
        }
        update shipList;
        
    }
    global void finish(database.batchableContext bc){
        
    }
}