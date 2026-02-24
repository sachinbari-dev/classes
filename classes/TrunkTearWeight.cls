public class TrunkTearWeight {
    
    @InvocableMethod
    public static void trunkTearWeightCalculator(List<Trunk__c> TrunkIds1) {
        
        Set<Id> trunkIds = new Set<Id>();
        Set<Id> trTrunkIds = new Set<Id>();
        Set<Id> lnIds = new Set<Id>();
        Decimal totalTrunksWeight = 0;
        
        for(Trunk__c trunk : TrunkIds1) {
            if(trunk.Trunk_name__c != null) {
                trunkIds.add(trunk.Trunk_name__c);
                trTrunkIds.add(trunk.Id);
                lnIds.add(trunk.linehaul_tracking__c);
            }
        }
        
        System.debug('for checking trunkIds' + trunkIds);
        
        List<Secure_Bag__c> secureBagList = [SELECT Id, Name, Trunk_Id__r.Name, Bag_Gross_Weight__c, Trunk_Id__c
                                             FROM Secure_Bag__c WHERE Trunk_Id__c IN :trunkIds];
        System.debug('for checking secureBagList ' + secureBagList);
        
        List<Secure_Packaging__c> secPackTrunkList1 = [Select Id,Name, Trunk_Tear_Weight__c From Secure_Packaging__c Where Id IN: trunkIds];
        system.debug('for checking secPackTrunkList1 '+ secPackTrunkList1);
        
        List<Trunk__c> trunkListToUpdate = new List<Trunk__c>();
        trunkListToUpdate = [SELECT Id, Name, Trunk_Tear_Weight__c, Trunk_weight__c, Trunk_name__c
                             FROM Trunk__c WHERE Id IN :trTrunkIds];
        System.debug('for checking trunkListToUpdate '+trunkListToUpdate);
        
        Map<Id, Trunk__c> trunkMap = new Map<Id, Trunk__c>();
        if(!secureBagList.isEmpty()) {
            for(Trunk__c trunkObj : trunkListToUpdate) {
                
                Decimal bagGrossWeight = 0;
                Decimal securePackingTrunkWeight = 0;
                
                for(Secure_Bag__c secBagObj : secureBagList) {
                    if(secBagObj.Bag_Gross_Weight__c != Null){
                        if(secBagObj.Trunk_Id__c == trunkObj.Trunk_name__c) {
                            bagGrossWeight += secBagObj.Bag_Gross_Weight__c;
                            System.debug('for checking bagGrossWeight '+bagGrossWeight);
                        }
                        
                    }
                    
                }
                
                System.debug('for checking bagGrossWeight11 '+bagGrossWeight);
                for(Secure_Packaging__c scTr : secPackTrunkList1) {
                    if(scTr.Trunk_Tear_Weight__c != Null){
                        if(scTr.id == trunkObj.Trunk_name__c) {
                            securePackingTrunkWeight = scTr.Trunk_Tear_Weight__c;
                            trunkObj.Trunk_Tear_Weight__c = securePackingTrunkWeight;
                            trunkMap.put(trunkObj.Id, trunkObj);
                            
                            System.debug('for checking scTr.Name : ' + scTr.Name);
                        }
                    }
                }
                
                System.debug('for checking trunkObj.Id : ' + trunkObj.Id);
                System.debug('for checking BagGrossWeight : ' + bagGrossWeight);
                System.debug('for checking securePackingTrunkWeight : ' + securePackingTrunkWeight);
                
                trunkObj.Trunk_weight__c = securePackingTrunkWeight + bagGrossWeight;
                trunkMap.put(trunkObj.Id, trunkObj);
                
                totalTrunksWeight += trunkObj.Trunk_weight__c;
                
            }
        }
        
        System.debug('for checking trunkMap.values() '+trunkMap.values());
        if(!trunkMap.isEmpty()) {
            update trunkMap.values();
            
            List<Linehaul_Tracking__c> lnList = new List<Linehaul_Tracking__c>();
            lnList = [Select Id, Name, Trunks_Weight_Kgs__c From Linehaul_Tracking__c Where Id IN:lnIds];
            
            List<Linehaul_Tracking__c> updateLnList = new List<Linehaul_Tracking__c>();
            for(Linehaul_Tracking__c lnObj : lnList){
                lnObj.Trunks_Weight_Kgs__c = totalTrunksWeight;
                updateLnList.add(lnObj);
            }
            
            if(updateLnList.size()>0){
                update updateLnList;
            }
            
        }
    }
}