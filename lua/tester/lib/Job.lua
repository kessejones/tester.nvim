local Job = {}

function Job.new(cmd, opts)
    local instance = {
        cmd = cmd,
        opts = opts,
        _id = nil,
    }
    setmetatable(instance, { __index = Job })
    return instance
end

function Job:start()
    self._id = vim.fn.jobstart(self.cmd, self.opts)
end

function Job:wait()
    vim.fn.jobwait({ self._id })
end

function Job:run_sync()
    self:start()
    self:wait()
end

return Job
