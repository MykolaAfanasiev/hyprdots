local ok, jdtls = pcall(require, "jdtls")
if not ok then
  return
end

local root_dir = vim.fs.root(0, {
  ".git",
  "mvnw",
  "gradlew",
  "pom.xml",
  "build.gradle",
  "build.gradle.kts",
  "settings.gradle",
  "settings.gradle.kts",
})

if not root_dir then
  return
end

local project_name = vim.fn.fnamemodify(root_dir, ":t")
local workspace_dir = vim.fn.stdpath("data")
  .. "/jdtls-workspace/"
  .. project_name

local bundles = {}

local function add_glob(pattern)
  local matches = vim.split(vim.fn.glob(pattern), "\n", {
    trimempty = true,
  })
  vim.list_extend(bundles, matches)
end

add_glob(
  vim.fn.stdpath("data")
    .. "/mason/packages/java-debug-adapter/extension/server/"
    .. "com.microsoft.java.debug.plugin-*.jar"
)

add_glob(
  vim.fn.stdpath("data")
    .. "/mason/packages/java-test/extension/server/*.jar"
)

local config = {
  cmd = {
    vim.fn.stdpath("data") .. "/mason/bin/jdtls",
    "-data",
    workspace_dir,
  },
  root_dir = root_dir,
  capabilities = require("blink.cmp").get_lsp_capabilities(),
  init_options = {
    bundles = bundles,
  },
  settings = {
    java = {
      signatureHelp = {
        enabled = true,
      },
      completion = {
        favoriteStaticMembers = {
          "org.junit.jupiter.api.Assertions.*",
          "org.mockito.Mockito.*",
        },
      },
    },
  },
}

jdtls.start_or_attach(config, {
  dap = true,
})
