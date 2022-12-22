/**
 * Process the invoice sent by the coopaz client
 * 
 * Parameters:
 *  String emailAddress: a valid email address Should be referenced in members sheet
 *  String paymentMethod: "CB", "virement" or "cheque"
 *  List<Product>: List of product objects for the current order. 
 *    A product object should have this fields: {"product": "GRENADE FRUITS BIO PAYS LANDAIS KILO 806", "qty": 5.2}
 */
function processOrder(emailAddress, paymentMethod, orderProducts, chequeNumber) {

  var date = Utilities.formatDate(new Date(), Session.getTimeZone(), "yyyy-MM-dd'_'HH:mm:ss")

  let cardFeeRate = 0.00553;
  let allProductsSheetName = 'produits' // product sheet
  let membersSheetName = 'ImportMembres' // members sheet
  let templateSheetName = 'ImportMembres' // members sheet
  let historySheetName = 'Recap' // members sheet

  let rangeAllProducts = 'A2:N9999' //range des produits
  let rangeMembersEmails = 'A1:B9999' //range des produits

  emailAddress = emailAddress.trim();

  let ss = SpreadsheetApp.getActive();

  let templateSheet = ss.getSheetByName(templateSheetName);

  let historySheet = ss.getSheetByName(historySheetName);

  let sheetMembers = ss.getSheetByName(membersSheetName);
  let membersEmailRange = sheetMembers.getRange(rangeMembersEmails);
  let member = membersEmailRange.getValues().find((email) => email[1].trim() == emailAddress);
  let memberName = member[0];

  let sheetAllProducts = ss.getSheetByName(allProductsSheetName);
  let allProductsRange = sheetAllProducts.getRange(rangeAllProducts);
  let allProductsValues = allProductsRange.getValues();

  // Verify that the given inputs are valid. If so do nothing. Throw an error otherwise.
  if (emailAddress == "" || !emailAddress.includes("@") || memberName == undefined) {
    throw `Email address invalid: ${emailAddress}`;
  }
  if (paymentMethod != "CB" && paymentMethod != "virement" && paymentMethod != "cheque") {
    throw `Payment method invalid: ${paymentMethod}`;
  }
  if (orderProducts == undefined || orderProducts == null || !(orderProducts.length > 0)) {
    throw `Order product list invalid: ${orderProducts}`;
  }

  let orderAmount = _updateStock(orderProducts, allProductsRange, allProductsValues);

  let fees = 0.0;
  if (paymentMethod == "CB") {
    fees = orderAmount * cardFeeRate;
  }

  _addToHistory(date, historySheet, memberName, orderAmount, fees, paymentMethod, chequeNumber);

  // TODO: let invoiceTicket = _createInvoiceticket();
  // TODO: _sendEmail(invoiceTicket);

}

/**
* Add to History sheet
*/
function _addToHistory(date, historySheet, memberName, orderAmount, fees, paymentMethod, chequeNumber) {

  var recapFirstEmptyRow = historySheet.getLastRow() + 1;

  historySheet.getRange(recapFirstEmptyRow, 1, 1, 1).setValue(date);

  var pasteNameOnly = historySheet.getRange(recapFirstEmptyRow, 2, 1, 1);
  pasteNameOnly.setValue(memberName);

  var pasteMontant = historySheet.getRange(recapFirstEmptyRow, 3, 1, 1);
  pasteMontant.setValue(orderAmount);

  var pasteFrais = historySheet.getRange(recapFirstEmptyRow, 4, 1, 1);
  pasteFrais.setValue(fees);

  var pasteRecaPaiement = historySheet.getRange(recapFirstEmptyRow, 5, 1, 1);
  pasteRecaPaiement.setValue(paymentMethod);

  var pasteNumeroCheque = historySheet.getRange(recapFirstEmptyRow, 6, 1, 1);
  pasteNumeroCheque.setValue(chequeNumber);

}

/**
* Update stock in products sheet
*/
function _updateStock(orderProducts, allProductsRange, allProductsValues) {
  // Update the products sheet based on the products in the invoice and return the total sum of the invoice
  let orderSum = 0.0;

  for (let i = 0; i < orderProducts.length; i++) {

    let productName = orderProducts[i]["product"].trim();
    let quantity = Number(orderProducts[i]["qty"]);


    // If there is no product name or quantity we ignore this invalid input.
    if (productName == "" || !(quantity > 0.0)) {
      break
    } else {

      let productIndex = allProductsValues.findIndex((productLine) => productLine[0].trim() == productName) + 1

      // if product index < 1 it means that the product was not found. We ignore it then.
      if (productIndex < 1) {
        break;
      }

      let unitPrice = Number(allProductsRange.getCell(productIndex, 10).getValue());

      orderSum += unitPrice * quantity;

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

  return orderSum;
}


function testProcessInvoice() {
  processOrder("laurie.besinet@gmail.com", "CB", [{ "product": "GRENADE FRUITS BIO PAYS LANDAIS KILO 806", "qty": 5.2 }], "718718718");
}

