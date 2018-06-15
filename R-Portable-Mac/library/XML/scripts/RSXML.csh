if(`test -n "-lxml2 -lz -lpthread -licucore -lm"`) then

if(${?LD_LIBRARY_PATH}) then
    setenv LD_LIBRARY_PATH ${LD_LIBRARY_PATH}:-lxml2 -lz -lpthread -licucore -lm
else
   setenv LD_LIBRARY_PATH -lxml2 -lz -lpthread -licucore -lm
endif

endif
