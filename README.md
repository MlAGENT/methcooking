# 🔬 MethLab - Advanced FiveM Drug Cooking Script (WIP)

> ⚠️ **This project is currently under development and not yet fully functional.**
> It is publicly shared for collaboration, debugging, and improvement purposes.

A complete and immersive **methamphetamine cooking system**, inspired by *Breaking Bad*, built for **QBX Core** servers. This script introduces a deep, high-risk illegal activity with real-time mechanics, visuals, and consequences.

---

## 🎮 Features

### ✅ Implemented

- **🔍 ox_target Integration**  
  Interact with specific vehicles (RV model) to begin meth cooking.
  
- **🧪 Cooking Mini-game**  
  Maintain stable **temperature** and **pressure** during the cooking session. Values fluctuate randomly—fail to control them and risk an explosion.

- **📉 Quality Score System**  
  Your performance during cooking affects the final product's quality (based on stability).

- **🔥 Explosion System**  
  If critical thresholds are exceeded, the lab explodes:
  - Player gets injured
  - Visual particle FX
  - Alerts sent to police (if enabled)

- **📦 Inventory Requirement Check**  
  Requires specific ingredients (e.g., lithium, acetone, pseudoephedrine) to start cooking.

- **⛔ Cooldown System**  
  Players must wait before starting a new batch, preventing spam/exploit.

- **🔒 Vehicle Locking During Cooking**  
  The RV becomes locked while cooking is in progress.

- **🎬 Basic Animations & HUD Feedback**  
  Animations play during the process, and real-time feedback is shown via `ox_lib`'s `TextUI`.

---

### 🧭 Planned / In Progress

- [ ] **Advanced NUI Cooking Interface**  
  Replace `TextUI` with a full-screen interface showing gauges, timers, and interactivity.

- [ ] **Police Blip Alerts**  
  Send GPS location blips to police on explosions or suspicious activities.

- [ ] **Meth Selling System**  
  Sell cooked meth to NPCs with risk/reward based on quality.

- [ ] **Meth Bagging & Packaging System**  
  Add a step to convert the final product into bagged meth before selling.

- [ ] **Dynamic Police Risk**  
  Cooking near city areas increases the chance of police getting notified.

- [ ] **Reputation & Stats Tracking**  
  Track player performance, success/failure history, and rank meth cooks.

---

## ⚙️ Requirements

| Dependency    | Version/Link                                    |
|---------------|--------------------------------------------------|
| [QBX Core]    | https://github.com/qbx-core-framework/qbx-core  |
| [ox_lib]      | https://overextended.dev/                       |
| [ox_target]   | https://overextended.dev/ox_target/             |

---

## 🗂️ Project Structure

