/*Class      : SendEmailController
 *Author     : Sanket.pisal@bvclogistics.com
 *Date       : Jan 2024
 */

public class ExhibitionInvocable {

    @InvocableMethod(label='Run Exhibition Batch' description='Runs the Exhibition Batch to update shipments')
    public static void runExhibitionBatch() {
        ExhibitionBatch exhibitionBatch = new ExhibitionBatch();
        Id batchJobId = Database.executeBatch(exhibitionBatch,200);
      
    }
}