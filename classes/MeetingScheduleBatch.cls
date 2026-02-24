public class MeetingScheduleBatch implements Database.Batchable<sObject> 
{
   public String query;

   public Database.QueryLocator start(Database.BatchableContext bc)
   {
       
       DateTime endDate = DateTime.now();     
       System.debug('DateTime.now():'+DateTime.now());
       String currentMonthName = Datetime.now().format('MMMM');
       Integer currentMonthNumber = endDate.month();
       Integer daysInPresentMonth = Date.daysInMonth(2000, currentMonthNumber);
       System.debug('daysInPresentMonth :'+daysInPresentMonth);       
       Integer finalDays = daysInPresentMonth==30?31:30;
       DateTime startDate = enddate - finalDays;
       System.debug('startDate :'+startDate);  
       System.debug('endDate :'+endDate);  
       query = 'select Id,Customer__c,Customer__r.Name from Meeting_Schedule__c WHERE CreatedDate >= :startDate AND CreatedDate <= : endDate';
       System.debug('query :'+query);
       return Database.getQueryLocator(query);
   }

   public void execute(Database.BatchableContext bc, List<Meeting_Schedule__c> scope)
   {
		System.debug('scope Size :'+scope.size());
       Set<String> customerIdList = new Set<String>();
       Set<String> MS_List = new Set<String>();
       for(Meeting_Schedule__c ms : scope)
       {
           System.debug('Id :'+ms.Id); 
           System.debug('CustomerId :'+ms.Customer__c);
           System.debug('Customer Name :'+ms.Customer__r.Name); 
           MS_List.add(ms.Id);
           customerIdList.add(ms.Customer__c);
       }
        System.debug('customerIdList :'+customerIdList); 
       List<Account> acList = [select Id,Name,Completed_visit_for_CBO__c,Completed_visit_for_CEO__c,
                               Completed_visit_for_Primary_AccountOwner__c,Completed_visit_for_Secondary_Ow__c
                               from Account where Id IN :customerIdList and RecordType.Name='Billing'];
       List<Monthly_meeting_Updates__c> mmuList = new List<Monthly_meeting_Updates__c>();
       if(acList.size()>0)
       {
           for(Account a:acList)
           {
               Monthly_meeting_Updates__c  singleRecord = new Monthly_meeting_Updates__c();
               singleRecord.Customer__c=a.Id;
               singleRecord.Primary_SOVisits__c=a.Completed_visit_for_Primary_AccountOwner__c;
               singleRecord.Secondary_SOVisits__c=a.Completed_visit_for_Secondary_Ow__c;
               singleRecord.CBO_Visits__c=a.Completed_visit_for_CBO__c;
               singleRecord.CEO_Visits__c=a.Completed_visit_for_CEO__c;
               singleRecord.Month__c=System.today();
               mmuList.add(singleRecord);
               System.debug('Name :'+a.Name);
           }
			if(mmuList.size()>0)
            {
                Database.Insert(mmuList,false);
                List<Account> acListtoUpdate = new List<Account>();
                for(Account a:acList)
                {
                    a.Completed_visit_for_Primary_AccountOwner__c=0;
                    a.Completed_visit_for_Secondary_Ow__c=0;
                    a.Completed_visit_for_CBO__c=0;
                    a.Completed_visit_for_CEO__c=0;
                    acListtoUpdate.add(a);
                }
                Database.update(acListtoUpdate,false);
            }
       }
   }

   public void finish(Database.BatchableContext bc)
   {
   }
}