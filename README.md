# http-rpc
Bash script for managing and sending http requests to services

# Table of Contents
1) [Requirements](#requirements)
2) [Installation](#installation)
3) [Getting Started](#getting-started)
	1) [Example](#getting-started-example)
4) [Commands](#commands)
5) [Usage](#usage)
	1) [Configuration](#usage-configuration)
		1) [Main Configuration](#usage-configuration-main)
		2) [Variables Configuration](#usage-configuration-variables)
		3) [Service Configuration](#usage-configuration-service)
		4) [Request Configuration](#usage-configuration-request)
	2) [Request Bodies](#usage-bodies)
	3) [Templates](#usage-templates)
6) [Advanced Usage](#advanced)
	1) [List of Functions](#advanced-functions)
	2) [Chaining Requests](#advanced-chaining)
	3) [User Input](#advanced-input)
	4) [Dynamic Bodies](#advanced-bodies)

## Requirements <a name="requirements"></a>
* bash 5 - bash 4 may or may not work
* curl

## Installation <a name="installation"></a>
Put http-rpc script in your PATH.  
For bash completion, put http-rpc-completion.sh where it will be sourced, e.g. `/etc/bash_completion.d/`  

## Getting Started <a name="getting-started"></a>
For the first run, run `http-rpc init` or `http-rpc config`.  
This will initialize the configuration.  
`http-rpc config` will edit the main configuration file.  
Services can be created with `http-rpc edit <service>`, and then requests can be created with `http-rpc edit <service> <request>`  

### Example <a name="getting-started-example"></a>
Create an example service with `http-rpc edit example` with this definition:
```
SERVICE_HOST="https://raw.githubusercontent.com"
```

Then create a request with `http-rpc edit example readme` with this definition:
```
REQUEST_PATH="/cjdeakin/http-rpc/master/README.md"
REQUEST_METHOD="GET"
```

Finally, send the request with `http-rpc send example readme`, which will retrieve this readme.

## Commands <a name="commands"></a>
`http-rpc` currently has these commands:
* `config`: edit the main configuration
* `edit`: creator or edit other files
* `init`: perform first time initialization, if necessary
* `rm`: delete files created with `edit`
* `send`: send a request, response body will be printed to stdout, all other output should be on stderr

## Usage <a name="usage"></a>
By default, `http-rpc` stores everything in `${XDG_CONFIG_HOME}/http-rpc`, but this can be controlled through the environment variable `HTTP_RPC_BASEDIR`

### Configuration <a name="usage-configuration"></a>
`http-rpc` is configured through bash files.  
The main configuration, which can be edited with `http-rpc config`, is sourced first.  
Variable configurations, which can edited/created with `http-rpc edit -v <file>`, are sourced second, depending on which ones are specified.  
Service configurations, which can be edited/created with `http-rpc edit <service>`, are sourced third.  
Request configurations, which can be edited/created with `http-rpc edit <service> <request>`, are sourced last.  

#### Main Configuration <a name="usage-configuration-main"></a>
Primarily this stores a mapping of mimetypes to a beautfier command.  
Response body will be beautified based on the Content-Type header.  

#### Variables Configuration <a name="usage-configuration-variables"></a>
These are good for dynamic configuration of the request.  
For example, the same request could be sent for different users by defining variables for each user.  
Requests and services are also capable of loading variables, so common variables can be extracted out of the request or service definition.  

#### Service Configuration <a name="usage-configuration-service"></a>
This stores service configuration that should be used for all requests to that service.  
For example, the hostname and port to which the request should be sent.  

#### Request Configuration <a name="usage-configuration-request"></a>
This stores the actual request information.  
The path the request should go to, the HTTP method to use, the body to send, etc.  

### Request Bodies <a name="usage-bodies"></a>
Request bodies can be created/edited with `http-rpc edit -b <body>`.  
These files exist as static data, and do not provide any configuration.  
The request body to send is decided in this order:  
1) REQUEST_BODY_FORCE variable
2) --body option, passed on the command line
3) REQUEST_BODY variable

A file outside of `HTTP_RPC_BASEDIR` can use used as the body if an absolute path is given, e.g. `/some/file`  

### Templates <a name="usage-templates"></a>
Templates control the content of new files created with the `edit` command.  
Templates can be removed with the `rm` command, in which case new files will be empty.  
On calling `edit` on a removed template, it will be populated with the default content.  
If you want the generated new files to contain varible substitutions, you must use `${DOLLAR}{var}` in the template
e.g.
```
${var}
${DOLLAR}{var}
```
becomes
```
value of var
${var}
```
when a new file is created.

## Advanced Usage <a name="advanced"></a>
As the configuration files are all bash scripts, dynamic configuration is perfectly possible.  
To that end, there are several built in utilities to aid in this.  

### List of Functions <a name="advanced-functions"></a>
* error: print an error and stop
* load_variables: load variables file
* log: print all arguments to stderr
* log2: prints stdin to stderr, for use with <<- EOF notation
* generate_body: Run template engine against a body, file is stored in TMPFILES[-1]
* prompt: ask user for input and read a single line from stdin, e.g. input="$(prompt "Enter a value.")"
* prompt_selection: ask user to select something from a list of options, e.g. selection="$(prompt_selection "Choose an option!" "First option" "2")"
* send: send a different request, results will e located in TMPDIRS[-1] as files body, headers, raw_body, and response_code
* tmpdir: create a temporary directory that will be deleted on program exit, new dir is stored in TMPDIRS[-1]
* tmpfile: create a temporary file that will be deleted on program exit, new dir is stored in TMPFILES[-1]

### Chaining Requests <a name="advanced-chaining"></a>
If necessary, a request can send a request before it is sent.  
This is accomplished with the `send` function.  
For example, if you needed to get an access token first:
```
send "${service}" get-access-token
tokendir="${TMPDIRS[-1]}"
if [[ $(< "${tokendir}/response_code") != 200 ]] ; then
	error "Failed to get access token"
	exit 1
fi

HEADERS+=("access token header: $(< "${tokendir}/body")")
```

### User Input <a name="advanced-input"></a>
When prompting a user for input, always print to stderr.  
To that end, there is the `log` function, which prints all its arguments to stderr.  
There is also the `log2` function, which printed stdin to stderr, and so can be used with `<<- EOF` notation.  

There is also the prompt_selection command, which works much like the `select` builtin, but printing to stderr instead.  
The usage is `selection="$(prompt_selection <prompt> [choices...])"`  

### Dynamic Bodies <a name="advanced-bodies"></a>
Suppose you had a body like this:
```
This body is for service ${service}.
```

Just setting the body to that will not cause `${service} to be replace with the service name, instead that can be achieved like so:
```
REQUEST_BODY="a default body" # Set a default body that the user can override on the command line
generate_body # Generate a body from the --body option if set, or REQUEST_BODY if not
REQUEST_BODY_FORCE="${TMPFILES[-1]}" # Force the generated body to be sent
```

If you did not want to ignore that command line --body option, it can be simplified to this:
```
generate_body "a body" # Generate a body from "a body"
REQUEST_BODY_FORCE="${TMPFILES[-1]}" # Force the generated body to be sent
```

Note that `generate_body` uses `envsubst`, so it will not work with array variables.  
Further, if you want the literal text `${service}`, then you must use `${DOLLAR}{service}`
