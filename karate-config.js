// Configuración global de Karate: URL del staging (pública), clave publicable y contraseña QA por entorno.
function fn() {
  return {
    baseUrl: karate.properties['base.url'] || java.lang.System.getenv('BASE_URL_API') || 'https://rpxdxitntsmgcbbnuyox.supabase.co',
    anonKey: karate.properties['anon.key'] || java.lang.System.getenv('ANON_KEY') || 'sb_publishable_2gp_hyA_-M5we4-EEl3vgA_zrGS0l4I',
    qaPassword: java.lang.System.getenv('QA_PASSWORD') || ''
  };
}
