package = 'obj'
version = 'scm-1'
source  = {
    url    = 'git://github.com/moonlibs/obj.git',
    branch = 'master',
}
description = {
    summary  = "Very simple lua oop framework",
    homepage = 'https://github.com/moonlibs/obj.git',
    license  = 'BSD',
}
dependencies = {
    'lua >= 5.1'
}
build = {
    type = 'builtin',
    modules = {
        ['obj'] = 'obj.lua'
    }
}

-- vim: syntax=lua
