export type OperatorAttentionLevel = "LOW" | "MEDIUM" | "HIGH" | "CRITICAL";

export interface OperatorAttention {
  level: OperatorAttentionLevel;
  badge: string;
  emphasis: "SUBTLE" | "STANDARD" | "STRONG";
}
