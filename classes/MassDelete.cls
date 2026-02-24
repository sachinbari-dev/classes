global class MassDelete implements Database.Batchable<sObject> {
    
    String objName;
    
    global MassDelete (String objectName){
        this.objName = objectName;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'Select Id From '+objName;
        return Database.getQueryLocator(query);
    }
	

    global void execute(Database.BatchableContext bc, List<sObject> recordsList) {
        delete recordsList;
    }

    global void finish(Database.BatchableContext bc) {
        
    }
    
}