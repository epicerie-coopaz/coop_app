function doGet() {
  return HtmlService.createHtmlOutputFromFile('SalesInterface')
    .setWidth(1920)
    .setHeight(1080);
}
function getProducts() {
  const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName('produits');
  const data = sheet.getDataRange().getValues();
  const products = data.map((row, index) => {
    if (index === 0) return null; // Ignorer l'en-tête
    return {
      name: row[0],     // Nom du produit
      price: row[7],    // Prix unitaire (colonne H)
      stock: row[8]     // Stock actuel (colonne I)
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
function receptionValidateReception(receptions) {
    const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName('produits');
    const data = sheet.getDataRange().getValues();
    receptions.forEach(reception => {
        const { productName, priceUpdate, stockUpdate, receivedQuantity } = reception;
        const productRow = data.find(row => row[0] === productName);
        if (productRow) {
            const productIndex = data.indexOf(productRow);
            let newStock = productRow[8];
            let newPrice = priceUpdate ? parseFloat(priceUpdate.replace(',', '.')) : productRow[7];  // Conversion avec gestion de la virgule
            // Vérification de la quantité reçue
            const quantity = parseFloat(receivedQuantity.replace(',', '.'));  // Remplacer les virgules par des points pour le nombre décimal
            if (isNaN(quantity) || quantity <= 0) {
                throw new Error('La quantité reçue doit être un nombre valide.');
            }
            // Mise à jour du prix (si spécifié)
            if (priceUpdate !== null && !isNaN(newPrice)) {
                sheet.getRange(productIndex + 1, 8).setValue(newPrice); // Colonne H pour le prix
            }
            // Mise à jour du stock
            if (stockUpdate !== null) {
                newStock = parseFloat(stockUpdate.replace(',', '.')) + quantity;
            } else {
                newStock += quantity;
            }
            if (!isNaN(newStock)) {
                sheet.getRange(productIndex + 1, 9).setValue(newStock); // Colonne I pour le stock
            } else {
                throw new Error('Le stock mis à jour doit être un nombre valide.');
            }
        }
    });
    return 'Réception validée avec succès !';
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

