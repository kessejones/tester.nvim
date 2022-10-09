return {
    providers = {
        phpunit = {
            command = { "./vendor/bin/phpunit", "--colors=never" },
        },
        pest = {
            command = { "./vendor/bin/pest" },
        },
    },
    mapping = {
        run_all = "<Leader>oa",
        run_current = "<Leader>oo",
    },
}
