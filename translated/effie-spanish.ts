```typescript
import { log } from '../utils/log.js';
import { promesas as fs } from 'fs';

export async function routerComandosEffie(comando: string, args?: Record<string, any>) {
  try {
    switch (comando) {
      case 'leer archivo':
        if (!args?.ruta) throw new Error('Falta ruta');
        return { estado: 'éxito', resultado: await fs.readFile(args.ruta, 'utf-8') };

      case 'escribir archivo':
        if (!args?.ruta || typeof args?.contenido !== 'string') throw new Error('Faltan ruta o contenido');
        await fs.writeFile(args.ruta, args.contenido);
        return { estado: 'éxito', resultado: `Escrito en ${args.ruta}` };

      case 'borrar archivo':
        if (!args?.ruta) throw new Error('Falta ruta');
        await fs.unlink(args.ruta);
        return { estado: 'éxito', resultado: `${args.ruta} eliminado` };

      case 'mover archivo':
        if (!args?.desde || !args?.hasta) throw new Error('Faltan desde/hasta');
        await fs.rename(args.desde, args.hasta);
        return { estado: 'éxito', resultado: `${args.desde} movido a ${args.hasta}` };

      case 'listar archivos':
        if (!args?.carpeta) throw new Error('Falta carpeta');
const archivos = await fs.readdir(args.carpeta);
        return { estado: 'éxito', resultado: archivos };

      default:
        return { estado: 'error', mensaje: `Comando desconocido: ${comando}` };
    }
  } catch (err: any) {
    await log(`Error Effie: ${err.mensaje}`);
    return { estado: 'error', mensaje: err.mensaje };
  }
}

/**
 * Exportado con nombre para el agente Effie
 */
export const effie = {
  nombre: "Effie",
  papel: "Asistente de operaciones local/Desktop",
  handler: routerComandosEffie
};
```