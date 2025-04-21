import dotenv from 'dotenv'; // Import dotenv
import express, { Express, Request, Response, Application } from 'express';
import path from 'path';
import { apiReference } from '@scalar/express-api-reference';

// --- Load Environment Variables ---
// Load variables from .env file into process.env
// Should be one of the first things to run
dotenv.config();
// --------------------------------

const app: Application = express();

// --- Use environment variable for PORT ---
// process.env will now have values from .env (if loaded successfully)
const port = process.env.PORT || 3001; // Keep the default just in case
// ----------------------------------------

// --- Scalar API Reference Setup ---
const openApiSpecUrl = '/static-docs/openapi.yaml'; // Using the static served version
const docsPath = path.resolve(process.cwd(), 'docs');
app.use('/static-docs', express.static(docsPath)); // Serve docs statically

app.use(
  '/docs',
  apiReference({
    spec: {
      url: openApiSpecUrl,
    },
  }),
);
// ---------------------------------

app.get('/', (req: Request, res: Response) => {
  res.send('Welcome to the Wakafi Backend API! View docs at /docs');
});

// --- Example: Accessing another env variable ---
console.log(`[config]: Loaded Mongo URI: ${process.env.MONGO_URI ? 'Yes' : 'No'}`);
// Avoid logging the actual URI/secret in production logs!
// ---------------------------------------------

app.listen(port, () => {
  console.log(`[server]: Server is running at http://localhost:${port}`);
  console.log(`[server]: Test YAML access at http://localhost:${port}/static-docs/openapi.yaml`);
  console.log(`[server]: API Docs available at http://localhost:${port}/docs`);
