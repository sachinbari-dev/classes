global class DeleteEmailMessageBatch implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'Select Id From EmailMessage Where CreatedDate <= 2023-05-31T00:00:00Z';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc,List<EmailMessage> emailMessageList){
        if(emailMessageList.size() > 0){
            delete emailMessageList;
        }
        
    }
    
    global void finish(Database.BatchableContext bc){
        
    }

}