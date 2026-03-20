import type { SituationFrame } from "./situationFrame.types";

function compareStrings(a: string, b: string): number {
  return a.localeCompare(b);
}

export function compareSituationFrames(
  a: SituationFrame,
  b: SituationFrame
): number {
  const orderDelta = (a.orderHint ?? Number.MAX_SAFE_INTEGER) - (b.orderHint ?? Number.MAX_SAFE_INTEGER);
  if (orderDelta !== 0) {
    return orderDelta;
  }

  const titleDelta = compareStrings(a.title, b.title);
  if (titleDelta !== 0) {
    return titleDelta;
  }

  return compareStrings(a.summary, b.summary);
}

export function sortSituationFrames(
  frames: SituationFrame[]
): SituationFrame[] {
  return [...frames].sort(compareSituationFrames);
}
