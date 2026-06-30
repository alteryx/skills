import fs from "node:fs";
import path from "node:path";
import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";

const libDir = path.dirname(fileURLToPath(import.meta.url));

export const repoRoot = path.resolve(libDir, "..", "..");

// The canonical version source of truth. commit-and-tag-version writes the
// version into both manifests; this one is what the release tooling reads back.
export const canonicalManifest = "alteryx/.claude-plugin/plugin.json";
export const manifestPaths = [
  "alteryx/.codex-plugin/plugin.json",
  "alteryx/.claude-plugin/plugin.json"
];

export function resolveRepoPath(relativePath) {
  return path.join(repoRoot, relativePath);
}

export function readJson(relativePath) {
  return JSON.parse(fs.readFileSync(resolveRepoPath(relativePath), "utf8"));
}

export function writeJson(relativePath, data) {
  fs.writeFileSync(
    resolveRepoPath(relativePath),
    `${JSON.stringify(data, null, 2)}\n`
  );
}

export function assertSemver(version, label = "version") {
  if (!/^\d+\.\d+\.\d+$/.test(version)) {
    throw new Error(`${label} must be an exact semver version, got ${version}`);
  }
}

export function readCanonicalVersion() {
  const { version } = readJson(canonicalManifest);
  assertSemver(version, `${canonicalManifest} version`);
  return version;
}

export function assertManifestVersions() {
  const version = readCanonicalVersion();

  const mismatches = [];
  for (const manifestPath of manifestPaths) {
    const manifest = readJson(manifestPath);
    if (manifest.version !== version) {
      mismatches.push(
        `${manifestPath} has ${manifest.version}; expected ${version}`
      );
    }
  }

  if (mismatches.length > 0) {
    throw new Error(
      `Plugin manifest versions must match ${canonicalManifest} (${version}):\n${mismatches.join(
        "\n"
      )}`
    );
  }

  return version;
}

export function readTopChangelogVersion() {
  const changelog = fs.readFileSync(
    resolveRepoPath("CHANGELOG.md"),
    "utf8"
  );
  const match = changelog.match(/^##\s+(?:\[)?(\d+\.\d+\.\d+)(?:\])?/m);
  if (!match) {
    throw new Error("CHANGELOG.md has no versioned release heading");
  }
  return match[1];
}

export function extractChangelogSection(version) {
  assertSemver(version, "release version");
  const changelogPath = resolveRepoPath("CHANGELOG.md");
  const changelog = fs.readFileSync(changelogPath, "utf8");
  const headingPattern = new RegExp(
    `^##\\s+(?:\\[)?${escapeRegExp(version)}(?:\\])?(?:\\s|$).*`,
    "m"
  );
  const headingMatch = changelog.match(headingPattern);

  if (!headingMatch || headingMatch.index === undefined) {
    throw new Error(`CHANGELOG.md does not contain a ${version} release entry`);
  }

  const sectionStart = headingMatch.index + headingMatch[0].length;
  const remaining = changelog.slice(sectionStart);
  const nextHeading = remaining.match(/^##\s+/m);
  const section = nextHeading
    ? remaining.slice(0, nextHeading.index).trim()
    : remaining.trim();

  if (section.length === 0) {
    throw new Error(`CHANGELOG.md has an empty ${version} release entry`);
  }

  return section;
}

export function run(command, args, options = {}) {
  const result = spawnSync(command, args, {
    cwd: repoRoot,
    encoding: "utf8",
    stdio: options.stdio ?? "pipe",
    shell: options.shell ?? false
  });

  if (result.error) {
    throw result.error;
  }

  if (result.status !== 0 && !options.allowFailure) {
    const output = [result.stdout, result.stderr].filter(Boolean).join("\n");
    throw new Error(
      `${command} ${args.join(" ")} exited with ${result.status}${
        output ? `\n${output}` : ""
      }`
    );
  }

  return result;
}

function escapeRegExp(value) {
  return value.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}
