-- Scratch sessions in a fresh temp dir (from frostplexx/dotfiles.nix).
-- No key: run "New Scratch Session" from the command palette.
local terminal = "com.superlogical.terminal"

-- Without a seed every server start would draw the same names
math.randomseed(os.time())

-- Random names for scratch sessions, to avoid collisions with existing sessions
local names = {
    "apple", "brick", "crane", "daisy", "eagle", "flint", "grove", "haste",
    "ivory", "joker", "kneel", "lemon", "mango", "noble", "olive", "pearl",
    "quilt", "raven", "stone", "tiger", "umbra", "vivid", "waltz", "xenon",
    "yacht", "zesty", "amber", "bison", "cedar", "delta", "ember", "fable",
    "glade", "hinge", "input", "jolly", "karma", "llama", "mirth", "nexus",
    "ocean", "plumb", "quest", "ridge", "sable", "thorn", "unity", "viper",
    "whale", "young", "zebra", "aloft", "bloom", "clove", "dwarf", "elbow",
    "frost", "gourd", "hazel", "inlet", "jewel", "knoll", "lunar", "moose",
    "nylon", "orbit", "prism", "quail", "robin", "slate", "tulip", "usher",
    "vapor", "wheat", "yield", "zonal", "acorn", "badge", "cabin", "dingo",
    "elfin", "finch", "gecko", "harpy", "igloo", "jumbo", "kiosk", "lotus",
    "maple", "ninja", "oxide", "pivot", "quirk", "rusty", "spice", "trout",
    "ultra", "venom", "wrist", "yodel", "zippy", "anvil", "brisk", "coral",
    "drift", "epoch", "flame", "gloom", "husky", "index", "jazzy", "kayak",
    "latch", "mocha", "nudge", "oasis", "pixel", "quota", "relic", "shard",
    "token", "uncle", "vault", "wharf", "xylem", "yearn", "zingy", "aroma",
    "bluff", "cider", "dross", "envoy", "fjord", "glint", "hobby", "icing",
    "jetty", "koala", "lyric", "mound", "nerve", "otter", "poppy", "query",
    "rival", "sheen", "trove", "unzip", "vigor", "wooly", "axiom", "bacon",
    "chalk", "dusty", "equal", "fudge", "gamma", "hover", "ionic", "juice",
    "knack", "lilac", "mossy", "notch", "oddly", "plank", "quiet", "roost",
    "swirl", "tango", "upset", "valve", "widow", "yummy", "zloty", "acute",
    "berry", "comet", "dodge", "exile", "fiery", "humid", "ivied",
    "jaunt", "kebab", "lodge", "maize", "nacho", "onion", "pouch", "quack",
    "reedy", "sound", "trail", "umber", "vodka", "wrath", "yeast", "zilch",
}


rex.action({
    name = "session_new_scratchspace",
    title = "New Scratch Session",
    description = "Create a new scratch session",
    keywords = "scratch session temporary tmp",
    run = function()
        local session_name = names[math.random(#names)] .. "-" .. names[math.random(#names)]

        -- An explicit template works with both BSD (macOS) and GNU mktemp
        local tmp_root = (os.getenv("TMPDIR") or "/tmp"):gsub("/+$", "")
        local tempdir = rex.exec({ "mktemp", "-d", tmp_root .. "/" .. session_name .. ".XXXXXX" })
        local cwd = (tempdir and tempdir.stdout or ""):gsub("%s+$", "")
        if cwd == "" then
            error("scratchspace: mktemp failed, no scratch session created", 0)
        end

        local created, err = rex.call("session.create", {
            label = " scratch: " .. session_name,
            initial_windows = {
                {
                    layout = rex.layout.block({
                        flavor = terminal .. ".shell",
                        options = { cwd = cwd },
                    }),
                },
            },
        })
        if err then
            error(err)
        end

        -- Shows the new session. Needs Remote Control turned on in Rex Settings;
        -- the session exists either way.
        local ok, select_err = pcall(rex.client.queue, "session.select", { session_id = created.session_id })
        if not ok then
            rex.log("warn", "scratchspace: created scratch session but could not show it: " .. tostring(select_err))
        end
    end,
})
