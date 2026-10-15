// Shared with the Pi extension. Herdr runs this file directly for prefix+e.
const { createHash } = require("node:crypto");
const fs = require("node:fs");
const os = require("node:os");
const path = require("node:path");
const { spawn, spawnSync } = require("node:child_process");

function registrationPath(socket, pid) {
  const server = createHash("sha256").update(socket).digest("hex");
  return path.join(os.homedir(), ".cache", "pi-herdr-session-history", `${server}-${pid}.json`);
}

function processStart(pid) {
  const result = spawnSync("ps", ["-p", String(pid), "-o", "lstart="], {
    encoding: "utf8", timeout: 5000, env: { ...process.env, LC_ALL: "C" },
  });
  if (result.error || result.status !== 0 || !result.stdout.trim()) {
    throw new Error(`Cannot identify Pi process ${pid}`);
  }
  return result.stdout.trim();
}

function publishSession(socket, sessionFile, sessionId) {
  const file = registrationPath(socket, process.pid);
  const registration = { pid: process.pid, processStart: processStart(process.pid), sessionFile, sessionId };
  fs.mkdirSync(path.dirname(file), { recursive: true, mode: 0o700 });
  const temporary = `${file}.tmp`;
  try {
    fs.writeFileSync(temporary, JSON.stringify(registration), { mode: 0o600 });
    fs.renameSync(temporary, file);
  } finally {
    fs.rmSync(temporary, { force: true });
  }
  return { file, registration };
}

function unpublishSession(published) {
  if (!published) return;
  try {
    const current = JSON.parse(fs.readFileSync(published.file, "utf8"));
    if (current.pid === published.registration.pid && current.sessionId === published.registration.sessionId) {
      fs.rmSync(published.file, { force: true });
    }
  } catch (error) {
    if (error.code !== "ENOENT") throw error;
  }
}

function herdr(args) {
  const result = spawnSync(process.env.HERDR_BIN_PATH || "herdr", args, {
    encoding: "utf8", timeout: 10000, maxBuffer: 256 * 1024 * 1024,
  });
  if (result.error) throw result.error;
  if (result.status !== 0) throw new Error(result.stderr.trim() || `Herdr command failed: ${args.join(" ")}`);
  return result.stdout;
}

function findSession(socket, processes) {
  const sessions = [];
  for (const process of processes) {
    let registration;
    try {
      registration = JSON.parse(fs.readFileSync(registrationPath(socket, process.pid), "utf8"));
    } catch (error) {
      if (error.code === "ENOENT") continue;
      throw error;
    }
    if (registration.pid !== process.pid || registration.processStart !== processStart(process.pid)) continue;
    if (!path.isAbsolute(registration.sessionFile || "") || !registration.sessionId) {
      throw new Error("Invalid Pi session registration. Run /reload in the source Pi pane.");
    }
    sessions.push(registration);
  }
  if (sessions.length > 1) throw new Error("Multiple Pi sessions in this foreground process group; refusing to guess.");
  return sessions[0];
}

// Render every field, not just model context or the currently visible branch.
// Strings keep their real newlines; no thinking/tool output is collapsed.
function renderValue(value, depth = 0) {
  const indent = "  ".repeat(depth);
  if (Array.isArray(value)) {
    if (!value.length) return `${indent}[]`;
    return value.map((item, i) => `${indent}[${i + 1}]\n${renderValue(item, depth + 1)}`).join("\n");
  }
  if (value !== null && typeof value === "object") {
    const fields = Object.entries(value);
    if (!fields.length) return `${indent}{}`;
    return fields.map(([key, item]) => `${indent}${key}:\n${renderValue(item, depth + 1)}`).join("\n");
  }
  const text = typeof value === "string" ? value : JSON.stringify(value);
  return text.split("\n").map(line => indent + line).join("\n");
}

function renderSession(text, sessionFile, sessionId) {
  const lines = text.split("\n");
  const entries = [];
  let incompleteTail = false;
  for (let i = 0; i < lines.length; i++) {
    if (!lines[i].trim()) continue;
    try {
      entries.push(JSON.parse(lines[i]));
    } catch (error) {
      // An active Pi may be appending its last JSONL entry during the read.
      if (i === lines.length - 1 && !text.endsWith("\n")) {
        incompleteTail = true;
        continue;
      }
      throw new Error(`Invalid session JSONL at line ${i + 1}: ${error.message}`);
    }
  }
  if (entries[0]?.type !== "session" || entries[0].id !== sessionId) {
    throw new Error("Session identity does not match the source Pi process. Run /reload in Pi.");
  }
  const output = [
    "# Pi session history", `Source: ${sessionFile}`, `Entries: ${entries.length}`,
    "Complete persisted history, including all branches and pre-compaction entries.",
    "Snapshot only: in-flight messages appear after Pi saves them. Reopen to refresh.", "",
  ];
  for (const [i, entry] of entries.entries()) {
    const title = entry.type === "message" ? entry.message?.role || "message" : entry.type;
    output.push(`## ${i + 1}. ${title}`, renderValue(entry), "");
  }
  if (incompleteTail) output.push("NOTE: The last entry is still being written. Reopen after Pi saves it.");
  return output.join("\n");
}

function snapshotForPane(paneId, socket) {
  const pane = JSON.parse(herdr(["pane", "get", paneId])).result.pane;
  const info = JSON.parse(herdr(["pane", "process-info", "--pane", paneId])).result.process_info;
  const session = findSession(socket, info.foreground_processes || []);
  if (session) {
    if (!fs.existsSync(session.sessionFile)) {
      throw new Error("This Pi session has no saved messages yet. Send a message, then reopen the viewer.");
    }
    return renderSession(fs.readFileSync(session.sessionFile, "utf8"), session.sessionFile, session.sessionId);
  }
  if (pane.agent === "pi") {
    throw new Error("The Pi session-history extension is not loaded in this pane.\nRun /reload in Pi, then press Ctrl+A followed by e again.\nNo partial terminal history was substituted for the session.");
  }
  // Preserve terminal history for shells, editors, and other agents.
  // Herdr's limit is bytes; this asks for effectively all retained rows.
  return herdr(["pane", "read", paneId, "--source", "recent", "--lines", "2147483647", "--raw"]);
}

async function main() {
  const paneId = process.env.HERDR_ACTIVE_PANE_ID;
  const socket = process.env.HERDR_SOCKET_PATH;
  if (!paneId || !socket) throw new Error("Launch this viewer with Herdr's Ctrl+A, then e shortcut.");
  let snapshot;
  try {
    snapshot = snapshotForPane(paneId, socket);
  } catch (error) {
    snapshot = `# Session history unavailable\n\n${error.message}\n`;
  }
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), "pi-herdr-history-"));
  const file = path.join(directory, "history.txt");
  const signalHandlers = new Map();
  try {
    fs.writeFileSync(file, snapshot, { mode: 0o600 });
    const editor = spawn("nvim", [
      "-R", "-n", "-i", "NONE", "--cmd", "set nomodeline nobackup nowritebackup noswapfile", "--", file,
    ], { stdio: "inherit" });
    for (const signal of ["SIGINT", "SIGTERM", "SIGHUP"]) {
      const handler = () => editor.kill(signal);
      signalHandlers.set(signal, handler);
      process.on(signal, handler);
    }
    return await new Promise((resolve, reject) => {
      editor.once("error", reject);
      editor.once("close", (code, signal) => resolve(code ?? 128 + (os.constants.signals[signal] || 0)));
    });
  } finally {
    for (const [signal, handler] of signalHandlers) process.off(signal, handler);
    fs.rmSync(directory, { recursive: true, force: true });
  }
}

module.exports = { registrationPath, processStart, publishSession, unpublishSession, findSession, renderSession, snapshotForPane, main };
if (require.main === module) {
  main().then(code => { process.exitCode = code; }).catch(error => {
    console.error(error.message);
    process.exitCode = 1;
  });
}
