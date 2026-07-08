# SportsEco — Product Blueprint

## Overview

SportsEco is a comprehensive sports ecosystem platform connecting players, coaches, academies, parents, and venue owners. Built for the Pune pilot, designed for national scale.

This directory contains the complete product blueprint that defines the vision, architecture, user experience, and development roadmap.

## Document Index

| Document | Description |
|----------|-------------|
| [00_Vision.md](./00_Vision.md) | Mission, vision, product philosophy, competitive differentiation |
| [01_Stakeholders.md](./01_Stakeholders.md) | Detailed stakeholder profiles — goals, pain points, KPIs, permissions |
| [02_Product_Modules.md](./02_Product_Modules.md) | Complete module catalog with purpose, users, dependencies, future scope |
| [03_User_Flows.md](./03_User_Flows.md) | End-to-end workflows for all critical user journeys |
| [04_Navigation.md](./04_Navigation.md) | Navigation architecture for phone, tablet, desktop per stakeholder |
| [05_Permissions.md](./05_Permissions.md) | Full permissions matrix — every action × every role |
| [06_Feature_Roadmap.md](./06_Feature_Roadmap.md) | Phased roadmap: MVP → Launch → Future → Dream |
| [07_Design_Principles.md](./07_Design_Principles.md) | Design philosophy, rules, and what NOT to do |
| [08_Data_Architecture.md](./08_Data_Architecture.md) | Entity relationships, Firestore collections, indexes |
| [09_Backlog.md](./09_Backlog.md) | Prioritized backlog: Must Have → Should Have → Could Have → Future → Tech Debt |

## How to Use These Documents

1. **Product Managers:** Start with Vision and Stakeholders. Use the Roadmap and Backlog for sprint planning.
2. **Designers:** Start with Design Principles and Navigation. Reference Stakeholders for user context.
3. **Developers:** Start with Data Architecture and Permissions. Use User Flows for implementation guidance.
4. **QA:** Start with User Flows for test case creation. Reference Permissions for authorization testing.
5. **Investors:** Start with Vision. Browse Roadmap for growth trajectory.

## Key Decisions Documented

- Dark theme as the hero experience
- Role-based shells with consistent navigation pattern
- Gamification (XP/levels/achievements) as core engagement loop
- Firestore as primary data store with Firestore streams for real-time
- GoRouter for declarative routing with auth guards
- Riverpod for state management with service/provider separation

## Status

**Phase:** Foundation (MVP) — active development
**Target:** Pune pilot launch
**Key blocker:** Firebase project needs to be migrated from `auth-for-docs` demo project to a production project
