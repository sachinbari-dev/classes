trigger LinehaulTrigger on Linehaul__c (before insert,before update,after insert,after update,after delete,after undelete) {

      if(Trigger.isBefore){
        //before insert
         if(Trigger.isInsert){
            LinehaulAWBprefixHelper.updateAWBPrefix(Trigger.new);
       }
        
        //before udpate 
        if(Trigger.isUpdate){
            
        }
    }
    
     if(Trigger.isAfter){
         
         if(Trigger.isInsert){
                       
           
        }
         
          if(Trigger.isUpdate){
            
                 List<Linehaul__c> offloadedList = new List<Linehaul__c>();
                
                    for (Linehaul__c l : Trigger.new) {
                        Linehaul__c oldRec = Trigger.oldMap.get(l.Id);
                        if (l.AWB_Tracking_Status__c == 'Offloaded' && l.AWB_Tracking_Status__c != oldRec.AWB_Tracking_Status__c) {
                            offloadedList.add(l);
                        }
                    }
                
                    if (!offloadedList.isEmpty()) {
                        IndigoAWBTrackingControllerBatchHelper.sendEmailfOffloaded(offloadedList);
                    }
              
        }
     }
}