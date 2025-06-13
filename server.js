const express = require('express');
const stripe = require('stripe')('sk_test_51QT4wWGGUyr9vbxpWt2w5qyh7zwrwU5ccyh0SFp8Sjnnhi1bya5VObFWzFL4gGpMdVBdHM2Y2leJf4hDQdgXtcvU00LUhJC5iU'); // Replace with your actual Stripe secret key
const bodyParser = require('body-parser');
const path = require('path'); // Add this line to import the path module

const app = express();
const port = 3000;

// Middleware
app.use(bodyParser.json());
app.use(express.static(path.join(__dirname))); // Serve static files from the project directory

// Root route
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'index.html')); // Change this if your HTML file is named differently
});

// Endpoint to create a payment intent
app.post('/create-payment-intent', async (req, res) => {
    const { amount, currency } = req.body;

    try {
        const paymentIntent = await stripe.paymentIntents.create({
            amount,
            currency,
        });
        res.send({ clientSecret: paymentIntent.client_secret });
    } catch (error) {
        res.status(400).send({ error: error.message });
    }
});

// Start the server
app.listen(port, () => {
    console.log(`Server running at http://127.0.0.1:${port}/`);
});
//sk_test_51QT4wWGGUyr9vbxpWt2w5qyh7zwrwU5ccyh0SFp8Sjnnhi1bya5VObFWzFL4gGpMdVBdHM2Y2leJf4hDQdgXtcvU00LUhJC5iU