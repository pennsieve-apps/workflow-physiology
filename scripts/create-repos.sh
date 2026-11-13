#!/usr/bin/env bash
# Creates the public GitHub repositories of the physiology workflows in the pennsieve-apps
# organization (empty; each app is pushed from its own checkout). Idempotent: a repo that already
# exists is skipped.
set -euo pipefail
ORG=pennsieve-apps
while IFS='|' read -r name desc; do
  if gh repo view "$ORG/$name" >/dev/null 2>&1; then echo "exists: $ORG/$name"; continue; fi
  gh repo create "$ORG/$name" --public -d "$desc"
done <<'LIST'
workflow-physiology|Pennsieve workflows for cardiovascular and autonomic physiology: cardiovascular response to nerve stimulation, and heart rate variability and baroreflex
physio-import|Pennsieve app: reads physiological recordings (EDF, WFDB, ABF, Spike2, BIOPAC, NWB, HDF5, MAT, CSV, WAV), types and calibrates channels, and writes one NWB file per recording
stim-events|Pennsieve app: finds stimulation epochs and their parameters from trigger, monitor or envelope channels, markers, parameter tables or file names, as a BIDS-style events.tsv
ecg-hrv|Pennsieve app: ECG R-peak detection, heart rate and heart rate variability (NeuroKit2) for humans and animals, per recording and per stimulation
bp-resp|Pennsieve app: beat-to-beat blood pressure, respiration, spontaneous baroreflex sensitivity and respiratory sinus arrhythmia
stim-dose-response|Pennsieve app: physiological responses to stimulation with dose-response fits, thresholds, response surfaces and the neural fulcrum
physio-report|Pennsieve app: one HTML and PDF report of a physiology workflow run, with every step's figures, headline numbers and references
LIST
