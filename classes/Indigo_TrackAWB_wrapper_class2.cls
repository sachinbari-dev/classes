public class Indigo_TrackAWB_wrapper_class2 {
// this class is used as wrapper class as well this class deserialize the JOSN response body and used in Indigo_TrackAWB_Helper apex class.
  public List<Table> Table;
	public List<Table1> Table1;
	public List<Table2> Table2;
	public List<Table3> Table3;
	public List<Table1> Table4;
	public List<Table5> Table5;
	public List<Table6> Table6;
	public List<Table7> Table7;
	public List<Table1> Table8;
	public List<Table1> Table9;

	public class Table {
		public Integer ErrorCode;
		public String ErrorDesc;
	}

	public class Table6 {
		public Integer StationCount;
	}
// used in Indigo_TrackAWB_Helper apex class to create linehaul tracking record
	public class Table7 {
		public String LastActivity;
		public String Description;
	}
 
	public class Table2 {
		public String AWBNumber;
		public String Station;
		public String Milestone;
		public Integer Pieces;
		public String PiecesWeight;
		public String UOM;
		public String FlightNo;
		public String FlightDate;
		public String Origin;
		public String Destination;
		public String ULDNO;
		public Integer OrderBy;
		public String UpdatedOn;
	}

	public class Table3 {
		public Integer SrNo;	//1
		public String AWBNumber;	//228-10567546
		public String Station;	//DEL
		public String AirportName;	//DELHI
		public String Milestone1;	//Accepted
		public String PiecesWeight1;	//53 P / 1101.00 Kgs
		public String FlightNoDate1;	// / 18/07/2023 09:32
		public String IconType1;	//Green
		public string Origin1;
		public string Destination1;
		public string Milestone2;
		public String PiecesWeight2;	//39 P / 810.17 Kgs
		public String FlightNoDate2;	//UK819 / 18/07/2023 14:13
		public String IconType2;	//Green
		public String Origin2;	//DEL
		public String Destination2;	//BLR
		public String Milestone3;	//Departed
		public String PiecesWeight3;	//14 P / 290.83 Kgs
		public String FlightNoDate3;	//UK819 / 18/07/2023
		public String IconType3;	//Green
		public String Origin3;	//DEL
		public String Destination3;	//BLR
		public string PrevMilestone;
		public string PrevPiecesWeight;
		public string PrevFlightNoDate;
		public Integer StationId;	//1
		public string Milestone4;
		public string PiecesWeight4;
		public string FlightNoDate4;
		public String IconType4;	//Green
		public string Milestone5;
		public string PiecesWeight5;
		public string FlightNoDate5;
		public String IconType5;	//Green
	}
    class cls_Origin1 {
	}
	class cls_Destination1 {
	}
	class cls_Milestone2 {
	}
	class cls_PrevMilestone {
	}
	class cls_PrevPiecesWeight {
	}
	class cls_PrevFlightNoDate {
	}
	class cls_Milestone4 {
	}
	class cls_PiecesWeight4 {
	}
	class cls_FlightNoDate4 {
	}
	class cls_Milestone5 {
	}
	class cls_PiecesWeight5 {
	}
	class cls_FlightNoDate5 {
	}
    public class Table4 {
        public String AWBNumber;	//228-10567546
		public String Station;	//DEL
		public Integer ConnectorCount;	//2
		public Integer SrNo;	//2
	}
	public class Table5 {
		public Integer MaxConCount;
	}

	public class Table1 {
        public String AWBNumber;	//228-10567546
		public String Station;	//DEL
		public String Milestone;	//Offloaded
		public Integer Pieces;	//39
		public String PiecesWeight;	//810.17 Kgs
		public String UOM;	//Kgs
		public String FlightNo;	//UK819
		public String FlightDate;	//18/07/2023 14:13
		public String Origin;	//DEL
		public String Destination;	//BLR
		public String ULDNO;	//
		public Integer OrderBy;	//6
		public String UpdatedOn;	
	}
    class cls_HAWBNo {
	}
	class cls_ULDNo {
	}
    public class Table9 {
        public String AWBNumber;	//228-10567546
		public String DONumber;	//DO-BLR-71025
		public String FlightInfo;	//UK819 / 18/07/2023
		public Integer ActualPieces;	//14
		public String ActualWeight;	//290.83 Kgs
		public String DOLink;	//https://ukproderpstorage.blob.core.windows.net/deliveryorder/DO-BLR-71025_20230719022956.pdf
		public String IssuedTo;	//LOKESH
	}
 
	public static Indigo_TrackAWB_wrapper_class2 parse(String json) {
		return (Indigo_TrackAWB_wrapper_class2) System.JSON.deserialize(json, Indigo_TrackAWB_wrapper_class2.class);
	}
}