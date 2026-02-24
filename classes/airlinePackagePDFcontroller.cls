public class airlinePackagePDFcontroller {

    public Trunk__c airlinePack { get; set; }
    public List<Trunk__c> airPack{ get; set; }
    public string packageTye {get;set;}
    public string param {get;set;}
    
    public airlinePackagePDFcontroller(ApexPages.StandardController controller) {
         
        string airId = ApexPages.currentPage().getParameters().get('id');
        this.airlinePack = (Trunk__c) controller.getRecord();
        system.debug('airId'+ airId);
        
        this.airPack = [ SELECT Id, Name,Trunk_name__r.barcodeurl__c, Trunk_name__c,Trunk_name__r.name, Trunk_weight__c, AWB_number__c, Flight_name__c, Linehaul_Tracking__c,Linehaul_Tracking__r.name , Trunk_Tear_Weight__c,
                             Airline_Trunk__c,Next_Destination__c,User_Hub__c, Left_Seal__c,Left_Seal__r.barcodeurl__c,Left_Seal__r.name, OSB__c, OST__c,Number_of_SB__c, Finalized_Linehaul_Number__c,Linehaul_Tracking__r.No_of_Shipment_Notes__c,Linehaul_Tracking__r.Origin__c,Linehaul_Tracking__r.Destination__c FROM Trunk__c
                            WHERE Id = :airId 
                        ]; 
            
            for(Trunk__c  tr : airPack){
                
                if(tr.Airline_Trunk__c != null){
                    packageTye = 'AT';
                }else if(tr.OSB__c != null){
                    packageTye = 'OSB';
                }else if(tr.OST__c != Null){
                    packageTye = 'CPMT';
                }else{
                    packageTye= 'BVC Trunk';
                }
                
                if(tr.Trunk_weight__c != Null){
                    param = 'KG';
                }
                
            }
            
            
    }
    
}