public class ES_SecurePackagingHandler {

     public static void createShippingLabel(integer availableCountThreshold,String lastRecordName){
                
         Integer securePackagingCount = [select count() from Secure_packaging__c where name like 'ES%' AND status__c ='Available' AND RecordTypeID='0125g0000003dGBAAY' ];
         
         system.debug('securePackagingCount@@@'+securePackagingCount);
        
        if(securePackagingCount <= availableCountThreshold){
            SendEmail();
            
            List<secure_packaging__c> secureLabelList =  new List<secure_packaging__c>();
            Set<String> generatedNames = new Set<String>();            
            
            
               for(integer i = 0 ; i < 10000; i++){
               
               String nextName = genNextNameRecord(lastRecordName,i);
               System.debug('Iteration: ' + i + ', Next Name: ' + nextName);
                
                if(!generatedNames.Contains(nextName)){
                    secure_packaging__c spRec= new secure_packaging__c();
                    spRec.Name = nextName;
                    spRec.Status__c = 'Available';
                    spRec.RecordTypeId =  Schema.SObjectType.secure_packaging__c.getRecordTypeInfosByName().get('Shipping Label').getRecordTypeId();
                    spRec.Digital__c = true;
                    spRec.Type_of_Packaging__c = 'Shipping Label';
                    secureLabelList.add(spRec);
                    
                    generatedNames.add(nextName);
                }
                 
            }  
              insert secureLabelList ;
           system.debug('secureLabelList@@@@'+ secureLabelList);
  
        }
        
    }
    
    public static void SendEmail(){
        
        string[] toEmails = new string[]{'arun.kudwalli@bvclogistics.com','vivek.gowda@bvclogistics.com','chaitannya.inamdar@bvclogistics.com','deepthi.kedilaya@bvclogistics.com'};
            
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(toEmails);
        email.setSubject ('TMS Pilot has Uploaded the ES Inventory');
        string body = 'Dear Team,'+'<br/><br/>';
               body = body + 'TMS pilot is sleepless & has uploaded the next 30k ES Shipping note inventory. Please verify once.' + '<br/><br/>';
               body = body + 'Thanks & Regards.'+'<br/>';
               body = body + 'Your TMS Pilot';
        email.setHtmlBody(body); 
        
         Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        
    }
    public static String genNextNameRecord(String lastRecordName,Integer iterationIndex){
        
        // Increment the last series name
        Integer lastNumber = Integer.valueOf(lastRecordName.substring(2));
        system.debug('lastNumber@@'+ lastNumber);
        
        String nextSeriesName = 'ES' + (lastNumber + iterationIndex + 1);
        system.debug('next series name@@'+ nextSeriesName);
        
        return nextSeriesName;
    }
}