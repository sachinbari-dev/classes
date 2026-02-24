global class DeleteTaskBatch implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext bc){
		String query = 'Select Id From Task Where CreatedDate <= 2023-05-31T00:00:00Z';
		return Database.getQueryLocator(query);        
    }
    
    global void execute(Database.BatchableContext bc, List<Task> taskList){
        if(taskList.size() > 0){
            delete taskList;
        }
    }
    
    global void finish(Database.BatchableContext bc){
        
    }

}