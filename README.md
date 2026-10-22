# edge-warp

**Move the mouse freely between side-by-side screens of different heights on macOS.**

macOS only lets the pointer cross between two screens where their edges overlap. Put a tall portrait monitor next to a MacBook, or a big screen next to a small one, and the pointer hits an invisible wall along part of the edge. You have to aim for the exact strip where the screens line up. edge-warp removes that wall: push against the edge anywhere, and the pointer jumps onto the next screen at the nearest height.

## Why it matters

- **Mixed setups are normal now:** a laptop plus a portrait monitor, a 27" next to a 24", a portable USB screen next to the MacBook. Their edges almost never line up.
- **The "dead zone" breaks your flow.** You push the mouse sideways, nothing happens, and you have to move up or down to find the gap. Many times a day.
- **Rearranging the screens doesn't fix it.** In System Settings → Displays you can slide a screen up or down, but a tall screen next to a short one always leaves part of the edge blocked.

## How it works

- A **listen-only** event tap watches mouse moves and drags. It never changes, delays or blocks your events.
- When the pointer pushes left or right against a screen edge, and another screen touches that edge but not at the pointer's height, edge-warp moves the pointer onto that screen. The height is clamped to the nearest point on it.
- Inside the overlapping part of the edge, macOS does its normal thing and edge-warp stays out of the way.
- It never moves or rearranges your screens.
- Tiny and quiet: about 50 lines of Swift, with no menu-bar icon and no window. It uses no CPU while the mouse is still.

## Install

Requires macOS and the Xcode Command Line Tools (`xcode-select --install`).

```bash
git clone https://github.com/nvark1996/edge-warp.git
cd edge-warp
./install.sh
```

This builds the helper into `~/.local/bin/edge-warp` and adds a LaunchAgent so it starts at every login and restarts if it ever stops. If macOS asks for **Accessibility** or **Input Monitoring** permission, allow it for `edge-warp`.

**Uninstall:**

```bash
./install.sh --uninstall
```

**Check it's working:** each warp is written to `~/Library/Logs/edge-warp.log`.

```bash
tail -f ~/Library/Logs/edge-warp.log
```

## Limits

- Left and right edges only, for screens placed side by side. Screens stacked above and below each other aren't handled.
- If two screens touch the same edge, the first one found is used.

## License

MIT. See [LICENSE](LICENSE).
