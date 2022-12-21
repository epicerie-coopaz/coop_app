/**
 * Process the invoice sent by the coopaz client
 * 
 * Parameters:
 *  String emailAddress: a valid email address Should be referenced in members sheet
 *  String paymentMethod: "CB", "virement" or "cheque"
 *  List<Product>: List of product objects for the incomming invoice. 
 *    A product object should have this fields: {"product": "GRENADE FRUITS BIO PAYS LANDAIS KILO 806", "qty": 5.2}
 */
function processInvoice(emailAddress, paymentMethod, invoiceProducts) {
  let allProductsSheetName = 'produits' // product sheet
  let membersSheetName = 'ImportMembres' // members sheet
  let rangeAllProducts = 'A2:N9999' //range des produits
  let rangeMembersEmails = 'B1:B9999' //range des produits

  emailAddress = emailAddress.trim();

  let ss = SpreadsheetApp.getActive();

  let sheetMembers = ss.getSheetByName(membersSheetName);
  let membersEmailRange = sheetMembers.getRange(rangeMembersEmails);

  let sheetAllProducts = ss.getSheetByName(allProductsSheetName);
  let allProductsRange = sheetAllProducts.getRange(rangeAllProducts);
  let allProductsValues = allProductsRange.getValues();

  // Verify that the given inputs are valid. If so do nothing. Throw an error otherwise.
  if (emailAddress == "" || !emailAddress.includes("@") || membersEmailRange.getValues().findIndex((email) => email[0].trim() == emailAddress) < 0) {
    throw `Email address invalid: ${emailAddress}`;
  }
  if (paymentMethod != "CB" && paymentMethod != "virement" && paymentMethod != "cheque") {
    throw `Payment method invalid: ${paymentMethod}`;
  }

  // Update the products sheet based on the products in the invoice
  for (let i = 0; i < invoiceProducts.length; i++) {

    let productName = invoiceProducts[i]["product"].trim()
    let quantity = Number(invoiceProducts[i]["qty"])

    // If there is no product name or quantity we ignore this invalid input.
    if (productName == "" || !(quantity > 0.0)) {
      break
    } else {

      let productIndex = allProductsValues.findIndex((productLine) => productLine[0].trim() == productName) + 1

      // if product index < 1 it means that the product was not found. We ignore it then.
      if (productIndex < 1) {
        break;
      }

      // Update current stock
      let quantityCurrentStockCell = allProductsRange.getCell(productIndex, 12);
      let quantityCurrentStockValue = quantityCurrentStockCell.getValue();
      if (quantityCurrentStockValue > 0) {
        quantityCurrentStockCell.setValue(quantityCurrentStockValue - quantity);
      }

      // Update history
      let quantityHistoryCell = allProductsRange.getCell(productIndex, 11);
      let quantityHistoryValue = quantityHistoryCell.getValue();
      quantityHistoryCell.setValue(quantityHistoryValue + quantity);

    }
  }
}


function testProcessInvoice() {
  processInvoice("laurie.besinet@gmail.com", "CB", [{ "product": "GRENADE FRUITS BIO PAYS LANDAIS KILO 806", "qty": 5.2 }]);
}

