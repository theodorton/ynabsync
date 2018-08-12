require "sidekiq"
require "./ynabsync"

Sidekiq::Client.default_context = Sidekiq::Client::Context.new

client = Sidekiq::Client.new
log = Logger.new(STDOUT)

loop do
  jid = Ynabsync::ImportWorker.async.perform()
  log.info "Scheduled job with ID #{jid}"
  sleep 30
end
