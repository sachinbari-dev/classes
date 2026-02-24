global class BVC_IqlooAccessTokenScheduler  implements schedulable {

    global void execute(SchedulableContext sc){
        BVC_IqlooAccessTokenSchedulerHelper.accesTokenGenerator();
    }
}