# Conventions shared by the physiology apps

Every app of the physiology workflows follows this contract, so any step's output can be linked to
any other step's input without glue, and so every app also works on data that never went through
the other apps. The apps are meant for **any lab's** cardiovascular and autonomic recordings (ECG,
arterial or finger blood pressure, respiration, nerve and stimulation channels), human or animal,
as exported by common acquisition systems, not for one consortium's data. Public datasets from
Pennsieve Discover and PhysioNet are the demo data only; the SPARC Data Structure (SDS) is one
metadata source among several that the apps understand.

Related families: `~/code/pennsieve/workflow-systems-neuroscience` (NWB everywhere; its
`nwb-inspect` app validates what `physio-import` writes) and `~/code/pennsieve/workflow-scalp-eeg`
(the table and `summary.json` / `provenance.json` conventions copied here). Where they differ, this
file wins for the physiology apps.

## Apps

| App | What | Compute |
|---|---|---|
| `physio-import` | Read physiological recordings in common formats (EDF/BDF, WFDB, Axon ABF, Spike2 `.smr`, BIOPAC `.acq`, NWB, HDF5, MATLAB `.mat`, CSV/TSV/XLSX, WAV), type and calibrate the channels (ECG, BP, respiration, nerve, EMG, stimulation, heart rate, ...), write one NWB file per recording plus index tables, keep any markers the source has | standard (Lambda-eligible when it fits) |
| `stim-events` | Find stimulation epochs and their parameters (amplitude, pulse width, frequency, duration, polarity, waveform, site) from trigger, monitor or envelope channels, imported markers, parameter tables, file/folder names, or SDS metadata; one `events.tsv` | standard (Lambda) |
| `ecg-hrv` | R-peaks, beat labels, heart rate, heart rate variability (time, frequency, non-linear), species presets; HRV over the whole recording, per stimulation phase when events are linked | standard (Lambda) |
| `bp-resp` | Beat-to-beat systolic/diastolic/mean pressure, respiration rate and depth, spontaneous baroreflex sensitivity (sequence and spectral methods), respiratory sinus arrhythmia | standard (Lambda) |
| `stim-dose-response` | Baseline vs during vs after each stimulation for every physiological series it is given; dose-response fits (thresholds, EC50, maximum), amplitude x frequency response surfaces, the neural fulcrum | standard (Lambda) |

Repo names carry **no `processor-` prefix**. Ports, parameters and file layouts are below.

Workflows (defined in `workflow/` once the apps exist):

- **Cardiovascular Response to Nerve Stimulation:** `physio-import → stim-events → {ecg-hrv, bp-resp} → stim-dose-response`
  (`stim-events` also feeds `ecg-hrv`, `bp-resp` and `stim-dose-response` directly).
- **Heart Rate Variability and Baroreflex** (resting recordings, no stimulation): `physio-import → {ecg-hrv, bp-resp}`.

A recording without blood pressure or respiration still runs through both workflows: `bp-resp`
reports it as skipped (see "Missing signals" below) and the other steps carry on.

## Runtime contract (Pennsieve processors)

- Read from `$INPUT_DIR`, write to `$OUTPUT_DIR`. Parameters arrive as environment variables named
  as in `app.yml`. Scratch goes to `$TMPDIR` (and `$HOME`), never a hard-coded `/tmp/...` path: on
  Lambda the file system is read-only except `INPUT_DIR`, `OUTPUT_DIR`, `HOME`, `TMPDIR` (see the
  builder brief, "How a Lambda step runs").
- One output port: it is the whole `$OUTPUT_DIR`. Two or more outputs: each is written to
  `$OUTPUT_DIR/<port>/`.
- **Everything an analysis app writes into a port lives under one top folder named after the app**:
  `$OUTPUT_DIR/[<port>/]<app>/...`, e.g. `ecg-hrv/hrv.csv`. This keeps `provenance.json`,
  `summary.json` and figures of different steps from colliding when several steps are linked into
  one input port. The one exception is `physio-import`: its `physio` port **is** the imported
  dataset (`recordings.csv` at the port root), with its `provenance.json` next to it. Its `qc`
  port follows the one-top-folder rule (`qc/physio-import/...`).
- Inputs with several ports use `placement: subfolder` (each arrives at `$INPUT_DIR/<port>/`).
  Apps must also work when everything is merged side by side at the root of `$INPUT_DIR`, so they
  find files **by name and content, recursively, following symlinks** (INPUT_DIR entries are
  symlinks), never by fixed paths.
- Port names: lowercase letters, digits and `-`.
- Each app's top folder gets a `provenance.json` (exact keys below) and a `summary.json` with the
  headline numbers and the figures a report shows.
- A recording that fails is logged and skipped; the step fails only when every recording failed or
  no input was found. Exit codes: `0` ok, `1` no usable input / every recording failed, `2` bad
  parameters.
- **Missing signals are not failures.** A recording that lacks the channel type a step needs (no
  BP for `bp-resp`, no stimulation for `stim-dose-response`) is listed in `provenance.json`
  `recordings` with `status: "skipped"` and a `reason`, and the step exits `0` with empty tables
  (header only) and a warning in `summary.json`. Only "no input at all" or "every recording that
  had the signal failed" exits `1`. This is what lets one workflow serve labs that record
  different subsets of signals.
- Logs go to stdout: one line per recording with channel counts and timings, plus progress at least
  every minute during long steps.
- Memory: process one recording at a time; read long or high-rate channels in windows (NWB/HDF5
  datasets are read by slice, never `[:]` on a 30 kHz nerve channel of hours). Each app's README
  states the peak memory measured on the demo data.
- Threads: `THREADS` (default `0` = from the cgroup CPU quota, else the CPU affinity, else the CPU
  count, **never the host's core count**), capped by the cgroup memory limit; log the number and
  why, keep both in `provenance.json`. Set `OMP_NUM_THREADS`, `OPENBLAS_NUM_THREADS`,
  `MKL_NUM_THREADS`, `NUMBA_NUM_THREADS` before importing numpy. Copy `processor/resources.py`
  from `~/code/pennsieve/processor-ieeg-hfo`.
- Reproducible: every random step takes `SEED` (default `42`) (bootstrap confidence intervals,
  surrogate nulls).
- No network at run time. Anything a library downloads on first use is fetched at image build
  time, verified by checksum, and kept read-only under `/opt/<app>/`.
- Runs as uid 1000 on ECS and as an arbitrary least-privileged user on Lambda: work with any uid.

## The data between steps: NWB per recording, plus plain tables

**Decision: `physio-import` writes one NWB 2.x file (HDF5 backend) per recording, plus CSV/TSV
index tables next to them. Every later step reads the NWB signals and writes plain CSV tables.**

Why NWB rather than BIDS-physio TSV or EDF+:

- Physiology recordings mix sampling rates in one session (dataset 349: ECG at 1 kHz, a device
  heart-rate trace at 500 Hz, nerve cuffs and a stimulus line at 30 kHz). BIDS physio
  (`_physio.tsv.gz`) needs one file per rate, as text; EDF+ needs one rate per data record and
  16-bit integers. NWB keeps each channel as its own `TimeSeries` with its own rate, unit and
  conversion, with explicit `timestamps` when a recording has gaps (trial-by-trial acquisition).
- NWB is the community standard for neurophysiology (Rübel et al. 2022), is what DANDI and the
  systems-neuroscience family already use, and has a validator we already ship (`nwb-inspect`).
- Read by slice through h5py, so a Lambda-sized step never loads a whole high-rate channel.
- People who are not programmers never need to open the NWB: every result is a CSV table and a
  figure, and `physio-import` writes `recordings.csv` and `channels.csv` that describe every file.

Layout of the `physio` output port of `physio-import`:

```
recordings.csv                       index, one row per recording (below)
channels.csv                         one row per channel kept (below)
events.tsv                           markers and annotations found in the sources (below), all recordings
provenance.json
sub-<subject>/[ses-<session>/]
  <recording_id>.nwb                 the signals (NWB 2.x, HDF5), one file per recording
```

### Recording ids, subjects, sessions

A **recording** is one continuous or trial-by-trial acquisition from one subject in one session
(one NWB file). `recording_id` = `sub-<subject>[_ses-<session>]_rec-<label>`, using only letters,
digits and `-` inside each label. `physio-import` takes the subject and session from, in order: a
user `recordings-map.csv` (columns `path_glob, subject, session, label, species`), BIDS/SDS-style
folder names (`sub-*`, `ses-*`, `perf-*`), the file's own metadata (NWB `subject_id`, WFDB record
name), else the file stem. The id is the key of every table below.

### `recordings.csv`

`recording_id, subject, session, label, path` (relative to the port root), `species` (`human`,
`pig`, `dog`, `rabbit`, `rat`, `mouse`, `other`, empty when unknown; from the mapping file, SDS
`subjects.xlsx`, NWB `Subject.species`, or the `SPECIES` parameter), `start_time` (ISO 8601 local
wall clock without an offset when known, else empty), `duration_s` (span from first to last
sample), `recorded_s` (time actually covered by samples: smaller than `duration_s` when the
recording has gaps), `n_segments` (contiguous segments), `channel_types` (`|`-joined, e.g.
`ecg|stim|nerve`), `source_format` (`edf`, `bdf`, `wfdb`, `abf`, `smr`, `acq`, `nwb`, `hdf5`,
`mat`, `csv`, `xlsx`, `wav`), `source_path` (as given), `metadata_source` (`mapping`, `sds`,
`bids`, `file`, `none`, `|`-joined), `age`, `sex` when known.

### `channels.csv` and channel types

`recording_id, channel` (the NWB `TimeSeries` name: lowercase `<type>` or `<type>-<n>`, e.g.
`ecg`, `ecg-2`, `bp`, `nerve-1`), `type`, `original_name`, `unit`, `sampling_rate_hz`,
`n_samples`, `calibrated` (`true` | `false`: false when the source gives no physical unit or says
the signal is uncalibrated, e.g. Fantasia's BP), `scale` (the factor applied to reach `unit`),
`site` (body site or electrode when known, e.g. `cervical vagus right`), `typing` (`mapping` |
`name` | `content` | `default`: how the type was decided), `status` (`good` | `flat` |
`saturated` | `noisy`) and `status_description`.

Types (closed list; anything else is `other` and is kept):

| `type` | Signal | NWB unit |
|---|---|---|
| `ecg` | electrocardiogram, any lead | `V` |
| `bp` | arterial or finger blood pressure waveform | `mmHg` (`calibrated=false` when only relative) |
| `resp` | respiration: belt, airflow, thermistor, plethysmography, impedance | as recorded (`a.u.` when unknown) |
| `ppg` | photoplethysmogram | `a.u.` |
| `nerve` | nerve recording (cuff, intrafascicular, microneurography) | `V` |
| `emg` | electromyogram | `V` |
| `stim` | stimulus trigger, monitor or command channel, or a stimulation parameter envelope (amplitude or frequency over time) | as recorded; the envelope's quantity goes in `site`/`original_name` |
| `hr` | heart rate computed by the acquisition device | `bpm` |
| `temp` | temperature | `degC` |
| `pressure` | other pressures (bladder, gastric, airway) | `mmHg` or `cmH2O` |
| `other` | anything else | as recorded |

Typing: a user `channels-map.csv` anywhere in the input (columns `pattern` (case-insensitive
regular expression on the original name), `type`, `unit`, `scale`, `site`, `name`) wins; else
name heuristics (`ECG|EKG|Lead (I|II|III)` → ecg, `BP|ABP|ART|NIBP|Finapres|pressure` → bp,
`RESP|breath|thorax|abdomen|airflow|pneumo` → resp, `PPG|pleth` → ppg, `ENG|nerve|vagus|cuff|CAP`
→ nerve, `EMG` → emg, `stim|trig|TTL|marker|pulse|StimAmp|CtrlAmp` → stim, `^HR$|heart.?rate` → hr);
else a content check where it is reliable (a channel of 0/1 steps is `stim`); else `other`. Every
decision is in `channels.csv` `typing` so a user can see and override it.

### Inside each NWB file

- `NWBFile.session_start_time` = the recording start (timezone-aware as NWB requires; when the
  source has no zone, UTC is written and `recordings.csv` `start_time` stays without an offset);
  `identifier` = `recording_id`; `Subject` with `subject_id`, `species` (Latin binomial when
  known), `sex`, `age` when known.
- Each channel is one `TimeSeries` in `acquisition`, named as in `channels.csv`, with `unit`,
  `conversion` (data stays in its source integer type where that saves space), `rate` +
  `starting_time` for gap-free data, or `timestamps` for trial-by-trial or gapped data, and a
  `description` with the original name and typing.
- Markers and annotations of the source go into `intervals`/`TimeIntervals` named `markers`
  (columns `start_time, stop_time, label, source`), mirrored in `events.tsv`.
- Stimulation parameters that the source stores **per trial** (e.g. HDF5 attributes of each trial
  group) are copied as a `TimeIntervals` table `stimulation_source` with one row per trial and one
  column per parameter, exactly as found (names as in the source); `stim-events` reads it.
- `physio-import` runs NWB Inspector (the `nwbinspector` package, as `nwb-inspect` does) on each
  file it writes; files with CRITICAL issues fail that recording.

### `events.tsv` (BIDS style)

Written by `physio-import` (markers found in the sources) and, with stimulation parameters, by
`stim-events`. Tab-separated, UTF-8, `n/a` for missing values. Columns, in this order:

`recording_id, onset, duration` (seconds from the recording start; `duration` `n/a` when
unknown), `trial_type` (`stimulation` | `baseline` | `block` (kilohertz block or other
inhibitory epoch) | `marker` | `annotation` | `artifact` | `condition`), `event_id` (unique within
the recording, e.g. `stim-0001`), `amplitude`, `amplitude_unit` (`uA`, `mA`, `V`), `pulse_width_us`
(one phase), `frequency_hz` (pulse rate), `train_duration_s`, `train_on_s` / `train_off_s` (for
duty-cycled trains, else `n/a`), `n_pulses`, `polarity` (`cathodic` | `anodic` first, `n/a`),
`waveform` (`monophasic` | `biphasic` | `biphasic-interphase` | `kilohertz` | `other`), `site`
(stimulation site or electrode), `contact` (contact or configuration), `condition` (any label the
experimenter gave, e.g. controller gain), `label` (original marker text), `source` (`trigger` |
`monitor` | `envelope` | `marker` | `table` | `filename` | `sds` | `nwb` | `hdf5-attrs` |
`user`), plus any extra parameter columns a parameter table supplies (kept as given, lowercase
snake_case).

Rules: one row per stimulation **train** (not per pulse); pulse-level detail is summarised in
`n_pulses`, `frequency_hz`, `pulse_width_us`. Values derived from a channel (rate from pulse
intervals, amplitude from a monitor) say so in `source`. When a parameter table and a channel
disagree, the table wins and the disagreement goes in `stim-events`' `qc.csv`.

### Units, time, precision

- Time is seconds from the recording start, in every table. Times inside an NWB file are the same
  seconds (`session_start_time` + t).
- SI or clinical units, written in column names where a table mixes quantities (`hr_bpm`, `rr_ms`,
  `sbp_mmhg`, `brs_ms_per_mmhg`). ECG/nerve/EMG in volts inside NWB; tables that show amplitudes
  use `mv` or `uv` in the column name.
- `calibrated=false` signals are analysed for timing and shape only: no absolute pressures or BRS
  slopes in mmHg are written for them; the tables say `calibrated` per recording.

## Shared physiological series: `series.csv`

The key between the analysis steps. `ecg-hrv` and `bp-resp` each write `series.csv`, the
beat- or breath-derived quantities **resampled to a regular grid** (`SERIES_HZ`, default `4` Hz
for humans and large animals; the species preset may raise it, e.g. `10` for rodents) by linear
interpolation between beats, with a `valid` flag false inside artifacts and gaps longer than
`MAX_GAP_S`. Long format:

`recording_id, time_s, variable, value, valid`

Variables: `hr_bpm`, `rr_ms` (ecg-hrv); `sbp_mmhg`, `dbp_mmhg`, `map_mmhg`, `pp_mmhg`,
`resp_rate_bpm` (breaths/min), `resp_amp` (bp-resp); a device heart-rate channel (`hr` type) is
passed through by `ecg-hrv` as `hr_device_bpm` when present. `stim-dose-response` reads **every**
`series.csv` it is given, so a future step (EMG RMS, gastric motility index, nerve activity) joins
the dose-response analysis by writing the same shape, without changes to `stim-dose-response`.

## Tables written by the analysis steps

All CSV, UTF-8, header row, `.` decimal, long format keyed by `recording_id`. Times are seconds
from the recording start. Each step writes its parameters into `provenance.json`.

| Step | Files (under `<app>/`) |
|---|---|
| stim-events | `events.tsv` (above; all recordings); `stim_summary.csv` (recording_id, n_stimulations, parameters varied, ranges); `qc.csv` (recording_id, check, value, note: e.g. table vs channel disagreements, overlapping trains, trains without a baseline gap) |
| ecg-hrv | `beats.csv` (recording_id, beat, time_s, rr_ms, label `N` / `ectopic` / `artifact`, detector); `series.csv` (above); `hrv.csv` (recording_id, scope `recording` / `<event_id>:<phase>` with phase `baseline` / `during` / `after`, metric, value, n_beats, window_s): Task Force time-domain (mean_nn, sdnn, rmssd, pnn50, ...), frequency-domain with the species bands (vlf/lf/hf power, lf_hf, peak frequencies), and non-linear (sd1, sd2, dfa_alpha1, sampen) where the window is long enough, with the minimum lengths in the README; `qc.csv` (recording_id, detector, n_beats, pct_ectopic, pct_artifact, agreement_with_second_detector, signal_quality) |
| bp-resp | `bp_beats.csv` (recording_id, beat, time_s, sbp_mmhg, dbp_mmhg, map_mmhg, pp_mmhg, calibrated); `breaths.csv` (recording_id, breath, onset_s, duration_s, rate_bpm, amplitude); `series.csv`; `brs.csv` (recording_id, method `sequence-up` / `sequence-down` / `sequence-all` / `alpha-lf` / `alpha-hf` / `transfer-lf`, value_ms_per_mmhg, n, coherence, valid); `rsa.csv` (recording_id, method `p2t` / `porges-bohrer`, value, unit); `qc.csv` |
| stim-dose-response | `responses.csv` (recording_id, event_id, variable, baseline, during, after, delta, pct_change, peak_delta, time_to_peak_s, recovery_s, valid_fraction, plus the event's stimulation parameter columns); `fits.csv` (subject, recording_id or `pooled`, variable, x (the parameter varied, e.g. `amplitude`), group (the other parameters held fixed, e.g. `frequency_hz=10`), model `hill` / `boltzmann` / `linear` / `none`, threshold, threshold_criterion, ec50, top, bottom, slope, r2, n, aic); `surface.csv` (subject, variable, amplitude, frequency_hz, mean_delta, sd, n) when two parameters are crossed; `fulcrum.csv` (subject, variable, frequency_hz, amplitude_at_fulcrum, method) when HR responses change sign; `features.csv` |

### Per-recording features: `features.csv`

Any app with one number per recording (or per recording and channel) also writes it as
`features.csv`: `recording_id, channel` (empty when recording-level), `feature, value`. Feature
names are lowercase `<kind>_<qualifier>` (`hrv_rmssd`, `hrv_lf_hf`, `brs_sequence_all`,
`dose_threshold_hr_bpm`). A future normative or group-comparison step reads this shape.

## Species presets

`ecg-hrv`, `bp-resp` and `stim-dose-response` take `SPECIES` (`auto` (default: from
`recordings.csv`, else `human`), `human`, `pig`, `dog`, `rabbit`, `rat`, `mouse`). A preset sets
the expected heart-rate range, the R-peak detector's refractory period and filter band, the HRV
frequency bands, the BRS sequence thresholds (RR and SBP steps), `SERIES_HZ`, and the default
baseline/response windows. Each preset is a small table in the app's code **with the source of
every number** (Task Force 1996 for human; Thireau et al. 2008 for mouse; the published PhysioZoo
preset values (Behar et al. 2018) for dog, rabbit, mouse and rat, taken as numbers, not code: its
code is GPL), shown in the README and in `provenance.json`. Every preset value can be overridden by
its own parameter.

## Ports

| App | Inputs | Outputs |
|---|---|---|
| physio-import | `recordings` (anything readable, subfolder; plus optional `channels-map.csv`, `recordings-map.csv`, SDS `subjects.xlsx` / `samples.xlsx` / `manifest.xlsx`) | `physio` (the dataset), `qc` (qc.csv, one overview PNG per recording) |
| stim-events | `physio`, `params` (optional: parameter tables CSV/XLSX, a `stim-map.yaml`) | `events` |
| ecg-hrv | `physio`, `events` (optional) | `hrv` |
| bp-resp | `physio`, `events` (optional), `hrv` (optional: beats from ecg-hrv, for BRS and RSA) | `bp` |
| stim-dose-response | `events`, and any of `hrv`, `bp` (series.csv), `physio` (optional, for figures with raw traces) | `responses` |

Media types in `app.yml` (platform registry only): NWB `application/x-hdf5; profile=nwb`, HDF5
`application/x-hdf5`, tables `text/csv`, `text/tab-separated-values`, XLSX
`application/vnd.openxmlformats-officedocument.spreadsheetml.sheet`, JSON `application/json`, PNG
`image/png`, EDF `application/edf`; formats without a registry type (ABF, Spike2, WFDB, ACQ, MAT,
WAV) as `application/octet-stream`. Check `GET /packages/formats` on api2 before adding a type.

## Figures, summaries, provenance

- Figures are PNG, 150 dpi, `<recording_id>_<what>.png` (or `<subject>_<what>.png` for pooled
  fits), with the id in the title, axes with units, and a caption in `summary.json` that says what
  to look at in words a physiologist (not a programmer) understands.
- `summary.json` per app top folder: `{"app", "version", "recordings": {<recording_id>: {headline
  numbers}}, "figures": [{"path", "caption"}], "tables": [{"path", "caption"}], "warnings": [...]}`
  (paths relative to the app's top folder; numbers are JSON numbers). Optional top-level `notice`:
  a method caveat every reader must see (e.g. "BP uncalibrated: pressures are relative").
- `provenance.json` (exact keys):

```json
{"app": "ecg-hrv", "version": "0.1.0", "variant": null,
 "tools": {"neurokit2": "0.2.12", "wfdb": "4.3.1"},
 "parameters": {"SPECIES": "auto", "DETECTOR": "neurokit"},
 "inputs": ["physio/recordings.csv", "physio/sub-2/sub-2_rec-vnsgrid.nwb"],
 "started": "2026-11-13T12:00:00Z", "finished": "...", "wall_seconds": 0.0,
 "peak_rss_mb": 0, "threads": {"requested": 0, "used": 2, "why": "cgroup cpu.max 2"},
 "recordings": {"sub-2_rec-vnsgrid": {"status": "ok", "seconds": 0.0, "species": "pig"}},
 "citations": ["10.3758/s13428-020-01516-y"],
 "licence_notice": null}
```

`status` is `ok`, `skipped` (with `reason`) or `failed` (with `error`). `citations` lists the DOIs
a report should cite for this step. `licence_notice` states usage terms a user must see (none of
the chosen tools need one).

## Demo data

Staged by `scripts/fetch-sample-data.sh` under `data/` (gitignored); file lists and checksums in
`data/README.md` and `data/SHA256SUMS.staged`. Read only; never modify. Outputs of finished apps
on the demo data go to `data/work/<demo>/<app>/` for the builders after them.

| Folder | What (checked by opening the files on 2026-11-13) | Source, licence | Use |
|---|---|---|---|
| `data/discover-349/` | Pig, vagus nerve stimulation grid. `files/primary/sub-2/subject-2.hdf5` (496 MB): one group per stimulation trial (20 in sub-2), group attributes `current_uA` (50–2500), `frequency_Hz` (2–30), `pulse_width_us` (500), `duration_s` (5), `polarity`, `stim_shape` (`monophasic` / `biphasicwithdeadzone`); per trial ~25 s: dataset `ecg` (1000 Hz; columns `timestamps, raw_ecg, processed_ecg` in attribute `_column_names`), `hr` (500 Hz; `timestamps, hr`), `neural` (30 kHz; `timestamps, record1, record2, stim_timing`: two recording cuffs and the pulse line). 10 s before and after each 5 s train. Gaps between trials: write NWB `timestamps`. `code/data_helper.py` is the authors' reader (CC BY 4.0) | Pennsieve Discover 349, doi:10.26275/dm5l-tspb, CC BY 4.0 (Armitage et al.) | Stimulation workflow: HR dose-response over a current x frequency grid (surface, fulcrum); stim parameters from HDF5 attributes; `hr` device channel |
| `data/discover-655/` | Rat, closed-loop heart-rate control by vagus stimulation and kilohertz block. Primary Spike2 `.smrx` (not staged: closed reader) and their CSV exports `primary/sub-Bimodal01/perf-*/*.smrx.csv`: columns `Time` (s), `3 ECG` (V), `4 StimAmp`, `5 CtrlAmp` (envelope channels, empty before the controller starts at ~122 s; StimAmp 0.02–3.84, CtrlAmp −17.9–15.2, sign = stimulate vs block), 1000 Hz, ~20 min per trial, 3 trials (controller gain 2, 5, 10 in the folder name). `derivative/HR/*.xlsx` = the authors' HR | Discover 655, doi:10.26275/5cwo-mkpz, CC BY 4.0 (Bender et al.) | Stimulation workflow: envelope-channel events, `condition` from the folder name (gain), HR validation against the authors' HR |
| `data/discover-406/` | Human (IBS patients), single-lead ECG as `.wav` (500 Hz, int16, uncalibrated), 5–17 min per file, 2 participants x 5 visits (A–E); `RD_A.mat` (`ECG` vector = the same signal), `.dat` from a G&J Electronics PPlus device (vendor format, not read); `docs/List1-22.xlsx` = treatment sequence | Discover 406, doi:10.26275/nung-b9bm, CC BY 4.0 (Ali et al.) | HRV workflow: WAV input, uncalibrated ECG (timing only), many short files |
| `data/fantasia/` | 6 records (f1y01, f1o01, f2y01, f2o01, f2y02, f2o02): healthy young (21–34) and elderly (68–85) adults, ~2 h supine rest watching *Fantasia*, 250 Hz, `RESP`, `ECG`, and in the f2 records `BP` (**uncalibrated**, per the database description), with beat annotations `.ecg` (N, V, S, ...) | PhysioNet Fantasia, doi:10.13026/C2RG61, ODC-By 1.0 (Iyengar et al. 1996) | HRV workflow: WFDB input, R-peak validation against the reference beats, respiration, RSA; BP beat detection on uncalibrated BP |
| `data/autonomic-aging/` | 3 records (0001–0003) + `subject-info.csv` (age group, sex, BMI, length, device): resting supine, 1000 Hz, `ECG1`, `ECG2` (mV), `NIBP` (**mmHg, calibrated**, continuous non-invasive), 15–32 min | PhysioNet Autonomic Aging, doi:10.13026/2hsy-t491, ODbL 1.0 (Schumann & Bär 2022) | HRV workflow: calibrated beat-to-beat BP and baroreflex sensitivity |
| `data/discover-9/` | Rat, vagal and gastric responses to parameter sweeps (4 sweep folders, 22 animals). Already epoched: per animal `ephys/*_ephys_data.mat` (`CNAP_avg` 28x1250 averaged nerve responses, `EMG_DuringStim` / `EMG_PostStim`, `Ist` (current), `PRF`, `TrainDur`, `CDist` (conduction distance), `CV`) and `derivatives/*_derived_data.mat` (AUC per fibre class). No continuous recording, no heart rate. `plog.xlsx` describes the folders only | Discover 9, doi:10.26275/qh3q-elj6, CC BY 4.0 (Ward et al.) | **Not used by these two workflows** (no cardiovascular signal). Staged for the planned workflow 2 (evoked nerve responses, gastric EMG) and as a `.mat` reader test |

Not staged, and why: Spike2 `.smrx` (only CED's closed `sonpy` reads it; dataset 655 ships CSV
exports), LabChart `.adicht` (the only Linux reader, `adichtion`, is GPL-3.0; datasets 378/691
ship `.txt` exports), dataset 349's `source/acute_dataset.hdf5` (1.1 GB, the same data as the
per-subject files).

For local tests use a few trials and short windows unless measuring memory and time; Docker on
the dev Mac has 8 GB and is shared.

## Research notes

`docs/research/1-physiology-survey.md` (tools, licences, datasets, 2026-11-12) and
`docs/research/citations.md` (every DOI, verified against Crossref/DataCite on 2026-11-13, and the
corrections to the survey found by that check and by opening the demo files).
