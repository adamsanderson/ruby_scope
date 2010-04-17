RubyScope
---------
Syntactically search your code.

    Usage: ruby_scope [options] path

    Queries:
            --def NAME                   Find the definition of instance method NAME
            --class-def NAME             Find the definition of class method NAME
            --call NAME                  Find method calls of NAME
            --class NAME                 Find definition of NAME
            --variable NAME              Find references to variable NAME
            --assign NAME                Find assignments to NAME
            --any NAME                   Find any reference to NAME (class, variable, number)
            --custom SEXP_PATH           Searches for a custom SexpPath

    Options:
        -R                               Recursively search folders
            --no-cache                   Do not use a cache
            --cache PATH                 Use the cache at PATH (defaults to current dir)
        -v, --verbose                    Verbose output
        -h, --help                       Show this message
        
Find all the places `run` or `save` are called in your secret project:

    ruby_scope -R --method 'run' --method 'save' ~/SecretProject
    
Where do I assign values to `a`:
    
    ruby_scope -R --assign 'a' ~/SecretProject
    
Wicked hacker? Go crazy and write your own SexpPath queries:

    ruby_scope --custom 's(:call, s(:ivar, atom), :save, _)'

That finds all the saves on instance variables by the way.
    
Depends on RubyParser, SexpProcessor, and SexpPath, no gem yet.

    Adam Sanderson
    netghost@gmail.com