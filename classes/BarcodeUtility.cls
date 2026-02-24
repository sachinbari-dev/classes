public class BarcodeUtility {
    public static String getBarcodeUrl(String snNumber) {
        if (String.isBlank(snNumber)) return '';

        return 'https://quickchart.io/barcode?'
            + 'text=' + EncodingUtil.urlEncode(snNumber, 'UTF-8')
            + '&type=code128'
            + '&scale=3'
            + '&height=100'
            + '&format=png';
    }
}