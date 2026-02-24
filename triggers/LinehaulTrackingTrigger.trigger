trigger LinehaulTrackingTrigger on Linehaul_Tracking__c (before insert,before update,after insert,after update,after delete,after undelete) {

    
    //before  opeartion
    if(Trigger.isBefore){
        //before insert
         if(Trigger.isInsert){
        
       }
        
        //before udpate 
        if(Trigger.isUpdate){
            
        }
    }
    
    //After operation
    
    if(Trigger.isAfter){
        
  //after insert operation
        
        if(Trigger.isInsert){
                       
           
        }
        
 //after update operation
        
        if(Trigger.isUpdate){
            
           
             Set<Id> linehaulIds = new Set<Id>();
            List<Linehaul__c> linehaulsToUpdate = new List<Linehaul__c>();
            
            for(Linehaul_Tracking__c tr : Trigger.new){
                  Linehaul_Tracking__c oldLt = Trigger.oldMap.get(tr.Id);
                if(tr.Trunks_Weight_Kgs__c != Null && tr.Trunks_Weight_Kgs__c != oldLt.Trunks_Weight_Kgs__c && tr.Linehaul_Type__c == 'Air'){
                    linehaulIds.add(tr.Linehaul_Name__c);
                    system.debug('LinehaulIDs@@@@@' + linehaulIds);
                }
                  
            }
            
                if(!linehaulIds.isEmpty()){
                    
                   for(Id lineId :  linehaulIds){
                        Linehaul__c ld = [select id, name,The_total_all_airline_packages_weight__c,(Select id,name,Trunks_Weight_Kgs__c  from Linehaul_Tracking__r) from Linehaul__c  where id =: lineId];
                        
                        Decimal totalPackagesWeight = 0;
                        for (Linehaul_Tracking__c lt : ld.Linehaul_Tracking__r) {
                            if(lt.Trunks_Weight_Kgs__c != Null ){
                                 totalPackagesWeight += lt.Trunks_Weight_Kgs__c;
                            }
                           
                       }
                    
                            ld.The_total_all_airline_packages_weight__c = totalPackagesWeight;
                            linehaulsToUpdate.add(ld);
                    }
                    
                    if(!linehaulsToUpdate.isEmpty()){
                        update linehaulsToUpdate;
                    }
                        
                }
                    
            
        }
        
        //after delete 
        if(Trigger.isDelete){
            
        }
        
       //after undelete 
        if(Trigger.isUndelete){
            
        }
    }
   
    
    
}