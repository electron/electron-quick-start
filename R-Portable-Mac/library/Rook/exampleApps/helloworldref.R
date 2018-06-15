app <- setRefClass(
    'HelloWorld',
    methods = list(
	call = function(env){
	    list(
		status=200,
		headers = list(
		    'Content-Type' = 'text/html'
		    ),
		body = paste('<h1>Hello World!</h1>')
	    )
	}
    )
)$new()
