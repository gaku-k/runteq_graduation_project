# =============================
# Base stage: Ruby runtime
# =============================
ARG RUBY_VERSION=3.2.4
FROM ruby:${RUBY_VERSION}-slim AS base

# Set working directory
WORKDIR /rails

# Install basic packages needed for Rails runtime
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      curl \
      libjemalloc2 \
      libvips \
      postgresql-client \
      nodejs \
      yarn \
      tzdata \
      && rm -rf /var/lib/apt/lists/*

# Set environment variables for production
ENV RAILS_ENV=production \
    BUNDLE_DEPLOYMENT=1 \
    BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_WITHOUT=development:test

# =============================
# Build stage: install gems
# =============================
FROM base AS build

# Install packages required to build native gems
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      build-essential \
      gcc \
      g++ \
      make \
      git \
      libpq-dev \
      pkg-config \
      libffi-dev \
      zlib1g-dev \
      libyaml-dev \
      libgmp-dev \
      libreadline-dev \
      libssl-dev \
      autoconf \
      bison \
      libc6-dev \
      && rm -rf /var/lib/apt/lists/*

# Copy Gemfiles early for caching
COPY Gemfile Gemfile.lock ./

# Install gems
RUN bundle install --jobs 4 --retry 3 && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# Copy the rest of the application
COPY . .

# Precompile bootsnap code
RUN bundle exec bootsnap precompile app/ lib/

# Precompile assets for production (dummy secret)
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile

# =============================
# Final stage: production image
# =============================
FROM base

# Copy built gems and application from build stage
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

# Create non-root user for security
RUN groupadd --system --gid 1000 rails && \
    useradd --uid 1000 --gid 1000 --create-home --shell /bin/bash rails && \
    chown -R rails:rails db log storage tmp

USER rails

# Entrypoint and default command
ENTRYPOINT ["/rails/bin/docker-entrypoint"]
EXPOSE 3000
CMD ["./bin/rails", "server"]