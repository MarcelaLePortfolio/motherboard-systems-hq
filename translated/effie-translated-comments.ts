```typescript
import { log } from '../utils/log.js';
import { promesas as fs } from 'fs';
//////import path from 'path';

export async function routerComandoEffie(comando: string, args?: Registro<string, any>) {
  try {
    switch (comando) {
      case 'leer archivo':
        if (!args?.ruta) throw new Error('Ruta omitida');
        return { estado: 'exito', resultado: await fs.readFile(args.ruta, 'utf-8') };

      case 'escribir archivo':
        if (!args?.ruta || typeof args?.contenido !== 'string') throw new Error('Ruta o contenido omitidos');
        await fs.writeFile(args.ruta, args.contenido);
        return { estado: 'exito', resultado: `Escrito en ${args.ruta}` };

      case 'eliminar archivo':
        if (!args?.ruta) throw new Error('Ruta omitida');
        await fs.unlink(args.ruta);
        return { estado: 'exito', resultado: `${args.ruta} eliminado` };

      case 'mover archivo':
        if (!args?.de || !args?.hacia) throw new Error('De o hacia omitidos');
        await fs.rename(args.de, args.hacia);
        return { estado: 'exito', resultado: `Movido ${args.de} a ${args.hacia}` };

      case 'listar archivos':
        if (!args?.carpeta) throw new Error('Carpeta omitida');
const archivos = await fs.readdir(args.carpeta);
        return { estado: 'exito', resultado: archivos };

      default:
        return { estado: 'error', mensaje: `Comando desconocido: ${comando}` };
    }
  } catch (err: any) {
    await log(`Error de Effie: ${err.mensaje}`);
    return { estado: 'error', mensaje: err.mensaje };
  }
}

/**
 * Exportado con nombre para el agente Effie
 */
export const effie = {
  nombre: "Effie",
  papel: "Asistente de Operaciones Locales/Local",
  handler: routerComandoEffie
};
```