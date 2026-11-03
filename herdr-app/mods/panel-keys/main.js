// Keyboard toggles for the side panel (Files / Changes), like the tab bar's buttons:
// shown with that view -> hide; otherwise switch the panel to it and show it.
// Bind in keys.json as "panel-keys.changes" / "panel-keys.files", or run() it from a mod.
// Hosted as an invisible floating block (mods only run while a layout shows them).
import { View, div } from "gpui-kit";
import { agents, layout, nextCommand, notify, run } from "herdr";

function find(node, id) {
  if (node?.id === id) return node;
  for (const child of node?.children ?? []) {
    const found = find(child, id);
    if (found) return found;
  }
  return null;
}

function toggle(view) {
  const root = layout();
  const panel = find(root, "panel");
  if (!panel) return;
  const shown = !panel.hidden && find(root, "panel-body")?.active === view;
  if (shown) return run("layout.hide", { id: "panel" });
  run("layout.select", { stack: "panel-body", child: view });
  run("layout.show", { id: "panel" });
}

// "alert": go to the agent that needs you (blocked), else the one that finished while you
// weren't looking (done); the most recent first, skipping the one already focused.
function goToAlert() {
  const all = agents().filter((a) => !a.focused);
  const pick = (status) => all.filter((a) => a.status === status).sort((a, b) => b.seq - a.seq)[0];
  const a = pick("blocked") ?? pick("done");
  if (!a) return notify({ title: "No agent alerts", level: "info", timeout: 2000 });
  run("space.select", { id: a.space });
  run("tab.select", { id: a.tab });
  run("pane.focus", { pane: a.pane });
}

export default class PanelKeys extends View {
  init(_props, cx) {
    cx.spawn(async () => {
      for (;;) {
        const command = await nextCommand();
        if (command === "changes" || command === "files") {
          try { toggle(command); } catch (e) { console.log(`panel-keys: ${e}`); }
        } else if (command === "alert") {
          try { goToAlert(); } catch (e) { console.log(`panel-keys: alert: ${e}`); }
        }
      }
    });
  }

  render() {
    return div();
  }
}
