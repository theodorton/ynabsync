FROM crystallang/crystal:0.25.1

RUN mkdir /src
WORKDIR /src

ADD shard.yml shard.lock ./
RUN shards install

ADD src /src/src
RUN mkdir bin
RUN crystal build --release src/scheduler.cr -o bin/scheduler
RUN crystal build --release src/sidekiq-worker.cr -o bin/sidekiq-worker
RUN crystal build -D without_openssl --release src/sidekiq-ui.cr -o bin/sidekiq-ui
ADD Procfile /src

# RUN shards build --production
# RUN ldd bin/scheduler | tr -s '[:blank:]' '\n' | grep '^/' | \
#     xargs -I % sh -c 'mkdir -p $(dirname deps%); cp % deps%;'
# RUN ldd bin/sidekiq-worker | tr -s '[:blank:]' '\n' | grep '^/' | \
#     xargs -I % sh -c 'mkdir -p $(dirname deps%); cp % deps%;'
# RUN ldd bin/sidekiq-ui | tr -s '[:blank:]' '\n' | grep '^/' | \
#     xargs -I % sh -c 'mkdir -p $(dirname deps%); cp % deps%;'
