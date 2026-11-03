#!/usr/bin/perl
# herdr-zoo's status bar (mods/my-status/main.js) for spaces on another machine too. Upstream
# shows the git parts and the Folder / VS Code buttons for this computer only.
#  - git (branch, ahead/behind, Sync, branch switch) and `gh pr view` run on the space's machine
#    through herdr-core (exec's `on`), so they work on any remote machine (WSL included).
#  - Folder / VS Code: WSL machines only (WSL_MACHINES below: machine name from `hc machine ls`
#    -> distro): Explorer at \\wsl.localhost\<distro>\<path>, VS Code with --remote wsl+<distro>.
# Run by sync.sh push: perl my-status-remote.pl <main.js>. Exit 0 = nothing to do (or upstream
# changed: reported, nothing applied), 2 = patched.
# Plain string replacements (no regex) so an upstream change is reported, not half-applied.
use strict;
use warnings;

my $MARK = 'dotfiles: my-status remote';
my $file = shift or die "usage: my-status-remote.pl <my-status/main.js>\n";

open(my $in, '<:raw', $file) or die "can't read $file: $!\n";
my $s = do { local $/; <$in> };
close $in;

exit 0 if index($s, $MARK) >= 0;

# [old, new, how many times old must occur (all are replaced)]
my @edits = (
  # openFolder: a WSL target ({ distro, path }) opens through Windows' WSL paths.
  [ "function openFolder(folder, what) {\n",
    "function openFolder(folder, what) {\n"
  . "  if (folder && typeof folder === \"object\") { // $MARK\n"
  . "    const { distro, path } = folder;\n"
  . "    // /mnt/<drive>/... is a Windows drive: Explorer opens it as <DRIVE>:\\... (it refuses it through \\\\wsl.localhost).\n"
  . "    const drive = path.match(/^\\/mnt\\/([a-zA-Z])(\\/.*)?\$/);\n"
  . "    const winPath = drive\n"
  . "      ? `\${drive[1].toUpperCase()}:\${(drive[2] || \"/\").replace(/\\//g, \"\\\\\")}`\n"
  . "      : `\\\\\\\\wsl.localhost\\\\\${distro}\${path.replace(/\\//g, \"\\\\\")}`;\n"
  . "    const [cmd, args] = what === \"code\"\n"
  . "      ? [\"cmd\", [\"/c\", \"code\", \"--remote\", `wsl+\${distro}`, path]]\n"
  . "      : [\"cmd\", [\"/c\", \"start\", \"\", winPath]];\n"
  . "    exec(cmd, args).then(\n"
  . "      (r) => { if (what === \"code\" && r.code) notify({ title: \"Couldn't open VS Code\", body: (r.stderr || r.stdout).trim() || \"Is `code` on the PATH?\", level: \"error\" }); },\n"
  . "      (e) => notify({ title: `Couldn't run \${cmd}`, body: String(e), level: \"error\" }));\n"
  . "    return;\n"
  . "  }\n", 1 ],

  # The bar's folder: on another machine too (absolute paths only), with that machine alongside.
  [ "    const folder = space && !space.machine ? (focused()?.cwd || space.folder) : \"\";\n",
    "    // $MARK: the folder on whichever machine the space is on; git runs there.\n"
  . "    const machine = space?.machine ?? null;\n"
  . "    const here = space ? (focused()?.cwd || space.folder) : \"\";\n"
  . "    const folder = !machine ? here : (here && here.startsWith(\"/\") ? here : \"\");\n"
  . "    const WSL_MACHINES = { wsl: \"Ubuntu\" }; // machine -> distro, for Folder / VS Code\n"
  . "    const distro = machine && WSL_MACHINES[machine];\n"
  . "    const openAt = !machine ? folder : (distro && folder ? { distro, path: folder } : null);\n"
  . "    const openLabel = machine ? `\${distro}:\${folder}` : folder;\n", 1 ],
  [ ".tooltip(`\${what === \"code\" ? \"Open in VS Code\" : \"Open in Explorer\"}: \${folder}`)\n      .on_click(() => openFolder(folder, what));",
    ".tooltip(`\${what === \"code\" ? \"Open in VS Code\" : \"Open in Explorer\"}: \${openLabel}`)\n      .on_click(() => openFolder(openAt, what));", 1 ],
  [ ".when(Boolean(folder), el => el.child(button(\"open-folder\"",
    ".when(Boolean(openAt), el => el.child(button(\"open-folder\"", 1 ],

  # Remember the machine with the folder (and with the PR key), for the next tick's reads.
  [ "    this.folder = folder; // what readGit reads on its next tick\n",
    "    this.folder = folder; // what readGit reads on its next tick\n"
  . "    this.machine = machine;\n", 1 ],
  [ "    this.key = folder && branch ? `\${folder}|\${branch}` : null;\n",
    "    this.key = folder && branch ? `\${folder}|\${branch}` : null;\n"
  . "    this.keyOn = machine;\n", 1 ],

  # Each git/gh call captures its machine when it starts.
  [ "    const folder = this.folder;\n",
    "    const folder = this.folder, on = this.machine;\n", 1 ],
  [ "  sync(folder, cx) {\n",
    "  sync(folder, cx) {\n    const on = this.machine;\n", 1 ],
  [ "  openBranches(folder, above, cx) {\n",
    "  openBranches(folder, above, cx) {\n    const on = this.machine;\n", 1 ],
  [ "{ cwd: folder }", "{ cwd: folder, on }", 3 ],
  [ "    const key = this.key;\n",
    "    const key = this.key, on = this.keyOn;\n", 1 ],
  [ "{ cwd: key.split(\"|\")[0] }", "{ cwd: key.split(\"|\")[0], on }", 1 ],

  # The branch popup is another copy of this mod: hand it the machine, and switch there.
  [ "props: { branches, root, agentsHere, dirty },",
    "props: { branches, root, agentsHere, dirty, on },", 1 ],
  [ "const { branches, root, agentsHere, dirty, overlay } = props();",
    "const { branches, root, agentsHere, dirty, overlay, on = null } = props();", 1 ],
  [ "exec(\"git\", [\"switch\", name], { cwd: root })",
    "exec(\"git\", [\"switch\", name], { cwd: root, on })", 1 ],
);

for my $e (@edits) {
  my ($old, $new, $want) = @$e;
  my $n = () = $s =~ /\Q$old\E/g;
  if ($n != $want) {
    my $what = substr($old, 0, 60);
    $what =~ s/\n/\\n/g;
    print STDERR "my-status changed upstream: remote git / folder buttons not added (found $n of $want: $what; update patches/my-status-remote.pl)\n";
    exit 0;
  }
}
for my $e (@edits) {
  my ($old, $new) = @$e;
  my $pos = 0;
  while ((my $i = index($s, $old, $pos)) >= 0) {
    substr($s, $i, length($old)) = $new;
    $pos = $i + length($new);
  }
}

open(my $out, '>:raw', "$file.sync-tmp") or die "can't write $file.sync-tmp: $!\n";
print $out $s;
close $out;
rename("$file.sync-tmp", $file) or die "can't replace $file: $!\n";
print "added remote git and WSL folder buttons to my-status\n";
exit 2;
