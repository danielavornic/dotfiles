import { View, div } from "gpui-kit";
import { v_flex, h_flex } from "gpui-base";
import { appHome, closeOverlay, focused, hc, nextCommand, notify, props, readTextFile, run, setShared, shared, spaces, theme, writeTextFile } from "herdr";

// Edit these two things to make the example yours. Only repeatable actions
// start a timer: the first key after Ctrl+B can take as long as you like.
// 0 = no repeat: the popup only shows between the prefix and the next key, which
// closes it and runs at once. Set e.g. 300 to bring back tmux-style repeat (h/j/k/l…).
const REPEAT_MS = 0;
// Keys follow Dan's herdr TUI config (WSL ~/.config/herdr/config.toml): herdr's
// default prefix keys plus their overrides (q close pane, ctrl+n/p spaces,
// shift+1..9 spaces). Keys: a plain character ("c", "N", "-"), an arrow name,
// "ctrl+<key>" or "shift+<digit>".
const TOGGLE = "toggle-prefix";
const PREFIX_KEY = "tmux-prefix:prefix";
const OUR_BINDINGS = /"ctrl-([bs])": "(mod\.open:tmux-prefix|tmux-prefix\.send-prefix)"/g;
const keysPath = () => `${appHome()}/keys.json`;
const currentPrefix = (text) => text.match(/"ctrl-([bs])": "mod\.open:tmux-prefix"/)?.[1] ?? null;
// Last view: each time the prefix opens it records where you are (space, tab, pane);
// "last view" jumps to the most recent recorded place that isn't here. Moves made with
// the mouse between two prefix presses still count: the next press records the new spot.
const LAST = "last-view";
const VIEWS_KEY = "tmux-prefix:views";
const sameView = (a, b) => !!a && !!b && a.space === b.space && a.tab === b.tab && a.pane === b.pane;
function findView(v) {
  const space = v && spaces().find((s) => s.id === v.space);
  const tab = space?.tabs.find((t) => t.id === v.tab);
  return tab ? { space, tab } : null;
}
function recordView() {
  const f = focused();
  const now = f && { space: f.space, tab: f.tab, pane: f.pane };
  let views = Array.isArray(shared(VIEWS_KEY)) ? shared(VIEWS_KEY).filter(findView) : [];
  if (now && !sameView(views.at(-1), now)) {
    views = [...views, now].slice(-8);
    setShared(VIEWS_KEY, views);
  }
  return [...views].reverse().find((v) => !sameView(v, now)) ?? null;
}
const BINDINGS = [
  ["tab", "Last view", LAST],
  [";", "Last view", LAST],
  // Spaces
  ["N", "New space", "space.new"],
  ["ctrl+n", "Next space", "space.next", {}, true],
  ["ctrl+p", "Previous space", "space.prev", {}, true],
  ["W", "Rename space", "space.rename"],
  ["D", "Close space", "space.close"],
  ["w", "Space picker", "mod.open", { name: "picker" }],
  ["G", "New worktree", "mod.open", { name: "worktree" }],
  // Git: lazygit in the focused terminal's folder, on the space's machine
  ["g", "Lazygit (new tab)", "terminal.open", { argv: ["lazygit"], name: "lazygit" }],
  ["ctrl+g", "Lazygit (split right)", "terminal.open", { argv: ["lazygit"], place: "right" }],
  // Side panel toggles (panel-keys mod, also Ctrl+Shift+G for Changes)
  ["C", "Toggle Changes", "panel-keys.changes"],
  ["f", "Toggle Files", "panel-keys.files"],
  // Agents (panel-keys mod, also Ctrl+Shift+A)
  ["a", "Go to agent alert", "panel-keys.alert"],
  // Tabs
  ["c", "New tab", "tab.new"],
  ["n", "Next tab", "tab.next"],
  ["p", "Previous tab", "tab.prev"],
  ["T", "Rename tab", "tab.rename"],
  ["X", "Close tab", "tab.close"],
  // Panes
  ["v", "Split right", "pane.split", { direction: "right" }],
  ["-", "Split down", "pane.split", { direction: "down" }],
  ["q", "Close pane", "pane.close"],
  ["x", "Close pane", "pane.close"],
  ["z", "Zoom pane", "pane.zoom"],
  ["h", "Focus left", "pane.go", { direction: "left" }, true],
  ["j", "Focus down", "pane.go", { direction: "down" }, true],
  ["k", "Search spaces, panes, agents", "mod.open", { name: "picker" }], // Focus up: prefix + up arrow
  ["l", "Focus right", "pane.go", { direction: "right" }, true],
  ["H", "Swap left", "pane.swap", { direction: "left" }, true],
  ["J", "Swap down", "pane.swap", { direction: "down" }, true],
  ["K", "Swap up", "pane.swap", { direction: "up" }, true],
  ["L", "Swap right", "pane.swap", { direction: "right" }, true],
  ["left", "Focus left", "pane.go", { direction: "left" }, true],
  ["down", "Focus down", "pane.go", { direction: "down" }, true],
  ["up", "Focus up", "pane.go", { direction: "up" }, true],
  ["right", "Focus right", "pane.go", { direction: "right" }, true],
  // Window
  ["b", "Toggle sidebar", "layout.toggle", { id: "sidebar" }],
  ["s", "Settings", "app.settings"],
  ["d", "Minimize window", "window.minimize"],
  ["0", "Switch prefix Ctrl+B ⇄ Ctrl+S", TOGGLE],
  ...Array.from({ length: 9 }, (_, i) => [String(i + 1), `Tab ${i + 1}`, "tab.select", { index: i + 1 }]),
  ...Array.from({ length: 9 }, (_, i) => [`shift+${i + 1}`, `Space ${i + 1}`, "space.select", { index: i + 1 }]),
];
const SHIFTED_DIGITS = { "!": "1", "@": "2", '"': "2", "#": "3", "£": "3", "$": "4", "%": "5", "^": "6", "&": "7", "*": "8", "(": "9" };
const keyLabel = (key) => key.startsWith("ctrl+") ? `^${key.slice(5).toUpperCase()}`
  : key.startsWith("shift+") ? `⇧${key.slice(6)}`
  : /^[A-Z]$/.test(key) ? `⇧${key}` : key;
const HIDDEN = (key) => ["left", "right", "up", "down"].includes(key) || /^(shift\+)?[1-9]$/.test(key);

function forwardKey(e, key) {
  if (["enter", "tab", "backspace", "left", "right", "up", "down", "space"].includes(e.key)) return e.key;
  if (key === " ") return "space";
  if (/^[A-Z]$/.test(key)) return `shift+${key.toLowerCase()}`;
  if (key.length === 1 && "abcdefghijklmnopqrstuvwxyz0123456789`\\[],=-.';/".includes(key)) return key === "\\" ? "backslash" : key;
  return null;
}

export default class TmuxPrefix extends View {
  init(_props, cx) {
    this.handle = cx.focus_handle();
    this.handle.focus();
    this.repeat = false;
    this.generation = 0;
    this.all = false;
    this.prefix = shared(PREFIX_KEY) === "s" ? "s" : "b";
    this.switching = false;
    this.lastView = recordView();
    // keys.json is the truth for which prefix is live (it may have been edited by hand).
    cx.spawn(async (cx) => {
      const text = await readTextFile(keysPath());
      const live = text && currentPrefix(text);
      if (live && live !== this.prefix) { this.prefix = live; setShared(PREFIX_KEY, live); cx.notify(); }
    });
    // The mod-specific key binding beats the global opener while we're open.
    cx.spawn(async (cx) => {
      for (;;) {
        await nextCommand();
        this.sendPrefix(cx);
      }
    });
  }

  dismiss() {
    closeOverlay(props().overlay);
  }

  send(key, cx) {
    this.generation++;
    const terminal = focused()?.terminal;
    if (!terminal) return this.dismiss();
    // hc starts its subprocess at the call, before closing cancels this view's tasks.
    const pending = hc(["keys", terminal, key]);
    cx.spawn(async () => {
      const result = await pending;
      if (result.code !== 0) console.log(`tmux-prefix: ${result.stderr}`);
    });
    this.dismiss();
  }

  sendPrefix(cx) {
    this.send(`ctrl+${this.prefix}`, cx);
  }

  // Ctrl+B <-> Ctrl+S: rewrites only this mod's three bindings in keys.json.
  togglePrefix(cx) {
    if (this.switching) return;
    this.switching = true;
    this.generation++;
    cx.notify();
    cx.spawn(async () => {
      try {
        const path = keysPath();
        const text = await readTextFile(path);
        const from = text && currentPrefix(text);
        if (!from) throw new Error("no tmux-prefix bindings found in keys.json");
        const to = from === "b" ? "s" : "b";
        const others = text.replace(OUR_BINDINGS, "");
        if (others.includes(`"ctrl-${to}":`)) throw new Error(`Ctrl+${to.toUpperCase()} is already bound in keys.json`);
        await writeTextFile(path, text.replace(OUR_BINDINGS, (_, _k, action) => `"ctrl-${to}": "${action}"`), text);
        this.prefix = to;
        setShared(PREFIX_KEY, to);
        notify({ title: `Prefix is now Ctrl+${to.toUpperCase()}`, level: "success", timeout: 3000 });
      } catch (err) {
        notify({ title: "Couldn't switch prefix", body: String(err?.message ?? err), level: "error" });
      }
      this.dismiss();
    });
  }

  goLastView() {
    this.dismiss();
    const v = this.lastView;
    const found = findView(v);
    if (!found) return notify({ title: "No last view yet", body: "Move somewhere else first, then come back with the prefix.", level: "info", timeout: 3000 });
    try {
      run("space.select", { id: v.space });
      run("tab.select", { id: v.tab });
      if (v.pane) run("pane.focus", { pane: v.pane });
    } catch (err) {
      console.log(`tmux-prefix: last view: ${err?.message ?? err}`);
    }
  }

  lastViewLabel() {
    const found = findView(this.lastView);
    return found ? `Last view · ${found.space.name} › ${found.tab.name}` : "Last view · none yet";
  }

  key(e, cx) {
    cx.stop_propagation();
    const m = e.modifiers;
    if (e.key === "escape") return this.dismiss();
    if (this.switching) return;
    if (m.control && e.key === this.prefix) return this.sendPrefix(cx);
    const plain = !m.control && !m.alt && !m.platform;
    let key = plain && e.key === "tab" ? (m.shift ? "shift-tab" : "tab") : plain ? (e.key_char ?? (m.shift && e.key.length === 1 ? e.key.toUpperCase() : e.key)) : e.key;
    // Shift+digit, whether the key reports the digit or its US/UK symbol.
    const digit = plain && m.shift && (/^\d$/.test(e.key) ? e.key : SHIFTED_DIGITS[key]);
    const combo = digit ? `shift+${digit}`
      : m.control && !m.alt && !m.platform && !m.shift ? `ctrl+${e.key}`
      : plain ? key : null;
    if (plain && key === "?") {
      this.all = !this.all;
      this.repeat = false;
      this.generation++;
      cx.notify();
      return;
    }
    const binding = combo && BINDINGS.find((b) => b[0] === combo);
    if (!binding) {
      const forwarded = this.repeat && plain && forwardKey(e, key);
      if (forwarded) return this.send(forwarded, cx);
      return this.dismiss();
    }
    const [, , command, args = {}, wantsRepeat = false] = binding;
    const repeatable = wantsRepeat && REPEAT_MS > 0;
    if (command === TOGGLE) return this.togglePrefix(cx);
    if (command === LAST) return this.goLastView();
    if (!repeatable) this.dismiss();
    run(command, args);
    if (repeatable) {
      this.repeat = true;
      const generation = ++this.generation;
      cx.timer.after(REPEAT_MS, () => {
        if (this.generation === generation) this.dismiss();
      });
      cx.notify();
    }
  }

  render() {
    const t = theme();
    const rows = this.all ? BINDINGS : BINDINGS.filter(([key]) => !HIDDEN(key));
    return v_flex().id("tmux-prefix").track_focus(this.handle)
      .on_key_down((e, cx) => this.key(e, cx))
      .p(14).gap(8).bg(t.popover).text_color(t.foreground).text_size(12)
      .child(h_flex().justify_between().child(div().font_semibold().child(this.switching ? "Switching prefix…" : this.repeat ? `Repeat · ${REPEAT_MS} ms` : `Ctrl+${this.prefix.toUpperCase()} · waiting for a key`))
        .child(div().text_color(t.muted).child(`Esc cancel · ^${this.prefix.toUpperCase()} send prefix`)))
      .child(v_flex().h(280).min_h(0).overflow_y_scrollbar().children(rows.map(([key, label, command, , repeatable]) =>
        h_flex().h(20).flex_none().items_center().gap(12).child(div().w(48).text_color(t.accent).child(keyLabel(key)))
          .child(div().flex_1().child(command === LAST ? this.lastViewLabel() : label)).child(div().text_color(t.dim).child(repeatable && REPEAT_MS > 0 ? "repeat" : "")))))
      .child(div().text_color(t.muted).child("1–9 tabs · ⇧1–9 spaces · arrows focus · ? all bindings"));
  }
}
