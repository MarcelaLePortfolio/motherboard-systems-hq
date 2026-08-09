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

export interface MatildaProjectContextSegmentCandidate {
  relativePath: string;
  sourceStartLine: number;
  sourceEndLine: number;
  text: string;
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
  lineNumber: number
): MatildaBoundedExcerptReadResult | null {
  try {
    const stat = fs.statSync(absolutePath);

    if (!stat.isFile() || stat.size > 1_000_000) {
      return null;
    }

    const lines = fs.readFileSync(absolutePath, "utf8").split(/\r?\n/);
    const start = Math.max(0, lineNumber - 3);
    const end = Math.min(lines.length, lineNumber + 2);
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
      sourceStartLine:
        input.sourceStartLine + segmentStartIndex,
      sourceEndLine:
        input.sourceStartLine + exclusiveEndIndex - 1,
      text: segmentLines.join("\n"),
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
      {
        relativePath: string;
        lineNumber: number;
        score: number;
      }
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

    const selectedCandidates = [
      ...runtimeCandidates.slice(0, 3),
      ...documentCandidates.slice(0, 3),
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
        candidate.lineNumber
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
