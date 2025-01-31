return {
    base = "app",
    commands = {
        setup = {
            options = {
                configure = {
                    description = 'Configures application, renders templates and installs services'
                }
            },
            action = function(options, _, _, _)
                local no_options = #table.keys(options) == 0
                if no_options or options.environment then
                    am.app.prepare()
                end

                if no_options or not options['no-validate'] then
                    am.execute('validate', { '--platform' })
                end

                if no_options or options.app then
                    am.execute_extension('__btc/download-binaries.lua', { context_fail_exit_code = EXIT_SETUP_ERROR })
                end

                if no_options or not options['no-validate'] then
                    am.execute('validate', { '--configuration' })
                end

                if no_options or options.configure then
                    am.app.render()

                    am.execute_extension('__btc/configure.lua', { context_fail_exit_code = EXIT_APP_CONFIGURE_ERROR })
                end
                log_success('Node setup complete.')
            end
        },
        info = {
            description = "ami 'info' sub command",
            summary = 'Prints runtime info and status of the node',
            action = '__btc/info.lua',
            context_fail_exit_code = EXIT_APP_INFO_ERROR
        },
        start = {
            description = "ami 'start' sub command",
            summary = 'Starts the node',
            action = '__btc/start.lua',
            context_fail_exit_code = EXIT_APP_START_ERROR
        },
        stop = {
            description = "ami 'stop' sub command",
            summary = 'Stops the node',
            action = '__btc/stop.lua',
            context_fail_exit_code = EXIT_APP_STOP_ERROR
        },
        validate = {
            description = "ami 'validate' sub command",
            summary = 'Validates app configuration and platform support',
            action = function(_, _, _, _)
                ami_assert(proc.EPROC, 'Node AMI requires extra api - eli.proc.extra', EXIT_MISSING_API)
                ami_assert(fs.EFS, 'Node AMI requires extra api - eli.fs.extra', EXIT_MISSING_API)

                ami_assert(type(am.app.get('id')) == 'string', 'id not specified!', EXIT_INVALID_CONFIGURATION)
                ami_assert(
                    type(am.app.get_configuration()) == 'table',
                    'configuration not found in app.h/json!',
                    EXIT_INVALID_CONFIGURATION
                )
                ami_assert(type(am.app.get('user')) == 'string', 'USER not specified!', EXIT_INVALID_CONFIGURATION)
                ami_assert(
                    type(am.app.get_type()) == 'table' or type(am.app.get_type()) == 'string',
                    'Invalid app type!',
                    EXIT_INVALID_CONFIGURATION
                )
                log_success('Node configuration validated.')
            end
        },
        about = {
            description = "ami 'about' sub command",
            summary = 'Prints information about application',
            action = function(_, _, _, _)
                local ok, about_file = fs.safe_read_file(am.app.get_model('ABOUT_SOURCE'))
                ami_assert(ok, 'Failed to read about file!', EXIT_APP_ABOUT_ERROR)

                local ok, about = hjson.safe_parse(about_file)
                ami_assert(ok, 'Failed to parse about file!', EXIT_APP_ABOUT_ERROR)
                if type(about) == 'table' then --inject app type
                    about['App Type'] = am.app.get({ 'type', 'id' }, am.app.get('type'))
                end
                if am.options.OUTPUT_FORMAT == 'json' then
                    print(hjson.stringify_to_json(about, { indent = false, skip_keys = true }))
                else
                    print(hjson.stringify(about))
                end
            end
        },
        cli = {
            description = "ami 'cli' pass through command",
            summary = 'Passes any passed arguments directly to cli.',
            type = 'external',
            exec = path.combine('bin', am.app.get_model('CLI_NAME')),
            inject_args = {
                '-rpcconnect=' .. am.app.get_configuration({ 'DAEMON_CONFIGURATION', 'rpcbind' }, '127.0.0.1'),
                '-datadir=data'
            },
            context_fail_exit_code = EXIT_APP_INTERNAL_ERROR
        },
        removedb = {
            index = 6,
            description = 'command for crownd database removal',
            summary = 'Removes crownd database',
            action = '__btc/removedb.lua',
            context_fail_exit_code = EXIT_RM_DATA_ERROR
        },
        remove = {
            index = 7,
            action = function(_options, _, _, _)
                if _options.all then
                    am.execute_extension('__btc/remove-all.lua', { context_fail_exit_code = EXIT_RM_ERROR })
                    am.app.remove()
                    log_success('Application removed.')
                else
                    am.app.remove_data()
                    log_success('Application data removed.')
                end
            end
        }
    }
}
