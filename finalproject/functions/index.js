const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

// Low Inventory Alert
exports.notifyLowInventory = functions.firestore
	.document("products/{productId}")
	.onUpdate((change, context) => {
		const newValue = change.after.data();
		if (newValue.stock < newValue.reorderLevel) {
			const payload = {
				notification: {
					title: "Low Inventory Alert",
					body:
						"Some products are below their reorder level. " +
						"Please review inventory.",
					image: "https://yourapp.com/image.png"
				},
				data: { alertType: "InventoryAlert" },
			};
			return admin.messaging().sendToTopic("inventory-alerts", payload);
		}
		return null;
	});

// Out-of-Stock Alert
exports.notifyOutOfStock = functions.firestore
	.document("products/{productId}")
	.onUpdate((change, context) => {
		const newValue = change.after.data();
		if (newValue.stock === 0) {
			const payload = {
				notification: {
					title: "Out-of-Stock Alert",
					body:
						"Product " + newValue.name +
						" is out of stock. Immediate restocking is required.",
					image: "https://yourapp.com/image.png"
				},
				data: { alertType: "OutOfStockAlert" },
			};
			return admin.messaging().sendToTopic("inventory-alerts", payload);
		}
		return null;
	});

// Expiry Date Alert
exports.notifyExpiryDate = functions.firestore
	.document("products/{productId}")
	.onUpdate((change, context) => {
		const newValue = change.after.data();
		const expiryDate = new Date(newValue.expiry);
		const now = new Date();
		const daysToExpiry = (expiryDate - now) / (1000 * 60 * 60 * 24);
		if (daysToExpiry < 7) {
			const payload = {
				notification: {
					title: "Expiry Date Alert",
					body:
						"Some products are nearing their expiration date. " +
						"Please check and remove expired items.",
					image: "https://yourapp.com/image.png"
				},
				data: { alertType: "ExpiryAlert" },
			};
			return admin.messaging().sendToTopic("inventory-alerts", payload);
		}
		return null;
	});

// High Sales Alert
exports.notifyHighSales = functions.firestore
	.document("products/{productId}")
	.onUpdate((change, context) => {
		const newValue = change.after.data();
		if (newValue.sales && newValue.sales > 100) {
			const payload = {
				notification: {
					title: "High Sales Alert",
					body:
						"Top selling products have reached high sales volume this period. " +
						"Consider restocking or promotions.",
					image: "https://yourapp.com/image.png"
				},
				data: { alertType: "HighSalesAlert" },
			};
			return admin.messaging().sendToTopic("inventory-alerts", payload);
		}
		return null;
	});

// New Product Added Alert
exports.notifyNewProduct = functions.firestore
	.document("products/{productId}")
	.onCreate((snap, context) => {
		const newValue = snap.data();
		const payload = {
			notification: {
				title: "New Product Added",
				body:
					"A new product has been added to the inventory. " +
					"Please review details.",
				image: "https://yourapp.com/image.png"
			},
			data: { alertType: "NewProductAlert" },
		};
		return admin.messaging().sendToTopic("inventory-alerts", payload);
	});

// Price Change Alert
exports.notifyPriceChange = functions.firestore
	.document("products/{productId}")
	.onUpdate((change, context) => {
		const before = change.before.data();
		const after = change.after.data();
		if (before.price !== after.price) {
			const payload = {
				notification: {
					title: "Price Change Alert",
					body:
						"Product prices have changed. " +
						"Please review updated pricing.",
					image: "https://yourapp.com/image.png"
				},
				data: { alertType: "PriceChangeAlert" },
			};
			return admin.messaging().sendToTopic("inventory-alerts", payload);
		}
		return null;
	});
/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {setGlobalOptions} = require("firebase-functions");
const {onRequest} = require("firebase-functions/https");
const logger = require("firebase-functions/logger");

// For cost control, you can set the maximum number of containers that can be
// running at the same time. This helps mitigate the impact of unexpected
// traffic spikes by instead downgrading performance. This limit is a
// per-function limit. You can override the limit for each function using the
// `maxInstances` option in the function's options, e.g.
// `onRequest({ maxInstances: 5 }, (req, res) => { ... })`.
// NOTE: setGlobalOptions does not apply to functions using the v1 API. V1
// functions should each use functions.runWith({ maxInstances: 10 }) instead.
// In the v1 API, each function can only serve one request per container, so
// this will be the maximum concurrent request count.
setGlobalOptions({ maxInstances: 10 });

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
