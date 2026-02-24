/**
* @File Name : BikeInventoryAssociationHelper.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : May 1, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | May 1, 2025 |   | Initial Version
**/

public class BikeInventoryAssociationHelper {
    @AuraEnabled
    public static Map<String,Secure_Packaging__c> checkBagAvailaability(String recType, String recId)
    {
        System.debug('checkBagAvailaability recType:'+recType+' recId:'+recId);
        Secure_Packaging__c sp = new Secure_Packaging__c();
        String errorMsg='';
        Map<String,Secure_Packaging__c> resMap = new Map<String,Secure_Packaging__c>();
        try
        {
            String CurrentUserId = userInfo.getUserId();
            List<Bike_Inventory_Association__c> BIAListalreadyInProgress = [select Id,Biker_Status__c from Bike_Inventory_Association__c 
                                                                            where User__c=:CurrentUserId and Vault_SNN__r.Status__c!='Consumed'and Biker_Status__c !='Delivery Completed'];
            System.debug('27 BIAListalreadyInProgress:'+BIAListalreadyInProgress.size());
            if(recType=='Vault')
            {
                if(BIAListalreadyInProgress.size()>0)
                {
                    errorMsg += 'Error User Already Linked with Another Vault';
                    System.debug('27 errorMsg:'+errorMsg);
                    resMap.put(errorMsg,sp); 
                }
                else
                {
                    sp = [ select Id,Name,Status__c,Bike_Inventory_Association__c,GPS_Mapping__c,LOCK_MAPPING__c,GPS_Mapping__r.Name
                          from Secure_Packaging__c where Name=:recId and 
                          RecordType.Name='Shield Vault' and Status__c='Available' limit 1]; 
                    if(sp.GPS_Mapping__c==null)
                    {
                        if(sp.GPS_Mapping__c==null)
                        {
                            errorMsg += 'GPS '; 
                        }
                        errorMsg += 'Not Linked for this Vault';
                        resMap.put(errorMsg,sp);
                    }            
                    else
                    {
                        resMap.put('success',sp);  
                    }                    
                }

            }
            if(recType=='Lock')
            {
                sp = [ select Id,Name,Status__c,Bike_Inventory_Association__c,
                      GPS_Mapping__c,LOCK_MAPPING__c from Secure_Packaging__c where Name=:recId and 
                      RecordType.Name='Shield Lock' and Status__c='Available' limit 1];
                resMap.put('success',sp);                
            }            
                     
        }catch(exception e){
            System.debug('24 Exception :'+e.getMessage());
            String ErrorMessage ='Check : Secure Packaging '+recId+' & Type '+recType+' Not Found or Not Available, Scan Again';
            String LabelText = recType=='Lock'?'Lock':'Vault';
            String MessageError='Please Scan Available'+LabelText+' only';
            resMap.put(MessageError,sp);
        }  
        System.debug('29 resMap:'+resMap);
        return resMap;
    }
    @AuraEnabled
    public static String Delink(Secure_Packaging__c Vault,Secure_Packaging__c Lock)
    {
        String Result;
        List<Secure_Packaging__c> spListToUpdate = new List<Secure_Packaging__c>();
        try
        {
            Bike_Inventory_Association__c BIA = [select Id,Biker_Status__c from Bike_Inventory_Association__c 
                                                 where Id=:Vault.Bike_Inventory_Association__c limit 1];
            Vault.Status__c='Available';
            Vault.Bike_Inventory_Association__c=null;
            Lock.Status__c='Available';
            Lock.Bike_Inventory_Association__c=null;
            BIA.Biker_Status__c='Delivery Completed';
            spListToUpdate.add(Vault);
            spListToUpdate.add(Lock);  
            update spListToUpdate;
            update BIA;
            Result='Success';
        } catch(Exception ex)
        {
            Result='Error : '+ex.getMessage();
        }
        
        return Result;
    }
    @AuraEnabled
    public static Map<String,Secure_Packaging__c> checkforDelink(String SpName,String typeOfSp,Secure_Packaging__c delikVault)
    {
        String Result;
        Map<String,Secure_Packaging__c> resMap = new Map<String,Secure_Packaging__c>();
        Secure_Packaging__c sp = new Secure_Packaging__c();
        System.debug('65 SpName:'+SpName);
        System.debug('65 typeOfSp:'+typeOfSp);
        System.debug('66 delikVault:'+delikVault);
        try
        {
            String CurrentUserId = userInfo.getUserId();            
           sp = [ select Id,Name,Status__c,Bike_Inventory_Association__c,GPS_Mapping__c,LOCK_MAPPING__c,GPS_Mapping__r.Name,
                 Bike_Inventory_Association__r.User__c from Secure_Packaging__c where Name=:SpName limit 1]; 
            if(typeOfSp=='DeLink Vault')
            {
                if(sp.Bike_Inventory_Association__r.User__c==CurrentUserId)
                {
                    resMap.put('success',sp);  
                }
                else
                {
                    resMap.put('Error Scan Your Alloted Vault, Its not Assigned to You',sp);
                }                      
                
                return resMap;
            }
            if(delikVault==null && typeOfSp=='Delink Lock')
            {
                resMap.put('Error Please Scan Vault First',sp);
            }
            if(delikVault!=null && typeOfSp=='Delink Lock')
            {
                if(sp.Bike_Inventory_Association__r.User__c==CurrentUserId)
                {
                    if(sp.Bike_Inventory_Association__c==delikVault.Bike_Inventory_Association__c) 
                    {
                        resMap.put('success',sp);  
                    }
                    else
                    {
                        resMap.put('Error Please Scan Correct Lock for Delink',sp); 
                    }                    
                }
                else
                {
                    resMap.put('Error Scan Your Alloted Lock, Its not Assigned to You',sp);
                }
            }
            /*
            List<Secure_Packaging__c> recordsToUpdate = new List<Secure_Packaging__c>();
            if(Vault.Status__c=='Consumed')
            {
                if(Vault.LOCK_MAPPING__c!=null)
                {
                    Secure_Packaging__c Lock = [ select Id,Name,Status__c,Bike_Inventory_Association__c,GPS_Mapping__c,LOCK_MAPPING__c
                                      from Secure_Packaging__c where Id=:Vault.LOCK_MAPPING__c limit 1];
                    if(Lock.Status__c=='Consumed')
                    {
                       Lock.Status__c='Available';
                        recordsToUpdate.add(Lock);
                    }
                }
                Vault.Status__c='Available';
                recordsToUpdate.add(Vault);
                update recordsToUpdate;
                Result='success Delink Successfully for '+SpName;
                BIA.Biker_Status__c='Delivery Completed';
                update BIA;
            }
            else
            {
                Result='vault '+SpName+'alredy Available';
            }
            */
        }catch(Exception e)
        {
            Result='Error '+e.getMessage();
            resMap.put('Error'+e.getMessage(),sp);
        }      
        System.debug('66 resMap:'+resMap);
        return resMap;
    } 
    
    @AuraEnabled
    public static List<Bike_Inventory_Association__c> getAllRecords(String recType, String recId)
    {
        return [ select Id,Name,User__c,User__r.Name,Vault_SNN__c,Vault_SNN__r.Name,GPS_To_Vault_Map__c,GPS_To_Vault_Map__r.Name,
                Managed_By_Hub__c,Managed_By_Hub__r.Name,LOCK_SNN__c,LOCK_SNN__r.Name
                from Bike_Inventory_Association__c where User__c!=null and Vault_SNN__r.Status__c=:'Consumed' and Biker_Status__c='Delivery In Progress'];
    }    
    @AuraEnabled
    public static Map<String,Bike_Inventory_Association__c> saveBikeInvAssociation(Secure_Packaging__c ValtRec,Secure_Packaging__c bagLock)
    {
        System.debug('Inside saveBikeInvAssociation');
        System.debug('Inside ValtRec :'+ValtRec);
        System.debug('Inside bagLock :'+bagLock);
        Map<String,Bike_Inventory_Association__c> resultMap = new Map<String,Bike_Inventory_Association__c>();
        Bike_Inventory_Association__c newRecord = new Bike_Inventory_Association__c(); 
        List<Secure_Packaging__c> spToUpdateList = new List<Secure_Packaging__c>();
        try
        {
            if(ValtRec!=null)
            {
                System.debug('48');
                newRecord.User__c = UserInfo.getUserId();
                newRecord.Biker_Status__c = 'Delivery In Progress';
                newRecord.Vault_SNN__c = ValtRec.Id;
                newRecord.GPS_To_Vault_Map__c = ValtRec.GPS_Mapping__c;                 
                newRecord.LOCK_SNN__c = bagLock.Id;
                insert newRecord;   // inserting new Recored
                System.debug('55');
                ValtRec.Status__c='Consumed';
                ValtRec.Bike_Inventory_Association__c=newRecord.Id;
               // ValtRec.LOCK_MAPPING__c=bagLock.Id;
                System.debug('64');
                spToUpdateList.add(ValtRec);
                // update ValtRec;      // updating SP Record
                bagLock.Status__c='Consumed';
                bagLock.Bike_Inventory_Association__c=newRecord.Id;
                spToUpdateList.add(bagLock);
                update spToUpdateList;
                resultMap.put('success',newRecord);
                System.debug('67 newRecord:'+newRecord);
                
            }
        } catch(Exception e)
        {
            System.debug('72 e.getMessage():'+e.getMessage());
            resultMap.put('Error :'+e.getMessage(),newRecord);
        }
        System.debug('71 resultMap :'+resultMap);
        return resultMap;
    }
}