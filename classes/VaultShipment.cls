public class VaultShipment 
{
    @AuraEnabled
 public static boolean getCustomerChilds(String accountRecId)
 {
     boolean resp = false;
     try
     {
     	List<Account> acList = [select Id from Account where parentId=:accountRecId]; 
         if(acList.size()>0)
             {
                 resp=true;
             }
     } catch(Exception e)
     { }
     return resp;
 }
    @AuraEnabled
 public static Map<string,String> saveVShipment(String vaultShipData)
 {
     System.debug('saveVShipment');
     System.debug('vaultShipData :'+vaultShipData);
     Map<string,String> resultToReturn = new Map<String,String>();
     Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(vaultShipData);
     Vault_Shipmet__c newRecord = new Vault_Shipmet__c();

     if(result.get('customerId')!=null)
     {
         newRecord.Customer__c = (String) result.get('customerId');
     }
     if(result.get('BillingAccount')!=null)
     {
         newRecord.Billing_Account__c = (String) result.get('BillingAccount');
     }
     // *************** setting Billing Account and Billing Address   *****************
     if(result.get('BillingAccount')==null)
     {
         String CustId = (String) result.get('customerId');         
         newRecord.Billing_Account__c = CustId;
         try{
             AddressBook__c BA = [SELECT Id,Name,Is_Primary__c FROM AddressBook__c where Customer__c =:CustId and Is_Primary__c=true limit 1];
         newRecord.Billing_Address__c = BA.Id;
         }catch(Exception e)
         {
             
         }         
     } 
     
     if(result.get('BillingAddress')!=null)
     {
         newRecord.Billing_Address__c = (String) result.get('BillingAddress');
     }    
     if(result.get('ShippingAccount')!=null)
     {
         newRecord.Shipping_Account__c = (String) result.get('ShippingAccount');
     } 
     if(result.get('StallDetails')!=null)
     {
         newRecord.Stall_Details_Shipping_Address__c = (String) result.get('StallDetails');
     }   
     if(result.get('ExhibitionName')!=null)
     {
         newRecord.Exhibition_Name__c = (String) result.get('ExhibitionName');
     }   
     if(result.get('ExhibitionCode')!=null)
     {
         newRecord.Exhibition_Code__c = (String) result.get('ExhibitionCode');
     }   
     if(result.get('ProductDescription')!=null)
     {
         newRecord.Product_Description__c = (String) result.get('ProductDescription');
     }      
     if(result.get('Hub')!=null)
     {
         newRecord.Hub__c = (String) result.get('Hub');
     }
     System.debug('78 Vault :'+result.get('Vault'));
     if(result.get('Vault')!=null)
     {
         newRecord.Vault__c = (String) result.get('Vault');
     } 
     if(result.get('AuthorisedPersonIDDetails')!=null)
     {
         newRecord.Authorised_Person_ID_Details__c = (String) result.get('AuthorisedPersonIDDetails');
     }   
     
     if(result.get('AuthorisedPersonName')!=null)
     {
         newRecord.Authorised_Person_Name__c = (String) result.get('AuthorisedPersonName');
     }
     if(result.get('NetWeight')!=null && result.get('NetWeight')!='')
     {
         newRecord.Net_Weight_in_Kgs__c = Decimal.valueOf((String) result.get('NetWeight'));
     }
     if(result.get('GrossWeight')!=null && result.get('GrossWeight')!='')
     {
         newRecord.Gross_Weight_Kgs__c = Decimal.valueOf((String)result.get('GrossWeight')); 
     }
     if(result.get('ProductValue')!=null && result.get('ProductValue')!='')
     {
         newRecord.Product_Value__c = Decimal.valueOf((String)result.get('ProductValue'));
     }   
     if(result.get('NumberROfPackages')!=null && result.get('NumberROfPackages')!='')
     {
         newRecord.Number_of_Packages__c = Decimal.valueOf((String) result.get('NumberROfPackages'));
     } 
     if(result.get('PaymentType') != null && String.valueOf(result.get('PaymentType')).trim() != '') {
    newRecord.Payment_Type__c = String.valueOf(result.get('PaymentType'));
}

     
     if(result.get('isHub')!=null)
     {
         newRecord.Is_Hub__c = (boolean) result.get('isHub');
     }    
	try
    {
        insert newRecord;
        resultToReturn.put('success',newRecord.Id);
    }catch(Exception e)
    {
        resultToReturn.put('error',e.getMessage());
    }
     return resultToReturn;
 }    
}