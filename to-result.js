// Informes cucumber-json de Karate -> result.json (formato común de ivan-qa-lab-shared/schema)
const fs = require("fs");
const path = require("path");
const [, , dir, output] = process.argv;
const roles = { "TC-API12": "Jugador MAD", "TC-API13": "Jugador MAD", "TC-API14": "Jugador FOE", "TC-API15": "Bloqueado", "TC-API16": "Jugador MAD", "TC-API17": "Super Admin" };
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
tests.sort((a, b) => a.name.localeCompare(b.name));
const count = (s) => tests.filter((t) => t.status === s).length;
const total = tests.reduce((a, t) => a + t.duration_ms, 0);
const now = Date.now();
const result = {
  tool: "karate", target: "tactical-calendar", suite: process.env.SUITE || "api",
  started_at: new Date(now - total).toISOString(), finished_at: new Date(now).toISOString(), duration_ms: total,
  summary: { total: tests.length, passed: count("passed"), failed: count("failed"), skipped: count("skipped") },
  tests,
};
fs.writeFileSync(output, JSON.stringify(result, null, 2));
console.log(`result.json: ${result.summary.passed}/${result.summary.total} pasan, ${result.summary.skipped} omitidos`);
