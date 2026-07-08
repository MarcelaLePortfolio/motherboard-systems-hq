
import { CausalNode } from "./causal-graph";

/**

 * Prune weak + outdated signals

 */

export function pruneCausalGraph(graph: CausalNode[]): CausalNode[] {

  return graph.filter((node, index) => {

    if (index === 0) return true;

    const weight = node.finalWeight ?? 0;

    // stronger threshold because we now include time decay

    return weight >= 0.25;

  });

}

