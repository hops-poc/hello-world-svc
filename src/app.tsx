import { createRoot } from "react-dom/client";

function App() {
  return <h1>hello-world-svc</h1>;
}

createRoot(document.getElementById("root")!).render(<App />);
