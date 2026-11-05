#!/usr/bin/perl
# herdr-zoo's status bar (mods/my-status/main.js) for spaces on another machine too. Upstream
# shows the git item and the Folder / VS Code buttons for this computer only.
#  - git (branch, ahead/behind, Sync, branch page, new branch) and `gh pr view` run on the space's
#    machine through herdr-core: `exec` is wrapped so a call whose cwd is a /posix path while the
#    bar's space is remote gets `on: <machine>`. Paths starting with "/" stay posix in resolvePath
#    and inside (upstream turns every path into a Windows one on Windows).
#  - Folder / VS Code: WSL machines only (WSL_MACHINES: machine name from `hc machine ls` -> distro):
#    Explorer at \\wsl.localhost\<distro>\<path> (or <DRIVE>:\... for /mnt/<drive>), VS Code with
#    --remote wsl+<distro>.
#  - Dev container repos stay this-computer-only, as upstream.
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
  # The host's exec, wrapped below.
  [ "setShared, exec, notify,", "setShared, exec as hostExec, notify,", 1 ],
  [ "const SHOWN = \"status.shownRepo\";\n",
    "const SHOWN = \"status.shownRepo\";\n"
  . "\n"
  . "// $MARK: the machine the bar's space is on (null: this computer). Set by the bar's render;\n"
  . "// a repo page popup gets it in props.on. A command run in a /posix folder while it is set runs\n"
  . "// there, through herdr-core.\n"
  . "let REMOTE = null;\n"
  . "function exec(cmd, args, opts) {\n"
  . "  const there = REMOTE && typeof opts?.cwd === \"string\" && opts.cwd.startsWith(\"/\");\n"
  . "  return hostExec(cmd, args, there ? { ...opts, on: REMOTE } : opts);\n"
  . "}\n", 1 ],

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

  # Posix paths (another machine's) stay posix.
  [ "  return WIN ? parts.join(\"\\\\\") : \"/\" + parts.join(\"/\");\n",
    "  return WIN && !String(p).startsWith(\"/\") ? parts.join(\"\\\\\") : \"/\" + parts.join(\"/\"); // $MARK: posix stays posix\n", 1 ],
  [ "return c === p || c.startsWith(p + (WIN ? \"\\\\\" : \"/\"));",
    "return c === p || c.startsWith(p + (WIN && !p.startsWith(\"/\") ? \"\\\\\" : \"/\"));", 1 ],

  # A repo page popup runs its git on the machine it was opened for.
  [ "    const p = props() ?? {};\n",
    "    const p = props() ?? {};\n"
  . "    if (p.repo || p.repos) REMOTE = p.on ?? null; // $MARK\n", 1 ],
  [ "}, back, anchor },", "}, back, anchor, on: REMOTE },", 1 ],

  # The bar's folder: on another machine too (absolute paths only).
  [ "    const folder = space && !space.machine ? (focused()?.cwd || space.folder) : \"\";\n",
    "    // $MARK: the folder on whichever machine the space is on; git runs there.\n"
  . "    const machine = space?.machine ?? null;\n"
  . "    REMOTE = machine;\n"
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
