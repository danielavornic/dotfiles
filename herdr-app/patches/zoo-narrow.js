    // dotfiles: zoo narrow. Below 160 px (where Spaces/Agents switch to their rail) the 122 px
    // pens get clipped, so show a column of small animals: status dot, name on hover, click to go.
    const sideW = (function f(n) { if (n?.id === "sidebar") return n.size?.px; for (const c of n?.children ?? []) { const w = f(c); if (w != null) return w; } return null; })(layout()) ?? Infinity;
    if (props()?.side && sideW < 160) return v_flex()
      .size_full()
      .min_h(0)
      .bg(t.chrome)
      .border_t(1)
      .border_color(t.border)
      .child(v_flex().id("zoo-pens").flex_1().min_h(0).py(8).items_center().gap(4).overflow_y_scrollbar()
        .children(list.map((a) => div().id(`mini-${a.address}`).relative().p(4)
          .when(a.focused, (el) => el.bg(t.selected))
          .hover((s) => s.bg(t.hover))
          .cursor_pointer()
          .tooltip(`${nameOf(a, tabs, all)}${a.space_name ? ` · ${a.space_name}` : ""}`)
          .on_click(() => run("pane.focus", { pane: a.pane }))
          .child(sprite(map[a.address], 30, STATE[a.status] ?? "work", 30))
          .when(a.status !== "idle", (el) => el.child(div().absolute().top(2).right(2).size(7).bg(t[a.status] ?? t.dim))))));
