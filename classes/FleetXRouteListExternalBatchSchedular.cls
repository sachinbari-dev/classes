global class FleetXRouteListExternalBatchSchedular
{
    /*
global void execute(SchedulableContext sc)
{
FleetXRouteListExternal FRE = new FleetXRouteListExternal();
FRE.getFleetXRoutes();
}
*/
    @InvocableMethod(label='FleetXRouteCallout')   
    public static void FleetXRouteCallout(List<ID> ids) 
    {
        System.debug('<==== FleetXRouteListExternalBatchSchedular Started ====>');
        // FleetXRouteListExternal.getFleetXRoutes();
        System.enqueueJob(new FleetXRouteListExternalQuable());
        System.debug('<==== FleetXRouteListExternalBatchSchedular Ended ====>');
    }
}