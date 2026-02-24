public class BVC_IqlooLockAPIQueueable implements Queueable, Database.AllowsCallouts{

    private string deviceId;
    private id recordId ; 
    
      public BVC_IqlooLockAPIQueueable( string deviceIds, id recId) {
        this.deviceId = deviceIds;
          this.recordId= recId;
    }
      public void execute(QueueableContext context) {
          if(!Test.isRunningTest()){
              BVC_IqlooLockAPIHelper.getIqlooSinglePin(deviceId,recordId);
          }

    }

}