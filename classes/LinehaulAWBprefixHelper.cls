public class LinehaulAWBprefixHelper {

    
      public static void updateAWBPrefix(List<Linehaul__c> linehaulList) {

        
        Set<String> airlineNames = new Set<String>();

        for(Linehaul__c lh : linehaulList){
            if(String.isNotBlank(lh.Select_Airline__c)){
                airlineNames.add(lh.Select_Airline__c);
            }
        }

        if(airlineNames.isEmpty()) return;

        
        Map<String, AWB_Prefix__mdt> airlineToMetadataMap = new Map<String, AWB_Prefix__mdt>();

        for(AWB_Prefix__mdt meta : [ SELECT Airline_Name__c, Prefix__c FROM AWB_Prefix__mdt  WHERE Airline_Name__c IN :airlineNames]){
            airlineToMetadataMap.put(meta.Airline_Name__c, meta);
        }

     
        for(Linehaul__c lh : linehaulList){

            if(String.isNotBlank(lh.Select_Airline__c) &&
               airlineToMetadataMap.containsKey(lh.Select_Airline__c)){

                lh.AWB_Prefix__c = airlineToMetadataMap.get(lh.Select_Airline__c).Prefix__c;
            }
        }
    }
}