
'use client';

import ExecutionInspector from "../../components/ExecutionInspector";

export default function Page() {

  return (

    <div className="p-6 space-y-6">

      <div>

        <div className="text-lg font-semibold">Execution Inspector — Evidence Surface</div>

        <div className="text-sm text-gray-500">

          Read-only UI proof surface for task execution evidence. This page does not create, mutate, retry, or execute tasks.

        </div>

      </div>

      <ExecutionInspector

        task={{

          id: "t_920a97c9-ddd5-41d3-851d-5735c6e52c30",

          status: "completed",

          claimed_by: "worker-f23fad8f-a5db-4621-94a5-e41f2e1e666a",

          updated_at: "2026-05-06T04:25:29.607Z",

          outcome_preview: "Standard execution prepared for: Phase 704 Execution Inspector live proof",

          explanation_preview: "standard execution path",

          guidance: {

            classification: "success",

            outcome: "Standard execution prepared for: Phase 704 Execution Inspector live proof",

            explanation: "standard execution path",

            run_id: "run_8d705078-6853-44cb-92c4-94bae960c8ea",

            task_id: "t_920a97c9-ddd5-41d3-851d-5735c6e52c30",

            actor: "worker-f23fad8f-a5db-4621-94a5-e41f2e1e666a",

            source: "worker",

            completed_at: "2026-05-06T04:25:31.000Z",

            outcome_preview: "Standard execution prepared for: Phase 704 Execution Inspector live proof",

            explanation_preview: "standard execution path",

            communicationResult: {

              outcome: {

                tier: "TIER_1",

                content: "Standard execution prepared for: Phase 704 Execution Inspector live proof",

                purpose: "operator-safe outcome",

                visibility: "default"

              },

              explanation: {

                tier: "TIER_2",

                content: "standard execution path",

                purpose: "brief causal explanation",

                visibility: "on_request",

                persistence: "non_sticky"

              },

              systemTrace: {

                tier: "TIER_3",

                content: {

                  run_id: "run_8d705078-6853-44cb-92c4-94bae960c8ea",

                  task_id: "t_920a97c9-ddd5-41d3-851d-5735c6e52c30",

                  execution_meta: {},

                  compiler_options: {},

                  strategy_applied: "default"

                },

                purpose: "internal/system execution trace",

                visibility: "explicit_access_only",

                persistence: "non_default"

              }

            }

          }

        }}

      />

    </div>

  );

}

