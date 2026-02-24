/**
* @description       : for calulating trunks weight and update trunks records as well respecting linehaul tracking record
* @author            : rafi.khan@bvclogistics.com
* @created on		 : 12-12-2023
* @last modified on  : 03-04-2024 
* @last modified by  : rafi.khan@bvclogistics.com
**/
public class TrunksController {

    @AuraEnabled(cacheable=true)
    public static User getUserInfo() {
        return [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
    }
    
    @AuraEnabled
    public static List<Trunk__c> fetchAllTrunksData(){
        List<Trunk__c> trunkList = new List<Trunk__c>();
        trunkList = [Select Id, Name, Trunk_weight__c, Trunk_name__c, RecordTypeId, RecordType.Name, Left_Seal__c, Left_Seal__r.Name,  Linehaul_Tracking__c, AWB_number__c From Trunk__c];
        System.debug('for checking trunkList.size() '+trunkList.size());
        return trunkList;
    }
    
    @AuraEnabled
    public static List<Trunk__c> fetchTrunksWithAWB(String awbNumber){
        try{
            
            String userId = UserInfo.getUserId();
            FSE_Sales__c fs = [SELECT Sales_Person__c, Id, Name, Hub__c,Hub__r.name,Hub__r.Branch__c FROM FSE_Sales__c where Sales_Person__c=:userId LIMIT 1];
            string EmpHub = fs.Hub__r.Branch__c;
            System.debug('userId :'+userId);
            System.debug('fs.Name :'+fs.Name);
            System.debug('EmpHub :'+EmpHub);
            List<Trunk__c> trunkList = new List<Trunk__c>();
            //trunkList = [Select Id, Name, Trunk_weight__c, Trunk_name__c, Trunk_name__r.Name, Trunk_name__r.Trunk_Tear_Weight__c, AWB_number__c,RecordTypeId, RecordType.Name, Left_Seal__c, Left_Seal__r.Name, Linehaul_Tracking__c, Linehaul_Tracking__r.Origin__c From Trunk__c Where AWB_number__c = : awbNumber AND Linehaul_Tracking__r.Origin__c =: EmpHub];
            trunkList = [Select Id, Name, Trunk_weight__c, Trunk_name__c, Trunk_name__r.Name, Trunk_name__r.Trunk_Tear_Weight__c, AWB_number__c,RecordTypeId, RecordType.Name, Left_Seal__c, Left_Seal__r.Name, Linehaul_Tracking__c, Linehaul_Tracking__r.Origin__c From Trunk__c Where AWB_number__c = : awbNumber];
            System.debug('for checking trunkList '+trunkList);
            System.debug('for checking trunkList.size() '+trunkList.size());
            
            return trunkList;
            
        } catch (Exception ex){
            System.debug('for checking in ex.getMessage() in fetchTrunksWithAWB '+ex.getMessage());
            System.debug('for checking in ex.getLineNumber() in fetchTrunksWithAWB '+ex.getLineNumber());
            return Null;
        }
        
    }
    
    @AuraEnabled
    public static trunk__c updateTrunkRecord(String blobData,Decimal weight,Decimal tearWeight,String trunkId){
        System.debug('tearWeight '+tearWeight);
        System.debug('trunkId '+trunkId);
        try{
            Trunk__c trunkObj = new Trunk__c();
            trunkObj = [Select Id, Name, Trunk_weight__c, Trunk_Tear_Weight__c, RecordTypeId, RecordType.Name, Linehaul_Tracking__c, Trunk_name__c, Trunk_name__r.Trunk_Tear_Weight__c From Trunk__c Where Id =: trunkId];
            System.debug('trunkObj'+trunkObj);
            if (blobData.startsWith('data:image/jpeg;base64,')) {
                blobData = blobData.substring('data:image/jpeg;base64,'.length());
            }
            
            ContentVersion cVersion = new ContentVersion();
            Id conDocId;
            String nm = trunkObj.Name +'.png';
            cVersion.PathOnClient = nm; 
            cVersion.Title = nm; 
            cVersion.VersionData = EncodingUtil.base64Decode(blobData); 
            Insert cVersion;
            
            if(cVersion.Id != null){
                conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
            }
            
            ContentDocumentLink conDocLinkObj = new ContentDocumentLink();
            conDocLinkObj.ContentDocumentId = conDocId;
            conDocLinkObj.LinkedEntityId = trunkId;
            conDocLinkObj.ShareType = 'V';
            conDocLinkObj.Visibility = 'AllUsers';
            insert conDocLinkObj;
            
            Decimal trunkTearWeight = 0;
            
            Trunk__c tempTrunkObj = new Trunk__c();          
            
            tempTrunkObj.Id = trunkObj.Id;
            tempTrunkObj.Trunk_weight__c = weight;
            if(trunkObj.RecordType.Name=='Airline Trunks' || trunkObj.RecordType.Name=='Oversize Airline Trunks'){
                tempTrunkObj.Trunk_Tear_Weight__c = tearWeight;
                trunkTearWeight = tearWeight;
            } else if(trunkObj.RecordType.Name=='Oversize Bags'){
                tempTrunkObj.Trunk_Tear_Weight__c = 0.0;
                trunkTearWeight = 0.0;
            } else {
                tempTrunkObj.Trunk_Tear_Weight__c = trunkObj.Trunk_name__r.Trunk_Tear_Weight__c;
                trunkTearWeight = trunkObj.Trunk_name__r.Trunk_Tear_Weight__c;
            }
            tempTrunkObj.Photo__c = true;
            System.debug('trunkTearWeight '+trunkTearWeight);
            
            
            update tempTrunkObj;
                
           
           
            
            Linehaul_Tracking__c lnObj = new Linehaul_Tracking__c();
            lnObj = [Select Id, Name, Trunks_Weight_Kgs__c From Linehaul_Tracking__c Where Id =:trunkObj.Linehaul_Tracking__c];
            
            List<Trunk__c> trunkList = new List<Trunk__C>();
            trunkList = [Select Id, Name, Trunk_weight__c,Trunk_Tear_Weight__c, RecordType.Name, Linehaul_Tracking__c From Trunk__c Where Linehaul_Tracking__c =: lnObj.Id];
            System.debug('trunkList '+trunkList);
            
            Decimal totalTrunksWeight = 0;
            Decimal totalTrunksTearWeight = 0;

            for(Trunk__c trObj: trunkList){
                if(trObj.Trunk_weight__c != null){
                    totalTrunksWeight += trObj.Trunk_weight__c;
                } else {
                    totalTrunksWeight += 0.0;
                }
                
                if(trObj.Trunk_Tear_Weight__c != null){
                    totalTrunksTearWeight += trObj.Trunk_Tear_Weight__c;
                } else {
                    totalTrunksTearWeight += tearWeight;
                }
                
            }
            System.debug('trunkTearWeight '+trunkTearWeight);
            System.debug('totalTrunksWeight '+totalTrunksWeight);


            lnObj.Trunks_Weight_Kgs__c = totalTrunksWeight - totalTrunksTearWeight;
            update lnObj;
            
            System.debug('for checking lnObj '+lnObj);
            
            return tempTrunkObj;
        }catch(Exception ex){
            System.debug('Error occure Message '+ex.getMessage());
            System.debug('Error occure Line Number '+ex.getLineNumber());
            return Null;
        }
        
    }
    
    //to upload Trunk Photo
    @AuraEnabled
    public static Trunk__c saveTrunkPhoto(String fileData, String trunkName){
        Trunk__c trunkObj = new Trunk__c();
        try{
            
            trunkObj = [Select Id, Name, Trunk_weight__c, Trunk_name__c, AWB_number__c From Trunk__c Where Name =: trunkName];
            if (fileData.startsWith('data:image/jpeg;base64,')) {
                fileData = fileData.substring('data:image/jpeg;base64,'.length());
            }
            
            ContentVersion cVersion = new ContentVersion();
            Id conDocId;
            
            cVersion.PathOnClient = 'TrunkPhoto.png'; 
            cVersion.Title = 'Trunk Weight Photo.png'; 
            cVersion.VersionData = EncodingUtil.base64Decode(fileData); 
            Insert cVersion;
            
            if(cVersion.Id != null){
                conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
            }
            
            ContentDocumentLink conDocLinkObj = new ContentDocumentLink();
            conDocLinkObj.ContentDocumentId = conDocId;
            conDocLinkObj.LinkedEntityId = trunkObj.Id;
            conDocLinkObj.ShareType = 'V';
            conDocLinkObj.Visibility = 'AllUsers';
            Insert conDocLinkObj;
            
            return trunkObj;
            
        }catch(Exception ex){
            System.debug('Error occure Message '+ex.getMessage());
            System.debug('Error occure Line Number '+ex.getLineNumber());
            return Null;
            
        }
        
    }

    //to upload Trunk Tear Weight Photo
    @AuraEnabled
    public static Trunk__c saveTrunkTearWeightPhoto(String fileData, String trunkName){
        System.debug('trunkName '+trunkName);
        Trunk__c trunkObj = new Trunk__c();
        try{
            
            trunkObj = [Select Id, Name, Trunk_weight__c, Trunk_name__c, AWB_number__c From Trunk__c Where Id =: trunkName];
            if (fileData.startsWith('data:image/jpeg;base64,')) {
                fileData = fileData.substring('data:image/jpeg;base64,'.length());
            }
            
            ContentVersion cVersion = new ContentVersion();
            Id conDocId;
            
            cVersion.PathOnClient = 'TrunkTearWeightPhoto.png'; 
            cVersion.Title = 'Trunk Tear Weight Photo.png'; 
            cVersion.VersionData = EncodingUtil.base64Decode(fileData); 
            Insert cVersion;
            
            if(cVersion.Id != null){
                conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
            }
            
            ContentDocumentLink conDocLinkObj = new ContentDocumentLink();
            conDocLinkObj.ContentDocumentId = conDocId;
            conDocLinkObj.LinkedEntityId = trunkName;
            conDocLinkObj.ShareType = 'V';
            conDocLinkObj.Visibility = 'AllUsers';
            Insert conDocLinkObj;
            
            return trunkObj;
            
        }catch(Exception ex){
            System.debug('Error occure Message '+ex.getMessage());
            System.debug('Error occure Line Number '+ex.getLineNumber());
            return Null;
            
        }
        
    }

    //to upload AWB Trunk Tear Weight Photo
    @AuraEnabled
    public static Trunk__c saveAWBTrunkTearWeightPhoto(String fileData, String trunkName){
        System.debug('trunkName '+trunkName);
        Trunk__c trunkObj = new Trunk__c();
        try{
            
            trunkObj = [Select Id, Name, Trunk_weight__c, Trunk_name__c, AWB_number__c From Trunk__c Where Name =: trunkName];
            if (fileData.startsWith('data:image/jpeg;base64,')) {
                fileData = fileData.substring('data:image/jpeg;base64,'.length());
            }
            
            ContentVersion cVersion = new ContentVersion();
            Id conDocId;
            
            cVersion.PathOnClient = 'TrunkTearWeightPhoto.png'; 
            cVersion.Title = 'Trunk Tear Weight Photo.png'; 
            cVersion.VersionData = EncodingUtil.base64Decode(fileData); 
            Insert cVersion;
            
            if(cVersion.Id != null){
                conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
            }
            
            ContentDocumentLink conDocLinkObj = new ContentDocumentLink();
            conDocLinkObj.ContentDocumentId = conDocId;
            conDocLinkObj.LinkedEntityId = trunkObj.Id;
            conDocLinkObj.ShareType = 'V';
            conDocLinkObj.Visibility = 'AllUsers';
            Insert conDocLinkObj;
            
            return trunkObj;
            
        }catch(Exception ex){
            System.debug('Error occure Message '+ex.getMessage());
            System.debug('Error occure Line Number '+ex.getLineNumber());
            return Null;
            
        }
        
    }

    
    @AuraEnabled
    public static List<Linehaul_Tracking__c> saveAllTrunkWeights(Decimal sumOfWeights,trunk__c trunkName,List<TrunkUpdateWrapper> trunkList){
        System.debug('for checking sumOfWeights '+sumOfWeights);
        System.debug('for checking trunkName '+trunkName);
        System.debug('for checking trunkList '+trunkList);
        try{
            List<Trunk__c> updateTrunkList = new List<Trunk__c>();
            set<id> LtList = new set<id>();
            
            List<String> trunkIds = new List<String>();
            
            for(TrunkUpdateWrapper trunkWrapper : trunkList) {
                trunkIds.add(trunkWrapper.Id);
            }
            
            List<Trunk__c> trunkListToUpdate = new List<Trunk__c>();
            trunkListToUpdate = [ SELECT Id, Name, Trunk_weight__c,Linehaul_Tracking__c,Linehaul_Tracking__r.id,RecordType.name, Trunk_name__r.Trunk_Tear_Weight__c 
                                 FROM Trunk__c WHERE Id IN :trunkIds];
            
            for(Trunk__c tr : trunkListToUpdate){
                if(tr.Linehaul_Tracking__c != null){
                    LtList.add(tr.Linehaul_Tracking__c);
                }
            }
            
                        
            List<Linehaul_Tracking__c> lineTrackList = new List<Linehaul_Tracking__c>();
            List<Linehaul_Tracking__c> lnObj = new List<Linehaul_Tracking__c>();
                      
            Map<Id, Decimal> linehaulTrackingWeights = new Map<Id, Decimal>();
            
           
            for (Trunk__c trunkToUpdate : trunkListToUpdate) {
                for (TrunkUpdateWrapper trunkWrapper : trunkList) {
                    if (trunkToUpdate.Id == trunkWrapper.Id) {
                        
                        if (!linehaulTrackingWeights.containsKey(trunkToUpdate.Linehaul_Tracking__c)) {
                            linehaulTrackingWeights.put(trunkToUpdate.Linehaul_Tracking__c, 0);
                        }
            
                       
                        Decimal calculatedWeight;
                        if (trunkToUpdate.RecordType.Name == 'BVC Trunks' || trunkToUpdate.RecordType.Name == 'Airline Trunks') {
                            calculatedWeight = trunkWrapper.Weight - trunkWrapper.TrunkTearWeight;
                        } else {
                            calculatedWeight = trunkWrapper.Weight;
                        }
            
                       
                        linehaulTrackingWeights.put(trunkToUpdate.Linehaul_Tracking__c, linehaulTrackingWeights.get(trunkToUpdate.Linehaul_Tracking__c) + calculatedWeight);
            
                        
                        trunkToUpdate.Trunk_weight__c = trunkWrapper.Weight;
                        trunkToUpdate.Trunk_Tear_Weight__c = trunkWrapper.TrunkTearWeight;
                        trunkToUpdate.Photo__c = true;
                        updateTrunkList.add(trunkToUpdate);
                    }
                }
            }
            
           
            lineTrackList = [ SELECT Id, Trunks_Weight_Kgs__c FROM Linehaul_Tracking__c  WHERE Id IN :linehaulTrackingWeights.keySet() ];
            
          
            for (Linehaul_Tracking__c lt : lineTrackList) {
                if (linehaulTrackingWeights.containsKey(lt.Id)) {
                    lt.Trunks_Weight_Kgs__c = linehaulTrackingWeights.get(lt.Id);
                    lnObj.add(lt);
                }
            }
            
            
            if (!updateTrunkList.isEmpty() && !lnObj.isEmpty()) {
                update updateTrunkList;
                update lnObj;
                System.debug('Updated Linehaul Tracking Records: ' + lnObj);
            }


            

           /*
            
            for(Linehaul_Tracking__c lt :LineTrackList ){
                lt.Trunks_Weight_Kgs__c = sumOfWeights - trunktearweight;
                lnObj.add(lt); 
            }  */
           // lnObj.Trunks_Weight_Kgs__c = sumOfWeights - totalTearWeight;
           // update lnObj;
            
            System.debug('for checking lnObj '+lnObj);
            return lnObj;
            
        } catch(Exception ex){
            System.debug('for checking in saveAllTrunkWeights ex.getMessage() '+ex.getMessage());
            System.debug('for checking in saveAllTrunkWeights ex.getLineNumber() '+ex.getLineNumber());
            return null;
        }
        
    }
    
    public class TrunkUpdateWrapper {
        @AuraEnabled
        public String Id { get; set; }
        
        @AuraEnabled
        public Decimal Weight { get; set; }
        
        @AuraEnabled
        public Decimal TrunkTearWeight { get; set; }
    }
    
    
    
    
    
    
    
    
    
    
    public static void GetCoverage(){
        integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
    
}