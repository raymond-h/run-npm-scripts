{CompositeDisposable} = require 'atom'
{exec} = require 'child_process'

Q = require 'q'

defaultScripts = [
	'lint', 'test', 'build'
]

module.exports =
    disposables: null

    activate: ->
    	@disposables = new CompositeDisposable

    	for script in defaultScripts then do (script) =>
    		@disposables.add atom.commands.add 'atom-workspace',
    			'run-npm-scripts:run-' + script, =>
    				@runNpmScript script

    deactivate: ->
    	@disposables.dispose()

    runNpmScript: (script) ->
        @npm 'run', script

        .then ([stdout]) ->
            atom.notifications.addSuccess "
                Finished running script `#{script}`
            ", {
                detail: stdout
            }

        .catch (err) ->
            console.error err.stack
            atom.notifications.addError err.name,
                detail: err.message
                stack: err.stack

    npm: (params...) ->
        Q.nfcall exec,
            "npm #{params.map((p) -> '"' + p + '"').join ' '}",
            cwd: atom.project.getPaths()[0]
