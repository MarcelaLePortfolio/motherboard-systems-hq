import { queryVectorstore } from '../../utils/queryVectorstore';
import { learnVectorstore } from '../../utils/learnVectorstore';

export async function cadeCommandRouter(command: string, args: any): Promise<any> {
  switch (command) {
    case 'query': {
      const [namespace, prompt] = Array.isArray(args) ? args : [args.namespace, args.prompt];
      return queryVectorstore(namespace, prompt);
    }

    case 'learn': {
      const [targetPath, namespace] = Array.isArray(args) ? args : [args.targetPath, args.namespace];
      return learnVectorstore(targetPath, namespace);
    }

    default:
      return {
        status: 'error',
        message: `Unknown command "${command}"`,
      };
  }
}
