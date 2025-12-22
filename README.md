📈 TradeDesk – Personal Trade Manager App

TradeDesk is a personal trade management application built with Flutter and Firebase Firestore, designed to track positional/swing trades with a clean UI and rule-based calculations.

This project focuses on clarity, scalability, and correctness, rather than shortcuts.

🎯 Project Goal

To build a personal trading journal & trade manager that:

Tracks active and closed trades

Shows rule-based metrics (risk, 1R, P&L)

Uses a scalable architecture

Can evolve without painful refactoring

✅ What Has Been Achieved (v1)
🧱 Architecture & Structure

Feature-based folder structure

Clear separation of concerns:

Firestore (data source)

DTO (mapping + calculations)

UI Model

UI Widgets

Scalable, clean architecture suitable for future growth

🔥 Firebase Integration

Firebase initialized correctly at app startup

Firestore used as backend (holdings collection)

Real-time data via StreamBuilder

Open rules for personal usage (v1)

🔁 DTO-Based Data Mapping

Introduced Data Transfer Object (DTO) layer

DTO responsibilities:

Map Firestore fields to UI model

Perform deterministic calculations

Isolate backend changes from UI

Calculated fields include:

Invested amount

Partial quantity (25%)

P&L (rule-based)

P&L %

1R target

Trade age (days)

📊 Trade Screen (Core Feature)

Clean and compact trade card UI

Displays:

Name

Quantity & partial quantity

Buy price, SL, initial SL

Invested amount

P&L (₹ and %)

1R target

Trade age

Partial profit status

Handles:

Loading state

Empty state

Live updates from Firestore

🎨 UI & Theming

Centralized app theme

Reusable widgets

Compact card design to support 10–15 trades per screen

UI logic kept free from business logic

🧠 Key Design Decisions

UI-first development to validate UX before backend

No dummy logic in production UI

No calculations inside widgets

Firestore stores facts, not derived values

DTO handles mapping and calculations

This makes field changes, renaming, or rule updates safe and localized.

🚀 Current Status

✅ Read-only version complete

✅ Live data from Firestore

✅ Stable v1 foundation

🔜 Planned Next Steps

Create trade / holding screen (write to Firestore)

Dashboard summary (PnL, risk, R-multiple)

Filters (Active / Closed / Free)

Optional authentication (later)

🛠 Tech Stack

Flutter

Firebase Firestore

Dart

Material UI

📌 Note

This app is built for personal use, with a focus on discipline, clarity, and long-term scalability, not rapid prototyping shortcuts.