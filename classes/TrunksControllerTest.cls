@isTest
public class TrunksControllerTest {
    
    public static testMethod void testData(){
        
        Trunk__c trunkObj = new Trunk__c();
        trunkObj.Trunk_weight__c = 564.56;
        trunkObj.Trunk_Tear_Weight__c = 22.22;
        Insert trunkObj;
        
        List<Trunk__c> trunkList = new List<Trunk__c>();
        trunkList.add(trunkObj);
        
        Linehaul_Tracking__c lnObj = new Linehaul_Tracking__c();
        lnObj.Trunks_Weight_Kgs__c = 252.25;
        Insert lnObj;
        
        ContentVersion cVersion = new ContentVersion();
        Id conDocId;
        
        cVersion.PathOnClient = 'test.png'; 
        cVersion.Title = 'Test Trunk Photo.png'; 
        cVersion.VersionData = EncodingUtil.base64Decode('fileData'); 
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
        
        TrunksController.TrunkUpdateWrapper testWrapper = new TrunksController.TrunkUpdateWrapper();
        testWrapper.Id = trunkObj.Id;
        testWrapper.Weight = 15;
        testWrapper.TrunkTearWeight = 3;
        
        String fileData = 'data:image/jpeg;base64,/dsvhgfvhgdsvvjjhdsbfj';
        
        test.startTest();
        TrunksController.fetchAllTrunksData();
        TrunksController.fetchTrunksWithAWB('awbNumber');
        list <Linehaul_Tracking__c> result = TrunksController.saveAllTrunkWeights(12.12, trunkObj, new List<TrunksController.TrunkUpdateWrapper>{testWrapper});
        Trunk__c savedTrunk = TrunksController.saveTrunkPhoto(fileData, trunkObj.Name);
        TrunksController.updateTrunkRecord(fileData, 250.25, 50.50, trunkObj.Id);
        TrunksController.saveTrunkTearWeightPhoto(fileData,trunkObj.Id);
        TrunksController.saveAWBTrunkTearWeightPhoto(fileData, trunkObj.Name);
        TrunksController.GetCoverage();
        test.stopTest();
        
    }
    
}