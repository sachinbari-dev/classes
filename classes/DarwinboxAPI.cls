@RestResource(urlMapping='/darwinbox')
global with sharing class DarwinboxAPI {

    @HttpPost
    global static String createRecord(String first_name, String last_name, String employee_id, String personal_email_id, String company_email_id, String sub_department, String designation, String direct_manager, String direct_manager_email, String l2_manager, String l2_manager_email, String designation_name) {
        try {
           
            List<FleetX_People__c> existingRecords = [SELECT Id FROM FleetX_People__c WHERE Employee_Code__c = :employee_id LIMIT 1];

            if (existingRecords.size() == 0) {
              
                FleetX_People__c newFleetXPerson = new FleetX_People__c(
                    Name = first_name,
                    People_lastName__c = last_name,
                    Employee_Code__c = employee_id,
                    People_email__c = personal_email_id,
                    People_userType__c = designation
                   
                );

                insert newFleetXPerson;

                return 'Record created successfully';
            } else {
                return 'Record with the same Employee_Code__c already exists';
            }
        } catch (Exception e) {
            return 'Error: ' + e.getMessage();
        }
    }
}