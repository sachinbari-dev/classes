public class Indigo_GetTrackingInfowrapper1 {
    public String d;  

    public class TrackingResult {
        public List<Table> Table;
        public List<Object> Table1;
        public List<Table2> Table2;
        public List<Table3> Table3;
        public List<Object> Table4;
        public List<Table5> Table5;
        public List<Table6> Table6;
        public List<Table7> Table7;
        public List<Object> Table8;
        public List<Object> Table9;
    }

    public class Table {
        public Integer ErrorCode;
        public String ErrorDesc;
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
        public Integer SrNo;
        public String AWBNumber;
        public String Station;
        public String AirportName;

        public String Milestone1;
        public String PiecesWeight1;
        public String FlightNoDate1;
        public String IconType1;
        public String Origin1;
        public String Destination1;

        public String Milestone2;
        public String PiecesWeight2;
        public String FlightNoDate2;
        public String IconType2;
        public String Origin2;
        public String Destination2;

        public String Milestone3;
        public String PiecesWeight3;
        public String FlightNoDate3;
        public String IconType3;
        public String Origin3;
        public String Destination3;

        public String PrevMilestone;
        public String PrevPiecesWeight;
        public String PrevFlightNoDate;
        public Integer StationId;

        public String Milestone4;
        public String PiecesWeight4;
        public String FlightNoDate4;
        public String IconType4;

        public String Milestone5;
        public String PiecesWeight5;
        public String FlightNoDate5;
        public String IconType5;
    }

    public class Table5 {
        public Integer MaxConCount;
    }

    public class Table6 {
        public Integer StationCount;
    }

    public class Table7 {
        public String LastActivity;
        public String Description;
    }

   
    public static Indigo_GetTrackingInfowrapper1 parse(String json) {
        return (Indigo_GetTrackingInfowrapper1) System.JSON.deserialize(json, Indigo_GetTrackingInfowrapper1.class);
    }

     
}