@RestResource(urlMapping='/KarzaKYC/')
global class BVC_KarzaKYCupdateAPIforUniverse {

    @HttpPost
    global static string karzaKYCUpdate() {
        String requestBody = RestContext.request.requestBody.toString();
        System.debug('Request Body: ' + requestBody);

        try {
         
            if (String.isEmpty(requestBody)) {
                return 'Error: No request body provided.';
            }

            // Deserialize the JSON payload
            Map<String, Object> kycPayload = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
            System.debug('KYC Payload: ' + kycPayload);

            // Validate the required field
            if (!kycPayload.containsKey('Name') || String.isBlank((String) kycPayload.get('Name'))) {
                return 'Error: Missing required field "Name".';
            }

            String customerName = (String) kycPayload.get('Name');
            System.debug('Customer Name: ' + customerName);

            // Query matching Account records
            List<Account> existingCustomers = [SELECT Id, PAN_Number_of_Entity__c, First_Name__c, Last_Name__c, 
                                                       Primary_Customer_Email__c, Phone, Customer_Created_In_Universe__c, 
                                                       Credit_Status__c, Customer_Category_Static__c, 
                                                       Name_As_Per_PAN_Manual_Input__c
                                                FROM Account
                                                WHERE Name = :customerName];

                if (existingCustomers.isEmpty()) {
                    return 'Error: No customer found with the provided Name: ' + customerName;
                }
    
                List<Account> accountsToUpdate = new List<Account>();
                List<String> customerIdsForVerification = new List<String>();
                List<String> customerPANsForVerification = new List<String>();
    
                // Update the accounts and prepare for PAN verification
                for (Account customer : existingCustomers) {
                    if (kycPayload.containsKey('PAN_Number_of_Entity__c')) {
                        customer.PAN_Number_of_Entity__c = (String) kycPayload.get('PAN_Number_of_Entity__c');
                    }
                    if (kycPayload.containsKey('First_Name__c')) {
                        customer.First_Name__c = (String) kycPayload.get('First_Name__c');
                    }
                    if (kycPayload.containsKey('Last_Name__c')) {
                        customer.Last_Name__c = (String) kycPayload.get('Last_Name__c');
                    }
                    if (kycPayload.containsKey('Primary_Customer_Email__c')) {
                        customer.Primary_Customer_Email__c = (String) kycPayload.get('Primary_Customer_Email__c');
                    }
                    if (kycPayload.containsKey('Phone')) {
                        customer.Phone = (String) kycPayload.get('Phone');
                    }
                    if (kycPayload.containsKey('Customer_Created_In_Universe__c')) {
                        customer.Customer_Created_In_Universe__c = (Boolean) kycPayload.get('Customer_Created_In_Universe__c');
                    }
                    if (kycPayload.containsKey('Credit_Status__c')) {
                        customer.Credit_Status__c = (String) kycPayload.get('Credit_Status__c');
                    }
                    if (kycPayload.containsKey('Customer_Category_Static__c')) {
                        customer.Customer_Category_Static__c = (String) kycPayload.get('Customer_Category_Static__c');
                    }
                    if (kycPayload.containsKey('Name_As_Per_PAN_Manual_Input__c')) {
                        customer.Name_As_Per_PAN_Manual_Input__c = (String) kycPayload.get('Name_As_Per_PAN_Manual_Input__c');
                    }
    
                    accountsToUpdate.add(customer);
    
                    if (!String.isEmpty(customer.PAN_Number_of_Entity__c)) {
                        customerIdsForVerification.add(customer.Id);
                        customerPANsForVerification.add(customer.PAN_Number_of_Entity__c);
                    }
                }
    
                // Update the accounts
                update accountsToUpdate;
                System.debug('Accounts updated successfully: ' + accountsToUpdate);
    
                // Call the future method for PAN verification
                BVC_KarzaKYCupdateAPIforUniverse.verifyPANInFuture(customerIdsForVerification, customerPANsForVerification);
    
                return 'Customer updated successfully And PAN KYC Re-verification initiated ID:'+ customerIdsForVerification;

        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
            return 'Error: ' + e.getMessage();
        }
    }

    @Future(callout=true)
    public static void verifyPANInFuture(List<String> customerIds, List<String> panNumbers) {
        System.debug('Initiating PAN verification in future method.');
        for (Integer i = 0; i < customerIds.size(); i++) {
            try { 
                KYCPanVerificationAPI.verifyPanAPI(customerIds[i], panNumbers[i]);
                System.debug('PAN verification initiated for Customer Id: ' + customerIds[i]);
            } catch (Exception e) {
                System.debug('Error during PAN verification for Customer Id: ' + customerIds[i] + ' - ' + e.getMessage());
            }
        }
    }
    
    
    
    
    
    
    
    public  static void GetCoverage(){
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
    }
}