# File paths, never base64

Every Lazy Shot MCP tool that produces or references an image returns a **`file_path`** — never inline image data. This is the single most consequential design decision in the server, and it's worth defending properly, because most screenshot MCPs do the opposite.

## The cost of an image in a context window

A base64-encoded full-resolution screenshot is hundreds of kilobytes of payload. Push that through a tool response and three things happen:

1. **You pay for it whether or not the model needed to look.** Most screenshot operations are bookkeeping — capture, name, file, move on. Vision was never required; the tokens are spent anyway.
2. **It crowds out the actual work.** Agent sessions die of context exhaustion. A handful of inlined screenshots can displace the code, the plan, and the conversation history the agent needed more.
3. **It compounds.** A 20-step navigation session with inline captures is 20 payloads in history. The same session with file paths is 20 short strings.

A file path costs about twenty tokens. The agent that *does* need pixels reads the file at that moment, in that turn — and the image doesn't haunt the rest of the session.

## Deciding when to look is the agent's job

Returning a reference instead of pixels moves the "should I actually look at this?" decision to the agent, where it belongs. Capture-and-file workflows never pay the vision tax. Inspection workflows pay it exactly once, at read time, at whatever resolution the agent's file tools apply.

There's a second exit that only exists because of this design: **`ocr_screenshot`**. When the agent needs the *text* rather than the *picture*, it gets a few hundred tokens of transcript from local Tesseract instead of a megapixel image — no vision call, no pixels leaving the machine. An inline-image server can't offer that choice, because it already made it for you at capture time.

## References beat blobs for everything downstream

- **Logging.** Every MCP operation lands in the app log as a compact `[MCP] TOOL_CALL … params={…}` line carrying paths — greppable, diffable, exportable. Try that with base64.
- **Reproducibility.** A path names a stable artifact in the library, keyworded and searchable, weeks later. An inline blob evaporates with the session.
- **Interop.** The same path feeds your issue tracker, your docs pipeline, your `git add`. It's already a file; nothing needs decoding.

## When base64 *is* right

Honesty clause. Inline images are the correct design when the consumer is **remote** — a cloud runner with no filesystem access to your machine — or when the whole point is one-shot vision QA with no persistence (Peekaboo's territory on macOS, and it does that well). Lazy Shot chooses the other end of the trade: local-first agents, a persistent library, a localhost server. If your agent can't read local files, this server isn't for it — by design, not by omission.

## A checklist for MCP authors shipping images

- [ ] Default to references (paths, IDs, URLs) in tool responses; make inline data opt-in per call, if you offer it at all.
- [ ] Give references stable, human-recallable names — we use agent-assigned keywords with collision auto-suffixing.
- [ ] Offer a cheap textual path out (OCR, extracted structure) so vision is a choice, not a toll.
- [ ] Never mutate an artifact a previous response referenced; fork instead (our markers create copies).
- [ ] Constrain any path the caller supplies to directories you own — an image tool that reads arbitrary paths is an exfiltration primitive.
- [ ] Log every operation with the reference, not the payload.
- [ ] State your locality contract loudly in the docs: localhost-only servers should say so on the first screen.
- [ ] Return errors as structured contracts, not prose — agents branch on structure.

---

*This is how [Heretic Lazy Shot](https://giglabo.com/heretic/applications/heretic-lazy-shot)'s 23-tool MCP server is built. The [cookbook recipes](../README.md#recipes) show the payoff in practice.*
