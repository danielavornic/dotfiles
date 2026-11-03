#!/usr/bin/perl
# Folder / VS Code buttons in herdr-zoo's status bar (mods/my-status/main.js) for spaces on a
# WSL machine too: Explorer at \\wsl.localhost\<distro>\<path>, VS Code with --remote wsl+<distro>.
# Upstream shows them for this computer only. Run by sync.sh push: perl wsl-folder.pl <main.js>
# Machines are mapped to distros in WSL_MACHINES below (machine name from `hc machine ls`).
# Plain string replacements (no regex) so an upstream change is reported, not half-applied.
use strict;
use warnings;

my $MARK = 'dotfiles: wsl folder';
my $file = shift or die "usage: wsl-folder.pl <my-status/main.js>\n";

open(my $in, '<:raw', $file) or die "can't read $file: $!\n";
local $/;
my $s = <$in>;
close $in;

if (index($s, $MARK) >= 0) { exit 0; }

my @edits = (
  # 1. openFolder: a WSL target ({ distro, path }) opens through Windows' WSL paths.
  [ "function openFolder(folder, what) {\n",
    "function openFolder(folder, what) {\n"
  . "  if (folder && typeof folder === \"object\") { // $MARK\n"
  . "    const { distro, path } = folder;\n"
  . "    const [cmd, args] = what === \"code\"\n"
  . "      ? [\"cmd\", [\"/c\", \"code\", \"--remote\", `wsl+\${distro}`, path]]\n"
  . "      : [\"cmd\", [\"/c\", \"start\", \"\", `\\\\\\\\wsl.localhost\\\\\${distro}\${path.replace(/\\//g, \"\\\\\")}`]];\n"
  . "    exec(cmd, args).then(\n"
  . "      (r) => { if (what === \"code\" && r.code) notify({ title: \"Couldn't open VS Code\", body: (r.stderr || r.stdout).trim() || \"Is `code` on the PATH?\", level: \"error\" }); },\n"
  . "      (e) => notify({ title: `Couldn't run \${cmd}`, body: String(e), level: \"error\" }));\n"
  . "    return;\n"
  . "  }\n" ],
  # 2. Where the buttons open: this computer's folder, else the WSL machine's (absolute paths only).
  [ "    const folder = space && !space.machine ? (focused()?.cwd || space.folder) : \"\";\n",
    "    const folder = space && !space.machine ? (focused()?.cwd || space.folder) : \"\";\n"
  . "    const WSL_MACHINES = { wsl: \"Ubuntu\" }; // $MARK: machine -> distro\n"
  . "    const distro = space?.machine && WSL_MACHINES[space.machine];\n"
  . "    const remote = distro ? (focused()?.cwd || space.folder) : \"\";\n"
  . "    const openAt = folder || (remote && remote.startsWith(\"/\") ? { distro, path: remote } : null);\n"
  . "    const openLabel = typeof openAt === \"object\" && openAt ? `\${openAt.distro}:\${openAt.path}` : folder;\n" ],
  [ ".tooltip(`\${what === \"code\" ? \"Open in VS Code\" : \"Open in Explorer\"}: \${folder}`)\n      .on_click(() => openFolder(folder, what));",
    ".tooltip(`\${what === \"code\" ? \"Open in VS Code\" : \"Open in Explorer\"}: \${openLabel}`)\n      .on_click(() => openFolder(openAt, what));" ],
  [ ".when(Boolean(folder), el => el.child(button(\"open-folder\"",
    ".when(Boolean(openAt), el => el.child(button(\"open-folder\"" ],
);

for my $e (@edits) {
  my ($old, $new) = @$e;
  my $n = () = $s =~ /\Q$old\E/g;
  if ($n != 1) {
    print STDERR "my-status changed upstream: WSL folder buttons not added (update patches/wsl-folder.pl)\n";
    exit 0;
  }
}
for my $e (@edits) {
  my ($old, $new) = @$e;
  my $i = index($s, $old);
  substr($s, $i, length($old)) = $new;
}

open(my $out, '>:raw', "$file.sync-tmp") or die "can't write $file.sync-tmp: $!\n";
print $out $s;
close $out;
rename("$file.sync-tmp", $file) or die "can't replace $file: $!\n";
print "added WSL folder buttons to my-status\n";
exit 2;  # 2 = changed (sync.sh then runs herdr-app check)
