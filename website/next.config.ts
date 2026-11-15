import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  // A self-contained server in .next/standalone, for the Docker image that
  // Coolify runs (see Dockerfile).
  output: "standalone",
};

export default nextConfig;
