import { createServer } from 'http';
import matildaHandler from './api/matilda';

const server = createServer(async (req, res) => {
  if (req.url === '/api/matilda') {
    return matildaHandler(req, res);
  }

  res.writeHead(200, { 'Content-Type': 'text/plain' });
  res.end('Motherboard Local Server Online');
});

const PORT = 59272;
server.listen(PORT, () => {
  console.log(`🌐 Local server listening on http://localhost:${PORT}`);
});
