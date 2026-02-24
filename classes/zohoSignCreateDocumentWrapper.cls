public class zohoSignCreateDocumentWrapper {

    public class Pages {
		public String image_string;
		public Integer page;
		public Boolean is_thumbnail;
	}

	public class Document_fields {
		public String document_id;
		public List<Templates_used> fields;
	}

	public Integer code;
	public Requests requests;
	public String message;
	public String status;

	public class Document_ids {
		public String image_string;
		public String document_name;
		public List<Pages> pages;
		public Integer document_size;
		public String document_order;
		public Boolean is_nom151_present;
		public Boolean is_editable;
		public Integer total_pages;
		public String document_id;
	}

	public class Actions {
		public Boolean verify_recipient;
		public String recipient_countrycode_iso;
		public String action_type;
		public String private_notes;
		public String cloud_provider_name;
		public String recipient_email;
		public Boolean send_completed_document;
		public Boolean allow_signing;
		public String recipient_phonenumber;
		public Boolean is_bulk;
		public String action_id;
		public Integer cloud_provider_id;
		public Integer signing_order;
		public List<Templates_used> fields;
		public String recipient_name;
		public String delivery_mode;
		public String action_status;
		public String recipient_countrycode;
		public Boolean ishost;
		public String in_person_name;
		public String in_person_email;
	}

	public class Templates_used {
	}

	public class Requests {
		public String request_status;
		public String notes;
		public Integer reminder_period;
		public String owner_id;
		public String description;
		public String request_name;
		public Long modified_time;
		public Boolean is_deleted;
		public Integer expiration_days;
		public Boolean is_sequential;
		public List<Templates_used> templates_used;
		public String owner_first_name;
		public Integer sign_percentage;
		public String owner_email;
		public Long created_time;
		public Boolean email_reminders;
		public List<Document_ids> document_ids;
		public Boolean self_sign;
		public List<Document_fields> document_fields;
		public Boolean in_process;
		public Integer validity;
		public String request_type_name;
		public String request_id;
		public String request_type_id;
		public String owner_last_name;
		public List<Actions> actions;
	}

	
	public static zohoSignCreateDocumentWrapper parse(String json) {
		return (zohoSignCreateDocumentWrapper) System.JSON.deserialize(json, zohoSignCreateDocumentWrapper.class);
	}
}