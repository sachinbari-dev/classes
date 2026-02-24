@RestResource(urlMapping='/SecureBagWeighing/')
global class cubizonFalconAPI {
    @HttpPost
    global static String updateSecureBagDetails() {
        try {
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
            List<ContentVersion> contentVersionList = new List<ContentVersion>();
            string awbNum = '';
           
           
            
            for (Map<String, Object> record : requestList) {
                String awb = (String) record.get('awb');
                  awbNum = awb;
                  
             for(secure_bag__c secureBagRecord: [SELECT Id,Name,shipment__c,shipment__r.weight__c,Is_Scanned_by_Weight__c, Secure_Packaging_Identifier__c FROM Secure_Bag__c WHERE Secure_Packaging_Identifier__c =:awb]){
         
                 
                if (secureBagRecord != null) {
                    if(secureBagRecord.Is_Scanned_by_Weight__c != true){
                        
                    
                  //  Secure_Bag__c secureBagRecord = existingRecordsMap.get(awb);
                 //   Secure_Bag__c secureBagRecord = [SELECT Id, Secure_Packaging_Identifier__c FROM Secure_Bag__c WHERE Secure_Packaging_Identifier__c =:awb];
                    
                    boolean checkshipment = false;
                    
                    secureBagRecord.Device_Id__c = (String) record.get('deviceid');
                    secureBagRecord.Additional_AWB__c = (String) record.get('additional_awb');
                    secureBagRecord.M_Length__c = record.containsKey('length') ? Decimal.valueOf((String) record.get('length')) : null;
                    secureBagRecord.M_Breadth__c = record.containsKey('breadth') ? Decimal.valueOf((String) record.get('breadth')) : null;
                    secureBagRecord.M_Height__c = record.containsKey('height') ? Decimal.valueOf((String) record.get('height')) : null;
                    secureBagRecord.M_Weight__c = record.containsKey('weight') ? Decimal.valueOf((String) record.get('weight')) : null;
                    secureBagRecord.M_Volumetric_Weight__c = record.containsKey('Vol. Weight') ? Decimal.valueOf((String) record.get('Vol. Weight')) : null;
                    secureBagRecord.Scanned_Date__c = record.containsKey('scanned_date') ? Date.valueOf((String) record.get('scanned_date')) : null;
                    secureBagRecord.scannedTime__c = (String) record.get('scanned_time');
                 //   secureBagRecord.Scanned_Time__c = record.containsKey('scanned_time') ? Time.valueOf((String) record.get('scanned_time')) : null;
                    secureBagRecord.Weight_unit__c = (String) record.get('Weight unit');
                    secureBagRecord.Dim_Unit__c = (String) record.get('Dim. Unit');
                    secureBagRecord.Is_Bag_Scanned_By_Falcon__c = true;
                     

                    recordsToUpdate.add(secureBagRecord);
                    
                    
                    if (record.containsKey('images') && String.isNotBlank((String) record.get('images'))) {
                        String base64Image = (String) record.get('images');
                        ContentVersion cv = new ContentVersion();
                        cv.Title = 'Secure Bag Image - ' + awb;
                        cv.PathOnClient = 'SecureBagImage_' + awb + '.jpg'; 
                        cv.VersionData = EncodingUtil.base64Decode(base64Image);
                       
                        cv.IsMajorVersion = true;
                        
                        contentVersionList.add(cv);
                        system.debug('calling weight method');
                         system.debug('secure bag Name'+awbnum);
                       
                       if(secureBagRecord.Shipment__r.weight__c != Null){
                            weight__c wtList = [select id, name ,shipment__c,shipment__r.id from weight__c where shipment__c=:secureBagRecord.shipment__c];
                               system.debug('wtList'+wtList);
                            TMS_WeightForSecureBagController.createUpdateRecord( base64Image, awbnum, secureBagRecord.M_Length__c, secureBagRecord.M_Breadth__c, secureBagRecord.M_Height__c, secureBagRecord.M_Volumetric_Weight__c, checkShipment, wtList.id, secureBagRecord.M_Weight__c);

                       }else{
                                
                            string weightid = null ; 
                            TMS_WeightForSecureBagController.createUpdateRecord( base64Image, awbnum, secureBagRecord.M_Length__c, secureBagRecord.M_Breadth__c, secureBagRecord.M_Height__c, secureBagRecord.M_Volumetric_Weight__c, checkShipment, weightid, secureBagRecord.M_Weight__c);

                       }
                                          
                    }
                    }else{
                       return 'This bag is already scanned by secure bag weighing';
                    }
             }
                }
          
            }

            
            if (!recordsToUpdate.isEmpty()) {
                update recordsToUpdate;
            }
            
            if (!contentVersionList.isEmpty()) {
                insert contentVersionList;

                Secure_Bag__c sb = [SELECT Id, Secure_Packaging_Identifier__c FROM Secure_Bag__c WHERE Secure_Packaging_Identifier__c =:awbNum];
                string docId = '';
                List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
                for (ContentVersion cv : [SELECT Id, ContentDocumentId, Title FROM ContentVersion WHERE Id IN :contentVersionList]) {
                    String awb = cv.Title.split('- ')[1].trim();
                    Secure_Bag__c relatedBag = existingRecordsMap.get(awbNum);
                    system.debug('awbNum@@'+awbNum);
                     system.debug('relatedBag@@'+relatedBag);
                    if (sb != null) {
                        docId = cv.ContentDocumentId;
                        ContentDocumentLink cdl = new ContentDocumentLink();
                        cdl.ContentDocumentId = cv.ContentDocumentId;
                        cdl.LinkedEntityId = sb.Id;
                        cdl.ShareType = 'V'; 
                        contentDocumentLinks.add(cdl);
                    }
                }
                insert contentDocumentLinks;
                
          
                
            }
          
            return JSON.serialize(new Map<String, Object>{'success' => true, 'status_code' => 200,'message' => 'Records and images updated successfully.' });
        } catch (Exception e) {
          
            return JSON.serialize(new Map<String, Object>{'success' => false,'status_code' => 500, 'message' => 'Internal Server Error: ' + e.getMessage() });
        }
    }
}