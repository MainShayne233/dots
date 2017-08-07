# Dots

GenServers as Dots

![](https://media.giphy.com/media/l1J3LiBktdCd5iQJG/giphy.gif)

Run on your computer:

[Install Elixir](https://elixir-lang.org/install.html)

```bash
# clone and enter the repo
git clone https://www.github.com/MainShayne233/dots.git
cd dots

# install the dependencies
mix deps.get
mix assets.install

# start the server
mix phx.server
```

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Commands
```elixir
# create a dot
iex> Dot.new("Name", "color")

# change color
iex> Dot.set_color("Name", "blue")

# start/stop pulsing
iex> Dot.start_pulse("Name")
iex> Dot.stop_pulse("Name")

# kill
iex> Dot.kill("Name")
```

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: http://phoenixframework.org/docs/overview
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix
