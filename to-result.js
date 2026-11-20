// Informes cucumber-json de Karate -> result.json (formato común de ivan-qa-lab-shared/schema)
const fs = require("fs");
const path = require("path");
const [, , dir, output] = process.argv;
const roles = {"TC-API10":"Anónimo","TC-API11":"Anónimo","TC-API12":"Jugador MAD","TC-API05":"Anónimo","TC-API18":"Jugador MAD","TC-API19":"Bloqueado","TC-API20":"Sin equipo","TC-API21":"Jugador MAD","TC-API01":"Anónimo","TC-API06":"Anónimo","TC-API08":"Anónimo","TC-API13":"Jugador MAD","TC-API14":"Jugador FOE","TC-API15":"Bloqueado","TC-API16":"Jugador MAD","TC-API17":"Super Admin","TC-API22":"Jugador FOE","TC-API23":"Admin MAD","TC-API02":"Anónimo","TC-API24":"Anónimo","TC-API25":"Sin equipo","TC-API26":"Bloqueado","TC-API27":"Jugador MAD","TC-API28":"Jugador FOE","TC-API29":"Anónimo","TC-API30":"Jugador FOE","TC-API31":"Jugador MAD","TC-API32":"Super Admin","TC-API03":"Anónimo","TC-API04":"Anónimo","TC-API33":"Jugador MAD","TC-API34":"Jugador FOE","TC-API35":"Admin FOE","TC-API36":"Jugador MAD","TC-API37":"Jugador FOE","TC-API38":"Jugador FOE","TC-API07":"Anónimo","TC-API39":"Anónimo","TC-API40":"Bloqueado","TC-API41":"Jugador FOE","TC-API42":"Jugador FOE","TC-API43":"Super Admin","TC-API44":"Jugador MAD","TC-API45":"Jugador FOE","TC-API46":"Jugador MAD","TC-API47":"Jugador MAD","TC-API48":"Anónimo","TC-API49":"Anónimo","TC-API50":"Jugador MAD","TC-API51":"Jugador MAD","TC-API52":"Jugador MAD","TC-API53":"Anónimo","TC-API54":"Jugador MAD","TC-API55":"Jugador MAD","TC-API56":"Jugador MAD","TC-API57":"Anónimo","TC-API58":"Anónimo"};
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
