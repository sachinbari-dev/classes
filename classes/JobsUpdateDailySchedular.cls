global class JobsUpdateDailySchedular implements Schedulable 
{
   global void execute(SchedulableContext sc) {
      JobsUpdateDaily.jobUpdateCallout();
   }
}