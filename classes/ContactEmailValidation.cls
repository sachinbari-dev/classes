public class ContactEmailValidation {
    public static void validateEmail(List<Contact> contacts) {
        for (Contact contact : contacts) {
            if (contact.Email != null && contact.Email.endsWith('bvclogistics.com')) {
                contact.Email.addError('Email Addresses Ending With "bvclogistics.com" Domain Are Not Allowed.');
            }
        }
    }
}