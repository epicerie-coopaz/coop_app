function doGet() {
  return HtmlService.createTemplateFromFile('SalesInterface')
    .evaluate();
};
/*
function doGet() {
  var html = HtmlService.createHtmlOutputFromFile('SalesInterface')
                         // Important pour l'affichage responsive
  return html;
}
*/
function include(filename) {
  return HtmlService.createHtmlOutputFromFile(filename)
  .getContent();
};

function getProducts() {
  const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName('produits');
  const data = sheet.getDataRange().getValues();
  const products = data.map((row, index) => {
    if (index === 0) return null; // Ignorer l'en-tête
      // Vérifier si la date est présente dans une colonne (par exemple, la colonne L, soit index 11)
    const formattedDate = row[11] instanceof Date ? Utilities.formatDate(row[11], Session.getScriptTimeZone(), 'yyyy-MM-dd') : null;

    return {
      name: row[0],     // Nom du produit
      price: row[7],    // Prix unitaire (colonne H)
      stock: row[8],     // Stock actuel (colonne I)
      stockDate : formattedDate  // Date de l'adhérent, formatée si elle existe
    };
  }).filter(Boolean); // Supprimer les entrées null
  return products;
}
function getAdherents() {
  const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName('adherents');
  const data = sheet.getDataRange().getValues();
  const adherents = data.map((row, index) => {
    if (index === 0) return null; // Ignorer l'en-tête
    return {
      name: row[0],   // Nom de l'adhérent
      email: row[1]   // Email de l'adhérent
    };
  }).filter(Boolean); // Supprimer les entrées null
  return adherents;
}
function getAdherentsWithCotisation() {
  const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName('adherents'); // Change le nom de l'onglet si nécessaire
  const data = sheet.getDataRange().getValues();
  const adherents = data.map(row => {
    return {
      name: row[0], // Assumes que le nom est en colonne A
      email: row[1], // Assumes que l'email est en colonne B
      cotisation: row[3] // Assumes que l'état de cotisation est en colonne C
    };
  });
  return adherents;
}
function saveSale(adherent, paymentMethod, total, dateTime, purchases) {
  Logger.log("Début de la sauvegarde de la vente");
    Logger.log(`Adhérent: ${adherent}, Méthode de paiement: ${paymentMethod}, Total: ${total}`);
  const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName('produits');
  purchases.forEach(purchase => {
    const productName = purchase.productName;
    let quantitySold = parseFloat(purchase.quantity); // S'assurer que la quantité est un nombre décimal
    quantitySold = isNaN(quantitySold) ? 0 : quantitySold; // Vérifier si la conversion a échoué
    // Trouver la ligne du produit dans la feuille "Produits"
    const range = sheet.getDataRange();
    const values = range.getValues();
    for (let i = 1; i < values.length; i++) { // Ignorer l'en-tête
      if (values[i][0] === productName) { // Supposant que le nom du produit est dans la première colonne
        // Mettre à jour le stock (colonne H)
        const currentStock = parseFloat(values[i][8]); // Assurez-vous que le stock est un nombre
        const newStock = currentStock + (-quantitySold); // Déduire la quantité vendue
        sheet.getRange(i + 1, 9).setValue(newStock); // Mettre à jour la cellule correspondante
        // Mettre à jour le nombre de ventes (colonne I)
        const currentSalesCount = parseFloat(values[i][9] || 0); // Assurez-vous que le nombre de ventes est un nombre
        const newSalesCount = currentSalesCount + quantitySold; // Incrémenter le nombre de ventes
        sheet.getRange(i + 1, 10).setValue(newSalesCount); // Mettre à jour la cellule correspondante
        break;
      }
    }
  });
  // Vous pouvez également enregistrer les détails de la vente ici
  const salesSheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName('ventes');
  salesSheet.appendRow([dateTime, adherent, total, paymentMethod]);
}
function updateProductStockAndPrice(productName, newStock, newPrice) {
  const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName('produits');
  const data = sheet.getDataRange().getValues();
  newStock = parseFloat(newStock); // S'assurer que le stock est un nombre décimal
  newPrice = parseFloat(newPrice); // S'assurer que le prix est un nombre décimal
  // Parcours de toutes les lignes pour trouver le produit correspondant
  for (let i = 1; i < data.length; i++) {
    if (data[i][0] === productName) { // Assurez-vous que le nom du produit est dans la colonne 0
      sheet.getRange(i + 1, 9).setValue(newStock);  // Colonne 9 pour le stock
      sheet.getRange(i + 1, 8).setValue(newPrice);  // Colonne 8 pour le prix
      return `Produit ${productName} mis à jour avec succès.`;
    }
  }
  return `Produit ${productName} non trouvé.`;
}
function updateCotisation(adherentName, monthYear, cotisationAmount) {
    const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName('cotisations');
    const data = sheet.getDataRange().getValues();
    console.log('Mise à jour de la cotisation pour', adherentName, 'mois/année:', monthYear, 'montant:', cotisationAmount);
    // Trouver la ligne de l'adhérent
    let adherentRow = -1;
    for (let i = 1; i < data.length; i++) {
        if (data[i][0] === adherentName) {
            adherentRow = i + 1;
            break;
        }
    }
    if (adherentRow === -1) {
        console.log("Adhérent non trouvé !");
        return; // Ou lancer une erreur
    }
    // Trouver la colonne pour le mois et l'année
    const headerRow = data[0];
    const monthYearColumn = headerRow.indexOf(monthYear);
    if (monthYearColumn === -1) {
        console.log("Colonne pour le mois et l'année non trouvée !");
        return; // Ou lancer une erreur
    }
    // Mettre à jour la cellule
    sheet.getRange(adherentRow, monthYearColumn + 1).setValue(cotisationAmount);
    console.log(`Cotisation mise à jour pour ${adherentName} à ${cotisationAmount} dans la cellule [${adherentRow}, ${monthYearColumn + 1}]`);
}
function getCotisations() {
    const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName("cotisations");
    const data = sheet.getDataRange().getValues();
    const cotisations = {};
    const headers = data[0].slice(1); // Noms des mois dans la première ligne
    for (let i = 1; i < data.length; i++) {
        const adherentName = data[i][0]; // Nom de l'adhérent
        cotisations[adherentName] = {};
        for (let j = 0; j < headers.length; j++) {
            const status = data[i][j + 1]; // Statut de cotisation
            // Si la cellule est vide, on considère que l'adhérent n'est pas à jour
            cotisations[adherentName][headers[j]] = status ? "ok" : ""; // "ok" si non vide, sinon vide
        }
    }
    return cotisations;
}
function sendEmailToAdherent(email, invoiceHtml) {
    const subject = "Votre Facture Coop'az";
    const options = {
        htmlBody: invoiceHtml // Utiliser htmlBody pour envoyer du contenu HTML
    };
    MailApp.sendEmail(email, subject, '', options); // Notez le paramètre vide pour le corps du message texte
}




// Récupérer la liste des fournisseurs
function receptionGetSuppliers() {
    const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName('fournisseur');
    const data = sheet.getDataRange().getValues();
    const suppliers = data.slice(1).map(row => ({ name: row[0] }));
    return suppliers;
}
// Récupérer les produits associés à un fournisseur
function receptionGetProductsBySupplier(supplierName) {
    const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName('produits');
    const data = sheet.getDataRange().getValues();
    const products = data.slice(1).filter(row => row[3] === supplierName).map(row => ({
        name: row[0],     // Nom du produit
        price: row[7],    // Prix actuel (colonne H)
        stock: row[8]     // Stock actuel (colonne I)
    }));
    return products;
}
// Récupérer les détails d'un produit (prix et stock)
function receptionGetProductDetails(productName) {
    const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName('produits');
    const data = sheet.getDataRange().getValues();
    const product = data.find(row => row[0] === productName);
    if (product) {
        return {
            price: product[7], // Colonne H
            stock: product[8]  // Colonne I
        };
    }
    return null; // Produit non trouvé
}
// Fonction pour valider la réception


function receptionValidateReception(receptions) {
    const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName('produits');
    receptions.forEach(reception => {
        const currentDate = new Date(); // Récupérer la date actuelle
        const { productName, priceUpdate, stockUpdate, receivedQuantity } = reception;
        const data = sheet.getDataRange().getValues();
        for (let i = 1; i < data.length; i++) {
            if (data[i][0] === productName) { // Trouver le produit
                // Mettre à jour le prix
                if (priceUpdate !== null) {
                    sheet.getRange(i + 1, 8).setValue(priceUpdate);
                }
                // Mettre à jour le stock
                const currentStock = data[i][8];
                const newStock = (stockUpdate !== null ? parseFloat(stockUpdate) : currentStock) + parseFloat(receivedQuantity);
                sheet.getRange(i + 1, 9).setValue(newStock);
                
                
                  // Enregistrer la date si la quantité reçue est renseignée
                if (receivedQuantity && receivedQuantity !== '') {
                    sheet.getRange(i + 1, 7).setValue(currentDate); // Enregistrer la date dans la colonne 10 (par exemple)
                }

                break;
            }
        }
    });
}




function receptionCreateProduct(productData) {
  const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName('produits');
  sheet.appendRow([
    '', // Colonne A (vide)
    productData.name,     // Colonne B: Nom du produit
    productData.barcode,  // Colonne C: Code-barres
    productData.supplier, // Colonne D: Fournisseur
    productData.unit,     // Colonne E: Unité de mesure
    '', '',               // Colonnes F et G (vides)
    productData.price,    // Colonne H: Prix
    productData.quantity  // Colonne I: Quantité reçue
  ]);
  return `Le produit ${productData.name} a été ajouté avec succès.`;
}
function getSuppliers() {
    const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName('fournisseur');
    const data = sheet.getDataRange().getValues();
    const suppliers = [];


    // Parcours des lignes et extraction des données
    for (let i = 1; i < data.length; i++) {
        const supplier = {
            name: data[i][0], // Nom
            phone: data[i][8], // Téléphone
            email: data[i][7], // Email
            address: data[i][1] , // Adresse
            codePostal: data[i][2], // Adresse
            ville: data[i][3], // Adresse
            referent: data[i][5] // Référent
        };
        suppliers.push(supplier);
    }


    // Trier les fournisseurs par nom (ordre alphabétique)
    suppliers.sort((a, b) => a.name.localeCompare(b.name));


    return suppliers;
}




function createSupplier(supplierData) {
    const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName('fournisseur');
    sheet.appendRow([supplierData.name, supplierData.address,supplierData.codePostal,supplierData.ville, '',supplierData.referent, '', supplierData.email, supplierData.phone]);
    return "Fournisseur ajouté avec succès !";
}


function getReferents() {
  const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName("data");
  const referents = sheet.getRange("A2:A").getValues();  // Récupère les valeurs de la colonne A à partir de la ligne 2
  return referents.filter(row => row[0] != "");  // Filtre les valeurs vides
}

function backupSales() {
  const ss = SpreadsheetApp.getActiveSpreadsheet();
  const productsSheet = ss.getSheetByName('produits');
  const weeklySalesSheet = ss.getSheetByName('venteHebdo');
  
  // Récupérer les données de l'onglet 'produits' (nom des produits en B et quantités vendues en J)
  const productData = productsSheet.getRange('A2:J').getValues(); // Colonne B (produits) et J (quantité vendue)
  
  // Récupérer la liste des produits de l'onglet 'venteHebdo' (colonne A)
  const salesList = weeklySalesSheet.getRange('A2:A').getValues().flat(); // Liste des produits dans 'venteHebdo'
  
  // Trouver la première colonne vide dans 'venteHebdo'
  const lastColumn = weeklySalesSheet.getLastColumn();
  const nextEmptyColumn = lastColumn + 1;
  
  // Ajouter la date et l'heure actuelles en haut de la nouvelle colonne
  const currentDateTime = new Date();
  weeklySalesSheet.getRange(1, nextEmptyColumn).setValue('Ventes du ' + currentDateTime.toLocaleString());

  // Créer un objet de correspondance produit/quantité vendue
  const salesMap = {};
  productData.forEach(row => {
    const productName = row[0]; // Nom du produit (colonne B)
    const quantitySold = row[9]; // Quantité vendue (colonne J)
    
    // Si la quantité vendue est supérieure à 0, l'ajouter à l'objet salesMap
    if (quantitySold > 0) {
      salesMap[productName] = quantitySold;
    }
  });

  // Ajouter les quantités vendues pour chaque produit de 'venteHebdo' dans la nouvelle colonne
  const salesData = [];
  salesList.forEach(productName => {
    const quantitySold = salesMap[productName] || 0; // Si le produit n'a pas de ventes, mettre 0
    salesData.push([quantitySold]); // Ajouter la quantité vendue dans le tableau
  });

  // Insérer les données dans la nouvelle colonne de 'venteHebdo'
  weeklySalesSheet.getRange(2, nextEmptyColumn, salesData.length, 1).setValues(salesData);
  
  // Réinitialiser la colonne J de l'onglet 'produits' (quantité vendue)
  productsSheet.getRange('J2:J').clearContent(); // Réinitialiser toutes les quantités vendues

  // Calculer le montant total des ventes
  let totalSalesAmount = 0;
  salesList.forEach(productName => {
    const productPrice = weeklySalesSheet.getRange('B' + (salesList.indexOf(productName) + 2)).getValue(); // Récupérer le prix du produit
    const quantitySold = salesMap[productName] || 0;
    totalSalesAmount += productPrice * quantitySold; // Calculer le montant total pour ce produit
  });

  // Envoi de l'email avec le montant total des ventes
  const recipient = 'epiceriecoopaz@gmail.com';
  const subject = 'Rapport de ventes de la semaine';
  const body = `Les ventes de la semaine ont été enregistrées. Montant total des ventes : €${totalSalesAmount.toFixed(2)}.`;
  MailApp.sendEmail(recipient, subject, body);
  
  // Optionnel : Ajouter une notification que la sauvegarde a été effectuée
  Logger.log('Sauvegarde effectuée avec succès à : ' + currentDateTime.toLocaleString());
}

function createWeeklyTrigger() {
  // Crée un déclencheur qui exécute la fonction 'backupSales' tous les dimanches à midi
  ScriptApp.newTrigger('backupSales')
    .timeBased()
    .onWeekDay(ScriptApp.WeekDay.SUNDAY) // Chaque dimanche
    .atHour(12) // À midi
    .create();
}


/////INVENTAIRE/////////

// Fonction pour mettre à jour l'inventaire dans la feuille Google Sheets
function updateInventory(updatedProducts) {
    const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName('Produits');
    const dateFormat = 'dd/MM/yyyy';
    const today = Utilities.formatDate(new Date(), Session.getScriptTimeZone(), dateFormat);

    const data = sheet.getDataRange().getValues(); // Récupération des données de la feuille

    Logger.log('Produits mis à jour : %s', JSON.stringify(updatedProducts));

    for (let i = 1; i < data.length; i++) { // Parcourir les lignes (ignorer l'entête)
        const productName = data[i][0]; // Nom du produit (colonne A)
        const currentStock = data[i][8]; // Stock actuel (colonne I)
        const inventoryDate = data[i][11]; // Date d'inventaire (colonne L)

        // Vérifier si le produit est dans la liste des produits mis à jour
        const updatedProduct = updatedProducts.find(p => p.name === productName);

        // Convertir les dates pour une comparaison sans heure
        const formattedInventoryDate = inventoryDate ? Utilities.formatDate(new Date(inventoryDate), Session.getScriptTimeZone(), dateFormat) : null;

        if (updatedProduct) {
            // **Cas 1** : Produit renseigné
            Logger.log('Mise à jour du produit : %s avec un nouveau stock de %d', productName, updatedProduct.stock);

            sheet.getRange(i + 1, 9).setValue(updatedProduct.stock); // Mise à jour du stock (colonne I)
            sheet.getRange(i + 1, 12).setValue(today); // Mise à jour de la date (colonne L)

        } else if (formattedInventoryDate === today) {
            // **Cas 2** : Date d'inventaire correspond à la date du jour
            Logger.log('Produit %s déjà mis à jour aujourd\'hui, aucune modification.', productName);
            // Ne rien modifier pour ce produit

        } else {
            // **Cas 3** : Produit non renseigné et date différente ou inexistante
            Logger.log('Produit non renseigné ou date différente, remise du stock à 0 : %s', productName);

            sheet.getRange(i + 1, 9).setValue(0); // Remettre le stock à 0 (colonne I)
        }
    }
    Logger.log('Mise à jour de l\'inventaire terminée.');
    saveInventoryToSheet(updatedProducts)
}

function saveInventoryToSheet(updatedProducts) {
    const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName("Inventaire");

    // Format de la date pour l'ajouter dans le nom des colonnes
    const today = Utilities.formatDate(new Date(), Session.getScriptTimeZone(), 'dd/MM/yyyy');
    const headerPrice = "Prix " + today; // En-tête pour les prix
    const headerStock = "Stock " + today; // En-tête pour les stocks

    // Trouver la colonne où se trouvent les prix et les stocks pour la date d'aujourd'hui
    const existingPriceColumn = findColumnByHeader(sheet, headerPrice);
    const existingStockColumn = findColumnByHeader(sheet, headerStock);

    // Si les colonnes n'existent pas, ajouter les en-têtes et trouver les nouvelles colonnes
    let priceColumn = existingPriceColumn;
    let stockColumn = existingStockColumn;

    if (!priceColumn) {
        priceColumn = sheet.getLastColumn() + 1;
        sheet.getRange(1, priceColumn).setValue(headerPrice);
    }

    if (!stockColumn) {
        stockColumn = priceColumn + 1; // Stock dans la colonne suivante
        sheet.getRange(1, stockColumn).setValue(headerStock);
    }

    // Mettre à jour les prix et les stocks dans les colonnes appropriées
    updatedProducts.forEach((product) => {
        const productRow = findProductRow(sheet, product.name);
        if (productRow) {
            Logger.log('Ligne trouvée pour le produit : %s à la ligne %d', product.name, productRow);

            // Mettre à jour le prix et le stock dans les colonnes
            sheet.getRange(productRow, priceColumn).setValue(product.price); // Mise à jour du prix
            sheet.getRange(productRow, stockColumn).setValue(product.stock); // Mise à jour du stock
        } else {
            Logger.log('Produit non trouvé : %s', product.name);
        }
    });

    Logger.log('Inventaire sauvegardé avec succès.');
}

// Fonction pour trouver la colonne correspondant à un en-tête spécifique
function findColumnByHeader(sheet, header) {
    const headers = sheet.getRange(1, 1, 1, sheet.getLastColumn()).getValues()[0]; // Récupère les entêtes
    for (let i = 0; i < headers.length; i++) {
        if (headers[i] === header) {
            return i + 1; // Retourne l'index de la colonne correspondante
        }
    }
    return null; // Si l'en-tête n'est pas trouvé, retourner null
}

// Fonction pour trouver la ligne d'un produit par son nom
function findProductRow(sheet, productName) {
    const productNames = sheet.getRange("A:A").getValues(); // Liste des noms de produits dans la colonne A
    for (let i = 0; i < productNames.length; i++) {
        if (productNames[i][0] === productName) {
            return i + 1; // Retourner la ligne du produit (ajouter 1 pour la correspondance avec l'index)
        }
    }
    return null; // Si le produit n'est pas trouvé
}



// Fonction pour trouver la ligne du produit dans l'onglet "Inventaire"
function findProductRow(sheet, productName) {
    const productNames = sheet.getRange("A:A").getValues(); // Liste des noms de produits dans la colonne A
    for (let i = 0; i < productNames.length; i++) {
        if (productNames[i][0] === productName) {
            return i + 1; // Retourner la ligne du produit (ajouter 1 pour la correspondance avec l'index)
        }
    }
    return null; // Si le produit n'est pas trouvé
}

function getTotalForDate(formattedDate) {
    const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName('Produits'); // Onglet Produits
    const data = sheet.getDataRange().getValues(); // Récupérer toutes les données

    let total = 0;

    // Vérifier chaque ligne de l'onglet Produits
    data.forEach((row, index) => {
        if (index > 0) { // Ignorer l'en-tête
            const inventoryDate = row[11]; // Date d'inventaire dans la colonne L (index 11)
            
            // Convertir la date d'inventaire et vérifier si elle correspond à la date d'aujourd'hui
            const formattedInventoryDate = inventoryDate ? Utilities.formatDate(new Date(inventoryDate), Session.getScriptTimeZone(), 'dd/MM/yyyy') : null;
            
            if (formattedInventoryDate === formattedDate) {
                // Si la date d'inventaire correspond à la date du jour, ajouter le produit au total
                const price = parseFloat(row[7]); // Prix unitaire dans la colonne H (index 7)
                const stock = parseFloat(row[8]); // Stock actuel dans la colonne I (index 8)

                // Vérifier que le prix et le stock sont des nombres valides
                if (!isNaN(price) && !isNaN(stock)) {
                    total += price * stock; // Calculer le total pour ce produit
                }
            }
        }
    });

    return total.toFixed(2); // Retourner le total formaté à 2 décimales
}

function sendInventoryEmail(formattedDate, total) {
    const recipient = "fabien.hicauber@gmail.com"; // Remplacez par l'adresse email cible
    const subject = `Résumé de l'inventaire - ${formattedDate}`;
    const body = `Bonjour,

Voici le résumé de l'inventaire du ${formattedDate} :

Montant total des stocks : ${total}€

Cordialement,
Votre système de gestion`;

    MailApp.sendEmail(recipient, subject, body);
}