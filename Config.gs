/////////////////////////////////////////////////////////////////////
//configurations globales sous forme de constantes ou de fonctions//
/////////////////////////////////////////////////////////////////////

// version du fichier
const VERSION = "CaisseV4-4";

//Envoi des coordonnée du nouvel adhérent à l'adresse mail indiquée
const NEW_ADHERENT_EMAIL = {
  recipient: "laurie.besinet@gmail.com",
  subject: "Coop'Az - Nouvel adhérent",
  body: `
  Bonjour,

  Un nouvel adhérent a été créé. Voici les détails :

  - Nom : {{name}}
  - Email : {{email}}
  - Téléphone : {{phone}}
  - Adresse : {{address}}
  - Jour de réunion : {{meetingDates}}

  Cordialement,
  Votre système de gestion des adhérents
  `
};

//Envoi de la facture par mail
const INVOICE_EMAIL = {
  subject: "Coop'Az - Votre Facture",
  htmlBody: `
      <div>
        <p>Bonjour,</p>
        <p>Suite à votre achat à Coop'Az, voici les détails de votre facture :</p>
        <table style="width: 100%; border-collapse: collapse; margin-top: 20px;">
            <thead>
                <tr>
                    <th style="text-align: left; border-bottom: 2px solid #000;"><span>Description</span></th>
                    <th style="text-align: right; border-bottom: 2px solid #000;"><span>Valeur</span></th>
                </tr>
            </thead>
            <tbody>
                {{orderDetails}}
                <tr>
                    <th th style="text-align: left; border-top: 1px solid #000;"><span>Sous-total</span></th>
                    <th style="text-align: right; border-top: 1px solid #000;"><span>{{subTotal}}&nbsp;€</span></th>
                </tr>
                <tr>
                    <td><span>Cotisation</span></td>
                    <td style="text-align: right;"><nobr>{{cotisationAmount}}&nbsp;€</nobr></td>
                </tr>
                <tr>
                    <td><span>Avoir</span></td>
                    <td style="text-align: right;"><span><nobr>-&nbsp;{{creditAmount}}&nbsp;€</nobr></span></td>
                </tr>
                <tr>
                    <td><span>Méthode de Paiement</span></td>
                    <td style="text-align: right;"><span>{{paymentMethod}}</span></td>
                </tr>
                <tr>
                    <td><span>Frais de carte bancaire</span></td>
                    <td style="text-align: right;"><span><nobr>{{cbfee}}&nbsp;€</nobr></span></td>
                </tr>
                <tr>
                    <th style="text-align: left; border-top: 1px solid #000;"><span>Total</span></th>
                    <th style="text-align: right; border-top: 1px solid #000;"><span><nobr>{{total}}&nbsp;€</nobr></span></th>
                </tr>
            </tbody>
          </table>
        <br>
        <p>Merci pour votre commande.</p>
        <p>A bientôt, </p>
        <p>L'équipe Coop'Az</p>
      </div>
    `,
  //chaque ligne produit 
  orderDetailsTemplate: `
      <tr style="border-bottom: 1px solid #858a89;">
        <td>
          <span>{{productName}}</span><br>
          <span style="color: #8e8e8e;">&emsp;{{quantity}} x {{price}}&nbsp;€ : {{lineTotalBeforeDiscount}}&nbsp;€</span><br>
          <span style="color: #8e8e8e;">&emsp;Remise {{discount}}% : {{discountAmount}}&nbsp;€</span>
        </td>
        <td style="text-align: right;">
          <span><nobr>{{totalLine}} €</nobr></span>
        </td>
      </tr>
    `
};
