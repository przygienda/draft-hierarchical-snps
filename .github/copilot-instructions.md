# Repository instructions

This repository holds an IETF Internet-Draft (v3 RFC XML) describing the
"IS-IS Aggregated SNP Hash" (ASH) extension: a Merkle-tree-like scheme
(CASH/PASH PDUs) for compressing CSNP exchanges in IS-IS.

`draft-prz-lsr-ash-packets.xml` is the **only** authoritative source. Edit
that file. The `.txt`/`.pdf`/`.nl.txt` files are generated artifacts and some
of them are stale; never hand-edit a `.txt` to fix draft content.

## Build

```
./build.sh
```

Fast validity check while iterating:

```
xml2rfc draft-prz-lsr-ash-packets.xml
```

The XML sets `<?rfc strict="yes" ?>`, so malformed XML or invalid RFC
structure fails the build. Run the full `./build.sh` before declaring an edit
done. Build artifacts are gitignored; do not commit them.

Only `build.sh`, `tools/`, the source `.xml`, the companion reference `.txt`,
and the encrypted notes below are tracked.

## Private working notes

The detailed authoring conventions, build and idnits lore, structural
invariants, and design rationale for this draft are **encrypted** at
`.github/private-notes.md.enc`. They record what the draft deliberately
omits, which is not useful to a casual reader of a public repository.

The key is derived from an ssh-agent signature over a fixed challenge, so
there is no passphrase to type and nothing secret on disk. Any machine whose
agent holds the author's SSH key can read them. Decrypt before editing:

```
tools/notes.py decrypt
```

That writes plaintext to `~/.copilot/instructions/ash-draft.instructions.md`,
which this CLI loads automatically on the next session. Read that file now if
it exists. After changing it, re-encrypt and commit the result:

```
tools/notes.py encrypt
```

`tools/notes.py status` reports whether the ciphertext has fallen behind the
plaintext. If you cannot decrypt, you are not the author. Make only the
changes you were explicitly asked for, and do not infer conventions from the
rendered draft.

### Working rule

While working, the notes stay as **cleartext outside the repository
directory**, under `$HOME`. They are encrypted **only on the way into a
commit**. Never create a cleartext copy inside the working tree, not even a
temporary or gitignored one. The plaintext is deliberately somewhere `git`
cannot reach, so no gitignore rule, stash, or `git add -A` can ever pick it
up.

Edit `~/.copilot/instructions/ash-draft.instructions.md` directly. Run
`tools/notes.py encrypt` before committing, and commit the refreshed
`.github/private-notes.md.enc` together with whatever else changed.

## Commits

Commit and push only when explicitly asked. This draft goes through many
rounds of iterative wording edits between commits.
