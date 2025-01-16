////////////////////////////////////////////////////////////////////////////////////////////
//fonctions côté serveur traitent les requêtes de l'interface et interagissent avec Sheets//
////////////////////////////////////////////////////////////////////////////////////////////

function doGet() {
  return HtmlService.createTemplateFromFile('salesInterface').evaluate()
    .setTitle(VERSION);
}

function include(filename) {
  return HtmlService.createHtmlOutputFromFile(filename).getContent();
}

/////////////////////
//////Ventes/////////
/////////////////////

// récupérer les produits dans l'onglet produits de la feuille google sheet
function getProducts() {
  const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName('produits');
  const data = sheet.getDataRange().getValues();
  const products = data.map((row, index) => {
    if (index === 0) return null; // Ignorer l'en-tête
    // Vérifier si la date est présente dans une colonne (par exemple, la colonne L, soit index 11)
    const formattedDate = row[11] instanceof Date ? Utilities.formatDate(row[11], Session.getScriptTimeZone(), 'yyyy-MM-dd') : null;

    // Convertir le prix avec remplacement de la virgule par un point
    const price = row[7] ? parseFloat(row[7].toString().replace(',', '.')) : 0;

    return {
      name: row[0],       // Nom du produit
      shortName: row[1],  // Nom court (colonne 2)
      supplier: row[3],  // Fournisseur
      price: price,       // Prix unitaire
      stock: row[8],      // Stock actuel
      barcode: row[2],    // Code barre (colonne 3)
      stockDate: formattedDate  // Date de la dernière réception, formatée si elle existe
    };
  }).filter(Boolean); // Supprimer les entrées null
  return products;
}

//récupérer la liste des adhérents dans l'onglet adherents
function getAdherents() {
  const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName('adherents'); // Change le nom de l'onglet si nécessaire
  const data = sheet.getDataRange().getValues();
  const adherents = data.map(row => {
    return {
      name: row[0], //  nom de l'adhérent
      email: row[1], // email de l'adhérent

    };
  });
  return adherents;
}

//récupère l'état de la cotisation de l'adhérent dans l'onglet cotisations
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

//Mise à jour de la cotisation dans l'onglet cotisations lors de la validation de la vente
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

//Sauvegarde les coordonnées d'un nouvel adhérent dans une autre feuille dans l'onglet Recap
function saveNewAdherent(name, email, phone, address) {
    const ss = SpreadsheetApp.openById('1ziWZgsLbGDVyPLe3pGKwwBDCZGr1tglIKjWDtifMuCg'); // ID de ton Google Sheets
    const sheet = ss.getSheetByName('Recap'); // Nom de la feuille "Recap"
    const date = new Date(); // Date du jour
    const status = "Nouveau"; // Statut "Nouveau"
    // Insertion des données dans la feuille "Recap"
    sheet.appendRow([date, status, name, '', '', '', phone, '', email, '', '', '', address]);
}

//Envoi des coordonnée du nouvel adhérent à l'adresse indiquée
function sendAdherentEmail(adherentData) {
  const recipient = NEW_ADHERENT_EMAIL.recipient;
  const subject = NEW_ADHERENT_EMAIL.subject;
  const body = NEW_ADHERENT_EMAIL.body // Remplacer les variables dynamiques dans le corps du message
    .replace("{{name}}", adherentData.name)
    .replace("{{email}}", adherentData.email)
    .replace("{{phone}}", adherentData.phone)
    .replace("{{address}}", adherentData.address)
    .replace("{{meetingDates}}", adherentData.meetingDates);
  MailApp.sendEmail(recipient, subject, body);
}

//sauvegarde une vente
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
        
        // Remplacer les points par des virgules avant d'enregistrer
        const formattedStock = newStock.toString().replace('.', ',');
        sheet.getRange(i + 1, 9).setValue(formattedStock); // Mettre à jour la cellule correspondante
        
        // Mettre à jour le nombre de ventes (colonne I)
        const currentSalesCount = parseFloat(values[i][9] || 0); // Assurez-vous que le nombre de ventes est un nombre
        const newSalesCount = currentSalesCount + quantitySold; // Incrémenter le nombre de ventes
        
        // Remplacer les points par des virgules avant d'enregistrer
        const formattedSalesCount = newSalesCount.toString().replace('.', ',');
        sheet.getRange(i + 1, 10).setValue(formattedSalesCount); // Mettre à jour la cellule correspondante
        break;
      }
    }
  });

  // Remplacer les points par des virgules pour le total avant de l'enregistrer dans la feuille des ventes
  const formattedTotal = total.toString().replace('.', ',');

  // Ajouter une nouvelle ligne dans la feuille "ventes"
  const salesSheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName('ventes');
  salesSheet.appendRow([dateTime, adherent, formattedTotal, paymentMethod]);
}
function updateProductDetails(productName, newStock, newPrice, newShortName, newBarcode) {
  const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName('produits');
  const data = sheet.getDataRange().getValues();

  newStock = parseFloat(newStock); // S'assurer que le stock est un nombre décimal
  newPrice = parseFloat(newPrice); // S'assurer que le prix est un nombre décimal

  for (let i = 1; i < data.length; i++) {
    if (data[i][0] === productName) { // Nom du produit dans la colonne 0
      sheet.getRange(i + 1, 9).setValue(newStock);    // Colonne 9 : Stock
      sheet.getRange(i + 1, 8).setValue(newPrice);    // Colonne 8 : Prix
      sheet.getRange(i + 1, 2).setValue(newShortName); // Colonne 2 : Nom court
      sheet.getRange(i + 1, 3).setValue(newBarcode);   // Colonne 3 : Code-barre
      return `Produit "${productName}" mis à jour avec succès.`;
    }
  }

  return `Produit "${productName}" non trouvé.`;
}

//Envoi de la facture par mail
function sendInvoiceToAdherent(invoiceData) {
    const email = invoiceData.email;
    // passer les constante fixe paramétrée dans le fichier config
    const subject = INVOICE_EMAIL.subject;
    // Construire les détails des lignes de la commande
    let orderDetails = '';
    invoiceData.purchases.forEach(purchase => {
      const lineHtml = INVOICE_EMAIL.orderDetailsTemplate
        .replace('{{productName}}', purchase.productName)
        .replace('{{quantity}}', purchase.quantity)
        .replace('{{price}}', purchase.price.toFixed(2))
        .replace('{{lineTotalBeforeDiscount}}', (purchase.price * purchase.quantity).toFixed(2))
        .replace('{{discount}}', purchase.discount.toFixed(0))
        .replace('{{discountAmount}}',(- (purchase.price * purchase.quantity * purchase.discount / 100)).toFixed(2))
        .replace('{{totalLine}}', ((purchase.price * purchase.quantity) - (purchase.price * purchase.quantity * purchase.discount / 100)).toFixed(2));
      orderDetails += lineHtml;
    });
    // Remplacer les variables dynamiques dans le corps du message
    const htmlBody = INVOICE_EMAIL.htmlBody 
      .replace("{{adherent}}", invoiceData.adherent)
      .replace("{{paymentMethod}}", invoiceData.paymentMethod)
      .replace("{{orderDetails}}", orderDetails)
      .replace("{{cotisationAmount}}", invoiceData.cotisationAmount)
      .replace("{{creditAmount}}", invoiceData.creditAmount)
      .replace("{{total}}", invoiceData.total)
      .replace("{{date}}", invoiceData.date)
      .replace("{{cbfee}}", invoiceData.cbFee)
      .replace("{{subTotal}}", invoiceData.subTotal)
      ;
    MailApp.sendEmail({
        to: email,
        subject: subject,
        htmlBody: htmlBody
    });
}

// Sauvegarde les ventes hebdomadaires et envoie un mail avec le montant des ventes et le classement des produits
function backupSales() {
  const ss = SpreadsheetApp.getActiveSpreadsheet();
  const productsSheet = ss.getSheetByName('produits');
  const weeklySalesSheet = ss.getSheetByName('venteHebdo');
  
  // Récupérer les données de l'onglet 'produits' (nom des produits en A et quantités vendues en J)
  const productData = productsSheet.getRange('A2:J').getValues(); // Colonne A (produits), J (quantité vendue)
  
  // Récupérer la liste des produits de l'onglet 'venteHebdo' (colonne A)
  const salesList = weeklySalesSheet.getRange('A2:A').getValues().flat(); // Liste des produits dans 'venteHebdo'
  
  // Récupérer les prix des produits dans l'onglet 'venteHebdo' (colonne B)
  const productPrices = weeklySalesSheet.getRange('B2:B').getValues().flat(); // Prix des produits dans 'venteHebdo'

  // Trouver la première colonne vide dans 'venteHebdo'
  const lastColumn = weeklySalesSheet.getLastColumn();
  const nextEmptyColumn = lastColumn + 1;
  
  // Ajouter la date et l'heure actuelles en haut de la nouvelle colonne
  const currentDateTime = new Date();
  weeklySalesSheet.getRange(1, nextEmptyColumn).setValue('Ventes du ' + currentDateTime.toLocaleString());

  // Créer un objet de correspondance produit/quantité vendue
  const salesMap = {};
  productData.forEach(row => {
    const productName = row[0]; // Nom du produit (colonne A)
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
  
  // S'assurer que toutes les données sont bien enregistrées avant de continuer
  SpreadsheetApp.flush();  // Force l'application de toutes les modifications

  // Réinitialiser la colonne J de l'onglet 'produits' (quantité vendue)
  productsSheet.getRange('J2:J').clearContent(); // Réinitialiser toutes les quantités vendues

  // Calculer le montant total des ventes
  let totalSalesAmount = 0;
  let productSales = []; // Tableau pour stocker les produits avec leurs ventes (prix * quantité)
  
  salesList.forEach((productName, index) => {
    let productPrice = productPrices[index]; // Récupérer le prix du produit dans 'venteHebdo' (colonne B)
    
    // Nettoyer et forcer la conversion du prix en nombre avec décimales
    productPrice = parseFloat(productPrice.toString().replace(',', '.')); // Remplacer la virgule par un point décimal
    
    // Vérification et débogage des valeurs
    if (isNaN(productPrice) || productPrice <= 0) {
      Logger.log(`Prix non valide pour le produit: ${productName}. Valeur récupérée: ${productPrices[index]}`);
      productPrice = 0; // Mettre à 0 si le prix est invalide
    }
    
    const quantitySold = salesMap[productName] || 0; // Quantité vendue pour ce produit
    totalSalesAmount += productPrice * quantitySold; // Calculer le montant total pour ce produit
    
    // Ajouter l'information dans le tableau des ventes
    productSales.push({
      productName: productName,
      totalSaleAmount: productPrice * quantitySold,
      quantitySold: quantitySold,
      price: productPrice
    });
  });

  // Trier les produits par quantité vendue, du plus élevé au plus bas
  productSales.sort((a, b) => b.quantitySold - a.quantitySold);

  // Extraire les 10 premiers produits
  const top10Products = productSales.slice(0, 10);
  
  // Créer un tableau HTML pour le classement des 10 produits les plus vendus par quantité
  let top10Html = "<h3>Top 10 des produits les plus vendus :</h3><table border='1' cellpadding='5' style='border-collapse: collapse;'>";
  top10Html += "<tr><th>Rang</th><th>Produit</th><th>Quantité</th><th>Prix unitaire (€)</th><th>Total (€)</th></tr>";
  
  top10Products.forEach((product, index) => {
    top10Html += `<tr><td>${index + 1}</td><td>${product.productName}</td><td>${product.quantitySold}</td><td>${product.price.toFixed(2)}</td><td>${product.totalSaleAmount.toFixed(2)}</td></tr>`;
  });

  top10Html += "</table>";

  // Envoi de l'email avec le montant total des ventes et le classement des produits
  const recipient = 'epiceriecoopaz@gmail.com';
  const subject = 'Rapport de ventes de la semaine';
  const body = `Les ventes de la semaine ont été enregistrées. Montant total des ventes : €${totalSalesAmount.toFixed(2)}.<br><br>${top10Html}`;
  
  // Envoyer l'email avec du contenu HTML
  MailApp.sendEmail({
    to: recipient,
    subject: subject,
    htmlBody: body
  });
  
  // Optionnel : Ajouter une notification que la sauvegarde a été effectuée
  Logger.log('Sauvegarde effectuée avec succès à : ' + currentDateTime.toLocaleString());
}

// Crée un déclencheur qui exécute la fonction 'backupSales' tous les dimanches à midi
function createWeeklyTrigger() {
  ScriptApp.newTrigger('backupSales')
    .timeBased()
    .onWeekDay(ScriptApp.WeekDay.SUNDAY) // Chaque dimanche
    .atHour(12) // À midi
    .create();
}

//////////////////////
//////Réception///////
//////////////////////

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
        // Assurez-vous que le prix et le stock sont des nombres
        const price = parseFloat(product[7].toString().replace(',', '.')); // Remplacer la virgule par un point
        const stock = parseFloat(product[8].toString().replace(',', '.')); // Remplacer la virgule par un point
        
        return {
            price: isNaN(price) ? 0 : price,  // Si ce n'est pas un nombre, renvoyer 0
            stock: isNaN(stock) ? 0 : stock   // Si ce n'est pas un nombre, renvoyer 0
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
                    const formattedPriceUpdate = priceUpdate.toString().replace('.', ',');
                    sheet.getRange(i + 1, 8).setValue(formattedPriceUpdate); // Colonne du prix
                }

                // Mettre à jour le stock
                const currentStock = parseFloat(data[i][8]) || 0; // Assurez-vous que le stock est un nombre
                const stockToUpdate = stockUpdate !== null ? parseFloat(stockUpdate) : currentStock;
                const newStock = stockToUpdate + parseFloat(receivedQuantity || 0);

                // Formater le nouveau stock avec une virgule
                const formattedNewStock = newStock.toString().replace('.', ',');
                sheet.getRange(i + 1, 9).setValue(formattedNewStock); // Colonne du stock

                // Enregistrer la date si la quantité reçue est renseignée
                if (receivedQuantity && receivedQuantity !== '') {
                    sheet.getRange(i + 1, 7).setValue(currentDate); // Enregistrer la date dans la colonne correspondante
                }

                break;
            }
        }
    });
}

//Créer un nouveau produit depuis la réception
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

//// réception aventure bio////
function receptionAventureBio() {
  const feuilleProduits = SpreadsheetApp.getActiveSpreadsheet().getSheetByName("produits");
  const feuilleAventurebio = SpreadsheetApp.getActiveSpreadsheet().getSheetByName("aventurebio");

  // Récupérer les données des feuilles Produits et Aventurebio
  const dataProduits = feuilleProduits.getDataRange().getValues();
  const dataAventurebio = feuilleAventurebio.getDataRange().getValues();

  // Créer un objet pour stocker les produits actuels par code-barre
  let produitsMap = {};
  for (let i = 1; i < dataProduits.length; i++) {
    const [ , ,codeBarre, , , , , prix,stock] = dataProduits[i];
    if (codeBarre) produitsMap[codeBarre] = { index: i + 1, prix, stock };
  }

  // Catégories de produits
  const categories = [
    { motCle: "Sec", categorie: "Sec" },
    { motCle: "Epices", categorie: "Epices" },
    { motCle: "Condiments", categorie: "Condiments" },
    { motCle: "Boulangerie", categorie: "Boulangerie" },
    { motCle: "Boisson", categorie: "Boisson" },
    { motCle: "Laitier", categorie: "Produit Laitier" },
    { motCle: "Legumes", categorie: "Legumes" },
    { motCle: "Fruits secs", categorie: "Fruits secs" },
    { motCle: "Fruits", categorie: "Fruits" },
    { motCle: "Hygiene", categorie: "Hygiene" },
    { motCle: "Menage", categorie: "Menage" },
    { motCle: "Volaille", categorie: "Volaille" },
    { motCle: "Condiment sucre", categorie: "Condiment Sucre" },
    { motCle: "Poisson", categorie: "Poisson" },
    { motCle: "Charcuterie", categorie: "Charcuterie" },
    { motCle: "Plat cuisine", categorie: "Plat cuisine" },
    { motCle: "viande", categorie: "viande" },
    { motCle: "conserve", categorie: "conserve" },
    { motCle: "cereale", categorie: "cereale" },
    { motCle: "apero", categorie: "apero" },
  ];

  // Gérer les nouveaux produits
  let nouveauxProduits = [];

  for (let j = 1; j < dataAventurebio.length; j++) {
    const [nomProduit, , codeBarre, , , , , quantiteColH, quantiteColI, nouveauPrix] = dataAventurebio[j];
    const quantiteReception = quantiteColH * quantiteColI;

    if (produitsMap[codeBarre] !== undefined) {
      // Si le produit existe dans Produits, on incrémente le stock et met à jour le prix
      const { index, stock } = produitsMap[codeBarre];
      feuilleProduits.getRange(index, 9).setValue(stock + quantiteReception); // Mise à jour du stock en colonne L
      feuilleProduits.getRange(index, 8).setValue(nouveauPrix); // Mise à jour du prix en colonne J
    } else {
      // Préparer les nouveaux produits à ajouter à la fin de Produits
      let nomReduit = nomProduit.slice(0, -23);
      let unite = nomProduit.includes("KG") ? "Kilo" : "Unite";

      // Identifier la catégorie du produit
      let categorie = "autre"; // Catégorie par défaut
      for (let { motCle, categorie: cat } of categories) {
        if (nomProduit.toLowerCase().includes(motCle.toLowerCase())) {
          categorie = cat;
          break;
        }
      }

      nouveauxProduits.push(["", nomProduit, codeBarre, "AVENTURE BIO", unite,  "", "",  nouveauPrix, quantiteReception]);
      // Générer l'étiquette pour le nouveau produit
      generateEtiquette(nomProduit, codeBarre, nouveauPrix, quantiteReception);
    }
  }

  // Ajouter les nouveaux produits à la fin de la feuille Produits
  if (nouveauxProduits.length > 0) {
    const derniereLigne = feuilleProduits.getLastRow() + 1;
    feuilleProduits.getRange(derniereLigne, 1, nouveauxProduits.length, nouveauxProduits[0].length).setValues(nouveauxProduits);
  }
}

/////////////////////////
////////Fournisseurs/////
/////////////////////////

//Récupère la liste des fournisseurs pour l'afficher dans l'onglet fournisseur
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

//créer un nouveau fournisseur
function createSupplier(supplierData) {
    const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName('fournisseur');
    sheet.appendRow([supplierData.name, supplierData.address,supplierData.codePostal,supplierData.ville, '',supplierData.referent, '', supplierData.email, supplierData.phone]);
    return "Fournisseur ajouté avec succès !";
}

//récupérer le référent associé au founrissuer
function getReferents() {
  const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName("data");
  const referents = sheet.getRange("A2:A").getValues();  // Récupère les valeurs de la colonne A à partir de la ligne 2
  return referents.filter(row => row[0] != "");  // Filtre les valeurs vides
}

/////////////////////
//////PERTES/////////
/////////////////////

//Valider les pertes
function validateLoss(pertes) {
  const produitSheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName('produits');
  const perteSheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName('pertes');

  // Vérification si les feuilles existent
  if (!produitSheet || !perteSheet) {
    throw new Error("Les feuilles 'produits' ou 'pertes' sont introuvables.");
  }

  const produits = produitSheet.getRange("A2:A" + produitSheet.getLastRow()).getValues().flat();
  console.log("Liste des produits :", produits);  // Affiche la liste des produits pour vérifier la recherche

  // Récupérer la date de la semaine actuelle
  const today = new Date();
  const weekNumber = getWeekNumber(today);
  console.log("Semaine actuelle :", weekNumber);  // Affiche la semaine pour vérifier

  let headers = perteSheet.getRange(1, 1, 1, perteSheet.getLastColumn()).getValues()[0];
  console.log("En-têtes des pertes :", headers);  // Affiche les en-têtes des pertes

  let currentWeekIndex = headers.indexOf("Semaine " + weekNumber);
  if (currentWeekIndex === -1) {
    console.log("Ajout de la colonne pour la semaine " + weekNumber);
    currentWeekIndex = headers.length; // Nouvelle colonne pour la semaine
    perteSheet.getRange(1, currentWeekIndex + 1).setValue("Semaine " + weekNumber);
  }

  // Traitement des pertes
  pertes.forEach(perte => {
    // Trouver l'index du produit dans la liste
    const rowIndex = produits.indexOf(perte.productName) + 2; // +2 pour ignorer l'en-tête

    // Vérification si le produit existe dans la liste
    if (rowIndex <= 1) {
      console.warn(`Produit introuvable : ${perte.productName}`);
      return;  // Ignore ce produit s'il est introuvable
    }

    // Afficher les détails du produit pour déboguer
    console.log(`Produit trouvé : ${perte.productName}, Ligne : ${rowIndex}`);

    // Mettre à jour le stock
    const currentStock = produitSheet.getRange(rowIndex, 9).getValue(); // Colonne I = Stock
    console.log(`Stock actuel : ${currentStock}`);  // Affiche le stock avant la modification

    // Même si le stock devient négatif, on effectue la mise à jour
    const newStock = currentStock - perte.lossQuantity; // Le stock peut devenir négatif

    // Formater le stock avec une virgule
    const formattedNewStock = newStock.toString().replace('.', ',');
    produitSheet.getRange(rowIndex, 9).setValue(formattedNewStock);

    // Vérification du montant de la perte
    if (isNaN(perte.lossQuantity) || perte.lossQuantity <= 0) {
      console.warn(`Quantité invalide pour ${perte.productName}`);
      return; // Ignore ce produit si la perte est invalide
    }

    // Récupérer le prix du produit (colonne H)
    const productPrice = produitSheet.getRange(rowIndex, 8).getValue(); // Colonne H = Prix
    if (isNaN(productPrice) || productPrice <= 0) {
      console.warn(`Prix invalide pour ${perte.productName}`);
      return; // Ignore ce produit si le prix est invalide
    }

    // Calcul du montant de la perte
    const lossAmount = perte.lossQuantity * productPrice;

    // Formater le montant de la perte avec une virgule
    const formattedLossAmount = lossAmount.toString().replace('.', ',');
    console.log(`Montant de la perte pour ${perte.productName} : ${formattedLossAmount}`);

    // Trouver la ligne correspondant au produit dans la feuille des pertes
    const productRowInLossSheet = perteSheet.getRange(2, 1, perteSheet.getLastRow(), 1).getValues().flat().indexOf(perte.productName) + 2;

    // Vérification si la ligne pour le produit existe dans la feuille des pertes
    if (productRowInLossSheet <= 1) {
      console.warn(`Produit introuvable dans la feuille des pertes : ${perte.productName}`);
      return; // Ignore ce produit s'il est introuvable dans la feuille des pertes
    }

    // Enregistrer la perte dans la feuille des pertes
    const perteCell = perteSheet.getRange(productRowInLossSheet, currentWeekIndex + 1);
    const currentPerte = perteCell.getValue() || 0;

    // Formater et enregistrer la perte
    const formattedCurrentPerte = currentPerte.toString().replace('.', ',');
    const formattedNewPerte = (parseFloat(currentPerte) + parseFloat(lossAmount)).toString().replace('.', ',');
    perteCell.setValue(formattedNewPerte);

    console.log(`Perte enregistrée : ${perte.productName}, Montant : ${formattedLossAmount}, Stock mis à jour : ${formattedNewStock}`);
  });
}

// Fonction pour obtenir le numéro de la semaine
function getWeekNumber(d) {
  d = new Date(Date.UTC(d.getFullYear(), d.getMonth(), d.getDate()));
  const yearStart = new Date(Date.UTC(d.getUTCFullYear(), 0, 1));
  return Math.ceil(((d - yearStart) / 86400000 + 1) / 7);
}

function backupLosses() {
  const ss = SpreadsheetApp.getActiveSpreadsheet();
  const produitsSheet = ss.getSheetByName('produits');
  const pertesSheet = ss.getSheetByName('pertes');
  
  // Vérifier que les feuilles existent
  if (!produitsSheet || !pertesSheet) {
    throw new Error("Les feuilles 'produits' ou 'pertes' sont introuvables.");
  }

  // Récupérer les produits et leur stock actuel
  const productData = produitsSheet.getRange('A2:I').getValues(); // Colonne A = produits, Colonne H = prix unitaire, Colonne I = stock
  const produits = productData.map(row => row[0]); // Liste des produits
  const prixUnitaires = productData.map(row => row[7]); // Liste des prix unitaires (Colonne H)
  const stocks = productData.map(row => row[8]); // Liste des stocks

  // Récupérer les en-têtes des pertes pour obtenir la colonne de la semaine actuelle
  const headers = pertesSheet.getRange(1, 1, 1, pertesSheet.getLastColumn()).getValues()[0];
  const today = new Date();
  const weekNumber = getWeekNumber(today); // Fonction pour obtenir la semaine actuelle
  const currentWeekIndex = headers.indexOf("Semaine " + weekNumber);

  if (currentWeekIndex === -1) {
    Logger.log(`Aucune perte enregistrée pour la semaine ${weekNumber}`);
    return; // Si aucune donnée pour la semaine actuelle, ne pas envoyer de mail
  }

  // Récupérer les pertes de la semaine actuelle
  const pertesData = pertesSheet.getRange(2, currentWeekIndex + 1, pertesSheet.getLastRow() - 1, 1).getValues();
  
  // Créer un tableau des produits perdus avec leurs montants
  let pertesMessage = '';
  let totalLossAmount = 0;

  pertesData.forEach((loss, index) => {
    const productName = produits[index];
    const lossAmount = loss[0];
    
    if (lossAmount > 0) {
      const productPrice = prixUnitaires[index]; // Prix unitaire (colonne H)
      const lossValue = lossAmount * productPrice;
      totalLossAmount += lossValue;
      
      // Ajouter le produit, le prix unitaire, la perte et le montant au message (en HTML)
      pertesMessage += `<tr>
                          <td style="border: 1px solid #ddd; padding: 8px;">${productName}</td>
                          <td style="border: 1px solid #ddd; padding: 8px;">€${productPrice.toFixed(2)}</td>
                          <td style="border: 1px solid #ddd; padding: 8px;">${lossAmount.toFixed(2)}</td>
                          <td style="border: 1px solid #ddd; padding: 8px;">€${lossValue.toFixed(2)}</td>
                        </tr>`;
    }
  });

  if (pertesMessage === '') {
    Logger.log("Aucune perte à signaler cette semaine.");
    return; // Si aucune perte, ne pas envoyer de mail
  }

  // Préparer l'email avec mise en forme HTML
  const recipient = 'epiceriecoopaz@gmail.com';
  const subject = `Rapport des pertes de la semaine ${weekNumber}`;
  
  const body = `
    <p>Bonjour,</p>
    <p>Les pertes de la semaine ${weekNumber} ont été enregistrées.</p>
    <p><strong>Total des pertes : €${totalLossAmount.toFixed(2)}</strong></p>
    <p><strong>Détails des pertes :</strong></p>
    <table style="border-collapse: collapse; width: 100%;">
      <thead>
        <tr>
          <th style="border: 1px solid #ddd; padding: 8px; text-align: left;">Produit</th>
          <th style="border: 1px solid #ddd; padding: 8px; text-align: left;">Prix unitaire (€)</th>
          <th style="border: 1px solid #ddd; padding: 8px; text-align: left;">Perte </th>
          <th style="border: 1px solid #ddd; padding: 8px; text-align: left;">Montant (€)</th>
        </tr>
      </thead>
      <tbody>
        ${pertesMessage}
      </tbody>
    </table>
    <p>Cordialement,</p>
    <p>Le système de gestion des ventes</p>
  `;

  // Envoi de l'email
  MailApp.sendEmail({
    to: recipient,
    subject: subject,
    htmlBody: body
  });

  Logger.log(`Rapport des pertes envoyé avec succès pour la semaine ${weekNumber}`);
}

function createWeeklyLossTrigger() {
  // Crée un déclencheur qui exécute la fonction 'backupLosses' tous les dimanches à midi
  ScriptApp.newTrigger('backupLosses')
    .timeBased()
    .onWeekDay(ScriptApp.WeekDay.SUNDAY) // Chaque dimanche
    .atHour(12) // À midi;
}

////////////////////////
/////INVENTAIRE/////////
////////////////////////

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
//Sauvegarde l'inventaire
function saveInventoryToSheet(updatedProducts) {
    const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName("Inventaire");

    if (!sheet) {
        throw new Error("La feuille 'Inventaire' est introuvable.");
    }

    // Format de la date pour les en-têtes de colonnes
    const today = Utilities.formatDate(new Date(), Session.getScriptTimeZone(), 'dd/MM/yyyy');
    const headerPrice = "Prix " + today;
    const headerStock = "Stock " + today;

    // Vérifier si les colonnes pour la date d'aujourd'hui existent déjà
    let priceColumn = findColumnByHeader(sheet, headerPrice);
    let stockColumn = findColumnByHeader(sheet, headerStock);

    if (!priceColumn) {
        priceColumn = sheet.getLastColumn() + 1;
        sheet.getRange(1, priceColumn).setValue(headerPrice); // Ajouter en-tête pour les prix
    }

    if (!stockColumn) {
        stockColumn = priceColumn + 1; // Ajouter en-tête pour les stocks
        sheet.getRange(1, stockColumn).setValue(headerStock);
    }

    // Mettre à jour les prix et les stocks pour les produits
    updatedProducts.forEach((product) => {
        const productRow = findProductRow(sheet, product.name);

        if (productRow) {
            Logger.log("Produit trouvé : %s à la ligne %d", product.name, productRow);

            // Remplacer le point par une virgule dans le prix et le stock
            const formattedPrice = formatNumber(product.price);
            const formattedStock = formatNumber(product.stock);

            // Mettre à jour le prix et le stock dans les colonnes
            sheet.getRange(productRow, priceColumn).setValue(formattedPrice);
            sheet.getRange(productRow, stockColumn).setValue(formattedStock);
        } else {
            Logger.log("Produit non trouvé : %s", product.name);
        }
    });

    Logger.log("Inventaire sauvegardé avec succès.");
}

// Fonction pour formater les nombres et remplacer les points par des virgules
function formatNumber(value) {
    if (typeof value === 'number') {
        return value.toString().replace('.', ',');
    }
    return value; // Si ce n'est pas un nombre, renvoyer la valeur originale
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