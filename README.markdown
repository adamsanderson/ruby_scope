RubyScope
---------
Fun experimental code searching.

    Usage: ruby_scope [options] path
    Queries:
        -d, --def NAME                   Find the definition of instance method NAME
        -D, --class-def NAME             Find the definition of class method NAME
        -c, --call NAME                  Find method calls of NAME
        -C, --class NAME                 Find definition of NAME
        -v, --variable NAME              Find references to variable NAME
        -a, --assign NAME                Find assignments to NAME
        -h, --help                       Show this message
        
For instance, find all the places `to_i` or `to_f` are called in your secret project:

    ruby ruby_scope.rb -c 'to_i' -c 'to_f' ~/SecretProject/**/*.rb
    
Depends on RubyParser, SexpProcessor, and SexpPath, no gem yet.

    Adam Sanderson
    netghost@gmail.com