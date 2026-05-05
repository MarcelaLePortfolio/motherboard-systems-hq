#!/usr/bin/env bash
set -euo pipefail

python3 - << 'PY'
from pathlib import Path

path = Path("app/components/GuidancePanel.tsx")
s = path.read_text()

s = s.replace(
"  const [retryStatus, setRetryStatus] = useState<string | null>(null);\n",
"  const [retryStatus, setRetryStatus] = useState<string | null>(null);\n  const [coherenceData, setCoherenceData] = useState<any>(null);\n"
)

s = s.replace(
"  const fetchGuidance = async () => {\n    try {\n      const res = await fetch('/api/guidance');\n      const json = await res.json();\n      setData(json);\n    } catch {\n      console.error('Guidance fetch failed');\n    } finally {\n      setLoading(false);\n    }\n  };\n",
"  const fetchGuidance = async () => {\n    try {\n      const res = await fetch('/api/guidance');\n      const json = await res.json();\n      setData(json);\n    } catch {\n      console.error('Guidance fetch failed');\n    } finally {\n      setLoading(false);\n    }\n  };\n\n  const fetchCoherencePreview = async () => {\n    try {\n      const res = await fetch('/api/guidance/coherence-shadow');\n      if (!res.ok) return;\n      const json = await res.json();\n      setCoherenceData(json);\n    } catch {\n      console.error('Coherence preview fetch failed');\n    }\n  };\n"
)

s = s.replace(
"      fetchGuidance();\n      pollingInterval = setInterval(fetchGuidance, 5000);\n",
"      fetchGuidance();\n      fetchCoherencePreview();\n      pollingInterval = setInterval(() => {\n        fetchGuidance();\n        fetchCoherencePreview();\n      }, 5000);\n"
)

s = s.replace(
"            setData(json);\n            setLoading(false);\n",
"            setData(json);\n            fetchCoherencePreview();\n            setLoading(false);\n"
)

s = s.replace(
"      <div style={sectionStyle}>\n        <strong>Guidance</strong>\n",
"      <div style={sectionStyle}>\n        <strong>Coherence Preview</strong>\n        <div style={{ marginTop: '8px', fontSize: '12px', opacity: 0.82, lineHeight: 1.45 }}>\n          {coherenceData ? (\n            <>\n              <div>Mode: {coherenceData.mode || 'coherence-shadow'}</div>\n              <div>Raw signals: {coherenceData.raw?.length ?? 0}</div>\n              <div>Coherent signals: {coherenceData.coherent?.length ?? 0}</div>\n              <div>Source: {coherenceData.source || 'unknown'}</div>\n            </>\n          ) : (\n            <div>Coherence preview unavailable.</div>\n          )}\n        </div>\n      </div>\n\n      <div style={sectionStyle}>\n        <strong>Guidance</strong>\n"
)

path.write_text(s)
PY
