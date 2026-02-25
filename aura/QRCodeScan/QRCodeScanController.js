({
    startScan : function(component, event, helper) {

        component.set("v.scannedValue", null);
        component.set("v.errorMessage", null);

        var scanner = component.find("scanner");

        if (!scanner) {
            component.set("v.errorMessage", "Scanner not available 1111");
            return;
        }
		
        alert('Success :'+JSON.stringify(scanner));
        
        scanner.beginCapture({
            barcodeTypes: ["QR"],          // 🔥 QR only = faster
            instructionText: "Scan QR Code",
            successText: "QR detected",
            showSuccessCheckMark: false    // 🔥 faster exit
        })
        .then(function(result) {
            component.set("v.scannedValue", result.value);
        })
        .catch(function(error) {
            component.set("v.errorMessage", error.message);
        })
        .finally(function() {
            scanner.endCapture();
        });
    }
})