/**
* @description       : 
* @author            : rafi.khan@bvclogistics.com
* @group             : 
* @last modified on  : 25-12-2023
* @last modified by  : rafi.khan@bvclogistics.com
**/

trigger WeightTrigger on Weight__c (after insert,after update) {
    if(trigger.isAfter && trigger.isUpdate){
        List<String> weightIds = new List<String>();
        
        for(Weight__c weightObj : trigger.new){
            if(weightObj.Number_of_Secure_Bags_Scanned__c == 0){
                weightIds.add(weightObj.Id);
            }
        }
        //System.debug('In trigger weightId :'+weightIds);
        
        List<Secure_Bag__c> secureBagList = new List<Secure_Bag__c>();
        secureBagList = [Select Id,Name,Volumetric_Weight__c,BVC_Gross_Weight_Manual_in_Grams__c from Secure_Bag__c
                         where Weight__c IN:weightIds];
        //System.debug('In trigger secureBagList :'+secureBagList);
        //System.debug('In trigger secureBagList.size() :'+secureBagList.size());
        
        Decimal AggregateVolumetricWeight = 0;
        Decimal AggregateBVCGrossWeightManual = 0;
        if(secureBagList.size()>0){
            for(Secure_Bag__c secObj: secureBagList){
                AggregateVolumetricWeight = AggregateVolumetricWeight + secObj.Volumetric_Weight__c;
                AggregateBVCGrossWeightManual = AggregateBVCGrossWeightManual + secObj.BVC_Gross_Weight_Manual_in_Grams__c;
            }
            //System.debug('In trigger AggregateVolumetricWeight : '+AggregateVolumetricWeight);
            //System.debug('In trigger AggregateBVCGrossWeightManual : '+AggregateBVCGrossWeightManual);
            
        }
        //System.debug('weightId '+weightIds);
        List<Shipment__c> shipList = new List<Shipment__c>();
        shipList = [Select Id,Name,Volumetric_Weight__c,BVC_Gross_Weight_Manual__c from Shipment__c
                    where Weight__c IN:weightIds];
        //System.debug('In trigger shipList :'+shipList);
        //System.debug('In trigger shipList.size() :'+shipList.size());
        
        if(shipList.size()>0){
            Shipment__c tempShipObj = new Shipment__c();
            for(Shipment__c shipObj : shipList){
                shipObj.Volumetric_Weight__c = AggregateVolumetricWeight;
                shipObj.BVC_Gross_Weight_Manual__c = AggregateBVCGrossWeightManual;
                shipObj.Weighing_Completed__c = true;
                tempShipObj.Volumetric_Weight__c = shipObj.Volumetric_Weight__c;
                tempShipObj.BVC_Gross_Weight_Manual__c = shipObj.BVC_Gross_Weight_Manual__c;
                tempShipObj.Weighing_Completed__c = shipObj.Weighing_Completed__c;
                
                if(tempShipObj.Volumetric_Weight__c > tempShipObj.BVC_Gross_Weight_Manual__c){
                    tempShipObj.Gross_Weight__c = tempShipObj.Volumetric_Weight__c;
                } else {
                    tempShipObj.Gross_Weight__c = tempShipObj.BVC_Gross_Weight_Manual__c;
                }
                
                tempShipObj.Id = shipObj.Id;
            }
            //System.debug('In trigger tempShipObj.Volumetric_Weight__c '+tempShipObj.Volumetric_Weight__c);
            //System.debug('In trigger tempShipObj.BVC_Gross_Weight_Manual__c '+tempShipObj.BVC_Gross_Weight_Manual__c);
            //System.debug('In trigger tempShipObj.Gross_Weight__c '+tempShipObj.Gross_Weight__c);
            Update tempShipObj;
            
        }
    }
}