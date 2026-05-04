// Phase 663 — Guidance History API (READ-ONLY, NON-INTRUSIVE)

import { getGuidanceHistory } from "../guidance/historyBuffer.mjs";

export default async function handler(req, res) {
  try {
    const history = getGuidanceHistory();

    return res.status(200).json({
      ok: true,
      history_available: history.length > 0,
      history,
    });
  } catch (err) {
    return res.status(500).json({
      ok: false,
      error: "failed_to_fetch_guidance_history",
    });
  }
}
