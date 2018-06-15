.rApacheInputStream <- setRefClass(
   'rApacheInputStream',
   methods = list(
      read_lines = function(n = -1L){
         if (n<=0) return(character())
         readLines(n=n,warn=FALSE)
      },
      read = function(l = -1L){
         receiveBin(l)
      },
      rewind = function(){
         warning("rApache doesn't support rewind()")
      }
   )
)

.rApacheErrorStream <- setRefClass(
   'rApacheErrorStream',
   methods = list(
      flush = function() { base::flush(stderr()) },
      cat = function(...,sep=" ",fill=FALSE,labels=NULL)
      { base::cat(...,sep=sep,fill=fill,labels=labels,file=stderr()) }
   )
)

Server <- setRefClass(
   'rApacheServer',
   fields = c('appPath','appList'),
   methods = list(
      initialize = function(...){
         callSuper(...)
      },
      AppPath = function(appPath){
         if (length(appList) == 0) return()
         appPath <<- appPath
      },
      build_env = function(){
         env <- new.env(hash=TRUE,parent=emptyenv())

         lapply(names(SERVER$headers_in),function(h){
               assign(
                  paste('HTTP_',gsub('-','_',gsub('(\\w+)','\\U\\1',h,perl=TRUE)),sep=''),
                  SERVER$headers_in[[h]],
                  env)
         })

         if (exists('HTTP_CONTENT_LENGTH',env))
            assign('CONTENT_LENGTH',get('HTTP_CONTENT_LENGTH',env),env)
         else 
            assign('CONTENT_LENGTH',SERVER$clength,env)

         if (exists('HTTP_CONTENT_TYPE',env))
            assign('CONTENT_TYPE',get('HTTP_CONTENT_TYPE',env),env)
         else
            assign('CONTENT_TYPE',SERVER$content_type,env)

         assign('SCRIPT_NAME',SERVER$cmd_path,env)

         assign('PATH_INFO',sub(SERVER$cmd_path,'',SERVER$uri),env)

         # Ensure only one leading forward slash
         env$PATH_INFO <- sub('^/+','/',env$PATH_INFO)

         assign('QUERY_STRING',SERVER$args,env)
         assign('QUERY_STRING',ifelse(is.null(SERVER$args),'',SERVER$args),env)
         assign('REQUEST_METHOD',SERVER$method,env)

         assign('REMOTE_HOST',SERVER$remote_host,env)
         assign('REMOTE_ADDR',SERVER$remote_ip,env)

         hostport <- strsplit(get('HTTP_HOST',env),':',fixed=TRUE)[[1]]

         assign('SERVER_NAME',hostport[1],env)
         if ('port' %in% names(SERVER))
            assign('SERVER_PORT',SERVER$port,env)
         else
            assign('SERVER_PORT',hostport[2],env)

         assign('rook.version',packageDescription('Rook',fields='Version'),env)
         assign('rook.url_scheme', ifelse(isTRUE(SERVER$HTTPS),'https','http'),env)
         assign('rook.input',.rApacheInputStream$new(),env)
         assign('rook.errors',.rApacheErrorStream$new(),env)

         env
      },
      call = function(app){
         if (is(app,'refClass')) res <- try(app$call(build_env()))
         else if (is(app,'function')) res <- try(app(build_env()))
         else stop('App not Rook aware')

         if (inherits(res,'try-error')){
            warning('App returned try-error object')
            return(HTTP_INTERNAL_SERVER_ERROR)
         }

         setStatus(res$status)

         setContentType(res$headers$`Content-Type`)
         res$headers$`Content-Type` <- NULL
         lapply(names(res$headers),function(n)setHeader(n,res$headers[[n]]))

         # If body is named, then better be a file.
         if (!is.null(names(res$body)) && names(res$body)[1] == 'file'){
            sendBin(readBin(res$body[1],'raw',n=file.info(res$body[1])$size))
         } else {
            if ((is.character(res$body) && nchar(res$body)>0) || 
                (is.raw(res$body) && length(res$body)>0) )
            sendBin(res$body)
         }

         OK
      }
   )
)$new()

Request$methods(
   GET = function(){
      if (!exists('rook.request.query_list',env))
         env[['rook.request.query_list']] <<- base::get('GET','rapache')
      env[['rook.request.query_list']]
   },
   POST = function() {
      if (exists('rook.request.form_list',env))
         return(env[['rook.request.form_list']])
      postvar <- base::get('POST','rapache')
      filevar <- base::get('FILES','rapache')

      if (length(postvar) <= 0 && length(filevar) <= 0) return(NULL)

      if (length(filevar) > 0){
         if (length(postvar) <= 0) postvar <- list()
         for (n in names(filevar)){
            if (length(filevar[[n]])>0){
               postvar[[n]] <- list(
                  filename = filevar[[n]]$name,
                  tempfile = filevar[[n]]$tmp_name,
                  content_type = Mime$mime_type(Mime$file_extname(filevar[[n]]$name))
               )
            }
         }
      }
      for (n in names(postvar)){
         if (is.null(postvar[[n]])) postvar[[n]] <- NULL
      }
      env[['rook.request.form_list']] <<- postvar
      postvar
   }
)
