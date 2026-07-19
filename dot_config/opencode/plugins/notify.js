/**
 * Desktop notifications for OpenCode sessions.
 *
 * Fires an OS notification when a session goes idle (response finished),
 * errors, or asks for permission — so long-running tasks (UE5 builds,
 * test ladders) can be left in the background.
 *
 * Cross-platform: osascript on macOS, notify-send on Linux, no-op elsewhere.
 */

const IS_DARWIN = process.platform === "darwin"
const IS_LINUX = process.platform === "linux"

/** @type {import("@opencode-ai/plugin").Plugin} */
export const NotifyPlugin = async ({ $, directory }) => {
  // Project basename so parallel sessions are distinguishable in notifications.
  const project = (directory ?? "").split("/").filter(Boolean).pop() || "session"

  async function notify(title, body) {
    try {
      if (IS_DARWIN) {
        await $`osascript -e ${`display notification "${body.replace(/"/g, '\\"')}" with title "${title}"`}`.quiet().nothrow()
      } else if (IS_LINUX) {
        await $`notify-send ${title} ${body}`.quiet().nothrow()
      }
    } catch {
      // Notifications are best-effort.
    }
  }

  return {
    event: async ({ event }) => {
      if (event.type === "session.idle") {
        await notify("OpenCode", `${project}: response finished`)
      } else if (event.type === "session.error") {
        await notify("OpenCode", `${project}: session error — check the terminal`)
      } else if (event.type === "permission.asked") {
        await notify("OpenCode", `${project}: waiting for your approval`)
      }
    },
  }
}

export default NotifyPlugin
