MathMLOperations =
 c("power" = "^",
   "times" = "*",
   "plus" = "+"
  )

handlers =
function(operations = MathMLOperations)
{
  current = list()
  state = character()

  start = 
    function(x, atts, ...) {
      # Handle the opening tags and set the stack appropriately.

     if(x == "apply") {
          # Make a call with a silly name that we will change when we read the next element
          # giving the operation.
        current <<- c(call("<dummy>"), current)
        state <<- c("call", state)
     } else if(x == 'ci') {
           # Expecting the next text contents to be a name of a variable.
        state <<- c("name", state)
        current <<- c("", current)

     } else if(!is.na(idx <- match(x, names(operations)))) {
           # If we are dealing with a call and the name of this element being opened
           # matches our operation names, then insert the S name of the corrresponding
           # function into the previously created call.
       if(length(state) && state[1] == "call")
         current[[1]][[1]] <<- as.name(operations[idx])
           # make certain that we add something to state stack so that when we close the
           # tag, we remove it, not the previously active element on the stack.
         state <<- c("<>", state)
     }
   }

  text = function(x, atts, ...) {
     if(x == "")
       return(FALSE)

     if(length(state) && state[1] == "name") {
        current[[1]] <<- paste(current[[1]], x, sep = "")
     }
  }

  end =
    function(x, atts, ...) {
         # If there is nothing on the stack, then nothing to close.

       if(length(state)) {
         if(state[1] == "call" && length(current) > 1) {
             # If ending an apply (call) and we have 2 or more things
             # on the stack, then fold this call (current[[1]]) into the argument of the 
             # of the previous call (current[[2]]) at the end.
           e = current[[1]]
           f = current[[2]]
             # Should check f is a call or state[2] == "call"
           f[[length(f) + 1]] = e
           current[[2]] = f
           current <<- current[-1]  

         } else if(state[1]  == "name") {
              # ending a <ci> so we have a name, then put this into the 
              # current call.
           if(length(state) > 1 && state[2] == "call") {  
                # this is very similar to the previous block for call
                # except we have a as.name(). Could easily consolidate by doing
                # this coercion first.  Left like this for clarity of concept.
              e = current[[2]] 
              e[[length(e) + 1]] = as.name(current[[1]])
              current[[2]] = e
                   # Remove the elements from the top of the stacks.
              current <<- current[-1]  
           }
         }

         state <<- state[-1]
       } 
    }


 list(startElement = start, endElement = end, text = text, 
      state = function() state,
      current = function() current)
}
