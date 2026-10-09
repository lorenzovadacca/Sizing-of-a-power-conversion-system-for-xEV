# Electrical Technologies for eMobility – Electric Powertrain System

A comprehensive simulation, control design, and validation project for a high-performance electric vehicle powertrain (benchmarked against the Tesla Model 3 drive unit), developed for the **Electrical Technologies for eMobility** course at Politecnico di Torino.

---

## Table of contents
1. [Project Overview](#project-overview)
2. [Powertrain Specifications](#powertrain-specifications)
3. [Key Functionalities & Control Architecture](#key-functionalities--control-architecture)
   - [Bidirectional DC/DC Boost Converter](#1-bidirectional-dcdc-boost-converter-dcdc_converter)
   - [IPM Synchronous Machine & Inverter Drive](#2-ipm-synchronous-machine--inverter-drive-ipm_inverter)
   - [Integrated Powertrain (Full System)](#3-integrated-powertrain-full-system-full_system)
4. [Repository Structure](#repository-structure)
5. [Getting Started & Simulation Workflow](#getting-started--simulation-workflow)

---

## Project overview

This project models and simulates the end-to-end electric propulsion system of an EV:
* **Energy Source:** Low-voltage lithium-ion traction battery pack ($V_{\text{bat}} = 200\text{ V} \div 350\text{ V}$).
* **DC/DC Intermediate Stage:** Bidirectional, non-isolated boost converter boosting battery voltage to a regulated high-voltage DC link ($V_{\text{dc}} = 400\text{ V} \div 650\text{ V}$).
* **Traction Drive:** Two-level 3-phase Voltage Source Inverter (VSI) driving an Internal Permanent Magnet Synchronous Machine (IPMSM) using Field-Oriented Control (FOC), MTPA, and Field Weakening strategies.

---

## Powertrain specifications

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

---

## Key functionalities & Control architecture

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

---

## Repository structure

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