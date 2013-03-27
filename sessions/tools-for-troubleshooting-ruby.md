Tools for Troubleshooting Ruby
==============================

debugger
--------
https://github.com/cldwalker/debugger

`gem install debugger`

In ~/.rdebugrc (You'll want to set these)

    set autolist
    set autoeval
    set autoreload

In the location you want to debug, add the following line:

`require 'debugger'; debugger`

While debugging the following methods may be helpful:

    object.instance_variables
    object.instance_variable_get("@name_of_variable")
    Class.constants
    object.methods.grep(/regexp_for_method/)
    object.method(:method_name).source_location

method_locator
--------------
https://github.com/ryanlecompte/method_locator

`gem install method_locator`

`object.methods_for(:method_name)`

Returns an array of where all that method is defined for the object

`object.method_lookup_path`

Returns an array of all of the classes and modules that compose the object

bundle
------

Where is the gem I am using located on my machine
`$ bundle show <gemname>`

Open the gem in my editor
`$ bundle open <gemname>`

https://blog.engineyard.com/2013/bundler-hacking

gem
---

`$ gem server` or `$ bundle exec gem server`

Go to http://0.0.0.0:8808/ and view all of the gems, their locations and descriptions.
If you installed the gems with RDoc, then you will also have access to the RDocs.

git
---

I hope you are using git.

`$ git blame path/to/file`

`$ git bisect`

Have a test script that exits status 0 on success; and not 0 on failure
  (This could be a test script in your project or an external script)
Mark one commit as good and another as bad, then run bisect.
  (It will point out exactly which commit broke your test script)
  (As an aside, keep your git commits as small as possible, with each commit being a single concern.)

http://www.askbjoernhansen.com/2010/04/30/git_bisect_mini_tutorial.html


awesome_print
-------------
https://github.com/michaeldv/awesome_print

You may appreciate output formatted output in IRB