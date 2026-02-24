@RestResource(urlMapping='/ImageAPI/')
global class cubizonFalconImageAPI {

    @HttpPost
    global static String updateImagePathOnSecureBag() {
        
            try{

                String requestBody = RestContext.request.requestBody.toString();
                System.debug('requestBody@@@' + requestBody);
                
                 if (String.isEmpty(requestBody)) {
                    return JSON.serialize(new Map<String, Object>{'success' => false,'status_code' => 400,'message' => 'Bad Request: Request body is empty.'});
                }
    
                      List<Map<String, Object>> requestList = new List<Map<String, Object>>();
    
             
                    Object deserializedBody = JSON.deserializeUntyped(requestBody);
                    if (deserializedBody instanceof Map<String, Object>) {
                        
                        requestList.add((Map<String, Object>) deserializedBody);
                    } else if (deserializedBody instanceof List<Object>) {
                        
                        requestList = (List<Map<String, Object>>) deserializedBody;
                    } else {
                        return JSON.serialize(new Map<String, Object>{'success' => false, 'status_code' => 400, 'message' => 'Bad Request: Invalid JSON format.'});
                    }
        
                    if (requestList.isEmpty()) {
                        return JSON.serialize(new Map<String, Object>{'success' => false,'status_code' => 400, 'message' => 'Bad Request: No records provided.'});
                    }
                
                 Set<String> awbNumbers = new Set<String>();
                
                 for (Map<String, Object> record : requestList) {
                    if (record.containsKey('awb')) {
                        awbNumbers.add((String) record.get('awb'));
                    }
                 }
                
                Map<String, Secure_Bag__c> existingRecordsMap = new Map<String, Secure_Bag__c>([SELECT Id, Secure_Packaging_Identifier__c FROM Secure_Bag__c WHERE Secure_Packaging_Identifier__c IN :awbNumbers]);
    
                if (existingRecordsMap.isEmpty()) {
                    return JSON.serialize(new Map<String, Object>{'success' => false,'status_code' => 400, 'message' => 'Bad Request: No matching records found for the provided AWB numbers.' });
                }
                
                   List<Secure_Bag__c> recordsToUpdate = new List<Secure_Bag__c>();
                   string awbNum = '';
                
                   for (Map<String, Object> record : requestList) {
                         String awb = (String) record.get('awb');
                         awbNum = awb;
                          
                          for(secure_bag__c secureBagRecord: [SELECT Id, Secure_Packaging_Identifier__c FROM Secure_Bag__c WHERE Secure_Packaging_Identifier__c =:awb]){
                              if (secureBagRecord != null) {
                                   
                                  secureBagRecord.ImagePath__c = (String) record.get('image_path');
                                  
                                   recordsToUpdate.add(secureBagRecord);
                              }
                          }
                       }
                    
                       if (!recordsToUpdate.isEmpty()) {
                           update recordsToUpdate;
                       }
                
                 return JSON.serialize(new Map<String, Object>{'success' => true, 'status_code' => 200,'message' => 'Data Inserted Successfully.' });
            }catch(exception e){
                 return JSON.serialize(new Map<String, Object>{'success' => false,'status_code' => 500, 'message' => 'Internal Server Error: ' + e.getMessage() });
            }
           
    }
}