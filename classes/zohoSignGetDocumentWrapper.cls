public class zohoSignGetDocumentWrapper {

    public class Pages {
        public String image_string;
        public Integer page;
        public Boolean is_thumbnail;
    }

    public class Document_fields {
        public String document_id;
        public List<Attachments> fields;
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
        public List<Fields> fields;
        public String recipient_name;
        public String delivery_mode;
        public String action_status;
        public String recipient_countrycode;
        public Boolean ishost;
        public String in_person_name;
        public String in_person_email;
    }

    public class Attachments {
    }

    public class Fields {
        public String field_id;
        public Integer x_coord;
        public String field_type_id;
        public Integer abs_height;
        public String field_category;
        public String field_label;
        public Boolean is_mandatory;
        public Integer page_no;
        public String document_id;
        public Boolean is_draggable;
        public String field_name;
        public Double y_value;
        public Integer abs_width;
        public String action_id;
        public Double width;
        public Integer y_coord;
        public String field_type_name;
        public String description_tooltip;
        public Double x_value;
        public Boolean is_resizable;
        public Double height;
    }

    public class Visible_sign_settings {
        public Boolean allow_custom_signer_reason_visible_sign;
        public Boolean allow_predefined_reason_visible_sign;
        public Boolean visible_sign;
        public List<String> predefined_reasons_visible_sign;
        public Boolean allow_reason_visible_sign;
    }

    public class Requests {
        public String request_status;
        public String notes;
        public List<Attachments> attachments;
        public Integer reminder_period;
        public String owner_id;
        public String description;
        public String request_name;
        public Long modified_time;
        public Boolean is_deleted;
        public Integer expiration_days;
        public Boolean is_sequential;
        public List<String> templates_used;
        public String owner_first_name;
        public double sign_percentage;
        public String owner_email;
        public Long created_time;
        public Boolean email_reminders;
        public List<Document_ids> document_ids;
        public Boolean self_sign;
        public List<Document_fields> document_fields;
        public Boolean in_process;
        public Integer validity;
        public String request_type_name;
        public Visible_sign_settings visible_sign_settings;
        public String request_id;
        public String request_type_id;
        public String owner_last_name;
        public List<Actions> actions;
        public Integer attachment_size;
    }

    public static zohoSignGetDocumentWrapper parse(String json) {
        return (zohoSignGetDocumentWrapper) System.JSON.deserialize(json, zohoSignGetDocumentWrapper.class);
    }
}