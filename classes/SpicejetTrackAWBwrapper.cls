public class SpicejetTrackAWBwrapper {
 // This is wrapper class and is also used to deserialize response adn used in Track_AWB_SpiceJetHelper apex class.
	public String status;
	public Integer code;
	public String message;
	public Result result;
/*
	public class Task_tracker {
		public Integer status_id;
		public String status_detail;
		public String airport_code;
		public String flight_details;
		public String event_date_time;
		public String weight;
		public List<String> bag_list;
	}   */
// this method is used to create linehaul tracking record in Track_AWB_SpiceJetHelper  apex class
	public class Result {
		public List<cls_task_tracker> Task_tracker;
	}
    public String client_status;	//ORDER_INITIATED
	public Integer client_status_id;	//1
	public Integer current_status;	//1
	public String task_ref_id;	//T1633-20210531163928
	public String awb_number;	//775-83991250
	public Integer id;	//152448
	public cls_pod pod;
	public String estimated_delivery_time;	//
	public cls_delivery_associate_user_id delivery_associate_user_id;
	public String booking_type;	//D2D
	public String booking_date;	//2022-05-04 15:51:50
	public cls_task_tracker[] task_tracker;
	public String delivery_boy;	//Balaji Reddy
	public Integer total_weight;	//0
	public Integer total_pieces;	//0
	public boolean is_cold_chain;
	public boolean chart_exist;
	public String full_pod_url;	//https://spicetag-pdf-dev.s3-ap-south-1.amazonaws.com/151136/do/1-pod_report.pdf
	public String master_airway_bill;	//https://spicetag-pdf-dev.s3-ap-south-1.amazonaws.com/master_airway_bill_pdf?task_id=151451
	public cls_axb_detail axb_detail;
	class cls_pod {
	}
	class cls_delivery_associate_user_id {
	}
	public class cls_task_tracker {
		public Integer task_id;	//152448
		public String status;	//Request Initiated
		public Integer status_details_id;	//1
		public String flight_code;	//
		public String city;	//Mahipalpur
		public String updated_at;	//2022-05-04 15:51:50
	}
	public class cls_axb_detail {
		public Integer task_id;	//152448
		public String consignee_name;	//648-B, HALPATI COLONY, BOOK N FLY, RING ROAD, OPP KINNARY CINEMA,80 FE
		public String consignee_city;	//648-B, HALPATI COLONY, BOOK N FLY, RING ROAD, OPP KINNARY CINEMA,80 FE
		public String commodity_code;	//GEN
		public String consignee_address;	//648-B, HALPATI COLONY, BOOK N FLY, RING ROAD, OPP KINNARY CINEMA,80 FE
		public String consignee_postal_code;	//110037
		public String shipper_name;	//Book N Fly
		public String shipper_city;	//Mahipalpur
		public String charged_weight;	//100
		public String collected_date;	//2021-05-31 16:42:26
		public String delivered_date;	//2021-05-31 19:04:35
		public cls_e_way_bill e_way_bill;
		public String gross_weight;	//100.00
		public String origin;	//DL1
		public String destination;	//BL1
	}
	class cls_e_way_bill {
	}
	

// deserialization method

	public static SpicejetTrackAWBwrapper parse(String json) {
        
		return (SpicejetTrackAWBwrapper) System.JSON.deserialize(json, SpicejetTrackAWBwrapper.class);
	   
	}  
}