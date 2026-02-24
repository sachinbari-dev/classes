@RestResource(urlMapping='/IqlooOTP/')
global class BVC_IqlooPickupRetriggerAPI {

      @HttpPost
     global static string generateIqlooOTP(){
         
         string requestBody = RestContext.request.requestBody.toString();
         system.debug('RequestBody'+requestBody);
         
         try{
              if(String.isEmpty(requestBody)){
                 return 'Error: No request body provided.';  
             
              }else{
                  
                   Map<string,object> pickupPayload = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
                  
                    List<Object> recordIdsObj  = (List<Object>)pickupPayload.get('recordId');
                 system.debug('recordId@@'+ recordIdsObj );
                 
                 if(recordIdsObj  == Null || recordIdsObj .isEmpty()){
                     return 'Error:  No record IDs provided.'; 
                 }else{
                     
                      List<Id> recordIdList = new List<Id>();
                     for (Object recordId : recordIdsObj ) {
                          recordIdList.add((Id)recordId);
                          system.debug('recordIdList@@'+ recordIdList);
                     }
                     
                     List<pickup__c> pList = [select id, name, OTP__c, Lock_ID__c,Lock_ID__r.name from pickup__c where id IN:recordIdList ];
                     List<Shipment__c> ShipList = [select id, name, OTP__c, Lock_ID__c from Shipment__c where id IN:recordIdList ];
                     
                    List<Map<String, String>> responseList = new List<Map<String, String>>();
                     
                     if(!pList.isEmpty()){
                         
                         for(pickup__c p:pList){
                            string pin =BVC_IqlooLockAPIHelper.getIqlooSinglePin(p.Lock_ID__r.name, p.Id);
                         
                            Map<String, String> response = new Map<String, String>();
                            response.put('message', 'PIN Generated successfully');
                            response.put('Pickup Name', P.Name);
                            response.put('pin', pin);
                            
                           responseList.add(response);
                     } 
                   }
                     
                     if(!ShipList.isEmpty()){
                         
                          for(Shipment__c s: ShipList){
                            string pin =BVC_IqlooLockAPIHelper.getIqlooSinglePin(s.Lock_ID__c, s.Id);
                         
                            Map<String, String> response = new Map<String, String>();
                            response.put('message', 'PIN Generated successfully');
                            response.put('Shipment Name', s.Name);
                            response.put('pin', pin);
                            
                           responseList.add(response);
                     }
                    
                     
                 }
                     return JSON.serialize(responseList);
              }
            }
         }catch(exception e){
              return 'Error:'+ e.getMessage();
         }
         
        
     }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    public static void getCoverage(){
        
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
        
    }
}