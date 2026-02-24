/**
 * @description       : 
 * @author            : Imran
 * @group             : 
 * @Created on  	  : 17-06-2025
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   17-06-2025   Imran								   Initial Version
**/

public class TMS_AddSecureBagOnValutShipment {
    @AuraEnabled
    public static Vault_Shipmet__c shipmentRecordGet(String shipmentRecordId){
        try { 

            //System.debug('=============shippingNoteNumber: ' + shipmentRecordId);
            Vault_Shipmet__c  shipmentRecord = new Vault_Shipmet__c();

            Vault_Shipmet__c [] tempDate = [
                SELECT ID, Name,Number_of_Packages__c FROM Vault_Shipmet__c WHERE Id =: shipmentRecordId LIMIT 1];

            //System.debug('=============tempDate: ' + tempDate);

            return tempDate.size() > 0 ? tempDate[0] : null;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
  @AuraEnabled
public static String createSecureBagRecords(String bagId, String shipmentID) {
    System.debug('shipmentID :' + shipmentID);
	String result;
    List<Secure_Packaging__c> securePackagingList = [ SELECT Id, Name, Vault_Shipmet__c, Shipment__c, Status__c, RecordType.Name  
        FROM Secure_Packaging__c  WHERE Name = :bagId AND RecordType.Name = 'Secure Bag' ];
		System.debug('36 securePackagingList :'+securePackagingList);
    if(securePackagingList.size()>0)
    {
        Secure_Packaging__c securePackaging = securePackagingList[0];        
        if (securePackaging.Status__c != 'Available') {
            result = 'Secure Bag is not available. Try with another one.';
        }
        else
        {
            if (String.isNotBlank(shipmentID) && shipmentID != 'null') {
                try
                {
                    securePackaging.Status__c = 'Consumed';
                    securePackaging.Vault_Shipmet__c = shipmentID;
                    update securePackaging;
                    Vault_Shipmet__c VS = [ SELECT Id, Secure_Bags__c  FROM Vault_Shipmet__c  WHERE Id = :shipmentID ];                
                    VS.Secure_Bags__c = (VS.Secure_Bags__c == null) ? bagId : (VS.Secure_Bags__c + ',' + bagId);
                    update VS;   
                    result='success';
                }catch(Exception e)
                {
                    result='Failed '+e.getMessage();
                }         
            }
    	}		       
    }
    else
    {
        result='No Secure packaging Found,Please Enter Correct one';
    }
	return result;
}


    
}