public class vistaraGetFlightListWrapper1 {

    public class Table {
		public String ScheduleID;
		public String FltNumber;
		public String FltOrigin;
		public String FltDestination;
		public String FltDate;
		public Time ArrTime; 
		public Time DeptTime;
		public String LegSequence;
		public DateTime DepDateTime;
		public DateTime ArrDateTime;
		public String STATUS;
	} 

	public List<Table> Table;

	
	public static vistaraGetFlightListWrapper1 parse(String json) {
		return (vistaraGetFlightListWrapper1) System.JSON.deserialize(json, vistaraGetFlightListWrapper1.class);
	}
}