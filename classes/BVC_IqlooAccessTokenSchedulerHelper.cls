public class BVC_IqlooAccessTokenSchedulerHelper {

     @future(callout=true)
    public static void accesTokenGenerator(){
        BVC_IqlooLockAPIHelper.generateAccessToken();
    }
}