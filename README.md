# Sizing of a power conversion system for xEV (Electrical Technologies for eMobility)

A comprehensive simulation, control design, and validation project for a high-performance electric vehicle powertrain (benchmarked against the Tesla Model 3 drive unit), developed for the **Electrical Technologies for eMobility** course at Politecnico di Torino.


## Table of contents
1. [Overview](#overview)
2. [Requirements](#requirements)
3. [Architecture](#architecture)
   - [Bidirectional DC/DC Boost Converter](#1-bidirectional-dcdc-boost-converter-dcdc_converter)
   - [IPM Synchronous Machine & Inverter Drive](#2-ipm-synchronous-machine--inverter-drive-ipm_inverter)
   - [Integrated Powertrain (Full System)](#3-integrated-powertrain-full-system-full_system)
4. [Specifications](#specifications)
5. [Project structure](#project-structure)
6. [Usage](#usage)
   - [Standalone DC/DC Boost Converter](#standalone-dcdc-boost-converter-dcdc_converter)
   - [Standalone IPM Motor Drive & Inverter](#standalone-ipm-motor-drive--inverter-ipm_inverter)
   - [Full Integrated Powertrain](#full-integrated-powertrain-full_system)


## Overview

This project models and simulates the end-to-end electric propulsion system of an EV:
* **Energy Source:** Low-voltage lithium-ion traction battery pack ($V_{\text{bat}} = 200\text{ V} \div 350\text{ V}$).
* **DC/DC Intermediate Stage:** Bidirectional, non-isolated boost converter boosting battery voltage to a regulated high-voltage DC link ($V_{\text{dc}} = 400\text{ V} \div 650\text{ V}$).
* **Traction Drive:** Two-level 3-phase Voltage Source Inverter (VSI) driving an Internal Permanent Magnet Synchronous Machine (IPMSM) using Field-Oriented Control (FOC), MTPA, and Field Weakening strategies.


## Requirements

* **MATLAB & Simulink:** R2023b or later recommended.
* **Required Toolboxes:**
  * Control System Toolbox
  * DSP System Toolbox *(optional)*
  * Simscape / Simscape Electrical *(if physical blocks are inspected)*
* Make sure your MATLAB Current Folder is set to the root directory of this repository before executing the steps below.


## Architecture

### 1. Bidirectional DC/DC Boost Converter (`/DCDC_CONVERTER`)
* **Dual-Loop Cascaded PI Control:**
  * **Inner Current Loop ($i_{\text{in}}$):** High-bandwidth PI controller ($B_i \approx 500\text{ Hz}$) regulating the boost inductor current with sub-cycle dynamic tracking.
  * **Outer Voltage Loop ($v_{\text{dc}}$):** Slower PI controller ($B_v \approx 10\text{ Hz}$) stabilizing the high-voltage bus against aggressive load transients.
* **Feedforward & Decoupling Compensation:**
  * Direct load current compensation ($i_{\text{load}}$ / $i_{\text{dc}}$) to minimize voltage drop under instantaneous load steps.
  * Battery voltage compensation for duty cycle linearization ($d = 1 - V_{\text{bat}} / V_{\text{dc}}$).
* **Protection & Anti-Windup:**
  * Dynamic clamp anti-windup implemented across both current and voltage integrators.
  * Controlled reference ramp generation to suppress inrush current during the initial DC-link pre-charging phase.

### 2. IPM Synchronous Machine & Inverter Drive (`/IPM_INVERTER`)
* **Vector Field-Oriented Control (FOC):**
  * Synchronous $d$-$q$ reference frame current regulation with decoupling of motional cross-coupling back-EMF terms ($\omega_e \lambda_d$, $\omega_e \lambda_q$).
* **Nonlinear Cross-Saturation Magnetic Model:**
  * Implements experimental/FEA flux lookup tables $\lambda_d(i_d, i_q)$ and $\lambda_q(i_d, i_q)$ capturing magnetic saturation and cross-coupling effects.
* **Optimal Trajectory Tracking:**
  * **MTPA (Maximum Torque Per Ampere):** Maximizes reluctance and magnetic torque below base speed, minimizing stator ohmic losses.
  * **Field Weakening (FW) & MTPV (Maximum Torque Per Voltage):** Automatically advances the current angle along the voltage limit ellipse ($V_{\text{max}} = V_{\text{dc}}/\sqrt{3}$) into deep flux weakening, extending torque capability up to 18,000 rpm.
* **Space Vector PWM Modulation (SVPWM):** High DC-bus voltage utilization with low harmonic distortion.

### 3. Integrated Powertrain (Full System) (`/FULL_SYSTEM`)
* **Coupled Electro-Mechanical Power Flow:**
  * Closed-loop interaction between the inverter DC current draw and DC/DC converter bus stabilization.
* **Bidirectional Energy & Regenerative Braking:**
  * Seamless transitions between positive traction mode (boost) and regenerative deceleration (buck mode, returning braking energy to the battery pack).
* **Multi-Regime Transient Testing:**
  * **Dynamic Torque Steps:** Validates DC-link stability during full torque reversals.
  * **Full Speed Range Run-Up:** Continuous transition from constant torque (MTPA) to constant power and flux-weakening regimes.


## Specifications

| Parameter | Symbol | Nominal Value | Unit |
| :--- | :---: | :---: | :---: |
| Battery Voltage Range | $V_{\text{bat}}$ | $200 - 350$ | $\text{V}$ |
| Regulated DC-Link Voltage | $V_{\text{dc}}$ | $400$ | $\text{V}$ |
| Maximum Inductor Boost Current | $I_{\text{in,max}}$ | $425$ | $\text{A}$ |
| DC-Link Filter Capacitance | $C_o$ | $4.4$ | $\text{mF}$ |
| Peak Inverter Stator Current | $I_{\text{max}}$ | $380$ | $\text{A}_{\text{pk}}$ |
| Inverter Max Voltage Limit | $V_{\text{max}}$ | $V_{\text{dc}} / \sqrt{3}$ | $\text{V}$ |
| Pole Pairs | $p$ | $3$ | - |
| Base Speed | $n_{\text{base}}$ | $\sim 4500$ | $\text{rpm}$ |
| Maximum Operating Speed | $n_{\text{max}}$ | $18000$ | $\text{rpm}$ |


## Project structure

```plaintext
.
├── DCDC_CONVERTER/
│   ├── DCDC_ClosedLoop.slx        # Closed-loop DC/DC converter Simulink model
│   ├── init_DCDC_ClosedLoop.m     # Parameters initialization & PI tuning (kpv, kiv, kpi, kii)
│   ├── PlotResults.m              # Post-processing script for DC/DC waveforms
│   └── SetPlot.m                  # IEEE-compliant plot formatting utility
│
├── IPM_INVERTER/
│   ├── IPM_Drive.slx              # FOC-controlled IPM drive and inverter Simulink model
│   ├── init_IPM_machine.m         # Flux maps loader, MTPA/FW/MTPV trajectory generation
│   ├── PlotResults.m              # Script for trajectory curves and dq maps
│   └── SetPlot.m
│
├── FULL_SYSTEM/
│   ├── full_system.slx            # Fully integrated powertrain: Battery + DC/DC + Inverter + IPM
│   ├── init_full_system.m         # Powertrain initialization script
│   └── PlotResults.m              # Full system performance evaluation script
│
├── Project.pdf                    # Course project guidelines and specifications
├── Report.pdf                     # Technical project report with analytical results
└── README.md                      # Project documentation
```

## Usage

### Standalone DC/DC Boost Converter (`/DCDC_CONVERTER`)

This simulation verifies DC-link voltage regulation ($V_{\text{dc}} = 400\text{ V}$), pre-charging inrush current limitation, and load transient response.

1. In the MATLAB Command Window, navigate to the converter folder:
   ```matlab
   cd('DCDC_CONVERTER')
   ```
2. Execute the initialization script to load base parameters (`Data11.mat`) and compute the PI controller gains ($k_{pv}, k_{iv}, k_{pi}, k_{ii}$):
   ```matlab
   init_DCDC_ClosedLoop
   ```
3. Open the Simulink model:
   ```matlab
   open_system('DCDC_ClosedLoop1.slx') % or DCDC_ClosedLoop.slx
   ```
4. Run the simulation:
   ```matlab
   sim('DCDC_ClosedLoop1.slx')
   ```
5. *(Optional)* If the model does not trigger plotting automatically upon completion, run:
   ```matlab
   PlotResults
   ```
   This generates the waveforms for DC-link voltage ($v_{\text{dc}}$), battery current ($i_{\text{in}}$), and load current steps.

6. Return to the root directory when finished:
   ```matlab
   cd('..')
   ```


### Standalone IPM Motor Drive & Inverter (`/IPM_INVERTER`)

This simulation validates Field-Oriented Control (FOC), dynamic current tracking ($i_d, i_q$), MTPA trajectory tracking, and field weakening at high speeds.

1. Navigate to the IPM drive directory:
   ```matlab
   cd('IPM_INVERTER')
   ```
2. Execute the initialization script to load motor parameters, magnetic flux maps ($\lambda_d(i_d, i_q), \lambda_q(i_d, i_q)$), and pre-calculate optimal trajectory curves:
   ```matlab
   init_IPM_machine
   ```
3. Open the Simulink model:
   ```matlab
   open_system('IPM_machine.slx')
   ```
4. **Select Test Case:** Configure the desired profile in the input/reference blocks (refer to comments in `init_IPM_machine.m`):
   * **Test 1 – Torque Step Response:** Fixed rotor speed with rapid torque steps/reversals to evaluate decoupling and inner current loop dynamics.
   * **Test 2 – Speed Ramp & Field Weakening:** Wide speed acceleration ramp crossing base speed ($\sim 4500\text{ rpm}$) into deep flux weakening up to $18{,}000\text{ rpm}$.
5. Run the simulation:
   ```matlab
   sim('IPM_machine.slx')
   ```
6. Generate trajectory and dynamic response plots:
   ```matlab
   PlotResults
   ```

7. Return to the root directory when finished:
   ```matlab
   cd('..')
   ```


### Full Integrated Powertrain (`/FULL_SYSTEM`)

This simulation evaluates the complete coupled system: Battery $\leftrightarrow$ DC/DC Boost Converter $\leftrightarrow$ Inverter $\leftrightarrow$ IPM Motor under driving and regenerative braking regimes.

1. Navigate to the full system directory:
   ```matlab
   cd('FULL_SYSTEM')
   ```
2. Run the full system initialization script (loads parameters for both the power electronics stage and the electric drive):
   ```matlab
   init_full_system
   ```
3. Open the integrated Simulink model:
   ```matlab
   open_system('full_system.slx')
   ```
4. Start the simulation:
   ```matlab
   sim('full_system.slx')
   ```
5. Run post-processing to inspect DC-link stability, battery power flow, motor torque, and energy recovery:
   ```matlab
   PlotResults
   ```

6. Return to the root directory:
   ```matlab
   cd('..')
   ```
