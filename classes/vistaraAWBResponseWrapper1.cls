public class vistaraAWBResponseWrapper1 {
 
    public List<Table6> Table6;

	public class Table6 {
		public Integer ErrorCode;
		public String ErrorDesc;
		public String AWBNumber;
		public String DepartureTimeMsg;
		public String CurrentDate;
		public String CommodityName;
		public String DeptTime;
        public String FlightRoute;
	}

	
	public static vistaraAWBResponseWrapper1 parse(String json) {
		return (vistaraAWBResponseWrapper1) System.JSON.deserialize(json, vistaraAWBResponseWrapper1.class);
	}
}