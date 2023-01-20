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
}
