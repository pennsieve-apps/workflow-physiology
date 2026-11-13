#!/usr/bin/env bash
# Downloads the demo data of the physiology workflows into data/ (gitignored). Every source is
# public, needs no login, and is redistributable with attribution:
#   - Four public datasets from Pennsieve Discover (CC BY 4.0), read anonymously from the AWS Open
#     Data bucket that mirrors them (s3://sparc-prod-aod-discover-publish50-use1/<id>/):
#       349  Influence of vagus nerve stimulation on cardiac activity in pigs (HDF5; one subject)
#       655  Single-electrode bidirectional control of heart rate via vagus nerve modulation in rat
#            (Spike2 recordings with CSV exports; the CSV twins of the first subject's trials)
#       9    Influence of left vagal stimulus pulse parameters on vagal and gastric activity in rat
#            (MATLAB .mat per animal + plog.xlsx parameter log; whole dataset, 37 MB)
#       406  Best parameters of heart rate variability ... rectal distention in patients with IBS
#            (human ECG as .wav; two participants)
#   - PhysioNet Fantasia (doi:10.13026/C2RG61, ODC-By 1.0): healthy young and elderly adults,
#     2 h supine rest, ECG + respiration (+ blood pressure in the f2* records), 250 Hz, with
#     beat annotations. Its blood pressure is uncalibrated (shape and timing only).
#   - PhysioNet Autonomic Aging (doi:10.13026/2hsy-t491, ODbL 1.0; Schumann & Bär 2022): resting
#     ECG + continuous non-invasive blood pressure calibrated in mmHg, 1000 Hz, ~15-30 min per
#     record; the calibrated BP for beat-to-beat pressure and baroreflex sensitivity.
# Usage: scripts/fetch-sample-data.sh [out-dir]
#   env: D349_SUBJECTS="2"  D655_SUBJECTS="Bimodal01"  D406_SUBJECTS="1001 1002"
#        FANTASIA_RECORDS="f1y01 f1o01 f2y01 f2o01 f2y02 f2o02"  AGING_RECORDS="0001 0002 0003"
# Needs the AWS CLI (no credentials: --no-sign-request) and curl. About 0.9 GB with the defaults.
set -euo pipefail
OUT="${1:-data}"; mkdir -p "$OUT"
BUCKET=s3://sparc-prod-aod-discover-publish50-use1
S3="aws s3 --no-sign-request --only-show-errors"
D349_SUBJECTS="${D349_SUBJECTS:-2}"
D655_SUBJECTS="${D655_SUBJECTS:-Bimodal01}"
D406_SUBJECTS="${D406_SUBJECTS:-1001 1002}"
FANTASIA_RECORDS="${FANTASIA_RECORDS:-f1y01 f1o01 f2y01 f2o01 f2y02 f2o02}"
AGING_RECORDS="${AGING_RECORDS:-0001 0002 0003}"

# Dataset-level metadata of a Discover dataset: readme, manifest, top-level SDS files.
meta() {
  local id=$1 d="$OUT/discover-$1"; mkdir -p "$d"
  for f in readme.md manifest.json changelog.md; do $S3 cp "$BUCKET/$id/$f" "$d/$f" 2>/dev/null || true; done
  $S3 sync "$BUCKET/$id/files/" "$d/files/" --exclude "*" --include "*.xlsx" --include "README*" \
    --include "code/*" --exclude "primary/*/*" --exclude "derivative/*/*/*"
}

# 349: pig VNS grid, one subject's HDF5 (~0.5 GB each; source/acute_dataset.hdf5 is 1.1 GB, skipped)
meta 349
for s in $D349_SUBJECTS; do $S3 sync "$BUCKET/349/files/primary/sub-$s/" "$OUT/discover-349/files/primary/sub-$s/"; done

# 655: rat closed-loop HR control; CSV exports of the Spike2 files (the .smrx need CED's closed reader)
meta 655
$S3 sync "$BUCKET/655/files/derivative/" "$OUT/discover-655/files/derivative/"
for s in $D655_SUBJECTS; do
  $S3 sync "$BUCKET/655/files/primary/sub-$s/" "$OUT/discover-655/files/primary/sub-$s/" --exclude "*" --include "*.csv" --include "*.s2rx"
done

# 9: rat vagal parameter sweeps, whole dataset (folder names contain spaces)
$S3 sync "$BUCKET/9/files/" "$OUT/discover-9/files/"
for f in readme.md manifest.json; do $S3 cp "$BUCKET/9/$f" "$OUT/discover-9/$f" 2>/dev/null || true; done

# 406: human ECG during rectal distension, selected participants
meta 406
$S3 sync "$BUCKET/406/files/docs/" "$OUT/discover-406/files/docs/"
for s in $D406_SUBJECTS; do $S3 sync "$BUCKET/406/files/primary/sub-$s/" "$OUT/discover-406/files/primary/sub-$s/"; done

# Fantasia (PhysioNet), checksummed
F="$OUT/fantasia"; mkdir -p "$F"; base="https://physionet.org/files/fantasia/1.0.0"
curl -fsS -L --retry 5 -o "$F/SHA256SUMS.txt" "$base/SHA256SUMS.txt"
# Fantasia has no LICENSE.txt on PhysioNet (a plain curl would save the 404 page): write the terms.
cat > "$F/LICENSE.txt" <<'LIC'
Fantasia Database v1.0.0 (PhysioNet, doi:10.13026/C2RG61)
Licence: Open Data Commons Attribution License v1.0 (ODC-By 1.0),
https://opendatacommons.org/licenses/by/1-0/ (as stated on https://physionet.org/content/fantasia/1.0.0/).
Please cite Iyengar N, Peng CK, Morin R, Goldberger AL, Lipsitz LA. Am J Physiol 1996;271:R1078-R1084,
doi:10.1152/ajpregu.1996.271.4.R1078, and Goldberger AL et al. Circulation 2000;101:e215-e220,
doi:10.1161/01.CIR.101.23.e215.
LIC
for r in $FANTASIA_RECORDS; do
  for ext in hea dat ecg; do
    [ -f "$F/$r.$ext" ] || curl -fsS -L --retry 5 -o "$F/$r.$ext" "$base/$r.$ext"
  done
done
(cd "$F" && for r in $FANTASIA_RECORDS; do grep -E " $r\.(hea|dat|ecg)$" SHA256SUMS.txt; done | sed 's/ /  /' | shasum -a 256 -c --quiet) \
  || { echo "Fantasia checksum mismatch"; exit 1; }

# Autonomic Aging (PhysioNet), checksummed
A="$OUT/autonomic-aging"; mkdir -p "$A"; base="https://physionet.org/files/autonomic-aging-cardiovascular/1.0.0"
curl -fsS -L --retry 5 -o "$A/SHA256SUMS.txt" "$base/SHA256SUMS.txt"
curl -fsS -L --retry 5 -o "$A/LICENSE.txt" "$base/LICENSE.txt" || true
curl -fsS -L --retry 5 -o "$A/subject-info.csv" "$base/subject-info.csv"
for r in $AGING_RECORDS; do
  for ext in hea dat; do [ -f "$A/$r.$ext" ] || curl -fsS -L --retry 5 -o "$A/$r.$ext" "$base/$r.$ext"; done
done
(cd "$A" && for r in $AGING_RECORDS; do grep -E " $r\.(hea|dat)$" SHA256SUMS.txt; done | sed 's/ /  /' | shasum -a 256 -c --quiet) \
  || { echo "Autonomic Aging checksum mismatch"; exit 1; }

# Checksums of everything staged (Discover files have no published checksums: record ours)
(cd "$OUT" && find . -type f ! -name SHA256SUMS.staged ! -path "./work/*" -print0 | sort -z | xargs -0 shasum -a 256 > SHA256SUMS.staged)
echo "done: $(du -sh "$OUT" | cut -f1) in $OUT"
