global class MeetingScheduleBatchScheduler implements Schedulable {
   global void execute(SchedulableContext sc) {
      MeetingScheduleBatch b = new MeetingScheduleBatch(); 
      Database.executeBatch(b);
   }
}