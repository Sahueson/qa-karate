// Comprobaciones comunes de los casos de API. Devuelve '' si todo está bien o el motivo del fallo.
function(spec, status, body) {
  var get = function(o, p) {
    var parts = p.split('.'), cur = o;
    for (var i = 0; i < parts.length; i++) {
      if (cur == null) return cur;
      var k = parts[i];
      if (Array.isArray(cur) && !/^\d+$/.test(k)) { var out = []; for (var j = 0; j < cur.length; j++) out.push(cur[j] == null ? null : cur[j][k]); cur = out; }
      else cur = cur[k];
    }
    return cur;
  };
  var isArr = Array.isArray(body);
  var has = function(a, v) { for (var i = 0; i < a.length; i++) if (a[i] == v) return true; return false; };
  if (spec.status && !has(spec.status, status)) return 'status ' + status + ' no esperado ' + spec.status;
  if (spec.blocked && !(has([401, 403], status) || (has([200, 204], status) && (!body || (isArr && body.length == 0))))) return 'la operación debería estar bloqueada o no afectar a ninguna fila (status ' + status + ')';
  if (spec.empty && !(isArr && body.length == 0)) return 'se esperaba una lista vacía';
  if (spec.nonEmpty && !(isArr && body.length > 0)) return 'se esperaba una lista con filas';
  if (spec.isArray && !isArr) return 'se esperaba una lista';
  if (spec.errorCode && (!body || body.error_code != spec.errorCode)) return 'error_code distinto de ' + spec.errorCode;
  if (spec.token && (!body || !body.access_token)) return 'falta access_token';
  if (spec.eachEq) { for (var i = 0; i < body.length; i++) if (get(body[i], spec.eachEq.path) != spec.eachEq.value) return 'una fila no cumple ' + spec.eachEq.path + ' = ' + spec.eachEq.value; }
  if (spec.hasValue && get(body, spec.hasValue.path) != spec.hasValue.value) return 'valor distinto en ' + spec.hasValue.path;
  if (spec.hasSquads) { for (var s = 0; s < spec.hasSquads.length; s++) { var found = false; for (var i = 0; i < body.length; i++) if (body[i].squad == spec.hasSquads[s]) found = true; if (!found) return 'falta el equipo ' + spec.hasSquads[s]; } }
  if (spec.notEscalated && !(status >= 400 || (isArr && (body.length == 0 || (body[0].app_role == 'player' && !body[0].is_super_admin))))) return 'el jugador no debe poder ascenderse';
  return '';
}
