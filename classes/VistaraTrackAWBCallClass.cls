public class VistaraTrackAWBCallClass {
@InvocableMethod
      public static void callBatch(){
        database.executeBatch(new VistaraTrackAwbBatch(),200);
        database.executeBatch(new Indigo_TrackAWB_Batch(),200);
    }
}