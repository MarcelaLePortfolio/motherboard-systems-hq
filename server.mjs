import express from 'express';

const app = express();
// FIX: Use environment variable PORT or default to 3000
const PORT = process.env.PORT || 3000;

app.get('/', (req, res) => {
  res.send(`Motherboard Systems HQ - Service Active on port ${PORT}!`);
});

app.listen(PORT, () => {
    console.log(`Server listening on port ${PORT}`);
});
