import { extractChangelogSection, readCanonicalVersion } from "./lib/release-utils.mjs";

const version = process.argv[2] ?? readCanonicalVersion();
const notes = extractChangelogSection(version);

process.stdout.write(`${notes.trimEnd()}\n`);
