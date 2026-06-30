// Local/manual tag helper — the backstop for when CI cannot push to GitHub.
//
// Run after the release MR (the `chore(release): X.Y.Z` commit) has merged to
// main and is checked out. It validates the release, creates the vX.Y.Z tag
// locally, and prints the push commands for the canonical repo and the mirror.
import {
  assertManifestVersions,
  extractChangelogSection,
  readTopChangelogVersion,
  run
} from "./lib/release-utils.mjs";

const dryRun = process.argv.includes("--dry-run");
const version = assertManifestVersions();
const tagName = `v${version}`;

const changelogVersion = readTopChangelogVersion();
if (changelogVersion !== version) {
  throw new Error(
    `CHANGELOG.md top entry is ${changelogVersion}; expected ${version}.`
  );
}

// Confirm the release notes section is present and non-empty before tagging.
extractChangelogSection(version);

const existingTag = run(
  "git",
  ["rev-parse", "-q", "--verify", `refs/tags/${tagName}`],
  { allowFailure: true }
);

if (existingTag.status === 0) {
  throw new Error(`Tag ${tagName} already exists.`);
}

if (dryRun) {
  const head = run("git", ["rev-parse", "--short", "HEAD"]).stdout.trim();
  console.log(`Dry run: ${tagName} would be created at ${head}.`);
  console.log("No tag was created.");
  process.exit(0);
}

const dirty = run("git", ["status", "--porcelain"]).stdout.trim();
if (dirty.length > 0) {
  throw new Error("Release tags must be created from a clean working tree.");
}

run("git", ["tag", tagName], { stdio: "inherit" });

console.log(`Created ${tagName}. Push it to the canonical repo and the mirror:`);
console.log(`  git push origin ${tagName}`);
console.log(`  git push github ${tagName}`);
console.log(
  "The GitHub Release is created automatically by github-release.yml once the tag lands on the mirror."
);
