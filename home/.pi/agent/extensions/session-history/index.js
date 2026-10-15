import history from "./viewer.cjs";

// Publish the exact session owned by this foreground Pi process. Never choose
// the newest file in a cwd: several panes can run different sessions there.
export default function sessionHistory(pi) {
  let published;

  pi.on("session_start", (_event, ctx) => {
    history.unpublishSession(published);
    published = undefined;
    if (ctx.mode !== "tui" || !process.env.HERDR_SOCKET_PATH || !process.env.HERDR_PANE_ID) return;
    const file = ctx.sessionManager.getSessionFile();
    if (!file) return;
    published = history.publishSession(process.env.HERDR_SOCKET_PATH, file, ctx.sessionManager.getSessionId());
  });

  pi.on("session_shutdown", () => {
    history.unpublishSession(published);
    published = undefined;
  });
}
