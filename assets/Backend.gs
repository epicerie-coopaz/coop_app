const DATE_FORMAT = "yyyy-MM-dd'_'HH:mm:ss";

const ALL_PRODUCTS_SHEET_NAME = 'produits' // product sheet
const MEMBERS_SHEET_NAME = 'ImportMembres' // members sheet
const TEMPLATE_SHEET_NAME = 'Template' // members sheet
const HISTORY_SHEET_NAME = 'Recap' // members sheet

const RANGE_ALL_PRODUCTS = 'A2:N9999' //range des produits
const RANGE_MEMBERS = 'A1:B9999' //range des produits

const CARD_FEE_RATE = 0.00553;

const FOLDER_ID = "1N97mrKpTYFa9zOD2Ilp9-tLO26vOWOEQ"; // Folder id to save in a Drive folder.

const EMAIL_FROM = "guilhem.radonde@gmail.com"


/**
 * DO NOT USE FOR ANYTHING OTHER THAN TESTING !
 * 
 * Change the parameters to whatever is needed for testing
 */
function testProcessInvoice() {
  processOrder("laurie.besinet@gmail.com", "CB", [{ "product": "GRENADE FRUITS BIO PAYS LANDAIS KILO 806", "qty": 5.2 }], "718718718-3");
}

/**
 * Public
 * 
 * Process the invoice sent by the coopaz client
 * 
 * Parameters:
 *  String emailAddress: a valid email address Should be referenced in members sheet
 *  String paymentMethod: "CB", "virement" or "cheque"
 *  List<Product> orderProducts: List of product objects for the current order. 
 *    A product object should have this fields: {"product": "GRENADE FRUITS BIO PAYS LANDAIS KILO 806", "qty": 5.2}
 *  String chequeNumber: the cheque number. Can be set to "" if paymentMethod != "cheque"
 */
function processOrder(emailAddress, paymentMethod, orderProducts, chequeNumber) {
  Logger.log(`Starting script at ${Utilities.formatDate(new Date(), Session.getTimeZone(), DATE_FORMAT)}`);

  let date = Utilities.formatDate(new Date(), Session.getTimeZone(), DATE_FORMAT)

  emailAddress = emailAddress.trim();

  let ss = SpreadsheetApp.getActive();

  let templateSheet = ss.getSheetByName(TEMPLATE_SHEET_NAME);
  let historySheet = ss.getSheetByName(HISTORY_SHEET_NAME);
  let membersSheet = ss.getSheetByName(MEMBERS_SHEET_NAME);

  let membersEmailRange = membersSheet.getRange(RANGE_MEMBERS);
  let member = membersEmailRange.getValues().find((email) => email[1].trim() == emailAddress);
  let memberName = member[0];

  let sheetAllProducts = ss.getSheetByName(ALL_PRODUCTS_SHEET_NAME);
  let allProductsRange = sheetAllProducts.getRange(RANGE_ALL_PRODUCTS);
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


  let [orderAmount, cardFees, orderProductsWithTotal] = _updateStock(orderProducts, allProductsRange, allProductsValues, CARD_FEE_RATE, paymentMethod);

  Logger.log(`Updating stock done. orderAmount=${orderAmount}, cardFees=${cardFees}`);

  _addToHistory(date, historySheet, memberName, orderAmount, cardFees, paymentMethod, chequeNumber);

  Logger.log(`Add to history sheet done`);

  let invoiceTicket = _createInvoiceTicket(ss, templateSheet, date, memberName, orderProductsWithTotal, chequeNumber, paymentMethod, cardFees);

  Logger.log(`Invoice ticket created`);

  _sendEmail(invoiceTicket, emailAddress);

  Logger.log(`Email sent ! Finished at ${Utilities.formatDate(new Date(), Session.getTimeZone(), DATE_FORMAT)}`);
}

/**
 * Private
 * Create an invoice ticket in a dedicated sheet
 */
function _createInvoiceTicket(spreadSheet, templateSheet, date, clientName, orderProducts, chequeNumber, paymentMethod, cardFees) {

  let newSheetName = date + '_' + clientName;
  let newSheet = templateSheet.copyTo(spreadSheet).setName(newSheetName);

  let orderLines = orderProducts.map((p) => {
    return [p['product'], p['qty'], p['unitPrice'], p['total']]
  });

  for (let i = 0; i < orderLines.length; i++) {
    let orderLine = orderLines[i];
    let pasteData = newSheet.getRange(7 + i, 2, 1, 4);
    pasteData.setValues([orderLine]);
  }


  let pastePaiement = newSheet.getRange(46, 2, 1, 1);
  pastePaiement.setValue(paymentMethod);

  let pasteNumeroCheque = newSheet.getRange(47, 2, 1, 1);
  pasteNumeroCheque.setValue(chequeNumber);

  let pasteCardFees = newSheet.getRange(47, 5, 1, 1);
  pasteCardFees.setValue(cardFees);

  let pasteName = newSheet.getRange(4, 3, 1, 1);
  pasteName.setValue(clientName);

  let pasteDate = newSheet.getRange(2, 3, 1, 1);
  pasteDate.setValue(date);

  return newSheet;
}

/**
 * Private
 * Add to History sheet
 */
function _addToHistory(date, historySheet, memberName, orderAmount, fees, paymentMethod, chequeNumber) {

  let recapFirstEmptyRow = historySheet.getLastRow() + 1;

  historySheet.getRange(recapFirstEmptyRow, 1, 1, 1).setValue(date);

  let pasteNameOnly = historySheet.getRange(recapFirstEmptyRow, 2, 1, 1);
  pasteNameOnly.setValue(memberName);

  let pasteMontant = historySheet.getRange(recapFirstEmptyRow, 3, 1, 1);
  pasteMontant.setValue(orderAmount);

  let pasteFrais = historySheet.getRange(recapFirstEmptyRow, 4, 1, 1);
  pasteFrais.setValue(fees);

  let pasteRecaPaiement = historySheet.getRange(recapFirstEmptyRow, 5, 1, 1);
  pasteRecaPaiement.setValue(paymentMethod);

  let pasteNumeroCheque = historySheet.getRange(recapFirstEmptyRow, 6, 1, 1);
  pasteNumeroCheque.setValue(chequeNumber);

}

/**
 * Private
 * Update stock in products sheet
 * Return the total sum of the order and the bank fees if using a credit card
 */
function _updateStock(orderProducts, allProductsRange, allProductsValues, cardFeeRate, paymentMethod) {
  // Update the products sheet based on the products in the invoice and return the total sum of the invoice
  let orderSum = 0.0;
  let fees = 0.0;
  let orderProductsWithTotal = [];

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
      let total = unitPrice * quantity;

      orderSum += total;

      orderProductsWithTotal.push({
        'product': productName,
        'qty': quantity,
        'unitPrice': unitPrice,
        'total': total
      });

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

  if (paymentMethod == "CB") {
    fees = orderSum * cardFeeRate;
  }

  return [orderSum, fees, orderProductsWithTotal];
}

function _sendEmail(tempInvoiceSheet, emailAddress) {

  // SAved PDF destination
  let folder = DriveApp.getFolderById(FOLDER_ID);

  // URL à appeler pour récupérer une version PDF de la sheet
  const url = `https://docs.google.com/spreadsheets/d/${ss.getId()}/export?`;
  const exportOptions =
    'exportFormat=pdf&format=pdf' + // export as pdf / csv / xls / xlsx
    '&size=A4' + // paper size legal / letter / A4
    '&portrait=true' + // orientation, false for landscape
    '&fitw=true&source=false' + //labnol fit to page width, false for actual size
    '&sheetnames=false&printtitle=false' + // hide optional headers and footers
    '&pagenumbers=false&gridlines=false' + // hide page numbers and gridlines
    '&fzr=true' + // do not repeat row headers (frozen rows) on each page
    '&gid='; // the sheet's Id

  // le token d'authentification
  const token = ScriptApp.getOAuthToken();

  const clientSheetUrl = url + exportOptions + tempInvoiceSheet.getSheetId();

  SpreadsheetApp.flush();

  const sheetResponse = UrlFetchApp.fetch(clientSheetUrl, {
    headers: {
      Authorization: `Bearer ${token}`
    }
  });

  const pdf = sheetResponse.getBlob().setName(tempInvoiceSheet.getName() + '.pdf');

  // If allowed to send emails, send the email with the PDF attachment
  if (MailApp.getRemainingDailyQuota() > 0)
    GmailApp.sendEmail(emailAddress, 'Votre commande Coop Az', 'Veuillez trouver ci joint la facture de votre dernière commande', {
      attachments: [pdf], from: EMAIL_FROM
    });

  folder.createFile(pdf);

  ss.deleteSheet(tempInvoiceSheet);
}


