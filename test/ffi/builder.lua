local luajit = require 'LuaJIT'
local util = require 'utility'
rawset(_G, 'TEST', true)

local function removeEmpty(lines)
    local removeLines = {}
    for i, v in ipairs(lines) do
        if v ~= '\n' then
            removeLines[#removeLines+1] = v:gsub('^%s+', '')
        end
    end
    return removeLines
end

local function formatLines(lines)
    table.remove(lines, 1)
    return removeEmpty(lines)
end

---@param str string
local function splitLines(str)
    local lines = {}
    local i = 1
    for line in str:gmatch("[^\r\n]+") do
        lines[i] = line
        i = i + 1
    end
    return lines
end

function TEST(wanted)
    wanted = removeEmpty(splitLines(wanted))
    return function (script)
        local lines = formatLines(luajit.compileCodes({ script }))
        assert(util.equal(wanted, lines), util.dump(lines))
    end
end

TEST[[
    ---@param a boolean
    ---@param b boolean
    ---@param c integer
    ---@param d integer
    function m.test(a, b, c, d) end
]] [[
    void test(bool a, _Bool b, size_t c, ssize_t d);
]]

TEST[[
    ---@param a integer
    ---@param b integer
    ---@param c integer
    ---@param d integer
    function m.test(a, b, c, d) end
]] [[
    void test(int8_t a, int16_t b, int32_t c, int64_t d);
]]

TEST[[
    ---@param a integer
    ---@param b integer
    ---@param c integer
    ---@param d integer
    function m.test(a, b, c, d) end
]] [[
    void test(uint8_t a, uint16_t b, uint32_t c, uint64_t d);
]]

TEST[[
    ---@param a integer
    ---@param b integer
    ---@param c integer
    ---@param d integer
    function m.test(a, b, c, d) end
]] [[
    void test(unsigned char a, unsigned short b, unsigned long c, unsigned int d);
]]

TEST[[
    ---@param a integer
    ---@param b integer
    ---@param c integer
    ---@param d integer
    function m.test(a, b, c, d) end
]] [[
    void test(unsigned char a, unsigned short b, unsigned long c, unsigned int d);
]]

TEST[[
    ---@param a integer
    ---@param b integer
    ---@param c integer
    ---@param d integer
    function m.test(a, b, c, d) end
]] [[
    void test(signed char a, signed short b, signed long c, signed int d);
]]

TEST[[
    ---@param a integer
    ---@param b integer
    ---@param c integer
    ---@param d integer
    function m.test(a, b, c, d) end
]] [[
    void test(char a, short b, long c, int d);
]]

TEST[[
    ---@param a number
    ---@param b number
    ---@param c integer
    ---@param d integer
    function m.test(a, b, c, d) end
]] [[
    void test(float a, double b, int8_t c, uint8_t d);
]]

TEST [[
    ---@alias H ffi.namespace*.void

    function m.test() end
]] [[
    typedef void H;

    H test();
]]

TEST [[
    ---@class ffi.namespace*.a

    ---@param a ffi.namespace*.a
    function m.test(a) end
]] [[
    typedef struct {} a;

    void test(a* a);
]]

TEST [[
    ---@class ffi.namespace*.struct@a
    ---@field a integer
    ---@field b ffi.namespace*.char*

    ---@param a ffi.namespace*.struct@a
    function m.test(a) end
]] [[
    struct a {int a;char* b;};

    void test(struct a* a);
]]
