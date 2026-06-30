// Consistency lint for the release-MR flow.
//
// commit-and-tag-version writes the version into both plugin manifests and the
// CHANGELOG, so there is nothing to sync at release time. This script instead
// validates that they agree, and fails fast when a hand edit drifts them apart.
// Wired into the MR pipeline; the `--check` flag is accepted for readability but
// the script always checks.
import {
  assertManifestVersions,
  canonicalManifest,
  readTopChangelogVersion
} from "./lib/release-utils.mjs";

const version = assertManifestVersions();
const changelogVersion = readTopChangelogVersion();

if (changelogVersion !== version) {
  throw new Error(
    `CHANGELOG.md top entry is ${changelogVersion}; expected ${version} ` +
      `to match ${canonicalManifest}.`
  );
}

console.log(
  `Plugin manifests and CHANGELOG.md top entry are all at ${version}.`
);
