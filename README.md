# Redcar GDI

The Redcar GDI is meant as a general debugger interface to allow integration 
of remotely attaching commandline-driven debuggers into the Redcar editor by
Dan Lucraft™

It uses a variation on the builder pattern to create natively-ish looking frontends
using Haml partials and the Redcar observer mixin to communicate between process, 
frontend and debugger model. Currently available models are for GDB and JDB, more will
follow.
