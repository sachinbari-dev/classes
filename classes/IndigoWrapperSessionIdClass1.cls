public class IndigoWrapperSessionIdClass1 {
    public List<AgentData> Table;

    public class AgentData {
        public String AgentCode;
        public String ControllingLocator;
        public Boolean IsActive;
        public String SessionID;
        public String RetStatus;
        public String RoleName;
        public String AgentName;
        public String UserType;
        public String RoleType;
        public Decimal AgentBalance;
        public String AgentEmail;
        public String AgentContact;
        public String IsChangePassword;
        public String UserId;
        public String UserName;
        public String UserEmail;
        public String BaseStation;
        public String StationCode;
        public Boolean IsAllStn;
        public String BaseCarrier;
        public String AllowedCarriers;
        public String IsAllCarrierAcess;
        public String BasePrefix;
    }

       public static IndigoWrapperSessionIdClass1 parse(String json) {
		return (IndigoWrapperSessionIdClass1) System.JSON.deserialize(json, IndigoWrapperSessionIdClass1.class);
	}
}