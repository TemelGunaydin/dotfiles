import fs from "node:fs";
import os from "node:os";
import path from "node:path";

import type {
  ExtensionAPI,
  ExtensionContext,
} from "@earendil-works/pi-coding-agent";

type AgentInfo = {
  name: string;
  model?: string;
};

export default function (pi: ExtensionAPI) {
  let activeSubagents: AgentInfo[] = [];

  function readAgentInfo(
    agentName: string,
    cwd: string,
  ): AgentInfo {
    const candidates = [
      // Project-local agent
      path.join(cwd, ".pi", "agents", `${agentName}.md`),

      // Global agent
      path.join(
        os.homedir(),
        ".pi",
        "agent",
        "agents",
        `${agentName}.md`,
      ),
    ];

    for (const file of candidates) {
      if (!fs.existsSync(file)) {
        continue;
      }

      try {
        const content = fs.readFileSync(file, "utf8");

        const modelMatch = content.match(
          /^model:\s*["']?(.+?)["']?\s*$/m,
        );

        const nameMatch = content.match(
          /^name:\s*["']?(.+?)["']?\s*$/m,
        );

        return {
          name: nameMatch?.[1] ?? agentName,
          model: modelMatch?.[1],
        };
      } catch {
        // Fall through and just show agent name.
      }
    }

    return {
      name: agentName,
    };
  }

  function getParentLabel(ctx: ExtensionContext): string {
    const model = ctx.model;

    if (!model) {
      return "MAIN: none";
    }

    const thinking = pi.getThinkingLevel();

    return (
      `MAIN: ${model.provider}/${model.id}` +
      (thinking ? ` · ${thinking}` : "")
    );
  }

  function updateStatus(ctx: ExtensionContext) {
    const parent = getParentLabel(ctx);

    if (activeSubagents.length === 0) {
      ctx.ui.setStatus(
        "model-status",
        ctx.ui.theme.fg("accent", parent),
      );

      return;
    }

    const active = activeSubagents
      .map((agent) => {
        if (agent.model) {
          return `${agent.name} → ${agent.model}`;
        }

        return agent.name;
      })
      .join(" | ");

    const text =
      `${parent}  │  ` +
      `ACTIVE: ${active}`;

    ctx.ui.setStatus(
      "model-status",
      ctx.ui.theme.fg("accent", text),
    );
  }

  function extractAgents(
    args: any,
    cwd: string,
  ): AgentInfo[] {
    if (!args) {
      return [];
    }

    // Single subagent:
    //
    // {
    //   agent: "qwen",
    //   task: "review..."
    // }
    if (
      typeof args.agent === "string"
    ) {
      return [
        readAgentInfo(args.agent, cwd),
      ];
    }

    // Parallel:
    //
    // {
    //   tasks: [
    //     { agent: "qwen", ... },
    //     { agent: "mimo", ... }
    //   ]
    // }
    if (Array.isArray(args.tasks)) {
      return args.tasks
        .filter(
          (task: any) =>
            typeof task?.agent === "string",
        )
        .map((task: any) =>
          readAgentInfo(task.agent, cwd),
        );
    }

    // Chain:
    //
    // {
    //   chain: [
    //     { agent: "mimo", ... },
    //     { agent: "qwen", ... }
    //   ]
    // }
    if (Array.isArray(args.chain)) {
      return args.chain
        .filter(
          (task: any) =>
            typeof task?.agent === "string",
        )
        .map((task: any) =>
          readAgentInfo(task.agent, cwd),
        );
    }

    return [];
  }

  // --------------------------------------------------
  // Main session
  // --------------------------------------------------

  pi.on(
    "session_start",
    async (_event, ctx) => {
      activeSubagents = [];
      updateStatus(ctx);
    },
  );

  pi.on(
    "model_select",
    async (_event, ctx) => {
      updateStatus(ctx);
    },
  );

  pi.on(
    "thinking_level_select",
    async (_event, ctx) => {
      updateStatus(ctx);
    },
  );

  // --------------------------------------------------
  // Orchestrator / subagent tracking
  // --------------------------------------------------

  pi.on(
    "tool_execution_start",
    async (event, ctx) => {
      if (event.toolName !== "subagent") {
        return;
      }

      activeSubagents = extractAgents(
        event.args,
        process.cwd(),
      );

      updateStatus(ctx);
    },
  );

  pi.on(
    "tool_execution_end",
    async (event, ctx) => {
      if (event.toolName !== "subagent") {
        return;
      }

      activeSubagents = [];
      updateStatus(ctx);
    },
  );

  // --------------------------------------------------
  // Manual command
  // --------------------------------------------------

  pi.registerCommand("model-status", {
    description:
      "Show parent and active subagent models",

    handler: async (_args, ctx) => {
      updateStatus(ctx);

      const parent = ctx.model
        ? `${ctx.model.provider}/${ctx.model.id}`
        : "none";

      if (activeSubagents.length === 0) {
        ctx.ui.notify(
          `Main model: ${parent}`,
          "info",
        );

        return;
      }

      const active = activeSubagents
        .map(
          (agent) =>
            `${agent.name}: ${
              agent.model ?? "unknown model"
            }`,
        )
        .join("\n");

      ctx.ui.notify(
        `Main: ${parent}\n\nActive subagent:\n${active}`,
        "info",
      );
    },
  });
}
