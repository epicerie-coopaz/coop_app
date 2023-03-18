const DATE_FORMAT = 'yyyy-MM-dd\'_\'HH:mm:ss';

const ALL_PRODUCTS_SHEET_NAME = 'produits' // product sheet
const MEMBERS_SHEET_NAME = 'ImportMembres' // members sheet
const TEMPLATE_SHEET_NAME = 'Template' // members sheet
const HISTORY_SHEET_NAME = 'Recap' // members sheet

const RANGE_ALL_PRODUCTS = 'A2:N9999' //range des produits
const RANGE_MEMBERS = 'A1:B9999' //range des produits

const CARD_FEE_RATE = 0.00553;

const FOLDER_ID = '1N97mrKpTYFa9zOD2Ilp9-tLO26vOWOEQ'; // Folder id to save in a Drive folder.

const EMAIL_FROM = 'guilhem.radonde@gmail.com';

const PAYMENT_METHOD_CARD = 'CB';
const PAYMENT_METHOD_TRANSFER = 'virement';
const PAYMENT_METHOD_CHEQUE = 'cheque';

class OrderItem {
  constructor(product, qty) {
    this.product = product;
    this.qty = qty;
  }
}


/**
 * DO NOT USE FOR ANYTHING OTHER THAN TESTING !
 * 
 * Change the parameters to whatever is needed for testing
 */
function testProcessInvoice() {
  processOrder('team.radinet@gmail.com', 'CB', [{ 'product': 'GRENADE FRUITS BIO PAYS LANDAIS KILO 806', 'qty': 5.2 }], '718718718-5');
}

/**
 * Public
 * 
 * Process the reception sent by the coopaz client
 * 
 * Parameters:
 *  List<Product> receptionProducts: List of product objects for the current reception. 
 *    A product object should have this fields: {'product': 'GRENADE FRUITS BIO PAYS LANDAIS KILO 806', 'qty': 5.2}
 *  String chequeNumber: the cheque number. Can be set to '' if paymentMethod != 'cheque'
 */
function processReception(receptionProducts) {
  Logger.log(`Starting script...`);
}

/**
 * Public
 * 
 * Process the invoice sent by the coopaz client
 * 
 *  @param {string[]} emailAddress a valid email address Should be referenced in members sheet
 *  @param {string[]} paymentMethod 'CB', 'virement' or 'cheque'
 *  @param {OrderItem[]} orderItems
 *  @param {string[]} info the cheque number or bank info. Can be set to ''.
 */
function processOrder(emailAddress, paymentMethod, orderItems, info) {
  Logger.log(`Starting script...`);

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
  if (emailAddress == '' || !emailAddress.includes('@') || memberName == undefined) {
    throw `Email address invalid: ${emailAddress}`;
  }
  if (paymentMethod != PAYMENT_METHOD_CARD && paymentMethod != PAYMENT_METHOD_TRANSFER && paymentMethod != PAYMENT_METHOD_CHEQUE) {
    throw `Payment method invalid: ${paymentMethod}`;
  }
  if (orderItems == undefined || orderItems == null || !(orderItems.length > 0)) {
    throw `Order product list invalid: ${orderItems}`;
  }

  let [orderAmount, cardFees, orderProductsWithTotal] = _updateStock(orderItems, allProductsRange, allProductsValues, CARD_FEE_RATE, paymentMethod);

  Logger.log(`Updating stock done. orderAmount=${orderAmount}, cardFees=${cardFees}`);

  _addToHistory(date, historySheet, memberName, orderAmount, cardFees, paymentMethod, info);

  Logger.log(`Add to history sheet done`);

  let invoiceTicket = _createInvoiceTicket(ss, templateSheet, date, memberName, orderProductsWithTotal, info, paymentMethod, cardFees);

  Logger.log(`Invoice ticket created`);

  _createPdfAndSendEmail(invoiceTicket, emailAddress);

  Logger.log(`Email sent !`);

  ss.deleteSheet(invoiceTicket);

  Logger.log(`Temp sheet deleted. Script finished`);
}

/**
 * Private
 * Create an invoice ticket in a dedicated sheet
 */
function _createInvoiceTicket(spreadSheet, templateSheet, date, clientName, orderProducts, info, paymentMethod, cardFees) {

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
  pasteNumeroCheque.setValue(info);

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
function _addToHistory(date, historySheet, memberName, orderAmount, fees, paymentMethod, info) {

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
  pasteNumeroCheque.setValue(info);

}

/**
 * Private
 * Update stock in products sheet
 * Return the total sum of the order and the bank fees if using a credit card
 * @param {OrderItem[]} orderItems
 * @param {string} allProductsRange
 * @param {string} allProductsValues
 * @param {string} cardFeeRate
 * @param {string} paymentMethod
 */
function _updateStock(orderItems, allProductsRange, allProductsValues, cardFeeRate, paymentMethod) {
  // Update the products sheet based on the products in the invoice and return the total sum of the invoice
  let orderSum = 0.0;
  let fees = 0.0;
  let orderProductsWithTotal = [];

  for (let i = 0; i < orderItems.length; i++) {

    let productName = orderItems[i].product.trim();
    let quantity = Number(orderItems[i].qty);


    // If there is no product name or quantity we ignore this invalid input.
    if (productName == '' || quantity <= 0.0){
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

  if (paymentMethod == PAYMENT_METHOD_CARD) {
    fees = orderSum * cardFeeRate;
  }

  return [orderSum, fees, orderProductsWithTotal];
}

function _createPdfAndSendEmail(tempInvoiceSheet, emailAddress) {

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
}


