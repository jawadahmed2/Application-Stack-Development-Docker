const express = require('express');

const app = express();
const port = 3000;

app.get('/', (req, res) => {
  res.send('<h3>Hello From The Node Js</h3>');
});

app.listen(port, () => {
  console.log(`App is running on port ${port}`);
});
