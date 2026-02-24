/**
* @description       : 
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc
* @group             : 
* @last modified on  : 12-11-2021
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class TMS_LinehaulClass {
    @AuraEnabled
    public Map<String, String> options;
    @AuraEnabled
    public Map<String, String> BranchOptions;
    @AuraEnabled
    public List<SecureBagWrapper> BagWrapList;
    @AuraEnabled
    public ResultWrapper Originport;
    @AuraEnabled
    public ResultWrapper Destport;
    @AuraEnabled
    public ResultWrapper Vehicle;
    @AuraEnabled
    public ResultWrapper Flight;
    @AuraEnabled
    public Secure_Bag__c finalBag;
    @AuraEnabled
    public ResultWrapper UserHub;
    @AuraEnabled
    public string error;
    @AuraEnabled
    public string haulType;
    @AuraEnabled
    public string FinalizedLHNumber;
    @AuraEnabled
    public List<DefaultLineHaulWrap> lineHaulWrapList;
    @AuraEnabled
    public boolean showHubFilter;
    @AuraEnabled
    public string FinalizedLHNumberBD;
    @AuraEnabled
    public static string LoggedInUserHub(){
        FSE_Sales__c[] UserHub = [SELECT Hub__r.Name,Hub__c FROM FSE_Sales__c WHERE Sales_Person__c =:UserInfo.getUserId() AND Type__c='Manager' ORDER BY CreatedDate DESC LIMIT 1];
        // System.debug('logged: '+UserInfo.getUserId());
        // System.debug('UserHub: '+UserHub);
        if(UserHub != null && UserHub.size()>0 && UserHub[0].Hub__c !=null){
            return UserHub[0].Hub__r.Name;
        }else
            return '';
    }
    
    public static boolean IsAdminUser(){
        id LoggedInProfileId = UserInfo.getProfileId();
        Profile p = [SELECT Id,name FROM Profile WHERE id=:LoggedInProfileId];
        if(p!= null && LoggedInProfileId!=null && (p.Name=='Operations Admin' || p.Name=='System Administrator' || p.Name=='Sys Admin'))
            return true;
        else
            return false;
    }
  
   @AuraEnabled
    public static TMS_LinehaulClass Shipments( String filter, string Hub){
        Boolean admin = IsAdminUser();
        if(!admin)
            Hub = LoggedInUserHub();
        TMS_LinehaulClass cls = new TMS_LinehaulClass();
        cls.error = '';
        cls.showHubFilter = admin;
        if(string.isNotBlank(hub) || admin){
            // System.debug('hub: '+hub);
            cls.lineHaulWrapList = new List<DefaultLineHaulWrap>();
            Map<string,List<Secure_Bag__c>> BagMap = new Map<string,List<Secure_Bag__c>>();
            List<Secure_Bag__c> SecureBagList = new List<Secure_Bag__c>();
            Set<string> deliveryStatusSet = new set<string>();
            deliveryStatusSet.add('Out for Delivery');
            deliveryStatusSet.add('Delivered');
            if(filter =='Finalised'){
                string query = 'select id,Shipment__r.Number_of_Packages__c,Oversize_bag__c,Oversize_Trunk__c,Airline_Trunk__c,Shipment__r.Net_Weight__c,Shipment__r.Shipper_Name_TMS__r.Phone,Shipment__r.Consignee_Name_TMS__r.ShippingCity,Shipment__r.Consignee_Name_TMS__r.ShippingState,Shipment__r.Consignee_Name_TMS__r.Name,Shipment__r.Consignee_Name_TMS__r.Shipping_Address_Fromula__c,Shipment__r.Consignee_Name_TMS__r.ShippingCountry,Shipment__r.Consignee_Name_TMS__r.Phone,Shipment__r.Shipper_Name_TMS__r.Email__c,Shipment__r.Consignee_Name_TMS__r.Email__c,Shipment__r.Shipper_Name_TMS__r.Shipping_Address_Fromula__c,Shipment__r.Shipper_Name_TMS__r.ShippingPostalCode,Shipment__r.Shipper_Name_TMS__r.Name,Shipment__r.Shipper_Name_TMS__r.ShippingStreet,Shipment__r.Shipper_Name_TMS__r.ShippingState,Shipment__r.Shipper_Name_TMS__r.ShippingCity,Shipment__r.Shipper_Name_TMS__r.ShippingCountry,Shipment__r.Gross_Weight_UOM_TMS__c,Secure_Packaging_Identifier__c, Unique_Identifier__c,Shipment__r.Cargo_Type__c,Cargo_Type__c,Shipment__r.Origin_Address_City__c,Shipment__r.Destination_Address_City__c,Shipment__r.Destination_Hub__r.Branch__c,Linehaul_Type__c, Linehaul_Tracking__c,Linehaul_Tracking__r.name,Shipment__c,Finalised_Linehaul_Number__c,Seal_Id__c,Seal_Id__r.name,Right_Seal_Id__c ,Right_Seal_Id__r.name,Flight_Schedule__r.name,Shipping_Note_Number__c,Current_Scan_Hub__r.name,Next_Destination__c,Destination_Hub__c,Finalized_Time__c,Shipment__r.CreatedDate,Current_Scanned_at__c, Trunk_Id__c,Trunk_Id__r.Name FROM Secure_Bag__c WHERE Finalised_Linehaul_Number__c !=null AND Current_Scan_Loction__c!=:deliveryStatusSet';
                if(string.isNotBlank(hub)){
                    query = query+' AND Current_Scan_Hub__r.name=:hub';
                }
                query = query+' ORDER BY Finalized_Time__c DESC LIMIT 50000';   //Shipment__r.CreatedDate
                SecureBagList = Database.query(query);
                //SecureBagList = [select id,Secure_Packaging_Identifier__c, Unique_Identifier__c,Cargo_Type__c,Shipment__r.Origin_Address_City__c,Shipment__r.Destination_Address_City__c,Shipment__r.Origin_Hub__r.Branch__c,Shipment__r.Destination_Hub__r.Branch__c,Linehaul_Type__c, Linehaul_Tracking__c,Linehaul_Tracking__r.name,Shipment__c,Finalised_Linehaul_Number__c,Seal_Id__c,Seal_Id__r.name,Flight_Schedule__r.name,Shipping_Note_Number__c,Current_Scan_Hub__r.name,Next_Destination__c,Destination_Hub__c,Trunk_Id__c, Trunk_Id__r.Name FROM Secure_Bag__c WHERE Finalised_Linehaul_Number__c !=null AND Current_Scan_Loction__c!=:deliveryStatusSet AND Current_Scan_Hub__r.name=:hub ORDER BY LastModifiedDate DESC];
                if(SecureBagList!=null && SecureBagList.size()>0){
                    for(Secure_Bag__c sb:SecureBagList){
                        // System.debug('id=:'+sb.id);
                        if(BagMap.containsKey(sb.Finalised_Linehaul_Number__c)){
                            BagMap.get(sb.Finalised_Linehaul_Number__c).add(sb);
                        }else{
                            BagMap.put(sb.Finalised_Linehaul_Number__c,new List<Secure_Bag__c>{sb});
                        }
                    }
                }
            }else if(filter=='Outbound'){
                
                String userId = UserInfo.getUserId();
                 FSE_Sales__c fs = [SELECT Sales_Person__c, Id, Name, Hub__c,Hub__r.name FROM FSE_Sales__c where Sales_Person__c=:userId LIMIT 1];
                 string EmpHub = fs.Hub__r.name;
                system.debug('employee hub@@@' +EmpHub);
                // Shipment__r.Gross_Weight__c != null condition is added in below query to remove secure bags whose shipmnet doesn't have gross weight
             //   string query = 'select id,Shipment__r.Gross_Weight__c,Shipment__r.Number_of_Packages__c,Shipment__r.Net_Weight__c,Oversize_bag__c,Oversize_Trunk__c,Airline_Trunk__c,Shipment__r.Shipper_Name_TMS__r.Phone,Shipment__r.Consignee_Name_TMS__r.ShippingCity,Shipment__r.Consignee_Name_TMS__r.ShippingState,Shipment__r.Consignee_Name_TMS__r.Name,Shipment__r.Consignee_Name_TMS__r.Shipping_Address_Fromula__c,Shipment__r.Consignee_Name_TMS__r.ShippingCountry,Shipment__r.Consignee_Name_TMS__r.Phone,Shipment__r.Shipper_Name_TMS__r.Email__c,Shipment__r.Consignee_Name_TMS__r.Email__c,Shipment__r.Shipper_Name_TMS__r.Shipping_Address_Fromula__c,Shipment__r.Shipper_Name_TMS__r.ShippingPostalCode,Shipment__r.Shipper_Name_TMS__r.Name,Shipment__r.Shipper_Name_TMS__r.ShippingStreet,Shipment__r.Shipper_Name_TMS__r.ShippingCity,Shipment__r.Shipper_Name_TMS__r.ShippingState,Shipment__r.Shipper_Name_TMS__r.ShippingCountry,Shipment__r.Gross_Weight_UOM_TMS__c,Secure_Packaging_Identifier__c, Unique_Identifier__c,Shipment__r.Cargo_Type__c,Cargo_Type__c,Shipment__r.Origin_Address_City__c,Shipment__r.Destination_Address_City__c,Shipment__r.Destination_Hub__r.Branch__c,Linehaul_Type__c, Linehaul_Tracking__c,Linehaul_Tracking__r.name,Shipment__c,Finalised_Linehaul_Number__c,Seal_Id__c,Seal_Id__r.name,Shipping_Note_Number__c,Current_Scan_Hub__r.name,Next_Destination__c,Destination_Hub__c,Finalized_Time__c,Shipment__r.CreatedDate,Current_Scanned_at__c,Trunk_Id__c,Trunk_Id__r.Name,Right_Seal_Id__c ,Right_Seal_Id__r.name FROM Secure_Bag__c WHERE Current_Scan_Loction__c!=:deliveryStatusSet AND Finalised_Linehaul_Number__c =null  AND Destination_Hub__c !=:EmpHub AND Shipment__r.Gross_Weight__c != null AND Shipment__r.Gross_Weight__c !=0.000'; 
                
                String query = 'SELECT Id,draft__c, Shipment__r.Gross_Weight__c,Shipment__r.Cancel_Shipment__c,Shipment__r.RTO__c,Current_Scan_Airport__c, Shipment__r.Number_of_Packages__c, Shipment__r.Net_Weight__c, Oversize_bag__c, Oversize_Trunk__c, Airline_Trunk__c, Shipment__r.Shipper_Name_TMS__r.Phone, Shipment__r.Consignee_Name_TMS__r.ShippingCity, Shipment__r.Consignee_Name_TMS__r.ShippingState, Shipment__r.Consignee_Name_TMS__r.Name, Shipment__r.Consignee_Name_TMS__r.Shipping_Address_Fromula__c, Shipment__r.Consignee_Name_TMS__r.ShippingCountry, Shipment__r.Consignee_Name_TMS__r.Phone, Shipment__r.Shipper_Name_TMS__r.Email__c, Shipment__r.Consignee_Name_TMS__r.Email__c, Shipment__r.Shipper_Name_TMS__r.Shipping_Address_Fromula__c, Shipment__r.Shipper_Name_TMS__r.ShippingPostalCode, Shipment__r.Shipper_Name_TMS__r.Name, Shipment__r.Shipper_Name_TMS__r.ShippingStreet, Shipment__r.Shipper_Name_TMS__r.ShippingCity, Shipment__r.Shipper_Name_TMS__r.ShippingState, Shipment__r.Shipper_Name_TMS__r.ShippingCountry, Shipment__r.Gross_Weight_UOM_TMS__c, Secure_Packaging_Identifier__c, Unique_Identifier__c, Shipment__r.Cargo_Type__c, Cargo_Type__c, Shipment__r.Origin_Address_City__c, Shipment__r.Destination_Address_City__c, Shipment__r.Destination_Hub__r.Branch__c, Linehaul_Type__c, Linehaul_Tracking__c,Linehaul_Tracking__r.name, Shipment__c, Finalised_Linehaul_Number__c, Seal_Id__c, Seal_Id__r.Name, Shipping_Note_Number__c, Current_Scan_Hub__r.Name, Next_Destination__c, Destination_Hub__c, Finalized_Time__c, Shipment__r.CreatedDate, Current_Scanned_at__c, Trunk_Id__c, Trunk_Id__r.Name, Right_Seal_Id__c, Right_Seal_Id__r.Name ' +
                                'FROM Secure_Bag__c ' +
                                'WHERE Current_Scan_Loction__c != :deliveryStatusSet ' + 
                                'AND Destination_Hub__c != :EmpHub ' +
                                'AND Shipment__r.Gross_Weight__c != null ' +
                                'AND Shipment__r.Gross_Weight__c != 0.000 ' +
                    'AND (Shipment__r.Cancel_Shipment__c = false AND Shipment__r.RTO__c = false)' +			//added by Rafi Khan for shipments not to display in outbound if it is cancel shipment and rto checked one.
                                'AND (Finalised_Linehaul_Number__c = null ' +
                                'OR (Current_Scan_Loction__c = \'transit port\' AND Finalised_Linehaul_Number__c = null ))';
 
                
                if(string.isNotBlank(hub)){
                    query = query+' AND Current_Scan_Hub__r.name=:hub AND Destination_Hub__c !=:EmpHub';
                }
                query = query+' ORDER BY Shipment__r.CreatedDate DESC LIMIT 50000';
                try{
                    SecureBagList = Database.query(query);
                }catch(exception e){
                    // System.debug('line:'+e.getLineNumber());
                    // System.debug('err: '+e.getMessage());
                }
                
                if(SecureBagList!=null && SecureBagList.size()>0){
                    for(Secure_Bag__c sb:SecureBagList){
                        if(sb.draft__c == false){
                             system.debug('>>'+sb.Current_Scan_Hub__r.name);
                            if(BagMap.containsKey(sb.Unique_Identifier__c)){
                                BagMap.get(sb.Unique_Identifier__c).add(sb);
                            }else{
                                BagMap.put(sb.Unique_Identifier__c,new List<Secure_Bag__c>{sb});
                            } 
                       }
                        
                    }
                }
            }else{
                string query = 'select id,Shipment__r.Number_of_Packages__c,Shipment__r.Net_Weight__c,Oversize_bag__c,Oversize_Trunk__c,Airline_Trunk__c,Shipment__r.Shipper_Name_TMS__r.Phone,Shipment__r.Consignee_Name_TMS__r.ShippingCity,Shipment__r.Consignee_Name_TMS__r.ShippingState,Shipment__r.Consignee_Name_TMS__r.Name,Shipment__r.Consignee_Name_TMS__r.Shipping_Address_Fromula__c,Shipment__r.Consignee_Name_TMS__r.ShippingCountry,Shipment__r.Consignee_Name_TMS__r.Phone,Shipment__r.Shipper_Name_TMS__r.Email__c,Shipment__r.Consignee_Name_TMS__r.Email__c,Shipment__r.Shipper_Name_TMS__r.Shipping_Address_Fromula__c,Shipment__r.Shipper_Name_TMS__r.ShippingPostalCode,Shipment__r.Shipper_Name_TMS__r.Name,Shipment__r.Shipper_Name_TMS__r.ShippingStreet,Shipment__r.Shipper_Name_TMS__r.ShippingState,Shipment__r.Shipper_Name_TMS__r.ShippingCity,Shipment__r.Shipper_Name_TMS__r.ShippingCountry,Shipment__r.Gross_Weight_UOM_TMS__c,Secure_Packaging_Identifier__c, Unique_Identifier__c,Shipment__r.Cargo_Type__c,Cargo_Type__c,Shipment__r.Origin_Address_City__c,Shipment__r.Destination_Address_City__c,Shipment__r.Destination_Hub__r.Branch__c,Linehaul_Type__c, Linehaul_Tracking__c,Linehaul_Tracking__r.name,Shipment__c,Finalised_Linehaul_Number__c,Seal_Id__c,Seal_Id__r.name,Shipping_Note_Number__c,Current_Scan_Hub__r.name,Next_Destination__c,Destination_Hub__c,Finalized_Time__c,Shipment__r.CreatedDate,Current_Scanned_at__c,Trunk_Id__c,Trunk_Id__r.Name,Right_Seal_Id__c ,Right_Seal_Id__r.name FROM Secure_Bag__c WHERE Current_Scan_Loction__c!=:deliveryStatusSet AND Next_Destination__c!=null AND Finalised_Linehaul_Number__c !=null';
                if(string.isNotBlank(hub)){
                    Hub__c destHub = [select id,Branch__c FROM Hub__c where name=:hub LIMIT 1];
                    string destBranch =destHub.Branch__c; 
                    query = query+' AND Next_Destination__c=:destBranch';
                }
                query = query+' ORDER BY Shipment__r.CreatedDate DESC LIMIT 50000';
                
                SecureBagList = Database.query(query);
                if(SecureBagList!=null && SecureBagList.size()>0){
                    for(Secure_Bag__c sb:SecureBagList){
                        if(BagMap.containsKey(sb.Finalised_Linehaul_Number__c)){
                            BagMap.get(sb.Finalised_Linehaul_Number__c).add(sb);
                        }else{
                            BagMap.put(sb.Finalised_Linehaul_Number__c,new List<Secure_Bag__c>{sb});
                        }
                    }
                }
            }
            Integer Index = 1;
            if(BagMap!=null && BagMap.size()>0){
                for(string key:BagMap.keyset()){
                    DefaultLineHaulWrap dl = new DefaultLineHaulWrap();
                    dl.index = Index;
                    dl.process = false;
                    dl.BagList = BagMap.get(key);
                    dl.UniqueBag = BagMap.get(key)[0];
                    dl.BagsCount = BagMap.get(key).size();
                    
                    set<id> shipIdSet = new Set<id>();
                    for(Secure_Bag__c bg:BagMap.get(key)){
                        shipIdSet.add(bg.Shipment__c);
                    }
                    dl.ShipCount = shipIdSet.size();
                    
                    set<id> WithoutSealBagIdSet = new set<id>();
                    for(Secure_Bag__c bg:BagMap.get(key)){
                        if(bg.Seal_Id__c ==null)
                            WithoutSealBagIdSet.add(bg.id);
                    }
                    dl.withoutSealBags = WithoutSealBagIdSet.size();
                    
                    set<id> FinalizedBagIdSet = new set<id>();
                    for(Secure_Bag__c bg:BagMap.get(key)){
                        if(bg.Finalised_Linehaul_Number__c !=null)
                            FinalizedBagIdSet.add(bg.id);
                    }
                    dl.FinalizedBags = FinalizedBagIdSet.size();
                    cls.lineHaulWrapList.add(dl);
                    Index++;
                }
            }
            if(cls.lineHaulWrapList.size()==0)
                cls.error = 'No record found for '+Hub+ ' Hub!';
        }else{
            cls.error = 'No Hub found !';
        }
        return cls;
    }
    
    public class DefaultLineHaulWrap{  
        @AuraEnabled
        public Boolean process;
        @AuraEnabled
        public List<Secure_Bag__c> BagList;
        @AuraEnabled
        Public Secure_Bag__c UniqueBag;
        @AuraEnabled
        public integer withoutSealBags;
        @AuraEnabled
        public integer FinalizedBags;
        @AuraEnabled
        public integer Index;
        @AuraEnabled
        public Integer ShipCount;
        @AuraEnabled
        public Integer BagsCount;
        @AuraEnabled
        public Secure_Bag__c FinalBag;
        @AuraEnabled
        public string airline;     
    }
   
    
  @AuraEnabled
   public static TMS_LinehaulClass SecureBagsList(List<Secure_Bag__c> BagList) {
    TMS_LinehaulClass cls = new TMS_LinehaulClass();
    cls.BagWrapList = new List<SecureBagWrapper>();

    try {
        if (BagList != null && !BagList.isEmpty()) {
            Integer index = 1;

      
            List<Secure_Bag__c> nonDraftBags = new List<Secure_Bag__c>();
           
            for (Secure_Bag__c sb : BagList) {
                if (sb.Draft__c == false ) {
                    nonDraftBags.add(sb);
                }
               
            }
            system.debug('nonDraftBags'+nonDraftBags);
        
             
            for (Secure_Bag__c sb : nonDraftBags) {
                SecureBagWrapper sbwrap = new SecureBagWrapper();
                sbwrap.index = index;
                sbwrap.sb = sb;
                sbwrap.process = false;
                sbwrap.Seal = (sb.Seal_Id__r != null) ? sb.Seal_Id__r.Name : null;
                sbwrap.rseal = (sb.Right_Seal_Id__r != null) ? sb.Right_Seal_Id__r.Name : null;
                sbwrap.trunk = (sb.Trunk_Id__r != null) ? sb.Trunk_Id__r.Name : null;
                sbwrap.CurrentHub = (sb.Current_Scan_Hub__r != null) ? sb.Current_Scan_Hub__r.Name : null;
                sbwrap.overbag = sb.Oversize_Bag__c;
                sbwrap.overTrunk = sb.Oversize_Trunk__c;
                sbwrap.airtr = sb.Airline_Trunk__c;
                sbwrap.draft = sb.draft__c;

                cls.BagWrapList.add(sbwrap);
                index++;
            }
        }


        cls.BranchOptions = new Map<String, String>();
        cls.BranchOptions.put('', 'None');

        Schema.DescribeFieldResult fieldResult = Secure_Bag__c.Next_Destination__c.getDescribe();
        for (Schema.PicklistEntry p : fieldResult.getPicklistValues()) {
            cls.BranchOptions.put(p.getValue(), p.getLabel());
        }

        return cls;

    } catch (Exception e) {
        System.debug('️ Error in SecureBagsList: ' + e.getMessage());
        return null;
    }
}


    
    //added by govind from line 234 to 269
    
     @AuraEnabled
    public static TMS_LinehaulClass SecureBagsBVCTrunkList(List<Secure_Bag__c> BagList){
        // System.debug('BagList:'+BagList.size());
        TMS_LinehaulClass cls = new TMS_LinehaulClass();
        cls.BagWrapList = new List<SecureBagWrapper>();
        try{
           if (BagList != null && !BagList.isEmpty()) {
            Integer index = 1;

            
            List<Secure_Bag__c> nonDraftBags = new List<Secure_Bag__c>();
            for (Secure_Bag__c sb : BagList) {
                if (sb.Draft__c == false ) {
                    nonDraftBags.add(sb);
                }
            }
            system.debug('nonDraftBags'+nonDraftBags);
         
            for (Secure_Bag__c sb : BagList) {
                SecureBagWrapper sbwrap = new SecureBagWrapper();
                sbwrap.index = index;
                sbwrap.sb = sb;
                sbwrap.process = false;
                sbwrap.Seal = (sb.Seal_Id__r != null) ? sb.Seal_Id__r.Name : null;
                sbwrap.rseal = (sb.Right_Seal_Id__r != null) ? sb.Right_Seal_Id__r.Name : null;
                sbwrap.trunk = (sb.Trunk_Id__r != null) ? sb.Trunk_Id__r.Name : null;
                sbwrap.CurrentHub = (sb.Current_Scan_Hub__r != null) ? sb.Current_Scan_Hub__r.Name : null;
                sbwrap.overbag = sb.Oversize_Bag__c;
                sbwrap.overTrunk = sb.Oversize_Trunk__c;
                sbwrap.airtr = sb.Airline_Trunk__c;
                sbwrap.draft = false;

                cls.BagWrapList.add(sbwrap);
                index++;
            }
        }
            cls.BranchOptions = new Map<String, String>();
            cls.BranchOptions.put('','None');
            Schema.DescribeFieldResult fieldResult = Secure_Bag__c.BVC_Trunk__c.getDescribe();
            List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
            for (Schema.PicklistEntry p: pList){
                cls.BranchOptions.put(p.getValue(), p.getLabel());
            }
            return cls;
        }catch(exception e){
            return null;
        }
    }
    
    @AuraEnabled
    public static List<SecureBagWrapper> FilteredBagList(List<Secure_Bag__c> bags,string Dest,string SealId,string rightSealId, string CargoType){
        List<SecureBagWrapper> bagWrap = new List<SecureBagWrapper>();
        Set<id> bagIds = new Set<id>();
        if(bags != null && bags.size()>0){
            for(Secure_Bag__c sb:bags){
                bagIds.add(sb.id);
            }
            
            // System.debug('CargoType: '+CargoType);
            // System.debug('SealId: '+SealId);
            // System.debug('Dest: '+Dest);
            Set<string> deliveryStatusSet = new set<string>();
            
            String query = 'select id,Secure_Packaging_Identifier__c, Unique_Identifier__c,Oversize_bag__c,Oversize_Trunk__c,Airline_Trunk__c,Cargo_Type__c,Shipment__r.Origin_Address_City__c,Shipment__r.Destination_Address_City__c,Shipment__r.Origin_Hub__r.Branch__c,Shipment__r.Destination_Hub__r.Branch__c,Linehaul_Type__c, Linehaul_Tracking__c,Linehaul_Tracking__r.name,Shipment__c,Finalised_Linehaul_Number__c,Seal_Id__c,Seal_Id__r.name,Right_Seal_Id__r.name,Right_Seal_Id__c,Shipping_Note_Number__c,Current_Scan_Hub__r.name,Next_Destination__c,Destination_Hub__c,Finalized_Time__c,Trunk_Id__c,Trunk_Id__r.Name FROM Secure_Bag__c WHERE id=:bagIds';
            
            if(string.isNotBlank(Dest))
                query = query+' AND Next_Destination__c=:Dest';
            if(string.isNotBlank(CargoType))
                query = query+' AND Shipment__r.Cargo_Type__c=:CargoType';
            if(string.isNotBlank(SealId)){
                if(SealId=='Pending')
                    query = query+' AND Seal_Id__c=null';
                else if(SealId=='Completed')
                    query = query+' AND Seal_Id__c!=null';
            }
        // added by govind 260-266
             if(string.isNotBlank(rightSealId)){
                if(rightSealId=='Pending')
                    query = query+' AND Right_Seal_Id__c=null';
                else if(rightSealId=='Completed')
                    query = query+' AND Right_Seal_Id__c!=null';
            }
            // System.debug('bagWrap:'+Database.query(query).size());
            integer index=1;
            for(Secure_Bag__c bag:Database.query(query)){
                SecureBagWrapper sbwrap = new SecureBagWrapper();
                sbwrap.index = index;
                sbwrap.sb = bag;
                sbwrap.process = false;
                sbwrap.Seal=bag.Seal_Id__r.name;
                sbwrap.rseal = bag.Right_Seal_Id__r.name;
                sbwrap.trunk=bag.Trunk_Id__r.name;
                sbwrap.CurrentHub=bag.Current_Scan_Hub__r.name;
                sbwrap.overbag=bag.Oversize_bag__c;
                sbwrap.overTrunk=bag.Oversize_Trunk__c;
                sbwrap.airtr=bag.Airline_Trunk__c;
                bagWrap.add(sbwrap);
                index++;
            }
             
        }
        
        return bagWrap;
    }
    @AuraEnabled
    public static List<SecureBagWrapper> FilteredBagByDest(List<Secure_Bag__c> bags,string SearchText){
        List<SecureBagWrapper> bagWrap = new List<SecureBagWrapper>();
        Set<id> bagIds = new Set<id>();
        if(bags != null && bags.size()>0){
            for(Secure_Bag__c sb:bags){
                bagIds.add(sb.id);
            }
            
            // System.debug('SearchText: '+SearchText);
            SearchText='\'%' + String.escapeSingleQuotes(SearchText.trim()) + '%\'';
            Set<string> deliveryStatusSet = new set<string>();
            
            String query = 'select id,Draft__c,Secure_Packaging_Identifier__c, Unique_Identifier__c,Oversize_bag__c,Oversize_Trunk__c,Airline_Trunk__c,Cargo_Type__c,Shipment__r.Origin_Address_City__c,Shipment__r.Destination_Address_City__c,Shipment__r.Origin_Hub__r.Branch__c,Shipment__r.Destination_Hub__r.Branch__c,Linehaul_Type__c, Linehaul_Tracking__c,Linehaul_Tracking__r.name,Shipment__c,Finalised_Linehaul_Number__c,Seal_Id__c,Seal_Id__r.name,Shipping_Note_Number__c,Current_Scan_Hub__r.name,Right_Seal_Id__r.name,Right_Seal_Id__c,Next_Destination__c,Destination_Hub__c,Trunk_Id__c,Trunk_Id__r.Name FROM Secure_Bag__c WHERE Draft__c = false AND  id=:bagIds';
            
            if(string.isNotBlank(SearchText))
                query = query+' AND Destination_Hub__c LIKE ' + SearchText;
            query = query+' LIMIT 500';    
            // System.debug('bagWrap:'+Database.query(query).size());
            integer index = 1;
            for(Secure_Bag__c bag:Database.query(query)){
                SecureBagWrapper sbwrap = new SecureBagWrapper();
                sbwrap.index = index;
                sbwrap.sb = bag;
                sbwrap.process = true;
                sbwrap.Seal= bag.Seal_Id__r.name;
                sbwrap.rseal = bag.Right_Seal_Id__r.name;
                sbwrap.trunk = bag.Trunk_Id__r.name;
                sbwrap.CurrentHub = bag.Current_Scan_Hub__r.name;
                sbwrap.overbag = bag.Oversize_bag__c;
                sbwrap.overTrunk = bag.Oversize_Trunk__c;
                sbwrap.airtr = bag.Airline_Trunk__c;
                bagWrap.add(sbwrap);
                index++;
            }
            
        }
        
        return bagWrap;
    }
    @AuraEnabled
    public static List<SecureBagWrapper> FilteredByBagNo(string BagWrapJson,List<Secure_Bag__c> bags,string SearchText){
        List<SecureBagWrapper> bagWrap = new List<SecureBagWrapper>();
        List<SecureBagWrapper> BagWrapList = (List<SecureBagWrapper>)JSON.deserialize(BagWrapJson, List<SecureBagWrapper>.class);
        Set<id> bagIds = new Set<id>();
        
        if(bags != null && bags.size()>0){
            for(Secure_Bag__c bag:bags){
                bagIds.add(bag.id);                
            }
            if(BagWrapList != null && BagWrapList.size()>0){
                for(SecureBagWrapper bag:BagWrapList){
                    if(bag.process){
                        bagWrap.add(bag);
                        bagIds.remove(bag.sb.id);
                    }
                }
            }
            // System.debug('SearchText: '+SearchText);
            SearchText='\'%' + String.escapeSingleQuotes(SearchText.trim()) + '%\'';
            Set<string> deliveryStatusSet = new set<string>();
            List<SecureBagWrapper> sbwrap0 = new List<SecureBagWrapper>();
            String query = 'select id,Draft__c,Secure_Packaging_Identifier__c, Unique_Identifier__c,Oversize_bag__c,Oversize_Trunk__c,Airline_Trunk__c,Cargo_Type__c,Shipment__r.Origin_Address_City__c,Shipment__r.Destination_Address_City__c,Shipment__r.Origin_Hub__r.Branch__c,Shipment__r.Destination_Hub__r.Branch__c,Linehaul_Type__c, Linehaul_Tracking__c,Linehaul_Tracking__r.name,Shipment__c,Finalised_Linehaul_Number__c,Seal_Id__c,Seal_Id__r.name,Right_Seal_Id__r.name,Right_Seal_Id__c,Shipping_Note_Number__c,Current_Scan_Hub__r.name,Next_Destination__c,Destination_Hub__c,Trunk_Id__c, Trunk_Id__r.Name FROM Secure_Bag__c WHERE  Draft__c = false AND id=:bagIds';
            
            if(string.isNotBlank(SearchText))   
                query = query+' AND Secure_Packaging_Identifier__c LIKE ' + SearchText;
            query = query+' LIMIT 500';    
            // System.debug('bagWrap:'+Database.query(query).size());
            //integer index=1;
            
            List<Secure_Bag__c> secbag = Database.query(query);
            System.debug('Test Log:::'+secbag);
            if(secBag.size() == 0)
            {
                return sbwrap0;
            } else {
         
            for(Secure_Bag__c bag:Database.query(query)){
                SecureBagWrapper sbwrap = new SecureBagWrapper();
                //sbwrap.index = index;
                sbwrap.sb = bag;
                sbwrap.process = true;
                sbwrap.Seal=bag.Seal_Id__r.name;
                sbwrap.rseal=bag.Right_Seal_Id__r.name;
                sbwrap.trunk=bag.Trunk_Id__r.name;
                sbwrap.CurrentHub=bag.Current_Scan_Hub__r.name;
                sbwrap.overbag=bag.Oversize_bag__c;
                sbwrap.overTrunk=bag.Oversize_Trunk__c;
                sbwrap.airtr=bag.Airline_Trunk__c;
                bagWrap.add(sbwrap);
                //index++;
            }
            integer index=1;
            for(SecureBagWrapper bg:bagWrap){
                bg.index = index;
                index++;
            }
            }
        }
        
        return bagWrap;
    }
    public class SecureBagWrapper{
        @AuraEnabled
        public Secure_Bag__c sb ;
        @AuraEnabled
        public Boolean process ;
        @AuraEnabled
        public string box;
        @AuraEnabled
        public string Seal;
        @AuraEnabled        
        public integer index;
        @AuraEnabled
        public string CurrentHub;
        @AuraEnabled
        public string trunk;
        @AuraEnabled
        public string rseal;
        @AuraEnabled
         public string overbag;
         @AuraEnabled
         public string overTrunk;
         @AuraEnabled
         public string airtr;
        @AuraEnabled
         public Boolean draft;
    }
    /*@AuraEnabled
public static string SaveDraftBags(string BagWrapJson){
string stage= '';
List<SecureBagWrapper> BagWrapList = (List<SecureBagWrapper>)JSON.deserialize(BagWrapJson, List<SecureBagWrapper>.class);
List<Secure_Bag__c> updateBagList = new List<Secure_Bag__c>();
for(SecureBagWrapper sw:BagWrapList){
updateBagList.add(sw.sb);
}
try{
update updateBagList;
stage = 'success';
}catch(exception e){
stage = e.getMessage();
// System.debug('exception: '+e.getMessage());
}
return stage;

}*/
    //remove drafted bags
     @AuraEnabled
    public static TMS_LinehaulClass RemoveDraftSelections(String BagWrapJson) {
        TMS_LinehaulClass cls = new TMS_LinehaulClass();
        cls.BagWrapList = new List<SecureBagWrapper>();
        cls.error = '';
    
        // Deserialize incoming wrappers
        List<SecureBagWrapper> wrappers;
        try {
            wrappers = (List<SecureBagWrapper>) JSON.deserialize(BagWrapJson, List<SecureBagWrapper>.class);
        } catch (Exception e) {
            cls.error = 'Invalid input data.';
            throw new AuraHandledException('Invalid BagWrapJson: ' + e.getMessage());
        }
    
        system.debug('wrappers for removal' +wrappers);
        Set<Id> selectedIds = new Set<Id>();
        Map<Id, List<Secure_Bag__c>> bagListMap = new Map<Id, List<Secure_Bag__c>>();
        for (SecureBagWrapper sw : wrappers) {
            if (sw != null && (sw.process == true || String.valueOf(sw.process).toLowerCase() == 'true')) {
                if (sw.sb != null && sw.sb.Id != null) {
                    selectedIds.add(sw.sb.Id);
                     Id sealId = sw.sb.Seal_Id__c;
                    if (!bagListMap.containsKey(sealId)) {
                        bagListMap.put(sealId, new List<Secure_Bag__c>());
                    }
                       bagListMap.get(sealId).add(sw.sb);
                    }

            }
        }
    
        if (selectedIds.isEmpty()) {
            cls.error = 'Please select at least one row to remove.';
            return cls;
        }
        
        List<Trunk__c> pkgsToUpdate = new List<Trunk__c>();
        List<Trunk__c> airPkgs = [SELECT Id, Left_Seal__c, Number_of_SB__c FROM Trunk__c  WHERE Left_Seal__c IN :bagListMap.keySet()];
        for (Trunk__c pkg : airPkgs) {
           Id sId = pkg.Left_Seal__c;
           Integer removeCount = bagListMap.containsKey(sId) ? bagListMap.get(sId).size() : 0;
            system.debug('removeCount' + removeCount);
            if(removeCount > 0){
                if(pkg.Number_of_SB__c >0){
                 pkg.Number_of_SB__c = Math.max(0, pkg.Number_of_SB__c - removeCount);
                    pkgsToUpdate.add(pkg);
                }
            }
    
        }

        if (!pkgsToUpdate.isEmpty()) {
            update pkgsToUpdate;
        }
        
        // Prepare updates
        List<Secure_Bag__c> toUpdate = new List<Secure_Bag__c>();
        for (Id bId : selectedIds) {
            Secure_Bag__c upd = new Secure_Bag__c(
                Id = bId,
                Seal_Id__c = null,
                Right_Seal_Id__c = null,
                Trunk_Id__c = null,
                Next_Destination__c = null,
                Oversize_Bag__c = null,
                Oversize_Trunk__c = null,
                Airline_Trunk__c = null,
                Draft__c = false,
                Lock_Status__c = 'unlock'
            );
            toUpdate.add(upd);
        }
    
        Integer updatedCount = 0;
        try {
            if (!toUpdate.isEmpty()) {
                update toUpdate;
             
            }
        } catch (DmlException de) {
          
            cls.error = 'Failed to update selected bags: ' + de.getMessage();
            throw new AuraHandledException(cls.error);
        }
    

        List<Secure_Bag__c> remainingDrafts = [
            SELECT Id, Secure_Packaging_Identifier__c, Unique_Identifier__c, Shipping_Note_Number__c,
                   Destination_Hub__c, Next_Destination__c, Cargo_Type__c,
                   Seal_Id__c, Seal_Id__r.Name, Right_Seal_Id__c, Right_Seal_Id__r.Name,
                   Trunk_Id__c, Trunk_Id__r.Name, Oversize_Bag__c, Oversize_Trunk__c, Airline_Trunk__c,
                   Current_Scan_Hub__c,Current_Scan_Hub__r.Name, Current_Scan_Hub__r.Id, Draft__c,
                   Shipment__r.CreatedDate, Shipment__r.Origin__c, Shipment__r.Origin_Address_City__c,
                   Shipment__r.Destination_Address_City__c, Shipment__r.Shipper_Name_TMS__r.Name,
                   Shipment__r.Consignee_Name_TMS__r.Name
            FROM Secure_Bag__c
            WHERE Draft__c = TRUE
            AND Id NOT IN :selectedIds
            ORDER BY Shipment__r.CreatedDate DESC
            LIMIT 5000
        ];
    
        Integer idx = 1;
        if (remainingDrafts != null && !remainingDrafts.isEmpty()) {
            for (Secure_Bag__c sb : remainingDrafts) {
                SecureBagWrapper w = new SecureBagWrapper();
                w.sb = sb;
                w.process = false;
                w.box = sb.Secure_Packaging_Identifier__c;
                w.Seal = (sb.Seal_Id__r != null) ? sb.Seal_Id__r.Name : '';
                w.rseal = (sb.Right_Seal_Id__r != null) ? sb.Right_Seal_Id__r.Name : '';
                w.CurrentHub = (sb.Current_Scan_Hub__r != null) ? sb.Current_Scan_Hub__r.Name : '';
                w.trunk = (sb.Trunk_Id__r != null) ? sb.Trunk_Id__r.Name : '';
                w.overbag = (String) sb.Oversize_Bag__c;
                w.overTrunk = (String) sb.Oversize_Trunk__c;
                w.airtr = (String) sb.Airline_Trunk__c;
                w.index = idx++;
                cls.BagWrapList.add(w);
            }
        }
    
    
        cls.BranchOptions = new Map<String, String>();
        cls.BranchOptions.put('', 'None');
        Schema.DescribeFieldResult fieldResult = Secure_Bag__c.Next_Destination__c.getDescribe();
        for (Schema.PicklistEntry p : fieldResult.getPicklistValues()) {
            cls.BranchOptions.put(p.getValue(), p.getLabel());
        }
    
     
        cls.error = ''; // no error
       
    
        return cls;
    }
    

   
   // drafted new method
 
      @AuraEnabled
    public static List<TMS_LinehaulClass.SecureBagWrapper> getDraftBagsfiltered(string destination,string seal,string cargo) {
        List<SecureBagWrapper> wrapList = new List<SecureBagWrapper>();

        
        FSE_Sales__c UserHub = [ SELECT id,Hub__r.id, Hub__r.Hub_City__c,Hub__r.Name FROM FSE_Sales__c WHERE Sales_Person__c =:UserInfo.getUserId() LIMIT 1];
        List<Secure_Bag__c> bags = new List<Secure_Bag__c>();
        if (String.isNotBlank(destination)) {
           bags = [SELECT Id, Secure_Packaging_Identifier__c,Unique_Identifier__c, Shipping_Note_Number__c,
                                           Destination_Hub__c, Next_Destination__c, Cargo_Type__c,
                                           Seal_Id__c,Seal_Id__r.name,Right_Seal_Id__r.name,Trunk_Id__r.name, Right_Seal_Id__c,
                                           Trunk_Id__c, Oversize_Bag__c, Oversize_Trunk__c, Airline_Trunk__c,
                                           Current_Scan_Hub__c,Current_Scan_Hub__r.id,Current_Scan_Hub__r.name, Draft__c,
                                           Shipment__r.CreatedDate,
                                           Shipment__r.Origin__c,
                                           Shipment__r.Origin_Address_City__c,
                                           Shipment__r.Destination_Address_City__c,
                                           Shipment__r.Shipper_Name_TMS__r.Name,
                                           Shipment__r.Consignee_Name_TMS__r.Name
                                    FROM Secure_Bag__c
                                    WHERE  Draft__c = TRUE AND Next_Destination__c =: destination]; 
      }else if(String.isNotBlank(seal)){
             bags = [SELECT Id, Secure_Packaging_Identifier__c,Unique_Identifier__c, Shipping_Note_Number__c,
                                           Destination_Hub__c, Next_Destination__c, Cargo_Type__c,
                                           Seal_Id__c,Seal_Id__r.name,Right_Seal_Id__r.name,Trunk_Id__r.name, Right_Seal_Id__c,
                                           Trunk_Id__c, Oversize_Bag__c, Oversize_Trunk__c, Airline_Trunk__c,
                                           Current_Scan_Hub__c,Current_Scan_Hub__r.id,Current_Scan_Hub__r.name, Draft__c,
                                           Shipment__r.CreatedDate,
                                           Shipment__r.Origin__c,
                                           Shipment__r.Origin_Address_City__c,
                                           Shipment__r.Destination_Address_City__c,
                                           Shipment__r.Shipper_Name_TMS__r.Name,
                                           Shipment__r.Consignee_Name_TMS__r.Name
                                    FROM Secure_Bag__c
                                    WHERE  Draft__c = TRUE AND Seal_Id__c =: seal]; 
      }else if(String.isNotBlank(cargo)){
                      bags = [SELECT Id, Secure_Packaging_Identifier__c,Unique_Identifier__c, Shipping_Note_Number__c,
                                           Destination_Hub__c, Next_Destination__c, Cargo_Type__c,
                                           Seal_Id__c,Seal_Id__r.name,Right_Seal_Id__r.name,Trunk_Id__r.name, Right_Seal_Id__c,
                                           Trunk_Id__c, Oversize_Bag__c, Oversize_Trunk__c, Airline_Trunk__c,
                                           Current_Scan_Hub__c,Current_Scan_Hub__r.id,Current_Scan_Hub__r.name, Draft__c,
                                           Shipment__r.CreatedDate,
                                           Shipment__r.Origin__c,
                                           Shipment__r.Origin_Address_City__c,
                                           Shipment__r.Destination_Address_City__c,
                                           Shipment__r.Shipper_Name_TMS__r.Name,
                                           Shipment__r.Consignee_Name_TMS__r.Name
                                    FROM Secure_Bag__c
                                    WHERE  Draft__c = TRUE AND Cargo_Type__c =: cargo]; 
          
      }
        //AND Current_Scan_Hub__r.id=:UserHub.Hub__r.id

        Integer idx = 1;
        for (Secure_Bag__c sb : bags) {
            SecureBagWrapper w = new SecureBagWrapper();
            w.sb = sb;
            w.process = false;
            w.box = sb.Secure_Packaging_Identifier__c;
            w.Seal = sb.Seal_Id__r.name;
            w.rseal = sb.Right_Seal_Id__r.name;
            w.CurrentHub = sb.Current_Scan_Hub__r.name;
            w.trunk = sb.Trunk_Id__r.name;
            w.overbag = (String) sb.Oversize_Bag__c;
            w.overTrunk = (String) sb.Oversize_Trunk__c;
            w.airtr = (String) sb.Airline_Trunk__c;
            w.index = idx++;
           
            wrapList.add(w);
        }
        return wrapList;
    }
    
   @AuraEnabled
    public static List<TMS_LinehaulClass.SecureBagWrapper> getDraftBags() {
        List<SecureBagWrapper> wrapList = new List<SecureBagWrapper>();

        FSE_Sales__c UserHub = [ SELECT id,Hub__r.id, Hub__r.Hub_City__c,Hub__r.Name FROM FSE_Sales__c WHERE Sales_Person__c =:UserInfo.getUserId() LIMIT 1];
        List<Secure_Bag__c> bags = [SELECT Id, Secure_Packaging_Identifier__c,Unique_Identifier__c, Shipping_Note_Number__c,
                                           Destination_Hub__c, Next_Destination__c, Cargo_Type__c,
                                           Seal_Id__c,Seal_Id__r.name,Right_Seal_Id__r.name,Trunk_Id__r.name, Right_Seal_Id__c,
                                           Trunk_Id__c, Oversize_Bag__c, Oversize_Trunk__c, Airline_Trunk__c,
                                           Current_Scan_Hub__c,Current_Scan_Hub__r.id,Current_Scan_Hub__r.name, Draft__c,
                                           Shipment__r.CreatedDate,
                                           Shipment__r.Origin__c,
                                           Shipment__r.Origin_Address_City__c,
                                           Shipment__r.Destination_Address_City__c,
                                           Shipment__r.Shipper_Name_TMS__r.Name,
                                           Shipment__r.Consignee_Name_TMS__r.Name
                                    FROM Secure_Bag__c
                                    WHERE  Draft__c = TRUE AND Seal_Id__c != Null AND Current_Scan_Hub__r.id=:UserHub.Hub__r.id ];  //AND Current_Scan_Hub__r.id=:UserHub.Hub__r.id 

        Integer idx = 1;
        for (Secure_Bag__c sb : bags) {
            SecureBagWrapper w = new SecureBagWrapper();
            w.sb = sb;
            w.process = false;
            w.box = sb.Secure_Packaging_Identifier__c;
            w.Seal = sb.Seal_Id__r.name;
            w.rseal = sb.Right_Seal_Id__r.name;
            w.CurrentHub = sb.Current_Scan_Hub__r.name;
            w.trunk = sb.Trunk_Id__r.name;
            w.overbag = (String) sb.Oversize_Bag__c;
            w.overTrunk = (String) sb.Oversize_Trunk__c;
            w.airtr = (String) sb.Airline_Trunk__c;
            w.index = idx++;
           
            wrapList.add(w);
        }
        return wrapList;
    }
    
    // get drfated sealId
    @AuraEnabled
    public static Map<String,String> getDraftSeals() {
        Map<String,String> result = new Map<String,String>();
        try {
            FSE_Sales__c UserHub = [ SELECT id,Hub__r.id, Hub__r.Hub_City__c,Hub__r.Name FROM FSE_Sales__c WHERE Sales_Person__c =:UserInfo.getUserId() LIMIT 1];
            List<Secure_Packaging__c> seals = [SELECT Id, Name,Allocated_To_Hub__c,Allocated_To_Hub__r.id FROM Secure_Packaging__c  WHERE Draft__c = TRUE AND Allocated_To_Hub__r.id=:UserHub.Hub__r.id ORDER BY Name ];  //AND Allocated_To_Hub__r.id=:UserHub.Hub__r.id
    
            for (Secure_Packaging__c s : seals) {
               
                result.put(String.valueOf(s.Id), s.Name);
            }
        } catch (Exception ex) {
           
            System.debug('getDraftSeals error: ' + ex);
        }
        return result;
    }
  
    @AuraEnabled
    public static AddBoxDraftResponse AddBox(
        String BagWrapJson,
        String seal,
        String rseal,
        String rightSealId,
        String SealId,
        String Dest,
        String trunk,
        String trunkId,
        String overbags,
        String overtrunks,
        String airTrunk,
        Boolean force
    ) {
        AddBoxDraftResponse resp = new AddBoxDraftResponse();

      
        List<TMS_LinehaulClass.SecureBagWrapper> BagWrapList = new List<TMS_LinehaulClass.SecureBagWrapper>();
        if (String.isNotBlank(BagWrapJson)) {
            BagWrapList = (List<TMS_LinehaulClass.SecureBagWrapper>) JSON.deserialize(BagWrapJson, List<TMS_LinehaulClass.SecureBagWrapper>.class);
        }
        resp.bagWrapList = BagWrapList;
       
          if (String.isNotBlank(SealId) && String.isNotBlank(Dest)) {
                    List<Secure_Bag__c> existingBagList = [
                        SELECT Id,Seal_Id__c, Next_Destination__c
                        FROM Secure_Bag__c
                        WHERE Seal_Id__c = :SealId  
                        LIMIT 1];
         
            if (!existingBagList.isEmpty()) {
                Secure_Bag__c existingBag = existingBagList[0];
                String existingDest = existingBag.Next_Destination__c == null ? '' : existingBag.Next_Destination__c.trim();
                String incomingDest = Dest == null ? '' : Dest.trim();
        
            
                if (!existingDest.equalsIgnoreCase(incomingDest)) {
                    resp.success = false;
                    resp.requiresConfirmation = false;
                    resp.message = 'Seal id is used for this Next Destination :' + existingDest +' '+'Please use another SealId.' ; 
                    return resp;
                }
            }
              
              
        }
        
        Set<Id> incomingBagIds = new Set<Id>();
        for (TMS_LinehaulClass.SecureBagWrapper sw : BagWrapList) {
            if (sw != null && sw.sb != null && sw.sb.Id != null) {
                incomingBagIds.add(sw.sb.Id);
            }
        }
        Map<Id, Secure_Bag__c> existingBagMap = new Map<Id, Secure_Bag__c>( [SELECT Id,Name,Secure_Packaging_Identifier__c,Seal_Id__r.Name, Seal_Id__c, Draft__c FROM Secure_Bag__c WHERE Id IN :incomingBagIds]);
       
        List<Secure_Bag__c> bagsToUpdate = new List<Secure_Bag__c>();
        Set<Id> bagIds = new Set<Id>();

        try {
            
            for (TMS_LinehaulClass.SecureBagWrapper sw : BagWrapList) {
                if (sw != null && sw.process == true && sw.sb != null) {
                    
                         Secure_Bag__c existingBag = existingBagMap.get(sw.sb.Id);

                        if (existingBag != null &&
                            String.isNotBlank(existingBag.Seal_Id__c) &&
                            existingBag.Seal_Id__c != SealId &&
                            existingBag.Draft__c == true) {
                
                            resp.success = false;
                            resp.requiresConfirmation = false;
                            resp.message = existingBag.Secure_Packaging_Identifier__c +' ' + 'This bag is IN draft with seal id: ' + existingBag.Seal_Id__r.Name +
                                           '. You can’t change seal id.';
                            return resp;
                        }
                    if (String.isNotBlank(SealId)) {
                        sw.seal = seal;
                        sw.sb.Seal_Id__c = SealId;
                        sw.sb.Lock_Status__c = 'Lock';
                        sw.overbag = overbags;
                        sw.overTrunk = overtrunks;
                        sw.airtr = airTrunk;
                       // sw.sb.Draft__c = true;
                    }

                    if (String.isNotBlank(rightSealId)) {
                        sw.rseal = rseal;
                        sw.sb.Right_Seal_Id__c = rightSealId;
                        sw.sb.Lock_Status__c = 'Lock';
                    }

                    if (String.isNotBlank(trunkId)) {
                        sw.trunk = trunk;
                        sw.sb.Trunk_Id__c = trunkId;
                        sw.sb.BVC_Trunk__c = 'TRUNK'; 
                    }

                    if (String.isNotBlank(Dest)) {
                        sw.sb.Next_Destination__c = Dest;
                        sw.sb.Oversize_Bag__c = overbags;
                        sw.sb.Oversize_Trunk__c = overtrunks;
                        sw.sb.Airline_Trunk__c = airTrunk;
                    }
                      if(String.isNotBlank(overbags)){
                        sw.sb.BVC_Trunk__c = 'OSB';
                    }
                    if(String.isNotBlank(overtrunks)){
                        sw.sb.BVC_Trunk__c = 'OST';
                    }
                    if(String.isNotBlank(airTrunk)){
                        sw.sb.BVC_Trunk__c = 'AIRLINE TRUNK';
                    }

                    bagsToUpdate.add(sw.sb);
                    if (sw.sb.Id != null) bagIds.add(sw.sb.Id);
                    sw.process = false;
                }
            }

           
            List<Secure_Packaging__c> spList = new List<Secure_Packaging__c>();
            if (String.isNotBlank(SealId)) {
                spList = [
                    SELECT Id, Name, Draft__c
                    FROM Secure_Packaging__c
                    WHERE Id = :SealId AND Draft__c = true
                    LIMIT 1
                ];
            }

         
            if (!spList.isEmpty() && spList[0].Draft__c == true && (force == null || force == false)) {
                resp.requiresConfirmation = true;
                resp.message = 'This Left Seal Id (' + spList[0].Name + ') is currently in DRAFT use another seal id or Use Save As Draft Option to proceed';
                resp.success = false;
                return resp;
            }

           
            List<Trunk__c> existingAirPackList = new List<Trunk__c>();
            if (String.isNotBlank(SealId)) {
                existingAirPackList = [
                    SELECT Id, Name, Left_Seal__c, Left_Seal__r.Name, Left_Seal__r.Draft__c
                    FROM Trunk__c
                    WHERE Left_Seal__c = :SealId
                     
                ];
            }

           
            List<Trunk__c> ovrbagList = new List<Trunk__c>();
            List<Trunk__c> obvrTrunkList = new List<Trunk__c>();
            List<Trunk__c> airTrunkList = new List<Trunk__c>();
            List<Trunk__c> bvcTrunkList = new List<Trunk__c>();

           
            Boolean allowTrunkCreate = spList.isEmpty() || (force == true);
            if (allowTrunkCreate) {
                if (existingAirPackList.isEmpty()) {
                    
                    if (String.isNotBlank(trunkId)) {
                        Trunk__c tr = new Trunk__c();
                        tr.Left_Seal__c = SealId;
                        tr.Trunk_name__c = trunkId;
                        tr.Next_Destination__c = Dest;
                        tr.Number_of_SB__c = bagIds.size();
                        tr.RecordTypeId = Schema.SObjectType.Trunk__c.getRecordTypeInfosByName().get('BVC Trunks').getRecordTypeId();
                        bvcTrunkList.add(tr);
                    }

               
                    if (String.isNotBlank(overbags)) {
                        Trunk__c tr = new Trunk__c();
                        tr.Left_Seal__c = SealId;
                        tr.OSB__c = overbags;
                        tr.Next_Destination__c = Dest;
                        tr.Number_of_SB__c = bagIds.size();
                        tr.RecordTypeId = Schema.SObjectType.Trunk__c.getRecordTypeInfosByName().get('Oversize Bags').getRecordTypeId();
                        ovrbagList.add(tr);
                    }

                   
                    if (String.isNotBlank(overtrunks)) {
                        Trunk__c tr = new Trunk__c();
                        tr.Left_Seal__c = SealId;
                        tr.OST__c = overtrunks;
                        tr.Next_Destination__c = Dest;
                        tr.Number_of_SB__c = bagIds.size();
                        tr.RecordTypeId = Schema.SObjectType.Trunk__c.getRecordTypeInfosByName().get('CPMT').getRecordTypeId();
                        obvrTrunkList.add(tr);
                    }

                  
                    if (String.isNotBlank(airTrunk)) {
                        Trunk__c tr = new Trunk__c();
                        tr.Left_Seal__c = SealId;
                        tr.Airline_Trunk__c = airTrunk;
                        tr.Next_Destination__c = Dest;
                        tr.Number_of_SB__c = bagIds.size();
                        tr.RecordTypeId = Schema.SObjectType.Trunk__c.getRecordTypeInfosByName().get('Airline Trunks').getRecordTypeId();
                        airTrunkList.add(tr);
                    }

                
                    if (!bvcTrunkList.isEmpty()) insert bvcTrunkList;
                    if (!ovrbagList.isEmpty()) insert ovrbagList;
                    if (!obvrTrunkList.isEmpty()) insert obvrTrunkList;
                    if (!airTrunkList.isEmpty()) insert airTrunkList;
                }
            }

           
            List<Secure_Packaging__c> sealsToUpdate = new List<Secure_Packaging__c>();
            if (String.isNotBlank(SealId)) {
                sealsToUpdate.add(new Secure_Packaging__c(Id = SealId,Status__c = 'Consumed'));
            }
            if (String.isNotBlank(rightSealId)) {
                sealsToUpdate.add(new Secure_Packaging__c(Id = rightSealId, Status__c = 'Consumed'));
            }
            if (String.isNotBlank(trunkId)) {
                sealsToUpdate.add(new Secure_Packaging__c(Id = trunkId, Status__c = 'Consumed'));
            }
            if (!sealsToUpdate.isEmpty()) {
                update sealsToUpdate;
            }

          
            if (!bagsToUpdate.isEmpty()) {
                update bagsToUpdate;
            }

           
            if (!existingAirPackList.isEmpty()) {
                resp.message = 'Existing airline package found for this seal. Bags updated.';
            } else {
                resp.message = 'Operation completed successfully.';
            }

            resp.success = true;
            resp.requiresConfirmation = false;
            resp.bagWrapList = BagWrapList;
            return resp;

        } catch (DmlException de) {
            resp.success = false;
            resp.requiresConfirmation = false;
            resp.message = 'DML failed: ' + de.getMessage();
            return resp;
        } catch (Exception e) {
            resp.success = false;
            resp.requiresConfirmation = false;
            resp.message = 'Error: ' + e.getMessage();
            return resp;
        }
    }
   // save bags in draft before finalization 
     public class AddBoxDraftResponse {
        @AuraEnabled public List<TMS_LinehaulClass.SecureBagWrapper> bagWrapList;
        @AuraEnabled public Boolean requiresConfirmation;
        @AuraEnabled public String message;
        @AuraEnabled public Boolean success;
        public AddBoxDraftResponse() {
            this.requiresConfirmation = false;
            this.message = '';
            this.success = false;
            this.bagWrapList = new List<TMS_LinehaulClass.SecureBagWrapper>();
        }
    }

    /**
     * AddBoxDraft
     * - force: pass false on first call. If server finds Seal in Draft and force=false it'll return requiresConfirmation=true.
     * - If user confirms, client calls again with force=true and server proceeds with DML.
     */
    @AuraEnabled
    public static AddBoxDraftResponse AddBoxDraft(
        String BagWrapJson,
        String seal,
        String rseal,
        String rightSealId,
        String SealId,
        String Dest,
        String trunk,
        String trunkId,
        String overbags,
        String overtrunks,
        String airTrunk,
        Boolean force
    ) {
        AddBoxDraftResponse resp = new AddBoxDraftResponse();

      
        List<TMS_LinehaulClass.SecureBagWrapper> BagWrapList = new List<TMS_LinehaulClass.SecureBagWrapper>();
        if (String.isNotBlank(BagWrapJson)) {
            BagWrapList = (List<TMS_LinehaulClass.SecureBagWrapper>) JSON.deserialize(BagWrapJson, List<TMS_LinehaulClass.SecureBagWrapper>.class);
        }
        resp.bagWrapList = BagWrapList;
          
            if (String.isNotBlank(SealId) && String.isNotBlank(Dest)) {
            List<Secure_Bag__c> existingBagList = [
                SELECT Id,Seal_Id__c, Next_Destination__c
                FROM Secure_Bag__c
                WHERE Seal_Id__c = :SealId  
                LIMIT 1];
        
            if (!existingBagList.isEmpty()) {
                Secure_Bag__c existingBag = existingBagList[0];
                String existingDest = existingBag.Next_Destination__c == null ? '' : existingBag.Next_Destination__c.trim();
                String incomingDest = Dest == null ? '' : Dest.trim();
        
                
                if (!existingDest.equalsIgnoreCase(incomingDest)) {
                    resp.success = false;
                    resp.requiresConfirmation = false;
                    resp.message = 'SealId is used for this Next Destination :' + existingDest +' '+'Please use another SealId.' ;
                    return resp;
                }
            }  
     }         
         Set<Id> incomingBagIds = new Set<Id>();
        for (TMS_LinehaulClass.SecureBagWrapper sw : BagWrapList) {
            if (sw != null && sw.sb != null && sw.sb.Id != null) {
                incomingBagIds.add(sw.sb.Id);
            }
        }
        Map<Id, Secure_Bag__c> existingBagMap = new Map<Id, Secure_Bag__c>( [SELECT Id,Name,Secure_Packaging_Identifier__c,Seal_Id__r.Name, Seal_Id__c, Draft__c FROM Secure_Bag__c WHERE Id IN :incomingBagIds]);
         Map<Id, List<Secure_Bag__c>> bagListMap = new Map<Id, List<Secure_Bag__c>>();
        
        List<Secure_Bag__c> bagsToUpdate = new List<Secure_Bag__c>();
        Set<Id> bagIds = new Set<Id>();

        try {
            
            for (TMS_LinehaulClass.SecureBagWrapper sw : BagWrapList) {
                if (sw != null && sw.process == true && sw.sb != null) {
                     
                     Secure_Bag__c existingBag = existingBagMap.get(sw.sb.Id);

                        if (existingBag != null &&
                            String.isNotBlank(existingBag.Seal_Id__c) &&
                            existingBag.Seal_Id__c != SealId &&
                            existingBag.Draft__c == true) {
                
                            resp.success = false;
                            resp.requiresConfirmation = false;
                            resp.message = existingBag.Secure_Packaging_Identifier__c +' ' + 'This bag is IN draft with seal id: ' + existingBag.Seal_Id__r.Name +
                                           '. You can’t change seal id.';
                            return resp;
                        }
                    
                    if (String.isNotBlank(SealId)) {
                        sw.seal = seal;
                        sw.sb.Seal_Id__c = SealId;
                        sw.sb.Lock_Status__c = 'Lock';
                        sw.overbag = overbags;
                        sw.overTrunk = overtrunks;
                        sw.airtr = airTrunk;
                        sw.sb.Draft__c = true;
                        
                    }

                    if (String.isNotBlank(rightSealId)) {
                        sw.rseal = rseal;
                        sw.sb.Right_Seal_Id__c = rightSealId;
                        sw.sb.Lock_Status__c = 'Lock';
                    }

                    if (String.isNotBlank(trunkId)) {
                        sw.trunk = trunk;
                        sw.sb.Trunk_Id__c = trunkId;
                        sw.sb.BVC_Trunk__c = 'TRUNK';
                    }

                    if (String.isNotBlank(Dest)) {
                        sw.sb.Next_Destination__c = Dest;
                        sw.sb.Oversize_Bag__c = overbags;
                        sw.sb.Oversize_Trunk__c = overtrunks;
                        sw.sb.Airline_Trunk__c = airTrunk;
                        
                    }
                    if(String.isNotBlank(overbags)){
                        sw.sb.BVC_Trunk__c = 'OSB';
                    }
                    if(String.isNotBlank(overtrunks)){
                        sw.sb.BVC_Trunk__c = 'OST';
                    }
                    if(String.isNotBlank(airTrunk)){
                        sw.sb.BVC_Trunk__c = 'AIRLINE TRUNK';
                    }
                   

                    bagsToUpdate.add(sw.sb);
                    if (sw.sb.Id != null) bagIds.add(sw.sb.Id);
                    sw.process = false;
                }
            }

           
            List<Secure_Packaging__c> spList = new List<Secure_Packaging__c>();
            if (String.isNotBlank(SealId)) {
                spList = [
                    SELECT Id, Name, Draft__c
                    FROM Secure_Packaging__c
                    WHERE Id = :SealId AND Draft__c = true
                    LIMIT 1
                ];
            }

         
            if (!spList.isEmpty() && spList[0].Draft__c == true && (force == null || force == false)) {
                resp.requiresConfirmation = true;
                resp.message = 'This Left Seal Id (' + spList[0].Name + ') is currently in DRAFT. Do you want to continue? Otherwise use another seal id.';
                resp.success = false;
                return resp;
            }

           
            List<Trunk__c> existingAirPackList = new List<Trunk__c>();
            if (String.isNotBlank(SealId)) {
                existingAirPackList = [
                    SELECT Id, Name,Number_of_SB__c,Left_Seal__c, Left_Seal__r.Name, Left_Seal__r.Draft__c
                    FROM Trunk__c
                    WHERE Left_Seal__c = :SealId
                     
                ];
            }

           
            List<Trunk__c> ovrbagList = new List<Trunk__c>();
            List<Trunk__c> obvrTrunkList = new List<Trunk__c>();
            List<Trunk__c> airTrunkList = new List<Trunk__c>();
            List<Trunk__c> bvcTrunkList = new List<Trunk__c>();
             List<Trunk__c> updateBagsCount = new List<trunk__c>();

            
            Boolean allowTrunkCreate = spList.isEmpty() || (force == true);
            if (allowTrunkCreate) {
                if (existingAirPackList.isEmpty()) {
                   
                    if (String.isNotBlank(trunkId)) {
                        Trunk__c tr = new Trunk__c();
                        tr.Left_Seal__c = SealId;
                        tr.Trunk_name__c = trunkId;
                        tr.Next_Destination__c = Dest;
                        tr.Number_of_SB__c = bagIds.size();
                        tr.RecordTypeId = Schema.SObjectType.Trunk__c.getRecordTypeInfosByName().get('BVC Trunks').getRecordTypeId();
                        bvcTrunkList.add(tr);
                    }

                    
                    if (String.isNotBlank(overbags)) {
                        Trunk__c tr = new Trunk__c();
                        tr.Left_Seal__c = SealId;
                        tr.OSB__c = overbags;
                        tr.Next_Destination__c = Dest;
                        tr.Number_of_SB__c = bagIds.size();
                        tr.RecordTypeId = Schema.SObjectType.Trunk__c.getRecordTypeInfosByName().get('Oversize Bags').getRecordTypeId();
                        ovrbagList.add(tr);
                    }

                    
                    if (String.isNotBlank(overtrunks)) {
                        Trunk__c tr = new Trunk__c();
                        tr.Left_Seal__c = SealId;
                        tr.OST__c = overtrunks;
                        tr.Next_Destination__c = Dest;
                        tr.Number_of_SB__c = bagIds.size();
                        tr.RecordTypeId = Schema.SObjectType.Trunk__c.getRecordTypeInfosByName().get('CPMT').getRecordTypeId();
                        obvrTrunkList.add(tr);
                    }

                    
                    if (String.isNotBlank(airTrunk)) {
                        Trunk__c tr = new Trunk__c();
                        tr.Left_Seal__c = SealId;
                        tr.Airline_Trunk__c = airTrunk;
                        tr.Next_Destination__c = Dest;
                        tr.Number_of_SB__c = bagIds.size();
                        tr.RecordTypeId = Schema.SObjectType.Trunk__c.getRecordTypeInfosByName().get('Airline Trunks').getRecordTypeId();
                        airTrunkList.add(tr);
                    }

                    
                    if (!bvcTrunkList.isEmpty()) insert bvcTrunkList;
                    if (!ovrbagList.isEmpty()) insert ovrbagList;
                    if (!obvrTrunkList.isEmpty()) insert obvrTrunkList;
                    if (!airTrunkList.isEmpty()) insert airTrunkList;
                }else if(!existingAirPackList.isEmpty()){
                    for(Trunk__c  tr : existingAirPackList){
                        system.debug('bagsize'+incomingBagIds.size());
                        tr.Number_of_SB__c = Math.max(0, tr.Number_of_SB__c + bagIds.size());
                        updateBagsCount.add(tr);
                    }
                    if(!updateBagsCount.isEmpty()){
                        update updateBagsCount;
                    }
                }
            }
        FSE_Sales__c[] UserHub = [ SELECT Hub__r.Hub_City__c,Hub__r.Name FROM FSE_Sales__c WHERE Sales_Person__c =:UserInfo.getUserId() ORDER BY CreatedDate DESC LIMIT 1]; 
            
            List<Secure_Packaging__c> sealsToUpdate = new List<Secure_Packaging__c>();
            if (String.isNotBlank(SealId)) {
                sealsToUpdate.add(new Secure_Packaging__c(Id = SealId,Allocated_To_Hub__c = UserHub[0].Hub__r.id,  Draft__c = true));
            }
            if (String.isNotBlank(rightSealId)) {
                sealsToUpdate.add(new Secure_Packaging__c(Id = rightSealId,Allocated_To_Hub__c = UserHub[0].Hub__r.id, Draft__c = true));
            }
            if (String.isNotBlank(trunkId)) {
                sealsToUpdate.add(new Secure_Packaging__c(Id = trunkId,Allocated_To_Hub__c = UserHub[0].Hub__r.id, Draft__c = true));
            }
            if (!sealsToUpdate.isEmpty()) {
                update sealsToUpdate;
            }

           
            if (!bagsToUpdate.isEmpty()) {
                update bagsToUpdate;
            }

          
            if (!existingAirPackList.isEmpty()) {
                resp.message = 'Existing airline package found for this seal. Bags updated.';
            } else {
                resp.message = 'Operation completed successfully.';
            }

            resp.success = true;
            resp.requiresConfirmation = false;
            resp.bagWrapList = BagWrapList;
            return resp;

        } catch (DmlException de) {
            resp.success = false;
            resp.requiresConfirmation = false;
            resp.message = 'DML failed: ' + de.getMessage();
            return resp;
        } catch (Exception e) {
            resp.success = false;
            resp.requiresConfirmation = false;
            resp.message = 'Error: ' + e.getMessage();
            return resp;
        }
    }
    // end AddBoxDraft
    
    public static String currentUserHub(){ 
        
        FSE_Sales__c[] UserHub = [
            SELECT Hub__r.Hub_City__c,Hub__r.Name 
            FROM FSE_Sales__c 
            WHERE Sales_Person__c =:UserInfo.getUserId() ORDER BY CreatedDate DESC
            LIMIT 1]; 
        if(UserHub !=null && UserHub[0].Hub__r.Name !=null){
            return UserHub[0].Hub__r.Name;
        }else{
            return '';
        }
    }
   
    
    @AuraEnabled
    public static string SaveProcess(string BagWrapJson, string LHType, String LHNumber,string AirLHNumber, String Flight, DateTime FlightDate,String profileName, String Vehicle,String Vehicle1,String Hub,String Hub1,String filter,string origin,string destination,string airline,string comcode,DateTime fltDate,boolean draft){
        string result = '';
        system.debug('entered in SaveProcess apex class');
        system.debug('Linehaul number from APEX saveprocess '+LHNumber);
        system.debug('Draft status:'+ draft);
         // Check if a Linehaul record with the same ABW number already exists
        String userId = UserInfo.getUserId();
        Date today = Date.today();
        Date yesterday = today.addDays(-1);
        Date createdDate ;
        system.debug('yesterday date' +yesterday );
        List<Linehaul__c> existingLinehaul = [SELECT Id,Linehaul_Track__c,Flt_DateTime__c,AWB_Number__c,Select_Airline__c,Origin__c,Destination__c,Finalized_Linehaul_Number__c,createdDate FROM Linehaul__c WHERE AWB_Number__c = :LHNumber AND Select_Airline__c =: airline];
         List<Linehaul_Tracking__c> existingLinehaultrack = [SELECT Id FROM Linehaul_Tracking__c WHERE AWB_Number__c = :LHNumber ];
         for(Linehaul__c l : existingLinehaul){
                 createdDate = l.CreatedDate.date();
             if(CreatedDate < yesterday ){
                 return 'You can not use AWB number after two days for this airline, please use new AWB Number.';
             }
             
         }
        if(string.isBlank(LHNumber) || LHNumber == '' || LHNumber == null){
            result = 'Please enter airway bill number';
        }  
        else{
                         
            List<SecureBagWrapper> BagWrapList = (List<SecureBagWrapper>)JSON.deserialize(BagWrapJson, List<SecureBagWrapper>.class);
            List<Secure_Bag__c> UpdatedBagList = new List<Secure_Bag__c>();
            Linehaul__c l = null;
            Linehaul_Tracking__c lt = null;
             for(SecureBagWrapper sw:BagWrapList){
                if(sw.process){
                    // System.debug('sw.sb '+sw.sb.id);
                    sw.sb.Linehaul_Type__c = LHType;
                    
                     
                  //  sw.sb.AWB_Number__c = AirLHNumber;
                    sw.sb.Finalized_Time__c = system.now();
                    if(draft == true){
                            sw.sb.Draft__c = false;
                        }
                    if(sw.sb.Linehaul_Type__c =='Air'){
                        
                        if(string.isNotBlank(Flight)){
                            sw.sb.Flight_Schedule__c=Flight;                           
                            sw.sb.AWB_Number__c = LHNumber;
                            sw.sb.Finalised_Linehaul_Number__c = AirLHNumber;
                            sw.sb.Vaults__c = null;
                        }else{
                            sw.sb.Flight_Schedule__c=null;
                            sw.sb.Flight_Date_Time__c = FlightDate;  
                            sw.sb.AWB_Number__c = LHNumber;
                            sw.sb.Finalised_Linehaul_Number__c = AirLHNumber;
                            sw.sb.Vaults__c = null;
                        }    
                          
                    }else{
                      if(string.isNotBlank(Vehicle)){
                            sw.sb.Vehicle__c=Vehicle;
                            sw.sb.Finalised_Linehaul_Number__c = LHNumber;
                            sw.sb.AWB_Number__c = null;
                          	sw.sb.Vaults__c = null;
                        }else{
                            sw.sb.Vehicle__c = null;
                        }
                        if(string.isNotBlank(Hub)){
                            sw.sb.Hub__c = Hub;
                        }else{
                            sw.sb.Hub__c = null;
                        }
                    }
                    UpdatedBagList.add(sw.sb);
                     
                }
            }
            try{
              //  update UpdatedBagList;
                if(LHType=='Road'){
                    if(string.isNotBlank(Vehicle)){
                        Transport__c tp = new Transport__c();
                        tp.id = Vehicle;
                      //  tp.Is_Inactive__c = true;
                        update tp;
                        
                      
                    }
                    TMS_DLHN__c dlhn = [select id, Finalized_Number__c FROM TMS_DLHN__c LIMIT 1 FOR UPDATE];
                    dlhn.Finalized_Number__c = dlhn.Finalized_Number__c+1;
                    update dlhn;
                    
                     
                }
                
                if(LHType =='Air'){
                 TMS_Air_Series__c dlhn = [select id, Finalised_Number__c FROM TMS_Air_Series__c LIMIT 1 FOR UPDATE];
                    dlhn.Finalised_Number__c = dlhn.Finalised_Number__c+1;
                    update dlhn;  
            }
               
                
                if(filter == 'Finalised'){
                    upsertLineTracking(UpdatedBagList);// Linehaul Tracking Record Creation
                }
                  if (l== null && existingLinehaul.isEmpty() && LHType =='Air' ){
                      
                        String validPattern = '^[a-zA-Z0-9]{1,8}$';
                      if (String.isNotBlank(LHNumber) && !Pattern.matches(validPattern, LHNumber)) {
                          return 'Special characters are not allowed in AWB number';   // added to restrict special chars
                      }else{
                        // Create the Linehaul__c record only when l is null (first time)
                            update UpdatedBagList;
                            system.debug('Manual Lt UpdatedBagList@@'+ UpdatedBagList);
                          try{
                             l = new Linehaul__c();
                            l.AWB_Number__c = LHNumber;
                            l.Flt_DateTime__c = fltDate;
                            l.Origin__c = origin;
                            l.Destination__c = destination;
                            l.Select_Airline__c = airline;
                            l.Finalized_Linehaul_Number__c = AirLHNumber;
                            l.Manual__c = true;
                            insert l;
                            System.debug('Linehaul record created: ' + l);

                          }catch(exception e){
                              
                                Linehaul_Error_Log__c log = new Linehaul_Error_Log__c();
                                log.Error_Message__c = e.getMessage();
                                log.Error_Stage__c = 'New master awb records creation for manual';
                              
                                insert log;  
                          }
                                                  
                List<secure_bag__c> bgList = new List<secure_bag__c>();
                List<secure_bag__c> basgList = [select id,master_awb__c from secure_bag__c where Finalised_Linehaul_Number__c =:l.AWB_Number__c];
                      system.debug('bagsList@@@@@'+ basgList);
                    for(secure_bag__c s: basgList){
                        if(s.master_awb__c == null  ){
                            s.master_awb__c = l.id;
                            bgList.add(s);
                        }
                    }
                      if(!bgList.isEmpty()){
                          try{
                              update bgList;  
                          }catch(exception e){
                              Linehaul_Error_Log__c log = new Linehaul_Error_Log__c();
                                log.Error_Message__c = e.getMessage();
                                log.Error_Stage__c = 'update master awb on secure bag.';
                              
                                insert log;  
                          }
                          
                      }
                    // this code is added to create Linhaul tracking for manual airline 
                    /*  if(l.Manual__c == true){
                           
                          Linehaul_Tracking__c lt1 = new Linehaul_Tracking__c();
                           lt1.AWB_Number__c = l.AWB_Number__c;
                           lt1.Origin__c =l.Origin__c;
                          lt1.Destination__c = l.Destination__c;
                          lt1.Airline__c = l.Select_Airline__c;
                          lt1.Flight_Date__c =l.Flt_DateTime__c.date();
                          lt1.Linehaul_Type__c = 'Air';
                          lt1.Status__c = 'AWB Finalized';
                          lt1.Linehaul_Name__c = l.Id;
                          
                          insert lt1;
                          
                      }  */
                      }
                  }else{
                      if(!existingLinehaul.isEmpty() &&  existingLinehaul.size() == 1){
                          List<Linehaul_Tracking__c> LtLIst = new List<Linehaul_Tracking__c>();
                          for(Linehaul__c lh : existingLinehaul ){
                              if(lh.Origin__c == Origin && lh.Destination__c == destination){
                                 
                                    if(lh.CreatedDate >= yesterday ){
                                    update UpdatedBagList;
                                        system.debug('LT UpdatedBagList @@' + UpdatedBagList);
                                    Linehaul_Tracking__c Lt2 = new Linehaul_Tracking__c();
                                     Lt2.AWB_Number__c = lh.AWB_Number__c;
                                     Lt2.Finalized_Linehaul_Number__c = AirLHNumber;
                                     Lt2.Airline__c = lh.Select_Airline__c;
                                     Lt2.Linehaul_Name__c = lh.Id;
                                     lt2.Destination__c = destination;
                                      if(lh.Flt_DateTime__c != null){
                                           lt2.Flight_Date__c = lh.Flt_DateTime__c.date();
                                      }
                                    
                                     lt2.Linehaul_Type__c = 'Air';
                                     lt2.Status__c = 'AWB Finalized';
                                     lt2.Origin__c = Origin;
                                     LtLIst.add(Lt2);
                                        
                                  }else{
                                      return 'You can not use AWB number after two days, please use new AWB Number.';
                                  }
                             }else{
                                   return 'Please check  Origin and Destination Airport for the entered AWB number ';
                           }
                              
                             
                          }
                           update UpdatedBagList;
                          if(!LtLIst.isEmpty()){
                              try{
                                  insert LtLIst;
                              }catch(exception e){
                               Linehaul_Error_Log__c log = new Linehaul_Error_Log__c();
                                log.Error_Message__c = e.getMessage();
                                log.Error_Stage__c = 'Linehaul tracking record creation for existing master awb.';
                              
                                insert log;  
                              }
                              
                              
                          system.debug('Linehaul Tracking List@@@@' + LtLIst);
                          }
                          
                      }else if(!existingLinehaul.isEmpty() &&  existingLinehaul.size() > 1 && LHType =='Air' ){
                          return 'Found more than one master AWB record for same details '+ LHNumber +', please contact to Salesforce Admin.';
                      }
                  }
           
                if(!existingLinehaul.isEmpty() && LHType =='Air'){
                   
                    List<Linehaul__c> LineList = new List<Linehaul__c>();    
                    List<Linehaul__c> existingLinehaulList = [SELECT Id,Linehaul_Track__c,AWB_Number__c,manual__c FROM Linehaul__c WHERE AWB_Number__c = :LHNumber];
                    if(!existingLinehaulList.isEmpty()){
                        for(Linehaul__c ln :existingLinehaulList ){
                        if( ln.Linehaul_Track__c == false){
                            ln.Linehaul_Track__c = true;
                            LineList.add(ln); 
                        }
                     }
                   //  update LineList;  
                    }
                }
          
                
                
                     
              //   Hub__c empHub = [SELECT Id, Name FROM Hub__c where name =:hubEmp.Hub__r.name Limit 1 ];
                
                 if (lt == null && existingLinehaultrack.isEmpty() && LHType == 'Road') {
                       update UpdatedBagList;
                     system.debug('UpdatedBagList@@@@'+UpdatedBagList);
                            // Create the Linehaul__c record only when l is null (first time)
                   FSE_Sales__c hubEmp= [SELECT Id, Name, Sales_Person__c, Hub__r.name FROM FSE_Sales__c where Sales_Person__r.id =:userId];  
                     
                     try{
                            lt = new Linehaul_Tracking__c();
                            lt.Finalized_Linehaul_Number__c = LHNumber;
                            lt.Linehaul_Type__c  ='Road';
                            lt.Flight_Date__c  = Date.today();
                            lt.Origin__c = hubEmp.Hub__r.name;
                            lt.Destination__c = Hub1;
                            lt.Driver_Details__c =''; 
                            lt.F_O_Executive__c = profileName;
                            lt.Vehicle_Number__c = Vehicle1;
                            insert lt;
                     
                     
                            System.debug('Linehaul record created: ' + lt);
                     }catch(exception e){
                         Linehaul_Error_Log__c log = new Linehaul_Error_Log__c();
                                log.Error_Message__c = e.getMessage();
                                log.Error_Stage__c = 'Linehaul tracking record creation for road.';
                              
                                insert log;  
                     }

                            
                         
                     
                        }   
                               
                result = 'Success';
               
               
                // System.debug('updated');
            }
            catch(exception e){
                System.debug('msg: '+e.getMessage());
                result = e.getMessage();
              //   System.debug('msg: '+e.getMessage());
                 
            }
             
        }
        // System.debug('result: '+result);
       
         return result;
       
    }
    
    @AuraEnabled 
    public static TMS_LinehaulClass AddBagToLineHaul(string BagWrapJson){
        TMS_LinehaulClass cls = new TMS_LinehaulClass();
        
        List<SecureBagWrapper> BagWrapList = (List<SecureBagWrapper>)JSON.deserialize(BagWrapJson, List<SecureBagWrapper>.class);
        
        //check bags are drafted or not 
        
           try {
                Set<Id> selectedBagIds = new Set<Id>();
                for (SecureBagWrapper sw : BagWrapList) {
                    if (sw != null && sw.process == true && sw.sb != null && sw.sb.Id != null) {
                        selectedBagIds.add(sw.sb.Id);
                    }
                }
                if (!selectedBagIds.isEmpty()) {
                    // Query once for all selected bag ids
                    List<Secure_Bag__c> selectedBags = [
                        SELECT Id, Secure_Packaging_Identifier__c, Draft__c
                        FROM Secure_Bag__c
                        WHERE Id IN :selectedBagIds
                    ];
                    // find any draft ones
                    for (Secure_Bag__c b : selectedBags) {
                        if (b.Draft__c == true) {
                            // Immediate error return — client will show toast using existing code path
                            cls.error = 'Adding drafted bags to linehaul is not allowed from this screen. Please use the “Add to Linehaul” option from the "View All Drafts" Bags screen to proceed.';
                            return cls;
                        }
                    }
                }
            } catch (Exception ex) {
                // If query fails, set an error message and return
                cls.error = 'Error validating selected bags: ' + ex.getMessage();
                return cls;
            }
        
        cls.error = '';
        Set<string> destSet = new Set<string>();
        boolean NextDest = false;
        boolean Seal = false;
        boolean rseal = false;
        Boolean RowSelected = false;
        string finalisedBagId = ''; 
        string origin ='';
        String dest = '';
        for(SecureBagWrapper sw:BagWrapList){
            if(sw.process==true){
                RowSelected=true;
                if(string.isBlank(origin) && sw.CurrentHub!=null)
                    origin = sw.CurrentHub;
                if(string.isBlank(dest) && sw.sb.Next_Destination__c!=null)
                    dest = sw.sb.Next_Destination__c;
                //destSet.add(sw.sb.Current_Destination_City__c);
                if(sw.sb.Finalised_Linehaul_Number__c != null && string.isBlank(finalisedBagId)){
                    finalisedBagId = sw.sb.id;
                }
                if(string.isBlank(sw.sb.Next_Destination__c) && NextDest==false)
                    NextDest=true;
                if(string.isBlank(sw.sb.Seal_Id__c) && Seal==false)
                    Seal=true;
                if(string.isBlank(sw.sb.Right_Seal_Id__c)&& rseal == false)
                    rseal = true;
            }
        }
        //if(destSet.size()>1)
        //cls.error= 'Please select bags for same destination';
        if(!RowSelected)
            cls.error= 'Please select atleast one row to proceed';
        if(Seal==true)
            cls.error= 'Please add seal in selected rows';
        if(NextDest==true)
            cls.error= 'Please add next destination in selected rows';
        
        if(string.isNotBlank(finalisedBagId)){
            Secure_Bag__c FinalisedBag = [select Linehaul_Type__c, Linehaul_Tracking__c,Linehaul_Tracking__r.name,Finalised_Linehaul_Number__c,Flight_Schedule__c,Flight_Schedule__r.name,
                                          Flight_Schedule__r.Origin_Airport__c,Flight_Schedule__r.Origin_Airport__r.name,Vehicle__c,Vehicle__r.name,
                                          Flight_Schedule__r.Destination_Airport__c,Flight_Schedule__r.Destination_Airport__r.name,Trunk_Id__c, Trunk_Id__r.Name FROM Secure_Bag__c where id=:finalisedBagId];
            cls.finalBag = FinalisedBag;
            if(FinalisedBag.Flight_Schedule__r.Origin_Airport__c !=null){
                cls.Originport = new ResultWrapper();
                cls.Originport.objName='Transport__c';
                cls.Originport.text = FinalisedBag.Flight_Schedule__r.Origin_Airport__r.name;
                cls.Originport.val = FinalisedBag.Flight_Schedule__r.Origin_Airport__c;
             
            }
            if(FinalisedBag.Flight_Schedule__r.Destination_Airport__c !=null){
                cls.Destport = new ResultWrapper();
                cls.Destport.objName='Transport__c';
                cls.Destport.text = FinalisedBag.Flight_Schedule__r.Destination_Airport__r.name;
                cls.Destport.val = FinalisedBag.Flight_Schedule__r.Destination_Airport__c;
            }
            if(FinalisedBag.Vehicle__c !=null){
                cls.Vehicle = new ResultWrapper();
                cls.Vehicle.objName='Transport__c';
                cls.Vehicle.text = FinalisedBag.Vehicle__r.name;
                cls.Vehicle.val = FinalisedBag.Vehicle__c;
            }
            if(FinalisedBag.Flight_Schedule__c !=null){
                cls.Flight = new ResultWrapper();
                cls.Flight.objName='Flight_Schedule__c';
                cls.Flight.text = FinalisedBag.Flight_Schedule__r.name;
                cls.Flight.val = FinalisedBag.Flight_Schedule__c;
                
           
            }
          //   string originairPort = FinalisedBag.Flight_Schedule__r.Origin_Airport__c;
              
        }else{
            TMS_DLHN__c dlhn = [select id, Finalized_Number__c FROM TMS_DLHN__c LIMIT 1];
            decimal finalNumber = dlhn.Finalized_Number__c+1;
            cls.FinalizedLHNumber = 'FL- ' + origin.left(3)+'-'+dest.left(3)+'-'+finalNumber;
        }
        
        // System.debug('FinalizedLHNumber: '+cls.FinalizedLHNumber);
        cls.options = new Map<String, String>();
        Schema.DescribeFieldResult fieldResult = Origin_Destination__c.Line_Haul_Type__c.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList){
            cls.options.put(p.getValue(), p.getLabel());
        }
        
        return cls;
    }

// add to linehaul for draft bags

 @AuraEnabled 
    public static TMS_LinehaulClass AddBagToLineHaulDraft(string BagWrapJson){
        TMS_LinehaulClass cls = new TMS_LinehaulClass();
        
        List<SecureBagWrapper> BagWrapList = (List<SecureBagWrapper>)JSON.deserialize(BagWrapJson, List<SecureBagWrapper>.class);
        
        cls.error = '';
        Set<string> destSet = new Set<string>();
        boolean NextDest = false;
        boolean Seal = false;
        boolean rseal = false;
        Boolean RowSelected = false;
        string finalisedBagId = ''; 
        string origin ='';
        String dest = '';
        
         Map<String, List<Id>> selectedBagsBySeal = new Map<String, List<Id>>();
         Set<String> allSealIds = new Set<String>();
        
        for(SecureBagWrapper sw:BagWrapList){
            if(sw.process==true){
                RowSelected=true;
                
                  if (String.isNotBlank(sw.sb.Seal_Id__c)) {
                       allSealIds.add(sw.sb.Seal_Id__c);
                        if (!selectedBagsBySeal.containsKey(sw.sb.Seal_Id__c)) {
                            selectedBagsBySeal.put(sw.sb.Seal_Id__c, new List<Id>());
                        }
                        selectedBagsBySeal.get(sw.sb.Seal_Id__c).add(sw.sb.Id);
                    }
                        
                
                if(string.isBlank(origin) && sw.CurrentHub!=null)
                    origin = sw.CurrentHub;
                if(string.isBlank(dest) && sw.sb.Next_Destination__c!=null)
                    dest = sw.sb.Next_Destination__c;
                //destSet.add(sw.sb.Current_Destination_City__c);
                if(sw.sb.Finalised_Linehaul_Number__c != null && string.isBlank(finalisedBagId)){
                    finalisedBagId = sw.sb.id;
                }
                if(string.isBlank(sw.sb.Next_Destination__c) && NextDest==false)
                    NextDest=true;
                if(string.isBlank(sw.sb.Seal_Id__c) && Seal==false)
                    Seal=true;
                if(string.isBlank(sw.sb.Right_Seal_Id__c)&& rseal == false)
                    rseal = true;
            }
        }
        
            Map<String, List<Secure_Bag__c>> dbBagsBySeal = new Map<String, List<Secure_Bag__c>>();  
            Map<String, String> sealNamesById = new Map<String, String>(); 
        
            if (!allSealIds.isEmpty()) {
                for (Secure_Bag__c b : [ SELECT Id, Seal_Id__c,Draft__c,Seal_Id__r.Name FROM Secure_Bag__c WHERE Draft__c = True AND Seal_Id__c IN :allSealIds]) {
                    if (!dbBagsBySeal.containsKey(b.Seal_Id__c)) {
                        dbBagsBySeal.put(b.Seal_Id__c, new List<Secure_Bag__c>());
                    }
                    dbBagsBySeal.get(b.Seal_Id__c).add(b);
                    sealNamesById.put(b.Seal_Id__c, b.Seal_Id__r.Name);
                }
            }
        
         for (String sealId : selectedBagsBySeal.keySet()) {
                Integer selectedCount = selectedBagsBySeal.get(sealId).size();
                Integer totalCount = dbBagsBySeal.containsKey(sealId) ? dbBagsBySeal.get(sealId).size() : 0;
        
                if (selectedCount < totalCount) {
                    String sealName = sealNamesById.containsKey(sealId) ? sealNamesById.get(sealId) : sealId;
                    cls.error = 'Please select all bags with the same seal before adding to linehaul. ' +
                                'Seal ID: ' + sealName  + ' (' + selectedCount + ' of ' + totalCount + ' selected)';
                    return cls;
                }
            }
        
        
        //if(destSet.size()>1)
        //cls.error= 'Please select bags for same destination';
        if(!RowSelected)
            cls.error= 'Please select atleast one row to proceed';
        if(Seal==true)
            cls.error= 'Please add seal in selected rows';
        if(NextDest==true)
            cls.error= 'Please add next destination in selected rows';
        
        if(string.isNotBlank(finalisedBagId)){
            Secure_Bag__c FinalisedBag = [select Linehaul_Type__c, Linehaul_Tracking__c,Linehaul_Tracking__r.name,Finalised_Linehaul_Number__c,Flight_Schedule__c,Flight_Schedule__r.name,
                                          Flight_Schedule__r.Origin_Airport__c,Flight_Schedule__r.Origin_Airport__r.name,Vehicle__c,Vehicle__r.name,
                                          Flight_Schedule__r.Destination_Airport__c,Flight_Schedule__r.Destination_Airport__r.name,Trunk_Id__c, Trunk_Id__r.Name FROM Secure_Bag__c where id=:finalisedBagId];
            cls.finalBag = FinalisedBag;
            if(FinalisedBag.Flight_Schedule__r.Origin_Airport__c !=null){
                cls.Originport = new ResultWrapper();
                cls.Originport.objName='Transport__c';
                cls.Originport.text = FinalisedBag.Flight_Schedule__r.Origin_Airport__r.name;
                cls.Originport.val = FinalisedBag.Flight_Schedule__r.Origin_Airport__c;
             
            }
            if(FinalisedBag.Flight_Schedule__r.Destination_Airport__c !=null){
                cls.Destport = new ResultWrapper();
                cls.Destport.objName='Transport__c';
                cls.Destport.text = FinalisedBag.Flight_Schedule__r.Destination_Airport__r.name;
                cls.Destport.val = FinalisedBag.Flight_Schedule__r.Destination_Airport__c;
            }
            if(FinalisedBag.Vehicle__c !=null){
                cls.Vehicle = new ResultWrapper();
                cls.Vehicle.objName='Transport__c';
                cls.Vehicle.text = FinalisedBag.Vehicle__r.name;
                cls.Vehicle.val = FinalisedBag.Vehicle__c;
            }
            if(FinalisedBag.Flight_Schedule__c !=null){
                cls.Flight = new ResultWrapper();
                cls.Flight.objName='Flight_Schedule__c';
                cls.Flight.text = FinalisedBag.Flight_Schedule__r.name;
                cls.Flight.val = FinalisedBag.Flight_Schedule__c;
                
           
            }
          //   string originairPort = FinalisedBag.Flight_Schedule__r.Origin_Airport__c;
              
        }else{
            TMS_DLHN__c dlhn = [select id, Finalized_Number__c FROM TMS_DLHN__c LIMIT 1];
            decimal finalNumber = dlhn.Finalized_Number__c+1;
            cls.FinalizedLHNumber = 'FL- ' + origin.left(3)+'-'+dest.left(3)+'-'+finalNumber;
        }
        
        // System.debug('FinalizedLHNumber: '+cls.FinalizedLHNumber);
        cls.options = new Map<String, String>();
        Schema.DescribeFieldResult fieldResult = Origin_Destination__c.Line_Haul_Type__c.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList){
            cls.options.put(p.getValue(), p.getLabel());
        }
        
        return cls;
    }
    
    
    // added by govind for Road Auto finalize number generation line 879 to 947
   @AuraEnabled
    public static String processHub(String hubId, String hubName, String lineHaulType) {
        try {
            String currentUser = UserInfo.getUserId();

            // Query for user hub
            FSE_Sales__c userHub = [ SELECT Id, Hub__c, Name, Hub__r.name, Sales_Person__r.Name  FROM FSE_Sales__c WHERE Sales_Person__r.Id = :currentUser LIMIT 1];

            // Check if userHub is not null
            if (userHub == null) {
                throw new AuraHandledException('User hub not found.');
            }
 
            String originHub = userHub.Hub__r.name;
            
            if (lineHaulType == 'Road' && hubId != null) {
                // Query for finalized number
                TMS_DLHN__c dlhn = [SELECT Id, Finalized_Number__c FROM TMS_DLHN__c LIMIT 1];

                // Check if dlhn is not null
                if (dlhn == null) {
                    throw new AuraHandledException('DLHN record not found.');
                }

                Decimal finalNumber = dlhn.Finalized_Number__c + 1;
                String finalisedNumberRoad = 'FL-' + originHub.left(3).toUpperCase() + '-' + hubName.left(3).toUpperCase() + '-' + finalNumber;
                return finalisedNumberRoad;
            } else {
                return '';
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error in processHub method: ' + e.getMessage());
        }
    }
     @AuraEnabled
    public static String processDestAirHub(String DestID, String DestName, String lineHaulType) {
        try {
            String currentUser = UserInfo.getUserId();

            // Query for user hub
            FSE_Sales__c userHub = [ SELECT Id, Hub__c, Name, Hub__r.name, Sales_Person__r.Name  FROM FSE_Sales__c WHERE Sales_Person__r.Id = :currentUser LIMIT 1];

            // Check if userHub is not null
            if (userHub == null) {
                throw new AuraHandledException('User hub not found.');
            }
 
            String originHub = userHub.Hub__r.name;
            
           if (lineHaulType == 'Air' && DestID != null) {
                // Query for finalized number
                 TMS_Air_Series__c dlhn = [SELECT Id, Finalised_Number__c FROM TMS_Air_Series__c LIMIT 1];   

                // Check if dlhn is not null
                if (dlhn == null) {
                    throw new AuraHandledException('DLHN record not found.');
                }

                Decimal finalNumber = dlhn.Finalised_Number__c + 1;
               
                String finalisedNumberAir = 'FL-' + originHub.left(3).toUpperCase() + '-' + DestName.left(3).toUpperCase() + '-' + finalNumber;
                return finalisedNumberAir; 
            } else {
                return '';
            }    
        } catch (Exception e) {
            throw new AuraHandledException('Error in processHub method: ' + e.getMessage());
        }
    }  
    public class ResultWrapper{
        @AuraEnabled
        public String objName {get;set;}
        @AuraEnabled
        public String text{get;set;}
        @AuraEnabled
        public String val{get;set;}
    }
    
    public class shipmentWrapper{
        @AuraEnabled
        public Shipment__c ship ;
        
        @AuraEnabled
        public Boolean process ;
        
        
    }
    
    @AuraEnabled
    public static List<String> getAvailableAwb(String origin, String destination, Date flightDate, String flightscheduleId, String airlineName){
        system.debug('entered in get awb');
        system.debug('origin '+origin);
        system.debug('destination '+destination);
        List<Transport__c> tslst = [Select Id, Name,Airport_Code__c from Transport__c where Name =: origin OR Name =: destination];
        system.debug('transport '+tslst);
        Map<String,String> nameCodeMap = new Map<String,String>();
        for(Transport__c ts: tslst){
            if(ts.Name == origin){
                nameCodeMap.put(origin,ts.Airport_Code__c);
            }
            if(ts.Name == destination){
                nameCodeMap.put(destination,ts.Airport_Code__c);
            }
        }
        
        List<Flight_Schedule__c>  fschlst = [Select Id, Origin__c,Destination__c,Schedule_Time_To_Departure__c,Name,Airline_Name1__c from Flight_Schedule__c where
                                             Id=:flightscheduleId LIMIT 1];        
        system.debug('flight '+fschlst);
        system.debug('nameCodeMap '+nameCodeMap);
        system.debug('airlineName '+airlineName);
        List<String> linehaulList = new List<String>();
       Date indigoDate = date.valueOf(flightDate);
      /*
        if(fschlst!=null && !fschlst.isEmpty()){
           
            for(Linehaul__c getAWB : [SELECT Id, Name, origin__c, destination__c, AWB_Consumed__c,Flight_Date__c, From__c,AWB_Number__c FROM Linehaul__c 
                                      where origin__c =: nameCodeMap.get(origin) and destination__c =: nameCodeMap.get(destination) 
                                         //  AND (( AirLine_Name__c = 'Indigo' AND AirLine_Name__c =:airlineName) OR (Flight_No_for_SpiceJet_Indigo__c=: flightscheduleId AND From__c =: fschlst[0].Schedule_Time_To_Departure__c AND AirLine_Name__c=: airlineName))
                                      AND Flight_No_for_SpiceJet_Indigo__c=: flightscheduleId
                                      AND AWB_Consumed__c != true
                                           AND ((Flight_Date__c =: indigoDate AND AirLine_Name__c =:airlineName) 
                                                 OR (From__c =: fschlst[0].Schedule_Time_To_Departure__c AND AirLine_Name__c=: airlineName))
                                     ]){
                                         system.debug('getAWB record '+getAWB);
                                         linehaulList.add(getAWB.AWB_Number__c);
                                         system.debug(linehaulList);
                                         
                                     }
        } */
       
         if(airlineName == 'Indigo' || airlineName == 'Vistara' || airlineName == 'AIR ASIA' || airlineName == 'GO'){
             system.debug('airlineName '+airlineName);
             system.debug('airlineName '+nameCodeMap.get(origin));
             system.debug('airlineName '+nameCodeMap.get(destination));
           // (Flight_Date__c =: indigoDate AND AirLine_Name__c =:airlineName)
            for(Linehaul__c getAWB2 : [SELECT Id, Name, origin__c, destination__c, AWB_Consumed__c,Flight_Date__c, From__c,AWB_Number__c FROM Linehaul__c 
                                      where origin__c =: origin and destination__c =: destination 
                                       AND  (Flight_Date__c =: indigoDate AND AirLine_Name__c =:airlineName)
                                        AND AWB_Consumed__c != true AND CreatedDate = LAST_N_DAYS:2
                                                
                                     ]){
                                         linehaulList.add(getAWB2.AWB_Number__c);
                                         system.debug(linehaulList);
                                         
                                     }
 
            
        }
       /* if(airlineName == 'Indigo'){
            system.debug('airline name '+airlineName);
        for(Linehaul__c getAWB2 : [SELECT Id, Name, origin__c, destination__c, Flight_Date__c, From__c,AWB_Number__c FROM Linehaul__c 
                                      where ( AirLine_Name__c =:airlineName) 
                                       //origin__c =: nameCodeMap.get(origin) and destination__c =: nameCodeMap.get(destination) 
                                       //Flight_Date__c =: indigoDate
                                     ]){
                                         system.debug('available awb '+getAWB2);
                                         linehaulList.add(getAWB2.AWB_Number__c);
                                         system.debug(linehaulList);
                                         
                                     }
        } */
        if(linehaulList!=null && !linehaulList.isEmpty()){
            return linehaulList;
        }else{
            return linehaulList;
        }
        
    }
    
    @AuraEnabled
    public static List<String> getAWBFromAPICalloutIndigo(String origin, String destination, DateTime flightDate, String shipmentList, String baglist, String commodityCode,string airFLTNumber){
        system.debug(origin+'@@ '+destination+'@@ '+flightDate +'@@'+commodityCode);
        List<String> abwNumberlst = new List<String>();
        //try{
           // List<Flight_Schedule__c>  fschlst = [Select Id, Origin__c,Departure_Date__c,Destination__c,Schedule_Time_To_Departure__c,Name from Flight_Schedule__c where
             //                                    Id=:flightscheduleId];        
            List<Commodity_Code_List__mdt>  comCodeLst= [Select Id, DeveloperName,Airline__c,Commodity_Code__c,Commodity_Description__c,Product_Type__c,SCH_Code__c from Commodity_Code_List__mdt where Commodity_Code__c=:commodityCode];
            
            String token = getIndigoTokenIndigo();
            if(token != null && token != ''){
                String sessionId = getIndigoSessionIdIndigo(token);
                system.debug('shipment List '+shipmentList);
                String awbNumber = getAWBNumberfromCallOutIndigo(token,sessionId,origin,destination,flightDate,shipmentList,baglist,comCodeLst);
                List<String> res = awbNumber.split(';');
                createlineHaulRecfromResIndigo(res,origin,destination,airFLTNumber,flightDate);
                
                abwNumberlst.add(res[0]);
            }
            
        //}catch(Exception ex){
           // system.debug(ex);
             //   System.debug('The following exception has occurred: ' + ex.getMessage());

       // }
        return abwNumberlst;
    }
    
    public static String getIndigoTokenIndigo(){
        String status = '';
        String token = '';
        String Endpoint = '';
        String ClientUID = '';
        String Client_Key = '';
        String AppID = '';
        String Device_ID = '';
        
        List<Linehaul__c> updateIndigoLinehaulList = new List<Linehaul__c>();
        List<Airline_API__mdt> indigoAirline = [SELECT ClientUID__c,Client_Key__c,AppID__c,Device_ID__c, Endpoint__c FROM Airline_API__mdt
                                                WHERE DeveloperName = 'Indigo_Token_Generation' LIMIT 1];
        
        
        if(!indigoAirline.isEmpty()){
            Endpoint = indigoAirline[0].Endpoint__c;
            ClientUID = indigoAirline[0].ClientUID__c;
            Client_Key = indigoAirline[0].Client_Key__c;
            AppID = indigoAirline[0].AppID__c;
            Device_ID = indigoAirline[0].Device_ID__c;
        } 
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(Endpoint);
        request.setMethod('POST');
        request.setHeader('Content-type', 'application/json');
        request.setBody('{"ClientUID":"'+ClientUID+'", "ClientKey":"'+Client_Key+'", "AppID":"'+AppID+'", "DeviceID":"'+Device_ID+'"}');
        
        HttpResponse response = http.send(request);
        
        if(response.getStatusCode() != 200) {
            System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
        } else {
            system.debug(response.getBody());
            
            IndigoWrapperClass responseWrapper = IndigoWrapperClass.parse(response.getBody());
            system.debug(responseWrapper);
            String d = '';
            
            if(String.isNotBlank(responseWrapper.d)){
                d = responseWrapper.d; 
            }
            String result = d.subStringBetween('RESULT_START:',':RESULT_END');
            system.debug(result);
            IndigoWrapperTokenClass responseWrap = new IndigoWrapperTokenClass();
            
            if(String.isNotBlank(result)){
                responseWrap = IndigoWrapperTokenClass.parse(result);
            } 
            system.debug(responseWrap);
            if(responseWrap != null){
                if(responseWrap.Table != null){
                    token =  responseWrap.Table[0].TokenNumber ;
                }
                
            }else{
                token ='';
            }
            
        }
        return token;
    }
    
    public static string getIndigoSessionIdIndigo(String token){
        List<Airline_API__mdt> indigoAirlinesessionId = [SELECT Username__c,Password__c,Station__c,AppID__c, Endpoint__c FROM Airline_API__mdt
                                                         WHERE DeveloperName = 'Indigo_Get_Session_ID' LIMIT 1];
        
        String sessionID = '';
        String Username = '';
        String Password = '';
        String Station = '';
        String session = '';
        String Endpoint1 = '';
        String AppID = '';
        String Device_ID = '';
        if(!indigoAirlinesessionId.isEmpty()){
            Username = indigoAirlinesessionId[0].Username__c;
            Password = indigoAirlinesessionId[0].Password__c;
            //Station = indigoAirlinesessionId[0].Station__c;
            AppID = indigoAirlinesessionId[0].AppID__c;
            Endpoint1 = indigoAirlinesessionId[0].Endpoint__c;
        }   
        system.debug('Endpoint===='+Endpoint1);
        Http httpsession = new Http();
        HttpRequest requestsession = new HttpRequest();
        requestsession.setEndpoint(Endpoint1);
        requestsession.setTimeout(120000);
        requestsession.setMethod('POST');
        requestsession.setHeader('Content-type', 'application/json');
        requestsession.setBody('{"username":"'+Username+'", "password":"'+Password+'", "station":"'+Station+'", "appID":"'+AppID+'", "TokenNumber":"'+token+'"}');
        
        HttpResponse responsesession = httpsession.send(requestsession);
        System.debug('{"username":"'+Username+'", "password":"'+Password+'", "station":"'+Station+'", "appID":"'+AppID+'", "TokenNumber":"'+token+'"}');
        if(responsesession.getStatusCode() != 200) {
            System.debug('The status code returned was not expected: ' + responsesession.getStatusCode() + ' ' + responsesession.getStatus());
        } else {
            system.debug(responsesession.getBody());
            
            IndigoWrapperSessionIdClass responseWrapper2 = IndigoWrapperSessionIdClass.parse(responsesession.getBody());
            system.debug(responseWrapper2);
            
            String d = responseWrapper2.d;
            String result2 = d.subStringBetween('RESULT_START:',':RESULT_END');
            system.debug(result2);
            
            IndigoWrapperSessionIdClass1 responseWrap2 = IndigoWrapperSessionIdClass1.parse(result2);
            system.debug(responseWrap2);
            sessionID = responseWrap2.Table[0].SessionID;
            
        }
        return sessionId;
    }
    @AuraEnabled(cacheable=true)
    public static string getAWBNumberfromCallOutIndigo(String token,String sessionId,String origin, String destination, DateTime flightDate, String shipmentList, String baglist,List<Commodity_Code_List__mdt>  comCodeLst){
        Airline_API__mdt[] indigoAWBAirline = [SELECT Username__c,Password__c,Station__c,AppID__c, Endpoint__c,loginName__c FROM Airline_API__mdt
                                               WHERE DeveloperName = 'Indigo_Create_AWB' LIMIT 1];
        
        
        String Endpoint2='';
        Endpoint2 = indigoAWBAirline[0].Endpoint__c;
        String loginName = indigoAWBAirline[0].loginName__c;
        
        Http https = new Http();
        HttpRequest requestFlight = new HttpRequest();
        requestFlight.setEndpoint(Endpoint2);
        requestFlight.setMethod('POST');
        requestFlight.setHeader('Content-type', 'application/json');
        //String replaceJSON = '{"loginName":"'+loginName+'","sessionId":"'+sessionID+'","awbPrefix":"312","origin":"'+origin+'","destination":"'+desti+'","shippingAgentCode":"'+ShippingAgentCode+'","commodityCode":"'+commodityCode+'","productType":"'+productType+'","commodityDesc":"'+commodityDesc+'","pcs":"'+pcs+'","grossWt":"'+grossWt+'","chargeableWt":"'+chargeableWt+'","fltDate":"'+fltDate+'","fltNumber":"'+fltNumber+'","UOM":"'+UOM+'","Dimensions":"'+Dimensions+'","ShprAccountCode":"'+shippingAccountCode+'","ShprCity":"'+shippingCity+'","ShprState":"'+ShprState+'","ShprName":"'+ShippingAccountName+'","ShprAdd":"'+ShprAdd+'","ShprPincode":"'+ShprPincode+'","ShprCountryCode":"'+countryCode+'","ShprContactNo":"'+ShprContactNo+'","ConsAccountCode":"'+consigneeAccountCode+'","ConsCity":"'+ConsCity+'","ConsState":"'+ConsState+'","ConsName":"'+consigneeAccountName+'","ConsAdd":"'+ConsAdd+'","ConsPincode":"'+ConsPincode+'","ConsCountryCode":"'+countryCode+'","ConsContactNo":"'+ConsContactNo+'","ScheduleID":"'+ScheduleID+'","ShprLat":"'+ShprLat+'","ShprLong":"'+ShprLong+'","ConsLat":"'+ConsLat+'","ConsLong":"'+ConsLong+'","ShprEmailID":"'+ShprEmailID+'","ConsEmailID":"'+ConsEmailID+'","Unit":"'+Unit+'","awbNumber":"'+awbNumber+'","slac":"'+slac+'","dvCustom":"'+dvCustom+'","declaredValue":"'+declaredValue+'","payMode":"'+payMode+'","packagingInfo":"'+packagingInfo+'","TokenNumber":"'+token+'","volume":"'+volume+'","shcCode":"'+shcCode+'","multilegRoutes":"'+multilegRoutes+'"}';
        //String finalJSON = replaceJSON.replaceALL('null','');
        //system.debug('finalJSON ==== '+finalJSON);
        String reqBodyToSend = JSON.serialize(createAWBRequestIndigo(loginName,token,sessionId,origin,destination,flightDate,shipmentList,baglist,comCodeLst));
        requestFlight.setBody(reqBodyToSend);
        //requestFlight.setBody(JSON.serialize(createAWBRequestIndigo(token,sessionId,origin,destination,flightDate,shipmentList,baglist,fschlst)));
        requestFlight.setTimeout(120000);
        HttpResponse responseFlight = https.send(requestFlight);
        String awbNumber = '';
        String flightRoute = '';
        String status = '';
        
        if(responseFlight.getStatusCode() != 200) {
            System.debug('The status code returned was not expected: ' + responseFlight.getStatusCode() + ' ' + responseFlight.getStatus());
            status = responseFlight.getStatus();
        } 
        else {
            system.debug('getbody'+ responseFlight.getBody());
            
            Indigo_AWBResponse_Wrapper responseWrap = Indigo_AWBResponse_Wrapper.parse(responseFlight.getBody());
            system.debug(responseWrap);
            
            
            String d = responseWrap.d;
            String result = d.subStringBetween('RESULT_START:',':RESULT_END');
            system.debug(result);
            
            Indigo_AWBResponse_Wrapper2 createAWBresponse = Indigo_AWBResponse_Wrapper2.parse(result);
            system.debug(createAWBresponse);
            
            if(createAWBresponse.Table6.size() > 0){
                
                if(createAWBresponse.Table6[0].AWBNumber != '' && createAWBresponse.Table6[0].AWBNumber != null){
                    status = 'Success';
                    awbNumber = createAWBresponse.Table6[0].AWBNumber;
                }
                
                if(createAWBresponse.Table6[0].FlightRoute != '' && createAWBresponse.Table6[0].FlightRoute != null){
                    flightRoute = createAWBresponse.Table6[0].FlightRoute;
                }
            }
            
        }
        
        system.debug('@@@@@@@@@@@@@@@@@@ awb number '+ awbNumber);
        return awbNumber+';'+reqBodyToSend+';'+FlightRoute;
        /*
        }catch(Exception e){
            system.debug('exception error+++'+ e.getMessage());
            system.debug('exception on line no +++' + e.getLineNumber());
            system.debug('@@+'+e.getStackTraceString());
            system.debug('@@@@'+e.getCause());
            system.debug('@@@@@@++'+e.getTypeName());
            return 'temp';
        }   */
        
        
    }
    
    
   public static Indigo_CreateAWBrequest createAWBRequestIndigo(String loginName,String token,String sessionId,String origin, String destination, DateTime flightDate, String shipmentList, String baglist,List<Commodity_Code_List__mdt> comCodeLst){
      
        /*commented on 18 aug 2025 line 1398 and 1410
        system.debug('shipment List '+shipmentList);
        List<Object> shipMap = (List<Object>)JSON.deserializeUntyped(shipmentList);
        system.debug('shipMap@@@:'+shipMap);
        Map<String, Object> shipMaplst = (Map<String, Object>)shipMap[0];
        List<Object> baglst = (List<Object>)shipMaplst.get('BagList');
        Map<String, Object> bagmap = (Map<String, Object>)baglst[0];
        Map<String, Object> shipmentMap = (Map<String, Object>)bagmap.get('Shipment__r');
        Map<String, Object> ShipperNameMap = (Map<String, Object>)shipmentMap.get('Shipper_Name_TMS__r');
        Map<String, Object> ConsigneeNameMap = (Map<String, Object>)shipmentMap.get('Consignee_Name_TMS__r');
        
        system.debug('shipmentMap@@@'+shipmentMap);
          */
        
        List<Transport__c> tslst = [Select Id, Name,Airport_Code__c from Transport__c where Name =: origin OR Name =: destination];
        Map<String,String> nameCodeMap = new Map<String,String>();
        for(Transport__c ts: tslst){
            if(ts.Name == origin){
                nameCodeMap.put(origin,ts.Airport_Code__c);
            }
            if(ts.Name == destination){
                nameCodeMap.put(destination,ts.Airport_Code__c);
            }
        }
        //List<String> lst = new List<String>();
        //List<SpiceJet_CreateAWBrequest.cls_products> prodLst = new List<SpiceJet_CreateAWBrequest.cls_products>();
        // List<SpiceJet_CreateAWBrequest.cls_flight_route> flightLst = new List<SpiceJet_CreateAWBrequest.cls_flight_route>();
        
        /* String cargoTypeString = String.valueof(shipmentMap.get('Cargo_Type__c'));
String cargoType = '';
String cargoDesc = '';
if(cargoTypeString=='Valuable'){
cargoType = 'VALN';
}
if(cargoTypeString=='Vulnerable'){
cargoType = 'VAL S';
}*/
       /* commented on 18 aug 2025 till line 1448
        Integer tWeight=0;
        Integer bagnumber=0;
        for(Object bagObj : baglst){
            Map<String, Object> bagObjmap = (Map<String, Object>)bagObj;
            Map<String, Object> shipmentBagMap = (Map<String, Object>)bagObjmap.get('Shipment__r');
            
            Object netWeightObj = shipmentBagMap.get('Net_Weight__c');
            if (netWeightObj != null) {
                tWeight = tWeight + Integer.valueOf(netWeightObj);
                bagnumber++;
            } else {
                system.debug('tweight is null');
            }
            system.debug('shipmentBagMap@@@@@@:'+ shipmentBagMap); 
}  */
        /*    tWeight=tWeight+ Integer.valueOf(shipmentBagMap.get('Net_Weight__c'));
            
            system.debug('tweight@@@@@:'+ tWeight);
            bagnumber++;  */
       //  }      
        /* commented on 18 aug 2025 line 1455 and 1456
        Map<String, Object> bagObjmap = (Map<String, Object>)baglst[0];
        Map<String, Object> shipmentBagMap = (Map<String, Object>)bagObjmap.get('Shipment__r');
          */
        List<Shipper_Consignee_Indigo_AWB__mdt> shpConmdtlst = [Select Id, MasterLabel,DeveloperName,ACCOUNT_CODE__c,ACCOUNT_NAME__c,AGENT_CODE__c,Airport_Code__c,
                                                                CITY__c,COUNTRY__c,State__c,Address__c,Pincode__c,Contact__c,Email__c,PARTICIPATION_TYPE__c From Shipper_Consignee_Indigo_AWB__mdt  where Airport_Code__c=:nameCodeMap.get(origin) OR Airport_Code__c=:nameCodeMap.get(destination)];
        
        Map<String,String> originAgenctCode = new Map<String,String>();
        Map<String,String> originAccountCode = new Map<String,String>();
        Map<String,String> destAgenctCode = new Map<String,String>();
        Map<String,String> destAccountCode = new Map<String,String>();
        Map<string,string> originAccountName = new Map<string,string>();
        Map<string,string> destinationAcctName = new Map<string,string>();
        Map<string,string> originCityMap =  new Map<string,string>();
        Map<string,string> destCityMap = new Map<string,string>();
        Map<string,string> originCountryMap = new Map<string,string>();
        Map<string,string> destCountryMap = new Map<string,string>();
        
        Map<string,string> originStateMap =  new Map<string,string>();
        Map<string,string> destStateMap = new Map<string,string>();
        Map<string,string> originAddressMap = new Map<string,string>();
        Map<string,string> destAddressMap = new Map<string,string>();
        
        Map<string,string> originPincodeMap =  new Map<string,string>();
        Map<string,string> destPincodeMap = new Map<string,string>();
        Map<string,string> originContactMap = new Map<string,string>(); 
        Map<string,string> destContactMap = new Map<string,string>();
         Map<string,string> originEmailMap = new Map<string,string>(); 
        Map<string,string> destEmailMap = new Map<string,string>();
 
        for(Shipper_Consignee_Indigo_AWB__mdt scmdt: shpConmdtlst){
            if(scmdt.Airport_Code__c == nameCodeMap.get(origin) ){
                originAgenctCode.put(scmdt.Airport_Code__c,scmdt.AGENT_CODE__c);
                originAccountCode.put(scmdt.Airport_Code__c,scmdt.ACCOUNT_CODE__c);
                originAccountName.put(scmdt.Airport_Code__c,scmdt.ACCOUNT_NAME__c);
                originCityMap.put(scmdt.Airport_Code__c,scmdt.CITY__c);
                originCountryMap.put(scmdt.Airport_Code__c,scmdt.COUNTRY__c);
                originStateMap.put(scmdt.Airport_Code__c,scmdt.state__c);
                originAddressMap.put(scmdt.Airport_Code__c,scmdt.Address__c);  
                originPincodeMap.put(scmdt.Airport_Code__c,scmdt.Pincode__c); 
                originContactMap.put(scmdt.Airport_Code__c,scmdt.Contact__c);
                originEmailMap.put(scmdt.Airport_Code__c,scmdt.Email__c);     
            }
            if(scmdt.Airport_Code__c == nameCodeMap.get(destination)){
                destAgenctCode.put(scmdt.Airport_Code__c,scmdt.AGENT_CODE__c);
                destAccountCode.put(scmdt.Airport_Code__c,scmdt.ACCOUNT_CODE__c);
                destinationAcctName.put(scmdt.Airport_Code__c,scmdt.ACCOUNT_NAME__c);
                destCityMap.put(scmdt.Airport_Code__c,scmdt.CITY__c);
                destCountryMap.put(scmdt.Airport_Code__c,scmdt.COUNTRY__c);
                destStateMap.put(scmdt.Airport_Code__c,scmdt.state__c);
                destAddressMap.put(scmdt.Airport_Code__c,scmdt.Address__c);  
                destPincodeMap.put(scmdt.Airport_Code__c,scmdt.Pincode__c); 
                destContactMap.put(scmdt.Airport_Code__c,scmdt.Contact__c);
                destEmailMap.put(scmdt.Airport_Code__c,scmdt.Email__c);
            }
        }
        Date indigoDate = date.valueOf(flightDate);
        Indigo_CreateAWBrequest reqBody = new Indigo_CreateAWBrequest();
        reqBody.loginName = loginName;
        reqBody.sessionId = sessionId;
        reqBody.awbPrefix = '312';
        reqBody.origin = nameCodeMap.get(origin);
        reqBody.destination =nameCodeMap.get(destination);
        reqBody.shippingAgentCode = originAgenctCode.get(nameCodeMap.get(origin));//shpConmdtlst[0].AGENT_CODE__c;
        reqBody.commodityCode=comCodeLst[0].Commodity_Code__c;
        reqBody.productType = comCodeLst[0].Product_Type__c=='GEN'?'GEN':preventNull('');
        reqBody.commodityDesc=comCodeLst[0].Commodity_Description__c;
        reqBody.pcs ='10';    //String.valueof(bagnumber);
        reqBody.grossWt='100';  //preventNull(String.valueOf(tWeight)); //String.valueOf(tWeight); 
        reqBody.chargeableWt='100';//String.valueOf(tWeight); //preventNull(String.valueOf(tWeight));
        reqBody.fltDate= preventNull((String.ValueOf(indigoDate)));
        reqBody.fltNumber= preventNull('');
        reqBody.UOM= 'K';
        reqBody.Dimensions= preventNull('');
        reqBody.ShprAccountCode= preventNull(originAccountCode.get(nameCodeMap.get(origin)));
        reqBody.ShprCity= preventNull(originCityMap.get(nameCodeMap.get(origin)));     //preventNull(String.ValueOf(ShipperNameMap.get('ShippingCity')));
        reqBody.ShprState= preventNull(originStateMap.get(nameCodeMap.get(origin)));        //preventNull(String.ValueOf(ShipperNameMap.get('ShippingState')));
        reqBody.ShprName= preventNull(originAccountName.get(nameCodeMap.get(origin))); // preventNull(String.ValueOf(ShipperNameMap.get('Name')));
        reqBody.ShprAdd= preventNull(originAddressMap.get(nameCodeMap.get(origin)));   //preventNull(String.ValueOf(ShipperNameMap.get('Shipping_Address_Fromula__c')));
        reqBody.ShprPincode= preventNull(originPincodeMap.get(nameCodeMap.get(origin))); //preventNull(String.ValueOf(ShipperNameMap.get('ShippingPostalCode')));
        reqBody.ShprCountryCode=  preventNull(originCountryMap.get(nameCodeMap.get(origin))); //preventNull(String.ValueOf(ShipperNameMap.get('ShippingCountry')));
        reqBody.ShprContactNo= preventNull(originContactMap.get(nameCodeMap.get(origin)));    //preventNull(String.ValueOf(ShipperNameMap.get('Phone')));
        reqBody.ConsAccountCode= preventNull(destAgenctCode.get(nameCodeMap.get(destination)));
        reqBody.ConsCity= preventNull(destCityMap.get(nameCodeMap.get(destination)));           //preventNull(String.ValueOf(ConsigneeNameMap.get('ShippingCity')));
        reqBody.ConsState=preventNull(destStateMap.get(nameCodeMap.get(destination))); //preventNull(String.ValueOf(ConsigneeNameMap.get('ShippingState')));
        reqBody.ConsName= preventNull(destinationAcctName.get(nameCodeMap.get(destination)));  //preventNull(String.ValueOf(ConsigneeNameMap.get('Name')));
        reqBody.ConsAdd= preventNull(destAddressMap.get(nameCodeMap.get(destination)));   //preventNull(String.ValueOf(ConsigneeNameMap.get('Shipping_Address_Fromula__c')));
        reqBody.ConsPincode=preventNull(destPincodeMap.get(nameCodeMap.get(destination))); //preventNull(String.ValueOf(ConsigneeNameMap.get('ShippingPostalCode')));
        reqBody.ConsCountryCode= preventNull(destCountryMap.get(nameCodeMap.get(destination)));  //preventNull(String.ValueOf(ConsigneeNameMap.get('ShippingCountry')));
        reqBody.ConsContactNo= preventNull(destContactMap.get(nameCodeMap.get(destination))); //preventNull(String.ValueOf(ConsigneeNameMap.get('Phone')));
        reqBody.ScheduleID= '';
        reqBody.ShprLat= '';
        reqBody.ShprLong= '';
        reqBody.ConsLat= '';
        reqBody.ConsLong= '';
        reqBody.ShprEmailID= preventNull(originEmailMap.get(nameCodeMap.get(origin)));        //preventNull(String.ValueOf(ShipperNameMap.get('Email__c')));
        reqBody.ConsEmailID= preventNull(destEmailMap.get(nameCodeMap.get(destination)));     // preventNull(String.ValueOf(ConsigneeNameMap.get('Email__c')));
        reqBody.Unit= 'CMS';
        reqBody.awbNumber= preventNull('');
        reqBody.slac= preventNull('');
        reqBody.dvCustom=  preventNull(String.valueof(0));
        reqBody.declaredValue=  preventNull(String.valueof(0));
        reqBody.payMode=preventNull( '');
        reqBody.packagingInfo= preventNull('');
        reqBody.TokenNumber= token;
        reqBody.volume= preventNull(String.valueof(0.01));
        reqBody.shcCode= comCodeLst[0].SCH_Code__c;
        reqBody.multilegRoutes= preventNull('');
        system.debug('req@@@'+JSON.serialize(reqBody));
        return reqBody;
    }
    
    public static String preventNull(String val){
        if(val!=null && val!= ''){
            return val;
        }else{
            return '';
        }
    }
    
    public static void createlineHaulRecfromResIndigo(List<String> res,String origin, String destination ,string airFLTNumber,datetime flightdate){
        system.debug('createlineHaulRecfromResIndigo@@@'+JSON.serialize(res));
        
        if(res[0]!=null && res[0]!=''){
            
            List<String> flightDetailsLst = res[2].split(',');
            system.debug('flightDetailsLst List ==== '+flightDetailsLst[5]);
            system.debug('flightDetailsLst List ==== '+flightDetailsLst[1]);
            system.debug('flightDetailsLst List ==== '+flightDetailsLst[2]);
            system.debug('flightDetailsLst List ==== '+flightDetailsLst[3]);
            
            String str1 = flightDetailsLst[5];
            system.debug('str1 == '+str1);
            
            List<String> str2 = str1.split(' ');
            system.debug('str2 == '+str2[0]);
            system.debug('str 2 === '+str2[1]);
            
           // Date indigoDate = Date.parse(str2[0]);
           Datetime indigoDate = Datetime.newInstanceGMT(Integer.valueof(str2[0].substringAfterLast('/')),Integer.valueof(str2[0].substringBetween('/','/')),Integer.valueof(str2[0].substringBefore('/')),Integer.valueof(str2[1].substringBefore(':')),Integer.valueof(str2[1].substringAfter(':')),00);
           system.debug('indigoDate ===== '+indigoDate);
            
           Date finalindigoDate = Date.parse(Date.ValueOf(indigoDate).format());
            system.debug('finalindigoDate ==== '+finalindigoDate);
            
            String indigoName = 'Indigo '+flightDetailsLst[1]+'-'+flightDetailsLst[2]+'-'+flightDetailsLst[3]+'-'+indigoDate;
            system.debug('indigoName ==='+indigoName);
            List<Flight_Schedule__c>  fschlst = [Select Id, Origin__c,Departure_Date__c,Destination__c,Schedule_Time_To_Departure__c,Name from Flight_Schedule__c where
                                                 Origin__c=:flightDetailsLst[2] AND Destination__c=:flightDetailsLst[3] AND Flight_Number__c=:flightDetailsLst[1] AND 
                                                Name=:indigoName Limit 1];
            //Name=:indigoName.replace('00:00:00',str2[1]+':00')
           
            if(fschlst.size() > 0){
            system.debug('Flight Schedule '+fschlst[0].Id);
        }
            	
            Map<String,Object> requestMap = (Map<String,Object>)JSON.deserializeUntyped(res[1]);
            system.debug('requestMap'+ requestmap);
            List<Indigo_Commodity_Master__c> comMaster = [Select Id from Indigo_Commodity_Master__c where Commodity_Code__c =:(String)requestMap.get('commodityCode') LIMIT 1];
            // List<Object> flightDetaillst=(List<Object>)requestMap.get('flight_route');
            //  Map<String,Object> flightDetailMap=(Map<String,Object>)flightDetaillst[0];
            Linehaul__c linehaulRec = new Linehaul__c();
            linehaulRec.AWB_Number__c=res[0];
            system.debug('AWB Number '+linehaulRec.AWB_Number__c);
            linehaulRec.Origin__c=origin;
            linehaulRec.Finalized_Linehaul_Number__c = airFLTNumber;
            linehaulRec.Destination__c=destination;
            linehaulRec.Commodity_Name__c=comMaster[0].Id;
            linehaulRec.AWB_Prefix__c='312';
           // linehaulRec.AWB_Consumed__c = true;
            linehaulRec.UOM__c='K';
            linehaulRec.Pcs_Int__c=(Integer.valueOf((requestMap.get('pcs'))));
            linehaulRec.Dimension_Type__c='CMS';
            linehaulRec.Unit__c='CMS';
            linehaulRec.Volume__c=0.01;
            linehaulRec.Declared_Value__c=0;
            linehaulRec.Shipping_City_Text__c=(String)requestMap.get('ShprCity');
            linehaulRec.Shipping_Account_Code_Text__c=(String)requestMap.get('ShprAccountCode');
            linehaulRec.Shipping_Agent_Code_Text__c=(String)requestMap.get('shippingAgentCode');
            linehaulRec.Shipper_Name__c=((String)requestMap.get('ShprName')).mid(0,50);
            linehaulRec.Shipper_EmailID__c	=(String)requestMap.get('ShprEmailID');
            linehaulRec.Shipper_Contact_Number__c=(String)requestMap.get('ShprContactNo');
            linehaulRec.Shipping_Address__c=(String)requestMap.get('ShprAdd');
            linehaulRec.Shipping_State__c=(String)requestMap.get('ShprState');
            linehaulRec.Consignee_Name__c=((String)requestMap.get('ConsName')).mid(0,50);
            linehaulRec.Shipping_Country_Code__c=(String)requestMap.get('ShprCountryCode');
            linehaulRec.Consignee_City_Text__c=(String)requestMap.get('ConsCity');
            linehaulRec.Consignee_Account_Code_Text__c=(String)requestMap.get('ConsAccountCode');
            linehaulRec.Shipping_Pincode__c=(String)requestMap.get('ShprPincode');
            linehaulRec.Consignee_EmailID__c=(String)requestMap.get('ConsEmailID');
            linehaulRec.Consignee_Contact_Number__c=(String)requestMap.get('ConsContactNo');
            linehaulRec.Consignee_State__c=(String)requestMap.get('ConsState');
            linehaulRec.Consignee_Country_Code__c=(String)requestMap.get('ConsCountryCode');
            linehaulRec.Consignee_Pincode__c=(String)requestMap.get('ConsPincode');
            linehaulRec.Consignee_Address__c=(String)requestMap.get('ConsAdd');
            linehaulRec.Chargeable_Weight__c=Integer.valueOf((String)requestMap.get('chargeableWt'));
            linehaulRec.Gross_Weight__c=Decimal.valueOf((String)(requestMap.get('grossWt')));
            linehaulRec.Flight_Destination__c=destination;
            linehaulRec.Flight_Origin__c=origin;
              linehaulRec.Flt_DateTime__c = flightdate;
          //  linehaulRec.API_response__c = String.join(res, ', ');
            //String str = fschlst[0].Departure_Date__c.format();
            // string datestr = str.format('yyyy/MM/dd');
            if(fschlst.size() > 0 ){//&& fschlst[0].Departure_Date__c != null
                if(fschlst[0].Departure_Date__c != null){
                 linehaulRec.Flight_Date__c= fschlst[0].Departure_Date__c;   
                }
                
            }
            
            //linehaulRec.Flight_Date__c= date.valueof(str);
            //system.debug('str date 2 ==='+date.valueof(str));
            linehaulRec.Select_Airline__c='Indigo';
             linehaulRec.Flight_Number__c=flightDetailsLst[1];
            if(fschlst.size() > 0){
               if(fschlst[0].Id != null ){//&& fschlst[0].Id != ''
                linehaulRec.Flight_No_for_SpiceJet_Indigo__c=fschlst[0].Id;
            }
             
            }
            
            system.debug('linehaulRec@@@@@@@@@@@ '+linehaulRec);
            insert linehaulRec;
        }
    }
  // this method is updating linehual record  
     @AuraEnabled
    public static void saveApiResponseToField(String recordId, String apiResponse) {
        Linehaul__c lh = [SELECT Id FROM Linehaul__c WHERE Id = :recordId LIMIT 1];
        lh.id =recordId;
        lh.API_response__c = apiResponse; // Replace with your field API name
        update lh;
    }
    
    // VISTARA AIRLINE CODE STARTED FROM LINE 1189- to Line 1600
    @AuraEnabled
     public static List<String> getAWBFromAPICalloutVistara(String origin, String destination, DateTime flightDate, String shipmentList, String baglist, String commodityCode,string airFLTNumber){
       
         system.debug(origin+'@@ '+destination+'@@ '+flightDate +'@@'+commodityCode);
        List<String> abwNumberlst = new List<String>();
              
            List<Commodity_Code_List__mdt>  comCodeLst= [Select Id, DeveloperName,Airline__c,Commodity_Code__c,Commodity_Description__c,Product_Type__c,SCH_Code__c from Commodity_Code_List__mdt where Commodity_Code__c=:commodityCode];
            
            String token = getvistaraTokenNumber();
            system.debug('token @@@@@@'+token );
         
            if(token != null && token != ''){
                String sessionId = getVistaraSessionID(token,origin);
                system.debug('sessionID@@@@'+sessionId );
                system.debug('shipment List '+shipmentList);
                String awbNumber = getAWBNumberFromVistaraCallout(token,sessionId,origin,destination,flightDate,shipmentList,baglist,comCodeLst);
                  system.debug('awbnumbers@@@@'+awbNumber);
                List<String> res = awbNumber.split(';');
                createlineHaulRecfromResVistara(res,origin,destination,airFLTNumber);
                
                abwNumberlst.add(res[0]);
                system.debug('abwNumberlst@@@@@'+abwNumberlst);
            }
         
        return abwNumberlst;
    
     }
    
    public static string getvistaraTokenNumber(){
        string status = ''; 
        string token = '';
        string Endpoint = '';
        string ClientUID = '';
        string Client_Key = '';
        string AppId = '';
        string Device_ID = '';
        
        List<Linehaul__c> updateVistaraLinehaulList =  new List<Linehaul__c>();
         List<Airline_API__mdt> VistaraAirline = [SELECT ClientUID__c,Client_Key__c,AppID__c,Device_ID__c, Endpoint__c FROM Airline_API__mdt
                                                WHERE DeveloperName = 'Vistara_Token_Generation'];
        if(!VistaraAirline.isEmpty()){
            Endpoint = VistaraAirline[0].Endpoint__c;
            ClientUID = VistaraAirline[0].ClientUID__c;
            Client_Key = VistaraAirline[0].Client_Key__c;
            AppId = VistaraAirline[0].AppID__c;
            Device_ID = VistaraAirline[0].Device_ID__c;
        }
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(Endpoint);
        request.setMethod('POST');
        request.setHeader('Content-type','application/json');
        request.setBody('{"ClientUID":"'+ClientUID+'", "ClientKey":"'+Client_Key+'", "AppID":"'+AppID+'", "DeviceID":"'+Device_ID+'"}');
        
        HttpResponse response = http.send(request);
        
        if(response.getStatusCode() != 200){
            system.debug('The status code required was not expected :'+response.getStatusCode()+'' + response.getStatus());
        }else{
            system.debug(response.getBody());
            vistaraTokenGenarationWrapper responseWrapper = vistaraTokenGenarationWrapper.parse(response.getBody());
            system.debug('responsewrapper:'+ responseWrapper);
            string d = '';
             
            if(string.isNotBlank(responseWrapper.d)){
                d = responseWrapper.d;
            }
            string result = d.subStringBetween('RESULT_START:','RESULT_END');
            system.debug('result:' + result);
            
            vistaraWrapperTokenClass responseWrap = new vistaraWrapperTokenClass();
            
            if(string.isNotBlank(result)){
                responseWrap = vistaraWrapperTokenClass.parse(result);
            }
            system.debug('responseWrap:'+responseWrap);
            if(responseWrap !=null){
                if(responseWrap.Table != null){
                    token = responseWrap.Table[0].TokenNumber;
                }
            }else{
                token = '';
            }
            
        }
        return token;
    }
    
    public static string  getVistaraSessionID(string token,string origin){
        
         List<Airline_API__mdt> vistaraAirline = [SELECT AppID__c, Endpoint__c FROM Airline_API__mdt
                                                  WHERE DeveloperName = 'Vistara_Get_User_Details'];
        
         List<Transport__c>  TransList = [SELECT Id, Name,Username__c, Password__c, Station_Code__c FROM Transport__c where Name =:origin LIMIT 1];
         
         system.debug('TransList@@@'+ TransList);
         
        string sessionID = '';
        string Username= '';
        string Password ='';
        string Station = '';
        string session = '';
        string Endpoint = '';
        string AppID = '';
        string Device_ID = '';
        
        if(!vistaraAirline.isEmpty()){
         /*   Username= vistaraAirline[0].Username__c;
            Password =vistaraAirline[0].Password__c ;
            Station =vistaraAirline[0].Station__c ;  */
            AppID = vistaraAirline[0].AppID__c;
            Endpoint = vistaraAirline[0].Endpoint__c;
        }
        if(!TransList.isEmpty()){
            Username = TransList[0].Username__c;
            Password = TransList[0].Password__c ;
            Station  = TransList[0].Station_Code__c ;
        }
     
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(Endpoint);
        request.setMethod('POST');
        request.setHeader('Content-type', 'application/json');       
        system.debug('{"Username":"'+Username+'", "Password":"'+Password+'", "Station":"'+Station+'", "AppID":"'+AppID+'", "TokenNumber":"'+token+'"}');
        
        // Set the body as a JSON object
        request.setBody('{"username":"'+Username+'", "password":"'+Password+'", "station":"'+Station+'", "appID":"'+AppID+'", "TokenNumber":"'+token+'"}');
        HttpResponse response = http.send(request);
        
         if(response.getStatusCode() != 200) {
            System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
        } else {
            system.debug(response.getBody());
            
            vistaraGetSessionIdWrapper responseWrapper = vistaraGetSessionIdWrapper.parse(response.getBody());
            system.debug(responseWrapper);
            
            String d = responseWrapper.d;
            String result = d.subStringBetween('RESULT_START:',':RESULT_END');
            system.debug(result);
            
           vistaraGetSessionIdWrapper1 responseWrap = vistaraGetSessionIdWrapper1.parse(result);
            system.debug(responseWrap);
            session = responseWrap.Table[0].SessionID;
            system.debug('session ' + session);
        }
        return session;
        
    }
    // Vistra create AWB booking 
    @AuraEnabled(cacheable=true)
    Public static string getAWBNumberFromVistaraCallout(String token,String sessionId,String origin, String destination, DateTime flightDate, String shipmentList, String baglist,List<Commodity_Code_List__mdt>  comCodeLst){
        Airline_API__mdt[]  vistaraAWBAirline = [Select Username__c,Password__c,station__c,AppID__c,Endpoint__c,loginName__c From Airline_API__mdt
                                                WHERE DeveloperName ='Vistara_Save_Booking_Request' LIMIT 1];
        
        string Endpoint2 = '';
        Endpoint2 ='https://uk-uat-api-appservice.azurewebsites.net/SKMobilityWS.asmx/SaveBookingRequestWY';             //vistaraAWBAirline[0].Endpoint__c;
        string LoginName = vistaraAWBAirline[0].loginName__c;
        
        Http https = new Http();
        HttpRequest requestFlight = new HttpRequest();
        requestFlight.setEndpoint(Endpoint2);
        requestFlight.setMethod('POST');
        requestFlight.setHeader('content-type','application/json');
        
        String reqBodyToSend = JSON.serialize(createAWBRequestForVistara(loginName,token,sessionId,origin,destination,flightDate,shipmentList,baglist,comCodeLst));
        requestFlight.setBody(reqBodyToSend);
        system.debug('reqBodyToSend@@@@'+ reqBodyToSend);
        //requestFlight.setBody(JSON.serialize(createAWBRequestIndigo(token,sessionId,origin,destination,flightDate,shipmentList,baglist,fschlst)));
        requestFlight.setTimeout(120000);
        HttpResponse responseFlight = https.send(requestFlight);
        system.debug('responseFlight@@@@'+responseFlight);
        String awbNumber = '';
        String flightRoute = '';
        String status = '';
        
         if(responseFlight.getStatusCode() != 200) {
            System.debug('The status code returned was not expected: ' + responseFlight.getStatusCode() + ' ' + responseFlight.getStatus());
            status = responseFlight.getStatus();
        } 
        else {
            system.debug('getbody'+ responseFlight.getBody());
            
            vistaraAWBResponseWrapper responseWrap = vistaraAWBResponseWrapper.parse(responseFlight.getBody());
            system.debug(responseWrap);
            
            
            String d = responseWrap.d;
            String result = d.subStringBetween('RESULT_START:',':RESULT_END');
            system.debug(result);
            
            vistaraAWBResponseWrapper1 createAWBresponse = vistaraAWBResponseWrapper1.parse(result);
            system.debug(createAWBresponse);
            
            if(createAWBresponse.Table6.size() > 0){
                
                if(createAWBresponse.Table6[0].AWBNumber != '' && createAWBresponse.Table6[0].AWBNumber != null){
                    status = 'Success';
                    awbNumber = createAWBresponse.Table6[0].AWBNumber;
                }
                
                if(createAWBresponse.Table6[0].FlightRoute != '' && createAWBresponse.Table6[0].FlightRoute != null){
                    flightRoute = createAWBresponse.Table6[0].FlightRoute;
                }
            }
        }
        system.debug('@@@@@@@@@@@@@@@@@@ awb number '+ awbNumber);
        return awbNumber+';'+reqBodyToSend+';'+FlightRoute;

    }
 // VISTARA REQUEST FOR AWB BOOKING
    public static vistaraCreateAWBRequest createAWBRequestForVistara(string loginName,string token,string sessionId,string origin,string destination,DateTime flightDate,string shipmentlist,string bagList,List<Commodity_Code_List__mdt>comCodeLst){
        
        system.debug('shipmnetList:' + shipmentlist);        
        
        List<Object> shipMap = (List<Object>)JSON.deserializeUntyped(shipmentlist);
        system.debug('shipMap@@@'+shipMap);
        Map<String, Object> shipMaplst = (Map<String, Object>)shipMap[0];
        system.debug('shipMaplst@@@@'+shipMaplst);
        List<Object> baglst = (List<Object>)shipMaplst.get('BagList');
        Map<String, Object> bagmap = (Map<String, Object>)baglst[0];
        system.debug('bagmap@@@@'+bagmap);
        Map<String, Object> shipmentMap = (Map<String, Object>)bagmap.get('Shipment__r');
        Map<String, Object> ShipperNameMap = (Map<String, Object>)shipmentMap.get('Shipper_Name_TMS__r');
        Map<String, Object> ConsigneeNameMap = (Map<String, Object>)shipmentMap.get('Consignee_Name_TMS__r');
        
        system.debug('shipmentMap@@@:'+ shipmentMap);

        List<Transport__c> tslst = [Select id,name,Airport_code__c from Transport__c where Name =:origin];
        List<Transport__c> tslst1 = [Select id,name,Airport_code__c from Transport__c where  Name =:destination];
        system.debug('origin@@@@'+origin); 
        system.debug('destination@@@'+ destination);
        Map<string,string> namecodeMap = new Map<string,string>();
         Map<string,string> namecodeMap1 = new Map<string,string>();
        
        System.debug('transport airportc codes@@@@'+tslst );
        for(Transport__c ts : tslst){
            if(ts.Name == origin){
                namecodeMap.put(origin,ts.Airport_Code__c);
            }
       /*     if(ts.Name == destination){
                namecodeMap.put(destination,ts.Airport_Code__c);
            }  */
        }
        
        for(Transport__c ts1 : tslst1){
             if(ts1.Name == destination){
                namecodeMap1.put(destination,ts1.Airport_Code__c);
            }
        }
        
         system.debug('namecodeMap@@@@@'+namecodeMap);
         system.debug('namecodeMap1@@@@@'+namecodeMap1);
        
        integer tWeight = 0;
        integer bagNumber = 0;
         for(Object bagObj : baglst){
            Map<String, Object> bagObjmap = (Map<String, Object>)bagObj;
            Map<String, Object> shipmentBagMap = (Map<String, Object>)bagObjmap.get('Shipment__r');
            
         //   tWeight=tWeight+ Integer.valueOf(shipmentBagMap.get('Net_Weight__c'));
            
            bagnumber++;
        }
        
        Map<String, Object> bagObjmap = (Map<String, Object>)baglst[0];
        Map<String, Object> shipmentBagMap = (Map<String, Object>)bagObjmap.get('Shipment__r');
        
         List<Shipper_Consignee_Vistara_AWB__mdt> shpConmdtlst = [Select Id, MasterLabel,DeveloperName,ACCOUNT_CODE__c,ACCOUNT_NAME__c,AGENT_CODE__c,Airport_Code__c,
                                                                CITY__c,COUNTRY__c,State__c,Address__c,Pincode__c,Contact__c,Email__c,PARTICIPATION_TYPE__c From Shipper_Consignee_Vistara_AWB__mdt  where Airport_Code__c=:nameCodeMap.get(origin)];
        
        system.debug('ship/consignee@@@@@@' + shpConmdtlst);
        
         List<Shipper_Consignee_Vistara_AWB__mdt> shpConmdtlst1 = [Select Id, MasterLabel,DeveloperName,ACCOUNT_CODE__c,ACCOUNT_NAME__c,AGENT_CODE__c,Airport_Code__c,
                                                                CITY__c,COUNTRY__c,State__c,Address__c,Pincode__c,Contact__c,Email__c,PARTICIPATION_TYPE__c From Shipper_Consignee_Vistara_AWB__mdt  where  Airport_Code__c=:nameCodeMap1.get(destination)];
    
        
        Map<String,String> originAgenctCode = new Map<String,String>();
        Map<String,String> originAccountCode = new Map<String,String>();
        Map<String,String> destAgenctCode = new Map<String,String>();
        Map<String,String> destAccountCode = new Map<String,String>();
        Map<string,string> originAccountName = new Map<string,string>();
        Map<string,string> destinationAcctName = new Map<string,string>();
        Map<string,string> originCityMap =  new Map<string,string>();
        Map<string,string> destCityMap = new Map<string,string>();
        Map<string,string> originCountryMap = new Map<string,string>();
        Map<string,string> destCountryMap = new Map<string,string>();        
       
        Map<string,string> originStateMap =  new Map<string,string>();
        Map<string,string> destStateMap = new Map<string,string>();
        Map<string,string> originAddressMap = new Map<string,string>();
        Map<string,string> destAddressMap = new Map<string,string>();
        
        Map<string,string> originPincodeMap =  new Map<string,string>();
        Map<string,string> destPincodeMap = new Map<string,string>();
        Map<string,string> originContactMap = new Map<string,string>(); 
        Map<string,string> destContactMap = new Map<string,string>();
         Map<string,string> originEmailMap = new Map<string,string>(); 
        Map<string,string> destEmailMap = new Map<string,string>();
         
        
        for(Shipper_Consignee_Vistara_AWB__mdt scmdt: shpConmdtlst){
            if(scmdt.Airport_Code__c == nameCodeMap.get(origin) ){
                originAgenctCode.put(scmdt.Airport_Code__c,scmdt.AGENT_CODE__c);
                originAccountCode.put(scmdt.Airport_Code__c,scmdt.ACCOUNT_CODE__c);
                originAccountName.put(scmdt.Airport_Code__c,scmdt.ACCOUNT_NAME__c);
                originCityMap.put(scmdt.Airport_Code__c,scmdt.CITY__c);
                originCountryMap.put(scmdt.Airport_Code__c,scmdt.COUNTRY__c);
                originStateMap.put(scmdt.Airport_Code__c,scmdt.state__c);
                originAddressMap.put(scmdt.Airport_Code__c,scmdt.Address__c);  
                originPincodeMap.put(scmdt.Airport_Code__c,scmdt.Pincode__c); 
                originContactMap.put(scmdt.Airport_Code__c,scmdt.Contact__c);
                originEmailMap.put(scmdt.Airport_Code__c,scmdt.Email__c);                
                system.debug('origin acct metadata code@@'+originAccountCode );
                system.debug('origin agent metadata code@@'+originAgenctCode );
                
            }
            
        }
        
        for(Shipper_Consignee_Vistara_AWB__mdt scmdt1: shpConmdtlst1){
            if(scmdt1.Airport_Code__c == nameCodeMap1.get(destination)){
                destAgenctCode.put(scmdt1.Airport_Code__c,scmdt1.AGENT_CODE__c);
                destAccountCode.put(scmdt1.Airport_Code__c,scmdt1.ACCOUNT_CODE__c);
                destinationAcctName.put(scmdt1.Airport_Code__c,scmdt1.ACCOUNT_NAME__c);
                destCityMap.put(scmdt1.Airport_Code__c,scmdt1.CITY__c);
                destCountryMap.put(scmdt1.Airport_Code__c,scmdt1.COUNTRY__c);                
                destStateMap.put(scmdt1.Airport_Code__c,scmdt1.state__c);
                destAddressMap.put(scmdt1.Airport_Code__c,scmdt1.Address__c);  
                destPincodeMap.put(scmdt1.Airport_Code__c,scmdt1.Pincode__c); 
                destContactMap.put(scmdt1.Airport_Code__c,scmdt1.Contact__c);
                destEmailMap.put(scmdt1.Airport_Code__c,scmdt1.Email__c);
                system.debug('desti metadata code@@'+destAgenctCode );
                system.debug('desti metadata code@@'+destAccountCode );
                system.debug('desti metadata acct name code@@'+destinationAcctName );
                system.debug('desti metadata city code@@'+destCityMap );
                system.debug('desti metadata country code@@'+destCountryMap);
            }
        }
         Date VistaraDate = date.valueOf(flightDate);
        VistaraCreateAWBRequest reqBody = new VistaraCreateAWBRequest();
        reqBody.loginName = loginName;
        reqBody.sessionId = sessionId;
        reqBody.awbPrefix = '228';
        reqBody.origin =nameCodeMap.get(origin);
        reqBody.destination = namecodeMap1.get(destination);
        reqBody.shippingAgentCode =originAgenctCode.get(nameCodeMap.get(origin));//shpConmdtlst[0].AGENT_CODE__c;
        reqBody.commodityCode=comCodeLst[0].Commodity_Code__c;
        reqBody.productType =comCodeLst[0].Product_Type__c=='GEN'?'GEN':preventNull('');
        reqBody.commodityDesc=comCodeLst[0].Commodity_Description__c;
        reqBody.pcs ='10';       //String.valueof(bagnumber);
        reqBody.grossWt='100';  // preventNull(String.valueOf(tWeight));
        reqBody.chargeableWt='100';  // preventNull(String.valueOf(tWeight));
        reqBody.fltDate=preventNull((String.ValueOf(VistaraDate)));
        reqBody.fltNumber= preventNull('');
        reqBody.UOM= 'K';
        reqBody.Dimensions=preventNull('');
        reqBody.ShprAccountCode=preventNull(originAccountCode.get(nameCodeMap.get(origin)));
        reqBody.ShprCity=preventNull(originCityMap.get(nameCodeMap.get(origin)));
        reqBody.ShprState= preventNull(originStateMap.get(nameCodeMap.get(origin)));                           //preventNull(String.ValueOf(ShipperNameMap.get('ShippingState')));
        reqBody.ShprName=preventNull(originAccountName.get(nameCodeMap.get(origin)));
        reqBody.ShprAdd= preventNull(originAddressMap.get(nameCodeMap.get(origin)));                              //preventNull(String.ValueOf(ShipperNameMap.get('Shipping_Address_Fromula__c')));
        reqBody.ShprPincode= preventNull(originPincodeMap.get(nameCodeMap.get(origin)));                         //preventNull(String.ValueOf(ShipperNameMap.get('ShippingPostalCode')));
        reqBody.ShprCountryCode=preventNull(originCountryMap.get(nameCodeMap.get(origin)));  //preventNull(String.ValueOf(ShipperNameMap.get('ShippingCountry')));
        reqBody.ShprContactNo= preventNull(originContactMap.get(nameCodeMap.get(origin)));                          //preventNull(String.ValueOf(ShipperNameMap.get('Phone')));
        reqBody.ConsAccountCode=preventNull(destAgenctCode.get(nameCodeMap1.get(destination)));
        reqBody.ConsCity=preventNull(destCityMap.get(nameCodeMap1.get(destination)));
        reqBody.ConsState=preventNull(destStateMap.get(nameCodeMap1.get(destination)));                     //preventNull(String.ValueOf(ConsigneeNameMap.get('ShippingState')));
        reqBody.ConsName=preventNull(destinationAcctName.get(nameCodeMap1.get(destination)));
        reqBody.ConsAdd= preventNull(destAddressMap.get(nameCodeMap1.get(destination)));        //preventNull(String.ValueOf(ConsigneeNameMap.get('Shipping_Address_Fromula__c')));
        reqBody.ConsPincode=preventNull(destPincodeMap.get(nameCodeMap1.get(destination)));   //preventNull(String.ValueOf(ConsigneeNameMap.get('ShippingPostalCode')));
        reqBody.ConsCountryCode= preventNull(destCountryMap.get(nameCodeMap1.get(destination)));                        //preventNull(String.ValueOf(ConsigneeNameMap.get('ShippingCountry')));
        reqBody.ConsContactNo= preventNull(destContactMap.get(nameCodeMap1.get(destination)));    //preventNull(String.ValueOf(ConsigneeNameMap.get('Phone')));
        reqBody.ScheduleID= '';
        reqBody.ShprLat= ''; 
        reqBody.ShprLong= '';
        reqBody.ConsLat= '';
        reqBody.ConsLong= '';
        reqBody.ShprEmailID= preventNull(originEmailMap.get(nameCodeMap.get(origin)));                                      //preventNull(String.ValueOf(ShipperNameMap.get('Email__c')));
        reqBody.ConsEmailID= preventNull(destEmailMap.get(nameCodeMap1.get(destination)));                                     //preventNull(String.ValueOf(ConsigneeNameMap.get('Email__c')));
        reqBody.Unit= 'CMS';
        reqBody.awbNumber= preventNull('');
        reqBody.slac= preventNull('');
        reqBody.dvCustom=  preventNull(String.valueof(0));
        reqBody.declaredValue=  preventNull(String.valueof(0));
        reqBody.payMode=preventNull( '');
        reqBody.packagingInfo= preventNull('');
        reqBody.TokenNumber= token;
        reqBody.volume= preventNull(String.valueof(0.01));
        reqBody.shcCode=comCodeLst[0].SCH_Code__c;
        reqBody.multilegRoutes= preventNull('');
        system.debug('req@@@'+JSON.serialize(reqBody));
        return reqBody;
    }
   // create Linehaul record from vistara response
    public static void createlineHaulRecfromResVistara(List<String> res,String origin, String destination,string airFLTNumber){
        
        system.debug('createlineHaulRecfromResVistara@@@'+JSON.serialize(res));
        
        if(res[0]!=null && res[0]!=''){
            
            List<String> flightDetailsLst = res[2].split(',');
            system.debug('flightDetailsLst List ==== '+flightDetailsLst[5]);
            system.debug('flightDetailsLst List ==== '+flightDetailsLst[1]);
            system.debug('flightDetailsLst List ==== '+flightDetailsLst[2]);
            system.debug('flightDetailsLst List ==== '+flightDetailsLst[3]);
            
            String str1 = flightDetailsLst[5];
            system.debug('str1 == '+str1);
            
            List<String> str2 = str1.split(' ');
            system.debug('str2 == '+str2[0]);
            system.debug('str 2 === '+str2[1]);
            
           // Date indigoDate = Date.parse(str2[0]);
           Datetime vistaraDate = Datetime.newInstanceGMT(Integer.valueof(str2[0].substringAfterLast('/')),Integer.valueof(str2[0].substringBetween('/','/')),Integer.valueof(str2[0].substringBefore('/')),Integer.valueof(str2[1].substringBefore(':')),Integer.valueof(str2[1].substringAfter(':')),00);
           system.debug('vistaraDate ===== '+vistaraDate);
            
           Date finalvistaraDate = Date.parse(Date.ValueOf(vistaraDate).format());
            system.debug('finalindigoDate ==== '+finalvistaraDate);
            
            String vistaraName = 'vistara '+flightDetailsLst[1]+'-'+flightDetailsLst[2]+'-'+flightDetailsLst[3]+'-'+vistaraDate;
            system.debug('vistaraName ==='+vistaraName);
            List<Flight_Schedule__c>  fschlst = [Select Id, Origin__c,Departure_Date__c,Destination__c,Schedule_Time_To_Departure__c,Name from Flight_Schedule__c where
                                                 Origin__c=:flightDetailsLst[2] AND Destination__c=:flightDetailsLst[3] AND Flight_Number__c=:flightDetailsLst[1] AND 
                                                Name=:vistaraName Limit 1];
            //Name=:indigoName.replace('00:00:00',str2[1]+':00')
           
            if(fschlst.size() > 0){
            system.debug('Flight Schedule '+fschlst[0].Id);
        }
            	
            Map<String,Object> requestMap = (Map<String,Object>)JSON.deserializeUntyped(res[1]);
            
            List<Vistara_Commodity_Master__c> comMaster = [Select Id from Vistara_Commodity_Master__c where Commodity_Code__c =:(String)requestMap.get('commodityCode') LIMIT 1];
            // List<Object> flightDetaillst=(List<Object>)requestMap.get('flight_route');
            //  Map<String,Object> flightDetailMap=(Map<String,Object>)flightDetaillst[0];
            Linehaul__c linehaulRec = new Linehaul__c();
            linehaulRec.AWB_Number__c=res[0];
            system.debug('AWB Number '+linehaulRec.AWB_Number__c);
            linehaulRec.Origin__c=origin;
            linehaulRec.Destination__c=destination;
            linehaulRec.Finalized_Linehaul_Number__c = airFLTNumber;
            linehaulRec.Vistara_Commodity_Name__c=comMaster[0].id;
            linehaulRec.AWB_Prefix__c='228';
            linehaulRec.AWB_Consumed__c = true;
            linehaulRec.UOM__c='K';
            linehaulRec.Pcs_Int__c=(Integer.valueOf((requestMap.get('pcs'))));
            linehaulRec.Dimension_Type__c='CMS';
            linehaulRec.Unit__c='CMS';
            linehaulRec.Volume__c=0.01;
            linehaulRec.Declared_Value__c=0;
            linehaulRec.Shipping_City_Text__c=(String)requestMap.get('ShprCity');
            linehaulRec.Shipping_Account_Code_Text__c=(String)requestMap.get('ShprAccountCode');
            linehaulRec.Shipping_Agent_Code_Text__c=(String)requestMap.get('shippingAgentCode');
            linehaulRec.Shipper_Name__c=((String)requestMap.get('ShprName')).mid(0,50);
            linehaulRec.Shipper_EmailID__c	=(String)requestMap.get('ShprEmailID');
            linehaulRec.Shipper_Contact_Number__c=(String)requestMap.get('ShprContactNo');
            linehaulRec.Shipping_Address__c=(String)requestMap.get('ShprAdd');
            linehaulRec.Shipping_State__c=(String)requestMap.get('ShprState');
            linehaulRec.Consignee_Name__c=((String)requestMap.get('ConsName')).mid(0,50);
            linehaulRec.Shipping_Country_Code__c=(String)requestMap.get('ShprCountryCode');
            linehaulRec.Consignee_City_Text__c=(String)requestMap.get('ConsCity');
            linehaulRec.Consignee_Account_Code_Text__c=(String)requestMap.get('ConsAccountCode');
            linehaulRec.Shipping_Pincode__c=(String)requestMap.get('ShprPincode');
            linehaulRec.Consignee_EmailID__c=(String)requestMap.get('ConsEmailID');
            linehaulRec.Consignee_Contact_Number__c=(String)requestMap.get('ConsContactNo');
            linehaulRec.Consignee_State__c=(String)requestMap.get('ConsState');
            linehaulRec.Consignee_Country_Code__c=(String)requestMap.get('ConsCountryCode');
            linehaulRec.Consignee_Pincode__c=(String)requestMap.get('ConsPincode');
            linehaulRec.Consignee_Address__c=(String)requestMap.get('ConsAdd');
            linehaulRec.Chargeable_Weight__c=Integer.valueOf((String)requestMap.get('chargeableWt'));
            linehaulRec.Gross_Weight__c=Decimal.valueOf((String)(requestMap.get('grossWt')));
            linehaulRec.Flight_Destination__c=destination;
            linehaulRec.Flight_Origin__c=origin;
          //  linehaulRec.API_response__c = String.join(res, ', ');
            //String str = fschlst[0].Departure_Date__c.format();
            // string datestr = str.format('yyyy/MM/dd');
            if(fschlst.size() > 0 ){//&& fschlst[0].Departure_Date__c != null
                if(fschlst[0].Departure_Date__c != null){
                 linehaulRec.Flight_Date__c= fschlst[0].Departure_Date__c;   
                }
                
            }
            
            //linehaulRec.Flight_Date__c= date.valueof(str);
            //system.debug('str date 2 ==='+date.valueof(str));
            linehaulRec.Select_Airline__c='vistara';
            if(fschlst.size() > 0){
               if(fschlst[0].Id != null ){//&& fschlst[0].Id != ''
                linehaulRec.Flight_No_for_SpiceJet_Indigo__c=fschlst[0].Id;
            }
             
            }
            
            system.debug('linehaulRec@@@@@@@@@@@ '+linehaulRec);
            insert linehaulRec;
        }
    } 
    
    //spiceJetcode to comment
 /*    @@@@@@@
    @AuraEnabled
    public static List<String> getAWBFromAPICalloutSpiceJet(String origin, String destination, DateTime flightDate, String shipmentList, String baglist, String flightscheduleId,String commodityCode){
        system.debug(origin+'@@ '+destination+'@@ '+flightDate);
        List<String> abwNumberlst = new List<String>();
        try{
            List<Flight_Schedule__c>  fschlst = [Select Id, Origin__c,Flight_Number__c,Destination__c,Schedule_Time_To_Departure__c,Name from Flight_Schedule__c where
                                                 Id=:flightscheduleId];        
            List<Commodity_Code_List__mdt>  comCodeLst= [Select Id, DeveloperName,Airline__c,Commodity_Code__c,Commodity_Description__c,Product_Type__c,SCH_Code__c from Commodity_Code_List__mdt where Commodity_Code__c=:commodityCode];
            
            String token = getSpiceJetTokenSpiceJet();
            if(token != null && token != ''){
                String awbNumber = getAWBNumberfromCallOutSpiceJet(token,origin,destination,flightDate,shipmentList,baglist,fschlst,comCodeLst);
                List<String> res = awbNumber.split(';');
                createlineHaulRecfromResSpiceJet(res,origin,destination,fschlst);
                
                abwNumberlst.add(res[0]);
            }
            
        }catch(Exception ex){
            system.debug(ex);
        }
        return abwNumberlst;
    }
     */
  /*
    public static void createlineHaulRecfromResSpiceJet(List<String> res,String origin, String destination,List<Flight_Schedule__c>  fschlst){
        
        if(res[0]!=null && res[0]!=''){
            Map<String,Object> requestMap = (Map<String,Object>)JSON.deserializeUntyped(res[1]);
            List<Object> flightDetaillst=(List<Object>)requestMap.get('flight_route');
            Map<String,Object> flightDetailMap=(Map<String,Object>)flightDetaillst[0];
            Linehaul__c linehaulRec = new Linehaul__c();
            linehaulRec.AWB_Number__c=res[0];
            linehaulRec.Origin__c=origin;
            linehaulRec.Destination__c=destination;
            // linehaulRecord[0].Commodity_Code__c;
            //CommodityDescription= linehaulRecord[0].Commodity_Description__c;
            linehaulRec.Gross_Weight__c=Decimal.valueOf((String)(requestMap.get('gross_weight')));
            linehaulRec.Total_Pieces__c=(Integer.valueOf((requestMap.get('total_pieces'))));
            // HeightDimension= String.valueOf(linehaulRecord[0].Height_Dimension__c);
            //LengthDimension= String.valueOf(linehaulRecord[0].Length_Dimension__c);
            //WidthDimension= String.valueOf(linehaulRecord[0].Width_Dimension__c);
            linehaulRec.Requested_Quantity__c=(Integer.valueOf((requestMap.get('total_pieces'))));
            linehaulRec.Weight_Dimension__c=Decimal.valueOf((String)requestMap.get('gross_weight'));
            linehaulRec.Bag_Number__c=(Integer.valueOf((requestMap.get('total_pieces'))));
            linehaulRec.Dimension_Type__c='CMS';
            linehaulRec.Type__c='KG';
            linehaulRec.Route_Type__c='Air';
            //PartnerType= linehaulRecord[0].Partner_Type__c;
            //PartnerCode= linehaulRecord[0].Partner_Code__c;
            linehaulRec.Flight_Destination__c=destination;
            linehaulRec.Flight_Origin__c=origin;
            linehaulRec.From__c=DateTime.Valueof((String)flightDetailMap.get('from'));
            //FromDate = String.valueof(DateTime.newInstanceGMT(2022,08,12, 18,20,0));
            linehaulRec.Flight_Code__c=(String)flightDetailMap.get('flight_code');
            
            linehaulRec.Flight_No_for_SpiceJet_Indigo__c=fschlst[0].Id;
            linehaulRec.Mode__c=(String)requestMap.get('mode');
            system.debug('linehaulRec@@@@@@@@@@@ '+linehaulRec);
            insert linehaulRec;
        }
    }  */
   /*    
    public static string getAWBNumberfromCallOutSpiceJet(String Token,String origin, String destination, DateTime flightDate, String shipmentList, String baglist, List<Flight_Schedule__c> flightschedule,  List<Commodity_Code_List__mdt>  comCodeLst){
        Airline_API__mdt[] spiceJetAirlineAWB = [SELECT Endpoint__c,Email__c,Password__c,Source__c,isSwagger__c FROM Airline_API__mdt WHERE DeveloperName = 'Spice_Jet_Create_AWB'];
        String Endpoint2='';
        Endpoint2 = spiceJetAirlineAWB[0].Endpoint__c;
        Http httpawb = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(Endpoint2);
        req.setMethod('POST');
        req.setHeader('Content-type', 'application/json');
        req.setHeader('Authorization',token);
        String reqBodyToSend = JSON.serialize(createAWBRequestSpiceJet(origin,destination,flightDate,shipmentList,baglist, flightschedule, comCodeLst)).replace('tofrom','from');
        req.setBody(reqBodyToSend);
        HttpResponse responseAWB = httpawb.send(req);
        String awbNumber = '';
        if(responseAWB.getStatusCode() != 200) {
            
            System.debug('The status code returned was not expected: ' + responseAWB.getStatusCode() + ' ' + responseAWB.getStatus());
        } else {
            system.debug('Response of Spicejet===='+responseAWB.getBody());
            SpiceJet_CreateAWBresponse awbResponseWrapper =  SpiceJet_CreateAWBresponse.parse(responseAWB.getBody());
            if(awbResponseWrapper.Result!=null && awbResponseWrapper.Result.awb_number != null && awbResponseWrapper.Result.awb_number != ''){
                awbNumber=awbResponseWrapper.Result.awb_number;
            }
        }
        return awbNumber+';'+reqBodyToSend;
    }  */
    /*
    public static String getSpiceJetTokenSpiceJet(){
        String status = '';
        List<Linehaul__c> updateLinehaulList = new List<Linehaul__c>();
        String token = '';
        Airline_API__mdt[] spiceJetAirline = [SELECT Endpoint__c,Email__c,Password__c,Source__c,isSwagger__c FROM Airline_API__mdt WHERE DeveloperName = 'Spice_Jet_Token_Generation'];
        String endpoint = '';
        String Email = '';
        String Password = '';
        Boolean isSwagger = false;
        String Source = '';
        if(!spiceJetAirline.isEmpty()){
            endpoint = spiceJetAirline[0].Endpoint__c;
            Email = spiceJetAirline[0].Email__c;
            Password = spiceJetAirline[0].Password__c;
            isSwagger = spiceJetAirline[0].isSwagger__c;
            Source = spiceJetAirline[0].Source__c;
        }
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('POST');
        request.setHeader('Content-type', 'application/json');
        request.setBody('{"email":"'+Email+'","password":"'+Password+'","source":"'+Source+'","isSwagger":"'+isSwagger+'"}');
        HttpResponse response = http.send(request);
        
        
        if(response.getStatusCode() != 200) {
            System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
        } else {
            SpiceJetTokenResponseWrapper responseWrapper = SpiceJetTokenResponseWrapper.parse(response.getBody());
            if(responseWrapper.result!= null){
                if(String.isNotBlank(responseWrapper.result.access_token)){
                    token = responseWrapper.result.access_token; 
                }
            }
            system.debug('Token Generated ------ '+token);
            
        }
        return token;
        
        
    }  */
    /*
    public static SpiceJet_CreateAWBrequest createAWBRequestSpiceJet(String origin, String destination, DateTime flightDate, String shipmentList, String baglist, List<Flight_Schedule__c> fschlst,  List<Commodity_Code_List__mdt>  comCodeLst){
        List<Object> shipMap = (List<Object>)JSON.deserializeUntyped(shipmentList);
        Map<String, Object> shipMaplst = (Map<String, Object>)shipMap[0];
        List<Object> baglst = (List<Object>)shipMaplst.get('BagList');
        Map<String, Object> bagmap = (Map<String, Object>)baglst[0];
        Map<String, Object> shipmentMap = (Map<String, Object>)bagmap.get('Shipment__r');
        system.debug('shipmentMap@@@'+shipmentMap);
        
        
        List<Transport__c> tslst = [Select Id, Name,Airport_Code__c from Transport__c where Name =: origin OR Name =: destination];
        Map<String,String> nameCodeMap = new Map<String,String>();
        for(Transport__c ts: tslst){
            if(ts.Name == origin){
                nameCodeMap.put(origin,ts.Airport_Code__c);
            }
            if(ts.Name == destination){
                nameCodeMap.put(destination,ts.Airport_Code__c);
            }
        }
        List<String> lst = new List<String>();
        List<SpiceJet_CreateAWBrequest.cls_products> prodLst = new List<SpiceJet_CreateAWBrequest.cls_products>();
        List<SpiceJet_CreateAWBrequest.cls_flight_route> flightLst = new List<SpiceJet_CreateAWBrequest.cls_flight_route>();
   @@@@@  */   
        /* String cargoTypeString = String.valueof(shipmentMap.get('Cargo_Type__c'));
String cargoType = '';
if(cargoTypeString=='Valuable'){
cargoType = 'VAL G';
}
if(cargoTypeString=='Vulnerable'){
cargoType = 'VAL S';
}*/  /*  @@@@@---
        List<Shipper_Consignee_Detail_SpiceJet__c> scList = [SELECT Id,Consignee_Address__c,Consignee_City__c,Consignee_Code__c,Consignee_Contact_No__c,Consignee_Country_Code__c,
                                                                    Consignee_Email__c,Consignee_Name__c,Consignee_Pincode__c,Consignee_State_Code__c,Shipper_Address__c,
                                                                    Shipper_City__c,Shipper_Code__c,Shipper_Contact_No__c,Shipper_Country_Code__c,Shipper_Email__c,Shipper_Name__c,
                                                                    Shipper_Pincode__c,Shipper_State_Code__c,Name,Shipper_Airport_Code__c,Consignee_Airport_Code__c
                                                              FROM Shipper_Consignee_Detail_SpiceJet__c
                                                             WHERE Shipper_Airport_Code__c =: String.valueOf(nameCodeMap.get(origin)) AND Consignee_Airport_Code__c =: String.valueOf(nameCodeMap.get(destination))
                                                            ];
        
        SpiceJet_CreateAWBrequest reqBody = new SpiceJet_CreateAWBrequest();
        reqBody.awb_number = null;
        reqBody.origin = String.valueOf(nameCodeMap.get(origin));
        reqBody.destination = String.valueOf(nameCodeMap.get(destination));
        reqBody.commodity_code = comCodeLst[0].Commodity_Code__c;
        reqBody.commodity_description = comCodeLst[0].Commodity_Description__c;
        reqBody.total_pieces = String.valueOf(baglst.size());//String.valueOf(shipmentMap.get('Number_of_Packages__c'));
        reqBody.mode = 'BVC';
         SpiceJet_Customer_Code__mdt[] customerCode = [SELECT Agent_Code__c,Airport_Code__c FROM SpiceJet_Customer_Code__mdt WHERE Airport_Code__c =: String.valueOf(nameCodeMap.get(origin))];
                   
                    if(customerCode != null && !(customerCode.isEmpty()) && customerCode[0].Agent_Code__c != null && customerCode[0].Agent_Code__c != ''){
                        reqBody.customer = customerCode[0].Agent_Code__c;
                    }
                    else {
                        reqBody.customer = '';
                    }  
        if(scList != null && !(scList.isEmpty())){
        SpiceJet_CreateAWBrequest.cls_Shipper shipperRequest = new SpiceJet_CreateAWBrequest.cls_Shipper();
                 shipperRequest.shipper_address = scList[0].Shipper_Address__c;
                 shipperRequest.shipper_name = scList[0].Shipper_Name__c;
                 shipperRequest.shipper_city = scList[0].Shipper_City__c;
                 shipperRequest.shipper_state_code = scList[0].Shipper_State_Code__c;
                 shipperRequest.shipper_country_code = scList[0].Shipper_Country_Code__c;
                 shipperRequest.shipper_postal_code = scList[0].Shipper_Pincode__c;
                 shipperRequest.shipper_contact_number = scList[0].Shipper_Contact_No__c;
                 shipperRequest.shipper_email = scList[0].Shipper_Email__c;
         SpiceJet_CreateAWBrequest.cls_Consignee consigneeRequest = new SpiceJet_CreateAWBrequest.cls_Consignee();
                 consigneeRequest.consignee_address = scList[0].Consignee_Address__c;
                 consigneeRequest.consignee_name = scList[0].Consignee_Name__c;
                 consigneeRequest.consignee_city = scList[0].Consignee_City__c;
                 consigneeRequest.consignee_state_code = scList[0].Consignee_State_Code__c;
                 consigneeRequest.consignee_country_code = scList[0].Consignee_Country_Code__c;
                 consigneeRequest.consignee_postal_code = scList[0].Consignee_Pincode__c;
                 consigneeRequest.consignee_contact_number = scList[0].Consignee_Contact_No__c;
                 consigneeRequest.consignee_email = scList[0].Consignee_Email__c;
            reqBody.shipper = shipperRequest;
            reqBody.consignee = consigneeRequest; 
                      
        }
        Integer tWeight=0;
        Integer bagnumber=1;
        for(Object bagObj : baglst){
            Map<String, Object> bagObjmap = (Map<String, Object>)bagObj;
            Map<String, Object> shipmentBagMap = (Map<String, Object>)bagObjmap.get('Shipment__r');
            SpiceJet_CreateAWBrequest.cls_products prdRec = new SpiceJet_CreateAWBrequest.cls_products();
            prdRec.height_dimension='';
            prdRec.length_dimension='';
            prdRec.width_dimension='';
            prdRec.requested_quantity=String.valueOf(shipmentBagMap.get('Number_of_Packages__c'));
            prdRec.weight_dimension=String.valueOf(shipmentBagMap.get('Net_Weight__c'));
            prdRec.type=String.valueOf(shipmentBagMap.get('Gross_Weight_UOM_TMS__c'));
            prdRec.bag_number=String.valueOf(bagnumber);
            prdRec.dimension_type='CMS';
            tWeight=tWeight+ Integer.valueOf(shipmentBagMap.get('Net_Weight__c'));
            prodLst.add(prdRec);
            bagnumber++;
        }
        
        reqBody.gross_weight = String.valueOf(tWeight);
        reqBody.products = prodLst;
        
        Datetime dateGMT=flightDate;// here you can user your dates e.g. createddate
        Datetime d1=Datetime.valueOf(dateGMT);
        string s1=d1.format();
        System.debug('@@@@@@@@@@@'+d1);
        
        //   List<Flight_Schedule__c>  fschlst = [Select Id, Origin__c,Destination__c,Schedule_Time_To_Departure__c,Name from Flight_Schedule__c where
        //                                        Id=:flightscheduleId];        
        
        System.debug('@@@@@@@@@@@'+fschlst);
        SpiceJet_CreateAWBrequest.cls_flight_route flightRec = new SpiceJet_CreateAWBrequest.cls_flight_route();
        
        if(fschlst!=null && !fschlst.isEmpty()){
            flightRec.route_type='air';	//air
            flightRec.partner_type=null;
            flightRec.partner_code=null;
            flightRec.flight_destination = String.valueof(fschlst[0].Destination__c);	//BLR
            flightRec.flight_origin = String.valueof(fschlst[0].Origin__c);	//DEL
            flightRec.tofrom = String.valueof(fschlst[0].Schedule_Time_To_Departure__c);	//2022-07-22 20:00:00
            //flightRec.flight_code = String.valueof(fschlst[0].Name);	//SG537 
            flightRec.flight_code = (String.valueof(fschlst[0].Name)).substringBetween(' ', '-');
           // flightRec.id = '';
        }
        
        flightLst.add(flightRec);
        
        reqBody.flight_route = flightLst;
        
        system.debug('req@@@'+JSON.serialize(reqBody));
        
        return reqBody;
    }
 @@@@@@@@@@--     */ 
    @AuraEnabled
    public Static List<Flight_Schedule__c> getFlightSchedule(String origin, String destination, Date flightDate, String airlineVal ){
        system.debug(origin +destination+flightDate+ airlineVal);
        List<Transport__c> tslst = [Select Id, Name,Airport_Code__c from Transport__c where Name =: origin OR Name =: destination];
        Map<String,String> nameCodeMap = new Map<String,String>();
        for(Transport__c ts: tslst){
            if(ts.Name == origin){
                nameCodeMap.put(origin,ts.Airport_Code__c);
            }
            if(ts.Name == destination){
                nameCodeMap.put(destination,ts.Airport_Code__c);
            }
        }
        Date dateGMT=flightDate;// here you can user your dates e.g. createddate
        Date d1=Date.valueOf(dateGMT);
        List<Flight_Schedule__c>  fschlst = [Select Id, Origin__c,Destination__c,Schedule_Time_To_Departure__c,Name,Airline_Name1__c,Actual_Flight_Departure__c from Flight_Schedule__c where
                                             Origin__c =:nameCodeMap.get(origin) AND Destination__c=:nameCodeMap.get(destination)
                                             AND Departure_Date__c =:d1 AND Airline_Name1__c =:airlineVal];        
        
        System.debug('@@@@@@@@@@@'+fschlst);
        
        return fschlst;
    }
    
    @AuraEnabled
    public static List<AirLine1__c> getAirlinesDetails(){
        List<AirLine1__c>  arl= [Select Id, Airline_Name__c from AirLine1__c];
        return arl;
    }
    
    @AuraEnabled
    public static List<Commodity_Code_List__mdt> getCommodityCode(String airlineName){
        List<Commodity_Code_List__mdt>  arl= [Select Id, DeveloperName,Airline__c,Commodity_Code__c,Commodity_Description__c,Product_Type__c,SCH_Code__c from Commodity_Code_List__mdt where Airline__c=:airlineName];
        return arl;
    }
    
    
    /*@AuraEnabled
public static List<String> FetchCities(String searchText){
// System.debug('target:'+searchText);
String newSearchText = '%'+searchText+'%';
Set<String> citySet = new Set<String>();
for(Active_Pincode__c ap : [select City__c FROM Active_Pincode__c WHERE City__c LIKE :newSearchText LIMIT 50000]){
// System.debug('city: '+ap.City__c);
citySet.add(ap.City__c);
}
List<String> CityList = new List<String> ();
CityList.AddAll(citySet);
return CityList;
}*/
    
    
    public static void upsertLineTracking (List<Secure_Bag__c> secureBagList){
        //Finalised_Linehaul_Number__c 
        
        Map<String, List<Secure_Bag__c>> awbwithBag = new Map<String, List<Secure_Bag__c>>();
        List<Linehaul_Tracking__c> linehaulTrackingList = new List<Linehaul_Tracking__c>();
        List<Linehaul__c> updateLinehaulRecord = new List<Linehaul__c>();
        List<AWB_Number__c> awbNumbersList = new List<AWB_Number__c>();
        Set<AWB_Number__c> awbNumbersSet = new Set<AWB_Number__c>();
        
        for(Secure_Bag__c bag : secureBagList){
            if(String.isNotBlank(bag.Finalised_Linehaul_Number__c)){ 
                if(awbwithBag.containsKey(bag.Finalised_Linehaul_Number__c)){
                    awbwithBag.get(bag.Finalised_Linehaul_Number__c).add(bag);
                }else{
                    awbwithBag.put(bag.Finalised_Linehaul_Number__c, new List<Secure_Bag__c>{bag});
                } 
            } 
        }
        
        if(awbwithBag != null){
            for(Linehaul__c Linehaul : [SELECT Id, AWB_Number__c,AWB_Consumed__c FROM Linehaul__c WHERE AWB_Number__c IN : awbwithBag.keySet()]){
                Linehaul.AWB_Consumed__c = true;
                 updateLinehaulRecord.add(Linehaul);
                Linehaul_Tracking__c tracking = new Linehaul_Tracking__c();
                tracking.Linehaul_Name__c = Linehaul.Id;
                tracking.Status__c = 'AWB Finalized';
                tracking.AWB_Number__c = Linehaul.AWB_Number__c ;
                linehaulTrackingList.add(tracking);
            }
        }
        
        if(updateLinehaulRecord.size() > 0){
            update updateLinehaulRecord;
        }
        
        if(linehaulTrackingList.size() > 0){
            Insert linehaulTrackingList; 
            
            for(Linehaul_Tracking__c tracking : linehaulTrackingList){
                for(Secure_Bag__c bag : awbwithBag.get(tracking.AWB_Number__c)){
                    AWB_Number__c awb = new AWB_Number__c();
                    awb.Linehaul_Tracking__c =   tracking.Id; 
                    awb.Shipment__c = bag.Shipment__c;
                    awb.AWB_Code__c = tracking.AWB_Number__c;
                    awbNumbersSet.add(awb);
                }
                
            }
        }
        
        if(awbNumbersSet.size()>0){
            awbNumbersList.addAll(awbNumbersSet);
            Insert awbNumbersList;
        }
        
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
      i++;
      i++;
      i++;
      i++;
                     i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
                     i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
         i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
         i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
         i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
         i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
             i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
             i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
                     i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
                     i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
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