import type { RequestHandler } from "express";
import {
  createPublicKey,
  verify as verifySignature,
} from "node:crypto";

type JwtHeader = {
  alg?: string;
  kid?: string;
  typ?: string;
};

type JwtClaims = {
  iss?: string;
  aud?: string | string[];
  exp?: number;
  nbf?: number;
  iat?: number;
};

type Jwk = {
  kty?: string;
  kid?: string;
  alg?: string;
  use?: string;
  n?: string;
  e?: string;
};

type Jwks = {
  keys?: Jwk[];
};

const MAX_TOKEN_LENGTH = 16384;
const JWKS_TIMEOUT_MS = 5000;
const JWKS_CACHE_MS = 300000;

function decodeBase64Url(value: string): Buffer {
  if (!/^[A-Za-z0-9_-]+$/.test(value)) {
    throw new Error("Invalid base64url encoding");
  }

  return Buffer.from(value, "base64url");
}

function decodeJson<T>(value: string): T {
  return JSON.parse(decodeBase64Url(value).toString("utf8")) as T;
}

function getConfiguration() {
  const teamDomain = process.env.CF_ACCESS_TEAM_DOMAIN?.trim();
  const audience = process.env.CF_ACCESS_AUD?.trim();

  if (!teamDomain || !audience) {
    throw new Error("Cloudflare Access configuration missing");
  }

  const url = new URL(teamDomain);

  if (
    url.protocol !== "https:" ||
    url.username ||
    url.password ||
    url.port ||
    url.pathname !== "/" ||
    url.search ||
    url.hash ||
    !url.hostname.endsWith(".cloudflareaccess.com")
  ) {
    throw new Error("Invalid Cloudflare Access team domain");
  }

  return {
    issuer: url.origin,
    audience,
    jwksUrl: `${url.origin}/cdn-cgi/access/certs`,
  };
}

let cachedJwks: Jwks | undefined;
let cachedIssuer: string | undefined;
let cachedUntil = 0;

async function getJwks(issuer: string, url: string): Promise<Jwks> {
  if (
    cachedJwks &&
    cachedIssuer === issuer &&
    Date.now() < cachedUntil
  ) {
    return cachedJwks;
  }

  const response = await fetch(url, {
    signal: AbortSignal.timeout(JWKS_TIMEOUT_MS),
    headers: { Accept: "application/json" },
  });

  if (!response.ok) {
    throw new Error("Cloudflare Access JWKS unavailable");
  }

  const jwks = (await response.json()) as Jwks;

  if (!Array.isArray(jwks.keys)) {
    throw new Error("Invalid Cloudflare Access JWKS");
  }

  cachedJwks = jwks;
  cachedIssuer = issuer;
  cachedUntil = Date.now() + JWKS_CACHE_MS;

  return jwks;
}

async function verifyAccessToken(token: string): Promise<void> {
  if (token.length > MAX_TOKEN_LENGTH) {
    throw new Error("Token too large");
  }

  const segments = token.split(".");

  if (segments.length !== 3 || segments.some((part) => !part)) {
    throw new Error("Invalid JWT structure");
  }

  const [encodedHeader, encodedClaims, encodedSignature] = segments;
  const header = decodeJson<JwtHeader>(encodedHeader);
  const claims = decodeJson<JwtClaims>(encodedClaims);

  if (
    header.alg !== "RS256" ||
    typeof header.kid !== "string" ||
    !header.kid
  ) {
    throw new Error("Unsupported JWT signing algorithm");
  }

  const config = getConfiguration();
  const jwks = await getJwks(config.issuer, config.jwksUrl);

  const key = jwks.keys?.find(
    (candidate) =>
      candidate.kid === header.kid &&
      candidate.kty === "RSA" &&
      candidate.n &&
      candidate.e &&
      (!candidate.use || candidate.use === "sig") &&
      (!candidate.alg || candidate.alg === "RS256"),
  );

  if (!key) {
    throw new Error("JWT signing key not found");
  }

  const publicKey = createPublicKey({
    key: {
      kty: "RSA",
      n: key.n!,
      e: key.e!,
    },
    format: "jwk",
  });

  const validSignature = verifySignature(
    "RSA-SHA256",
    Buffer.from(`${encodedHeader}.${encodedClaims}`),
    publicKey,
    decodeBase64Url(encodedSignature),
  );

  if (!validSignature) {
    throw new Error("Invalid JWT signature");
  }

  const now = Math.floor(Date.now() / 1000);
  const audiences = Array.isArray(claims.aud)
    ? claims.aud
    : [claims.aud];

  if (
    claims.iss !== config.issuer ||
    !audiences.includes(config.audience) ||
    typeof claims.exp !== "number" ||
    !Number.isFinite(claims.exp) ||
    claims.exp <= now ||
    (claims.nbf !== undefined &&
      (typeof claims.nbf !== "number" ||
        !Number.isFinite(claims.nbf) ||
        claims.nbf > now)) ||
    (claims.iat !== undefined &&
      (typeof claims.iat !== "number" ||
        !Number.isFinite(claims.iat) ||
        claims.iat > now))
  ) {
    throw new Error("Invalid JWT claims");
  }
}

export const requireCloudflareAccess: RequestHandler = async (
  request,
  response,
  next,
) => {
  const token = request.header("Cf-Access-Jwt-Assertion");

  if (!token) {
    response.status(401).json({ error: "Unauthorized" });
    return;
  }

  try {
    await verifyAccessToken(token);
    next();
  } catch {
    response.status(401).json({ error: "Unauthorized" });
  }
};
