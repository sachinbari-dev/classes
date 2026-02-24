@isTest
public class indigo_TrackAWBResponseWrapperTest {

     @isTest
    public static void testTrackAWBAPI(){
        string json = '{"d":"RESPONSE_START:SUCCESS:RESPONSE_ENDRESULT_START:{\"Table\":[{\"ErrorCode\":0,\"ErrorDesc\":\"Get Tracking Details successful.\"}],\"Table1\":[],\"Table2\":[{\"AWBNumber\":\"312-11109980\",\"Station\":\"BOM\",\"Milestone\":\"Booked\",\"Pieces\":1,\"PiecesWeight\":\"1000.00 Kgs\",\"UOM\":\"K\",\"FlightNo\":\"6E5179 10/09/2025\",\"FlightDate\":\"08/09/2025 10:24\",\"Origin\":\"BOM\",\"Destination\":\"HYD\",\"ULDNO\":\"\",\"OrderBy\":1,\"UpdatedOn\":\"2025-09-10T00:00:00\"}],\"Table3\":[{\"SrNo\":1,\"AWBNumber\":\"312-11109980\",\"Station\":\"BOM\",\"AirportName\":\"MUMBAI\",\"Milestone1\":null,\"PiecesWeight1\":null,\"FlightNoDate1\":null,\"IconType1\":\"Normal\",\"Origin1\":null,\"Destination1\":null,\"Milestone2\":null,\"PiecesWeight2\":null,\"FlightNoDate2\":null,\"IconType2\":\"Normal\",\"Origin2\":null,\"Destination2\":null,\"Milestone3\":null,\"PiecesWeight3\":null,\"FlightNoDate3\":null,\"IconType3\":\"Normal\",\"Origin3\":null,\"Destination3\":null,\"PrevMilestone\":null,\"PrevPiecesWeight\":null,\"PrevFlightNoDate\":null,\"StationId\":1,\"Milestone4\":null,\"PiecesWeight4\":null,\"FlightNoDate4\":null,\"IconType4\":\"Normal\",\"Milestone5\":null,\"PiecesWeight5\":null,\"FlightNoDate5\":null,\"IconType5\":\"Normal\"},{\"SrNo\":2,\"AWBNumber\":\"312-11109980\",\"Station\":\"HYD\",\"AirportName\":\"HYDERABAD\",\"Milestone1\":null,\"PiecesWeight1\":null,\"FlightNoDate1\":null,\"IconType1\":\"Normal\",\"Origin1\":null,\"Destination1\":null,\"Milestone2\":null,\"PiecesWeight2\":null,\"FlightNoDate2\":null,\"IconType2\":\"Normal\",\"Origin2\":null,\"Destination2\":null,\"Milestone3\":null,\"PiecesWeight3\":null,\"FlightNoDate3\":null,\"IconType3\":\"Normal\",\"Origin3\":null,\"Destination3\":null,\"PrevMilestone\":null,\"PrevPiecesWeight\":null,\"PrevFlightNoDate\":null,\"StationId\":null,\"Milestone4\":null,\"PiecesWeight4\":null,\"FlightNoDate4\":null,\"IconType4\":\"Normal\",\"Milestone5\":null,\"PiecesWeight5\":null,\"FlightNoDate5\":null,\"IconType5\":\"Normal\"}],\"Table4\":[],\"Table5\":[{\"MaxConCount\":0}],\"Table6\":[{\"StationCount\":2}],\"Table7\":[{\"LastActivity\":\"Booked at BOM\",\"Description\":\"1 P / 1000.00 Kgs\"}],\"Table8\":[],\"Table9\":[]}:RESULT_END"}';
            try{
             indigo_TrackAWBResponseWrapper.parse(json);
        }catch(exception e){
            system.debug('error:' + e);
        }
       
    }
}