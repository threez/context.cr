# context [![.github/workflows/ci.yml](https://github.com/threez/context.cr/actions/workflows/ci.yml/badge.svg)](https://github.com/threez/context.cr/actions/workflows/ci.yml) [![https://threez.github.io/context.cr/](https://badgen.net/badge/api/documentation/green)](https://threez.github.io/context.cr/)

Coming from languages like golang you might miss the equivalent of a context providing
library to help support your cross functional requirements. This library adds the 
context right to the current `Fiber`. It handles immutable context variables using `Fiber.current.with_values` that can be accessed by `Fiber.current[]`.

The heavy lifting is done by the stdlib `Log::Metadata` implementation.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     context:
       github: threez/context.cr
   ```

2. Run `shards install`

## Usage



```crystal
require "context"
require "http/server"
require "http/client"

class AuthHandler
  include HTTP::Handler

  def call(context)
    # take token from request and verify it
    Fiber.current.with_values token: "123" do
      call_next(context)
    end
  end
end

# lets assume that is a different internal micro service that wants to get the token...
client = HTTP::Client.new(URI.parse("https://example.com"))
client.before_request do |context|
  context.headers["Authorization"] = "Bearer #{Fiber.current[:token]}"
end

server = HTTP::Server.new([
  AuthHandler.new,
]) do |context|
  context.response.content_type = "text/plain"
  context.response.print "Hello world, got #{context.request.path}!"

  client.get("/secret/data")
end

puts "Listening on http://127.0.0.1:8080"
server.listen(8080)
```

## Resources

* [Forum Discussion](https://forum.crystal-lang.org/t/how-do-you-manage-context/5572)

## Contributing

1. Fork it (<https://github.com/threez/context/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [threez](https://github.com/threez) - creator and maintainer
