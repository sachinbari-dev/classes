@RestResource(urlMapping='/SecurePackagingUpdate/')

 global class SecurePackagingBulkUpdateAPI {

     @HttpPost
     global static string updateSecurePackagingById(){
         
          String requestBody = RestContext.request.requestBody.toString();
              system.debug('requestbody1@@@' + requestBody);
         
         try{
             
             if(String.isEmpty(requestBody)){
                 return 'Error: No request body provided.';   
                 
             }else{    
                 
                 Map<string,object> securePackPayload = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
                 
                 system.debug('securepackpayload@@'+ securePackPayload);   
                 
                 List<Object> recordIdsObj  = (List<Object>)securePackPayload.get('recordIds');
                 system.debug('recordIds@@'+ recordIdsObj );
                 
                 if(recordIdsObj  == Null || recordIdsObj .isEmpty()){
                     return 'Error:  No record IDs provided.';  
                     
                 }else{
                     
                     List<Id> recordIdList = new List<Id>();
                     for (Object recordId : recordIdsObj ) {
                          recordIdList.add((Id)recordId);
                          system.debug('recordIdList@@'+ recordIdList);
                     }
                     
                     SecurePackagingBulkBatchUpdate batch = new SecurePackagingBulkBatchUpdate(recordIdList);
                      id JobId =  Database.executeBatch(batch, 2000);
                      system.debug('JobID@@@' + JobId);
                  
                      return 'Batch process initiated successfully' +'-' + 'JobID:' + JobId ;
                 }
             }
             }catch(Exception e){
                 return 'Error:'+ e.getMessage();
             }
         
         }
     }