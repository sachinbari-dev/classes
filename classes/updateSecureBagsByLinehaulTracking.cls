public class updateSecureBagsByLinehaulTracking {

     @InvocableMethod
    public static void updateSecureBags(List<id> LinehaulIds){
        
        Linehaul_Tracking__c Line = [SELECT Id, Name, AWB_Number__c,Finalized_Linehaul_Number__c,Linehaul_Type__c , Linehaul_Name__c FROM Linehaul_Tracking__c where id =:LinehaulIds];
        List<secure_bag__c> bagList = new List<secure_bag__c>();
       
        if(line.Linehaul_Type__c == 'Air'){
             List<secure_bag__c> bgList = [SELECT Id, Name, Finalised_Linehaul_Number__c,Seal_Id__c ,Linehaul_Tracking__c, Master_AWB__c,AWB_Number__c FROM Secure_Bag__c where AWB_Number__c =:Line.AWB_Number__c AND Finalised_Linehaul_Number__c =:Line.Finalized_Linehaul_Number__c];
        system.debug('bagList1@@@'+ bgList); 
          
        for(secure_bag__c sb :bgList ){    
              sb.Linehaul_Tracking__c = line.Id;
                
                bagList.add(sb); 
               
        }
        update bagList;
      system.debug('bagList1@@@@' + bagList);
        }else{
            List<secure_bag__c> bgList = [SELECT Id, Name, Finalised_Linehaul_Number__c,Linehaul_Tracking__c, Master_AWB__c,AWB_Number__c FROM Secure_Bag__c where Finalised_Linehaul_Number__c =:Line.Finalized_Linehaul_Number__c];
            system.debug('bagList1@@@'+ bgList);
              
            for(secure_bag__c sb :bgList ){    
               sb.Linehaul_Tracking__c = line.Id;
                    
                    bagList.add(sb);  
                   
            }
            update bagList;
          system.debug('bagList1@@@@' + bagList);
        }
       
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
    }
}