public class JobResponceWrapper{
	public cls_content[] content;
	public Integer totalElements;	//57
	public boolean last;
	public Integer totalPages;	//6

	public boolean first;
	public Integer numberOfElements;	//10
	public Integer size;	//10
	class cls_content {
		public Integer id;	//7383181
		public String name;	//LOCAL
		public String status;	//COMPLETED
		public String startDate;	//2023-05-01 23:55:00
		public cls_vehicle vehicle;
		public String delayStatus;	//LATE
		public String jobLoadingStatus;	//LOADING
		public Integer vehicleId;	//222503
		public Integer accountId;	//771
		public cls_driver driver;
		public Integer driverId;	//501090
		public cls_route route;
		public Integer routeId;	//396157
		public Integer routeAuditId;	//6202910
		public cls_jobAnalytics[] jobAnalytics;
		public cls_jobBudget jobBudget;
		public Integer predictedDelay;	//0
		public Integer percentageOfRouteCompletedFromPreviousPoint;	//0
		public Integer percentageOfRouteCompletedFromFirstPoint;	//0
		public Integer remainingKmToNextPoint;	//0
		public Double currentKm;	//0.43
		public Integer noOfRunnings;	//1
		public Integer currentFuel;	//0
		public Integer runningDuration;	//174000
		public Integer totalDuration;	//37802900
		public Integer totalTransitTime;	//29284000
		public String jobStatus;	//LOADING
		public Integer etaNextPoint;	//0
		public Integer createdDate;	//1682925215000
		public Integer lastModifiedDate;	//1682995022000
		public Integer createdBy;	//13923
		public String endDate;	//2023-05-02 08:03:04
		public cls_customFields[] customFields;
		public Double avgSpeed;	//8.9
		public boolean manualEntry;
		public boolean epodUploaded;
		public Integer drivingScore;	//100
		public cls_jobAlarms[] jobAlarms;
		public cls_checkListPresent checkListPresent;
		public boolean indicativeKmPresent;
		public boolean eway;
		public cls_erpJob erpJob;
		public boolean innerGeofenceStatus;
		public boolean outerGeofenceStatus;
		public Integer openingOdo;	//28862
		public cls_trailers[] trailers;
		public cls_jobMetrics[] jobMetrics;
		public boolean scanningDisabled;
	}
	class cls_vehicle {
		public Integer id;	//222503
		public String licensePlate;	//TS13UC7059
		public String name;	//7059
		public Integer groupId;	//1281
		public String deviceType;	//FMB910
		public String deviceId;	//354018113416162
		public String consentStatus;	//NOTALLOWED
		public Integer sos;	//0
		public boolean immobiliser;
		public Integer deviceInstallDate;	//1632826207000
		public Integer tempSensor;	//0
		public Integer fuelSensor;	//0
		public cls_vehicleSpecs vehicleSpecs;
		public Integer accountId;	//771
		public String vehicleOwnership;	//OWNED
	}
	class cls_group {
		public Integer createdDate;	//1687251569000
		public Integer lastModifiedDate;	//1687251570000
		public Integer createdBy;	//5801
		public Integer lastModifiedBy;	//5801
		public Integer id;	//1281
		public String name;	//Hyderabad - Andhra Pradesh & Telangana
		public Integer accountId;	//771
		public boolean enabled;
	}
	class cls_vehicleSpecs {
		public Integer id;	//90813
	}
	class cls_driver {
		public Integer id;	//501090
		public String firstName;	//B SUBBA REDDY - TH257714
		public String username;	//7674820259
		public String phoneNumber;	//+91-7674820259
		public String userType;	//DRIVER
		public boolean enabled;
		public cls_tagIdsSet[] tagIdsSet;
		public String name;	//B SUBBA REDDY - TH257714
	}
	class cls_tagIdsSet {
	}
	class cls_route {
		public Integer id;	//396157
		public String name;	//OLD CITY HYD01
		public boolean enabled;
		public Integer hillKm;	//0
		public Double distance;	//72.567
	}
	class cls_jobAnalytics {
		public Integer id;	//20332864
		public Integer jobId;	//7383181
		public Integer scheduledArrival;	//1682922000000
		public Integer scheduledDeparture;	//1682965500000
		public Integer actualArrival;	//1682956981000
		public String status;	//LATE
		public String vehicleState;	//LOADED
		public String currentVehicleState;	//LOADING
		public cls_customFields[] customFields;
		public Integer delay;	//34981000
		public cls_routePoint routePoint;
		public Integer routePointId;	//802273
		public Integer transitTime;	//0
		public cls_jobPointMetric jobPointMetric;
		public Integer actualDistance;	//0
		public cls_billNumbers[] billNumbers;
		public cls_epods[] epods;
		public cls_erpJobAnalytics[] erpJobAnalytics;
	}
	class cls_customFields {
	}
	class cls_routePoint {
		public Integer id;	//802273
		public String address;	//Hyderabad 1 - Mehdipatnam	 - HYD
		public Double latitude;	//17.398193679438734
		public Double longitude;	//78.44400579999999
		public Integer distance;	//0
		public Integer addressBookId;	//31564
		public Integer transitTime;	//0
		public Integer radius;	//300
		public boolean reversePoint;
		public boolean wayPoint;
		public boolean createJobAnalytics;
	}
	class cls_jobPointMetric {
		public String createdDate;	//2023-05-01T21:41:52
		public String lastModifiedDate;	//2023-05-02T13:39:29
		public Integer lastModifiedBy;	//13923
		public Integer id;	//13054196
		public Integer predictedDelay;	//0
		public String currentStatus;	//LATE
		public Integer jobAnalyticsId;	//20332864
		public boolean unloadingComplete;
	}
	class cls_billNumbers {
	}
	class cls_epods {
	}
	class cls_erpJobAnalytics {
	}
	class cls_jobBudget {
		public Integer id;	//683419
		public Integer jobId;	//7383181
		public Integer estimatedTotal;	//0
		public Integer sanctionedTotal;	//0
		public Integer paidTotal;	//0
	}
	class cls_jobAlarms {
		public String createdDate;	//2023-05-01T21:51:31
		public String lastModifiedDate;	//2023-05-02T07:57:24
		public Integer id;	//3386744
		public Integer jobId;	//7383181
		public String type;	//parked
		public Integer count;	//64
	}
	class cls_checkListPresent {
	}
	class cls_erpJob {
		public Integer id;	//78148
		public Integer jobId;	//7383181
	}
	class cls_trailers {
	}
	class cls_jobMetrics {
		public Integer id;	//18789843
		public Integer jobId;	//7383181
		public String type;	//SCHEDULED_TRANSIT_TIME
		public Integer value;	//6531029
	}
	class cls_sort {
		public String direction;	//DESC
		public String property;	//startDate
		public boolean ignoreCase;
		public String nullHandling;	//NATIVE
		public boolean ascending;
		public boolean descending;
	}



}