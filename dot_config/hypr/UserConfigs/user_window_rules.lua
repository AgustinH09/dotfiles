-- ==================================================
--  KoolDots (2026)
--  Project URL: https://github.com/LinuxBeginnings
--  License: GNU GPLv3
--  SPDX-License-Identifier: GPL-3.0-or-later
-- ==================================================

-- User window rule overrides (auto-generated).
-- Add your own rules with apply_window_rule({...})
-- Example:
-- apply_window_rule({
--   name = "My Float Rule",
--   match = { class = "^pavucontrol$" },
--   float = true,
--   center = true,
-- })

local user_window_rules_helper = nil
do
  local source = (debug.getinfo(1, "S") or {}).source or ""
  local source_path = source:match("^@(.+)$")
  local source_dir = source_path and source_path:match("^(.*)/[^/]+$") or nil
  local home = os.getenv("HOME") or ""
  local candidate_paths = {
    source_dir and (source_dir .. "/../lua/user_window_rules_helper.lua") or nil,
    home ~= "" and (home .. "/.config/hypr/lua/user_window_rules_helper.lua") or nil,
    home ~= "" and (home .. "/.config/hypr/user_window_rules_helper.lua") or nil,
  }

  local tried_paths = {}
  for _, helper_path in ipairs(candidate_paths) do
    if helper_path then
      table.insert(tried_paths, helper_path)
      local f = io.open(helper_path, "r")
      if f then
        f:close()
        local loaded_ok, loaded_helpers = pcall(dofile, helper_path)
        if loaded_ok and type(loaded_helpers) == "table" and loaded_helpers.apply_window_rule then
          user_window_rules_helper = loaded_helpers
          break
        end
      end
    end
  end

  if not user_window_rules_helper then
    error("Failed to load user_window_rules_helper.lua from: " .. table.concat(tried_paths, ", "))
  end
end
local apply_window_rule = user_window_rules_helper.apply_window_rule

-- Converted from WindowRules.conf
apply_window_rule({
  name = "user-window-windowrule-001",
  match = {
    class = "^([Ff]irefox|org.mozilla.firefox|[Ff]irefox-esr|[Ff]irefox-bin)$",
  },
  tag = "+browser",
})

apply_window_rule({
  name = "user-window-windowrule-002",
  match = {
    class = "^([Gg]oogle-chrome(-beta|-dev|-unstable)?)$",
  },
  tag = "+browser",
})

apply_window_rule({
  name = "user-window-windowrule-003",
  match = {
    class = "^(chrome-.+-Default)$",
  },
  tag = "+browser",
})

apply_window_rule({
  name = "user-window-windowrule-004",
  match = {
    class = "^([Cc]hromium)$",
  },
  tag = "+browser",
})

apply_window_rule({
  name = "user-window-windowrule-005",
  match = {
    class = "^([Mm]icrosoft-edge(-stable|-beta|-dev|-unstable))$",
  },
  tag = "+browser",
})

apply_window_rule({
  name = "user-window-windowrule-006",
  match = {
    class = "^(?i)brave-browser(-beta|-dev|-unstable)?$",
  },
  tag = "+browser",
})

apply_window_rule({
  name = "user-window-windowrule-007",
  match = {
    class = "^(brave-.+-Default)$",
  },
  tag = "+browser",
})

apply_window_rule({
  name = "user-window-windowrule-008",
  match = {
    class = "^([Tt]horium-browser|[Cc]achy-browser)$",
  },
  tag = "+browser",
})

apply_window_rule({
  name = "user-window-windowrule-009",
  match = {
    class = "^(zen-alpha|zen)$",
  },
  tag = "+browser",
})

apply_window_rule({
  name = "user-window-windowrule-010",
  match = {
    class = "^(swaync-control-center|swaync-notification-window|swaync-client|class)$",
  },
  tag = "+notif",
})

apply_window_rule({
  name = "user-window-windowrule-011",
  match = {
    title = "^(KooL Quick Cheat Sheet)$",
  },
  tag = "+KooL_Cheat",
})

apply_window_rule({
  name = "user-window-windowrule-012",
  match = {
    title = "^(KooL Hyprland Settings)$",
  },
  tag = "+KooL_Settings",
})

apply_window_rule({
  name = "user-window-windowrule-013",
  match = {
    class = "^(nwg-displays|nwg-look)$",
  },
  tag = "+KooL-Settings",
})

apply_window_rule({
  name = "user-window-windowrule-014",
  match = {
    class = "^(Alacritty|kitty|kitty-dropterm)$",
  },
  tag = "+terminal",
})

apply_window_rule({
  name = "user-window-windowrule-015",
  match = {
    class = "^([Tt]hunderbird|org.gnome.Evolution)$",
  },
  tag = "+email",
})

apply_window_rule({
  name = "user-window-windowrule-016",
  match = {
    class = "^(eu.betterbird.Betterbird)$",
  },
  tag = "+email",
})

apply_window_rule({
  name = "user-window-windowrule-017",
  match = {
    class = "^(codium|codium-url-handler|VSCodium)$",
  },
  tag = "+projects",
})

apply_window_rule({
  name = "user-window-windowrule-018",
  match = {
    class = "^(VSCode|code-url-handler)$",
  },
  tag = "+projects",
})

apply_window_rule({
  name = "user-window-windowrule-019",
  match = {
    class = "^(jetbrains-.+)$",
  },
  tag = "+projects",
})

apply_window_rule({
  name = "user-window-windowrule-020",
  match = {
    class = "^(com.obsproject.Studio)$",
  },
  tag = "+screenshare",
})

apply_window_rule({
  name = "user-window-windowrule-021",
  match = {
    class = "^([Dd]iscord|[Ww]ebCord|[Vv]esktop)$",
  },
  tag = "+im",
})

apply_window_rule({
  name = "user-window-windowrule-022",
  match = {
    class = "^([Ff]erdium)$",
  },
  tag = "+im",
})

apply_window_rule({
  name = "user-window-windowrule-023",
  match = {
    class = "^([Ww]hatsapp-for-linux)$",
  },
  tag = "+im",
})

apply_window_rule({
  name = "user-window-windowrule-024",
  match = {
    class = "^(ZapZap|com.rtosta.zapzap)$",
  },
  tag = "+im",
})

apply_window_rule({
  name = "user-window-windowrule-025",
  match = {
    class = "^(org.telegram.desktop|io.github.tdesktop_x64.TDesktop)$",
  },
  tag = "+im",
})

apply_window_rule({
  name = "user-window-windowrule-026",
  match = {
    class = "^(teams-for-linux)$",
  },
  tag = "+im",
})

apply_window_rule({
  name = "user-window-windowrule-027",
  match = {
    class = "^(gamescope)$",
  },
  tag = "+games",
})

apply_window_rule({
  name = "user-window-windowrule-028",
  match = {
    class = "^(steam_app_\\d+)$",
  },
  tag = "+games",
})

apply_window_rule({
  name = "user-window-windowrule-029",
  match = {
    class = "^([Ss]team)$",
  },
  tag = "+gamestore",
})

apply_window_rule({
  name = "user-window-windowrule-030",
  match = {
    title = "^([Ll]utris)$",
  },
  tag = "+gamestore",
})

apply_window_rule({
  name = "user-window-windowrule-031",
  match = {
    class = "^(com.heroicgameslauncher.hgl)$",
  },
  tag = "+gamestore",
})

apply_window_rule({
  name = "user-window-windowrule-032",
  match = {
    class = "^([Tt]hunar|org.gnome.Nautilus|[Pp]cmanfm-qt)$",
  },
  tag = "+file-manager",
})

apply_window_rule({
  name = "user-window-windowrule-033",
  match = {
    class = "^(app.drey.Warp)$",
  },
  tag = "+file-manager",
})

apply_window_rule({
  name = "user-window-windowrule-034",
  match = {
    class = "^([Ww]aytrogen)$",
  },
  tag = "+wallpaper",
})

apply_window_rule({
  name = "user-window-windowrule-035",
  match = {
    class = "^([Aa]udacious)$",
  },
  tag = "+multimedia",
})

apply_window_rule({
  name = "user-window-windowrule-036",
  match = {
    class = "^([Mm]pv|vlc)$",
  },
  tag = "+multimedia_video",
})

apply_window_rule({
  name = "user-window-windowrule-037",
  match = {
    title = "^(ROG Control)$",
  },
  tag = "+settings",
})

apply_window_rule({
  name = "user-window-windowrule-038",
  match = {
    class = "^(wihotspot(-gui)?)$",
  },
  tag = "+settings",
})

apply_window_rule({
  name = "user-window-windowrule-039",
  match = {
    class = "^([Bb]aobab|org.gnome.[Bb]aobab)$",
  },
  tag = "+settings",
})

apply_window_rule({
  name = "user-window-windowrule-040",
  match = {
    class = "^(gnome-disks|wihotspot(-gui)?)$",
  },
  tag = "+settings",
})

apply_window_rule({
  name = "user-window-windowrule-041",
  match = {
    title = "(Kvantum Manager)",
  },
  tag = "+settings",
})

apply_window_rule({
  name = "user-window-windowrule-042",
  match = {
    class = "^(file-roller|org.gnome.FileRoller)$",
  },
  tag = "+settings",
})

apply_window_rule({
  name = "user-window-windowrule-043",
  match = {
    class = "^(nm-applet|nm-connection-editor|blueman-manager)$",
  },
  tag = "+settings",
})

apply_window_rule({
  name = "user-window-windowrule-044",
  match = {
    class = "^(pavucontrol|org.pulseaudio.pavucontrol|com.saivert.pwvucontrol)$",
  },
  tag = "+settings",
})

apply_window_rule({
  name = "user-window-windowrule-045",
  match = {
    class = "^(qt5ct|qt6ct|[Yy]ad)$",
  },
  tag = "+settings",
})

apply_window_rule({
  name = "user-window-windowrule-046",
  match = {
    class = "(xdg-desktop-portal-gtk)",
  },
  tag = "+settings",
})

apply_window_rule({
  name = "user-window-windowrule-047",
  match = {
    class = "^(org.kde.polkit-kde-authentication-agent-1)$",
  },
  tag = "+settings",
})

apply_window_rule({
  name = "user-window-windowrule-048",
  match = {
    class = "^([Rr]ofi)$",
  },
  tag = "+settings",
})

apply_window_rule({
  name = "user-window-windowrule-049",
  match = {
    class = "^(gnome-system-monitor|org.gnome.SystemMonitor|io.missioncenter.MissionCenter)$",
  },
  tag = "+viewer",
})

apply_window_rule({
  name = "user-window-windowrule-050",
  match = {
    class = "^(evince)$",
  },
  tag = "+viewer",
})

apply_window_rule({
  name = "user-window-windowrule-051",
  match = {
    class = "^(eog|org.gnome.Loupe)$",
  },
  tag = "+viewer",
})

apply_window_rule({
  name = "user-window-windowrule-052",
  match = {
    tag = "multimedia_video*",
  },
  no_blur = true,
})

apply_window_rule({
  name = "user-window-windowrule-053",
  match = {
    tag = "multimedia_video*",
  },
  opacity = 1.0,
})

apply_window_rule({
  name = "user-window-windowrule-054",
  match = {
    tag = "KooL_Cheat*",
  },
  center = true,
})

apply_window_rule({
  name = "user-window-windowrule-055",
  match = {
    class = "([Tt]hunar)",
    title = "negative:(.*[Tt]hunar.*)",
  },
  center = true,
})

apply_window_rule({
  name = "user-window-windowrule-056",
  match = {
    title = "^(ROG Control)$",
  },
  center = true,
})

apply_window_rule({
  name = "user-window-windowrule-057",
  match = {
    tag = "KooL-Settings*",
  },
  center = true,
})

apply_window_rule({
  name = "user-window-windowrule-058",
  match = {
    title = "^(Keybindings)$",
  },
  center = true,
})

apply_window_rule({
  name = "user-window-windowrule-059",
  match = {
    class = "^(pavucontrol|org.pulseaudio.pavucontrol|com.saivert.pwvucontrol)$",
  },
  center = true,
})

apply_window_rule({
  name = "user-window-windowrule-060",
  match = {
    class = "^([Ww]hatsapp-for-linux|ZapZap|com.rtosta.zapzap)$",
  },
  center = true,
})

apply_window_rule({
  name = "user-window-windowrule-061",
  match = {
    class = "^([Ff]erdium)$",
  },
  center = true,
})

apply_window_rule({
  name = "user-window-windowrule-062",
  match = {
    title = "^(Picture-in-Picture)$",
  },
  move = "72% 7%",
})

apply_window_rule({
  name = "user-window-windowrule-063",
  match = {
    fullscreen = 1,
  },
  idle_inhibit = "fullscreen",
})

apply_window_rule({
  name = "user-window-windowrule-064",
  match = {
    tag = "email*",
  },
  workspace = 1,
})

apply_window_rule({
  name = "user-window-windowrule-065",
  match = {
    tag = "browser*",
  },
  workspace = 2,
})

apply_window_rule({
  name = "user-window-windowrule-066",
  match = {
    tag = "gamestore*",
  },
  workspace = 5,
})

apply_window_rule({
  name = "user-window-windowrule-067",
  match = {
    tag = "im*",
  },
  workspace = 7,
})

apply_window_rule({
  name = "user-window-windowrule-068",
  match = {
    tag = "games*",
  },
  workspace = 8,
})

apply_window_rule({
  name = "user-window-windowrule-069",
  match = {
    tag = "screenshare*",
  },
  workspace = "4 silent",
})

apply_window_rule({
  name = "user-window-windowrule-070",
  match = {
    class = "^(virt-manager)$",
  },
  workspace = "6 silent",
})

apply_window_rule({
  name = "user-window-windowrule-071",
  match = {
    class = "^(.virt-manager-wrapped)$",
  },
  workspace = "6 silent",
})

apply_window_rule({
  name = "user-window-windowrule-072",
  match = {
    class = "^(obsidian|md.obsidian.Obsidian)$",
  },
  workspace = "8 silent",
})

apply_window_rule({
  name = "user-window-windowrule-073",
  match = {
    class = "^([Bb]itwarden)$",
  },
  workspace = "9 silent",
})

apply_window_rule({
  name = "user-window-windowrule-074",
  match = {
    tag = "multimedia*",
  },
  workspace = "9 silent",
})

apply_window_rule({
  name = "user-window-windowrule-075",
  match = {
    tag = "KooL_Cheat*",
  },
  float = true,
})

apply_window_rule({
  name = "user-window-windowrule-076",
  match = {
    tag = "wallpaper*",
  },
  float = true,
})

apply_window_rule({
  name = "user-window-windowrule-077",
  match = {
    tag = "settings*",
  },
  float = true,
})

apply_window_rule({
  name = "user-window-windowrule-078",
  match = {
    tag = "viewer*",
  },
  float = true,
})

apply_window_rule({
  name = "user-window-windowrule-079",
  match = {
    tag = "KooL-Settings*",
  },
  float = true,
})

apply_window_rule({
  name = "user-window-windowrule-080",
  match = {
    class = "([Zz]oom|onedriver|onedriver-launcher)$",
  },
  float = true,
})

apply_window_rule({
  name = "user-window-windowrule-081",
  match = {
    class = "(org.gnome.Calculator)",
    title = "(Calculator)",
  },
  float = true,
})

apply_window_rule({
  name = "user-window-windowrule-082",
  match = {
    class = "^(mpv|com.github.rafostar.Clapper)$",
  },
  float = true,
})

apply_window_rule({
  name = "user-window-windowrule-083",
  match = {
    class = "^([Qq]alculate-gtk)$",
  },
  float = true,
})

apply_window_rule({
  name = "user-window-windowrule-084",
  match = {
    class = "^([Ff]erdium)$",
  },
  float = true,
})

apply_window_rule({
  name = "user-window-windowrule-085",
  match = {
    title = "^(Picture-in-Picture)$",
  },
  float = true,
})

apply_window_rule({
  name = "user-window-windowrule-086",
  match = {
    title = "^(Authentication Required)$",
  },
  float = true,
})

apply_window_rule({
  name = "user-window-windowrule-087",
  match = {
    title = "^(Authentication Required)$",
  },
  center = true,
})

apply_window_rule({
  name = "user-window-windowrule-088",
  match = {
    class = "(codium|codium-url-handler|VSCodium)",
    title = "negative:(.*codium.*|.*VSCodium.*)",
  },
  float = true,
})

apply_window_rule({
  name = "user-window-windowrule-089",
  match = {
    class = "^(com.heroicgameslauncher.hgl)$",
    title = "negative:(Heroic Games Launcher)",
  },
  float = true,
})

apply_window_rule({
  name = "user-window-windowrule-090",
  match = {
    class = "^([Ss]team)$",
    title = "negative:^([Ss]team)$",
  },
  float = true,
})

apply_window_rule({
  name = "user-window-windowrule-091",
  match = {
    class = "([Tt]hunar)",
    title = "negative:(.*[Tt]hunar.*)",
  },
  float = true,
})

apply_window_rule({
  name = "user-window-windowrule-092",
  match = {
    title = "^(Add Folder to Workspace)$",
  },
  float = true,
})

apply_window_rule({
  name = "user-window-windowrule-093",
  match = {
    title = "^(Add Folder to Workspace)$",
  },
  size = "70% 60%",
})

apply_window_rule({
  name = "user-window-windowrule-094",
  match = {
    title = "^(Add Folder to Workspace)$",
  },
  center = true,
})

apply_window_rule({
  name = "user-window-windowrule-095",
  match = {
    title = "^(Save As)$",
  },
  float = true,
})

apply_window_rule({
  name = "user-window-windowrule-096",
  match = {
    title = "^(Save As)$",
  },
  size = "70% 60%",
})

apply_window_rule({
  name = "user-window-windowrule-097",
  match = {
    title = "^(Save As)$",
  },
  center = true,
})

apply_window_rule({
  name = "user-window-windowrule-098",
  match = {
    initial_title = "(Open Files)",
  },
  float = true,
})

apply_window_rule({
  name = "user-window-windowrule-099",
  match = {
    initial_title = "(Open Files)",
  },
  size = "70% 60%",
})

apply_window_rule({
  name = "user-window-windowrule-100",
  match = {
    title = "^(SDDM Background)$",
  },
  float = true,
})

apply_window_rule({
  name = "user-window-windowrule-101",
  match = {
    title = "^(SDDM Background)$",
  },
  center = true,
})

apply_window_rule({
  name = "user-window-windowrule-102",
  match = {
    title = "^(SDDM Background)$",
  },
  size = "16% 12%",
})

apply_window_rule({
  name = "user-window-windowrule-103",
  match = {
    tag = "browser*",
  },
  opacity = "1.0 1.0",
})

apply_window_rule({
  name = "user-window-windowrule-104",
  match = {
    tag = "projects*",
  },
  opacity = "0.9 0.8",
})

apply_window_rule({
  name = "user-window-windowrule-105",
  match = {
    tag = "im*",
  },
  opacity = "0.94 0.86",
})

apply_window_rule({
  name = "user-window-windowrule-106",
  match = {
    tag = "multimedia*",
  },
  opacity = "0.94 0.86",
})

apply_window_rule({
  name = "user-window-windowrule-107",
  match = {
    tag = "file-manager*",
  },
  opacity = "0.9 0.8",
})

apply_window_rule({
  name = "user-window-windowrule-108",
  match = {
    tag = "terminal*",
  },
  opacity = "0.8 0.7",
})

apply_window_rule({
  name = "user-window-windowrule-109",
  match = {
    tag = "settings*",
  },
  opacity = "0.8 0.7",
})

apply_window_rule({
  name = "user-window-windowrule-110",
  match = {
    tag = "viewer*",
  },
  opacity = "0.82 0.75",
})

apply_window_rule({
  name = "user-window-windowrule-111",
  match = {
    tag = "wallpaper*",
  },
  opacity = "0.9 0.7",
})

apply_window_rule({
  name = "user-window-windowrule-112",
  match = {
    class = "^(gedit|org.gnome.TextEditor|mousepad)$",
  },
  opacity = "0.8 0.7",
})

apply_window_rule({
  name = "user-window-windowrule-113",
  match = {
    class = "^(deluge)$",
  },
  opacity = "0.9 0.8",
})

apply_window_rule({
  name = "user-window-windowrule-114",
  match = {
    class = "^(im.riot.Riot)$",
  },
  opacity = "0.9 0.8",
})

apply_window_rule({
  name = "user-window-windowrule-115",
  match = {
    class = "^(seahorse)$",
  },
  opacity = "0.9 0.8",
})

apply_window_rule({
  name = "user-window-windowrule-116",
  match = {
    title = "^(Picture-in-Picture)$",
  },
  opacity = "0.95 0.75",
})

apply_window_rule({
  name = "user-window-windowrule-117",
  match = {
    tag = "KooL_Cheat*",
  },
  size = "65% 90%",
})

apply_window_rule({
  name = "user-window-windowrule-118",
  match = {
    tag = "wallpaper*",
  },
  size = "70% 70%",
})

apply_window_rule({
  name = "user-window-windowrule-119",
  match = {
    tag = "settings*",
  },
  size = "70% 70%",
})

apply_window_rule({
  name = "user-window-windowrule-120",
  match = {
    class = "^([Ww]hatsapp-for-linux|ZapZap|com.rtosta.zapzap)$",
  },
  size = "60% 70%",
})

apply_window_rule({
  name = "user-window-windowrule-121",
  match = {
    class = "^([Ff]erdium)$",
  },
  size = "60% 70%",
})

apply_window_rule({
  name = "user-window-windowrule-122",
  match = {
    title = "^(Picture-in-Picture)$",
  },
  pin = true,
})

apply_window_rule({
  name = "user-window-windowrule-123",
  match = {
    title = "^(Picture-in-Picture)$",
  },
  keep_aspect_ratio = true,
})

apply_window_rule({
  name = "user-window-windowrule-124",
  match = {
    tag = "games*",
  },
  no_blur = true,
})

apply_window_rule({
  name = "user-window-windowrule-125",
  match = {
    tag = "games*",
  },
  fullscreen = true,
})

apply_window_rule({
  name = "personal-kitty-dropdown",
  match = {
    class = "^(kitty-dropdown)$",
  },
  float = true,
  size = "70% 60%",
  move = "15% 5%",
})

apply_window_rule({
  name = "personal-default-opaque",
  match = {
    class = "^(.*)$",
  },
  opaque = true,
})
