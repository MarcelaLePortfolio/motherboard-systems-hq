
# PHASE 719 — PRE PREVIEW CONSTRAINT PATCH BACKUP

## PURPOSE

Seal a clean checkpoint before starting a new UI-adjustment hypothesis for artifact preview sizing/containment.

## CURRENT STATE

- runtime healthy

- browser console cleaned

- artifact preview opens

- iframe/srcdoc payload exists

- artifact pipeline preserved

- stale endpoint callers disabled

- invalid legacy console scripts disabled

## ROOT CAUSE METRICS

Measured browser preview dimensions:

- dialog width: 760

- dialog height: 685

- dialog scrollHeight: 756

- body width: 726

- body height: 598

- body scrollHeight: 596

- iframe width: 688

- iframe height: 560

- srcdoc length: 2910

## NEXT HYPOTHESIS

Preview issue appears caused by modal/iframe sizing constraints, not missing artifact HTML.

## BACKUP REASON

This checkpoint protects the current clean diagnostic baseline before applying any new frontend UI-adjustment patch.

