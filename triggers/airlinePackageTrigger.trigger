trigger airlinePackageTrigger on Trunk__c (before insert,before update,after insert,after update,after delete,after undelete) {

      
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
            
           
        }
        
        //after delete 
        if(Trigger.isDelete){
            
        }
        
       //after undelete 
        if(Trigger.isUndelete){
            
        }
    }
   
    
}