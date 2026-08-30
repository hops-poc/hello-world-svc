import { createRoot } from "react-dom/client";
import { useEffect, useState } from "react";

function App() {
  const [version, setVersion] = useState<{ env: string; build: string } | null>(null);

  useEffect(() => {
    fetch("/api/version")
      .then((res) => res.json())
      .then(setVersion);
  }, []);

  return (
    <>
      <h1>hello-world-svc</h1>
      {version && (
        <p>
          env: {version.env} · build: {version.build}
        </p>
      )}
    </>
  );
}

createRoot(document.getElementById("root")!).render(<App />);
