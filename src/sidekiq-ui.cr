require "sidekiq/web"

# Basic authentication:
#
require "kemal-basic-auth"
basic_auth "admin", ENV["KEMAL_PASSWORD"]

Kemal.config do |config|
  # To enable SSL termination:
  # ./web --ssl --ssl-key-file your_key_file --ssl-cert-file your_cert_file
  #
  # For more options, including changing the listening port:
  # ./web --help
end

Kemal::Session.config.secret = "my_super_secret"

# Exact same configuration for the Client API as above
Sidekiq::Client.default_context = Sidekiq::Client::Context.new

Kemal.run
