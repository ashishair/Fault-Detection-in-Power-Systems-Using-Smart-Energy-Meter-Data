# Fault Detection in Power Systems Using Smart Energy Meter Data

A comprehensive project implementing **real-time harmonic-based fault detection** in 3-phase power systems using rolling-window FFT analysis on smart meter readings. This project leverages Digital Signal Processing (DSP) techniques to identify and classify electrical faults through harmonic signature analysis.

---

## 📋 Project Overview

### Problem Statement
Electrical power systems experience transient faults (phase-to-ground, phase-to-phase, line-to-line) that require real-time detection for:
- Grid stability and protection
- Asset damage prevention
- Faster fault localization and restoration
- Reduced power outage duration

### Solution Approach
This project implements a **DSP-based fault detection algorithm** that:
1. Acquires 3-phase voltage/current data from smart energy meters (2 kHz sampling at 0.5 ms intervals)
2. Performs rolling-window FFT analysis with **100 ms windows sliding at 1 ms intervals**
3. Extracts harmonic magnitudes (1st–9th order, 50 Hz–450 Hz)
4. Identifies fault signatures through harmonic evolution patterns
5. Classifies fault types based on harmonic distortion profiles

---

## 🎯 Key Features

✅ **Rolling Window FFT Analysis**
- 100 ms window with 1 ms step = 2 data points sliding increment
- Extracts real-time harmonic content evolution
- Suitable for transient fault detection during µs-ms timescales

✅ **Harmonic-Based Fault Signatures**
- Analyzes 1st–9th harmonics (50 Hz, 100 Hz, 150 Hz, ... 450 Hz)
- Detects distortions like 2sin(ωt), 2sin(2ωt), 2sin(3ωt), etc.
- Correlates harmonic patterns to fault types

✅ **Multi-Phase Analysis**
- Simultaneous processing of Phase A, B, C data
- Phase imbalance detection
- Comparative harmonic analysis across phases

✅ **Real-Time Visualization**
- 1st harmonic (fundamental 50 Hz) evolution across all phases
- Individual harmonic plots (2nd–9th) with 3-phase subplots
- Combined 3×3 grid visualization for all harmonics per phase
- Peak detection for fault event identification

✅ **Data Export & Statistics**
- CSV export of harmonic magnitudes over time
- Mean, Max, Min statistics per harmonic
- Suitable for machine learning model training

---

## 📊 Technical Details

### Data Acquisition
- **Source**: Smart Energy Meter (laterite fault dataset)
- **Sampling Rate**: 2000 Hz (Ts = 0.5 ms)
- **Duration**: ~0.5 seconds (1001 data points)
- **Phases**: 3-phase AC system (Phase A, B, C)
- **Format**: XLSX with transposed structure (rows = phase data)

### Processing Pipeline

```
Smart Meter Data → Data Loading → Rolling Window FFT Analysis → Harmonic Extraction
                                          ↓
                           Fault Classification Engine
                                          ↓
                        Visualization & Statistics Generation
```

### Algorithm Parameters

| Parameter | Value | Description |
|-----------|-------|-------------|
| Window Duration | 100 ms | Time window for each FFT analysis |
| Step Size | 1 ms | Sliding window increment |
| Samples/Window | 200 | FFT samples (100 ms ÷ 0.5 ms/sample) |
| Fundamental Freq | 50 Hz | Power grid frequency (India, EU, etc.) |
| Harmonics Analyzed | 1–9 | Up to 450 Hz (9 × 50 Hz) |
| Total Windows | ~401 | (1001 samples − 200) ÷ 2 + 1 |

---

## 📁 Project Structure

```
smart-meter-fault-detection/
│
├── README.md                          # This file
├── LICENSE                            # MIT License
├── .gitignore                         # Git ignore file
│
├── data/
│   ├── Fault-data-laterite.xlsx       # Sample fault dataset
│   ├── README.md                      # Data documentation
│   └── sample_data_structure.txt      # Expected data format
│
├── src/
│   ├── main_rolling_window_fft.m      # Main FFT analysis script
│   ├── load_smart_meter_data.m        # Data loading function
│   ├── compute_rolling_fft.m          # Rolling window FFT computation
│   ├── extract_harmonics.m            # Harmonic extraction function
│   └── plot_results.m                 # Visualization functions
│
├── outputs/
│   ├── rolling_window_fft_results.csv # CSV export of harmonics
│   ├── plots/                         # Generated MATLAB figures
│   │   ├── 1st_harmonic_all_phases.fig
│   │   ├── 2nd_harmonic_all_phases.fig
│   │   ├── harmonics_phase_A.fig
│   │   ├── harmonics_phase_B.fig
│   │   └── harmonics_phase_C.fig
│   └── README.md                      # Results documentation
│
├── docs/
│   ├── project_overview.md            # Detailed project description
│   ├── methodology.md                 # Technical approach & algorithm
│   ├── results_analysis.md            # Results interpretation guide
│   └── future_enhancements.md         # Potential improvements
│
└── tests/
    ├── test_data_loading.m            # Unit tests
    ├── test_fft_computation.m         # Verification scripts
    └── sample_test_cases.m            # Example fault scenarios
```

---

## 🚀 Getting Started

### Prerequisites
- **MATLAB** R2019a or later
- **Signal Processing Toolbox** (for FFT functions)
- **Data file**: `Fault-data-laterite.xlsx` in `/data` folder

### Installation

```bash
# Clone the repository
git clone https://github.com/YourUsername/smart-meter-fault-detection.git
cd smart-meter-fault-detection

# Ensure data file is in the correct location
cp your_fault_data.xlsx data/Fault-data-laterite.xlsx
```

### Running the Analysis

```matlab
% Open MATLAB and navigate to project directory
cd smart-meter-fault-detection

% Run the main analysis script
main_rolling_window_fft

% Output:
% - 13 MATLAB figures generated
% - rolling_window_fft_results.csv created
% - Console statistics displayed
```

---

## 📊 Output Examples

### Figure 1: 1st Harmonic (50 Hz) - All Phases
Shows the fundamental frequency magnitude evolution across all three phases, with phase imbalances indicating fault severity.

### Figures 2-10: 2nd–9th Harmonics
Individual figures for each harmonic order (100 Hz to 450 Hz) with 3 subplots:
- Phase A (Red)
- Phase B (Green)
- Phase C (Blue)

### Figures 11-13: Combined 3×3 Grids
All 9 harmonics displayed for each phase, enabling pattern recognition for fault classification.

### CSV Export
`rolling_window_fft_results.csv` contains:
- **Column 1**: Time (center of each window)
- **Columns 2-10**: Phase A harmonics (H1–H9)
- **Columns 11-19**: Phase B harmonics (H1–H9)
- **Columns 20-28**: Phase C harmonics (H1–H9)

---

## 🔍 How to Interpret Results

### Normal Operation
- 1st harmonic (50 Hz) shows **stable, high magnitude**
- Higher harmonics (2–9) have **minimal magnitude** (< 0.1)
- All phases show **balanced amplitudes** (~3:3:3 ratio)

### Fault Detection
- **Sudden spike** in 1st harmonic magnitude → voltage sag/swell
- **Increased 2nd–5th harmonics** → nonlinear loads or distortion
- **Phase imbalance** → Phase-to-ground or phase-to-phase fault
- **Rapid fluctuations** → Transient fault event

### Harmonic Signatures
| Fault Type | Characteristic Harmonics |
|-----------|--------------------------|
| Phase-to-Ground | 3rd, 5th, 7th elevated; Phase A prominent |
| Phase-to-Phase | 2nd, 4th harmonics elevated; Two phases affected |
| Three-Phase | All harmonics elevated uniformly |
| Unbalanced Load | Negative sequence (different per phase) |

---

## 🛠️ Customization

### Modify Window Parameters
Edit `main_rolling_window_fft.m`:
```matlab
win_samples = 200;      % Change window size
step_samples = 2;       % Change sliding step (1 ms)
f0 = 50;               % Change fundamental frequency (60 Hz for USA)
```

### Process Different Datasets
```matlab
% Load your own data
filename = 'your_smart_meter_data.xlsx';
opts = detectImportOptions(filename);
data_table = readtable(filename, opts, 'ReadVariableNames', false);
```

### Add Custom Fault Classification
Extend `extract_harmonics.m` to include machine learning:
```matlab
% Train classifier on harmonic features
X_train = [harm_A; harm_B; harm_C];
y_train = [fault_labels];
classifier = fitcsvm(X_train, y_train);
```

---

## 📈 Performance Metrics

- **Processing Time**: ~2–5 seconds for 0.5 s of data (401 windows)
- **Temporal Resolution**: 1 ms (window step)
- **Frequency Resolution**: ~10 Hz (2000 Hz ÷ 200 samples)
- **Harmonic Accuracy**: ±5 Hz (depends on FFT bin spacing)

---

## 🔬 Research Background

This project implements concepts from:
- **DSP**: Fast Fourier Transform (FFT), windowing, frequency analysis
- **Power Systems**: Harmonic analysis, fault detection, power quality
- **IoT**: Smart meter data acquisition and processing
- **Signal Processing**: Rolling window analysis, feature extraction

### Publications & References
- IEEE Std 519-2014: Recommended Practice for Power Quality
- "Harmonic Analysis of Power Systems" - Arrillaga et al.
- "Power Systems Fault Analysis" - NPTEL Lectures

---

## 🎓 Learning Outcomes

Upon completing this project, you will understand:
✓ FFT theory and implementation in MATLAB
✓ Rolling window signal processing techniques
✓ Harmonic analysis for fault detection
✓ 3-phase power system analysis
✓ Real-time DSP algorithm design
✓ Data visualization and statistics
✓ Project documentation and GitHub workflows

---

## 💡 Potential Enhancements

### Phase 2: Machine Learning Integration
- Train Random Forest or SVM classifiers on harmonic features
- Achieve fault type classification accuracy > 95%
- Add anomaly detection using Isolation Forests

### Phase 3: IoT Integration
- Connect to actual smart energy meters via MQTT/REST API
- Real-time cloud-based processing
- Mobile app for fault notifications

### Phase 4: Hardware Implementation
- Embedded C implementation on microcontroller
- FPGA-based FFT acceleration
- On-meter edge computing

### Phase 5: Advanced Analytics
- Wavelet transform for better transient capture
- Recurrent Neural Networks (LSTM) for temporal patterns
- Deep learning for multiclass fault classification

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. **Fork** the repository
2. **Create** a feature branch: `git checkout -b feature/new-fault-classifier`
3. **Commit** changes: `git commit -m 'Add new fault classifier'`
4. **Push** to branch: `git push origin feature/new-fault-classifier`
5. **Submit** a Pull Request

### Contribution Guidelines
- Add unit tests for new functions
- Update documentation in `docs/`
- Include sample data in `tests/`
- Follow MATLAB naming conventions

---

## 📝 License

This project is licensed under the **MIT License** - see `LICENSE` file for details.

---

## 👤 Author

**Ashish Kumar Jangid**  
Electrical Engineering Student | NIT Raipur  
Email: your.email@nit-raipur.ac.in  
GitHub: [@ashishair](https://github.com/YourUsername)

### Project Links
- 📂 Repository: [smart-meter-fault-detection](https://github.com/YourUsername/smart-meter-fault-detection)
- 📖 Project Report: `docs/project_overview.md`
- 📊 Dataset: `data/Fault-data-laterite.xlsx`

---

## 🙏 Acknowledgments

- **Advisors & Mentors**: [Dr. Monalisa Biswal]
- **Institute**: NIT Raipur, Electrical Engineering Department
- **Data Source**: Laterite fault testing lab
- **Tools**: MATLAB, GitHub, Markdown

---

## 🔖 Version History

| Version | Date | Changes |
|---------|------|---------|
| v1.0 | Nov 2025 | Initial release with rolling window FFT analysis |
| v0.9 | Oct 2025 | Beta testing with laterite fault data |
| v0.8 | Oct 2025 | Core FFT implementation complete |

---

## 📌 Quick Reference

**Key Commands:**
```bash
git clone https://github.com/YourUsername/smart-meter-fault-detection.git
cd smart-meter-fault-detection
# Run main_rolling_window_fft.m in MATLAB
```

**Key Files:**
- `src/main_rolling_window_fft.m` - Main analysis
- `data/Fault-data-laterite.xlsx` - Sample data
- `outputs/rolling_window_fft_results.csv` - Results

**Helpful Links:**
- [MATLAB FFT Documentation](https://mathworks.com/help/matlab/ref/fft.html)
- [IEEE Power Quality Standards](https://standards.ieee.org/)
- [Power Systems Fault Analysis](https://nptel.ac.in/)

---

*Last Updated: November 2025*  
*Made with ❤️ for power system engineers*
