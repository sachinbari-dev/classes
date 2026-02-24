/*
 * Created By 			: Imran
 * Created Date 		: 08-10-2025
 * Class 				: ApexTriggerControl
 * Description 			: control record insert/update inside an Apex trigger to avoid looping (recursion)
 */
public class ApexTriggerControl {
    public static Boolean hasAlreadyRun = false;
}