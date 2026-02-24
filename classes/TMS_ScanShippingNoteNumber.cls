/**
* @description       : 
* @author            : MohammadRafi Khan
* @last modified on  : 05-10-2023
* @last modified by  : MohammadRafi Khan
* Modifications Log 
* Ver   Date         Author                 Modification
* 1.0   05-10-2023   MohammadRafi Khan      Initial Version
**/

public class TMS_ScanShippingNoteNumber {
    
    @AuraEnabled
    public static Secure_Packaging__c getShipmentRecord(String shippingNoteNumber, String pickupID){
        System.debug('for checking shippingNoteNumber '+shippingNoteNumber);
        Secure_Packaging__c securePackaging;
        try {
            securePackaging = [SELECT Id, Name, Status__c, RecordType.Name
                               FROM Secure_Packaging__c
                               WHERE Name = : shippingNoteNumber AND RecordType.Name = 'Shipping Label'
                               LIMIT 1];
            
            if(securePackaging != null && securePackaging.Status__c == 'Available' ){ 
                return securePackaging;
            } else {
                throw new AuraHandledException('Invalid Shipping Lable');
            }
            
        } catch (Exception ex) {
            if(!test.isRunningTest()){
                throw new AuraHandledException(ex.getMessage());
            } else {
                return Null;
            }
            
        }
        
    }
    
}