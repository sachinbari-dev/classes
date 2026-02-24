/*
 * 
 *  @Last Modified By 	: Imran Shaik
 *  @Last Modified date : 27-10-2025
 *  @Version 			: V1.1 Before Insert Shipment Validation Added, (First Assign Pickup to Create Shipment)
 *  @Version   			: V1.2 After Insert Chainging Pickup Status to In Progress
 *  @Version   			: V1.3 After Update Pickup on Shipment Chainging Pickup Status to In Progress
 *  @Version			: v1.4 Commented by Rafi to avoid 101 SOQL on track shipment and rever order
 * 
 */
trigger IntegratedShipmentTrigger on Shipment__c (after update,after insert,before update, before insert,before delete) {
    if(Trigger.isBefore){
        
        //before insert
        if(trigger.isInsert){
            
            List<Shipment__c> ShipListForSetPayer = new List<Shipment__c>();
            List<Shipment__c> shipListForrestrictShipmentCreation = new List<Shipment__c>();
            List<Shipment__c> ShipList = new List<Shipment__c>();
            Set<Id>accountIds=new Set<Id>();
            List<Shipment__c> ShipmentWithBillingAccountList = new List<Shipment__c>();
            List<String> pickupIdList = new List<String>();  // V1.11
            Profile [] profileList = [SELECT Id, Name, UserType, UserLicense.Name FROM Profile WHERE Id=:userinfo.getProfileId() AND UserLicense.Name like 'Customer Community Plus%' LIMIT 1];
            
            Boolean showError = profileList.size() > 0 ? false: true;
            
            for(Shipment__c shipment : trigger.new){
                if(shipment.Customer__c!=null){
                    accountIds.add(shipment.Customer__c);
                }
                if(shipment.Pickup__c!=null)
                {
                    pickupIdList.add(shipment.Pickup__c);	// V1.1
                }
            }
            // from V1.1
            if(pickupIdList.size()>0)
            {
                List<Pickup__c> pkList = [select Id,Pickup_Assigned_To__c from Pickup__c where Id IN :pickupIdList and Pickup_Assigned_To__c=null];
                Map<Id, Pickup__c> pickupMap = new Map<Id, Pickup__c>([select Id,Pickup_Assigned_To__c from Pickup__c 
                                                                       where Id IN :pickupIdList and Pickup_Assigned_To__c=null] );
                if(pickupMap.size()>0)
                {
                   for(Shipment__c shipment : trigger.new){
                       if(shipment.Pickup__c!=null)
                       {
                           if(pickupMap.containsKey(shipment.Pickup__c))
                           {
                           //shipment.addError('First Assign Pickup to Create Shipment');
                           }
                       }
                   }
                }
            }
            // upto here V1.1
            Map<Id,Account>mapOfIdVsAccount=new Map<Id,Account>([SELECT Id,name,ParentId,Primary_Address__c,Primary_Address__r.id,(select id,name,Primary_Address__c,Primary_Address__r.id FROM ChildAccounts) FROM Account WHERE Id =:accountIds]);
            
            system.debug('map of Account++++' + mapOfIdVsAccount.values());
            
            List<Account> accList = [SELECT Id, Name, New_Contract__c FROM Account WHERE Id IN :accountIds LIMIT 1];
            Account ac = new Account();
            if (!accList.isEmpty()) {
                ac = accList[0];
            }
            
            //Account ac = [select Id,Name,New_Contract__c from Account where Id IN:accountIds limit 1];
                    
            String Uid = UserInfo.getUserId();
            User Usr = [select id,Name,International_Billing_Branch__c,BATH_eSHIP_Billing_Branch__c from User where Id=:Uid];
            List<Hub__c> BVCbranchBatheShip = [select id,Name,BVC_LegalEntity__c from Hub__c where Name=:Usr.BATH_eSHIP_Billing_Branch__c];
            
            for ( Shipment__c shipment: Trigger.new ){
                //tested-working
                if(shipment.Is_Uploaded__c==false){
                    if(shipment.Customer_Product_Category__c=='eSHIP' || shipment.Customer_Product_Category__c=='BATH'){ // tested-working
                        if(BVCbranchBatheShip.size()>0){
                            if(BVCbranchBatheShip[0].BVC_LegalEntity__c!=null){ 
                                Shipment.Status__c='Pending Billing';  
                                Shipment.Bill_To_Account__c=shipment.Customer__c; 
                            //    Shipment.Billing_Entity_Name_TMS__c=BVCbranchBatheShip[0].BVC_LegalEntity__c; commented for billing fields removal
                                
                            }
                        } 
                    }  
                }
                
                //tested-working
                if(shipment.Bill_to_1__c != null || shipment.Fixed_Billing_Shipment__c == false){
                    ShipListForSetPayer.add(shipment);
                }
                
                // added by Imran
                System.debug('11 . shipment.Customer__r.ID :'+shipment.Customer__c);
                // tested- working
                if(shipment.Customer_Product_Category__c=='GoldSHIP'){
                    System.debug('12 . ac.New_Contract__c :'+ac.New_Contract__c);
                    System.debug('12 . ac.Name :'+ac.Name);
                    if(ac.New_Contract__c==true)
                    {
                        if(!Test.isRunningTest()){
                            shipment.addError('GoldSHIP Not available for this Customer'); 
                        }
                        
                        
                    }
                    
                }
                // upto here
                // tested - working
                if(shipment.Origin_Address_Name__c != null || shipment.Destination_Address_Name__c != null || 
                   shipment.Customer_Product_Category__c != null || shipment.IsExhibition__c != null){
                       shipment.BVC_Product_Name__c = '';
                       shipment.Product_Code__c = '';
                       if(shipment.Origin_Address_City__c!=null && shipment.Destination_Address_City__c !=null && 
                          (shipment.Customer_Product_Category__c!=null || shipment.IsExhibition__c)){
                           ShipList.add(shipment);
                       }
                   }
                
                //testd- working
                if(shipment.Billing_Account__c !=null){
                    ShipmentWithBillingAccountList.add(shipment);
                }        
                
                //tested - wprking
                if (shipment.Shipment_Created_Through__c =='Mobile App' && shipment.Customer__c != null) {
                    shipListForrestrictShipmentCreation.add(shipment);
                }
                
                // tested-working
                if(shipment.Customer__c !=null){
                    if(mapOfIdVsAccount.containsKey(shipment.Customer__c)){
                        system.debug('>>'+mapOfIdVsAccount.get(shipment.Customer__c));
                        system.debug('>>'+mapOfIdVsAccount.get(shipment.Customer__c)+' :'+mapOfIdVsAccount.get(shipment.Customer__c).ChildAccounts.size());
                        if(mapOfIdVsAccount.get(shipment.Customer__c).ChildAccounts.size()==0){
                            shipment.Billing_Account__c=mapOfIdVsAccount.get(shipment.Customer__c).id;
                            shipment.Billing_Address__c=mapOfIdVsAccount.get(shipment.Customer__c).Primary_Address__r.id;
                        }
                        if(mapOfIdVsAccount.get(shipment.Customer__c).ChildAccounts.size()==1){
                            for(Account cust:mapOfIdVsAccount.get(shipment.Customer__c).ChildAccounts){
                                shipment.Billing_Account__c=cust.id;
                                shipment.Billing_Address__c=cust.Primary_Address__r.id;
                            }
                        }
                        if(mapOfIdVsAccount.get(shipment.Customer__c).ChildAccounts.size()>1 &&(shipment.Billing_Account__c==null || shipment.Billing_Address__c==null)){
                            if(showError ){ // to bypass mobile and Community
                                if(shipment.Shipment_Created_Through__c != 'Mobile App'){
                                    trigger.new[0].addError('Please select a Billing Account');
                                }
                                
                            }
                            
                        }
                    }
                }
                
                //upto here
                
                
                
            }
            
            
            if(!ShipListForSetPayer.isEmpty()){
                ShipmentTriggerHandler.setPayer(ShipListForSetPayer);
            }            
            
            if(ShipList!=null && ShipList.size()>0 && !Test.isRunningTest())
                TMS_ProductCodeHandler.UpdateProductDetails(ShipList);
            
            if(ShipmentWithBillingAccountList !=null && ShipmentWithBillingAccountList.size()>0){
                updateBillingAccount_handler.updatePrimaryAddress(ShipmentWithBillingAccountList);
            }
            
            if(!shipListForrestrictShipmentCreation.isEmpty()){
                ShipmentRestrictHandler.restrictShipmentCreation(shipListForrestrictShipmentCreation);
            }
            
        }
        
        //before update 
        if(Trigger.isUpdate){
            
            List<Shipment__c> ShipList = new List<Shipment__c>();
            List<Shipment__c> ShipList1 = new List<Shipment__c>();
            List<Shipment__c> ShipListForSetPayer = new List<Shipment__c>();
            
          
            for ( Shipment__c shipment: Trigger.new ){ 
                //tested-working
                if((shipment.Gross_Weight__c!=null && shipment.Gross_Weight__c!= trigger.oldMap.get(shipment.id).Gross_Weight__c)||
                   (shipment.Number_of_Packages__c!=null && shipment.Number_of_Packages__c!= trigger.oldMap.get(shipment.id).Number_of_Packages__c)){
                       ShipList.add(shipment);
                       
                   }
                
                //tested-working
                if(shipment.Verified_for_Billing__c==true && trigger.oldmap.get(shipment.Id).Verified_for_Billing__c == false && shipment.Verified_for_Billling__c!='Yes' && shipment.Fixed_Billing_Shipment__c == false){	//added Fixed_Billing_Shipment__c == false by Rafi to stop for fixed billing
                //if(shipment.Verified_for_Billing__c==true && trigger.oldmap.get(shipment.Id).Verified_for_Billing__c == false && shipment.Verified_for_Billling__c!='Yes'){	//without Fixed_Billing_Shipment__c for Imran's deployment 
                
                    if(shipment.Customer_Product_Category__c=='eSHIP' || shipment.Customer_Product_Category__c=='BATH'){
                        Shipment.Verified_for_Billling__c='No';    
                    } 
                }
                
                //tested - working
                if(shipment.Fixed_Billing_Shipment__c == false || shipment.Bill_to_1__c != null){		//remove this if, if fixed billing cpu timelimit failed
                    ShipListForSetPayer.add(shipment);			// without Fixed_Billing_Shipment__c for Imran's deployment
                    
                }
                
                //tested - working
                if(shipment.Origin_Address_Name__c != trigger.oldmap.get(shipment.id).Origin_Address_Name__c ||
                   shipment.Destination_Address_Name__c != trigger.oldmap.get(shipment.id).Destination_Address_Name__c ||
                   shipment.Customer_Product_Category__c != trigger.oldmap.get(shipment.id).Customer_Product_Category__c ||
                   shipment.IsExhibition__c != trigger.oldmap.get(shipment.id).IsExhibition__c){
                       shipment.BVC_Product_Name__c = '';
                       shipment.Product_Code__c = '';
                       if(shipment.Origin_Address_City__c!=null && shipment.Destination_Address_City__c !=null && (shipment.Customer_Product_Category__c!=null || shipment.IsExhibition__c)){
                           ShipList1.add(shipment);
                       }
                   }
            }   
            
            if(ShipList.size()>0 && !Test.isRunningTest()){
                TMS_ProductCodeHandler.UpdateProductDetails(ShipList);	//Prat
            }
            
            if(ShipList1!=null && ShipList1.size()>0 && !Test.isRunningTest())
                TMS_ProductCodeHandler.UpdateProductDetails(ShipList1);
            
            if(!ShipListForSetPayer.isEmpty()){
                ShipmentTriggerHandler.setPayer(ShipListForSetPayer);
            }
            
        }
        
        
        //before delete
        if(Trigger.isDelete){ 
            ShipmentTriggerHandler.cannotDeleteShipment(trigger.old);
        }
    }
    
    // after trigger executes    
    
    if(Trigger.isAfter){
        
        //after insert
        if(Trigger.isInsert){
            List<Shipment__c> shipListForShipmentTriggerHandlerServiceCtrl = new List<Shipment__c>();
            List<Shipment__c> shipListForShipmentTriggerBVCHelper = new List<Shipment__c>();
            List<Shipment__c> shipmentList = new List<Shipment__c>();
            List<Shipment__c> ShipToShare = new List<Shipment__c>();
            List<String> SharingToDelete = new List<String>();
            
            shipmentHelper.afterInsert(Trigger.new); // V1.2
            
            if(trigger.New[0].Invoice_Calculated_Amount__c != null){
                system.enqueueJob(new Community_RazorpayQueueableCrtInv(trigger.New));
            }  
            for ( Shipment__c shipment: Trigger.new ){
                
                //tested - working
                if(shipment.Shipping_Note_Number__c != null){
                    shipmentList.add(shipment);  
                }
                
                //tested-working
                if(shipment.Origin_Hub__c != null){
                    if(trigger.isInsert || shipment.OwnerId != trigger.oldMap.get(shipment.id).OwnerId)
                        ShipToShare.add(shipment);
                    else if(shipment.Origin_Hub__c != trigger.oldMap.get(shipment.id).Origin_Hub__c){
                        SharingToDelete.add(shipment.id);
                        ShipToShare.add(shipment);
                    }
                }
            }
            
            
            if(!shipmentList.isEmpty()){
                Update_Secure_Packaging.updateRelatedSecurePackaging(shipmentList);   
            }
            
            if(SharingToDelete !=null && SharingToDelete.size()>0)
                TMS_ShipmentSharingHandler.DeleteShareRecords(SharingToDelete);
            
            if(ShipToShare !=null && ShipToShare.size()>0)
                TMS_ShipmentSharingHandler.ShareShipmentRecords(ShipToShare);
            
        }
        
        //after update 
        if(Trigger.isUpdate){
            
             shipmentHelper.afterUpdate(Trigger.new, Trigger.oldMap); // V1.3
            
            if(trigger.New[0].Invoice_Calculated_Amount__c != trigger.Old[0].Invoice_Calculated_Amount__c){
                system.enqueueJob(new Community_RazorpayQueueableCrtInv(trigger.New));
            }
            
            if(trigger.New[0].Invoice_Calculated_Amount__c != null && trigger.New[0].Short_URL__c == null){
                system.enqueueJob(new Community_RazorpayQueueableCrtInv(trigger.New));
            }
            /* V1.4 Commented by Rafi to avoid 101 SOQL on track shipment and rever order
            if(trigger.New[0].Customer_Product_Category__c!='BATH' && trigger.New[0].Customer_Product_Category__c!='eSHIP' && trigger.new[0].Fixed_Billing_Shipment__c == false && !Test.isRunningTest()){	// added trigger.new[0].Fixed_Billing_Shipment__c == falseby Rafi to stop fixed billing flow
            //if(trigger.New[0].Customer_Product_Category__c!='BATH' && trigger.New[0].Customer_Product_Category__c!='eSHIP' && !Test.isRunningTest()){	// without Fixed_Billing_Shipment__c for Imran's deployment
                ShipmentTriggerHandler.updateShipmentLotCheckbox(Trigger.New);
            }*/
            
            // Added By standav
            Map<Id,Shipment__c> shipMap2 = new Map<Id,Shipment__c>();
            set<id> shipid = new set<id>();
            Map<Id,Shipment__c> shipMap = new Map<Id,Shipment__c>();
            
            list<Shipment__c> BVCShip = new list<Shipment__c>();
            Map<Id,Shipment__c> shipMap1 = new Map<Id,Shipment__c>();
            
			Map<id,id> Shipment_AssignedTo_Map = new Map<id,id>();
            Map<id,id> Shipment_PreAssignedTo_Map = new Map<id,id>();
                        
            List<Shipment__c> shipListForShipmentTriggerBVCHelper = new List<Shipment__c>();
            List<Shipment__c> shipListForRebillingOrder = new List<Shipment__c>();
            
            List<Shipment__c> shipListForCreateBVCOrder = new List<Shipment__c>();
            List<Shipment__c> shipListForCreateOrder = new List<Shipment__c>();
            List<Shipment__c> transitDayCalculatorList = new  List<Shipment__c>();            
                        
            for ( Shipment__c shipment: Trigger.new ){
                //tested-working
                if ( shipment.Verified_for_Billing__c != Trigger.oldMap.get( shipment.Id ).Verified_for_Billing__c){
                    if(shipment.Verified_for_Billing__c==true && Shipment.Verified_for_Billling__c=='No'){
                        if((shipment.Customer_Product_Category__c=='eSHIP' || shipment.Customer_Product_Category__c=='BATH') && shipment.Created_through_BVCeSHIP__c == true){
                            System.debug('for checking calling ShipmentTriggerBVCHelper.createBVCOrderNew');
                            shipListForCreateBVCOrder.add(shipment);
                        } 
                    }
                } 
                
                //tested-working
                if(shipment.Status__c == 'Verified For Billing' && trigger.oldmap.get(shipment.Id).Status__c == 'Pending Billing' && shipment.fixed_billing_shipment__c == false)
                //if(shipment.Status__c == 'Verified For Billing' && trigger.oldmap.get(shipment.Id).Status__c == 'Pending Billing' ) //without Fixed_Billing_Shipment__c for Imran's deployment
                {
                    shipMap1.put(shipment.Id,shipment);
                    BVCShip.add(shipment);
                } 
                
                //tested-working
                if((shipment.Delivery_Route_Assigned_To__c != trigger.oldMap.get(shipment.id).Delivery_Route_Assigned_To__c || 
                    shipment.OwnerId != trigger.oldMap.get(shipment.id).OwnerId) && shipment.Delivery_Route_Assigned_To__c !=null){
                        Shipment_AssignedTo_Map.put(shipment.id,shipment.Delivery_Route_Assigned_To__c);
                    }
                
                //tested-working
                //remove sharing for previously assigned escorters
                if(trigger.oldMap.get(shipment.id).Delivery_Route_Assigned_To__c != null && shipment.Delivery_Route_Assigned_To__c != trigger.oldMap.get(shipment.id).Delivery_Route_Assigned_To__c){
                    Shipment_PreAssignedTo_Map.put(shipment.id, trigger.oldMap.get(shipment.id).Delivery_Route_Assigned_To__c);
                }
                
                //tested- working
                //remove sharing for escorters whose shipment is delivered
                if(shipment.Tracking_Status__c == 'Delivered' && shipment.Tracking_Status__c != trigger.oldMap.get(shipment.id).Tracking_Status__c && shipment.Delivery_Route_Assigned_To__c !=null){
                    Shipment_PreAssignedTo_Map.put(shipment.id, shipment.Delivery_Route_Assigned_To__c);
                }
               

             
            }  
            
            
            if(shipMap1.size() > 0){
                if(BVCShip[0].Created_Through_BVCContract__c){
                   BVCOrderCreateShipment.validateAndCreateOrder(shipMap1); 
                    system.debug('BVC Contract=====');
                }
                
                
            }
            
            if(!shipListForCreateBVCOrder.isEmpty()){
                ShipmentTriggerBVCHelper.createBVCOrderNew(shipListForCreateBVCOrder);
                            
            }
            
            if(Shipment_PreAssignedTo_Map !=null && Shipment_PreAssignedTo_Map.size()>0){
                TMS_ShipmentSharingHandler.deleteSharingForEscorters(Shipment_PreAssignedTo_Map);
            }
            if(Shipment_AssignedTo_Map !=null && Shipment_AssignedTo_Map.size()>0){
                TMS_ShipmentSharingHandler.SharingForEscorters(Shipment_AssignedTo_Map);
            }
       
          
            
        }
        //after update end
        
    }
    // after trigger ends
    
}