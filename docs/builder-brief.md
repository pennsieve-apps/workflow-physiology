# Brief for building an app of the physiology workflows

You are building one or more Pennsieve processor apps, each in its own git repo under
`~/code/pennsieve/<repo>` (remote `git@github.com:pennsieve-apps/<repo>.git`, public). Repo names
carry **no `processor-` prefix**: `physio-import`, `stim-events`, `ecg-hrv`, `bp-resp`,
`stim-dose-response`, `physio-report`. Refer to sibling apps by these names. They form two workflows for
cardiovascular and autonomic physiology, human and animal:

- **Cardiovascular Response to Nerve Stimulation:** `physio-import → stim-events → {ecg-hrv, bp-resp} → stim-dose-response → physio-report`
- **Heart Rate Variability and Baroreflex:** `physio-import → {ecg-hrv, bp-resp} → physio-report`

**These apps are for the whole community, not one consortium.** Names, descriptions, READMEs,
parameters and defaults must make sense to any physiology or neuromodulation lab with ECG, blood
pressure, respiration and stimulation recordings from common acquisition systems. The demo data
happen to come from Pennsieve Discover (several of them SPARC-funded datasets) and PhysioNet;
credit them as data, but do not describe the apps as "for SPARC data", and do not make SPARC's
folder layout (SDS) a requirement: it is one metadata source among several.

Audience: physiologists, cardiologists, neuromodulation and autonomic researchers who are not
software engineers. Defaults must do the right thing on a typical recording of the species given;
every figure gets a caption that says what to look at; every number that could be mistaken for a
clinical finding is labelled as a research output.

## Read first

1. `~/code/pennsieve/workflow-physiology/docs/conventions.md`: the file, port, recording, channel
   and event contract between apps, the `series.csv` shape, species presets, and the demo data as
   found in the files. Follow it exactly. If something in it is wrong or missing, say so in your
   report instead of silently diverging.
2. `~/code/pennsieve/workflow-physiology/docs/research/1-physiology-survey.md`: tools, versions,
   licences, datasets (as of 2026-11-12; re-check PyPI and pin exact versions) and
   `docs/research/citations.md`: every DOI verified against the registries, **and the corrections
   to the survey** (read them).
3. Finished apps to copy layout, tone and level of care from: `~/code/pennsieve/eeg-spectral` and
   `~/code/pennsieve/eeg-sleep` (small CPU apps of the most recent family: `processor/`,
   `resources.py`, `tests/make_fixture.py`, `review` block, Lambda-safe Dockerfile, README and
   CITATION.cff with full attribution), `~/code/pennsieve/eeg-prep` (reading many formats, typed
   channel tables), `~/code/pennsieve/st-svg` (minimal layout), `~/code/pennsieve/nwb-inspect` and
   the systems-neuroscience apps (`~/code/pennsieve/ephys-prep`, `~/code/pennsieve/ophys-traces`)
   for writing and validating NWB with pynwb.
4. The app manifest: schema `docs/app-manifest.v1.schema.json` in the workflow repo, and the docs in
   `~/code/pennsieve/app-deploy-service/docs/` (`app-manifest-review.md`, `app-manifest-folders.md`).
   Validate `app.yml` against the schema (`python3.12 -m venv` + `pip install jsonschema pyyaml` in
   your scratch dir). Do NOT add `application.relations`.

## Every repo has

`app.yml` (`# yaml-language-server: $schema=https://schemas.pennsieve.io/app-manifest/v1.json`,
`schemaVersion: "1.0"`, `application` with name/description/type processor/tags, `runtime`
cpu/memory/computeTypes/timeoutSeconds, `parameters`, `inputs`, `outputs`, and a **`review` block**
with a `generate` command that writes small test inputs).
The review block's layout rule (app-fixtures copies what the generator writes into the app's
INPUT_DIR unchanged): a top-level `review.generate` must write exactly INPUT_DIR as a compute node
lays it out (`<port>/` for `placement: subfolder`, files at the top for `placement: root`), with
`root` naming the folder that becomes INPUT_DIR; anything else it writes (truth files, alternative
layouts) ends up in INPUT_DIR unless `root` excludes it. When the generator also writes such
extras, use `review.inputs.<port>.generate` with `root: <port>` instead: only that subtree becomes
the port's contents. Optional input ports need `required: false` on the port.

**Fargate sizes**: `cpu`/`memory` must be a valid Fargate pair (e.g. 1024 cpu: 2048–8192 MiB;
2048 cpu: 4096–16384 MiB in 1024 steps). 2048/3072 is **not** valid and broke a prod run.

Tags (generic): `physiology`, `autonomic`, `cardiovascular`, plus what applies: `ecg`,
`heart-rate-variability`, `blood-pressure`, `baroreflex`, `respiration`, `neuromodulation`,
`nerve-stimulation`, `vagus-nerve-stimulation`, `dose-response`, `electrophysiology`, `nwb`,
`data-import`, `quality-control`. No `sparc` tag.

`Dockerfile` (linux/amd64, base image pinned by digest, pinned package versions, non-interactive,
no network at run time, as small as reasonable; `python:3.12-slim` + pinned `requirements.txt`
installed with `--no-deps --only-binary=:all:` as the eeg-* apps do), `processor/` code, `tests/`
(pytest on a tiny synthetic fixture, no Docker; `tests/make_fixture.py` writes it, also used by
`review.generate`), `Makefile` (`test`, `fixture`, `run` = docker compose over a fixture into
`data/output/`, `clean`), `docker-compose.yml`, `dev.env`, `sample-input/README.md` (how to get
real input: which Discover or PhysioNet files), `README.md`, `THIRD_PARTY.md` (every bundled
component with its licence), `LICENSE` (Apache-2.0), `VERSION` (`0.1.0`), `CITATION.cff`,
`.gitignore` (use `/data/`, anchored, so a `validation/data/` folder is still tracked).

**Lambda needs no extra code.** The platform decides whether a version can run as a Lambda step
from its `runtime` and image (app-deploy-service `docs/builds.md`, "Lambda eligibility"): `memory`
≤ 10240 MiB, `cpu` ≤ 6144, `timeoutSeconds` ≤ 900 (or unset), image ≤ 10 GB compressed, not
GPU-only. So do **not** write a `processor/handler.py`, and do not list `lambda` in `computeTypes`
(`[standard]`). Size `cpu`, `memory` and `timeoutSeconds` from what you measured; these apps
should all fit Lambda on typical recordings. Don't inflate them.

How a Lambda step runs (compute-node-aws-provisioner `cmd/lambda-step-runtime`): the runtime
fetches inputs into `/tmp`, runs the image's ENTRYPOINT/CMD with the ECS contract, and pushes
`OUTPUT_DIR`. So **every app must be Lambda-safe**:
- The file system is read-only except `INPUT_DIR`, `OUTPUT_DIR`, `HOME` and `TMPDIR`, all under a
  step folder in `/tmp`. **Write scratch only to `$TMPDIR` (`tempfile`) or `$HOME`, never to a
  hard-coded `/tmp/...` path.** h5py/pynwb temporary files included.
- `/tmp` is the function's own disk: anything the image put in `/tmp` is **not there**. Caches
  that must be written (matplotlib, numba) go to `$TMPDIR`-relative paths set at startup
  (`MPLCONFIGDIR=$TMPDIR/mpl`).
- `HOME` is overridden: nothing may depend on files in the image's HOME.
- The app runs as a least-privileged user, not the image's `USER`: don't rely on a uid.
- Inputs + outputs + scratch share at most 10 GB of `/tmp`; a step has at most 15 min.
- Test it: `docker run --read-only --user 65534:65534 --tmpfs /tmp:mode=1777 -e HOME=/tmp/w/home
  -e TMPDIR=/tmp/w/tmp -e INPUT_DIR=/tmp/s/input -e OUTPUT_DIR=/tmp/s/output -v <in>:/tmp/s/input:ro
  -v <out>:/tmp/s/output ...` (the app must create HOME/TMPDIR itself if missing) must work.

Python 3.12. Synthetic fixtures (`tests/make_fixture.py`): an NWB recording as `physio-import`
writes it (and, for `physio-import`, source files in several formats) with a synthetic ECG
(known R-peak times, so tests assert detection), a BP waveform with known systolic/diastolic
values, a respiration signal with a known rate, and a stimulation channel with known trains whose
known effect on heart rate (e.g. a planted bradycardia that grows with amplitude) lets
`stim-dose-response` tests assert the fitted threshold. One human-rate and one rodent-rate variant
so the species presets are tested; one recording without BP so the "missing signals" path is
tested.

## Methods and defaults per app (decided; deviations go in your report)

- **physio-import**: readers: `neo` (BSD-3; Axon ABF, Spike2 `.smr` (CED 32-bit, no sonpy),
  Intan, TDT, Blackrock, Plexon, Open Ephys, BrainVision, EDF via its EDF IO), `wfdb` (MIT; WFDB
  records and annotations), `pyedflib` (BSD-2) or MNE (BSD-3) for EDF/BDF if neo's EDF support is
  insufficient (pick one and say why), `pynwb` (BSD-3) for NWB input and output, `h5py` (BSD-3)
  for HDF5, `scipy.io` + `pymatreader` (BSD-2) for `.mat` v5 and v7.3, `bioread` (MIT) for
  BIOPAC `.acq`, `pandas` + `openpyxl` (MIT) for CSV/TSV/XLSX, `scipy.io.wavfile` for WAV.
  Generic HDF5 and MAT files have no standard layout: recognise NWB and the common "one group per
  trial with column datasets" layout (dataset 349: `_column_names` and `frequency_hz` attributes,
  group attributes = per-trial parameters → `stimulation_source`), and accept a user
  `layout.yaml` (paths of time, signals, rates, units, per-trial parameter attributes) for
  anything else. CSV: a `Time` column (or `TIME_COLUMN`) in seconds, or a constant `SAMPLING_RATE`;
  numeric columns are channels; empty cells are gaps (not zeros). Channel typing and calibration
  as in conventions.md (`channels-map.csv`, name heuristics, content). Deferred with a clear
  message, not silently skipped: Spike2 `.smrx` ("export as .smr or CSV from Spike2: the only
  .smrx reader, CED's sonpy, is closed-source") and LabChart `.adicht` ("export as .txt/.mat from
  LabChart; the only Linux reader is GPL"). Write NWB with chunking and gzip, run NWB Inspector
  (`nwbinspector`, BSD-3) on every file. QC: per recording one overview PNG (each channel, a 10 s
  zoom, flat/saturated flags) and `qc.csv`. Validate on all five demo sources.
- **stim-events**: sources, in priority order, merged per recording: the NWB
  `stimulation_source` table (per-trial parameters from the source file); a parameter table in the
  `params` port (CSV/XLSX; a `stim-map.yaml` names its columns and how rows match trains, by order
  or by time); `stim` channels: TTL/trigger (threshold crossing with hysteresis, pulses grouped
  into trains by an inter-pulse gap `TRAIN_GAP_S`, rate and `n_pulses` from the pulses), stimulus
  monitor (pulse amplitude and width from the waveform when its unit is known), and envelope
  channels (a parameter over time, as in dataset 655: epochs where it is non-zero/above
  `ENVELOPE_THRESHOLD`, value per epoch = median, sign conventions in `stim-map.yaml`); imported
  markers (`events.tsv` of physio-import, label text parsed by a user regex `MARKER_PATTERN` with
  named groups `amplitude`, `frequency_hz`, ...); file/folder names (`NAME_PATTERN`, a regex with
  named groups; e.g. `(?P<amplitude>\d+)uA_(?P<pulse_width_us>\d+)us`); SDS `manifest.xlsx`
  / `samples.xlsx` columns when present (optional, last). Baseline epochs: `trial_type=baseline`
  rows where a source marks them, else none (stim-dose-response takes its own pre-stimulus window).
  QC: overlapping trains, trains too close for a baseline window (`MIN_GAP_S`), table vs channel
  disagreements. Figure per recording: a timeline of trains coloured by amplitude, with the
  parameters varied.
- **ecg-hrv**: NeuroKit2 (MIT) `ecg_clean` + `ecg_peaks` (default method `neurokit`; `DETECTOR`
  also `pantompkins1985`, `hamilton2002`, `elgendi2010`, `engzeemod2012`, `kalidas2017`,
  `rodrigues2021` as NeuroKit2 names them) with species-preset filter band and refractory period;
  a second detector (`wfdb.processing.XQRS`, MIT) on the same signal for an agreement figure in
  `qc.csv`; polarity check (inverted leads); beat labelling (ectopic/artifact by the Lipponen &
  Tarvainen 2019 method as NeuroKit2's `signal_fixpeaks` implements it: verify the citation, or
  name the method NeuroKit2 actually uses); `series.csv` at `SERIES_HZ`; HRV with NeuroKit2
  (`hrv_time`, `hrv_frequency` with the species bands, `hrv_nonlinear`) over the whole recording
  and, when `events` are linked, per stimulation (`baseline` = `BASELINE_S` before onset,
  `during`, `after` = `AFTER_S` after the end), with minimum window lengths per metric (no LF/HF
  from a 10 s window: the table leaves it empty with the reason in `qc.csv`). Device heart-rate
  channels (`hr` type) are passed through as `hr_device_bpm` and compared with the ECG-derived HR.
  Validation: Fantasia reference beat annotations (sensitivity and positive predictive value at
  ±50 ms, as `wfdb.processing.compare_annotations` does), Autonomic Aging (two leads agree),
  dataset 349 (pig, 1 kHz; compare with its `hr` device channel), dataset 655 (rat; compare with
  the authors' HR in `derivative/HR/*.xlsx`), dataset 406 (uncalibrated WAV ECG).
- **bp-resp**: arterial pressure beats: systolic peaks and diastolic troughs per beat (onset by
  the slope-sum or tangent method; implement from the cited paper, or NeuroKit2's PPG peak finder
  adapted to BP, say which), MAP as the integral mean over the beat (not (2D+S)/3), pulse
  pressure; respiration with NeuroKit2 `rsp_process` (method `khodadad2018` default, as NeuroKit2
  names it), breath onsets, rate, amplitude; spontaneous BRS in-house (no packaged licensed tool
  exists): sequence method (Parati et al. 1988; thresholds from the species preset; lags 0–2 beats;
  r ≥ 0.8; report up, down and all), alpha index and transfer-function gain in LF/HF with
  coherence ≥ 0.5 (Laude et al. 2004, EuroBaVar); RSA with NeuroKit2 `hrv_rsa` (peak-to-trough and
  Porges-Bohrer, Lewis et al. 2012) when ECG beats (from the `hrv` port or detected here) and
  respiration both exist. Uncalibrated BP (`calibrated=false`): beats and timing only, BRS and
  pressures not written (empty with reason). Validation: Autonomic Aging (calibrated NIBP), Fantasia
  f2 records (uncalibrated BP, respiration); report BRS values next to published ranges for
  healthy adults of that age, cited.
- **stim-dose-response**: for every stimulation event and every variable in every `series.csv`:
  `baseline` = mean over `BASELINE_S` (default from the species preset, e.g. 10 s) before onset,
  `during` = mean over the train (optionally `RESPONSE_WINDOW` = `train` | `peak` | `fixed:<a>,<b>`),
  `after` = mean over `AFTER_S` after the end; `delta`, `pct_change`, peak delta, time to peak,
  recovery time (back within `RECOVERY_FRACTION` of baseline); events whose windows overlap
  another train or have `valid_fraction` < `MIN_VALID` are flagged and left out of fits.
  Dose-response per subject (and pooled, with subject as a random effect only when there are ≥ 3
  subjects: `statsmodels` MixedLM, BSD-3, else per subject only), per variable, along the parameter
  that varies with the others held fixed: sigmoid (Hill / Boltzmann via `scipy.optimize.curve_fit`,
  with bounds), linear, or none, chosen by AIC with a minimum of 4 distinct levels; threshold = the
  lowest level whose response exceeds `THRESHOLD_CRITERION` (default: a 5 % change or 3 SD of the
  baseline variability, whichever is larger; say which in `fits.csv`); EC50, top, bottom, r².
  Response surface over amplitude x frequency when both vary (dataset 349: current 50–2500 µA x
  2–30 Hz). Neural fulcrum (Ardell et al. 2017) when HR responses change sign across amplitude at a
  fixed frequency: the amplitude where the fitted response crosses zero, with the caveat that the
  original definition is for chronic, duty-cycled VNS in conscious animals. Bootstrap CIs (`SEED`).
  Figures: response time course per parameter level (mean ± SD across trains), dose-response
  curves with fits per subject, the surface as a heat map, per-event table.
- **physio-report**: like `~/code/pennsieve/eeg-report` and `neuro-report`: renders each linked
  step's `summary.json` figures in order with their captions; a recordings table (subject, species,
  duration, signals present, skipped steps and why); the QC summary from `physio-import`; headline
  numbers (resting HR and HRV, BP and BRS with the published reference ranges the steps cite,
  thresholds, EC50 and fulcrum per subject from `stim-dose-response`); every `licence_notice`
  prominently; a references section built from each step's `citations` DOIs (bundle the verified
  citation table). Works with whichever ports are linked, so the same app ends both workflows.
  HTML + PDF (WeasyPrint, BSD-3) + `tables/` (copies of the key CSVs). Lambda-sized.

## Licences

Re-check the LICENSE of what you bundle (the survey has them as of 2026-11-12). Our own code is
Apache-2.0. Chosen tools are BSD/MIT/Apache: NeuroKit2 (MIT), wfdb (MIT), neo (BSD-3), pynwb and
hdmf (BSD-3), nwbinspector (BSD-3), h5py (BSD-3), numpy/scipy (BSD-3), pandas (BSD-3), openpyxl
(MIT), pymatreader (BSD-2), bioread (MIT, uwmadison-chm), pyedflib (BSD-2), statsmodels (BSD-3),
matplotlib (PSF-style), pyyaml (MIT), WeasyPrint (BSD-3).

Do **not** use: hrv-analysis, py-ecg-detectors, PhysioZoo / mhrv code, Kilosort4, MSNA-Burst-Analysis
(GPL-3.0); pyPPG (GPL-3.0 with an "academic research purpose only" preamble); ASCENT, PyFibers
(GPL-2.0 non-commercial); adichtion (GPL-3.0: `.adicht` is deferred); sonpy (closed); BreathMetrics,
the Chang 2020 VNS code, and any dataset-embedded script as code (no licence or CC BY data
licence: port the logic from the paper, credit it); anything with no licence. Dataset code
(`code/data_helper.py` of 349) may be read to understand the layout; write your own reader. If you
think an exception is worth it, report it instead of building it.

## README

What the app does and why, for a physiologist and for a data scientist; port table; parameters
table (defaults, what each does, the species presets with their sources); outputs with columns;
runtime (cpu/memory chosen and **measured** peak memory and wall time on the demo data, saying it
was amd64 emulation on an M-series Mac); validation results with numbers; limitations (what the
method cannot tell you, species it was not validated on, anaesthesia effects, uncalibrated
signals); licences; **Citations**.

## Attribution to the original developers (required)

These apps package other people's methods; the credit is theirs and must be impossible to miss:

- **README, first paragraph after the title**: name the tool(s) the app is built on, who made them
  (developers and their lab/institute, e.g. "NeuroKit2, developed by Dominique Makowski and
  colleagues", "WFDB for Python, from the MIT Laboratory for Computational Physiology", "Neo, from
  the NeuralEnsemble community", "PyNWB, from the Neurodata Without Borders project"), a link to
  their repository and paper, and a sentence that Pennsieve packages the method and did not develop
  it. For in-house implementations of published methods (BRS sequence method, dose-response,
  neural fulcrum), name the method's authors and paper the same way. Credit the demo datasets'
  authors (from the DataCite record: e.g. Discover 349 Oliver Armitage and colleagues; PhysioNet
  Fantasia: Nikhil Iyengar and colleagues; Autonomic Aging: Andy Schumann and Karl-Jürgen Bär).
  **Every name must be verifiable from the project's own repository, paper, website or the
  dataset's DataCite record**; if you cannot verify a name, leave it out.
- **README `## Citations`**: the primary method paper(s) with the **full author list**; other works
  may use "et al." when the full list is in CITATION.cff. A line "Please cite these works if you
  use this app" and "Verified on Crossref/DataCite and PubMed; full author lists in CITATION.cff".
  Software without a paper: cite its Zenodo/software DOI or repository URL with its authors.
- **README `## Acknowledgements`**: the upstream projects and their funders where the project asks
  for it.
- **CITATION.cff**: `message: If you use this app, please cite it and the works it builds on,
  listed under references.`; the entity author plus `contact:` (`given-names: Joost`,
  `family-names: Wagenaar`, `orcid: https://orcid.org/0009-0004-5925-5451`, `affiliation:
  University of Pennsylvania`), exactly as `~/code/pennsieve/cell2location/CITATION.cff`;
  `references:` for **every** tool, method and dataset the app uses or the README cites, all
  authors in order.
- **THIRD_PARTY.md**: each bundled component, its authors/copyright holder, licence and URL.
- Respect each project's own "how to cite": NeuroKit2 asks for Makowski et al. 2021; WFDB for
  Python asks for its PhysioNet DOI **and** Goldberger et al. 2000; PhysioNet databases ask for
  the database DOI, the database's paper **and** Goldberger et al. 2000; Pennsieve Discover
  datasets ask for the dataset DOI; NWB asks for Rübel et al. 2022.

## Citations: verified, and in CITATION.cff

Every paper or software you cite: authors, title, journal, year, volume:pages, DOI (and PMID if it
has one). Verify each via `https://api.crossref.org/works/<DOI>` (or DataCite for Zenodo,
PhysioNet and Pennsieve Discover DOIs, `https://api.datacite.org/dois/<DOI>`) and, for the PMID,
`https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&term=<DOI>[doi]&retmode=json`
then `esummary`: title, author list and year must match. Never cite something you could not
verify; cite the software repo URL instead. **Never write an author name, title, journal, volume,
page or year from memory**: copy every field from the registry response. Before you report, run
`~/code/pennsieve/workflow-physiology/scripts/verify-citations.py <your repo>` (needs pyyaml) and
fix everything it flags; paste its final line in your report. Verified DOIs are in
`docs/research/citations.md`; re-fetch each by DOI anyway.

`CITATION.cff` (CFF 1.2.0): `type: software`, title = app name, abstract, `repository-code`
`https://github.com/pennsieve-apps/<repo>`, license, keywords, **one entity author**
`- name: Pennsieve (University of Pennsylvania)`, no `version`/`date-released`, and `references:`
for every cited work (PMIDs as `identifiers: [{type: other, value: "<digits>"}]`), with **authors
exactly as Crossref/DataCite list them** (all of them, in order; a consortium as `name:`).
Validate with `cffconvert --validate`.

## Test on real data

Demo data (read-only, do not modify) is under `~/code/pennsieve/workflow-physiology/data/` (see
conventions.md, "Demo data", and `data/README.md`). Upstream outputs are in
`data/work/<demo>/<app>/` (`data/work/<demo>/physio-import/physio` is what every later app reads);
if what you need isn't there yet, use your fixture generator and say so; once you have run on real
data, put your output under `data/work/<demo>/<your app>/` for the builders after you. Demo names:
`d349`, `d655`, `d406`, `fantasia`, `aging`.

Local Docker has **8 GB shared with other builders running in parallel**: test on a few
recordings, give `docker run` a `--memory` limit (≤ 3 GB unless you must), measure peak memory
(`/sys/fs/cgroup/memory.peak` or `docker stats`), remove your containers and dangling images, and
use `docker build --platform linux/amd64`.

## Git

`git init -b main` (if not yet a repo), commit with clear messages ending with
`Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`, commit as
`-c user.name="Joost Wagenaar" -c user.email="1605953+jwagenaar@users.noreply.github.com"`, and add
the remote `git@github.com:pennsieve-apps/<repo>.git`. **Do not push, tag or create releases**: the
coordinator pushes and releases.

## Report back

Short: repo path, commits, ports and parameters as built, what you ran it on and the results
(numbers), measured memory/time, image size(s), chosen cpu/memory, citations with DOIs/PMIDs and
how you verified them (the verify-citations.py final line), deviations from conventions.md, open
problems.
