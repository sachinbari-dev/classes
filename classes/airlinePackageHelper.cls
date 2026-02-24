public class airlinePackageHelper {

    @InvocableMethod 
    public static void airlinePackageUpdate(List<Id> airlineId){
              set<id>  sealIds = new set<id>();
              
              List<Trunk__c> TList = new List<trunk__c>();
              List<Trunk__c> TrList = [select id, name,Left_Seal__c,Linehaul_tracking__c from Trunk__c where id IN:airlineId];
            
              for(Trunk__c tr : TrList){
                    if(tr.Left_Seal__c != null){
                        sealIds.add(tr.Left_Seal__c);
                    }
               }
                system.debug('seal ids' + sealIds);
        
            if(sealIds.size()>0){
                set<id> bagIds =  new set<id>();
                
                List<secure_bag__c> bagList = [select id , name,Seal_Id__c from Secure_Bag__c where id IN:sealIds ];
                 
                for(secure_bag__c  sb : bagList){
                    if(sb.Seal_Id__c != null){
                        bagIds.add(sb.id);
                    }
                }
                
                if(bagIds.size()>0){
                    for(id i : bagIds){
                        for (Trunk__c tr : TrList) {
                        if (tr.Left_Seal__c == i) {
                            tr.Number_of_SB__c = bagIds.size();
                            TList.add(tr);
                        } else {
                            tr.Number_of_SB__c = 0;
                            TList.add(tr);
                        }
                      }  
                   
                    }
                     update TList;
                }
                }
                
         /*     Map<Id, Integer> bagCountMap = new Map<Id, Integer>();
            
               for (AggregateResult ar : [SELECT Seal_Id__c, COUNT(Id) bagCount  FROM Secure_Bag__c WHERE Seal_Id__c IN :sealIds]) {
                
                   bagCountMap.put((Id) ar.get('Seal_Id__c'), (Integer) ar.get('bagCount'));
                 }
    
                   for (Trunk__c tr : TrList) {
                        if (tr.Left_Seal__c != null && bagCountMap.containsKey(tr.Left_Seal__c)) {
                            tr.Number_of_SB__c = bagCountMap.get(tr.Left_Seal__c); 
                            TList.add(tr);
                        } else {
                            tr.Number_of_SB__c = 0;
                            TList.add(tr);
                        }
                    }  
                   update TList;  */
                }
           
    
    
    public static void getCountAndUpdate( set<id> seadIds){
        
    }
}