# Physiology workflows: literature, software and data survey

> Scope note (2026-11-13): this survey was first written around SPARC datasets, because they are the
> largest public pool of stimulation physiology data on Pennsieve. The workflows built from it are
> **generic**: for any lab's ECG, blood pressure, respiration and stimulation recordings. SPARC and
> PhysioNet datasets serve as demo and validation data; the SPARC Data Structure is one optional
> metadata source. Corrections found by opening the demo files and checking every DOI are in
> `citations.md`; the contract the apps follow is `../conventions.md`, which wins where the two
> differ (e.g. demo data choice: Discover 9 is not used by the cardiovascular workflows; PhysioNet
> Autonomic Aging was added for calibrated blood pressure).

Prepared 2026-11-12 for the Pennsieve apps team. Every DOI below was checked against Crossref (api.crossref.org/works/<DOI>) or doi.org on this date; licences were read from the repository LICENSE file (GitHub API `repos/<r>/license`, which returns the file text) on this date. Stars and last-push dates come from the GitHub API on the same day and are adoption hints only.

Legend for flags: **[GPL]** copyleft (GPL/LGPL/AGPL), **[NC]** non-commercial or "academic only" wording, **[NOLIC]** no licence file (all rights reserved by default), **[MATLAB]** MATLAB-only, **[GATED]** weights need sign-up or are not redistributable, **[PROP]** proprietary/closed binary.

---

## 1. Autonomic and cardiovascular physiology (ECG, HRV, blood pressure, baroreflex, respiration, PPG)

### 1.1 Defining standards and method papers

| Topic | Citation | DOI |
|---|---|---|
| HRV standard (the "Task Force") | Task Force of the European Society of Cardiology and the North American Society of Pacing and Electrophysiology (1996). Heart rate variability: standards of measurement, physiological interpretation and clinical use. *Circulation* 93(5):1043-1065 | 10.1161/01.CIR.93.5.1043 |
| HRV metrics and norms review | Shaffer F, Ginsberg JP (2017). An overview of heart rate variability metrics and norms. *Frontiers in Public Health* 5:258 | 10.3389/fpubh.2017.00258 |
| HRV in mice (rodent bands, sampling) | Thireau J, Zhang BL, Poisson D, Babuty D (2008). Heart rate variability in mice: a theoretical and practical guide. *Experimental Physiology* 93(1):83-94 | 10.1113/expphysiol.2007.040733 |
| QRS detection (classic) | Pan J, Tompkins WJ (1985). A real-time QRS detection algorithm. *IEEE Trans Biomed Eng* BME-32(3):230-236 | 10.1109/TBME.1985.325532 |
| QRS detector benchmarking | Porr B, Macfarlane PW (2019). A new QRS detector stress test combining temporal jitter and F-score (JF) reveals significant performance differences amongst popular detectors. *bioRxiv* | 10.1101/722397 |
| PhysioNet | Goldberger AL, Amaral LAN, Glass L, et al. (2000). PhysioBank, PhysioToolkit, and PhysioNet. *Circulation* 101(23):e215-e220 | 10.1161/01.CIR.101.23.e215 |
| Baroreflex, sequence method (24 h intra-arterial BP) | Parati G, Di Rienzo M, Bertinieri G, et al. (1988). Evaluation of the baroreceptor-heart rate reflex by 24-hour intra-arterial blood pressure monitoring in humans. *Hypertension* 12(2):214-222 | 10.1161/01.HYP.12.2.214 |
| Baroreflex method comparison (EuroBaVar) | Laude D, Elghozi JL, Girard A, et al. (2004). Comparison of various techniques used to estimate spontaneous baroreflex sensitivity (the EuroBaVar study). *Am J Physiol Regul Integr Comp Physiol* 286(1):R226-R231 | 10.1152/ajpregu.00709.2002 |
| RSA physiology | Grossman P, Taylor EW (2007). Toward understanding respiratory sinus arrhythmia: relations to cardiac vagal tone, evolution and biobehavioral functions. *Biological Psychology* 74(2):263-285 | 10.1016/j.biopsycho.2005.11.014 |
| RSA metrics (peak-to-trough, Porges-Bohrer) | Lewis GF, Furman SA, McCool MF, Porges SW (2012). Statistical strategies to quantify respiratory sinus arrhythmia: are commonly used metrics equivalent? *Biological Psychology* 89(2):349-364 | 10.1016/j.biopsycho.2011.11.009 |
| PPG review | Charlton PH, Kyriacou PA, Mant J, et al. (2022). Wearable photoplethysmography for cardiovascular monitoring. *Proceedings of the IEEE* 110(3):355-381 | 10.1109/JPROC.2022.3149785 |

Note: the original sequence-method paper (Bertinieri G et al., 1985, *J Hypertens Suppl* 3(3):S79-S81) has no DOI in Crossref; cite Parati 1988 and EuroBaVar for the method.

### 1.2 Tools

| Tool | What it does | Primary paper (verified DOI) | Repository | Licence | Weights | Runtime / GPU | Maintenance / adoption |
|---|---|---|---|---|---|---|---|
| **NeuroKit2** | ECG cleaning, R-peak detection (about 15 detectors incl. Pan-Tompkins, Hamilton, Elgendi, Engzee, Kalidas, Rodrigues, NeuroKit), delineation, HRV time/frequency/non-linear (Task Force set and many more), respiration (RSP) processing, RRV, **RSA** (`hrv_rsa`: P2T, Porges-Bohrer), PPG, EDA, EMG; event-related epoching | Makowski D, Pham T, Lau ZJ, Brammer JC, Lespinasse F, Pham H, Schölzel C, Chen SHA (2021). NeuroKit2: a Python toolbox for neurophysiological signal processing. *Behavior Research Methods* 53(4):1689-1696. 10.3758/s13428-020-01516-y | https://github.com/neuropsychology/NeuroKit | **MIT** | none | Python, CPU | Very active (push 2026-11-11), 2.4k stars, widely cited |
| **wfdb-python** | Read/write PhysioNet WFDB records and annotations, XQRS and GQRS detectors, HR from annotations | PhysioNet software record "Waveform Database Software Package (WFDB) for Python", 10.13026/9njx-6322 (DataCite DOI, resolves to physionet.org/content/wfdb-python/4.1.0); cite with Goldberger 2000 | https://github.com/MIT-LCP/wfdb-python | **MIT** | none | Python, CPU | Active (2026-11-08), 860 stars |
| **pyHRV** | HRV time, frequency (Welch, Lomb, AR), non-linear (Poincaré, DFA, sample entropy), reports | Gomes P, Margaritoff P, Plácido da Silva H (2019). pyHRV: development and evaluation of an open-source Python toolbox for heart rate variability. Proc. IcETRAN 2019 (conference proceedings, no Crossref DOI found) | https://github.com/PGomes92/pyhrv | **BSD-3-Clause** | none | Python, CPU | Low activity (last push 2026-06, few releases since 2021), 340 stars |
| **HeartPy** | Peak detection for noisy PPG and ECG, HR/HRV measures, breathing rate from HRV | van Gent P, Farah H, van Nes N, van Arem B (2019). HeartPy: a novel heart rate algorithm for the analysis of noisy signals. *Transportation Research Part F* 66:368-378. 10.1016/j.trf.2019.09.015; and *J Open Res Softw* 7(1):32, 10.5334/jors.241 | https://github.com/paulvangentcom/heartrate_analysis_python | **MIT** | none | Python, CPU | Maintenance mode (last push 2025-12), 1.2k stars |
| **BioSPPy** | ECG (Hamilton, Engzee, Christov, ASI), PPG, respiration, EDA, EMG; filtering, segmentation | Bota P, Silva R, Carreiras C, Fred A, da Silva HP (2024). BioSPPy: a Python toolbox for physiological signal processing. *SoftwareX* 26:101712. 10.1016/j.softx.2024.101712 | https://github.com/scientisst/BioSPPy (the old PIA-Group repo is archived) | **BSD-3-Clause style** (Instituto de Telecomunicações; GitHub shows NOASSERTION, text is BSD-3) | none | Python, CPU | Active (2026-11-03) |
| **SleepECG** | Fast R-peak detector (C extension), HRV features, sleep staging from heart rate (small bundled classifiers) | Brunner C, Hofer F (2023). SleepECG: a Python package for sleep staging based on heart rate. *JOSS* 8(86):5411. 10.21105/joss.05411 | https://github.com/cbrnr/sleepecg | **BSD-3-Clause** | bundled small classifier models for staging (same repo); not needed for peak detection | Python + C ext, CPU (TensorFlow only for staging) | Active (2026-11-02) |
| **hrv-analysis** (Aura) | HRV time/frequency/geometric/Poincaré from RR series, outlier/ectopic removal | none (software only) | https://github.com/Aura-healthcare/hrv-analysis | **GPL-3.0** [GPL] | none | Python, CPU | Active, 470 stars |
| **py-ecg-detectors** | Seven reference R-peak detectors plus the JF benchmark | Porr & Macfarlane 2019 (above) | https://github.com/berndporr/py-ecg-detectors | **GPL-3.0** [GPL] | none | Python, CPU | Stale since 2024-02 |
| **pyPPG** | PPG fiducial points (systolic peak, dicrotic notch, onset), 600+ biomarkers, SQI | Goda MÁ, Charlton PH, Behar JA (2024). pyPPG: a Python toolbox for comprehensive photoplethysmography signal analysis. *Physiological Measurement* 45(4):045001. 10.1088/1361-6579/ad33a2 | https://github.com/godamartonaron/GODA_pyPPG | **GPL-3.0 with a preamble "provided for academic research purpose only"** [GPL] [NC-ambiguous] | none | Python, CPU | Low activity (2025-04), 80 stars |
| **PhysioZoo** / **mhrv** | HRV for mammals with presets for human, dog, rabbit, mouse (species-specific bands and detector settings) | Behar JA, Rosenberg AA, Weiser-Bitoun I, et al. (2018). PhysioZoo: a novel open access platform for heart rate variability analysis of mammalian electrocardiographic data. *Frontiers in Physiology* 9:1390. 10.3389/fphys.2018.01390 | https://github.com/physiozoo/physiozoo (GUI), https://github.com/physiozoo/mhrv | **GPL-3.0** [GPL] [MATLAB] | none | MATLAB | Stale (2023-24). Useful as a **reference for species presets**, not to package |
| **BreathMetrics** | Respiratory waveform features (inhale/exhale onsets, volumes, pauses) | Noto T, Zhou G, Schuele S, Templer J, Zelano C (2018). Automated analysis of breathing waveforms using BreathMetrics. *Chemical Senses* 43(8):583-597. 10.1093/chemse/bjy045 | https://github.com/zelanolab/breathmetrics | **none** [NOLIC] [MATLAB] | none | MATLAB | Stale (2022) |
| **Breathe Easy** (BASSPRO-STAGG) | Rodent whole-body plethysmography breath segmentation and stats | (repo only) | https://github.com/MolecularNeurobiology/Breathe_Easy | **GPL-3.0** [GPL] | none | Python + R | Stale (2023), niche |

### 1.3 Blood pressure and baroreflex sensitivity: open implementations

- There is **no maintained, licensed Python package** for spontaneous baroreflex sensitivity (BRS). GitHub search ("baroreflex sensitivity") returns only small R or MATLAB scripts: `nkcheung95/BRS-Seq-R` (GPL-3, R, 0 stars), `renatofilogonio/baroreflex_methods` (R, no licence), `lindseyboulet/BRS_Analysis` (R, no licence), `CWRUDSP/EDF_Viewer_BRS` (MATLAB, no licence). None are suitable to package.
- **Recommendation: implement in-house** (a few hundred lines of NumPy/SciPy, MIT/Apache licensable). The algorithms are fully specified in the literature:
  - Sequence method (Parati 1988; EuroBaVar 2004): find runs of >= 3 consecutive beats where SBP and RR (or RR lagged 0-2 beats) rise together or fall together, with thresholds (classically 1 mmHg SBP, 5 ms RR in humans; rodents need scaled thresholds), regress RR on SBP per sequence, BRS = mean slope with r > 0.8.
  - Transfer-function / alpha (spectral) method: sqrt(P_RR/P_SBP) in LF/HF bands with coherence > 0.5 (EuroBaVar).
  - Beat detection from arterial pressure: systolic peaks, diastolic troughs, MAP per beat, pulse pressure, dP/dt max. NeuroKit2 PPG peak finding and SciPy `find_peaks` cover this; wfdb ships `wabp`-style detection only in the C toolkit (not Python).
- For pharmacological/phenylephrine-nitroprusside (Oxford) BRS, a simple sigmoid fit (SciPy `curve_fit`) of HR vs MAP is enough.

### 1.4 Assessment for apps

- **Core library: NeuroKit2 (MIT)**. It covers ECG R-peaks, HRV (Task Force metrics and more), respiration, RSA and PPG in one dependency, CPU only, no weights. wfdb-python (MIT) for PhysioNet-format input/output and an independent XQRS detector for cross-checking.
- **Animal data caveat**: most SPARC ECG is from rats, mice, pigs, ferrets, dogs (heart rates 300-600 bpm in rodents). NeuroKit2 detectors assume human rates; apps must expose species presets (filter band, refractory period, HRV frequency bands per Thireau 2008 / PhysioZoo presets). Re-implementing the PhysioZoo preset values as parameters (numbers are not copyrightable) avoids the GPL code.
- Avoid packaging GPL tools (hrv-analysis, py-ecg-detectors, pyPPG, PhysioZoo) unless the team accepts GPL for the app container; NeuroKit2 overlaps nearly all of their features.

---

## 2. Nerve stimulation response (organ response vs stimulation parameters; evoked CAPs)

### 2.1 Key papers that define stimulation-response analyses

| Paper | Why it matters | DOI |
|---|---|---|
| Ardell JL, Nier H, Hammer M, Southerland EM, Ardell CL, Beaumont E, KenKnight BH, Armour JA (2017). Defining the neural fulcrum for chronic vagus nerve stimulation: implications for integrated cardiac control. *J Physiol* 595(22):6887-6903 | "Neural fulcrum": the frequency x current point where HR response turns from tachycardia to bradycardia; the canonical VNS dose-response readout | 10.1113/JP274678 |
| Chang YC, Cracchiolo M, Ahmed U, Mughrabi I, Gabalski A, Daytz A, Rieth L, Becker L, et al. (2020). Quantitative estimation of nerve fiber engagement by vagus nerve stimulation using physiological markers. *Brain Stimulation* 13(6):1617-1630 | Maps HR drop (B fibres), breathing changes (A-delta/C afferents) and laryngeal EMG (A fibres) to fibre engagement; defines threshold and %-of-max metrics | 10.1016/j.brs.2020.09.002 |
| Huffman WJ, Musselman ED, Pelot NA, Grill WM (2023). Measuring and modeling the effects of vagus nerve stimulation on heart rate and laryngeal muscles. *Bioelectronic Medicine* 9:3 | Mouse VNS HR and EMG dose-response, paired with SPARC datasets 375/376 (ECG and EMG in mice during VNS) | 10.1186/s42234-023-00107-4 |
| Settell ML, Pelot NA, Knudsen BE, Dingle AM, McConico AL, Nicolai EN, et al. (2020). Functional vagotopy in the cervical vagus nerve of the domestic pig. *J Neural Eng* 17(2):026022 | Pig VNS: evoked CAP components vs HR/EMG side effects | 10.1088/1741-2552/ab7ad4 |
| Nicolai EN, Settell ML, Knudsen BE, McConico AL, Gosink BA, Trevathan JK, Baumgart IW, Ross EK, et al. (2020). Sources of off-target effects of vagus nerve stimulation using the helical clinical lead in domestic pigs. *J Neural Eng* 17(4):046017 | eCAP latency windows mapped to fibre types; neck EMG contamination of eCAPs (SPARC dataset 163) | 10.1088/1741-2552/ab9db8 |
| Blanz SL, Musselman ED, Settell ML, Knudsen BE, Nicolai EN, Trevathan JK, et al. (2023). Spatially selective stimulation of the pig vagus nerve to modulate target effect versus side effect. *J Neural Eng* 20(1):016051 | Multi-contact cuff: target (HR, breathing) vs side effect (laryngeal EMG) trade-off; SPARC dataset 333 | 10.1088/1741-2552/acb3fd |
| Musselman ED, Cariello JE, Grill WM, Pelot NA (2021). ASCENT: a pipeline for sample-specific computational modeling of electrical stimulation of peripheral nerves. *PLoS Comput Biol* 17(9):e1009285 | Modelling (not data analysis) | 10.1371/journal.pcbi.1009285 |
| Marshall DP, Farah ES, Musselman ED, Pelot NA, Grill WM (2025). PyFibers: an open-source NEURON-Python package to simulate responses of model nerve fibers to electrical stimulation. *PLoS Comput Biol* 21:e1013764 | Modelling (fibre thresholds, CV) | 10.1371/journal.pcbi.1013764 |

### 2.2 Open code from SPARC teams

| Code | What it is | Licence | Verdict |
|---|---|---|---|
| github.com/nih-sparc (24 repos) | Portal, API (`sparc-api`, `sparc-app`), `sparc.client` (Python client, Apache-2.0), metrics, AWS Open Data scripts | Apache-2.0 / MIT / none | **No physiology analysis code** in the org. `sparc.client` is useful for data access only |
| ASCENT (https://github.com/wmglab-duke/ascent) | Sample-specific FEM + fibre models of nerve stimulation | **Dual: GPL-2.0 for non-commercial use only, commercial licence from Duke OTC** [GPL] [NC]; needs **COMSOL Multiphysics** (proprietary) | Not packageable; out of scope (modelling) |
| PyFibers (https://github.com/wmglab-duke/pyfibers) | NEURON-based fibre models | Same Duke dual licence (GPL-2.0 non-commercial) [GPL] [NC] | Out of scope; licence blocks commercial use |
| ychang3/VNS-Fiber-Engagement (Chang 2020 code) | Zip of MATLAB code | **No licence** [NOLIC] [MATLAB] | Re-implement from paper |
| asimgazi/tcVNS_Response_Modeling | MATLAB tcVNS response modelling | GPL-3.0 [GPL] [MATLAB] | Not relevant to animal data |
| o²S²PARC (https://github.com/ITISFoundation/osparc-simcore) | Cloud platform for SPARC models and pipelines; hosts the VNS cardiovascular model (dataset 335, MIT) and "SPARC Nerve Activity Predictor" | Platform code MIT; many services wrap Sim4Life (proprietary) | Platform, not a tool to package; individual models may be portable |
| Dataset-embedded code | Many SPARC datasets ship analysis code in `code/`: e.g. 349 and 380 (`code/data_helper.py` for HDF5 pig VNS data), 9 (MATLAB `.m`), 406 (MATLAB HRV app), 375 (21 `.m` files), 537 (Jupyter notebooks, pickles) | Dataset licence (CC-BY-4.0) applies to code too, which is legally usable but not a software licence | Good **reference implementations**; port the logic rather than ship the scripts |

Conclusion: **there is no reusable, licensed open tool for VNS dose-response analysis**. This is the main gap and the main opportunity: every SPARC stimulation dataset needs the same steps (detect stimulation epochs, compute baseline vs during vs post physiology, tabulate against parameters, fit dose-response, find thresholds and the neural fulcrum), and each lab wrote ad hoc MATLAB.

### 2.3 Proposed analysis design (in-house, MIT/Apache)

1. **Stimulation epoch extraction**: from a stimulus trigger/marker channel (Spike2 event/marker channels, LabChart comments, ABF epochs, CSV/XLSX stimulation tables in the dataset), or by detecting artefacts in the stimulus monitor channel. Output a BIDS-like `events.tsv`: onset, duration, amplitude, pulse width, frequency, polarity, electrode/contact, train on/off.
2. **Physiological readouts per epoch** (reuse family 1 apps): HR (NeuroKit2 R-peaks), MAP/SBP/DBP per beat, breathing rate and tidal amplitude (NeuroKit2 RSP), EMG RMS (laryngeal side effect), gastric/colonic motility index (family 4).
3. **Response metrics**: delta and percent change vs pre-stimulus baseline window, time to peak, recovery time; artefact masking of the stimulus period.
4. **Dose-response modelling**: sigmoid (Hill/Boltzmann) fit of response vs amplitude per frequency (SciPy `curve_fit`), threshold (e.g. 5 or 10 % change), EC50, saturation; 2-D response surfaces over amplitude x frequency (dataset 9 uses exactly this "stimulus-response surface" layout; dataset 349 is a 2-D current x frequency grid); neural fulcrum detection (Ardell 2017).
5. **Evoked CAP analysis** (when nerve recordings exist): stimulus-locked averaging, artefact blanking/template subtraction, latency windows converted to conduction-velocity bands from the electrode distance (A-alpha/beta > 30 m/s, A-delta 5-30, B 3-15, C < 2 m/s; exact bands configurable), area/peak-to-peak per window, recruitment curves per fibre class. See family 3.

Reference implementations to port: Chang 2020 (physiological markers to fibre engagement), Nicolai 2020/Blanz 2023 (eCAP windows), dataset 349 `data_helper.py` (B-fibre recruitment vs HR).

---

## 3. Peripheral nerve recordings (CAPs, conduction velocity, fibre types, spike sorting, MSNA)

| Tool | What it does | Primary paper (verified DOI) | Repository | Licence | Weights | Runtime / GPU | Maintenance / adoption |
|---|---|---|---|---|---|---|---|
| **SpikeInterface** | Unified reading (via neo), preprocessing, sorter wrappers, quality metrics, export; works on any extracellular recording incl. nerve cuff/intrafascicular arrays | Buccino AP, Hurwitz CL, Garcia S, Magland J, Siegle JH, Hurwitz R, Hennig MH (2020). SpikeInterface, a unified framework for spike sorting. *eLife* 9:e61834. 10.7554/eLife.61834 | https://github.com/SpikeInterface/spikeinterface | **MIT** | none | Python, CPU | Very active, 870 stars (already used in the team's Neuropixels apps) |
| **MountainSort5** | Template-free sorter, CPU friendly, good for few-channel data | (software; Magland et al., Flatiron) | https://github.com/flatironinstitute/mountainsort5 | **Apache-2.0** | none | Python, CPU | Active |
| **Tridesclous** | Template matching sorter with GUI; CPU, small channel counts | (software) | https://github.com/tridesclous/tridesclous | **MIT** | none | Python, CPU (OpenCL optional) | Active |
| **Kilosort4** | High-density probe sorter | Pachitariu M, Sridhar S, Pennington J, Stringer C (2024). Spike sorting with Kilosort4. *Nature Methods* 21:914-921. 10.1038/s41592-024-02232-7 | https://github.com/MouseLand/Kilosort | **GPL-3.0** [GPL] | none | Python, **GPU** recommended | Active. Poor fit for 1-4 channel nerve cuffs; listed for completeness |
| **openMNGlab** (Digital-C-Fiber fork) | Microneurography (C-fibre "marking"/latency tracking) data model and analysis | Schlebusch F, Kehrein F, Röhrig R, Namer B, Kutafina E (2021). openMNGlab: data analysis framework for microneurography - a technical report. *Stud Health Technol Inform* (German Medical Data Sciences 2021). 10.3233/SHTI210556 | https://github.com/Digital-C-Fiber/openMNGlab (MIT); original https://github.com/rwth-imi/openMNGlab (**AGPL-3.0**) | MIT fork / AGPL original [GPL] | none | Python | Both stale (2023-24), 0-1 stars. Human C-fibre microneurography is rare in SPARC |
| **MNG-Spike-Sorting-Pipeline** | Notebook sorting microneurography spikes by morphology | (repo) | https://github.com/Digital-C-Fiber/MNG-Spike-Sorting-Pipeline | MIT | none | Jupyter | Small, 2026 |
| **msna-detect** | Deep-learning MSNA burst detection on integrated neurograms | Dow R, Anselmo M, Lee E, Keller-Ross M, Varatharajah Y (2025). A robust deep learning framework for detecting bursts in muscle sympathetic nerve activity. *2025 IEEE EMBC* pp 1-4. 10.1109/EMBC58623.2025.11253957 | https://github.com/ryanirl/msna-detect (+ `msna-sim` synthetic data generator, MIT) | **MIT** | one pretrained model `msna-v1` (trained on synthetic data), downloaded by `from_pretrained`; must be baked into the image; weight licence not stated separately (repo MIT) | Python/PyTorch, CPU OK | New (2025), 1 star |
| **MSNA-Burst-Analysis** | Automated MSNA burst quantification (Hamner & Taylor style) | method: Hamner JW, Taylor JA (2001). Automated quantification of sympathetic beat-by-beat activity, independent of signal quality. *J Appl Physiol* 91(3):1199-1206. 10.1152/jappl.2001.91.3.1199 | https://github.com/gefoster11/MSNA-Burst-Analysis | GPL-3.0 [GPL] | none | R | 5 stars, 2024 |
| **interactive-cap-analyzer** | Interactive CAP measurement (peaks, latency, area) | (repo) | https://github.com/Xiangyu-Li97/interactive-cap-analyzer | MIT | none | **MATLAB** [MATLAB] | 11 stars |
| **CAP-analysis** (EIN-lab) | CAP extraction/characterisation | (repo) | https://github.com/EIN-lab/CAP-analysis | custom/NOASSERTION [MATLAB] | none | MATLAB | Stale (2018) |

### 3.1 Assessment

- **No maintained, permissively licensed Python package exists for stimulus-evoked CAP analysis, conduction velocity or A/B/C fibre classification.** GitHub hits are MATLAB scripts or student projects. The methods are simple and well described (Settell 2020, Nicolai 2020, Chang 2020): implement in-house with NumPy/SciPy/neo, which also lets the app share the epoching code with family 2.
  - Inputs: raw nerve channel, stimulus trigger times, stimulation-recording electrode distance (from SPARC `samples.xlsx`/protocol or user parameter).
  - Steps: stimulus-locked epochs; artefact blanking or template subtraction (exponential fit or "ligated/crushed nerve" control trials, as dataset 430 recorded); averaging; latency to CV conversion; integrate rectified signal within fibre-class CV windows; recruitment curves vs amplitude; thresholds.
- **MSNA**: SPARC has almost no human MSNA (search "microneurography" returns 2 datasets, both tumour recordings). Low priority; if needed, port Hamner & Taylor (2001) or use msna-detect (MIT).
- **Spontaneous vagal/nerve activity** (e.g. datasets 51 bilateral rat cervical vagus, 380 freely moving pig, 27 pig nodose): SpikeInterface + MountainSort5/Tridesclous, plus "neurogram" features (rectified-integrated activity, burst detection, respiratory/cardiac phase coupling). All MIT/Apache.

---

## 4. Gastrointestinal and bladder physiology

### 4.1 Methods literature

| Paper | Use | DOI |
|---|---|---|
| Yassi R, O'Grady G, Paskaranandavadivel N, Du P, Angeli TR, Pullan AJ, et al. (2012). The gastrointestinal electrical mapping suite (GEMS): software for analyzing and visualizing high-resolution (multi-electrode) recordings in spatiotemporal detail. *BMC Gastroenterology* 12:60 | Reference pipeline for HR slow-wave mapping (event detection, activation-time maps, velocity) | 10.1186/1471-230X-12-60 |
| Erickson JC, O'Grady G, Du P, Obioha C, Qiao W, Richards WO, et al. (2010). Falling-edge, variable threshold (FEVT) method for the automated detection of gastric slow wave events in high-resolution serosal electrode recordings. *Ann Biomed Eng* 38(4):1511-1529 | Slow-wave event detection algorithm (implementable) | 10.1007/s10439-009-9870-3 |
| O'Grady G, Du P, Cheng LK, Egbuji JU, Lammers WJEP, Windsor JA, et al. (2010). Origin and propagation of human gastric slow-wave activity defined by high-resolution mapping. *Am J Physiol GI* 299(3):G585-G592 | Normal propagation patterns, frequencies | 10.1152/ajpgi.00125.2010 |
| Wolpert N, Rebollo I, Tallon-Baudry C (2020). Electrogastrography for psychophysiological research: practical considerations, analysis pipeline, and normative data in a large sample. *Psychophysiology* 57(9):e13599 | Standard EGG pipeline (channel selection, peak frequency 2-4 cpm, cycle stats) | 10.1111/psyp.13599 |
| Hennig GW (2016). Spatio-temporal mapping and the enteric nervous system. In: The Enteric Nervous System, *Adv Exp Med Biol* pp 31-42 | Spatiotemporal (ST) maps of motility | 10.1007/978-3-319-27592-5_4 |

### 4.2 Tools

| Tool | What it does | Repository | Licence | Runtime | Status / verdict |
|---|---|---|---|---|---|
| **GEMS** | HR gastric slow-wave mapping (Auckland Bioengineering Institute) | not in any public code repository found | not open source (distributed by the authors) [MATLAB] [PROP] | MATLAB | Use only as method reference; no open Python alternative exists |
| **gastropy** | EGG processing (filtering, channel selection, peak frequency, cycle durations, instability), gastric-brain coupling | https://github.com/embodied-computation-group/gastropy | **MIT** | Python, CPU | Very new (created 2026-02, last push 2026-04, 13 stars); human 2-4 cpm defaults; animal species need other bands (rat ~4-6 cpm, pig ~3 cpm, ferret ~8-10 cpm: make parameters) |
| Gastric_Signal_Processing_Toolbox (GSPT) | EGG toolbox | https://github.com/AleIan2025/Gastric_Signal_Processing_Toolbox---GSPT- | MIT | MATLAB [MATLAB] | New, 0 stars |
| Statistical EGG / syEGG | EGG ML, augmentation | https://github.com/NadicaSm/syEGG | GPL-3.0 [GPL] | Octave/R | Not needed |
| **NeuroKit2** EMG/signal utilities | Envelope, RMS, bursts | (section 1) | MIT | Python | Usable for gastric/antral EMG and EUS EMG |
| cystometry_analyzer (Samineni lab) | Rodent cystometry analysis | https://github.com/Samineni-Lab/cystometry_analyzer | **none** [NOLIC] | Python | Reference only |
| UDI_Scripts_Python (1urology) | Awake mouse cystometry (infrared-enhanced) | https://github.com/1urology/UDI_Scripts_Python | **none** [NOLIC] | Python | Reference only |
| PatapoutianLab/cystometry | Bladder pressure + EMG | https://github.com/PatapoutianLab/cystometry | **none** [NOLIC] [MATLAB] | MATLAB | Reference only |
| maxneuro/cystometry_matlabscripts | Anaesthetised cystometry time-series analysis | https://github.com/maxneuro/cystometry_matlabscripts | Apache-2.0 | MATLAB [MATLAB] | Portable logic, Apache |
| PlotHRM (used by SPARC dataset 33) | Colonic HRM analysis | not available (dataset README: "not freely available") | proprietary [PROP] | MATLAB/Java | Not usable |

### 4.3 Assessment

- **There is no open, maintained Python tool for high-resolution GI electrical mapping, colonic manometry or cystometry.** All are lab MATLAB scripts, unlicensed repos, or closed software (GEMS, PlotHRM, Laborie/Medical Measurement Systems urodynamics software). All four analyses are, however, signal-processing routines with well-specified literature methods, so in-house apps (MIT/Apache) on NumPy/SciPy are realistic:
  - **Gastric/GI myoelectric (EGG, serosal EMG)**: band-pass per species, dominant frequency and power (Welch), percentage of normal rhythm (brady/normo/tachy-gastria), cycle-to-cycle instability, spike-burst (contractile) detection, pre/during/post-stimulation comparison. gastropy (MIT) can be a dependency for EGG; check its maturity first.
  - **HR slow-wave mapping**: FEVT-style event detection, activation times, isochronal maps and velocity by finite differences over the electrode grid. Medium-high effort; SPARC has few raw HR mapping datasets (search "gastric slow wave" found only a model dataset), so lower priority.
  - **Colonic manometry/motility**: motility index (area under pressure curve or log-sum of amplitudes) per channel and window, contraction detection, propagating pattern detection across sensors (cross-correlation lags), ST maps as images. Datasets 149/150/34/653 (Yucatan minipig, Spike2 `.smr`) and 33 (human colon HRM, `.txt`) fit directly; the 149 curators already define "motility index before, during, after stimulation".
  - **Cystometry**: voiding contraction detection, intercontraction interval, threshold pressure, maximum pressure, compliance (dV/dP), voided volume if infusion rate known, non-voiding contractions; EUS EMG bursting. Datasets 357 (rat, 33 GB), 206 (rat, HDF5, 43 MB), 378 and 691 (human urodynamics, LabChart + text exports), 473/533/463 (wireless pig/cat bladder monitoring).

---

## 5. MicroCT and histology of nerves; anatomical scaffold mapping

### 5.1 Papers

| Paper | Use | DOI |
|---|---|---|
| Zaimi A, Wabartha M, Herman V, Antonsanti PL, Perone CS, Cohen-Adad J (2018). AxonDeepSeg: automatic axon and myelin segmentation from microscopy data using convolutional neural networks. *Scientific Reports* 8:3816 | Axon/myelin segmentation, g-ratio, axon density | 10.1038/s41598-018-22181-4 |
| Pelot NA, Goldhagen GB, Cariello JE, Musselman ED, Clissold KA, Ezzell JA, et al. (2020). Quantified morphology of the cervical and subdiaphragmatic vagus nerves of human, pig, and rat. *Frontiers in Neuroscience* 14:601479 | Defines the SPARC vagus morphometry (effective nerve/fascicle diameters, fascicle counts); data in SPARC datasets 60 (rat), 64 and 89 (pig), 65 (human) with MATLAB code | 10.3389/fnins.2020.601479 |
| Upadhye AR, Kolluru C, Druschel L, Al Lababidi L, Ahmad SS, Menendez DM, et al. (2022). Fascicles split or merge every ~560 microns within the human cervical vagus nerve. *J Neural Eng* 19(5):054001 | microCT fascicle tracking, split/merge events (dataset 321 morphometry spreadsheet) | 10.1088/1741-2552/ac9643 |
| Buyukcelik ON, Lapierre-Landry M, Kolluru C, Upadhye AR, Marshall DP, Pelot NA, et al. (2023). Deep-learning segmentation of fascicles from microCT of the human vagus nerve. *Frontiers in Neuroscience* 17:1169187 | U-Net fascicle segmentation for microCT (REVA). No public code repository found on GitHub; weights availability unverified | 10.3389/fnins.2023.1169187 |
| Osanlouy M, Bandrowski A, de Bono B, Brooks D, Cassarà AM, Christie R, et al. (2021). The SPARC DRC: building a resource for the autonomic nervous system community. *Frontiers in Physiology* 12:693735 | Describes scaffolds, flatmaps, MAP client, o²S²PARC | 10.3389/fphys.2021.693735 |

### 5.2 Tools

| Tool | What it does | Repository | Licence | Weights | Runtime / GPU | Status |
|---|---|---|---|---|---|---|
| **AxonDeepSeg** (v5, nnU-Net based) | Axon + myelin segmentation (TEM, SEM, bright-field incl. toluidine blue, CARS), morphometrics (axon diameter, myelin thickness, g-ratio, density) | https://github.com/axondeepseg/axondeepseg | **MIT** | Separate repos. **MIT**: `default-BF-model`, `default-SEM-model`, `default-TEM-model`, `default-CARS-model`, `default-wakehealth-model`, `model-seg-pns-bf`, `model_postprocess_touching_myelin`. **No licence file**: `model_seg_generalist` (the current "generalist" default, release r20240416, 250-345 MB zips), `model_seg_human_axon-myelin_bf`, `model_seg_rabbit_axon-myelin_bf`, `model_seg_nerve` (nerve area for density) [NOLIC weights] | Python/PyTorch; CPU inference works (slow on whole slides), GPU optional | Active (2026-11-10), 130 stars; widely used in PNS histology. Weights download at install time: bake into image |
| **nnU-Net v2** | Self-configuring segmentation; train a fascicle model on SPARC microCT/histology masks | https://github.com/MIC-DKFZ/nnUNet | **Apache-2.0** | none shipped (train own) | Python/PyTorch; GPU to train, CPU inference feasible | Very active, 9k stars |
| **Cellpose** | Generalist instance segmentation; fascicles in trichrome/IHC cross-sections are cell-like blobs | https://github.com/MouseLand/cellpose | **BSD-3-Clause** | pretrained models downloaded on first use (bake in); check model terms at the version used | Python/PyTorch, CPU OK | Very active, 2.4k stars |
| **StarDist** | Star-convex instance segmentation | https://github.com/stardist/stardist | **BSD-3-Clause** | pretrained 2D models bundled (BSD) | Python/TensorFlow, CPU OK | Active |
| scikit-image / SciPy | Morphometry from binary masks (area, effective diameter = 2*sqrt(A/pi), counts, perineurium thickness via distance transforms) | - | BSD-3 | - | CPU | Standard |
| Pelot 2020 MATLAB scripts (in SPARC datasets 60, 64, 65, 89) | Morphometry from binary traces | in dataset `code/` | CC-BY-4.0 (dataset licence) [MATLAB] | - | MATLAB | Port to Python: the metrics are simple |
| tlevy-nds/fascicleMaskRCNN, dtovbis/FascicleReconstruction | Fascicle detection / 3D reconstruction | GitHub | **none** [NOLIC] [MATLAB] | - | MATLAB | Reference only |
| MBF Neurolucida / NIS-Elements | Tracing used by many SPARC datasets (xml traces, jp2) | - | proprietary [PROP] | - | - | Outputs readable (Neurolucida XML is plain XML) |
| **scaffoldmaker** | Generates parametrised organ/nerve scaffolds (heart, stomach, colon, bladder, vagus, whole body) | https://github.com/ABI-Software/scaffoldmaker | **Apache-2.0** (Univ. Auckland) | - | Python + cmlibs.zinc | Active (2026-10), low stars but the SPARC standard |
| **scaffoldfitter** | Fits a scaffold to digitised data (landmarks, contours) | https://github.com/ABI-Software/scaffoldfitter | **Apache-2.0** | - | Python | Active (2026-11) |
| **cmlibs.zinc** (OpenCMISS-Zinc) | FE field library behind scaffolds (`.exf`) | https://github.com/cmlibs/zinc ; PyPI `cmlibs.zinc` 4.2.1 | **MPL-2.0** (weak, file-level copyleft; fine to use unmodified) | - | C++ with Python wheels (Linux available) | Maintained |
| **MAP Client** | GUI workflow tool that strings scaffold creation, fitting and data mapping ("Scaffold Mapping Tools") | https://github.com/MusculoskeletalAtlasProject/mapclient | **GPL-3.0** [GPL] | - | Python/Qt GUI | Active; GUI and GPL: do not package; call the Apache libraries directly instead |

### 5.3 Assessment

- **Histology morphometry is ready to package**: AxonDeepSeg (MIT, use the MIT-licensed default models) for axon/myelin; a fascicle/nerve-boundary step (Cellpose or StarDist, or a small nnU-Net trained on SPARC trichrome traces from datasets 60/64/89/65, which ship binary masks = ready-made training data); then a morphometry step reproducing Pelot 2020 metrics. Avoid the unlicensed `model_seg_generalist` weights unless the AxonDeepSeg team confirms terms (ask: they are an academic lab at Polytechnique Montréal / NeuroPoly and the code is MIT).
- **microCT fascicle segmentation**: no packaged open model. Options: nnU-Net trained on REVA labels (datasets 521 "Automated 3D segmentation of human vagus nerve fascicles and epineurium from microCT" has labels, 81 GB), or classical 3D (threshold + watershed + slice-to-slice tracking for split/merge counts per Upadhye 2022). Most microCT datasets are 0.5-4.5 TB; demo on dataset 321 (0.43 GB, 72 µm voxels).
- **Scaffold mapping** needs human-in-the-loop digitisation (landmarks) and the inputs are rarely in public datasets, so automated "map to scaffold" apps are low priority. A thin app "export scaffold as mesh/VTK for viewing" on scaffoldmaker (Apache) is cheap but low impact.

---

## 6. SPARC data conventions and file readers

### 6.1 SPARC Data Structure (SDS)

- Reference: Bandrowski A, Grethe JS, Pilko A, Gillespie T, Pine G, Patel B, et al. (2021). SPARC Data Structure: rationale and design of a FAIR standard for biomedical research data. *bioRxiv* 10.1101/2021.02.10.430563.
- Layout: top-level `dataset_description.xlsx`, `subjects.xlsx`, `samples.xlsx`, `code_description.xlsx`, `submission.xlsx`, `README`/`CHANGES`; folders `primary/` (raw, organised `sub-<id>/[sam-<id>/][perf-<id>/]`), `derivative/`, `code/`, `docs/`, `protocol/`, `source/`; a `manifest.xlsx` (or .csv/.json) per folder describes each file (description, timestamp, file type, "additional types", and often stimulation conditions). Performance (`perf-`) folders typically correspond to a stimulation condition or session. Stimulation parameters are **not** a standardised machine-readable field: they appear in manifests, `docs/` tables, file names (e.g. `1mA_10Hz`), or Spike2/LabChart comments, so apps need a configurable "events/parameters table" input.
- Tools: SODA for SPARC (curation GUI, https://github.com/fairdataihub/SODA-for-SPARC, MIT), sparc-curation / SDS validator (https://github.com/SciCrunch/sparc-curation, MIT), `sparc-me` (https://github.com/SPARC-FAIR-Codeathon/sparc-me, Apache-2.0; read/write SDS metadata in Python), `sparc.client` (https://github.com/nih-sparc/sparc.client, Apache-2.0).

### 6.2 What formats SPARC physiology datasets actually use (census)

Census of the file manifests of **all 421 public SPARC datasets** on Discover (organisations "SPARC" and "SPARC Consortium"; the 681 total includes Penn CNT and other organisations), via `GET /discover/datasets/{id}/versions/{v}/metadata`, 2026-11-12:

| Format | Datasets | Files | Size | Typical source | Example dataset ids |
|---|---|---|---|---|---|
| `.mat` (MATLAB, mixed v5 and v7.3) | 42 | 18,706 | 2.98 TB | many (also derived) | 9, 26, 27, 28, 60, 64, 65, 375 |
| `.smrx` (Spike2 64-bit) | 16 | 465 | 302 GB | CED Spike2 | 26, 27, 28, 52, 130, 151, 164, 204, 237, 315, 338, 655 |
| `.smr` (Spike2 32-bit) | 13 | 538 | 1.2 TB | CED Spike2 | 34, 35, 138, 149, 150, 237, 488, 489, 546, 547, 652, 653, 659 |
| `.s2r`/`.s2rx` | 6 / 11 | 415 / 98 | ~0 | Spike2 resource (display) files, ignore | |
| `.adicht` (LabChart) | 8 | 604 | 40 GB | ADInstruments | 51, 88, 333, 375, 376, 378, 400, 691 |
| TDT tank (`.tev/.tsq/.tdx/.tbk`, `.sev`) | 4 | ~1,250 each | 371 GB | Tucker-Davis | 163, 229, 262, 333 |
| Blackrock (`.ns2/.ns5/.nev`) | 5 (any of the three) | 2,471 (ns5) | 573 GB | Blackrock/Ripple | 138, 301, 391, 435, 489 |
| Intan `.rhd` | 4 | 6,856 | 2.0 TB | Intan | 48, 316, 436, 522 |
| `.abf` (Axon) | 4 | 591 | 2.8 GB | pClamp | 257, 297, 430, 440 |
| Biopac `.acq` | 6 | 66 | 0.5 GB | AcqKnowledge | 126, 148, 224, 283, 291, 336 |
| `.hdf5`/`.h5` | 4 | 54 | 4 GB | custom | 206, 349, 380, 391 |
| Plexon `.plx/.pl2` | 2 | 103 | 71 GB | Plexon | 34, 488 |
| `.edf` | 2 | 35 | 1.5 GB | | 138, 541 |
| `.wav` | 1 | 282 | 0.2 GB | ECG as audio | 406 |
| `.csv` / `.txt` / `.xlsx` | 376 / 179 / 420 | | 74 / 57 / 669 GB | exports, tables, manifests | most |
| `.nwb`, `.tdms` | **0** | 0 | - | - | - |

Imaging, for family 5: `.tif/.tiff` (173 + 32 datasets, 38.8 TB), `.jpx/.jp2` (MBF web derivatives, 94 + 74 datasets), `.czi` (44), `.ims` (16), `.nii(.gz)` (41, microCT), `.exf` (14, scaffolds), `.vtk/.stl` (36/32).

Takeaway: **one format-agnostic "physiology import" app is a prerequisite** for every family. Spike2 (29 datasets) and MATLAB (42) dominate, followed by LabChart, TDT, Blackrock, Intan, ABF, Biopac and custom HDF5. NWB and TDMS are absent, so do not prioritise them as inputs (NWB is still a good *output* format).

### 6.3 Readers and their licences

| Reader | Formats | Repository / package | Licence | Linux/Docker | Notes |
|---|---|---|---|---|---|
| **neo** (Garcia S, Guarino D, Jaillet F, et al. 2014. Neo: an object model for handling electrophysiology data in multiple formats. *Front Neuroinform* 8:10. 10.3389/fninf.2014.00010) | Spike2 `.smr` (Spike2RawIO, pure Python), `.smrx` (CedRawIO, **needs sonpy**), ABF, TDT, Blackrock, Intan, Plexon, EDF, many more (not Biopac) | https://github.com/NeuralEnsemble/python-neo (PyPI `neo` 0.14.6) | **BSD-3-Clause** | yes, pure Python | Active (2026-11-09), 370 stars; also the backend of SpikeInterface |
| **sonpy** (CED) | Spike2 `.smr`/`.smrx` read/write | PyPI `sonpy` 1.9.12 (no source repository) | **No licence stated**; neo documents it as "NOT open source", maintained by CED [PROP] | Linux wheel only for **CPython 3.14 on manylinux_2_39 x86_64** (e.g. Ubuntu 24.04+); Windows wheels for 3.10-3.14 | Required for the 16 `.smrx` datasets. Ask CED for redistribution permission before baking into public images, or install at build time from PyPI (still redistributes the binary in the image) |
| **adi-reader** | LabChart `.adicht` | https://github.com/JimHokanson/adinstruments_sdk_python (PyPI `adi-reader` 0.2.0) | MIT wrapper around the proprietary ADInstruments SDK DLL [PROP DLL] | **Windows only** ("not fixable by me, requires changes by ADInstruments", README) | Unusable in Linux containers |
| **adichtion** | `.adicht` pure-Python, reverse engineered; LabChart for Mac documents | https://github.com/emilwalsted/adichtion | **GPL-3.0** [GPL] | yes (numpy only) | Brand new (created 2026-10-06, 3 stars). Claims sample-exact decoding against LabChart text exports. Validate on SPARC 378/691, which ship paired `.adicht` + `.txt` exports. Being a GPL dependency, isolate it in a converter app |
| LabChart exports | `.txt`, `.mat` exported by LabChart | - | - | yes | Several SPARC datasets ship both (378, 691); preferred path where available |
| **pyABF** | Axon ABF1/ABF2 | https://github.com/swharden/pyABF | **MIT** | yes | Stable (last push 2024-10), widely used; neo also reads ABF |
| **npTDMS** | NI TDMS | https://github.com/adamreeve/npTDMS | **LGPL-3.0** [GPL-weak] | yes | Not needed (no TDMS in SPARC) |
| **pyEDFlib** | EDF/BDF | https://github.com/holgern/pyedflib | **BSD-3-Clause** | yes (wheels) | |
| **h5py** | HDF5 (incl. MATLAB v7.3) | https://github.com/h5py/h5py | **BSD-3-Clause** | yes | |
| SciPy `scipy.io.loadmat` | MATLAB v4-v7.2 | SciPy | **BSD-3-Clause** | yes | v7.3 needs h5py |
| mat73 | MATLAB v7.3 convenience | https://github.com/skjerns/mat7.3 | **GPL-3.0** [GPL] | yes | Avoid; use h5py directly |
| `tdt` (TDT official) | TDT tanks | PyPI `tdt` 0.7.6 | no licence metadata on PyPI [NOLIC?] | yes | Prefer neo `TdtRawIO` (BSD) |
| bioread | Biopac `.acq` | https://github.com/uwmadison-chm/bioread | **MIT** | yes | for the 6 `.acq` datasets |
| pynwb | NWB output | https://github.com/NeurodataWithoutBorders/pynwb | **BSD-3-Clause-LBNL** (BSD-style) | yes | Output/interchange format |

---

## 7. Demo datasets on Pennsieve Discover

All are public SPARC datasets, licence **CC-BY-4.0** ("Creative Commons Attribution" in the API), sizes and file counts from the Discover API on 2026-11-12. "Stim annotated" = whether stimulation parameters are machine-recoverable.

| # | Id (version) | Title | DOI | Size / files | Formats | What is recorded | Stim annotated? | Families |
|---|---|---|---|---|---|---|---|---|
| A | **9** (v4) | Influence of left vagal stimulus pulse parameters on vagal and gastric activity in rat | 10.26275/qh3q-elj6 | 48 MB / 133 | `.mat` (ephys + derived per subject), `.xlsx` (`plog.xlsx` parameter log), MATLAB plotting code | Rat vagal CNAPs and antral/gastric EMG during sweeps of 28+ current x pulse width x frequency combinations at cervical, ventral gastric branch and gastric "hotspot" sites, paired baselines | **Yes**: per-trial parameter log + folder names (`10 Hz Left Cervical VNS Parameter Sweep`) | 2, 3, 4 (best all-round small demo) |
| B | **655** (v1) | Single-electrode bidirectional control of heart rate via vagus nerve modulation in rat model | 10.26275/5cwo-mkpz | 1.9 GB / 100 | Spike2 `.smrx` (+ `.s2rx`), `.csv` exports of the same, `.xlsx` derived HR | Rat ECG/HR, stimulation frequency and KHFAC block amplitude envelopes, closed-loop controller; calibration bpm/Hz | **Yes**: amplitude and frequency envelopes recorded as channels; protocol in README | 1, 2 (CSV twins avoid the sonpy problem) |
| C | **349** (v1) | Influence of vagus nerve stimulation on cardiac activity in pigs | 10.26275/dm5l-tspb | 2.2 GB / 23 | `.hdf5` (one per pig), `code/data_helper.py` | Pig ECG + vagus nerve (two rostral recording cuffs) for a 2-D grid of 20+ VNS settings: 0.05-2.5 mA x 2-30 Hz, 500 µs, 5 s trains, 30 s windows | **Yes**: grid described in README; per-stimulation parameters stored with the HDF5 records (read via `code/data_helper.py`; file contents not opened in this survey) | 1, 2, 3 (HR dose-response + eCAP fibre recruitment in one file) |
| D | **430** (v1) | Acute stimulation and recording of the rat sciatic nerve using a self-sizing and soft closing polymer cuff electrode | 10.26275/6fxa-8gef | 367 MB / 99 | Axon `.abf` (100 kHz) | Rat sciatic ENG CAPs + EMG; 100 µA-1 mA in 100 µA steps, 200/500 µs pulses, 1 or 30 Hz; ligated-nerve artefact controls | **Yes**: in file names (`100uA_200us.abf`) and `perf-` folders | 3 (CAP recruitment curve, artefact control) |
| E | **149** (v3) | Influence of acute thoracolumbar root nerves electrical stimulation on colonic motility in anesthetized male Yucatan minipig | 10.26275/abac-rzbv | 211 MB / 96 | Spike2 **`.smr`** (32-bit: readable by neo without sonpy), `.xlsx` derived motility index | Proximal/transverse/distal colonic manometry during T12/L1 root stimulation (10 Hz continuous or 30 Hz pulse trains, afferent vs afferent+efferent) | **Yes**: `perf-` folder names (`perf-T12-stim_30Hz_PT_afferent`) | 4 (colonic motility index), 2 |
| F | **206** (v1) | Recording of electrically evoked neural activity and bladder pressure responses in awake rats chronically implanted with a pelvic nerve array | 10.26275/kkmb-vun5 | 45 MB / 91 | `.hdf5`, `.csv` stimulus tables | Pelvic nerve ECAPs and bladder (and colonic) pressure responses to pelvic nerve stimulation; electrode impedances | **Yes**: per-stimulus CSV tables | 3, 4 (bladder), 2 |
| G | **406** (v1) | Best parameters of heart rate variability for assessing autonomic responses to brief rectal distention in patients with IBS | 10.26275/nung-b9bm | 234 MB / 613 | ECG as `.wav` (282), `.dat`, MATLAB HRV app | Human ECG (22 IBS patients): 15 min baseline then 30 s rectal distensions at 5 mmHg steps; authors' HRV results | Partly: distension steps in protocol/derived files, not as channel markers | 1 (human HRV; validation against the authors' HRV values) |
| H | **378** (v2) | Targeting bladder function with network-specific epidural stimulation after chronic spinal cord injury | 10.26275/t2ve-vu9o | 341 MB / 48 | LabChart `.adicht` **paired with `.txt` exports**, PDFs | Human urodynamics (detrusor and urethral pressure, sphincter EMG) during filling/voiding with varied epidural stimulation configs | Partly: configs in PDFs/xlsx | 4 (cystometry), also the `.adicht` reader validation set |
| I | **691** (v1) | Blood pressure responses to bladder and bowel distension after human spinal cord injury | 10.26275/j4ga-dvrv | 1.7 GB / 294 | `.adicht` + paired Laborie `.txt` | Human SBP/DBP during urodynamic cystometry and anorectal manometry (autonomic dysreflexia), 56 subjects | Distension events in recordings | 1 (BP), 4 (cystometry) |
| J | **64** (v4) / **60** (v5) | Quantified morphology of the pig / rat vagus nerve | 10.26275/maq2-eii4 / 10.26275/lg3c-1kjf | 968 MB / 180; 206 MB / 147 | `.tif` histology + binary fascicle/nerve traces, `.jp2`, `.xml` (Neurolucida), `.mat` metrics, MATLAB code | Masson's trichrome cross-sections (cervical and subdiaphragmatic vagus) with ground-truth segmentations and published metrics (Pelot 2020) | n/a | 5 (fascicle segmentation + morphometry, with ground truth) |
| K | **321** (v1) | Human cervical vagus nerve fascicle imaging with MicroCT | 10.26275/59t4-jlnz | 428 MB / 282 | `.tif` microCT stacks (+ OME-TIFF, `.jpx`), `.xlsx` fascicle morphometry and split/merge counts | 8 human mid-cervical vagus specimens, osmium stained, 72 µm isotropic | n/a | 5 (microCT fascicle tracking, with published counts) |

Runner-up / larger: 375 and 376 (mouse ECG/EMG during VNS, Huffman 2023; 23 GB each, LabChart + `.mat`), 380 (freely moving pig VNS, HDF5, 1.5 GB), 51 (bilateral rat cervical vagus, LabChart only, 10 GB), 333 (pig multi-contact VNS, TDT + LabChart, 251 GB), 537 (ferret EGG features under VNS, **Python pickles**: never unpickle untrusted pickles in an app; use only as reference), 33 (human colon HRM `.txt`, 0.4 GB, but its analysis software is closed).

---

## Licence risk

1. **sonpy (CED)**: closed-source binary, no licence text, Linux wheel only for CPython 3.14 / glibc 2.39 x86_64. Needed for `.smrx` (16 SPARC datasets). Ask CED about redistribution in public container images; until then use `.smr` (neo, BSD) and CSV twins where datasets provide them (655 does).
2. **LabChart `.adicht`**: the only official reader (ADInstruments SDK via `adi-reader`, MIT wrapper) is **Windows-only**. The Linux alternative `adichtion` is **GPL-3.0** and two months old. Put it in a separate converter app (GPL obligations then attach to that image only) and validate against paired `.txt` exports (378, 691).
3. **ASCENT and PyFibers (Duke)**: GPL-2.0 **for non-commercial use only**, commercial licence via Duke OTC; ASCENT also needs COMSOL (proprietary). Do not package.
4. **pyPPG**: GPL-3.0 plus a preamble "provided for academic research purpose only", which conflicts with GPL freedoms and is legally ambiguous. Avoid; NeuroKit2 covers PPG.
5. **GPL-3.0 tools**: hrv-analysis, py-ecg-detectors, PhysioZoo/mhrv (also MATLAB), Kilosort4, MSNA-Burst-Analysis (R), Breathe Easy, mat73, MAP Client, syEGG. **AGPL-3.0**: rwth-imi/openMNGlab (the Digital-C-Fiber fork is MIT). **LGPL-3.0**: npTDMS (not needed). **MPL-2.0**: cmlibs.zinc (fine when used unmodified).
6. **No licence (all rights reserved)**: BreathMetrics (MATLAB), Chang 2020 VNS fibre-engagement code, cystometry_analyzer, UDI_Scripts_Python, PatapoutianLab/cystometry, baroreflex R scripts, fascicleMaskRCNN, FascicleReconstruction, `tdt` PyPI package (no licence metadata).
7. **Weights**: AxonDeepSeg `model_seg_generalist` (current default), human/rabbit BF models and `model_seg_nerve` repos have **no licence file**; use the MIT-licensed `default-*` models or ask NeuroPoly. msna-detect `msna-v1` weights are covered only by the repo MIT licence (not stated separately). Cellpose models are downloaded at first run: pin and bake in.
8. **Closed/proprietary analysis software referenced by SPARC datasets**: GEMS (MATLAB), PlotHRM (dataset 33), MBF Neurolucida/NIS-Elements, Sim4Life (o²S²PARC services), COMSOL.
9. **MATLAB-only**: PhysioZoo, BreathMetrics, interactive-cap-analyzer, CAP-analysis, GSPT, Pelot 2020 morphometry scripts, most dataset-embedded code. Port logic rather than run MATLAB (MCR images are large and licence-encumbered for some toolboxes).
10. **Dataset code is CC-BY-4.0**, not an OSI software licence: legally reusable with attribution, but port rather than vendor.

---

## Recommended app shortlist

Ranked by impact on SPARC data. "Effort" is for a team that already builds Python CPU apps: S = 1-3 days, M = 1-2 weeks, L = 3+ weeks.

### Workflow 1 (highest impact): "Nerve stimulation response" (autonomic/cardiovascular dose-response), built as "Cardiovascular Response to Nerve Stimulation" and "Heart Rate Variability and Baroreflex"

Serves the vagus (132), autonomic (105), heart/cardiac (75/61) datasets; the core SPARC experiment and the clearest tooling gap.

| App (suggested name) | Tools | Licence | Demo dataset | Effort |
|---|---|---|---|---|
| `physio-import` - any SPARC physiology file to a common NWB/HDF5 + channel table | neo (BSD-3; Spike2 `.smr`, ABF, TDT, Blackrock, Intan, Plexon, EDF), h5py/SciPy (`.mat`, HDF5), bioread (MIT, `.acq`), pandas (CSV/TXT), pynwb (BSD) for output | BSD/MIT | 149 (`.smr`), 430 (`.abf`), 349 (HDF5), 9 (`.mat`) | M |
| `stim-events` - extract stimulation epochs and parameters into `events.tsv` (from trigger/envelope channels, Spike2/LabChart markers, SDS manifests, file/perf-folder names, parameter tables) | NumPy/SciPy, pandas, sparc-me (Apache-2.0) for SDS metadata | MIT (in-house) | 655, 430, 9 | M |
| `ecg-hrv` - R-peaks, HR, HRV (Task Force metrics) with species presets (human/pig/dog/rat/mouse) | NeuroKit2 (MIT), wfdb-python (MIT) for cross-check | MIT | 406 (human), 655 (rat), 349 (pig) | S-M |
| `bp-resp` - beat-to-beat SBP/DBP/MAP, respiration rate/amplitude, RSA, spontaneous BRS (sequence + spectral) | NeuroKit2 (MIT) + in-house BRS (EuroBaVar methods) | MIT | 691 (human BP), 380/349 | M |
| `stim-dose-response` - baseline/during/post deltas per epoch, sigmoid fits, thresholds, EC50, 2-D amplitude x frequency response surfaces, neural fulcrum | SciPy, statsmodels (BSD), matplotlib | MIT | 349 (current x frequency grid), 655, 9 | M |

### Workflow 2: "Peripheral nerve and visceral organ physiology" (evoked CAPs, GI and bladder motility)

Serves colon (91), stomach (65), bladder (40) and nerve-recording datasets. Reuses `physio-import` and `stim-events` from workflow 1.

| App | Tools | Licence | Demo dataset | Effort |
|---|---|---|---|---|
| `ecap-fibre-types` - stimulus-locked averaging, artefact blanking/subtraction, latency to conduction velocity, A/B/C window integrals, recruitment curves and thresholds | NumPy/SciPy, neo; methods from Settell 2020, Nicolai 2020, Chang 2020 | MIT (in-house) | 430 (rat sciatic, ABF), 9 (rat vagal CNAP), 206 (pelvic ECAP), 349 (pig vagus) | M |
| `gi-motility` - manometry/tension motility index, contraction detection, propagation across sensors, spatiotemporal maps; pre/during/post stimulation | NumPy/SciPy, matplotlib | MIT (in-house) | 149 (minipig colon `.smr`), 653, 33 | M |
| `gastric-myoelectric` - EGG/serosal EMG dominant frequency, %-normal rhythm, instability, spike-burst detection, species bands | gastropy (MIT) + NeuroKit2 (MIT) | MIT | 9 (antral EMG), 537 (reference features) | S-M |
| `cystometry` - voiding contraction detection, intercontraction interval, threshold/max pressure, compliance, non-voiding contractions, EUS EMG bursting | NumPy/SciPy (in-house) | MIT | 206 (rat, HDF5), 378 (human `.txt`), 357 (rat, larger) | M |
| `adicht-convert` (optional, isolated GPL image) - `.adicht` to HDF5/CSV on Linux | adichtion (GPL-3.0) | **GPL-3.0** | 378 / 691 (validate against `.txt`) | S + validation |

### Workflow 3: "Nerve morphology" (histology and microCT)

Serves the large microCT (42) and vagus anatomy datasets (REVA, ~30 datasets of 1-4.5 TB). Lower near-term usage than 1-2 because the data are huge and analyses were already done by the producers, but strongest ML story and reusable for new submissions.

| App | Tools | Licence | Demo dataset | Effort |
|---|---|---|---|---|
| `nerve-fascicle-seg` - fascicle and nerve boundary segmentation in trichrome/IHC cross-sections | Cellpose (BSD-3) or StarDist (BSD-3); optional nnU-Net (Apache-2.0) fine-tuned on SPARC traces from 60/64/65/89 | BSD/Apache (+ own CC-BY-derived weights) | 64 (pig), 60 (rat), with ground-truth masks | M (L if training nnU-Net) |
| `axon-myelin-seg` - axon/myelin segmentation, axon diameter, myelin thickness, g-ratio, density | AxonDeepSeg (MIT) with MIT `default-BF-model`/`default-SEM-model`/`default-TEM-model` | MIT | needs a high-res BF/EM nerve dataset (e.g. 442 SBF-SEM rat pelvic nerve volume, large) | S-M |
| `nerve-morphometry` - Pelot 2020 metrics (effective nerve and fascicle diameters, counts, perineurium) from masks; per-subject tables | scikit-image (BSD-3), pandas | MIT | 64 / 60 (compare to the published `.mat` metrics) | S |
| `microct-fascicle-tracking` - 3D fascicle segmentation and slice-to-slice tracking, split/merge counts | scikit-image/SciPy (classical); nnU-Net (Apache) later, trained on dataset 521 labels | Apache/BSD | 321 (human, 0.43 GB; published split/merge counts) | L |

### Notes for the decision

- Workflow 1 + `physio-import` first: it unlocks every physiology family and has no licence blockers (all MIT/BSD/Apache) except optional `.smrx`/`.adicht` support (sonpy, adichtion).
- In-house code is unavoidable for dose-response, BRS, eCAP fibre typing, GI motility and cystometry: no maintained permissive Python tool exists for any of these. The algorithms are short and literature-defined; credit the method papers in each app's README and CITATION.cff.
- Species presets (HR ranges, HRV bands, gastric frequencies) must be explicit parameters: SPARC is mostly rat, mouse, pig, cat, ferret, dog, and human tools default to human values.
