local actions = require'telescope.actions'
local conf = require'telescope.config'.values
local finders = require'telescope.finders'
local pickers = require'telescope.pickers'
local previewers = require'telescope.previewers'

local M = {}

M.list = function(opts)
  opts = opts or {}
  pickers.new(opts, {
    prompt_title = 'Repositories managed by ghq',
    finder = finders.new_oneshot_job(
      {'ghq', 'list', '--full-path'},
      opts
    ),
    previewer = previewers.new_termopen_previewer{
      get_command = function(entry)
        -- TODO: deal with another README
        local readme
        for _, name in pairs{'README', 'README.md'} do
          local path = entry.value..'/'..name
          local file_found = io.open(path)
          if file_found then
            io.close(file_found)
            readme = path
            break
          end
        end
        if readme then
          if vim.fn.executable'glow' then
            return {'glow', readme}
          elseif vim.fn.executable'bat' then
            return {'bat', '--style', 'header,grid', readme}
          end
          return {'cat', readme}
        end
        return {'echo', ''}
      end,
    },
    sorter = conf.file_sorter(opts),
    attach_mappings = function()
      actions.goto_file_selection_edit:replace(function(prompt_bufnr)
        local selection = actions.get_selected_entry()
        actions.close(prompt_bufnr)
        require'telescope.builtin'.git_files{cwd = selection.value}
      end)
      return true
    end,
  }):find()
end

return M
