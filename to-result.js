// Informes cucumber-json de Karate -> result.json (formato común de ivan-qa-lab-shared/schema)
const fs = require("fs");
const path = require("path");
const [, , dir, output] = process.argv;
const roles = {"TC-A01":"Anónimo","TC-A02":"Anónimo","TC-A03":"Jugador MAD","TC-A04":"Anónimo","TC-A05":"Jugador MAD","TC-A06":"Bloqueado","TC-A07":"Sin equipo","TC-A08":"Jugador MAD","TC-B01":"Anónimo","TC-B02":"Anónimo","TC-B03":"Anónimo","TC-B04":"Jugador MAD","TC-B05":"Jugador FOE","TC-B06":"Bloqueado","TC-B07":"Jugador MAD","TC-B08":"Super Admin","TC-B09":"Jugador FOE","TC-B10":"Admin MAD","TC-C01":"Anónimo","TC-C02":"Anónimo","TC-C03":"Sin equipo","TC-C04":"Bloqueado","TC-C05":"Jugador MAD","TC-C06":"Jugador FOE","TC-D01":"Anónimo","TC-D02":"Jugador FOE","TC-D03":"Jugador MAD","TC-D04":"Super Admin","TC-E01":"Anónimo","TC-E02":"Anónimo","TC-E03":"Jugador MAD","TC-E04":"Jugador FOE","TC-E05":"Admin FOE","TC-E06":"Jugador MAD","TC-E07":"Jugador FOE","TC-E08":"Jugador FOE","TC-F01":"Anónimo","TC-F02":"Anónimo","TC-F03":"Bloqueado","TC-F04":"Jugador FOE","TC-F05":"Jugador FOE","TC-G01":"Super Admin","TC-G02":"Jugador MAD","TC-G03":"Jugador FOE","TC-G04":"Jugador MAD","TC-G05":"Jugador MAD","TC-H01":"Anónimo","TC-H02":"Anónimo","TC-H03":"Jugador MAD","TC-H04":"Jugador MAD","TC-H05":"Jugador MAD","TC-I01":"Anónimo","TC-I02":"Jugador MAD","TC-I03":"Jugador MAD","TC-I04":"Jugador MAD","TC-I05":"Anónimo","TC-I06":"Anónimo"};
const walk = (d) => fs.readdirSync(d, { withFileTypes: true }).flatMap((e) => (e.isDirectory() ? walk(path.join(d, e.name)) : [path.join(d, e.name)]));
const files = walk(dir).filter((f) => f.endsWith(".json") && !path.basename(f).startsWith("karate-summary"));
const tests = [];
for (const f of files) {
  const features = JSON.parse(fs.readFileSync(f, "utf8"));
  for (const feat of Array.isArray(features) ? features : [features]) {
    for (const sc of feat.elements || []) {
      if (sc.type === "background") continue;
      const steps = sc.steps || [];
      const bad = steps.find((s) => s.result && s.result.status === "failed");
      const ms = Math.round(steps.reduce((a, s) => a + ((s.result && s.result.duration) || 0), 0) / 1e6);
      const auth = (sc.tags || []).some((t) => t.name === "@auth");
      // Sin QA_PASSWORD los escenarios @auth hacen karate.abort(): para el lab son "omitidos".
      const skipped = !bad && auth && !process.env.QA_PASSWORD;
      tests.push({
        name: sc.name,
        status: bad ? "failed" : skipped ? "skipped" : "passed",
        duration_ms: ms,
        role: roles[sc.name.split(" ")[0]] || "Anónimo",
        error: bad ? bad.result.error_message : null,
        evidence_url: null,
      });
    }
  }
}
if (process.env.GREP) {
  const wanted = process.env.GREP.split("|").map((n) => n.replace(/^\^/, "").replace(/\$$/, "").replace(/\\(.)/g, "$1"));
  for (let i = tests.length - 1; i >= 0; i--) if (!wanted.includes(tests[i].name)) tests.splice(i, 1);
}
tests.sort((a, b) => a.name.localeCompare(b.name));
const count = (s) => tests.filter((t) => t.status === s).length;
const total = tests.reduce((a, t) => a + t.duration_ms, 0);
const now = Date.now();
const result = {
  tool: "karate", target: "tactical-calendar", suite: process.env.SUITE || "all",
  started_at: new Date(now - total).toISOString(), finished_at: new Date(now).toISOString(), duration_ms: total,
  summary: { total: tests.length, passed: count("passed"), failed: count("failed"), skipped: count("skipped") },
  tests,
};
fs.writeFileSync(output, JSON.stringify(result, null, 2));
console.log(`result.json: ${result.summary.passed}/${result.summary.total} pasan, ${result.summary.skipped} omitidos`);
