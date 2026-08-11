# Security

## Reporting a vulnerability

**In this repository** (a recipe that leaks data, a malicious example config, a script issue): open a [private security advisory](https://github.com/GigLaboCom/lazy-shot-cookbook/security/advisories/new), or email **[lazy-shot@giglabo.com](mailto:lazy-shot@giglabo.com)**.

**In Heretic Lazy Shot itself** (the desktop app or its MCP server): email **[lazy-shot@giglabo.com](mailto:lazy-shot@giglabo.com)**. Please don't file a public issue for app vulnerabilities.

Include what you did, what happened, and what you expected. If the issue involves the MCP server, the relevant `[MCP]`-tagged excerpt from the newest log in `~/.heretic-lazy-shot/logs/` helps — with anything sensitive removed. We aim to acknowledge within three working days.

## Threat model you should know about

The cookbook drives a tool that **can see your screen**. That deserves plain language rather than reassurance.

### The MCP server has no authentication

Anything that can reach the port can capture your screen, list your screenshot library, and read text out of it. The server binds to `127.0.0.1` by default, which is the correct setting for essentially every user.

- **Do not bind it to `0.0.0.0`** unless you fully control the network, and understand that you're exposing screen capture to every host that can route to you.
- **Do not port-forward it, tunnel it, or expose it through ngrok** to give a remote agent "eyes". A remote agent can't read the returned file paths anyway — see [the design principle](./principles/FILE-PATHS-NOT-BASE64.md) — so the only thing exposure buys you is the risk.
- On a shared or multi-user machine, remember that "localhost" includes every other account on that machine.

### Captures contain whatever was on screen

Password managers, `.env` files open in your editor, a customer's data in another window, your own email. Practical hygiene:

- Capture **windows**, not whole displays, when you have the choice. `capture_window` scopes the blast radius; `capture_display` doesn't.
- Redact before sharing. Blur and Spoiler are in-app tools, and that's deliberate — redaction is a human decision. Note that light blur over text can be reversed by published attacks; Spoiler's heavy pixelation is the safe choice for anything that matters.
- Remember where the images go. A cloud agent reading a capture sends those pixels to its model provider. Local OCR (`ocr_screenshot`) does not — [recipe 05](./recipes/05-copy-the-uncopyable/) covers when to use which.
- `delete_screenshot` is a **soft** delete. The file record remains. It is not a way to destroy evidence of a leak; delete the underlying file yourself if that's what you need.

### Prompt injection reaches the screen too

If your agent captures a window whose content came from someone else — a web page, an email, a shared dashboard — text in that image can address your agent directly ("ignore previous instructions and…"). Vision does not sanitise anything. Treat captured content as untrusted input, exactly as you would a fetched web page, and don't wire screen capture into an agent loop that can act without review.

### Path restrictions are deliberate

`ocr_image_path` refuses paths outside the screenshots and app-data directories. That's a boundary, not a bug: an image tool that reads arbitrary paths is a file-exfiltration primitive for any agent that can be talked into using it. Please don't ask for it to be relaxed.

## Supported versions

This repository documents the current release of Heretic Lazy Shot. Tool surface and behaviour are verified against the version named at the top of [docs/TOOLS.md](./docs/TOOLS.md); older app versions may expose fewer tools.
