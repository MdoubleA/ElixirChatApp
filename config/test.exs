use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :interface_web, InterfaceWeb.Endpoint,
  http: [port: 4002],
  server: false
