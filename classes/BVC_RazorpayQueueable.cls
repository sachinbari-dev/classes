public class BVC_RazorpayQueueable implements Queueable,Database.AllowsCallouts {

     List<Id> razorpayIds = new  List<Id>();
    public BVC_RazorpayQueueable (List<Id> invList )
    {
        razorpayIds.addall(invList );
        
    }
    public void execute(QueueableContext ctx){
       
    
        if(razorpayIds.size() >0){
            system.debug('invoiceids'+razorpayIds);
              BVC_CPQ_ConnectController.authurl(razorpayIds);
        }
      
    }
}