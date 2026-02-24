public class BVCFetchPaymentsWrapper 
{
    public String id{get;set;}
    public Integer first_min_partial_amount{get;set;}
    public Integer expired_at{get;set;}
    public Integer expire_by{get;set;}
    public String description{get;set;}
    public String order_id{get;set;}
    public Boolean reminder_enable{get;set;}
    public String reference_id{get;set;}
    public String short_url{get;set;}
    public Integer created_at{get;set;}
    public String status{get;set;}
    public Integer cancelled_at{get;set;}
    public Integer updated_at{get;set;}
    public Integer amount_paid{get;set;}
    public Boolean upi_link{get;set;}
    public Integer amount{get;set;}
    public String user_id{get;set;}
    public Boolean accept_partial{get;set;}   
    public list<payments> payments{get;set;}
    
    public class payments{
        public String method{get;set;}
        public String payment_id{get;set;}
        public Integer created_at{get;set;}
        public String status{get;set;}
        public Integer amount{get;set;}
    }
}