const assert = require("node:assert/strict");
const fs = require("node:fs");
const os = require("node:os");
const path = require("node:path");
const { spawn, spawnSync } = require("node:child_process");
const { pathToFileURL } = require("node:url");
const { test, beforeEach, afterEach } = require("node:test");

const directory = path.resolve(__dirname, "../home/.pi/agent/extensions/session-history");
const history = require(path.join(directory, "viewer.cjs"));
let root, savedEnvironment;

function fixture(id = "session-one", prompt = "EARLIEST PROMPT") {
  return [
    { type: "session", id, version: 3, cwd: "/same/project" },
    { type: "message", id: "old", parentId: null, message: { role: "user", content: prompt } },
    { type: "message", id: "answer", parentId: "old", message: {
      role: "assistant", content: [
        { type: "thinking", thinking: "HIDDEN THINKING\nsecond thinking line" },
        { type: "toolCall", id: "call", name: "bash", arguments: { command: "full command" } },
        { type: "text", text: "FULL REPLY" },
      ],
    } },
    { type: "message", id: "result", parentId: "answer", message: {
      role: "toolResult", toolName: "bash", content: [{ type: "text", text: "TOOL START\n" + "large output\n".repeat(12000) + "TOOL END" }],
    } },
    { type: "compaction", id: "compact", parentId: "result", summary: "summary only" },
    { type: "message", id: "branch", parentId: "old", message: { role: "user", content: "ALTERNATE BRANCH" } },
    { type: "future_entry", id: "future", data: { customField: "UNKNOWN ENTRY KEPT" } },
  ].map(entry => JSON.stringify(entry)).join("\n") + "\n";
}

function executable(name, source) {
  const file = path.join(root, "bin", name);
  fs.writeFileSync(file, "#!/usr/bin/env node\n" + source, { mode: 0o700 });
  return file;
}

function runViewer() {
  return spawnSync(process.execPath, [path.join(directory, "viewer.cjs")], {
    env: process.env, encoding: "utf8", timeout: 20000,
  });
}

beforeEach(() => {
  savedEnvironment = { ...process.env };
  root = fs.mkdtempSync(path.join(os.tmpdir(), "pi-history-test-"));
  fs.mkdirSync(path.join(root, "bin"));
  Object.assign(process.env, {
    HOME: root, TMPDIR: root, PATH: path.join(root, "bin") + path.delimiter + process.env.PATH,
    HERDR_SOCKET_PATH: path.join(root, "herdr.sock"), HERDR_ACTIVE_PANE_ID: "w1:p1",
    TEST_PI_PID: String(process.pid), TEST_PANE_AGENT: "pi", TEST_ROOT: root,
  });
  process.env.HERDR_BIN_PATH = executable("herdr", `
    const fs = require("node:fs"), path = require("node:path");
    const args = process.argv.slice(2);
    fs.appendFileSync(path.join(process.env.TEST_ROOT, "calls.jsonl"), JSON.stringify(args) + "\\n");
    if (args[1] === "get") console.log(JSON.stringify({ result: { pane: { agent: process.env.TEST_PANE_AGENT } } }));
    else if (args[1] === "process-info") console.log(JSON.stringify({ result: { process_info: { foreground_processes: [{ pid: Number(process.env.TEST_PI_PID) }] } } }));
    else if (args[1] === "read") process.stdout.write("SHELL EARLY\\nSHELL LATE\\n");
    else process.exit(2);
  `);
  executable("nvim", `
    const fs = require("node:fs"), path = require("node:path");
    const file = process.argv.at(-1);
    const output = { args: process.argv.slice(2), file, mode: fs.statSync(file).mode & 0o777, directoryMode: fs.statSync(path.dirname(file)).mode & 0o777 };
    fs.copyFileSync(file, path.join(process.env.TEST_ROOT, "viewed.txt"));
    fs.writeFileSync(path.join(process.env.TEST_ROOT, "editor.json"), JSON.stringify(output));
    process.exit(Number(process.env.TEST_EDITOR_STATUS || 0));
  `);
});

afterEach(() => {
  for (const key of Object.keys(process.env)) if (!(key in savedEnvironment)) delete process.env[key];
  Object.assign(process.env, savedEnvironment);
  fs.rmSync(root, { recursive: true, force: true });
});

test("all persisted entries survive rendering, including thinking, tools, old and alternate branches", () => {
  const snapshot = history.renderSession(fixture(), "/session.jsonl", "session-one");
  for (const marker of ["EARLIEST PROMPT", "HIDDEN THINKING", "second thinking line", "full command", "FULL REPLY", "TOOL START", "TOOL END", "ALTERNATE BRANCH", "UNKNOWN ENTRY KEPT"]) {
    assert.ok(snapshot.includes(marker), marker);
  }
  assert.equal((snapshot.match(/large output/g) || []).length, 12000);
  assert.ok(snapshot.includes("Entries: 7"));
});

test("partial append is explained; malformed completed records and identity mismatches fail", () => {
  assert.match(history.renderSession(fixture() + '{"type":', "/session", "session-one"), /last entry is still being written/);
  assert.throws(() => history.renderSession(fixture() + "{broken}\n", "/session", "session-one"), /Invalid session JSONL/);
  assert.throws(() => history.renderSession(fixture(), "/session", "wrong-session"), /identity/);
});

test("registrations are private and scoped by socket, PID, and process start", () => {
  const published = history.publishSession(process.env.HERDR_SOCKET_PATH, "/session.jsonl", "session-one");
  assert.equal(fs.statSync(published.file).mode & 0o777, 0o600);
  assert.equal(fs.statSync(path.dirname(published.file)).mode & 0o777, 0o700);
  assert.notEqual(published.file, history.registrationPath("another-server", process.pid));
  assert.notEqual(published.file, history.registrationPath(process.env.HERDR_SOCKET_PATH, process.pid + 1));
  assert.equal(history.findSession(process.env.HERDR_SOCKET_PATH, [{ pid: process.pid }]).sessionId, "session-one");
  fs.writeFileSync(published.file, JSON.stringify({ ...published.registration, processStart: "previous process" }));
  assert.equal(history.findSession(process.env.HERDR_SOCKET_PATH, [{ pid: process.pid }]), undefined);
});

test("cleanup of an older session cannot remove its replacement", () => {
  const old = history.publishSession(process.env.HERDR_SOCKET_PATH, "/old.jsonl", "old");
  const current = history.publishSession(process.env.HERDR_SOCKET_PATH, "/current.jsonl", "current");
  history.unpublishSession(old);
  assert.ok(fs.existsSync(current.file));
  history.unpublishSession(current);
  history.unpublishSession(current);
  assert.ok(!fs.existsSync(current.file));
});

test("Pi extension republishes on switch/reload and cleans up on shutdown; non-TUI sessions do not publish", async () => {
  const extension = (await import(pathToFileURL(path.join(directory, "index.js")))).default;
  const handlers = new Map();
  extension({ on: (event, handler) => handlers.set(event, handler) });
  process.env.HERDR_PANE_ID = "w1:p1";
  let id = "first";
  const ctx = { mode: "tui", sessionManager: { getSessionFile: () => `/${id}.jsonl`, getSessionId: () => id } };
  const registration = history.registrationPath(process.env.HERDR_SOCKET_PATH, process.pid);
  for (const reason of ["startup", "resume", "new", "reload", "fork"]) {
    id = reason;
    await handlers.get("session_start")({ reason }, ctx);
    assert.equal(JSON.parse(fs.readFileSync(registration, "utf8")).sessionId, reason);
  }
  await handlers.get("session_shutdown")({}, ctx);
  assert.ok(!fs.existsSync(registration));
  await handlers.get("session_start")({}, { ...ctx, mode: "rpc" });
  assert.ok(!fs.existsSync(registration));
  await handlers.get("session_start")({}, { ...ctx, sessionManager: { getSessionFile: () => undefined } });
  assert.ok(!fs.existsSync(registration));
});

test("Herdr-to-Neovim path opens the exact foreground session, not a newer file in the same cwd", () => {
  const file = path.join(root, "exact session.jsonl");
  fs.writeFileSync(file, fixture());
  fs.writeFileSync(path.join(root, "newer.jsonl"), fixture("other", "WRONG SESSION"));
  history.publishSession(process.env.HERDR_SOCKET_PATH, file, "session-one");
  const result = runViewer();
  assert.equal(result.status, 0, result.stderr);
  const viewed = fs.readFileSync(path.join(root, "viewed.txt"), "utf8");
  assert.ok(viewed.includes("EARLIEST PROMPT"));
  assert.ok(viewed.includes("TOOL END"));
  assert.ok(!viewed.includes("WRONG SESSION"));
  const editor = JSON.parse(fs.readFileSync(path.join(root, "editor.json"), "utf8"));
  assert.equal(editor.mode, 0o600);
  assert.equal(editor.directoryMode, 0o700);
  assert.ok(editor.args.includes("-R"));
  assert.ok(editor.args.includes("set nomodeline nobackup nowritebackup noswapfile"));
  assert.ok(!fs.existsSync(path.dirname(editor.file)));
  const calls = fs.readFileSync(path.join(root, "calls.jsonl"), "utf8");
  assert.ok(!calls.includes('"read"'));
});

test("unregistered Pi explains /reload rather than presenting partial scrollback as full history", () => {
  const result = runViewer();
  assert.equal(result.status, 0, result.stderr);
  assert.match(fs.readFileSync(path.join(root, "viewed.txt"), "utf8"), /Run \/reload/);
  assert.ok(!fs.readFileSync(path.join(root, "calls.jsonl"), "utf8").includes('"read"'));
});

test("shell panes keep all available terminal history and editor exit status; snapshots are removed", () => {
  process.env.TEST_PANE_AGENT = "";
  process.env.TEST_EDITOR_STATUS = "7";
  const result = runViewer();
  assert.equal(result.status, 7, result.stderr);
  assert.equal(fs.readFileSync(path.join(root, "viewed.txt"), "utf8"), "SHELL EARLY\nSHELL LATE\n");
  const calls = fs.readFileSync(path.join(root, "calls.jsonl"), "utf8").trim().split("\n").map(JSON.parse);
  assert.deepEqual(calls.at(-1), ["pane", "read", "w1:p1", "--source", "recent", "--lines", "2147483647", "--raw"]);
  const editor = JSON.parse(fs.readFileSync(path.join(root, "editor.json"), "utf8"));
  assert.ok(!fs.existsSync(path.dirname(editor.file)));
});

test("snapshot cleanup also runs when Neovim cannot start", () => {
  fs.rmSync(path.join(root, "bin/nvim"));
  // Prevent PATH from finding the real user's editor during this failure test.
  process.env.PATH = path.join(root, "bin");
  const result = runViewer();
  assert.equal(result.status, 1);
  assert.ok(!fs.readdirSync(root).some(name => name.startsWith("pi-herdr-history-")));
});

test("closing the viewer forwards termination to Neovim and removes the private snapshot", { timeout: 10000 }, async () => {
  executable("nvim", `
    const fs = require("node:fs"), path = require("node:path");
    fs.writeFileSync(path.join(process.env.TEST_ROOT, "open-file.txt"), process.argv.at(-1));
    setInterval(() => {}, 1000);
  `);
  const child = spawn(process.execPath, [path.join(directory, "viewer.cjs")], { env: process.env, stdio: "ignore" });
  const closed = new Promise((resolve, reject) => {
    child.once("error", reject);
    child.once("close", (code, signal) => resolve({ code, signal }));
  });
  try {
    const marker = path.join(root, "open-file.txt");
    for (let i = 0; i < 80 && !fs.existsSync(marker); i++) await new Promise(resolve => setTimeout(resolve, 50));
    const file = fs.readFileSync(marker, "utf8");
    assert.ok(fs.existsSync(file));
    child.kill("SIGTERM");
    assert.equal((await closed).code, 143);
    assert.ok(!fs.existsSync(path.dirname(file)));
  } finally {
    child.kill("SIGTERM");
  }
});

test("unsaved sessions and missing launch context show actionable errors without guessing", () => {
  history.publishSession(process.env.HERDR_SOCKET_PATH, path.join(root, "unsaved.jsonl"), "unsaved");
  assert.equal(runViewer().status, 0);
  assert.match(fs.readFileSync(path.join(root, "viewed.txt"), "utf8"), /no saved messages/);
  delete process.env.HERDR_ACTIVE_PANE_ID;
  const result = runViewer();
  assert.equal(result.status, 1);
  assert.match(result.stderr, /Launch this viewer with Herdr/);
});
