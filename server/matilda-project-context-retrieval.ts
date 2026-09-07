import fs from "node:fs";
import path from "node:path";
import { execFileSync } from "node:child_process";

const ALLOWED_ROOTS = new Set([
  "client",
  "server",
  "routes",
  "db",
  "src",
  "docs",
  "projects",
  "policy",
  "privacy",
  "legal",
  "patent",
]);

const ALLOWED_EXTENSIONS = new Set([
  ".ts",
  ".tsx",
  ".js",
  ".mjs",
  ".cjs",
  ".md",
  ".json",
  ".sql",
  ".css",
]);

const EXCLUDED_SEGMENTS = new Set([
  "node_modules",
  "dist",
  "_archive",
  "archive",
  "snapshots",
  "scripts_backup",
  "scripts_backup_2",
  "ts-backup",
  "_dashboard_candidate_previews",
  "frontend-rebuild-handoff-v1",
]);

const MAX_QUERY_TERMS = 8;
const MAX_MATCHES = 6;
const MAX_EXCERPT_CHARACTERS = 900;
const MAX_STRUCTURAL_EXCERPT_LINES = 13;

export interface MatildaProjectContextExcerpt {
  projectId: string;
  relativePath: string;
  lineNumber: number;
  excerpt: string;
  provenance: "git_tracked_project_file";
  authorityStatus: "candidate_evidence_not_authority";
}

export interface MatildaProjectContextRetrievalResult {
  projectId: string;
  projectRootPath: string | null;
  available: boolean;
  searched: boolean;
  queryTerms: string[];
  excerpts: MatildaProjectContextExcerpt[];
  projectContextSegmentCandidates:
    MatildaProjectContextSegmentCandidate[];
  warning: string | null;
}

function extractQueryTerms(message: string): string[] {
  const stopWords = new Set([
    "about",
    "after",
    "again",
    "also",
    "because",
    "before",
    "could",
    "does",
    "during",
    "from",
    "happened",
    "have",
    "hey",
    "how",
    "into",
    "just",
    "matilda",
    "more",
    "need",
    "now",
    "project",
    "right",
    "should",
    "still",
    "that",
    "testing",
    "their",
    "there",
    "these",
    "they",
    "this",
    "what",
    "when",
    "where",
    "which",
    "why",
    "with",
    "work",
    "would",
    "your",
  ]);

  return Array.from(
    new Set(
      message
        .toLowerCase()
        .match(/[a-z0-9][a-z0-9_-]{2,}/g)
        ?.filter((term) => !stopWords.has(term)) ?? []
    )
  )
    .sort((left, right) => right.length - left.length)
    .slice(0, MAX_QUERY_TERMS);
}

function isAllowedTrackedPath(relativePath: string): boolean {
  const normalized = relativePath.replaceAll("\\", "/");
  const parts = normalized.split("/").filter(Boolean);

  if (parts.length < 2 || !ALLOWED_ROOTS.has(parts[0])) {
    return false;
  }

  if (parts.some((part) => EXCLUDED_SEGMENTS.has(part))) {
    return false;
  }

  return ALLOWED_EXTENSIONS.has(path.extname(normalized).toLowerCase());
}

function resolveValidatedProjectRoot(
  projectRootPath: string
): string | null {
  const candidate = projectRootPath.trim();

  if (!candidate) {
    return null;
  }

  const resolved = path.isAbsolute(candidate)
    ? candidate
    : path.resolve(process.cwd(), candidate);

  if (
    !fs.existsSync(resolved) ||
    !fs.statSync(resolved).isDirectory() ||
    !fs.existsSync(path.join(resolved, ".git"))
  ) {
    return null;
  }

  return resolved;
}

export type MatildaProjectContextRetrievalOrigin =
  | "lexical"
  | "structural";

export interface MatildaProjectContextSegmentCandidate {
  relativePath: string;
  parentRelativePath: string;
  parentLineNumber: number;
  sourceStartLine: number;
  sourceEndLine: number;
  text: string;
  retrievalOrigin: MatildaProjectContextRetrievalOrigin;
}

interface MatildaBoundedExcerptReadResult {
  excerpt: string;
  metadata: {
    sourceStartLine: number;
    sourceEndLine: number;
    excerptTruncated: boolean;
  };
  boundedSourceLines: string[];
}

function readBoundedExcerpt(
  absolutePath: string,
  lineNumber: number,
  useStructuralUnitExcerpt = false
): MatildaBoundedExcerptReadResult | null {
  try {
    const stat = fs.statSync(absolutePath);

    if (!stat.isFile() || stat.size > 1_000_000) {
      return null;
    }

    const lines = fs.readFileSync(absolutePath, "utf8").split(/\r?\n/);

    let start = Math.max(0, lineNumber - 3);
    let end = Math.min(lines.length, lineNumber + 2);

    if (
      useStructuralUnitExcerpt &&
      lineNumber >= 1 &&
      lineNumber <= lines.length
    ) {
      const matchedIndex = lineNumber - 1;

      let structuralStart = matchedIndex;
      while (
        structuralStart > 0 &&
        lines[structuralStart - 1].trim() !== ""
      ) {
        structuralStart -= 1;
      }

      let structuralEnd = matchedIndex + 1;
      while (
        structuralEnd < lines.length &&
        lines[structuralEnd].trim() !== ""
      ) {
        structuralEnd += 1;
      }

      const structuralLength =
        structuralEnd - structuralStart;

      if (
        structuralLength <=
        MAX_STRUCTURAL_EXCERPT_LINES
      ) {
        start = structuralStart;
        end = structuralEnd;
      } else {
        const linesBeforeMatch = Math.floor(
          (MAX_STRUCTURAL_EXCERPT_LINES - 1) / 2
        );

        start = Math.max(
          0,
          matchedIndex - linesBeforeMatch
        );
        end = Math.min(
          lines.length,
          start + MAX_STRUCTURAL_EXCERPT_LINES
        );

        if (
          end - start <
          MAX_STRUCTURAL_EXCERPT_LINES
        ) {
          start = Math.max(
            0,
            end - MAX_STRUCTURAL_EXCERPT_LINES
          );
        }
      }
    }

    const boundedSourceLines = lines.slice(start, end);
    const boundedSource = boundedSourceLines
      .join("\n")
      .trim();

    return {
      excerpt: boundedSource.slice(0, MAX_EXCERPT_CHARACTERS),
      metadata: {
        sourceStartLine: start + 1,
        sourceEndLine: end,
        excerptTruncated:
          boundedSource.length > MAX_EXCERPT_CHARACTERS,
      },
      boundedSourceLines,
    };
  } catch {
    return null;
  }
}

function segmentBoundedProjectContextSource(input: {
  relativePath: string;
  matchedLineNumber: number;
  sourceStartLine: number;
  boundedSourceLines: readonly string[];
  retrievalOrigin: MatildaProjectContextRetrievalOrigin;
}): MatildaProjectContextSegmentCandidate[] {
  const segments: MatildaProjectContextSegmentCandidate[] = [];
  let segmentStartIndex: number | null = null;

  const flushSegment = (exclusiveEndIndex: number): void => {
    if (segmentStartIndex === null) {
      return;
    }

    const segmentLines = input.boundedSourceLines.slice(
      segmentStartIndex,
      exclusiveEndIndex
    );

    segments.push({
      relativePath: input.relativePath,
      parentRelativePath: input.relativePath,
      parentLineNumber: input.matchedLineNumber,
      sourceStartLine:
        input.sourceStartLine + segmentStartIndex,
      sourceEndLine:
        input.sourceStartLine + exclusiveEndIndex - 1,
      text: segmentLines.join("\n"),
      retrievalOrigin: input.retrievalOrigin,
    });

    segmentStartIndex = null;
  };

  for (
    let index = 0;
    index < input.boundedSourceLines.length;
    index += 1
  ) {
    if (input.boundedSourceLines[index].trim() === "") {
      flushSegment(index);
      continue;
    }

    if (segmentStartIndex === null) {
      segmentStartIndex = index;
    }
  }

  flushSegment(input.boundedSourceLines.length);

  return segments;
}

interface MatildaRankedProjectContextCandidate {
  relativePath: string;
  lineNumber: number;
  score: number;
  useStructuralUnitExcerpt?: boolean;
}

function escapeProjectContextRegExp(value: string): string {
  return value.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

function isTrackedProjectFile(
  projectRoot: string,
  relativePath: string
): boolean {
  if (!isAllowedTrackedPath(relativePath)) {
    return false;
  }

  try {
    const output = execFileSync(
      "git",
      [
        "-C",
        projectRoot,
        "ls-files",
        "--error-unmatch",
        "--",
        relativePath,
      ],
      {
        encoding: "utf8",
        stdio: ["ignore", "pipe", "ignore"],
      }
    );

    return output.trim() === relativePath;
  } catch {
    return false;
  }
}

function resolveLocalTrackedImport(input: {
  projectRoot: string;
  importerRelativePath: string;
  specifier: string;
}): string | null {
  if (!input.specifier.startsWith(".")) {
    return null;
  }

  const importerDirectory = path.posix.dirname(
    input.importerRelativePath.replaceAll("\\", "/")
  );
  const base = path.posix.normalize(
    path.posix.join(importerDirectory, input.specifier)
  );

  const candidates = [
    base,
    `${base}.ts`,
    `${base}.tsx`,
    `${base}.js`,
    `${base}.mjs`,
    `${base}.cjs`,
    path.posix.join(base, "index.ts"),
    path.posix.join(base, "index.tsx"),
    path.posix.join(base, "index.js"),
    path.posix.join(base, "index.mjs"),
    path.posix.join(base, "index.cjs"),
  ];

  for (const candidate of candidates) {
    const absolutePath = path.join(input.projectRoot, candidate);

    if (
      fs.existsSync(absolutePath) &&
      fs.statSync(absolutePath).isFile() &&
      isTrackedProjectFile(input.projectRoot, candidate)
    ) {
      return candidate;
    }
  }

  return null;
}

function exactQueryTermsOnLine(
  line: string,
  queryTerms: readonly string[]
): string[] {
  const tokens = new Set(
    line.toLowerCase().match(/[a-z0-9][a-z0-9_-]{2,}/g) ?? []
  );

  return queryTerms.filter((term) => tokens.has(term));
}

function extractIdentifiersOutsideStrings(line: string): string[] {
  const stripped = line
    .replace(/"[^"]*"|'[^']*'|`[^`]*`/g, " ")
    .replace(/\/\/.*$/g, " ");

  const identifiers =
    stripped.match(/\b[A-Za-z_$][A-Za-z0-9_$]*\b/g) ?? [];

  const ignored = new Set([
    "import",
    "from",
    "type",
    "const",
    "let",
    "var",
    "return",
    "if",
    "else",
    "true",
    "false",
    "null",
    "undefined",
    "new",
    "function",
  ]);

  return Array.from(
    new Set(identifiers.filter((identifier) => !ignored.has(identifier)))
  );
}

function findExactTokenStructuralAnchor(input: {
  projectRoot: string;
  relativePath: string;
  queryTerms: readonly string[];
}): {
  lineNumber: number;
  identifiers: string[];
} | null {
  if (!/\.(?:ts|tsx|js|jsx)$/.test(input.relativePath)) {
    return null;
  }

  try {
    const lines = fs
      .readFileSync(
        path.join(input.projectRoot, input.relativePath),
        "utf8"
      )
      .split(/\r?\n/);

    let best:
      | {
          lineNumber: number;
          exactTermCount: number;
          quotedExactTermCount: number;
          identifiers: string[];
        }
      | null = null;

    for (let index = 0; index < lines.length; index += 1) {
      const line = lines[index];
      const exactTerms = exactQueryTermsOnLine(
        line,
        input.queryTerms
      );

      if (exactTerms.length === 0) {
        continue;
      }

      const lowerLine = line.toLowerCase();
      const quotedExactTermCount = exactTerms.filter(
        (term) =>
          lowerLine.includes(`"${term}"`) ||
          lowerLine.includes(`'${term}'`) ||
          lowerLine.includes(`\`${term}\``)
      ).length;

      const candidate = {
        lineNumber: index + 1,
        exactTermCount: exactTerms.length,
        quotedExactTermCount,
        identifiers: extractIdentifiersOutsideStrings(line),
      };

      if (
        !best ||
        candidate.quotedExactTermCount > best.quotedExactTermCount ||
        (
          candidate.quotedExactTermCount === best.quotedExactTermCount &&
          candidate.exactTermCount > best.exactTermCount
        ) ||
        (
          candidate.quotedExactTermCount === best.quotedExactTermCount &&
          candidate.exactTermCount === best.exactTermCount &&
          candidate.lineNumber < best.lineNumber
        )
      ) {
        best = candidate;
      }
    }

    return best
      ? {
          lineNumber: best.lineNumber,
          identifiers: best.identifiers,
        }
      : null;
  } catch {
    return null;
  }
}

function parseLocalNamedImportBindings(input: {
  projectRoot: string;
  relativePath: string;
  source: string;
}): Array<{
  localName: string;
  sourcePath: string;
}> {
  const bindings: Array<{
    localName: string;
    sourcePath: string;
  }> = [];

  const pattern =
    /\bimport\s+(?:type\s+)?\{([^}]+)\}\s+from\s+["']([^"']+)["']/g;

  let match: RegExpExecArray | null;

  while ((match = pattern.exec(input.source)) !== null) {
    const sourcePath = resolveLocalTrackedImport({
      projectRoot: input.projectRoot,
      importerRelativePath: input.relativePath,
      specifier: match[2],
    });

    if (!sourcePath) {
      continue;
    }

    for (const rawBinding of match[1].split(",")) {
      const cleaned = rawBinding.trim().replace(/^type\s+/, "");

      if (!cleaned) {
        continue;
      }

      const [importedName, alias] = cleaned.split(/\s+as\s+/);

      bindings.push({
        localName: (alias ?? importedName).trim(),
        sourcePath,
      });
    }
  }

  return bindings;
}

function findBestLexicalAnchorInTrackedFile(input: {
  projectRoot: string;
  relativePath: string;
  queryTerms: readonly string[];
}): MatildaRankedProjectContextCandidate | null {
  try {
    const lines = fs
      .readFileSync(
        path.join(input.projectRoot, input.relativePath),
        "utf8"
      )
      .split(/\r?\n/);
    const normalizedPath = input.relativePath.toLowerCase();

    let best: MatildaRankedProjectContextCandidate | null = null;

    for (let index = 0; index < lines.length; index += 1) {
      const matchedLine = lines[index].toLowerCase();

      if (
        !input.queryTerms.some((term) =>
          matchedLine.includes(term)
        )
      ) {
        continue;
      }

      const score = input.queryTerms.reduce((total, term) => {
        const pathScore = normalizedPath.includes(term) ? 6 : 0;
        const lineScore = matchedLine.includes(term) ? 1 : 0;

        return total + pathScore + lineScore;
      }, 0);

      if (!best || score > best.score) {
        best = {
          relativePath: input.relativePath,
          lineNumber: index + 1,
          score,
        };
      }
    }

    return best;
  } catch {
    return null;
  }
}

function discoverBoundedStructuralProjectContextCandidate(input: {
  projectRoot: string;
  queryTerms: readonly string[];
  lexicalRuntimeCandidates: readonly MatildaRankedProjectContextCandidate[];
}): MatildaRankedProjectContextCandidate | null {
  const existingPaths = new Set(
    input.lexicalRuntimeCandidates.map(
      (candidate) => candidate.relativePath
    )
  );

  for (const lexicalCandidate of input.lexicalRuntimeCandidates) {
    const anchor = findExactTokenStructuralAnchor({
      projectRoot: input.projectRoot,
      relativePath: lexicalCandidate.relativePath,
      queryTerms: input.queryTerms,
    });

    if (!anchor || anchor.identifiers.length === 0) {
      continue;
    }

    let source: string;

    try {
      source = fs.readFileSync(
        path.join(
          input.projectRoot,
          lexicalCandidate.relativePath
        ),
        "utf8"
      );
    } catch {
      continue;
    }

    const imports = parseLocalNamedImportBindings({
      projectRoot: input.projectRoot,
      relativePath: lexicalCandidate.relativePath,
      source,
    });

    for (const identifier of anchor.identifiers) {
      const escaped = escapeProjectContextRegExp(identifier);
      const declarationPattern = new RegExp(
        `\\b${escaped}\\??\\s*:\\s*([A-Za-z_$][A-Za-z0-9_$]*)`,
        "g"
      );

      let declarationMatch: RegExpExecArray | null;

      while (
        (declarationMatch = declarationPattern.exec(source)) !== null
      ) {
        const governingSymbol = declarationMatch[1];
        const imported = imports.find(
          (entry) => entry.localName === governingSymbol
        );

        if (
          !imported ||
          existingPaths.has(imported.sourcePath)
        ) {
          continue;
        }

        const structuralCandidate =
          findBestLexicalAnchorInTrackedFile({
            projectRoot: input.projectRoot,
            relativePath: imported.sourcePath,
            queryTerms: input.queryTerms,
          });

        if (structuralCandidate) {
          return {
            ...structuralCandidate,
            useStructuralUnitExcerpt: true,
          };
        }
      }
    }
  }

  return null;
}

export function retrieveMatildaProjectContext(input: {
  projectId: string;
  projectRootPath?: string | null;
  message: string;
}): MatildaProjectContextRetrievalResult {
  const projectId = input.projectId.trim();
  const queryTerms = extractQueryTerms(input.message);
  const projectRoot = resolveValidatedProjectRoot(
    input.projectRootPath ?? ""
  );

  if (!projectRoot) {
    return {
      projectId,
      projectRootPath: input.projectRootPath ?? null,
      available: false,
      searched: false,
      queryTerms,
      excerpts: [],
      projectContextSegmentCandidates: [],
      warning:
        "The registered project repository is unavailable at its configured path.",
    };
  }

  if (queryTerms.length === 0) {
    return {
      projectId,
      projectRootPath: projectRoot,
      available: true,
      searched: false,
      queryTerms,
      excerpts: [],
      projectContextSegmentCandidates: [],
      warning: null,
    };
  }

  try {
    const pattern = queryTerms
      .map((term) => term.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"))
      .join("|");

    const output = execFileSync(
      "git",
      [
        "-C",
        projectRoot,
        "grep",
        "-n",
        "-I",
        "-E",
        "--",
        pattern,
        ...Array.from(ALLOWED_ROOTS).map((root) => `${root}/`),
      ],
      {
        encoding: "utf8",
        maxBuffer: 8_000_000,
        stdio: ["ignore", "pipe", "ignore"],
      }
    );

    const candidatesByPath = new Map<
      string,
      MatildaRankedProjectContextCandidate
    >();

    for (const line of output.split(/\r?\n/)) {
      if (!line.trim()) {
        continue;
      }

      const match = line.match(/^(.+?):(\d+):(.*)$/);

      if (!match) {
        continue;
      }

      const relativePath = match[1];
      const lineNumber = Number(match[2]);
      const matchedLine = match[3].toLowerCase();

      if (
        !Number.isInteger(lineNumber) ||
        !isAllowedTrackedPath(relativePath)
      ) {
        continue;
      }

      const normalizedPath = relativePath.toLowerCase();
      const score = queryTerms.reduce((total, term) => {
        const pathScore = normalizedPath.includes(term) ? 6 : 0;
        const lineScore = matchedLine.includes(term) ? 1 : 0;

        return total + pathScore + lineScore;
      }, 0);

      const existing = candidatesByPath.get(relativePath);

      if (!existing || score > existing.score) {
        candidatesByPath.set(relativePath, {
          relativePath,
          lineNumber,
          score,
        });
      }
    }

    const rankedCandidates = Array.from(candidatesByPath.values()).sort(
      (left, right) =>
        right.score - left.score ||
        left.relativePath.localeCompare(right.relativePath)
    );

    const runtimeCandidates = rankedCandidates.filter(
      (candidate) => !candidate.relativePath.startsWith("docs/")
    );
    const documentCandidates = rankedCandidates.filter(
      (candidate) => candidate.relativePath.startsWith("docs/")
    );

    const lexicalRuntimeCandidates =
      runtimeCandidates.slice(0, 3);
    const structuralCandidate =
      discoverBoundedStructuralProjectContextCandidate({
        projectRoot,
        queryTerms,
        lexicalRuntimeCandidates,
      });

    const selectedCandidates = [
      ...lexicalRuntimeCandidates,
      ...(structuralCandidate ? [structuralCandidate] : []),
      ...documentCandidates.slice(
        0,
        structuralCandidate ? 2 : 3
      ),
    ];

    for (const candidate of rankedCandidates) {
      if (selectedCandidates.length >= MAX_MATCHES) {
        break;
      }

      if (
        !selectedCandidates.some(
          (selected) => selected.relativePath === candidate.relativePath
        )
      ) {
        selectedCandidates.push(candidate);
      }
    }

    const excerpts: MatildaProjectContextExcerpt[] = [];
    const projectContextSegmentCandidates:
      MatildaProjectContextSegmentCandidate[] = [];

    for (const candidate of selectedCandidates.slice(0, MAX_MATCHES)) {
      const boundedExcerpt = readBoundedExcerpt(
        path.join(projectRoot, candidate.relativePath),
        candidate.lineNumber,
        candidate.useStructuralUnitExcerpt === true
      );

      if (!boundedExcerpt) {
        continue;
      }

      const admittedExcerpt =
        boundedExcerpt.excerpt;

      const sourceSegments =
        segmentBoundedProjectContextSource({
          relativePath: candidate.relativePath,
          matchedLineNumber: candidate.lineNumber,
          sourceStartLine:
            boundedExcerpt.metadata.sourceStartLine,
          boundedSourceLines:
            boundedExcerpt.boundedSourceLines,
          retrievalOrigin:
            candidate.useStructuralUnitExcerpt === true
              ? "structural"
              : "lexical",
        });

      let admittedCharacters = 0;

      for (const segment of sourceSegments) {
        const segmentText = segment.text.trim();

        if (!segmentText) {
          continue;
        }

        const segmentOffset =
          admittedExcerpt.indexOf(
            segmentText,
            admittedCharacters,
          );

        if (segmentOffset < 0) {
          continue;
        }

        const segmentEndOffset =
          segmentOffset + segmentText.length;

        if (
          segmentEndOffset >
          admittedExcerpt.length
        ) {
          continue;
        }

        projectContextSegmentCandidates.push(
          segment,
        );

        admittedCharacters =
          segmentEndOffset;
      }

      excerpts.push({
        projectId,
        relativePath: candidate.relativePath,
        lineNumber: candidate.lineNumber,
        excerpt: boundedExcerpt.excerpt,
        provenance: "git_tracked_project_file",
        authorityStatus: "candidate_evidence_not_authority",
      });
    }

    return {
      projectId,
      projectRootPath: projectRoot,
      available: true,
      searched: true,
      queryTerms,
      excerpts,
      projectContextSegmentCandidates,
      warning: null,
    };
  } catch (error) {
    const status =
      typeof error === "object" &&
      error !== null &&
      "status" in error
        ? Number((error as { status?: unknown }).status)
        : null;

    if (status === 1) {
      return {
        projectId,
        projectRootPath: projectRoot,
        available: true,
        searched: true,
        queryTerms,
        excerpts: [],
        projectContextSegmentCandidates: [],
        warning: null,
      };
    }

    return {
      projectId,
      projectRootPath: projectRoot,
      available: true,
      searched: false,
      queryTerms,
      excerpts: [],
      projectContextSegmentCandidates: [],
      warning: "Project context retrieval was unavailable for this request.",
    };
  }
}
