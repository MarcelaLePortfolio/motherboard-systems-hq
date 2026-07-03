
# Project Root and Git Repository Reconciliation

Status: RECONCILED

## Purpose

Reconcile the foundational onboarding distinction between a Project Root and a Git Repository within Motherboard.

This reconciliation prevents future architecture from conflating the local project folder with the version-control repository.

---

## Reconciled Finding

Motherboard requires two distinct foundational resources during project onboarding:

1. Project Root

2. Git Repository

These resources are related but not interchangeable.

---

## Project Root

The Project Root is the local folder selected or created by the user.

It answers:

Where does this project live on this computer?

The Project Root is a filesystem location.

The user explicitly chooses or creates the Project Root.

Motherboard must not infer Project Roots by scanning the user's filesystem.

---

## Git Repository

The Git Repository is the version-control resource associated with the project.

It answers:

How is this project versioned?

The user may connect an existing Git repository or create a new one during onboarding.

The Git Repository may be hosted by GitHub, GitLab, Bitbucket, Azure DevOps, a self-hosted Git provider, or another supported provider.

The Git Repository is not the same thing as the Project Root.

---

## Onboarding Model

Motherboard onboarding establishes both resources:

1. Pick or create a Project Root.

2. Connect or create a Git Repository.

After both foundational resources are established, Motherboard may register the project for organizational governance.

---

## Registration Rule

Registration occurs after Motherboard has a user-selected Project Root and an associated Git Repository.

Registration admits the project into organizational governance.

Registration does not grant Motherboard implicit visibility over unrelated folders, repositories, files, or system locations.

---

## Privacy Boundary

Motherboard possesses no implicit authority over the user's computer.

Organizational visibility begins only through explicit user selection, connection, or registration.

Motherboard must not autonomously scan the user's filesystem for projects or repositories.

---

## Architectural Boundary

The Project Root belongs to filesystem placement.

The Git Repository belongs to version-control continuity.

The Repository Registry belongs to organizational governance.

These layers must remain distinct.

---

## Relationship To Active Context

Only registered projects may become Active Context.

Changing Active Context selects a registered project.

Cross-repository execution remains separately governed.

---

## Relationship To Existing Artifacts

- CROSS_REPOSITORY_CORRIDOR_STATUS.md

- CROSS_REPO_CAPABILITY_GOVERNANCE_ROADMAP.md

