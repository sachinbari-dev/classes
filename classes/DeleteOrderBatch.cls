global class DeleteOrderBatch implements Database.Batchable <sObject> {
    
    global Database.QueryLocator start (Database.BatchableContext bc) {
        String query = 'Select Id From Order';
        return Database.getQueryLocator(query);
        
    }
    
    global void execute(Database.BatchableContext bc,List<Order> orderList) {
        if(orderList.size() > 0) {
            delete orderList;
        }
        
    }
    
    global void finish(Database.BatchableContext bc) {
        
    }

}