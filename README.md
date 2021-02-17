# Ruby Challenge

### RUN SERVER

To start a memcached server, you must be located in the root folder of the project, open the command line from that folder and type

<pre>
ruby .\run_server.rb</pre>

Make sure you have the latest version of ruby installed.

### RUN CLIENTS

Likewise, to start a memcached client, you must open the console located in the root folder and type

<pre>
ruby .\run_client.rb</pre>

By default the server listens on port 3000 and clients connect on this same port by referring to localhost. If you want to change configuration it is possible to modify the parameters in the scripts.

### COMMANDS

Once a client has been started, a message like the following should appear: MEMCACHED CLIENT STARTED, TYPE YOUR COMMAND. After that you can start typing some commands. The following are examples of them

##### GET

<pre>
get 1
</pre>

you can copy and paste them directly to the console or type them and then press enter after each line.

##### GETS

<pre>
gets 1 2
</pre>

##### SET

<pre>
set 1 23 5000 7
newdata
</pre>

##### SET NOREPLY

<pre>
set 1 23 5000 7 noreply
newdata
</pre>


##### ADD

<pre>
add 1 23 5000 7
newdata
</pre>

##### REPLACE

<pre>
replace 1 23 5000 7
newdata
</pre>

##### APPEND

<pre>
append 1 23 5000 9
appendata
</pre>

##### PREPEND

<pre>
prepend 1 23 5000 11
prependdata
</pre>

##### CAS

<pre>
cas 1 23 5000 5 c0ceb73bd7d652b126bb6df41d024109
hello
</pre>

### RUN UNIT TEST

To run the tests be sure to update the rspec dependency, go to the spec folder, open a console located in the folder and type

<pre>
rspec .\memcached_manager_spec.rb
</pre> 

<pre>
rspec .\persistence_unit_spec.rb
</pre> 

To run the servert tests be sure to run a server from the root folder, go to the spec folder, open a console located in this folder and type

<pre>
rspec .\server_spec.rb
</pre>
