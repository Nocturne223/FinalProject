const admin = require("firebase-admin");
const serviceAccount = require("./ServiceAccountKey.json");

// TODO: Add your project data below
admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    // databaseURL: "https://<your-project-id>.firebaseio.com" // Uncomment and set if needed
});

const db = admin.firestore();

// Low Inventory Alert
function sendLowInventoryAlert(product) {
    const payload = {
        notification: {
            title: "Low Inventory Alert",
            body: "Some products are below their reorder level. Please review inventory.",
            // image: "https://yourapp.com/image.png" // Optional
        },
        data: { alertType: "InventoryAlert" }
    };
    admin.messaging().send({
        topic: "inventory-alerts",
        ...payload
    })
    .then(response => console.log("Low Inventory Alert sent:", response))
    .catch(error => console.error("Error sending Low Inventory Alert:", error));
}

// Out-of-Stock Alert
function sendOutOfStockAlert(product) {
    const payload = {
        notification: {
            title: "Out-of-Stock Alert",
            body: "One or more products are out of stock. Immediate restocking is required.",
            // image: "https://yourapp.com/image.png"
        },
        data: { alertType: "OutOfStockAlert" }
    };
    admin.messaging().send({
        topic: "inventory-alerts",
        ...payload
    })
    .then(response => console.log("Out-of-Stock Alert sent:", response))
    .catch(error => console.error("Error sending Out-of-Stock Alert:", error));
}

// Expiry Date Alert
function sendExpiryAlert(product) {
    const payload = {
        notification: {
            title: "Expiry Date Alert",
            body: "Some products are nearing their expiration date. Please check and remove expired items.",
            // image: "https://yourapp.com/image.png"
        },
        data: { alertType: "ExpiryAlert" }
    };
    admin.messaging().send({
        topic: "inventory-alerts",
        ...payload
    })
    .then(response => console.log("Expiry Date Alert sent:", response))
    .catch(error => console.error("Error sending Expiry Date Alert:", error));
}

// High Sales Alert
function sendHighSalesAlert(product) {
    const payload = {
        notification: {
            title: "High Sales Alert",
            body: "Top selling products have reached high sales volume this period. Consider restocking or promotions.",
            // image: "https://yourapp.com/image.png"
        },
        data: { alertType: "HighSalesAlert" }
    };
    admin.messaging().send({
        topic: "inventory-alerts",
        ...payload
    })
    .then(response => console.log("High Sales Alert sent:", response))
    .catch(error => console.error("Error sending High Sales Alert:", error));
}

// New Product Added Alert
function sendNewProductAlert(product) {
    const payload = {
        notification: {
            title: "New Product Added",
            body: "A new product has been added to the inventory. Please review details.",
            // image: "https://yourapp.com/image.png"
        },
        data: { alertType: "NewProductAlert" }
    };
    admin.messaging().send({
        topic: "inventory-alerts",
        ...payload
    })
    .then(response => console.log("New Product Alert sent:", response))
    .catch(error => console.error("Error sending New Product Alert:", error));
}

// Price Change Alert
function sendPriceChangeAlert(product) {
    const payload = {
        notification: {
            title: "Price Change Alert",
            body: "Product prices have changed. Please review updated pricing.",
            // image: "https://yourapp.com/image.png"
        },
        data: { alertType: "PriceChangeAlert" }
    };
    admin.messaging().send({
        topic: "inventory-alerts",
        ...payload
    })
    .then(response => console.log("Price Change Alert sent:", response))
    .catch(error => console.error("Error sending Price Change Alert:", error));
}


// Firestore listeners for alerts
let isInitialLoad = true;
db.collection("products").onSnapshot(snapshot => {
    if (isInitialLoad) {
        isInitialLoad = false;
        return; // Skip alerts for initial load
    }
    snapshot.docChanges().forEach(change => {
        const data = change.doc.data();
        if (change.type === "modified") {
            // Low Inventory
                    if (data.stock <= data.reorderLevel) {
                sendLowInventoryAlert(data);
            }
            // Out-of-Stock
            if (data.stock === 0) {
                sendOutOfStockAlert(data);
            }
            // Expiry Date
            if (data.expiry) {
                const expiryDate = new Date(data.expiry);
                const now = new Date();
                const daysToExpiry = (expiryDate - now) / (1000 * 60 * 60 * 24);
                if (daysToExpiry < 7) {
                    sendExpiryAlert(data);
                }
            }
            // High Sales
            if (data.sales && data.sales > 100) {
                sendHighSalesAlert(data);
            }
            // Price Change (simple check, you may want to store previous price)
            // This is a placeholder, you may need to implement a better check
            // if (previousPrice !== undefined && previousPrice !== data.price) {
            //     sendPriceChangeAlert(data);
            // }
        }
        if (change.type === "added") {
            sendNewProductAlert(data);
        }
    });
});

console.log("Inventory notifier is running...");
