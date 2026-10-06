FROM ruby:3.4-slim

# Install system dependencies needed for compiling certain Ruby gems
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev

# Set up the working directory
WORKDIR /app

# Copy dependency files first to leverage Docker's build cache
COPY Gemfile Gemfile.lock ./

# Install bundler and your gems
RUN gem install bundler && bundle install

# Copy the rest of the application code
COPY . .

# Render dynamically assigns a port via the $PORT environment variable
EXPOSE 5000
CMD ["bundle", "exec", "rackup", "--host", "0.0.0.0", "-p", "5000"]
