# AF-002 — React Shell and Legacy Dashboard Are Distinct Applications

Status: Accepted

Confidence: High

## Question

Are the React shell and the legacy dashboard different implementations of the same application, or separate applications that currently coexist?

## Evidence

### Repository Evidence

Repository inspection identified:

- client/ as a Vite/React application
- public/index.html as a standalone legacy dashboard entrypoint
- Separate asset loading and composition models for each

### Reasoning

The repository contains two independently structured UI entrypoints with different composition strategies and technology stacks. Neither serves as a thin wrapper around the other, indicating coexistence rather than a single application expressed in two forms.

## Finding

The React shell and the legacy dashboard are distinct applications that currently coexist within the repository.

The React shell represents the newer presentation architecture, while the legacy dashboard remains a separate implementation rather than an alternate rendering of the same application.

## Implications

Migration planning should treat movement from the legacy dashboard to the React shell as application migration rather than component replacement.

Architectural decisions for one application should not automatically be assumed to apply to the other.

## Supersedes

None.
