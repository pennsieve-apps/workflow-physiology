# Brief for the independent review of an app before its pull request

You review one or more apps of the physiology workflows that **another agent built**. You did not
write them, and you must not trust the builder's report: check claims against the code, the
outputs and the registries yourself. The apps will be used by physiology, cardiology and
neuromodulation labs on human and animal data; a wrong citation, a misattributed method, a silently
wrong result (a wrong unit, a human preset applied to a rat), an uncalibrated pressure reported in
mmHg, or a licence problem is worse than a missing feature.

Read first: `~/code/pennsieve/workflow-physiology/docs/conventions.md`, `docs/builder-brief.md`,
`docs/research/1-physiology-survey.md` and `docs/research/citations.md` (including its corrections).

## What to check

1. **Citations and attribution (zero tolerance for invented facts).**
   - Run `scripts/verify-citations.py <repo>`; every line must be `ok`.
   - Independently, for **every** reference: open the Crossref/DataCite/PubMed record yourself and
     compare title, every author in order, journal, year, volume, pages. Check that the work is the
     right one for the claim (the method's own paper for an in-house implementation; the dataset's
     DOI for the dataset; PhysioNet's requested citations for PhysioNet data).
   - Every person, lab or institute named in the README must be verifiable from the tool's own
     repository, paper, website or the dataset's DataCite record. Remove or flag anything else.
   - Every tool and dataset the code imports or bundles is credited (README + CITATION.cff +
     THIRD_PARTY.md), and each project's own "how to cite" is honoured.
   - Species presets: every number has a cited source, and nothing presents a human-validated
     method as validated on animals (or the reverse).
2. **Licences.** Every bundled package: licence matches its LICENSE at the pinned version; nothing
   from the builder brief's "do not use" list (GPL tools, pyPPG, sonpy, adichtion, unlicensed or
   dataset-embedded code copied as code).
3. **Science and method.** Defaults match the brief / the cited method; units and time bases are
   right (seconds from the recording start; volts inside NWB; mmHg only for calibrated pressure;
   bpm vs breaths/min); windows (baseline, during, after) are where the README says; HRV metrics
   are not computed from windows too short for them; fits need enough levels and report how the
   model was chosen; bootstrap and pooled statistics are honest. Re-derive at least one headline
   number from the outputs in `data/work/` yourself (e.g. mean HR from `beats.csv`, an RMSSD, a
   BRS sequence slope, one event's `delta`).
4. **Contract.** Ports, folder layout (`<port>/<app>/`, physio-import's dataset at the port root),
   recording_id rules, `recordings.csv` / `channels.csv` / `events.tsv` columns, `series.csv`,
   provenance.json keys, summary.json with figures + captions, exit codes, the "missing signals are
   not failures" rule (run it on a recording without BP or stimulation), THREADS/SEED, no network at
   run time, valid Fargate cpu/memory pair, and **Lambda-safe** (no handler.py, no writes outside
   `$TMPDIR`/`$HOME`/INPUT/OUTPUT); run the documented `--read-only --user 65534:65534 --tmpfs
   /tmp` test yourself. NWB files written pass NWB Inspector without CRITICAL issues.
5. **Code.** Read all of `processor/`. Look for bugs: off-by-one in windows, sample/second
   confusion, unit conversions (V vs mV, µA vs mA), gaps in trial-by-trial data treated as
   continuous, file matching that picks the wrong file, crashes on edge cases (one recording, one
   stimulation level, no events, a recording shorter than a window, an inverted ECG lead), memory
   blow-ups on high-rate channels (30 kHz must be read by slice). Run `make test` and `make run` on
   the fixture. Validate `app.yml` against `docs/app-manifest.v1.schema.json`; check the review
   block's generate command works.
6. **README claims.** Every number (runtime, memory, accuracy, image size) must be backed by a
   measurement you can find in the repo, `data/work/` or the builder's logs; otherwise flag it.

## Output

Fix only what is **clearly wrong and mechanical** (a wrong author name, a typo'd DOI, a missing
reference, an incorrect licence string) in a separate commit per repo (`review: ...`, same
author/co-author lines as the brief). Do not refactor or change methods; list those as findings.
Do not push.

Report per app: verdict (`ready`, `ready after fixes I made`, `needs builder work`), each finding
with file:line, severity (blocker / should-fix / nit), and evidence (registry URL, command output).
The coordinator puts a summary of your review in the pull request.
