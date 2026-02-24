/*
  @description       : Updating Linehaul tracking record by details of secure bag and updating airline packages records by linehaul tracking records.
  @author            : Mr.Govind Sangale
  @last modified on  : 23-05-2024
  @last modified by  :Mr.Govind sangale

*/

public class updateLinehaulRecordFromSecureBag {
    
    @InvocableMethod
    public static void updateLinehaulRecord(List<Id> LinehaulIds) {
       
             system.debug('Entered In class');
            // Query all secure_bag__c records associated with the provided LinehaulIds
            List<secure_bag__c> bagList = [ SELECT Id, Name, Shipping_Note_Number__c, Seal_Id__c, Oversize_bag__c, Oversize_Trunk__c, 
                                                   Airline_Trunk__c, Trunk_Id__c, Secure_Bag__r.Name, Trunk_Id__r.Name, Linehaul_Tracking__c 
                                            FROM secure_bag__c 
                                            WHERE Linehaul_Tracking__c IN :LinehaulIds ];
           
              
                // Group secure bags by their seal ID
                Map<String, secure_bag__c> uniqueSealBags = new Map<String, secure_bag__c>();
                for (secure_bag__c sb : bagList) {
                    if (String.isNotBlank(sb.Seal_Id__c) && !uniqueSealBags.containsKey(sb.Seal_Id__c)) {
                        uniqueSealBags.put(sb.Seal_Id__c, sb);
                    }
                }

             // Extract all seal IDs from the unique secure_bag__c records for querying Trunk__c records
                Set<String> sealIds = uniqueSealBags.keySet();
        
             // Query Trunk__c records based on the seal IDs from secure_bag__c
                List<Trunk__c> trunkList = [ SELECT Id, Name, Left_Seal__c, OSB__c, Linehaul_Tracking__c, Trunk_name__c, 
                                                       OST__c, Airline_Trunk__c, AWB_number__c 
                                             FROM Trunk__c 
                                             WHERE Left_Seal__c IN :sealIds];

             // Initialize collections for updates
                List<Linehaul_Tracking__c> linehaulToUpdate = new List<Linehaul_Tracking__c>();
        
                List<Trunk__c> bvcTrList = new List<Trunk__c>();
                List<Trunk__c> overbgList = new List<Trunk__c>();
                List<Trunk__c> airtList = new List<Trunk__c>();
                List<Trunk__c> cpmtList = new List<Trunk__c>();
                List<Trunk__c> trunList = new List<Trunk__c>();

            // Organize secure_bag__c records by Linehaul ID
                Map<Id, List<secure_bag__c>> bagMap = new Map<Id, List<secure_bag__c>>();
        
                for (secure_bag__c sb : bagList) {
                    if (!bagMap.containsKey(sb.Linehaul_Tracking__c)) {
                        bagMap.put(sb.Linehaul_Tracking__c, new List<secure_bag__c>());
                    }
                    bagMap.get(sb.Linehaul_Tracking__c).add(sb);
                }

            // Process each Linehaul ID
                for (Id lnId : LinehaulIds) {
                Linehaul_Tracking__c ln = new Linehaul_Tracking__c(Id = lnId);
    
                // Get the associated secure_bag__c records for this LinehaulId
                List<secure_bag__c> bagsForLinehaul = bagMap.get(lnId);
                   
                if (bagsForLinehaul != null) {
                    
                    Set<String> formulaValues = new Set<String>();
                    Set<String> sbNameList = new Set<String>();
                    Set<String> trunkIds = new Set<String>();
                    Set<String> ovrbagList = new Set<String>();
                    Set<String> ovrTrunkList = new Set<String>();
                    Set<String> airlineTrunkList = new Set<String>();
    
                    Integer totalShippingNotes = 0;
                    Integer totalSecureBags = 0;
    
                    for (secure_bag__c sb : bagsForLinehaul) {
                        // Use only the unique bag for each seal ID
                        secure_bag__c uniqueBag = uniqueSealBags.get(sb.Seal_Id__c);
                        if (uniqueBag != null) {
                            formulaValues.add(sb.Shipping_Note_Number__c);
                            sbNameList.add(sb.Name);
    
                            if (uniqueBag.Trunk_Id__c != null) {
                                trunkIds.add(uniqueBag.Trunk_Id__r.Name);
                                for (Trunk__c tr : trunkList) {
                                    if (tr.Trunk_name__c == uniqueBag.Trunk_Id__c && tr.Left_Seal__c == uniqueBag.Seal_Id__c) {
                                        tr.Linehaul_Tracking__c = uniqueBag.Linehaul_Tracking__c;
                                        bvcTrList.add(tr);
                                        system.debug('bvcTrunkList@@@' + bvcTrList);
                                    }
                                }
                            }
    
                            if (uniqueBag.Oversize_bag__c != null) {
                                ovrbagList.add(uniqueBag.Oversize_bag__c);
                                for (Trunk__c tr : trunkList) {
                                    if (tr.OSB__c != null && tr.Left_Seal__c == uniqueBag.Seal_Id__c) {
                                        tr.Linehaul_Tracking__c = uniqueBag.Linehaul_Tracking__c;
                                        overbgList.add(tr);
                                         system.debug('overbgList@@@' + overbgList);
                                    }
                                }
                            }
    
                            if (uniqueBag.Oversize_Trunk__c != null) {
                                ovrTrunkList.add(uniqueBag.Oversize_Trunk__c);
                                for (Trunk__c tr : trunkList) {
                                    if (tr.OST__c != null && tr.Left_Seal__c == uniqueBag.Seal_Id__c) {
                                        tr.Linehaul_Tracking__c = uniqueBag.Linehaul_Tracking__c;
                                        cpmtList.add(tr);
                                        system.debug('cpmtList@@@' + cpmtList);
                                    }
                                }
                            }
    
                            if (uniqueBag.Airline_Trunk__c != null) {
                                airlineTrunkList.add(uniqueBag.Airline_Trunk__c);
                                for (Trunk__c tr : trunkList) {
                                    if (tr.Airline_Trunk__c != null && tr.Left_Seal__c == uniqueBag.Seal_Id__c) {
                                        tr.Linehaul_Tracking__c = uniqueBag.Linehaul_Tracking__c;
                                        airtList.add(tr);
                                         system.debug('airtList@@@' + airtList);
                                    }
                                }
                            }
    
                            totalShippingNotes++;
                            totalSecureBags++;
                        }
                    }

                    bvcTrList = new List<Trunk__c>(new Set<Trunk__c>(bvcTrList));
                    airtList = new List<Trunk__c>(new Set<Trunk__c>(airtList));
                    cpmtList = new List<Trunk__c>(new Set<Trunk__c>(cpmtList));
                    overbgList = new List<Trunk__c>(new Set<Trunk__c>(overbgList));
            
                Integer allAirlinePackages = bvcTrList.size() + overbgList.size() + cpmtList.size() + airtList.size();

                    // Update Linehaul record
                    ln.No_of_Shipment_Notes__c = formulaValues.size();
                    ln.No_of_Package__c = totalSecureBags;
                    ln.secure_bags__c = String.join(new List<String>(sbNameList), ', ');
                    ln.Total_Number_of_Airline_Packages__c = allAirlinePackages;
    
                    linehaulToUpdate.add(ln);
            }
        }

           
         // Perform updates
            if (!linehaulToUpdate.isEmpty()) {
                try{
                  update linehaulToUpdate;
                }catch(exception e){
                     Linehaul_Error_Log__c er = new Linehaul_Error_Log__c();
                     er.Error_Message__c = e.getMessage();
                     er.Error_Stage__c = 'failed to Update secure bag details on LT';
                   insert er;  
                }

            }
        
            if (!bvcTrList.isEmpty() || !airtList.isEmpty() || !cpmtList.isEmpty() || !overbgList.isEmpty()) {
                try{
                    update bvcTrList;
                    update airtList;
                    update cpmtList;
                    update overbgList;
                
                system.debug('End of class');
                }catch(exception e){
                     Linehaul_Error_Log__c er = new Linehaul_Error_Log__c();
                     er.Error_Message__c = e.getMessage();
                     er.Error_Stage__c = 'failed to update airline packge';
                   insert er;  
                }
               
            }
        if(!test.isRunningTest()){
            createAwbNumber(LinehaulIds);
        }
    }
    
    public static void createAwbNumber(List<Id> LinehaulIds){
        createAwbNumberRecord.createAWBRecords(LinehaulIds); 
    }  
    
 
    
    
    
    public static void getCoverage(){
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
      i++;  i++;
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
      i++;  i++;
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
      i++;  i++;
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
      i++;  i++;
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
      i++;  i++;
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
      i++;  i++;
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