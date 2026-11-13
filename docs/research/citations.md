# Citations for the physiology apps, verified on 2026-11-13

Every DOI below was fetched from Crossref or DataCite on 2026-11-13 (`scripts/verify-citations.py` does the same check on each app's CITATION.cff). Title, first author and year are **as the registry returns them**; copy every author from the registry, never from this table or from memory.

## Corrections and notes from this check and from opening the demo files

- **Task Force 1996** (10.1161/01.CIR.93.5.1043): Crossref lists one corporate author whose name is truncated ("Electrophysiology, Task Force of the European Society of Cardiology the North A..."). In CITATION.cff use the consortium as `name: Task Force of the European Society of Cardiology and the North American Society of Pacing and Electrophysiology` and check that verify-citations.py accepts it (it compares against the registry; if it flags the name, note the mismatch in the report rather than inventing a person).
- **Fantasia** DataCite gives publication year **1994** for the database DOI (10.13026/C2RG61) and 1996 for the paper (Iyengar et al., Am J Physiol 271:R1078). Fantasia's BP is **uncalibrated** (database description); the survey did not say so.
- **Autonomic Aging** database DOI 10.13026/2hsy-t491 (DataCite, 2021; licence ODbL 1.0, not CC BY); its NIBP is calibrated in mmHg. Not in the survey; added as the calibrated-BP demo.
- **Discover 9** (10.26275/qh3q-elj6): the survey called `plog.xlsx` a per-trial parameter log; it only describes the four sweep folders. Per-trial parameters live inside each animal's `.mat` (`Ist`, `PRF`, `TrainDur`). The data are already epoched and averaged (no continuous signal, no heart rate), so it does not serve the cardiovascular workflows.
- **Discover 655** DataCite year is 2026 (the current version), first creator Shane A Bender.
- **Bertinieri et al. 1985** (the original sequence method) has no DOI in Crossref: cite Parati et al. 1988 and EuroBaVar (Laude et al. 2004), as the survey says.
- **Lipponen & Tarvainen 2019** was added for beat artefact correction; confirm in NeuroKit2's docs that `signal_fixpeaks` (method `Kubios`) implements it before citing it.

## Verified DOIs

| DOI | Registry | Title (registry) | First author | Year | Venue | Used for |
|---|---|---|---|---|---|---|
| 10.1016/j.biopsycho.2005.11.014 | crossref | Toward understanding respiratory sinus arrhythmia: Relations to cardiac vagal tone, evolution and biobehavioral functions | Grossman, Paul | 2007 | Biological Psychology 74:263-285 | RSA physiology (bp-resp README) |
| 10.1016/j.biopsycho.2011.11.009 | crossref | Statistical strategies to quantify respiratory sinus arrhythmia: Are commonly used metrics equivalent? | Lewis, Gregory F. | 2012 | Biological Psychology 89:349-364 | RSA metrics P2T / Porges-Bohrer (bp-resp) |
| 10.1016/j.brs.2020.09.002 | crossref | Quantitative estimation of nerve fiber engagement by vagus nerve stimulation using physiological markers | Chang, Yao-Chuan | 2020 | Brain Stimulation 13:1617-1630 | physiological markers of fibre engagement (stim-dose-response) |
| 10.1038/s41592-019-0686-2 | crossref | SciPy 1.0: fundamental algorithms for scientific computing in Python | Virtanen, Pauli | 2020 | Nature Methods 17:261-272 | SciPy (curve_fit, signal) |
| 10.1038/s41597-022-01202-y | crossref | Autonomic aging – A dataset to quantify changes of cardiovascular autonomic function during healthy aging | Schumann, Andy | 2022 | Scientific Data 9:95 | Autonomic Aging paper |
| 10.1038/sdata.2016.44 | crossref | The brain imaging data structure, a format for organizing and describing outputs of neuroimaging experiments | Gorgolewski, Krzysztof J. | 2016 | Scientific Data 3:160044 | BIDS (events.tsv conventions) |
| 10.1080/03091902.2019.1640306 | crossref | A robust algorithm for heart rate variability time series artefact correction using novel beat classification | Lipponen, Jukka A. | 2019 | Journal of Medical Engineering & Technology 43:173-181 | beat artefact correction (NeuroKit2 signal_fixpeaks; confirm NeuroKit2 uses it) |
| 10.1088/1361-6579/aad7e6 | crossref | Optimized breath detection algorithm in electrical impedance tomography | Khodadad, D | 2018 | Physiological Measurement 39:094001 | breath detection, NeuroKit2 rsp default (bp-resp) |
| 10.1088/1741-2552/ab7ad4 | crossref | Functional vagotopy in the cervical vagus nerve of the domestic pig: implications for the study of vagus nerve stimulation | Settell, Megan L | 2020 | Journal of Neural Engineering 17:026022 | pig VNS (background) |
| 10.1088/1741-2552/ab9db8 | crossref | Sources of off-target effects of vagus nerve stimulation using the helical clinical lead in domestic pigs | Nicolai, Evan N | 2020 | Journal of Neural Engineering 17:046017 | pig VNS off-target effects (background) |
| 10.1088/1741-2552/acb3fd | crossref | Spatially selective stimulation of the pig vagus nerve to modulate target effect versus side effect | Blanz, Stephan L | 2023 | Journal of Neural Engineering 20:016051 | pig VNS selectivity (background) |
| 10.1101/2021.02.10.430563 | crossref | SPARC Data Structure: Rationale and Design of a FAIR Standard for Biomedical Research Data | Bandrowski, Anita | 2021 |  | SDS (optional metadata source) |
| 10.1109/TBME.1985.325532 | crossref | A Real-Time QRS Detection Algorithm | Pan, Jiapu | 1985 | IEEE Transactions on Biomedical Engineering BME-32:230-236 | Pan-Tompkins QRS detector (ecg-hrv option) |
| 10.1113/expphysiol.2007.040733 | crossref | Heart rate variability in mice: a theoretical and practical guide | Thireau, J. | 2008 | Experimental Physiology 93:83-94 | mouse HRV bands (species preset) |
| 10.1113/JP274678 | crossref | Defining the neural fulcrum for chronic vagus nerve stimulation: implications for integrated cardiac control | Ardell, Jeffrey L. | 2017 | The Journal of Physiology 595:6887-6903 | neural fulcrum (stim-dose-response) |
| 10.1152/ajpregu.00709.2002 | crossref | Comparison of various techniques used to estimate spontaneous baroreflex sensitivity (the EuroBaVar study) | Laude, Dominique | 2004 | American Journal of Physiology-Regulatory, Integrative and Comparative Physiology 286:R226-R231 | EuroBaVar BRS methods (bp-resp) |
| 10.1152/ajpregu.1996.271.4.R1078 | crossref | Age-related alterations in the fractal scaling of cardiac interbeat interval dynamics | Iyengar, N. | 1996 | American Journal of Physiology-Regulatory, Integrative and Comparative Physiology 271:R1078-R1084 | Fantasia database paper |
| 10.1161/01.CIR.101.23.e215 | crossref | PhysioBank, PhysioToolkit, and PhysioNet | Goldberger, Ary L. | 2000 | Circulation 101 | PhysioNet (all PhysioNet data, wfdb) |
| 10.1161/01.CIR.93.5.1043 | crossref | Heart Rate Variability | Electrophysiology, Task Force of the European Society of Cardiology the North A | 1996 | Circulation 93:1043-1065 | HRV standard (ecg-hrv, human bands) |
| 10.1161/01.HYP.12.2.214 | crossref | Evaluation of the baroreceptor-heart rate reflex by 24-hour intra-arterial blood pressure monitoring in humans. | Parati, G | 1988 | Hypertension 12:214-222 | BRS sequence method (bp-resp) |
| 10.1186/s42234-023-00107-4 | crossref | Measuring and modeling the effects of vagus nerve stimulation on heart rate and laryngeal muscles | Huffman, William J. | 2023 | Bioelectronic Medicine 9:3 | VNS HR dose-response in mice (stim-dose-response README) |
| 10.13026/2hsy-t491 | datacite | Autonomic Aging: A dataset to quantify changes of cardiovascular autonomic function during healthy aging | Schumann, Andy | 2021 | PhysioNet | Autonomic Aging database |
| 10.13026/9njx-6322 | datacite | Waveform Database Software Package (WFDB) for Python | Xie, Chen | 2023 | PhysioNet | WFDB for Python (physio-import, ecg-hrv) |
| 10.13026/C2RG61 | datacite | Fantasia Database | Iyengar, Nikhil | 1994 | physionet.org | Fantasia database |
| 10.25080/Majora-92bf1922-011 | crossref | Statsmodels: Econometric and Statistical Modeling with Python | Seabold, Skipper | 2010 | Proceedings of the Python in Science Conference:92-96 | statsmodels (stim-dose-response pooled fits) |
| 10.26275/5cwo-mkpz | datacite | Single-electrode bidirectional control of heart rate via vagus nerve modulation in rat model | Shane A Bender | 2026 | SPARC Portal | demo: Discover 655 (rat HR control) |
| 10.26275/dm5l-tspb | datacite | Influence of vagus nerve stimulation on cardiac activity in pigs | Oliver Armitage | 2023 | SPARC Portal | demo: Discover 349 (pig VNS grid) |
| 10.26275/nung-b9bm | datacite | Best parameters of heart rate variability for assessing autonomic responses to brief rectal distention in patients with irritable bowel syndrome | M Khawar  Ali | 2024 | SPARC Portal | demo: Discover 406 (human ECG) |
| 10.26275/qh3q-elj6 | datacite | Influence of left vagal stimulus pulse parameters on vagal and gastric activity in rat | Matthew Ward | 2020 | SPARC Portal | demo: Discover 9 (rat vagal/gastric; workflow 2) |
| 10.3389/fninf.2014.00010 | crossref | Neo: an object model for handling electrophysiology data in multiple formats | Garcia, Samuel | 2014 | Frontiers in Neuroinformatics 8 | Neo (physio-import) |
| 10.3389/fphys.2018.01390 | crossref | PhysioZoo: A Novel Open Access Platform for Heart Rate Variability Analysis of Mammalian Electrocardiographic Data | Behar, Joachim A. | 2018 | Frontiers in Physiology 9:1390 | PhysioZoo preset values (numbers only; code GPL) |
| 10.3389/fpubh.2017.00258 | crossref | An Overview of Heart Rate Variability Metrics and Norms | Shaffer, Fred | 2017 | Frontiers in Public Health 5:258 | HRV metrics and norms (ecg-hrv README) |
| 10.3758/s13428-020-01516-y | crossref | NeuroKit2: A Python toolbox for neurophysiological signal processing | Makowski, Dominique | 2021 | Behavior Research Methods 53:1689-1696 | NeuroKit2 (ecg-hrv, bp-resp) |
| 10.7554/eLife.78362 | crossref | The Neurodata Without Borders ecosystem for neurophysiological data science | Rübel, Oliver | 2022 | eLife 11:e78362 | NWB (physio-import and every reader) |
