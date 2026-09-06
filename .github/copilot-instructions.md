# draft-hierarchical-snps

This repository is an IETF Internet-Draft (I-D), not a software project. The content is
prose specification text written in `xml2rfc` v3 (RFC 7991) XML, describing the
"IS-IS Aggregated SNP Hash" (ASH) extension — a Merkle-tree-like scheme (CASH/PASH PDUs)
for compressing CSNP exchanges in IS-IS.

## Source of truth

- `draft-prz-lsr-ash-packets.xml` is the **only** authoritative source. Edit this file.
- `hierarchical-snps.xml` was the old name for this draft before it was renamed/split; it
  no longer exists in the tree (see commit "psnps, renaming"). Don't recreate it.
- `hierarchical-snps.txt`, `hierarchical-snps.raw.txt`, `hierarchical-snps.nl.txt`, and
  `draft-ginsberg-lsr-hello-capability-00.txt` are **generated/reference artifacts**, not
  hand-edited — they predate the current XML source and are stale. Never hand-edit a
  `.txt` file to fix draft content; edit the `.xml` and regenerate.

## Build

`build.sh` renders the draft to text/PDF and post-processes any diagram SVGs:

```bash
xml2rfc draft-prz-lsr-ash-packets.xml                 # -> .txt
xml2rfc --pdf draft-prz-lsr-ash-packets.xml           # -> .pdf
xml2rfc --allow-local-file-access --expand draft-prz-lsr-ash-packets.xml
nl -ba draft-prz-lsr-ash-packets.txt > draft-prz-lsr-ash-packets.nl.txt   # line-numbered copy for review
```

`xml2rfc` (v3, from Homebrew) is the only tool required for text output. The SVG
cleanup loop at the top of `build.sh` (strip Inkscape metadata via `xmlstarlet`, validate
via `svgcheck`) only runs if the draft has `.svg` figures checked in — it currently does
not, so that loop is a no-op; `xmlstarlet`/`svgcheck` are not installed in this
environment. There is no test suite or linter beyond `xml2rfc`'s own strict-mode
validation (`<?rfc strict="yes" ?>` is set at the top of the XML — malformed XML or
invalid RFC structure will fail the build).

`xml2rfc --v2 --raw` (legacy v2-compatible raw text) is **no longer supported** and has
been removed from `build.sh`: the document now uses v3-only elements (`<bcp14>`,
`<table>`, `<name>`) that cannot be expressed in the legacy v2 DTD, so `--v2` mode fails
with `Error: Unable to validate the XML document`. This isn't a problem for submission —
the IETF Datatracker accepts v3 XML directly and generates its own text/HTML/PDF.

PDF output requires WeasyPrint + Pango, which are **not** part of the Homebrew `xml2rfc`
formula and must be installed separately into its bundled interpreter (not the system
`pip3` — brew's `xml2rfc` runs its own Python, so `pip3 install` from the shell is
invisible to it):
```bash
/opt/homebrew/Cellar/xml2rfc/<version>/libexec/bin/python3 -m pip install "xml2rfc[pdf]"
brew install pango   # if not already present
```
After this, `xml2rfc --pdf` will log SSL `CERTIFICATE_VERIFY_FAILED` warnings fetching
IETF's Noto/Roboto Mono web fonts from `static.ietf.org` (an OpenSSL 3.6/cert-chain
mismatch unrelated to this repo) — these are non-fatal; WeasyPrint falls back to system
fonts and still produces a valid PDF.

To validate a change quickly without producing PDF, just run:
```bash
xml2rfc draft-prz-lsr-ash-packets.xml
```
and check for `xml2rfc` errors/warnings in the output.

## Submission / idnits

Before submitting a new revision to https://datatracker.ietf.org/submit/, run the
official nits checker against the source XML:
```bash
npx --yes @ietf-tools/idnits draft-prz-lsr-ash-packets.xml
```
The Datatracker requires the **uploaded filename** to end in the two-digit version
matching `docName` (e.g. `draft-prz-lsr-ash-packets-01.xml`); idnits flags
`FILENAME_INVALID_VERSION_SUFFIX`/`FILENAME_DOCNAME_MISMATCH` otherwise. Make a
version-suffixed copy of the source file for the actual upload rather than renaming the
canonical `draft-prz-lsr-ash-packets.xml` in the repo:
```bash
cp draft-prz-lsr-ash-packets.xml draft-prz-lsr-ash-packets-01.xml
```
Known accepted idnits warnings on this draft (don't try to fix these): `<references>`
uses the `title="..."` attribute instead of a `<name>` child — deliberately kept, since
using `<name>` inside `<references>` triggers an xml2rfc 3.34.0 preptool bug
(`Did not expect element name there`) when more than one `<references>` block is present;
a missing explicit `<date>` (intentionally empty so `xml2rfc` auto-fills it); and a
suggestion to also declare a `BCP14` XML entity alongside the `RFC2119`/`RFC8174`
references (informational only).

## Companion draft

`draft-ginsberg-lsr-hello-capability-00.txt` is a **separate**, related I-D (defines a
generic IS-IS Hello Capability TLV with a bit-flag registry). This draft references it
normatively for capability negotiation instead of defining its own bespoke IIH TLV — see
the "ASH Support Negotiation" section and the `ID.draft-ginsberg-lsr-hello-capability-00`
`<reference>` entry in the back matter. When adding new capability bits/negotiation, reuse
that mechanism rather than inventing a new TLV.

## Versioning

Bump `docName` in the `<rfc>` root element (e.g. `draft-prz-lsr-ash-packets-00` →
`-01`) whenever a round of substantive edits is ready to be regenerated/published; it does
not happen automatically and is easy to forget. The `<date/>` element is left empty
elsewhere in `<front>` so `xml2rfc` auto-fills today's date on each build.

## Document structure (for navigating the XML)

Top-level `<section>` elements, in order: Introduction → Example → Dynamic Partitioning
(with Node Ranges) → Hash Functions (Hash Function for a Fragment; Fast, Incremental,
Self-Inverse Hashing Function for Ranges) → Procedures (ASH Support Negotiation;
Advertising/Receiving CASHes; Advertising/Receiving PASHes; Refinement Rules) → CASH PDU
Format → PASH PDU Format → CASH Example → Further Considerations (Scale Envelope; Max
Advisable Hash Coverage; Hash Collision Probabilities; Impact of Packet Losses;
Decompression/Caching Optimizations) → Security Considerations → IANA Section →
Contributors → Acknowledgement → Reference Implementation appendix (Rust code).

Key terms used throughout and expected to stay consistent: **CASH** (cumulative/complete
ASH, aggregate hash PDU), **PASH** (partial ASH, hash over a node range/partition),
**SNP/CSNP/PSNP** (IS-IS sequence number PDUs this draft augments), fragment/pnode/node
range addressing.

## Conventions

- RFC 2119 keywords (MUST/SHOULD/MAY/etc.) are used normatively, declared via the
  Requirements Language paragraph in the Introduction citing `RFC2119`/`RFC8174` in the
  Normative References. Every in-prose occurrence of a keyword is wrapped in
  `<bcp14>...</bcp14>` (e.g. `<bcp14>MUST</bcp14>`) — required by idnits'
  `MISSING_BCP14_TAGS` check. Do **not** wrap keywords that appear inside `<artwork>`/
  `<![CDATA[...]]>` blocks (diagrams, the Rust reference code) or inside commented-out
  `<!-- -->` text — only tag keywords in live prose `<t>` paragraphs.
- Sections use the `<name>` child element (e.g. `<section anchor="foo"><name>Title</name>`),
  not the legacy `title="..."` attribute — required by idnits so it recognizes the
  Introduction/Security Considerations/IANA Considerations sections. `<references>`
  blocks are the one exception: they keep `title="..."` (see Submission/idnits above).
- The reference implementation appendix (`anchor="refcode"`) contains real Rust
  pseudo-code (`fragment_hash`, hashing/rotation logic) meant to mirror an actual
  implementation's algorithm; keep it in sync with prose changes to the hash algorithm
  sections rather than treating it as illustrative-only.
- Commented-out `<t>`/`<figure>` blocks (HTML `<!-- -->`) appear inline in several
  sections — these are intentionally retained drafts/alternates left by the authors, not
  dead code to delete on sight; leave them unless asked to clean up.
- Keep numeric anchors (`anchor="startexample"`, `anchor="partition"`, `anchor="hashfn"`,
  `anchor="rules"`, `anchor="cash-format"`, `anchor="pash-format"`, `anchor="collisions"`,
  `anchor="refcode"`, etc.) stable — other sections cross-reference them via `<xref>`.
- CASH/PASH packet contents (Node Range Hash Entries) are carried inside a dedicated
  **Node Range Hash TLV** (Type/Length/Value), the same way CSNP/PSNP carry LSP Entries in
  the LSP Entries TLV (type 9) — not as raw fields appended directly after the fixed PDU
  header. A PDU may carry multiple such TLVs (each capped at 12 entries due to the 1-octet
  TLV Length field) to hold all entries.
- ASCII-art box diagrams (in the CASH Example section and elsewhere) use a uniform
  46-character-wide box (`+` plus 44 `-`, matching `+----...----+`) for all field boxes,
  including TLV Type/Length headers — don't use a different border style (e.g. `====`) to
  set TLVs apart; keep every box the same width/style within a figure so borders visually
  line up. Trailing inline `// comment` text may extend past the right border.
- New IANA allocation requests go in the "IANA Considerations" section
  (`anchor="IGP_IANA"`) as one `<t>` per registry/codepoint being requested, following the
  existing pattern: name the exact IANA registry, what's being allocated (bit/TLV
  type/PDU type), and a `<table>` (with `<thead>`/`<tbody>`/`<tr>`/`<td>` — not the
  deprecated `<texttable>`/`<ttcol>`/`<c>`) when requesting multiple related codepoints
  (see the CASH/PASH PDU Type codepoint table).
