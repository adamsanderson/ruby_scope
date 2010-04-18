RubyScope
---------
Ruby colored binoculars for your code.

Using RubyScope
===============
You can invoke ruby_scope from the command line:

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
    
Of course regular expressions are fair game:

    ruby_scope -R --def '/^test/' ~/SecretProject
    
Wicked hacker? Go crazy and write your own SexpPath queries:

    ruby_scope --custom 's(:call, s(:ivar, atom), :save, _)'

That finds all the saves on instance variables by the way.

Hacking RubyScope
=================
Want to extend ruby_scope?  Take a look at `cli.rb`, at the 
moment this is where all of the queries are actually generated.  Have an
idea for a better caching mechanism? Look at `sexp_cache.rb`.

The source is on GitHub, so fork off:

    http://github.com/adamsanderson/ruby_scope

Enjoy,    

    Adam Sanderson
    http://endofline.wordpress.com/
    netghost@gmail.com