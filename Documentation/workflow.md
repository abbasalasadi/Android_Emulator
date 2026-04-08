# GPT Collaboration Workflow (User ↔ GPT)

This is a simple reusable workflow for how we work together on a project.

## 0) Baseline continuity across chats
- At the **start of every new chat**, GPT should explicitly state that the current batch is based on the **the name of the latest batch previously provided**.
- Throughout the chat, GPT must treat the **latest provided batch** as the active baseline, even if I have not tested it yet.
- GPT must not silently fall back to an older baseline when preparing a new batch.

## 1) Project handoff
- I share the **full project files** at the beginning.
- GPT studies the files before making changes.
- We discuss the problems and agree on priorities.

## 2) Plan first
- We create a **work plan** before patching.
- The plan is usually split into logical stages/phases (example: WS lifecycle, realtime updates, UI fixes).
- We agree what belongs to each stage before implementation.

## 3) Implementation in small batches
- GPT implements fixes in **small focused batches** (not too many unrelated changes at once).
- After each batch, I test locally and report:
  - what is fixed
  - what is still not fixed
  - any new errors / regressions

## 4) GPT should track latest file state
- GPT should always treat **latest provided batch/version** as the active baseline.
- This rule applies even if I have **not tested or explicitly accepted** that batch yet.
- GPT should keep in mind the **most recent updated files** and avoid reverting older versions.
- New patches must build on the latest patch state.
- If a newer batch exists, GPT must not prepare the next batch from any older snapshot.

## 5) Patch delivery format (important)
- GPT provides **only the updated files** (not full project files unless I ask).
- Updated files must be delivered in a **ZIP file**.
- The ZIP must preserve **paths from the project root**.

### Example
If two files changed:
- `web/js/app.core-runtime.js`
- `web/static/css/posts.css`

The zip should contain exactly:
- `web/js/app.core-runtime.js`
- `web/static/css/posts.css`

## 6) No manual edits unless requested
- By default, GPT should give me a **downloadable patch zip**.
- GPT should not ask me to manually edit code unless I explicitly ask for manual instructions.

## 7) Re-check the plan regularly
- From time to time, we review the plan and mark:
  - ✅ implemented
  - ⏳ in progress / needs retest
  - ❌ remaining
- This keeps the work organized and avoids missing audit items.

## 8) If a fix does not apply
- GPT should review the **latest version files** and check for:
  - overrides
  - alternate render paths
  - newer code replacing older code
- Then GPT should patch the correct source-of-truth files and send an updated patch zip.

## 9) Goal of this workflow
- Fast iteration
- Clear communication
- Minimal regressions
- Easy local testing
- Reliable progress tracking until all items are completed

## 10) Required baseline statement in every chat
- At the beginning of a chat, GPT should state in clear project language that: **"This batch is based on (name of the latest batch)"** after making sure that the latest batch is actually used as active baseline.
- GPT may adjust the exact wording to fit the style of the response, but the meaning must remain explicit.
