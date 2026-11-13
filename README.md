# Physiology workflows for Pennsieve

Two workflows for cardiovascular and autonomic physiology, human or animal, built from reusable
Pennsieve apps in the [pennsieve-apps](https://github.com/pennsieve-apps) organization. They take
recordings as labs export them (EDF, WFDB, Axon ABF, Spike2, BIOPAC, NWB, HDF5, MATLAB, CSV, WAV)
and work the same whether or not the data follow a particular consortium's layout:

- **Cardiovascular Response to Nerve Stimulation:** `physio-import → stim-events → {ecg-hrv, bp-resp} → stim-dose-response`
- **Heart Rate Variability and Baroreflex:** `physio-import → {ecg-hrv, bp-resp}`

| App | What it adds |
|---|---|
| [physio-import](https://github.com/pennsieve-apps/physio-import) | Reads common physiology formats, types and calibrates channels (ECG, BP, respiration, nerve, EMG, stimulation), one NWB file per recording + index tables |
| [stim-events](https://github.com/pennsieve-apps/stim-events) | Stimulation trains and their parameters from trigger/monitor/envelope channels, markers, parameter tables or file names, as a BIDS-style `events.tsv` |
| [ecg-hrv](https://github.com/pennsieve-apps/ecg-hrv) | R-peaks, heart rate, heart rate variability (NeuroKit2) with species presets, per recording and per stimulation |
| [bp-resp](https://github.com/pennsieve-apps/bp-resp) | Beat-to-beat blood pressure, respiration, spontaneous baroreflex sensitivity, respiratory sinus arrhythmia |
| [stim-dose-response](https://github.com/pennsieve-apps/stim-dose-response) | Baseline/during/after responses per stimulation, dose-response fits, thresholds, response surfaces, neural fulcrum |

The contract between the apps is `docs/conventions.md`; `docs/builder-brief.md` and
`docs/review-brief.md` are the briefs the apps are built and reviewed against; the literature and
licence survey and the verified citation table are in `docs/research/`. Workflow definitions go in
`workflow/` once the apps are released.

## Demo data

`scripts/fetch-sample-data.sh` downloads redistributable demo data into `data/` (about 0.7 GB):
four public Pennsieve Discover datasets (CC BY 4.0: 349 pig vagus stimulation grid, 655 rat
heart-rate control, 406 human ECG, 9 rat vagal sweeps) read anonymously from their AWS Open Data
mirror, and PhysioNet's Fantasia (ODC-By 1.0) and Autonomic Aging (ODbL 1.0) databases. See
`data/README.md` after fetching, and the credits in each app's README.

## Licence

The workflow definitions and scripts here are Apache-2.0. Each app lists the licences of what it
bundles in its `THIRD_PARTY.md`.
