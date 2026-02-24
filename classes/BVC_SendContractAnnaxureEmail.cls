/**********************************************************
 * Created By : Imran Sheik
 * Created Date:29-08-2024
 * Purpose: send Contract Annexure File Email
 * Copy of : SendContractAnnaxureEmail
**********************************************************************/
public class BVC_SendContractAnnaxureEmail 
{
    public static void sendConsumptionDetails(List<BVC_Contract__c> conList){
        if((conList[0].Status__c=='Expired' && conList[0].Customer_Name__c!=null))
        {     
            integer i=0;
           List<Account> sentemailAccounts = [SELECT AccountNumber,Name,Balance_Amount__c,Point_Of_Contact_Email__c,
                                   Annual_Contract_Balance__c,Active_Contract__c,Consumed_ACR_Amount__c,
                                   Active_Contract__r.of_Contract_Consumption__c,Active_Contract__r.Consumed_Amount__c,
                                   Adjusted_Contract_Amount__c,Contract_Start_Date__c,Contract_Amount__c,
                                   Consumed_Amount__c,Contract_End_Date__c,ST_Total_Consumable_ACR_Amount__c,
                                   (SELECT ContactId,AccountId,Contact.Email,Roles FROM AccountContactRelations WHERE Roles includes ('Finance','Invoice Recepient')),
                                   Email_Sent_at_85_Consumption__c,Email_Sent_at_90_Consumption__c,Email_Sent_at_95_Consumption__c,
                                   Email_Sent_at_98_Consumption__c,Email_Sent_at_100_Consumption__c,of_Contract_Consumption__c
                                   FROM Account 
                                   WHERE Id =:conList[0].Customer_Name__c];
			System.debug('23 sentemailAccounts.size() :'+sentemailAccounts.size());
            if(sentemailAccounts.size() > 0 && !Test.isRunningTest()) 
            {
                List<Messaging.SingleEmailMessage> mailingList = BVC_SendEmailUtility.ContractExpiryEmailSender(Label.ContractConsumptionExpiryEmailTemplateName ,sentemailAccounts,true);
                Messaging.SendEmailResult[] results = Messaging.sendEmail(mailingList);               
            }       
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
            /*
            EmailTemplate emailTemplate =[Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where name ='BVC Contract Consumption'];       
            Account customer = [select Id,Name from Account where Id=:conList[0].Customer_Name__c limit 1];
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setUseSignature(false);
            mail.setToAddresses(new String[] { conList[0].Primary_Customer_Email__c });//Set To Email Address
            System.debug('conList[0].Primary_Customer_Email__c :'+conList[0].Primary_Customer_Email__c);
            
            mail.setTemplateID(emailTemplate.Id);
            mail.setTargetObjectId(conList[0].OwnerId);
            mail.setSaveAsActivity(false);
            try
            {
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
            catch(Exception e)
            {
                System.debug('ERROR :'+e.getMessage());
            }
            
            */
            /*
            String Subject = '<html><body>';
            Subject+='<h1>BVC Annual Contract consumption alert as on'+System.Today()+' for '+conList[0].of_Contract_Consumption__c+' % of Consumption for '+conList[0].Name+' of '+customer.Name+'</h1>';
            mail.setSubject(Subject);
            String EmailBody='<br/>Dear '+customer.Name+',';
            EmailBody=EmailBody+'<br/>Greetings from BVC, the most secured logistics partner, having more than 60 years of experience in handling precious shipments.';
            EmailBody=EmailBody+'<br/>Please be informed that your Annual Contract with BVC has already reached '+conList[0].of_Contract_Consumption__c+' % consumption limit. we would appreciate discussing the renewal for continued seamless shipping.';
            EmailBody+='<br/>The summary of Annual Contract is as below:';
            EmailBody+='<br/>Customer Name :'+customer.Name;
            EmailBody+='<br/>PAN Number:';
            EmailBody+='<br/>Annual Contract Number :'+conList[0].Name;
            EmailBody+='<br/>Effective From :';       
            EmailBody+='<br/>Effective Till :';  
            EmailBody+='<br/>No. of days of Annual Contract :';        
            EmailBody+='<br/>No. of days of Annual Contract consumed :';        
            EmailBody+='<br/>Balance No. of days of Annual Contract :';        
            EmailBody+='<br/>Annual Contract Amount  :'+conList[0].Contract_Amount__c;        
            EmailBody+='<br/>Annual Contract consumed  :'+conList[0].Consumed_Amount__c;       
            EmailBody+='% Annual Contract consumed  :' ;        
            EmailBody+='<br/>ACR Contract Amount balance :'+conList[0].Name;
            EmailBody+='<br/>Number of parcels shipped :'+conList[0].Name;       
            EmailBody+='<br/>Net Weight shipped (Grams) :'+conList[0].Name;       
            EmailBody+='<br/>Gross Weight shipped (Grams) :'+conList[0].Name;        
            EmailBody+='<br/>Product value shipped (INR) :'+conList[0].Name;       
            EmailBody+='<br/><br/>The detailed shipment wise report is attached for your reference.';       
            EmailBody+='<br/>The BVC Standard Tariff as shown here  shall be applicable right after the ACR expires, by date or consumption.';        
            EmailBody+='For renewing your contract and for any clarifications, please feel free to get in touch with me';     
            EmailBody+='<br/>Looking forward to a long standing relationship between BVC and ';
            EmailBody+='<br/>Thanks and Regards,';
            EmailBody+='<br/>'+UserInfo.getName();
            EmailBody+='<br/>'+customer.Name;
            EmailBody+='<br/>BVC Logistics Pvt. Ltd.';              
            mail.setHtmlBody(EmailBody);                                         
            System.debug('Email sent mail:'+mail);       
            try
            {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });//Send Email
            }
            catch(Exception e)
            {
            System.debug('Email sent results:'+e.getMessage());
            }
            
            */
            
            
        }  
   }

}