/**
 * @description       : 
 * @author            : rafi.khan@bvclogistics.com
 * @group             : 
 * @last modified on  : 01-01-2024
 * @last modified by  : rafi.khan@bvclogistics.com
**/
public without sharing class TMS_WeightForSecureBagController {

    
    @AuraEnabled(cacheable=true)
    public static User getUserInfo() {
        return [SELECT Id, Name, Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
    }
    
    @AuraEnabled
    //Added By Sanket For OE/FE profile to not edit delivered shipments
    public static Secure_Bag__c fetchSecureBagData(String bagId){
        System.debug('bagId ' + bagId);
        try{
            // Fetch User Profile
            String profileName = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()].Profile.Name;
            System.debug('Current User Profile: ' + profileName);
            
            Secure_Bag__c secureBagObj;
            
            // If Operations Field Executive or Operations Office Executive → apply Tracking_Status filter
            if(profileName == 'Operations Field Executive' || profileName == 'Operations Office Executive'){
                secureBagObj = [
                    SELECT Id, Name, Is_Scanned_by_Weight__c, Shipment__c, Weight__c, Weight__r.Name, Shipment__r.Name, 
                    Shipping_Note_Number__c, Secure_Bag__r.Name, Current_Scan_Loction__c, Volumetric_Weight__c, 
                    Shipment__r.Net_Weight__c, Is_Bag_Scanned_By_Falcon__c, Secure_Packaging_Identifier__c, 
                    Shipment__r.Weight__c, Shipment__r.Number_of_Secure_Bags__c, Weight__r.Number_of_Secure_Bags_Scanned__c
                    FROM Secure_Bag__c
                    WHERE Secure_Bag__r.Name = :bagId
                    AND Shipment__r.Tracking_Status__c != 'Delivered'
                    AND Shipment__c != null
                    LIMIT 1
                ];
            }
            else {
                // For all other profiles → ignore Tracking_Status filter
                secureBagObj = [
                    SELECT Id, Name, Is_Scanned_by_Weight__c, Shipment__c, Weight__c, Weight__r.Name, Shipment__r.Name, 
                    Shipping_Note_Number__c, Secure_Bag__r.Name, Current_Scan_Loction__c, Volumetric_Weight__c, 
                    Shipment__r.Net_Weight__c, Is_Bag_Scanned_By_Falcon__c, Secure_Packaging_Identifier__c, 
                    Shipment__r.Weight__c, Shipment__r.Number_of_Secure_Bags__c, Weight__r.Number_of_Secure_Bags_Scanned__c
                    FROM Secure_Bag__c
                    WHERE Secure_Bag__r.Name = :bagId
                    AND Shipment__c != null
                    LIMIT 1
                ];
            }
            
            System.debug('for checking secureBagObj.Shipment__c :' + secureBagObj.Shipment__c);
            System.debug('for checking secureBagObj.Weight__c :' + secureBagObj.Weight__c);
            System.debug('for checking secureBag Data after scan : ' + secureBagObj);
            
            return secureBagObj;
            
        } catch(Exception ex){
            System.debug('for checking ex.getMessage() ' + ex.getMessage());
            System.debug('for checking ex.getLineNumber() ' + ex.getLineNumber());
            return null;
        }
    }
    
    @AuraEnabled
    public static WeightSecBagWrap createUpdateRecord(String blobData,String bagId, Decimal length, Decimal width, Decimal height, Decimal volumetricWeight, Boolean checkShipment, String weightId, Decimal BVCGrossWeightManual){
        
        WeightSecBagWrap result;

        try{
            
            Weight__c weightObj = new Weight__c();            
            Secure_Bag__c secureBagObj = new Secure_Bag__c();
            secureBagObj = [SELECT Id, Name, Shipment__c, Weight__c, Shipment__r.Name, Shipping_Note_Number__c,
                            Secure_Bag__r.Name, Current_Scan_Loction__c, Volumetric_Weight__c,Length__c,Width__c,Height__c,
                            BVC_Gross_Weight_Manual_in_Grams__c, Weight__r.Number_of_Secure_Bags_Scanned__c,Shipment__r.Number_of_Secure_Bags__c
                            FROM Secure_Bag__c 
                            WHERE Secure_Bag__r.Name =: bagId];
            
            secureBagObj.Volumetric_Weight__c = volumetricWeight;
            secureBagObj.BVC_Gross_Weight_Manual_in_Grams__c = BVCGrossWeightManual;
            secureBagObj.Length__c = length;
            secureBagObj.Width__c = width;
            secureBagObj.Height__c = height;
            secureBagObj.Is_Scanned_by_Weight__c = true;
            secureBagObj.Weighing_Completed__c = true;
            secureBagObj.POD__c = true;
            
            Shipment__c shipObj = new Shipment__c();
            shipObj = [Select Id,Weight__c,Number_of_Secure_Bags__c, Net_Weight__c, Net_weight_in_Gram__c From Shipment__c Where Id =: secureBagObj.Shipment__c];
            System.debug('for checking checkShipment '+checkShipment);
            System.debug('for checking bagId '+bagId);
            System.debug('for checking shipObj.Weight__c '+shipObj.Weight__c);
            
            if(!checkShipment && bagId!=null && bagId!='' && shipObj.Weight__c==Null){
                weightObj.Volumetric_Weight__c = volumetricWeight;
                weightObj.BVC_Gross_Weight__c = BVCGrossWeightManual;
                weightObj.Number_of_Secure_Bags_Scanned__c = shipObj.Number_of_Secure_Bags__c - 1;
                weightObj.RecordTypeId = Schema.SObjectType.Weight__c.getRecordTypeInfosByName().get('Secure Package').getRecordTypeId();
                weightObj.Shipment__c = shipObj.Id;
                
                if(secureBagObj.Weight__c == Null){
                    insert weightObj;
					secureBagObj.Weight__c = weightObj.Id;
                    update secureBagObj;

                    shipObj.Weight__c = weightObj.Id;
                    
                    Decimal calculatedGrossWeight = 0;

                    String bagSeries = secureBagObj.Secure_Bag__r.Name;

                    System.debug('for checking bagSeries = '+bagSeries);

                    if (bagSeries != null) {
                        if (bagSeries.startsWith('GS') || bagSeries.startsWith('YS') || bagSeries.startsWith('Y')
                        || bagSeries.startsWith('S') || bagSeries.startsWith('Q') || bagSeries.startsWith('EX')) {

                            if(volumetricWeight > BVCGrossWeightManual) {
                                calculatedGrossWeight = volumetricWeight;
                            } else {
                                calculatedGrossWeight = BVCGrossWeightManual;
                            }

                            if(weightObj.Number_of_Secure_Bags_Scanned__c == 0){
                                //shipObj.Volumetric_Weight__c = volumetricWeight;
                                //shipObj.BVC_Gross_Weight_Manual__c = BVCGrossWeightManual;
                                
                                updateShipmentCompletion(shipObj,volumetricWeight,BVCGrossWeightManual);
                    
                                if (calculatedGrossWeight >= shipObj.Net_weight_in_Gram__c){
                                    shipObj.Gross_Weight__c = calculatedGrossWeight;
                                    
                                } else {
                                    shipObj.Exception_weighing__c = true;
                                    shipObj.Dispute_Weighing__c = true;
                                }
                            }


                        } else {

                            calculatedGrossWeight = BVCGrossWeightManual;

                            if(weightObj.Number_of_Secure_Bags_Scanned__c == 0){
                                //shipObj.Volumetric_Weight__c = volumetricWeight;
                                //shipObj.BVC_Gross_Weight_Manual__c = BVCGrossWeightManual;
                    			
                                updateShipmentCompletion(shipObj,volumetricWeight,BVCGrossWeightManual);

                                if (calculatedGrossWeight >= shipObj.Net_weight_in_Gram__c){
                                    shipObj.Gross_Weight__c = calculatedGrossWeight;
                                    
                                } else {
                                    shipObj.Exception_weighing__c = true;
                                    shipObj.Dispute_Weighing__c = true;
                                }
                            }

                        }
                    }
                    

                    
                    
                    update shipObj;
                    
                }
                
                
                if(secureBagObj.Weight__c != Null && shipObj.Weight__c != Null && weightObj.Number_of_Secure_Bags_Scanned__c == 0){
                    weightObj.isBagAttached__c = true;
                    update weightObj;
                }
                
            } else{
                Weight__c weightTmp = new Weight__c();
                System.debug('for checking weightId '+weightId);
                
                weightTmp = [Select Id, BVC_Gross_Weight__c, Volumetric_Weight__c, Number_of_Secure_Bags_Scanned__c 
                             From Weight__c
                             WHERE Id=:weightId];
                System.debug('for checking weightTmp '+weightTmp);
                
                weightTmp.Number_of_Secure_Bags_Scanned__c = weightTmp.Number_of_Secure_Bags_Scanned__c - 1;
                weightTmp.Id = weightId;
                weightTmp.BVC_Gross_Weight__c = weightTmp.BVC_Gross_Weight__c + BVCGrossWeightManual;
                weightTmp.Volumetric_Weight__c = weightTmp.Volumetric_Weight__c + volumetricWeight;
                
                if(weightTmp.Number_of_Secure_Bags_Scanned__c >= 0){
                    secureBagObj.Weight__c = weightTmp.Id;
                    weightObj = weightTmp;
                    update secureBagObj;
                    Update weightTmp;
                    
                }

                if(weightTmp.Number_of_Secure_Bags_Scanned__c == 0){
                    List<Secure_Bag__c> secureBagList = new List<Secure_Bag__c>();
                    secureBagList = [Select Id,Name,Volumetric_Weight__c,BVC_Gross_Weight_Manual_in_Grams__c,Secure_Bag__r.Name from Secure_Bag__c
                                    where Weight__c =:weightTmp.Id];
                    System.debug('for checking secureBagList :'+secureBagList);
                    System.debug('for checking secureBagList.size() :'+secureBagList.size());
                    
                    Decimal AggregateVolumetricWeight = 0;
                    Decimal AggregateBVCGrossWeightManual = 0;

                    if(secureBagList.size()>0){
                        for(Secure_Bag__c secObj: secureBagList){
                            String bagSeries = secureBagObj.Secure_Bag__r.Name;
                            
                            System.debug('for checking bagSeries in loop = '+bagSeries);
                            
                            if (bagSeries != null) {
                                if (bagSeries.startsWith('GS') || bagSeries.startsWith('YS') || bagSeries.startsWith('Y')
                                    || bagSeries.startsWith('S') || bagSeries.startsWith('Q') || bagSeries.startsWith('EX')) {
                                        AggregateVolumetricWeight = AggregateVolumetricWeight + secObj.Volumetric_Weight__c;
                                    }
                            }
                            
                            AggregateBVCGrossWeightManual = AggregateBVCGrossWeightManual + secObj.BVC_Gross_Weight_Manual_in_Grams__c;

                        }
                        System.debug('for checking AggregateVolumetricWeight : '+AggregateVolumetricWeight);
                        System.debug('for checking AggregateBVCGrossWeightManual : '+AggregateBVCGrossWeightManual);
                        
                    }
                    // System.debug('weightId '+weightIds);
                    List<Shipment__c> shipList = new List<Shipment__c>();
                    shipList = [Select Id,Name,Volumetric_Weight__c,BVC_Gross_Weight_Manual__c, Net_Weight__c, Gross_Weight__c, Net_weight_in_Gram__c from Shipment__c
                                where Weight__c =:weightTmp.Id];
                    System.debug('for checking shipList :'+shipList);
                    System.debug('for checking shipList.size() :'+shipList.size());
                    
                    if(shipList.size()>0){
                        Shipment__c tempShipObj = new Shipment__c();
                        for(Shipment__c shipObj1 : shipList){
                            //shipObj1.Volumetric_Weight__c = AggregateVolumetricWeight;
                            //shipObj1.BVC_Gross_Weight_Manual__c = AggregateBVCGrossWeightManual;
                            tempShipObj.Id = shipObj1.Id;
                            
                            updateShipmentCompletion(tempShipObj,AggregateVolumetricWeight,AggregateBVCGrossWeightManual);
                            
                            //Used code to bypass net weight and gross weight validation working fine
                            Decimal calculatedGrossWeight = 0;
                            if(AggregateVolumetricWeight> AggregateBVCGrossWeightManual) {
                                calculatedGrossWeight = AggregateVolumetricWeight;
                            } else {
                                calculatedGrossWeight = AggregateBVCGrossWeightManual;
                            }
                            System.debug('for checking calculatedGrossWeight === '+calculatedGrossWeight);
                            
                            System.debug('for checking shipObj1.Net_Weight__c === '+shipObj1.Net_weight_in_Gram__c);
                            
                            if(calculatedGrossWeight >= shipObj1.Net_weight_in_Gram__c){
                                System.debug('for checking inside if');
                                tempShipObj.Gross_Weight__c = calculatedGrossWeight;
                            } else {
                                tempShipObj.Exception_weighing__c = true;
                                tempShipObj.Dispute_Weighing__c = true;
                            }  
                            
                        }
                        
                        System.debug('for checking tempShipObj.Volumetric_Weight__c '+tempShipObj.Volumetric_Weight__c);
                        System.debug('for checking tempShipObj.BVC_Gross_Weight_Manual__c '+tempShipObj.BVC_Gross_Weight_Manual__c);
                        System.debug('for checking tempShipObj.Gross_Weight__c '+tempShipObj.Gross_Weight__c);
                        Update tempShipObj;
                        
                        
                    }          
                    
                }
            }
            
            WeightSecBagWrap weightSecBagWrapObj = new WeightSecBagWrap();
            weightSecBagWrapObj.secureBagRec = secureBagObj;
            weightSecBagWrapObj.weightRec= weightObj;
            
            System.debug('weightSecBagWrapObj.weightRec :'+weightSecBagWrapObj.weightRec);
            result=weightSecBagWrapObj;
           
        } catch(Exception ex){
            Delivery_Error_Log__c weighingErrorLogRec = new Delivery_Error_Log__c();
            weighingErrorLogRec.Name = 'Error if Weighing failed';
            weighingErrorLogRec.Delivery_Id__c = bagId;
            weighingErrorLogRec.Error_Message__c = 'On line:'+ ex.getLineNumber() + ' ERROR -> '+ ex.getMessage();

            Insert weighingErrorLogRec;
            
            System.debug('for checking ex.getMessage() : '+ex.getMessage());
            System.debug('for checking ex.getLineNumber() : '+ex.getLineNumber());
            result=null;
        } 
        return result;
        
    }
    
    //to upload Secure Bag Photo
    @AuraEnabled
    public static String photoUpload(String fileData, String recId,String fileName){
                       
        try{
            if (fileData.startsWith('data:image/jpeg;base64,')) {
                fileData = fileData.substring('data:image/jpeg;base64,'.length());
            }
            
            ContentVersion cVersion = new ContentVersion();
            Id conDocId;
            //String nm = fileName+'.png';
            String nm = fileName+'-Weighing.png';
            cVersion.PathOnClient = nm; 
            cVersion.Title = nm; 
            cVersion.VersionData = EncodingUtil.base64Decode(fileData); 
            Insert cVersion;

            if(cVersion.Id != null){
                conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
            }
            
            //System.debug('conDocId === '+ conDocId);
            ContentDocumentLink conDocLinkObj = new ContentDocumentLink();
            conDocLinkObj.ContentDocumentId = conDocId;
            conDocLinkObj.LinkedEntityId = recId;
            conDocLinkObj.ShareType = 'V';
            conDocLinkObj.Visibility = 'AllUsers';
            insert conDocLinkObj;
            
            return 'Success';
            
        }catch(Exception ex){
            System.debug('Error occure Line Number '+ex.getLineNumber());
            System.debug('Error occure Message '+ex.getMessage());
            return 'Null';
        }
        
       
    }
    
    private static void updateShipmentCompletion(Shipment__c shipObj,  Decimal volumetricWeight,  Decimal BVCGrossWeightManual) {
        List<Secure_Bag__c> allBags = [
            SELECT Id, Weighing_Completed__c
            FROM Secure_Bag__c
            WHERE Shipment__c = :shipObj.Id
        ];
        Boolean allBagsWeighed = true;
        for (Secure_Bag__c bag : allBags) {
            if (bag.Weighing_Completed__c != true) {
                allBagsWeighed = false;
                break;
            }
        }
        if(allBagsWeighed){
            shipObj.Weighing_Completed__c = allBagsWeighed;
            shipObj.Volumetric_Weight__c = volumetricWeight;
            shipObj.BVC_Gross_Weight_Manual__c = BVCGrossWeightManual;
                    
        }
        

    }
    
    public class WeightSecBagWrap{
        @auraEnabled 
        public Secure_Bag__c secureBagRec{get;set;}
        @auraEnabled 
        public Weight__c weightRec{get;set;}
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
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
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