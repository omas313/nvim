-- local port = os.getenv('GDScript_Port') or 6005
local port = 6005
local cmd = vim.lsp.rpc.connect('127.0.0.1', port)
local pipe = '/tmp/godot.pipe'
-- local pipe = '/home/pace/Godot/Godot_v4.2-stable_linux.x86_64'

vim.lsp.start({
    name = 'Godot',
    cmd = cmd,
    root_dir = vim.fs.dirname(vim.fs.find({ 'project.godot', '.git' }, { upward = true })[1]),
    on_attach = function(_, _)
        vim.api.nvim_command('echo serverstart("' .. pipe .. '")')
    end
})
