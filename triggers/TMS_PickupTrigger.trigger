trigger TMS_PickupTrigger on Pickup__c (after Insert, after update,before insert,before update) {
    //pickup shring code...
    if(trigger.isAfter){ 
        List<Pickup__c> PickToShare = new List<Pickup__c>();
        List<String> SharingToDelete = new List<String>();
         if(trigger.isInsert){
             set<Id> ids=new set<Id>(); 
              for(Pickup__c  pick: trigger.new){
                if(pick.Shipper_Address__c!=null){
                    system.debug('Shipper_Address__c found');
                    ids.add(pick.id) ;
                }
              }
             if(ids !=null && ids.size()>0){
               TMS_PickupHandler.updatePickUp(ids);  
            }
         }
        for(Pickup__c  pick: trigger.new){
            if(pick.BVC_Origin_Hub__c != null){
                if(trigger.isInsert)
                    PickToShare.add(pick);
                else if(pick.BVC_Origin_Hub__c != trigger.oldMap.get(pick.id).BVC_Origin_Hub__c){
                    SharingToDelete.add(pick.id);
                    PickToShare.add(pick);
                }
            }
        }
        if(SharingToDelete !=null && SharingToDelete.size()>0)
            TMS_PickupSharingHandler.DeleteShareRecords(SharingToDelete);
        if(PickToShare !=null && PickToShare.size()>0)
            TMS_PickupSharingHandler.SharePickupRecords(PickToShare);
        
        //share pickup to escorter assigned for pickup---starts---
        if(trigger.isUpdate){
            set<Id> ids=new set<Id>(); 
            Map<id,id> pickup_AssignedTo_Map = new Map<id,id>();
            Map<id,id> pickup_PreAssignedTo_Map = new Map<id,id>();
            List<String> pickupIdList = new List<String>();	// added  by imran
            //PickupTriggerHelper.handlePickupCompleted(Trigger.new,Trigger.oldMap);  // added on 19-11-2025 by imran
            System.debug('40 PickupTriggerHelper1 Started');
            PickupTriggerHelper1.handlePickupCompleted(Trigger.new,Trigger.oldMap);  // added on 25-11-2025 by imran
            System.debug('40 PickupTriggerHelper1 Ended');
       //IqlooLock code from Line -38 to 60     
             Set<Id> pickupIds = new Set<Id>();            
            for (Pickup__c pick : Trigger.new) {
                 Pickup__c oldPickup = Trigger.oldMap.get(pick.Id);
                if(oldPickup.Physical_Pickup_Completed_Time__c!=pick.Physical_Pickup_Completed_Time__c) // added  by imran on Sep 25   
                {
                    pickupIdList.add(pick.Id);
                }										// upto here added  by imran
                pickupIds.add(pick.Id);
            }
            // added  by imran
            if(pickupIdList.size()>0)
            {
                //SLACalculatorHandlerBatchHandler.callbatchHelper(pickupIdList);
            }
            // upto here added  by imran
            
            //Added code by Rafi khan for TAT via queuable but failed
            /*for(Pickup__c pickObj: trigger.new){
                if(pickObj.Pickup_Status__c == 'Completed'){
                  PhysicalPickCompletedForTAT.updateShipmentPhysicalCompletedTime(trigger.new);   
                }
                
            }*/
             
            
             Map<Id, Pickup__c> pickupWithLockMap = new Map<Id, Pickup__c>( [SELECT Id, Lock_ID__c, Lock_ID__r.Name FROM Pickup__c WHERE Id IN :pickupIds]);
                        
            for(Pickup__c  pick: trigger.new){
                
                 Pickup__c oldMap = trigger.oldMap.get(pick.id);
                 Pickup__c pickWithLock = pickupWithLockMap.get(pick.Id);
                
                if(oldmap.Lock_ID__c == null && pick.Lock_ID__c  != null){
                    if(pick.Customer_Product_Category__c == 'Hyper local'){
                        //System.enqueueJob(new BVC_IqlooLockAPIQueueable(pickWithLock.Lock_ID__r.Name,pick.Id));
                    }
                   
                     
                }
                
                
                if(pick.Shipper_Address__c!=null && pick.Shipper_Address__c!=trigger.oldMap.get(pick.id).Shipper_Address__c){
                    system.debug('Shipper_Address__c found');
                    ids.add(pick.id) ;
                }
                if(pick.Pickup_Assigned_To__c != trigger.oldMap.get(pick.id).Pickup_Assigned_To__c && pick.Pickup_Assigned_To__c !=null){
                    system.debug('assigned');
                    pickup_AssignedTo_Map.put(pick.id,pick.Pickup_Assigned_To__c);
                }
                //remove sharing for previously assigned escorters
                if(trigger.oldMap.get(pick.id).Pickup_Assigned_To__c != null && pick.Pickup_Assigned_To__c != trigger.oldMap.get(pick.id).Pickup_Assigned_To__c){
                    pickup_PreAssignedTo_Map.put(pick.id, trigger.oldMap.get(pick.id).Pickup_Assigned_To__c);
                }
                //remove sharing for escorters whose pickup is complete/cancelled
                /*if((pick.Pickup_Status__c =='Completed' || pick.Pickup_Status__c =='Cancelled') && pick.Pickup_Status__c != trigger.oldMap.get(pick.id).Pickup_Status__c && pick.Pickup_Assigned_To__c !=null){
                pickup_PreAssignedTo_Map.put(pick.id, pick.Pickup_Assigned_To__c);
               }*/
                
            }
            if(pickup_PreAssignedTo_Map !=null && pickup_PreAssignedTo_Map.size()>0){
                TMS_PickupSharingHandler.deleteSharingForEscorters(pickup_PreAssignedTo_Map);
            }
            if(pickup_AssignedTo_Map !=null && pickup_AssignedTo_Map.size()>0){
                TMS_PickupSharingHandler.SharingForEscorters(pickup_AssignedTo_Map);
            }
            if(ids !=null && ids.size()>0){
                TMS_PickupHandler.updatePickUp(ids);  
            }
            //CalculationOfHoliday.handleAfterUpdate(Trigger.new, Trigger.oldMap); //added by Pratik on 5th August 25
            
            //added by Pratik on 6th August 25===============================commented calling batch on 20/9/2025 by Pratik=================================================================== 
            /*
            Set<Id> pickupIdsToProcess = new Set<Id>();
            
            for (Pickup__c newPickup : Trigger.new) {
                Pickup__c oldPickup = Trigger.oldMap.get(newPickup.Id);
                
                if (newPickup.Physical_Pickup_Completed_Time__c != null &&
                    newPickup.Physical_Pickup_Completed_Time__c != oldPickup.Physical_Pickup_Completed_Time__c) {
                        pickupIdsToProcess.add(newPickup.Id);
                    }
            }
            
            if (!pickupIdsToProcess.isEmpty()) {
               HolidayChargeBatch batch = new HolidayChargeBatch(pickupIdsToProcess);
               Database.executeBatch(batch,1);
            }
            */
            //upto here==============================================================================================================================
        }
        //share pickup to escorter assigned for pickup---ends---
    }
    
    //Used for Pickupfiledupdate
    If(Trigger.isbefore && Trigger.isInsert){
       PickupCutoffValidator.validatePickupTime(Trigger.new);//Added By Sanket Pickup Slot Req Feb 2026
        TMS_PickupHandler.updatepickupFields(Trigger.new);
         updateBillingAccountPickup billingAccountUpdater = new updateBillingAccountPickup();
         billingAccountUpdater.updateBillingAccounts(Trigger.new, new Map<Id, Pickup__c>());
    }
     
    //Sharing ends...
   
    
    //Code added by Rafi Khan for OTP generation for pickup assigned to --> escortors
    If(Trigger.isBefore){
        if (Trigger.isInsert || Trigger.isUpdate) {
            
            //Set<Id> escorterUserIds = new Set<Id>();
            for(Pickup__c  pick: trigger.new){  
                if(Trigger.isUpdate)
                {
                    Pickup__c oldPickup = trigger.OldMap.get(pick.Id);
                    if(pick.Pickup_Status__c=='Completed' && oldPickup.Pickup_Status__c!=pick.Pickup_Status__c){pick.Physical_Pickup_Completed_Time__c = System.now();} // Imran Added Sep 22 
                }
                
                if (pick.Pickup_Assigned_To__c != null && (trigger.isInsert || (trigger.isUpdate && pick.Pickup_Assigned_To__c != trigger.oldMap.get(pick.Id).Pickup_Assigned_To__c))) {
                    system.debug('assigned');
                    //escorterUserIds.add(pick.Pickup_Assigned_To__c);
                }
                
            }
            
           // Map<Id, User> escorterUsers = new Map<Id, User>([SELECT Id, UserRole.Name FROM User WHERE Id IN :escorterUserIds AND UserRole.Name = 'Escorter']);
   
            for (Pickup__c pick : trigger.new) {
             
                if (pick.Pickup_Assigned_To__c != null && pick.OTP__c == null && (trigger.isInsert || (trigger.isUpdate && trigger.oldMap.get(pick.Id).OTP__c == null))) {
                    
                    Integer otpLength = 4;
                    String allowedChars = '0123456789';
                    String otp = '';
                    
                    while (otp.length() < otpLength) {
                        Integer randomIndex = Math.mod(Math.abs(Crypto.getRandomInteger()), allowedChars.length());
                        otp += allowedChars.charAt(randomIndex);
                    }
                    
                   pick.OTP__c = otp;
                }  
            
            }  

        }
    }
     //OTP generation Code ends her
    //Added By Sanket
    if (Trigger.isBefore && Trigger.isUpdate) {
        PickupStatusValidator.validatePickupStatus(Trigger.new, Trigger.oldMap);		//add secure bag on shipment validation before pickup complete
    }
    
    }