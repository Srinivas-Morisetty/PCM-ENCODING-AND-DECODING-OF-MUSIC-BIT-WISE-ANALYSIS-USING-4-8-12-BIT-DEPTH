#  PCM Encoding and Decoding of Music

##  Overview

This project demonstrates the implementation of **Pulse Code Modulation (PCM)** for digital communication of audio signals.
The system converts an analog music signal into a digital bitstream using PCM encoding and reconstructs it back into an audio signal using PCM decoding.

The objective is to understand how real-world digital audio transmission works in:

* Mobile communication
* Voice transmission
* Audio storage systems
* Streaming platforms

---

##  Objectives

* Convert analog audio signal → digital signal
* Perform sampling, quantization, and encoding
* Reconstruct audio using decoding and filtering
* Analyze signal distortion and noise
* Compare original and reconstructed audio

---

##  Concepts Used

* Analog to Digital Conversion (ADC)
* Sampling Theorem (Nyquist Rate)
* Quantization
* Binary Encoding
* Digital to Analog Conversion (DAC)
* Low Pass Filtering
* Signal Reconstruction

---

##  System Flow

```
Audio Input → Sampling → Quantization → Encoding → Bitstream Transmission
           → Decoding → Reconstruction Filter → Output Audio
```

---

##  Tools & Technologies

* MATLAB
* Signal Processing Toolbox
* Audio Processing Functions
* Digital Communication Concepts

---

##  How to Run

1. Open MATLAB
2. Place all project files in the same folder
3. Open the script:

```
PCM_Analysis.m
```

4. Click **Run**
5. The program will:

   * Read audio file
   * Encode using PCM
   * Decode signal
   * Play reconstructed audio
   * Display graphs

---

##  Output Graphs

The program generates:

* Original Signal
* Sampled Signal
* Quantized Signal
* Encoded Bitstream
* Reconstructed Signal

---

##  Observations

* Increasing quantization levels improves audio quality
* Lower sampling rate causes distortion (aliasing)
* Noise introduced due to quantization error

---

##  Applications

* Telecommunication systems
* VoIP calls
* Audio recording
* Bluetooth audio transmission
* Digital music players
* Satellite communication
