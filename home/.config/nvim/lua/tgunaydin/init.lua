-- Compatibility shim: some plugins still call vim.tbl_flatten (deprecated in newer Nvim).
-- Replace it with the recommended iterator-based implementation to avoid startup warnings.
if type(vim.iter) == "function" then
  vim.tbl_flatten = function(t)
    return vim.iter(t):flatten():totable()
  end
else
  -- Fallback for very old Nvim builds without vim.iter
  vim.tbl_flatten = function(t)
    local out = {}
    local function add(x)
      if type(x) == "table" then
        for _, v in ipairs(x) do
          add(v)
        end
      else
        out[#out + 1] = x
      end
    end
    add(t)
    return out
  end
end

require("tgunaydin.lazy")
require("tgunaydin.remap") --her neovim acildiginda otomatik olarak remap dosyasini so yani source edecek
require("tgunaydin.set")
require("tgunaydin.timer").setup()
