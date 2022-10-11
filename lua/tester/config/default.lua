return {
    providers = {
        phpunit = {
            command = { "./vendor/bin/phpunit", "--colors=never" },
        },
        pest = {
            command = { "./vendor/bin/pest" },
        },
        pytest = {
            command = { "pytest", "--color=no" },
        },
    },
    mapping = {
        run_all = "<Leader>oa",
        run_current = "<Leader>oo",
    },
}
