# Focus & Break  
*A back-safe, productivity-first focus tracker*

## 1. Project Overview

**Focus & Break** is a macOS desktop productivity application designed for knowledge workers who need **deep focus** while also protecting their **physical health**, especially the **lower back**.

The app is built around a simple but critical principle:

> Sustained high performance requires **intentional focus cycles** and **regular posture-aware recovery**, not random breaks or rigid pomodoro timers.

This project is specifically motivated by:
- Long hours of deep cognitive work (software engineering, design, analysis)
- A need to avoid prolonged static sitting or standing
- Maintaining focus **without frequent disruptive interruptions**
- Prior history of lower-back injury (e.g., disc hernia surgery)

The app acts as a **gentle guide**, not a nagging timer.

---

## 2. Core Goals

### Health
- Prevent prolonged static posture (sitting or standing)
- Encourage spine-safe posture rotation
- Reduce lower-back strain through predictable movement
- Avoid aggressive or distracting reminders

### Productivity
- Preserve deep focus and flow states
- Minimize context switching
- Align posture with task type
- Track real focus time, not just “time at desk”

---

## 3. Design Philosophy

### Not a Pomodoro App
- No forced 25-minute cycles
- No loud alarms
- No constant notifications

### Instead:
- **Long focus blocks** (45–60 minutes)
- **Short, intentional reset periods** (2–5 minutes)
- **Gentle reminders only at natural stopping points**
- Full user control over timing and behavior

---

## 4. Core Concepts

### Focus Block
A continuous period of focused work (e.g. 50 minutes).

Characteristics:
- One posture (sit, stand, perch, walk)
- One primary task or task type
- No interruptions from the app during the block

### Reset / Recovery Period
A short break meant for:
- Posture change
- Light movement
- Eye and mental reset

Typical duration:
- 2–5 minutes

---

## 5. Posture-Aware Workflow

### Focus Session Postures
Each focus block uses a **working posture**:

- Sitting (with lumbar support)
- Standing
- Perching (high stool / active sitting)

The app does **not** enforce posture — it **guides rotation** to prevent overload.

### Break Session Types
Breaks use **activities**, not postures. Activities can rotate or be switched mid-break.
Primary activity is auto-selected; secondary suggestions can be shown for variety.

#### Walking
Purpose:
- Decompress lumbar spine
- Improve blood flow
- Clear mental fatigue

Rules:
- Slow pace
- No phone (optional setting)
- Indoors or outdoors

#### Stretching (Gentle Only)
Purpose:
- Release hip flexors, thoracic spine
- Reduce stiffness from sitting/standing

Rules:
- No forward bends
- No aggressive holds
- Short duration (1–3 min)

Examples:
- Hip flexor stretch
- Standing back extension
- Gentle torso rotation

#### Mobility / Reset
Movement without stretching.

Purpose:
- Re-introduce motion
- Reset posture
- Prevent stiffness

Examples:
- Shoulder rolls
- Pelvic tilts
- Neck circles (gentle)

#### Passive Recovery
Purpose:
- Nervous system reset
- Back decompression

Examples:
- Lying on the floor (knees bent)
- Leaning against a wall
- Sitting with full lumbar support

Important: This is not sitting at your desk.

#### Eyes / Mental Reset
Purpose:
- Reduce eye strain
- Restore attentional capacity

Examples:
- Look outside (distance focus)
- Eyes closed breathing
- 4-7-8 breathing (optional)

### Default Break Durations
- Walking: 3–5 min
- Stretching: 2–3 min
- Mobility: 1–2 min
- Passive recovery: 2–5 min
- Eyes / mental reset: 1–2 min

---

## 6. Key Features (MVP)

### Focus Timer
- Customizable focus duration (default: 50 min)
- Customizable rest duration (default: 5 min)
- Start / pause / reset

### Gentle Alerts
- macOS banner notification at block completion
- Optional sound with banner
- No alerts mid-focus
- Notification permission optional

### Session Logging
- Track:
  - Focus duration
  - Rest duration
  - Focus posture
  - Break activity
  - Timestamp
- Daily aggregation (optional, later)

### Analytics (Later)
- Deferred until after MVP

---

## 7. Non-Goals (Explicitly Out of Scope)

- Gamification (points, streak pressure)
- Social features
- Task management replacement
- Competitive productivity metrics
- Medical advice or diagnosis

---

## 8. UX Principles

- Zero friction to start a focus session
- Minimal UI during focus
- Clear visual countdown (optional)
- Calm, neutral visual language
- Dark-mode friendly

### macOS UI (Menu Bar-First)
- Menu bar title always shows a live timer (e.g., ⏱ 24:12)
- Compact popover as the primary surface (~300×220)
- Large timer digits with clear Focus/Break mode label
- Contextual icon row (focus postures vs break activities)
- Primary controls: Start/Pause and Reset
- Footer shows next transition time and daily block count
- Break-end alert shows the suggested next focus posture

### Visual Style (Dark-First)
- Background: #0E1012
- Surface: #161A1F
- Surface (elevated): #1C2128
- Text (primary): #E7EAF0
- Text (secondary): #9AA3B2
- Accent (focus): #4F6BFF
- Accent (break): #3CCF91
- Accent (warn): #E8B85C
- Border: #232833

### Focus Posture Icons (SF Symbols)
- Sit: chair.lounge.fill
- Stand: figure.stand
- Perch: stool

### Break Activity Icons (SF Symbols, suggested)
- Walk: figure.walk
- Stretching: figure.cooldown
- Mobility: figure.core.training
- Passive recovery: figure.seated.side
- Eyes / mental reset: eye

---

## 9. Technical Direction (High-Level)

> **Implementation details intentionally minimal here**  
> (to be handled by Codex / implementation phase)

Expected stack (macOS MVP):
- Native macOS app built with SwiftUI
- Core Data for local persistence
- Notification Center banners for focus/rest transitions
- Exportable data (JSON / CSV)
- No backend required for MVP

---

## 10. Future Extensions (Optional)

- Weekly / monthly health-focused summaries
- Smart posture rotation suggestions
- Integration with standing desks (manual or API-based)
- Minimal wearable integration (step count during walking blocks)
- Voice-friendly mode for hands-free transitions

---

## 11. Success Criteria

The project is successful if:
- Focus time increases **without increasing discomfort**
- Posture changes happen naturally, not forcefully
- The app fades into the background during deep work
- The user finishes the day mentally sharp and physically comfortable

---

## 12. Guiding Principle

> The best productivity tool is one you *forget exists* —  
> until it quietly helps you avoid long-term harm.