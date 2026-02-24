public class VistaraCreateAWBRequest {

    public String loginName;	//BVCCOKDOM
	public String sessionId;	//03ee9988-7a69-4c39-8d83-40990c13174a
	public String awbPrefix;	//228
	public String origin;	//BOM
	public String destination;	//DEL
	public String shippingAgentCode;	//BVCCOKDOM
	public String commodityCode;	//2298
	public String productType;	//GENERAL
	public String commodityDesc;	//BREAK BULK GENERAL CARGO
	public String pcs;	//10
	public String grossWt;	//100.00
	public String chargeableWt;	//100.00
	public String fltDate;	//10/04/2023
	public String fltNumber;	//UK960
	public String UOM;	//K
	public String Dimensions;	//10.0,10.0,10.0,10,100.0,0/
	public String ShprAccountCode;	//BVCCOKDOM
	public String ShprCity;	//MUMBAI
	public String ShprState;	//MAHARASHTRA
	public String ShprName;	//AMX LOGISTICS
	public String ShprAdd;	//G-303 GOKUL GALAXY THAKUR COMPLEX KANDIVLI EAST CITY”, CITY
	public String ShprPincode;	//400001
	public String ShprCountryCode;	//IN
	public String ShprContactNo;	//7892234577
	public String ConsAccountCode;	//AMBOMDOM
	public String ConsCity;	//BENGALURU
	public String ConsState;	//KARNATAKA
	public String ConsName;	//AMX LOGISTICS
	public String ConsAdd;	//G-303 GOKUL GALAXY THAKUR COMPLEX KANDIVLI EAST CITY
	public String ConsPincode;	//560078
	public String ConsCountryCode;	//IN
	public String ConsContactNo;	//7892239788
	public String ScheduleID;	//
	public String ShprLat;	//
	public String ShprLong;	//
	public String ConsLat;	//
	public String ConsLong;	//
	public String ShprEmailID;	//
	public String ConsEmailID;	//
	public String Unit;	//Cms
	public String awbNumber;	//10564632
	public String slac;	//
	public String dvCustom;	//0
	public String declaredValue;	//0.0
	public String payMode;	//
	public String packagingInfo;	//
	public String TokenNumber;	//EB5F43ED-EED8-45C7-B045-D6839CAFD2B2
	public String volume;	//0.01
	public String shcCode;	//BBG
	public String multilegRoutes;	
    
    public static VistaraCreateAWBRequest parse(String json) {
		return (VistaraCreateAWBRequest) System.JSON.deserialize(json, VistaraCreateAWBRequest.class);
	}
}