public class acrMonthlyReportScheduleHelper {
    
    
    @InvocableMethod
    public static void acrschedulerByUser(){
        
			System.schedule('acrMonthlyReportSchedule 13', '0 03 * * * ?', new acrMonthlyReportSchedule());
            System.schedule('acrMonthlyReportSchedule 14', '0 07 * * * ?', new acrMonthlyReportSchedule());
            System.schedule('acrMonthlyReportSchedule 15', '0 13 * * * ?', new acrMonthlyReportSchedule());
            System.schedule('acrMonthlyReportSchedule 16', '0 17 * * * ?', new acrMonthlyReportSchedule());
            System.schedule('acrMonthlyReportSchedule 17', '0 23 * * * ?', new acrMonthlyReportSchedule());
            System.schedule('acrMonthlyReportSchedule 18', '0 27 * * * ?', new acrMonthlyReportSchedule());
            System.schedule('acrMonthlyReportSchedule 19', '0 33 * * * ?', new acrMonthlyReportSchedule());
            System.schedule('acrMonthlyReportSchedule 20', '0 37 * * * ?', new acrMonthlyReportSchedule());
            System.schedule('acrMonthlyReportSchedule 21', '0 43 * * * ?', new acrMonthlyReportSchedule());
            System.schedule('acrMonthlyReportSchedule 22', '0 47 * * * ?', new acrMonthlyReportSchedule());
            System.schedule('acrMonthlyReportSchedule 23', '0 53 * * * ?', new acrMonthlyReportSchedule());
            System.schedule('acrMonthlyReportSchedule 24', '0 57 * * * ?', new acrMonthlyReportSchedule());
            System.schedule('acrMonthlyReportSchedule 1', '0 05 * * * ?', new acrMonthlyReportSchedule());
            System.schedule('acrMonthlyReportSchedule 2', '0 10 * * * ?', new acrMonthlyReportSchedule());
            System.schedule('acrMonthlyReportSchedule 3', '0 15 * * * ?', new acrMonthlyReportSchedule());
            System.schedule('acrMonthlyReportSchedule 4', '0 20 * * * ?', new acrMonthlyReportSchedule());
            System.schedule('acrMonthlyReportSchedule 5', '0 25 * * * ?', new acrMonthlyReportSchedule());
            System.schedule('acrMonthlyReportSchedule 6', '0 30 * * * ?', new acrMonthlyReportSchedule());
            System.schedule('acrMonthlyReportSchedule 7', '0 35 * * * ?', new acrMonthlyReportSchedule());
            System.schedule('acrMonthlyReportSchedule 8', '0 40 * * * ?', new acrMonthlyReportSchedule());
            System.schedule('acrMonthlyReportSchedule 9', '0 45 * * * ?', new acrMonthlyReportSchedule());
            System.schedule('acrMonthlyReportSchedule 10', '0 50 * * * ?', new acrMonthlyReportSchedule());
            System.schedule('acrMonthlyReportSchedule 11', '0 55 * * * ?', new acrMonthlyReportSchedule());
            System.schedule('acrMonthlyReportSchedule 12', '0 00 * * * ?', new acrMonthlyReportSchedule());
        	System.schedule('acrMontlyEmailsSchedule 13', '0 03 * * * ?', new acrMontlyEmailsSchedule());
            System.schedule('acrMontlyEmailsSchedule 14', '0 07 * * * ?', new acrMontlyEmailsSchedule());
            System.schedule('acrMontlyEmailsSchedule 15', '0 13 * * * ?', new acrMontlyEmailsSchedule());
            System.schedule('acrMontlyEmailsSchedule 16', '0 17 * * * ?', new acrMontlyEmailsSchedule());
            System.schedule('acrMontlyEmailsSchedule 17', '0 23 * * * ?', new acrMontlyEmailsSchedule());
            System.schedule('acrMontlyEmailsSchedule 18', '0 27 * * * ?', new acrMontlyEmailsSchedule());
            System.schedule('acrMontlyEmailsSchedule 19', '0 33 * * * ?', new acrMontlyEmailsSchedule());
            System.schedule('acrMontlyEmailsSchedule 20', '0 37 * * * ?', new acrMontlyEmailsSchedule());
            System.schedule('acrMontlyEmailsSchedule 21', '0 43 * * * ?', new acrMontlyEmailsSchedule());
            System.schedule('acrMontlyEmailsSchedule 22', '0 47 * * * ?', new acrMontlyEmailsSchedule());
            System.schedule('acrMontlyEmailsSchedule 23', '0 53 * * * ?', new acrMontlyEmailsSchedule());
            System.schedule('acrMontlyEmailsSchedule 24', '0 57 * * * ?', new acrMontlyEmailsSchedule());
            System.schedule('acrMontlyEmailsSchedule 1', '0 05 * * * ?', new acrMontlyEmailsSchedule());
            System.schedule('acrMontlyEmailsSchedule 2', '0 10 * * * ?', new acrMontlyEmailsSchedule());
            System.schedule('acrMontlyEmailsSchedule 3', '0 15 * * * ?', new acrMontlyEmailsSchedule());
            System.schedule('acrMontlyEmailsSchedule 4', '0 20 * * * ?', new acrMontlyEmailsSchedule());
            System.schedule('acrMontlyEmailsSchedule 5', '0 25 * * * ?', new acrMontlyEmailsSchedule());
            System.schedule('acrMontlyEmailsSchedule 6', '0 30 * * * ?', new acrMontlyEmailsSchedule());
            System.schedule('acrMontlyEmailsSchedule 7', '0 35 * * * ?', new acrMontlyEmailsSchedule());
            System.schedule('acrMontlyEmailsSchedule 8', '0 40 * * * ?', new acrMontlyEmailsSchedule());
            System.schedule('acrMontlyEmailsSchedule 9', '0 45 * * * ?', new acrMontlyEmailsSchedule());
            System.schedule('acrMontlyEmailsSchedule 10', '0 50 * * * ?', new acrMontlyEmailsSchedule());
            System.schedule('acrMontlyEmailsSchedule 11', '0 55 * * * ?', new acrMontlyEmailsSchedule());
            System.schedule('acrMontlyEmailsSchedule 12', '0 00 * * * ?', new acrMontlyEmailsSchedule());  
        
      /*  acrMonthlyReportSchedule job13 = new acrMonthlyReportSchedule();
        job13.setIsOld(isOld);
        System.schedule('acrMonthlyReportSchedule 13', '0 03 * * * ?', job13);
        acrMonthlyReportSchedule job14 = new acrMonthlyReportSchedule();
        job13.setIsOld(isOld);
        System.schedule('acrMonthlyReportSchedule 14', '0 07 * * * ?', job14);
        acrMonthlyReportSchedule Job15 = new acrMonthlyReportSchedule();
        Job15.setIsOld(isOld);
        System.schedule('acrMonthlyReportSchedule 15', '0 13 * * * ?', Job15);
        acrMonthlyReportSchedule Job16 = new acrMonthlyReportSchedule();
        Job16.setIsOld(isOld);
        System.schedule('acrMonthlyReportSchedule 16', '0 17 * * * ?', Job16);
        acrMonthlyReportSchedule Job17 = new acrMonthlyReportSchedule();
        Job17.setIsOld(isOld);
        System.schedule('acrMonthlyReportSchedule 17', '0 23 * * * ?', Job17);
        acrMonthlyReportSchedule Job18 = new acrMonthlyReportSchedule();
        Job18.setIsOld(isOld);
        System.schedule('acrMonthlyReportSchedule 18', '0 27 * * * ?', Job18);
        acrMonthlyReportSchedule Job19 = new acrMonthlyReportSchedule();
        Job19.setIsOld(isOld);
        System.schedule('acrMonthlyReportSchedule 19', '0 33 * * * ?', Job19);
        acrMonthlyReportSchedule Job20 = new acrMonthlyReportSchedule();
        Job20.setIsOld(isOld);
        System.schedule('acrMonthlyReportSchedule 20', '0 37 * * * ?', Job20);
        acrMonthlyReportSchedule Job21 = new acrMonthlyReportSchedule();
        Job21.setIsOld(isOld);
        System.schedule('acrMonthlyReportSchedule 21', '0 43 * * * ?', Job21);
        acrMonthlyReportSchedule Job22 = new acrMonthlyReportSchedule();
        Job22.setIsOld(isOld);
        System.schedule('acrMonthlyReportSchedule 22', '0 47 * * * ?', Job22);
        acrMonthlyReportSchedule Job23 = new acrMonthlyReportSchedule();
        Job23.setIsOld(isOld);
        System.schedule('acrMonthlyReportSchedule 23', '0 53 * * * ?', Job23);
        acrMonthlyReportSchedule Job24 = new acrMonthlyReportSchedule();
        Job24.setIsOld(isOld);
        System.schedule('acrMonthlyReportSchedule 24', '0 57 * * * ?', Job24);
        acrMonthlyReportSchedule Job1 = new acrMonthlyReportSchedule();
        Job1.setIsOld(isOld);
        System.schedule('acrMonthlyReportSchedule 1', '0 05 * * * ?', Job1);
        acrMonthlyReportSchedule Job2 = new acrMonthlyReportSchedule();
        Job2.setIsOld(isOld);
        System.schedule('acrMonthlyReportSchedule 2', '0 10 * * * ?', Job2);
        acrMonthlyReportSchedule Job3 = new acrMonthlyReportSchedule();
        Job3.setIsOld(isOld);
        System.schedule('acrMonthlyReportSchedule 3', '0 15 * * * ?', Job3);
        acrMonthlyReportSchedule Job4 = new acrMonthlyReportSchedule();
        Job4.setIsOld(isOld);
        System.schedule('acrMonthlyReportSchedule 4', '0 20 * * * ?', Job4);
        acrMonthlyReportSchedule Job5 = new acrMonthlyReportSchedule();
        Job5.setIsOld(isOld);
        System.schedule('acrMonthlyReportSchedule 5', '0 25 * * * ?', Job5);
        acrMonthlyReportSchedule Job6 = new acrMonthlyReportSchedule();
        Job6.setIsOld(isOld);
        System.schedule('acrMonthlyReportSchedule 6', '0 30 * * * ?', Job6);
        acrMonthlyReportSchedule Job7 = new acrMonthlyReportSchedule();
        Job7.setIsOld(isOld);
        System.schedule('acrMonthlyReportSchedule 7', '0 35 * * * ?', Job7);
        acrMonthlyReportSchedule Job8 = new acrMonthlyReportSchedule();
        Job8.setIsOld(isOld);
        System.schedule('acrMonthlyReportSchedule 8', '0 40 * * * ?', Job8);
        acrMonthlyReportSchedule Job9 = new acrMonthlyReportSchedule();
        Job9.setIsOld(isOld);
        System.schedule('acrMonthlyReportSchedule 9', '0 45 * * * ?', Job9);
        acrMonthlyReportSchedule Job10 = new acrMonthlyReportSchedule();
        Job10.setIsOld(isOld);
        System.schedule('acrMonthlyReportSchedule 10', '0 50 * * * ?', Job10);
        acrMonthlyReportSchedule Job11 = new acrMonthlyReportSchedule();
        Job11.setIsOld(isOld);
        System.schedule('acrMonthlyReportSchedule 11', '0 55 * * * ?', Job11);
        			acrMontlyEmailsSchedule Job013 = new acrMontlyEmailsSchedule();
        Job013.setIsOld(isOld);
			System.schedule('acrMontlyEmailsSchedule 13', '0 03 * * * ?', Job013);
			acrMontlyEmailsSchedule Job014 = new acrMontlyEmailsSchedule();
        Job014.setIsOld(isOld);
			System.schedule('acrMontlyEmailsSchedule 14', '0 07 * * * ?', Job014);
			acrMontlyEmailsSchedule Job015 = new acrMontlyEmailsSchedule();
        Job015.setIsOld(isOld);
			System.schedule('acrMontlyEmailsSchedule 15', '0 13 * * * ?', Job015);
			acrMontlyEmailsSchedule Job016 = new acrMontlyEmailsSchedule();
        Job016.setIsOld(isOld);
            System.schedule('acrMontlyEmailsSchedule 16', '0 17 * * * ?', Job016);
			acrMontlyEmailsSchedule Job017 = new acrMontlyEmailsSchedule();
        Job017.setIsOld(isOld);
            System.schedule('acrMontlyEmailsSchedule 17', '0 23 * * * ?', Job017);
			acrMontlyEmailsSchedule Job018 = new acrMontlyEmailsSchedule();
        Job018.setIsOld(isOld);
            System.schedule('acrMontlyEmailsSchedule 18', '0 27 * * * ?', Job018);
			acrMontlyEmailsSchedule Job019 = new acrMontlyEmailsSchedule();
        Job019.setIsOld(isOld);
            System.schedule('acrMontlyEmailsSchedule 19', '0 33 * * * ?', Job019);
			acrMontlyEmailsSchedule Job020 = new acrMontlyEmailsSchedule();
        Job020.setIsOld(isOld);
            System.schedule('acrMontlyEmailsSchedule 20', '0 37 * * * ?', Job020);
			acrMontlyEmailsSchedule Job021 = new acrMontlyEmailsSchedule();
        Job021.setIsOld(isOld);
            System.schedule('acrMontlyEmailsSchedule 21', '0 43 * * * ?', Job021);
			acrMontlyEmailsSchedule Job022 = new acrMontlyEmailsSchedule();
        Job022.setIsOld(isOld);
            System.schedule('acrMontlyEmailsSchedule 22', '0 47 * * * ?', Job022);
			acrMontlyEmailsSchedule Job023 = new acrMontlyEmailsSchedule();
        Job023.setIsOld(isOld);
            System.schedule('acrMontlyEmailsSchedule 23', '0 53 * * * ?', Job023);
			acrMontlyEmailsSchedule Job024 = new acrMontlyEmailsSchedule();
        Job024.setIsOld(isOld);
            System.schedule('acrMontlyEmailsSchedule 24', '0 57 * * * ?', Job024);
			acrMontlyEmailsSchedule Job01 = new acrMontlyEmailsSchedule();
        Job01.setIsOld(isOld);
            System.schedule('acrMontlyEmailsSchedule 1', '0 05 * * * ?', Job01);
			acrMontlyEmailsSchedule Job02 = new acrMontlyEmailsSchedule();
        Job02.setIsOld(isOld);
            System.schedule('acrMontlyEmailsSchedule 2', '0 10 * * * ?', Job02);
			acrMontlyEmailsSchedule Job03 = new acrMontlyEmailsSchedule();
        Job03.setIsOld(isOld);
            System.schedule('acrMontlyEmailsSchedule 3', '0 15 * * * ?', Job03);
			acrMontlyEmailsSchedule Job04 = new acrMontlyEmailsSchedule();
        Job04.setIsOld(isOld);
            System.schedule('acrMontlyEmailsSchedule 4', '0 20 * * * ?', Job04);
			acrMontlyEmailsSchedule Job05 = new acrMontlyEmailsSchedule();
        Job05.setIsOld(isOld);
            System.schedule('acrMontlyEmailsSchedule 5', '0 25 * * * ?', Job05);
			acrMontlyEmailsSchedule Job06 = new acrMontlyEmailsSchedule();
        Job06.setIsOld(isOld);
            System.schedule('acrMontlyEmailsSchedule 6', '0 30 * * * ?', Job06);
			acrMontlyEmailsSchedule Job07 = new acrMontlyEmailsSchedule();
        Job07.setIsOld(isOld);
            System.schedule('acrMontlyEmailsSchedule 7', '0 35 * * * ?', Job07);
			acrMontlyEmailsSchedule Job08 = new acrMontlyEmailsSchedule();
        Job08.setIsOld(isOld);
            System.schedule('acrMontlyEmailsSchedule 8', '0 40 * * * ?', Job08);
			acrMontlyEmailsSchedule Job09 = new acrMontlyEmailsSchedule();
        Job09.setIsOld(isOld);
            System.schedule('acrMontlyEmailsSchedule 9', '0 45 * * * ?', Job09);
			acrMontlyEmailsSchedule Job010 = new acrMontlyEmailsSchedule();
        Job010.setIsOld(isOld);
            System.schedule('acrMontlyEmailsSchedule 10', '0 50 * * * ?', Job010);
			acrMontlyEmailsSchedule Job011 = new acrMontlyEmailsSchedule();
        Job011.setIsOld(isOld);
            System.schedule('acrMontlyEmailsSchedule 11', '0 55 * * * ?', Job011);*/
            
        
    }
    
    

    public static void acrmonthlyhealper() {
        IF(datetime.now().hour() == 23 && datetime.now().minute() == 30) {
            for (CronTrigger job: [select Id, CronJobDetail.Name from CronTrigger where CronJobDetail.JobType = '7'
                    and (CronJobDetail.Name like '%acrMonthlyReportSchedule%' or CronJobDetail.Name like '%acrMontlyEmailsSchedule%')
                ]) {
                System.abortJob(job.Id);
                System.debug('cancellation path');
            }
        }

    }

}