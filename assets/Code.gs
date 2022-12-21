var MainSheet = 'main' //page main
var RecapSheet = 'Recap' //page du recap pour la compta
var RecepSheet = 'Reception' //page réception des produits
var range = 'A1:B';
var rangeReception = 'B7:H7';

var ss = SpreadsheetApp.getActive();

var sheetTemplate = ss.getSheetByName('Template');
var sheetCotisation = ss.getSheetByName('cotisation');
var sheetReception = ss.getSheetByName('Reception');
var sheetBL = ss.getSheetByName('bon de livraison');
var sheetRecap = ss.getSheetByName('recap');
var sheetRecapImpaye = ss.getSheetByName('RecapImpayé');
var sheetFournisseur = ss.getSheetByName('fournisseurs');
var sheetVentes = ss.getSheetByName('VentesHebdo');
var sheetRecapReception = ss.getSheetByName('RecapReception');
var sheetRecapInventaire = ss.getSheetByName('RecapInventaire');
var sheetProduits = ss.getSheetByName('produits');
var sheetInventaire = ss.getSheetByName('Inventaire');
var sheetRecapBL = ss.getSheetByName('recapBL');
var sheetfactureFournisseurs = ss.getSheetByName('factureFournisseurs');
var sheetReleveDeCompte = ss.getSheetByName('ReleveDeCompte');
var sheetDettesFournisseurs = ss.getSheetByName('dettesFournisseurs');
var sheetCreancesClients = ss.getSheetByName('creancesClients');
var sheetRecapInventaire = ss.getSheetByName('RecapInventaire');
var sheetEtiquette = ss.getSheetByName('PrintEtiquette');

/**
* Verifier qu'il y a bien un nom et un mode de paiement renseigné avant de valider
* Retourne true si erreur, false si ça s'est bien passé
*/
function _isInputsValid() {
  var clientRow = SpreadsheetApp.getActiveSheet().getRange('F11').getValue();
  var PaimentModeRow = SpreadsheetApp.getActiveSheet().getRange('G17').getValue();

  if (clientRow == "" || PaimentModeRow == "") {
    SpreadsheetApp.getUi().alert('Renseigner un nom ET un mode de paiement');
    return true;
  }
  return false;
}


/////// VALIDER UNE VENTE /////////////////////////////////
function validerCaisse01() {
  validerCaisse('01')
}
function validerCaisse02() {
  validerCaisse('02')
}

function validerCaisseExternal() {
  var totalrange = 'A2:D37' //range de la facture
  var totalsheet = 'facture' + numCaisse //page de la facture
  var sourcerange = 'A2:N9999' //range des produits
  var sourcesheet = 'produits' //page des produits

  if (_isInputsValid()) {
    return; // stoppe la validation s'il manque un nom ou un mode de paiement
  }

  var newSheet = copySheet(date, numCaisse); //copier la facture dans une page au nom du client
  _sendEmail(newSheet); //envoyer le mail
  valid(totalsheet, totalrange, sourcesheet, sourcerange)
  reinitialiser(numCaisse); // reinitialiser la facture
}

function validerCaisse(numCaisse) {

  var date = Utilities.formatDate(new Date(), Session.getTimeZone(), "yyyy-MM-dd'_'HH:mm:ss")

  //SpreadsheetApp.setActiveSheet(SpreadsheetApp.getActive().getSheetByName("facture" + numCaisse));

  var totalrange = 'A2:D37' //range de la facture
  var totalsheet = 'facture' + numCaisse //page de la facture
  var sourcerange = 'A2:N9999' //range des produits
  var sourcesheet = 'produits' //page des produits

  if (_isInputsValid()) {
    return; // stoppe la validation s'il manque un nom ou un mode de paiement
  }

  var newSheet = copySheet(date, numCaisse); //copier la facture dans une page au nom du client
  _sendEmail(newSheet); //envoyer le mail
  valid(totalsheet, totalrange, sourcesheet, sourcerange)
  reinitialiser(numCaisse); // reinitialiser la facture
}


/**
* creer une copie du template au nom du client
*/
function copySheet(date, numCaisse) {
  var ss = SpreadsheetApp.getActive();

  // Copier les données de la page fature
  var copyData = ss.getRange("A1:D37").getValues();
  var copyPaiement = ss.getRange("G17:G17").getValues();
  var copyNumeroCheque = ss.getRange("G18:G18").getValues();
  var formInputSheet = ss.getSheetByName('facture' + numCaisse);  //feuille principale
  var templateSheet = ss.getSheetByName('Template');  //feuille du template
  var recapSheet = ss.getSheetByName('Recap');  //feuille du recap
  var recap = "Recap";
  // copier le nom et adresse mail de la page facture
  var copyName = ss.getRange("F11:F12").getValues();
  var copyDateOnly = ss.getRange("F15:F15").getValues();
  var copyNameOnly = ss.getRange("F11:F11").getValues();
  var copyMontant = ss.getRange("G11:G11").getValues();
  var copyFrais = ss.getRange("D39:D39").getValues();
  var copyAvoir = ss.getRange("D40:D40").getValues();


  var rowClient = 'F11';
  var rowEmail = 'F12';
  var rowDate = 'F15';

  /////*Ajouter la commande dans la feuille recap*/////
  var recapFirstEmptyRow = recapSheet.getLastRow() + 1;

  var pasteDateOnly = ss.getSheetByName(recap).getRange(recapFirstEmptyRow, 1, 1, 1);
  pasteDateOnly.setValues(copyDateOnly);

  var pasteNameOnly = ss.getSheetByName(recap).getRange(recapFirstEmptyRow, 2, 1, 1);
  pasteNameOnly.setValues(copyNameOnly);

  var pasteMontant = ss.getSheetByName(recap).getRange(recapFirstEmptyRow, 3, 1, 1);
  pasteMontant.setValues(copyMontant);

  var pasteFrais = ss.getSheetByName(recap).getRange(recapFirstEmptyRow, 4, 1, 1);
  pasteFrais.setValues(copyFrais);

  var pasteRecaPaiement = ss.getSheetByName(recap).getRange(recapFirstEmptyRow, 5, 1, 1);
  pasteRecaPaiement.setValues(copyPaiement);

  var pasteNumeroCheque = ss.getSheetByName(recap).getRange(recapFirstEmptyRow, 6, 1, 1);
  pasteNumeroCheque.setValues(copyNumeroCheque);

  /* Coller les données dans la feuille template*/

  var clientName = formInputSheet.getRange(rowClient).getValue();
  var newSheetName = date + '_' + clientName;
  var newSheet = templateSheet.copyTo(ss).setName(newSheetName);

  newSheet.showSheet();

  ///*coller les données de la page facture vers la page au nom du client *///

  var pasteData = newSheet.getRange(6, 2, 37, 4);
  pasteData.setValues(copyData);

  var pastePaiement = newSheet.getRange(46, 2, 1, 1);
  pastePaiement.setValues(copyPaiement);

  var pasteNumeroCheque = newSheet.getRange(47, 2, 1, 1);
  pasteNumeroCheque.setValues(copyNumeroCheque);

  var pasteName = newSheet.getRange(4, 3, 2, 1);
  pasteName.setValues(copyName);

  var pasteAvoir = newSheet.getRange(47, 5, 1, 1);
  pasteAvoir.setValues(copyAvoir);

  var pasteDate = newSheet.getRange(2, 3, 1, 1);
  pasteDate.setValues(copyDateOnly);

  return newSheet;

}



// // Envoyer mail
function _sendEmail(newSheet) {

  // var ss = SpreadsheetApp.getActive();

  // SAved PDF destination
  var folderID = "1hsKFXi6M11dTUV69QHOgf9R4NmoSSQtT"; // Folder id to save in a Drive folder.
  var folder = DriveApp.getFolderById(folderID);

  // var rowClient = 'C4';
  var rowEmail = 'C5';
  // var rowDate = 'C2';


  Logger.log(newSheet.getName())

  // var clientName = getClientSheet.getRange(rowClient).getValue();
  var emailAddress = newSheet.getRange('C5').getValue();
  // var date = Utilities.formatDate(new Date(), Session.getTimeZone(), "yyyy-MM-dd'_'HH:mm:ss'_'")


  // URL à appeler pour récupérer une version PDF de la sheet
  const url = 'https://docs.google.com/spreadsheets/d/SS_ID/export?'.replace('SS_ID', ss.getId());
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

  const clientSheetUrl = url + exportOptions + newSheet.getSheetId();
  Logger.log(" client sheet url " + clientSheetUrl);


  SpreadsheetApp.flush();

  const sheetResponse = UrlFetchApp.fetch(clientSheetUrl, {
    headers: {
      Authorization: 'Bearer ${token}'
    }
  });


  const pdf = sheetResponse.getBlob().setName(newSheet.getName() + '.pdf');


  // If allowed to send emails, send the email with the PDF attachment
  if (MailApp.getRemainingDailyQuota() > 0)
    GmailApp.sendEmail(emailAddress, 'Votre commande Coop Az', 'Veuillez trouver ci joint la facture de votre dernière commande', {
      attachments: [pdf], from: "epiceriecoopaz@gmail.com"
    });


  //  var destSpreadsheet = SpreadsheetApp.open(DriveApp.getFileById(ss.getId()).makeCopy("tmp_convert_to_pdf", folder))



  //  var theBlob = destSpreadsheet.getBlob().getAs('application/pdf').setName(date+clientName);
  folder.createFile(pdf);
  //
  //  DriveApp.getFileById(destSpreadsheet.getId()).setTrashed(true);

  var deleteSheet = ss.deleteSheet(newSheet);
}



//Incrémenter pour le stock
function valid(tsheet, trange, ssheet, srange) {
  var ss = SpreadsheetApp.getActive();
  var ts = ss.getSheetByName(tsheet);
  var tr = ts.getRange(trange);

  var ssh = ss.getSheetByName(ssheet);
  var sr = ssh.getRange(srange);

  var tvalues = tr.getValues();
  for (var trow = 0; trow < tvalues.length; trow++) {
    if (tvalues[trow][0] == "") {
      break
    } else {
      tproduct = tvalues[trow][0]
      tquantity = tvalues[trow][1]
      //Browser.msgBox('produit=' + tproduct + ' quantite=' + tquantity)
      var srow = findCell(tproduct, ssheet, srange);
      //Browser.msgBox('Row in sourcetab=' + srow)
      _updateSourceCell(ssheet, srange, srow, 12, tquantity)
      _updateSourceCell(ssheet, srange, srow, 11, tquantity)
    }
  }
}
//rechercher la celulle dans la liste des produits
function findCell(containingValue, sheetname, range) {
  var lv_cell
  var ss = SpreadsheetApp.getActiveSpreadsheet();
  var sheet = ss.getSheetByName(sheetname);
  var r = sheet.getRange(range);
  //var dataRange = sheet.getDataRange();
  var values = r.getValues();
  for (var i = 0; i < values.length; i++) {
    var row = "";
    if (values[i][0] == containingValue) {
      row = values[i][0];
      //Browser.msgBox(i)
      break
    }
  }
  if (row != "") {
    lv_cell = i + 1
  } else {
    lv_cell = ""
  }
  return lv_cell
}
//Function pour incrementer quand un produit est vendu dans les ventes et décrémenter dans le stock actuel
function _updateSourceCell(sheet, range, row, col, val) {
  var ss = SpreadsheetApp.getActive();
  var ts = ss.getSheetByName(sheet);
  var r = ts.getRange(range)
  var CellQuantity = r.getCell(row, col).getValue();
  if (col == 12) {
    if (CellQuantity > 0) {
      r.getCell(row, col).setValue(CellQuantity - val);
    }
  }
  if (col == 11) {
    r.getCell(row, col).setValue(CellQuantity + val);
  }

}
//reinitialiser la facture
function reinitialiser(numCaisse) {
  var ss = SpreadsheetApp.getActive();
  var sheet = ss.getSheetByName('facture' + numCaisse);
  var rangesAddressesList = ['A2:B31', 'A32:C37', 'F11', 'G17', 'G18'];
  reinit(sheet, rangesAddressesList);
}



///////// FAIRE UNE RECEPTION //////////////////
function validerReception() {
  var receptionrange = 'B7:Z7' //range de la facture
  var receptionsheet = 'Reception' //page de la facture
  var sourcerange = 'A2:Z9999' //range des produits
  var sourcesheet = 'produits' //page des produits

  copyReception();
  validReception(receptionsheet, receptionrange, sourcesheet, sourcerange)
  validReceptionPrice(receptionsheet, receptionrange, sourcesheet, sourcerange)
  validReceptionBL(receptionsheet, receptionrange, sourcesheet, sourcerange)
  reinitialiserReception(); // reinitialiser la facture
}

// ajouter une ligne dans la page recap des réceptions
function copyReception() {
  var ss = SpreadsheetApp.getActive();

  // Copier les données de la page réception
  var copyProdName = ss.getRange("B4:B4").getValues();
  var copyName = ss.getRange("B7:B7").getValues();
  var copyPriceActuel = ss.getRange("C7:C7").getValues();
  var copyPrice = ss.getRange("M7:M7").getValues();
  var copyStockActuel = ss.getRange("D7:D7").getValues();
  var copyStock = ss.getRange("N7:N7").getValues();
  var copyReassort = ss.getRange("G7:G7").getValues();
  var copyDate = ss.getRange("H1:H1").getValues();
  var formInputSheet = ss.getSheetByName('reception');  //feuille principale
  var recapSheet = ss.getSheetByName('RecapReception');  //feuille du recap
  var RecapReception = "RecapReception";
  // copier le nom et adresse mail de la page facture

  //Ajouter la commande dans la feuille recap
  var recapFirstEmptyRow = recapSheet.getLastRow() + 1;


  var pasteDate = recapSheet.getRange(recapFirstEmptyRow, 1, 1, 1);
  pasteDate.setValues(copyDate);
  var pasteName = recapSheet.getRange(recapFirstEmptyRow, 2, 1, 1);
  pasteName.setValues(copyProdName);
  var pasteName = recapSheet.getRange(recapFirstEmptyRow, 3, 1, 1);
  pasteName.setValues(copyName);
  var pastePriceActuel = recapSheet.getRange(recapFirstEmptyRow, 4, 1, 1);
  pastePriceActuel.setValues(copyPriceActuel);
  var pastePrice = recapSheet.getRange(recapFirstEmptyRow, 5, 1, 1);
  pastePrice.setValues(copyPrice);
  var pasteStockActuel = recapSheet.getRange(recapFirstEmptyRow, 6, 1, 1);
  pasteStockActuel.setValues(copyStockActuel);
  var pasteStock = recapSheet.getRange(recapFirstEmptyRow, 7, 1, 1);
  pasteStock.setValues(copyStock);
  var pasteReassort = recapSheet.getRange(recapFirstEmptyRow, 8, 1, 1);
  pasteReassort.setValues(copyReassort);
}




//Incrémenter pour modifier le stock
function validReception(tsheet, trange, ssheet, srange) {
  var ss = SpreadsheetApp.getActive();
  var ts = ss.getSheetByName(tsheet);
  var tr = ts.getRange(trange);

  var ssh = ss.getSheetByName(ssheet);
  var sr = ssh.getRange(srange);

  var tvalues = tr.getValues();


  /*
      var productRange = activeSheet.getRange(3, 1, 999,1).getValues();
      var lv_cellRange = productRange.map(function(r) {return r[0];}) // t
  
      // fair eun for() dans trange pour boucler sur tous les produits
      var lv_cell = lv_cellRange.lastIndexOf(tproduct); // la ligne de l'onglet produit correspondant au produit en cours
      // faire l'update de la valeur
      // fin du for
  
  */

  for (var trow = 0; trow < tvalues.length; trow++) {
    if (tvalues[trow][0] == "") {
      break
    } else {
      tproduct = tvalues[trow][0]
      tquantity = tvalues[trow][7]
      //Browser.msgBox('produit=' + tproduct + ' quantite=' + tquantity)
      var srow = findCell(tproduct, ssheet, srange);
      //Browser.msgBox('Row in sourcetab=' + srow)
      updateSourceCellReception(ssheet, srange, srow, 12, tquantity)
    }
  }
}
//Incrémenter pour modifier le prix
function validReceptionPrice(tsheet, trange, ssheet, srange) {
  var ss = SpreadsheetApp.getActive();
  var ts = ss.getSheetByName(tsheet);
  var tr = ts.getRange(trange);

  var ssh = ss.getSheetByName(ssheet);
  var sr = ssh.getRange(srange);

  var tvalues = tr.getValues();
  for (var trow = 0; trow < tvalues.length; trow++) {
    if (tvalues[trow][0] == "") {
      break
    } else {
      tproduct = tvalues[trow][0]
      tquantity = tvalues[trow][11]
      //Browser.msgBox('produit=' + tproduct + ' quantite=' + tquantity)
      var srow = findCell(tproduct, ssheet, srange);
      //Browser.msgBox('Row in sourcetab=' + srow)
      updateSourceCellPrice(ssheet, srange, srow, 10, tquantity)
    }
  }
}
//Incrémenter pour modifier le numéro de BL
function validReceptionBL(tsheet, trange, ssheet, srange) {
  var ss = SpreadsheetApp.getActive();
  var ts = ss.getSheetByName(tsheet);
  var tr = ts.getRange(trange);

  var ssh = ss.getSheetByName(ssheet);
  var sr = ssh.getRange(srange);

  var tvalues = tr.getValues();
  for (var trow = 0; trow < tvalues.length; trow++) {
    if (tvalues[trow][0] == "") {
      break
    } else {
      tproduct = tvalues[trow][0]
      tquantity = tvalues[trow][8]
      // Browser.msgBox('produit=' + tproduct + ' quantite=' + tquantity)
      var srow = findCell(tproduct, ssheet, srange);
      //Browser.msgBox('Row in sourcetab=' + srow)
      updateSourceCellBL(ssheet, srange, srow, 19, tquantity)
    }
  }
}
function updateSourceCellReception(sheet, rangeReception, row, col, val) {
  var ss = SpreadsheetApp.getActive();
  var ts = ss.getSheetByName(sheet);
  var r = ts.getRange(rangeReception)
  var CellQuantity = r.getCell(row, col).getValue();
  if (col == 12) {
    r.getCell(row, col).setValue(val);
  }
}
function updateSourceCellPrice(sheet, rangeReception, row, col, val) {
  var ss = SpreadsheetApp.getActive();
  var ts = ss.getSheetByName(sheet);
  var r = ts.getRange(rangeReception)
  var CellQuantity = r.getCell(row, col).getValue();
  if (col == 10) {
    r.getCell(row, col).setValue(val);
  }

}
function updateSourceCellBL(sheet, rangeReception, row, col, val) {
  var ss = SpreadsheetApp.getActive();
  var ts = ss.getSheetByName(sheet);
  var r = ts.getRange(rangeReception)
  var CellQuantity = r.getCell(row, col).getValue();
  if (col == 19) {
    r.getCell(row, col).setValue(val);
  }

}
// Pop up pour créer un nouveau produit
//ouvrir une pop up
function showFormInModalDialog() {
  var form = HtmlService.createTemplateFromFile('Index').evaluate();
  SpreadsheetApp.getUi().showModalDialog(form, "Nouveau produit");
}
//transférer les données de la pop up dans la page produit
function processForm(formObject) {

  var ss = SpreadsheetApp.getActive();
  var produitsSheet = ss.getSheetByName('produits');  //feuille des produits
  var receptionSheet = ss.getSheetByName('Reception');  //feuille des produits  
  var recapSheet = ss.getSheetByName('RecapReception');  //feuille du recap

  var copyProducteur = receptionSheet.getRange("B4:B4").getValues();

  var sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName('produits');
  sheet.appendRow([formObject.empty,
  formObject.Nom_du_produit,
  formObject.Famille,
  formObject.empty,
  formObject.Unite,
  formObject.CodeBar,
  formObject.empty,
  formObject.empty,
  formObject.empty,
  formObject.Price,
  formObject.empty,
  formObject.Stock,
  formObject.empty,
  formObject.empty,
  formObject.empty,
  formObject.empty,
  formObject.empty,
  formObject.empty,
  formObject.BL,
    //Add your new field names here
  ]);

  var produitsFirstEmptyRow = produitsSheet.getLastRow();

  var pasteProducteurOnly = produitsSheet.getRange(produitsFirstEmptyRow, 4, 1, 1);
  pasteProducteurOnly.setValues(copyProducteur);


  // Copier les données du dernier produit de la page produit
  var copyName = produitsSheet.getRange(produitsFirstEmptyRow, 1, 1, 1).getValues();
  var copyPrice = produitsSheet.getRange(produitsFirstEmptyRow, 10, 1, 1).getValues();
  var copyStock = produitsSheet.getRange(produitsFirstEmptyRow, 12, 1, 1).getValues();
  var copyDate = receptionSheet.getRange("H1:H1").getValues();
  var copyProd = receptionSheet.getRange("B4:B4").getValues();


  // copier les informations du dernier produit créé sur la page RecaReception

  var recapFirstEmptyRow = recapSheet.getLastRow() + 1;

  var pasteDate = recapSheet.getRange(recapFirstEmptyRow, 1, 1, 1);
  pasteDate.setValues(copyDate);
  var pasteName = recapSheet.getRange(recapFirstEmptyRow, 2, 1, 1);
  pasteName.setValues(copyProd);
  var pasteName = recapSheet.getRange(recapFirstEmptyRow, 3, 1, 1);
  pasteName.setValues(copyName);
  var pastePrice = recapSheet.getRange(recapFirstEmptyRow, 5, 1, 1);
  pastePrice.setValues(copyPrice);
  var pasteStock = recapSheet.getRange(recapFirstEmptyRow, 8, 1, 1);
  pasteStock.setValues(copyStock);

}
//INCLUDE HTML PARTS, EG. JAVASCRIPT, CSS, OTHER HTML FILES
function include(filename) {
  return HtmlService.createHtmlOutputFromFile(filename).getContent();
}
//reinitialiser la page de réception
function reinitialiserReception() {
  var ss = SpreadsheetApp.getActive();
  var sheet = ss.getSheetByName('Reception');
  var rangesAddressesList = ['B7', 'E7', 'F7', 'G7', 'H7'];
  reinit(sheet, rangesAddressesList);
}


function HideRecapRecetion() {
  var ss = SpreadsheetApp.getActive();
  var sheet = ss.getSheetByName('RecapReception');
  sheet.hideSheet();
}



///////// FAIRE UN INVENTAIRE //////////////////
function validerInventaireOLD() {
  var inventairerange = 'B7:I7' //range de la facture
  var inventairesheet = 'Inventaire' //page de la facture
  var sourcerange = 'A2:Z9999' //range des produits
  var sourcesheet = 'produits' //page des produits
  var producteurrange = 'B4:C4' //range de la facture

  copyInventaireOLD();
  validInventaire(inventairesheet, inventairerange, sourcesheet, sourcerange)
  reinitialiserInventaire(); // reinitialiser la facture

}
//Incrémenter pour modifier le stock
function validInventaire(tsheet, trange, ssheet, srange) {
  var ss = SpreadsheetApp.getActive();
  var ts = ss.getSheetByName(tsheet);
  var tr = ts.getRange(trange);

  var ssh = ss.getSheetByName(ssheet);
  var sr = ssh.getRange(srange);

  var tvalues = tr.getValues();
  for (var trow = 0; trow < tvalues.length; trow++) {
    if (tvalues[trow][0] == "") {
      break
    } else {
      tproduct = tvalues[trow][0]
      tquantity = tvalues[trow][2]
      //Browser.msgBox('produit=' + tproduct + ' quantite=' + tquantity)
      var srow = findCell(tproduct, ssheet, srange);
      //Browser.msgBox('Row in sourcetab=' + srow)
      updateSourceCellInventaire(ssheet, srange, srow, 12, tquantity)
    }
  }
}

function updateSourceCellInventaire(sheet, rangeInventaire, row, col, val) {
  var ss = SpreadsheetApp.getActive();
  var ts = ss.getSheetByName(sheet);
  var r = ts.getRange(rangeInventaire)
  var CellQuantity = r.getCell(row, col).getValue();
  if (col == 12) {
    r.getCell(row, col).setValue(val);
  }
}

// ajouter une ligne dans la page recap des réceptions
function copyInventaire() {
  var ss = SpreadsheetApp.getActive();

  // Copier les données de la page réception
  var copyName = ss.getRange("B7:B7").getValues();
  var copyStockActuel = ss.getRange("C7:C7").getValues();
  var copyStockMisAJour = ss.getRange("D7:D7").getValues();
  var copyDate = ss.getRange("H1:H1").getValues();
  var formInputSheet = ss.getSheetByName('Inventaire');  //feuille principale
  var recapSheet = ss.getSheetByName('RecapInventaire');  //feuille du recap
  var RecapInventaire = "RecapInventaire";
  // copier le nom et adresse mail de la page facture

  //Ajouter la commande dans la feuille recap

  var recapFirstEmptyRow = recapSheet.getLastRow() + 1;

  var pasteDate = ss.getSheetByName(RecapInventaire).getRange(recapFirstEmptyRow, 1, 1, 1);
  pasteDate.setValues(copyDate);
  var pasteName = ss.getSheetByName(RecapInventaire).getRange(recapFirstEmptyRow, 2, 1, 1);
  pasteName.setValues(copyName);
  var pastePriceActuel = ss.getSheetByName(RecapInventaire).getRange(recapFirstEmptyRow, 3, 1, 1);
  pastePriceActuel.setValues(copyStockActuel);
  var pastePrice = ss.getSheetByName(RecapInventaire).getRange(recapFirstEmptyRow, 4, 1, 1);
  pastePrice.setValues(copyStockMisAJour);

}

//reinitialiser la page d'inventaire'
function reinitialiserInventaire() {
  var ss = SpreadsheetApp.getActive();
  var sheet = ss.getSheetByName('Inventaire');
  var rangesAddressesList = ['B7', 'D7'];
  reinit(sheet, rangesAddressesList);
}
//reinitialiser la colonne des stocks dans la page produits
// function reinitialiserStock() {
//   var ss = SpreadsheetApp.getActive();
//   var sheet = ss.getSheetByName('produits');
//   var rangesAddressesList = ['L3:L10'];
//   reinit(sheet, rangesAddressesList);
// }

function reinitStock() {
  var producteurName = ss.getRange('B4').getValue();
  var sheetProduits = ss.getSheetByName('produits');
  var data = sheetProduits.getDataRange().getValues();
  for (var i = 0; i < data.length; i++) {
    if (data[i][3] == producteurName) {
      sheetProduits.getRange(i + 1, 12).setValue(0);
    }
  }
}

////// FAIRE UN INVENTAIRE V2 ////////////

function validerInventaire() {

  var date = Utilities.formatDate(new Date(), Session.getTimeZone(), "yyyy-MM-dd'_'HH:mm:ss")

  var totalrange = 'A3:B10000' //range de l'inventaire
  var totalsheet = 'Inventaire' //page de l'inventaire
  var sourcerange = 'A3:N10000' //range des produits
  var sourcesheet = 'produits' //page des produits


  ReplaceEmptyCell()
  validInventaire(totalsheet, totalrange, sourcesheet, sourcerange)
  saveInventaire()
}


function ReplaceEmptyCell() {
  var sheet = SpreadsheetApp.getActiveSpreadsheet().getActiveSheet();
  var colToZero = 2;

  var data = sheet.getRange(1, colToZero, sheet.getMaxRows()).getValues();

  var blank = data.map(testBlank); // this returns an array of true or false
  for (var i = 0; i < data.length; i++) {
    if (blank[i]) {
      data[i] = ["0"];
    }
  }
  sheet.getRange(1, colToZero, sheet.getMaxRows()).setValues(data);
}

function testBlank(arg) {
  return arg == "";
}



//Valider l'invetaire, copier le nouveau stock
function validInventaire(tsheet, trange, ssheet, srange) {
  var ss = SpreadsheetApp.getActive();
  var ts = ss.getSheetByName(tsheet);
  var tr = ts.getRange(trange);
  var ssh = ss.getSheetByName(ssheet);
  var sr = ssh.getRange(srange);

  var tvalues = tr.getValues();

  var activeSheet = ss.getSheetByName(ssheet);
  var productRange = activeSheet.getRange(3, 1, 9999, 1).getValues();
  var lv_cellRange = productRange.map(function (r) { return r[0]; }) // tableau avec tous les produits

  for (var trow = 0; trow < tvalues.length; trow++) {
    if (tvalues[trow][0] == "") {
      break
    } else {
      tproduct = tvalues[trow][0]
      tquantity = tvalues[trow][1]
      var lv_cell = lv_cellRange.lastIndexOf(tproduct); // la ligne de l'onglet produit correspondant au produit en cours
      updateSourceCellInventaire02(ssheet, srange, lv_cell, tquantity)
    }
  }
}
//Function pour coller le nouveau stock
function updateSourceCellInventaire02(sheet, range, row, val) {
  var ss = SpreadsheetApp.getActive();
  var ts = ss.getSheetByName(sheet);
  var r = ts.getRange(range)
  r.getCell(row + 1, 12).setValue(val);

}


function saveInventaire() {
  copyInventaire();
  reinitialiserInventaire2();
}

// Copier les données de l'inventaire 
function copyInventaire() {
  var ss = SpreadsheetApp.getActive();
  var produitsSheet = ss.getSheetByName('produits');
  var VentesSheet = ss.getSheetByName('HistoriqueInventaires');

  var VenteFirstEmptyCol = ss.getSheetByName('HistoriqueInventaires').getLastColumn() + 1;

  var copyVentes = ss.getSheetByName('produits').getRange("L2:L10000").getValues();
  var pasteVentes = ss.getSheetByName('HistoriqueInventaires').getRange(1, VenteFirstEmptyCol, 9999, 1);
  pasteVentes.setValues(copyVentes);
}

//reinitialiser l'inventaire'
function reinitialiserInventaire2() {
  var ss = SpreadsheetApp.getActive();
  var sheet = ss.getSheetByName('Inventaire');
  var rangesAddressesList = ['B2:B10000'];
  reinit(sheet, rangesAddressesList);
}




////// Sauvegarde des ventes toutes les semaines/////////////////////

function saveVentes() {
  copyVentes();
  reinitialiserVentes();
}

// Copier les données des ventes de la semaine depuis la page produits vers la page ventesHebdo
function copyVentes() {
  var ss = SpreadsheetApp.getActive();
  var produitsSheet = ss.getSheetByName('produits');
  var VentesSheet = ss.getSheetByName('VentesHebdo');

  var VenteFirstEmptyCol = ss.getSheetByName('VentesHebdo').getLastColumn() + 1;

  var copyVentes = ss.getSheetByName('produits').getRange("K2:K1000").getValues();
  var pasteVentes = ss.getSheetByName('VentesHebdo').getRange(1, VenteFirstEmptyCol, 999, 1);
  pasteVentes.setValues(copyVentes);
}


// Réinitialiser la colonne des ventes dans la page produit
function reinitialiserVentes() {
  var ss = SpreadsheetApp.getActive();
  var sheet = ss.getSheetByName('produits');
  var rangesAddressesList = ['K3:K1000'];
  reinit(sheet, rangesAddressesList);
}



// // IMPRIMER ETIQUETTE
function PrintTag() {

  // var ss = SpreadsheetApp.getActive();

  // SAved PDF destination
  var folderID = "1mLeAgMuElyjTk4YeYOnfQ8BHfVpcnuI_"; // Folder id to save in a Drive folder.
  var folder = DriveApp.getFolderById(folderID)
    ;

  // var rowClient = 'C4';
  // var rowEmail = 'C5';
  var rowDate = 'G1';



  // Logger.log(newSheet.getName())

  // var clientName = getClientSheet.getRange(rowClient).getValue();
  // var emailAddress = newSheet.getRange('C5').getValue();
  var date = Utilities.formatDate(new Date(), Session.getTimeZone(), "yyyy-MM-dd'_'HH:mm:ss'_'")





  // URL à appeler pour récupérer une version PDF de la sheet
  const url = 'https://docs.google.com/spreadsheets/d/SS_ID/export?'.replace('SS_ID', ss.getId());
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

  const clientSheetUrl = url + exportOptions + sheetEtiquette.getSheetId();
  Logger.log(" client sheet url " + clientSheetUrl);


  SpreadsheetApp.flush();

  const sheetResponse = UrlFetchApp.fetch(clientSheetUrl, {
    headers: {
      Authorization: 'Bearer ${token}'
    }
  });


  const pdf = sheetResponse.getBlob().setName(date + 'Etiquette' + '.pdf');


  folder.createFile(pdf);


}



////// UI ///////////////////////////////////////
function reinit(sheet, rangesAddressesList) {
  sheet.getRangeList(rangesAddressesList).clearContent();
}

//Remove All Empty Rows in the Entire Workbook
function removeEmptyRows() {
  var ss = SpreadsheetApp.getActive();
  var allsheets = ss.getSheets();
  for (var s in allsheets) {
    var sheet = allsheets[s]
    var maxRows = sheet.getMaxRows();
    var lastRow = sheet.getLastRow();
    if (maxRows - lastRow != 0) {
      sheet.deleteRows(lastRow + 1, maxRows - lastRow);
    }
  }
}