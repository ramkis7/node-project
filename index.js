const express = require('express');
const app = express();

const PORT = process.env.PORT || 3000;

// VULN 1: hardcoded secret (seeded)
const ADMIN_PASSWORD = "P@ssw0rd123"; // <-- vulnerability: hardcoded credentials

app.get('/', (req, res) => {
  res.send('Hello from Capstone App');
});

// VULN 2: insecure use of eval (seeded)
app.get('/run', (req, res) => {
  // developer convenience API — insecure
  const code = req.query.code || '1+1';
  // insecure
  const result = eval(code);
  res.json({ result });
});

app.listen(PORT, () => console.log(`Server running on ${PORT}`));
