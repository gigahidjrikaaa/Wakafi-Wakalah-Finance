import express, { Express, Request, Response, Application } from 'express';

// Create an Express application instance
const app: Application = express();

// Define the port the server will listen on
// Use environment variable if available, otherwise default to 3001
const port = process.env.PORT || 3001;

// Define a simple root route (GET request to '/')
app.get('/', (req: Request, res: Response) => {
  res.send('Welcome to the Wakafi Backend API!');
});

// Start the server and listen on the specified port
app.listen(port, () => {
  console.log(`[server]: Server is running at http://localhost:${port}`);
});