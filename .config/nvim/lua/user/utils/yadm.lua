M = {}

function M.get_yadm_files()
  local output = vim.fn.systemlist("yadm --no-pager --literal-pathspecs ls-files")
  if vim.v.shell_error ~= 0 then
    print("Error running 'yadm ls-files'.")
    return {}
  end
  local files = {}
  for _, file in ipairs(output) do
    table.insert(files, file)
  end
  return files
end

return M
