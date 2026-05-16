
from pathlib import Path

path = Path("server/worker/task_execution_interpreter.mjs")

text = path.read_text()

old = '''  if (detectVisualArtifactIntent(title)) {

    return {

      ok: true,

      strategy_applied: "visual_artifact_generation",

      notes: "visual artifact intent detected",

      output: buildVisualArtifactOutput(title),

      meta: {

        ...meta,

        visual_artifact: true

      }

    };

  }

'''

new = '''  if (detectVisualArtifactIntent(title)) {

    return {

      ok: true,

      strategy_applied: "prompt_augmentation",

      notes: "visual artifact intent detected",

      output: buildVisualArtifactOutput(title),

      meta: {

        ...meta,

        visual_artifact: true,

        visual_artifact_strategy: "visual_artifact_generation"

      }

    };

  }

'''

if old not in text:

    raise SystemExit("Visual artifact strategy branch not found.")

path.write_text(text.replace(old, new, 1))

