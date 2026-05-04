export async function retry({ label, tries = 120, delayMs = 250, fn }) {
  let lastErr
  for (let i = 1; i <= tries; i++) {
    try {
      if (i > 1) console.log(`[retry] ${label}: attempt ${i}/${tries}`)
      return await fn()
    } catch (err) {
      lastErr = err
      const msg = String(err?.message || err)
      const code = err?.code
      // retry only on common "db not ready" failure modes
      const ok =
        code === 'ECONNREFUSED' ||
        code === 'ENOTFOUND' ||
        code === 'EAI_AGAIN' ||
        /ECONNREFUSED|terminating connection|the database system is starting up/i.test(msg)

      if (!ok || i === tries) throw err
      await new Promise(r => setTimeout(r, delayMs))
    }
  }
  throw lastErr
}
