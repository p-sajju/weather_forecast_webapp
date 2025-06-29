Weather Forecast Rails Application

A full-stack Ruby on Rails application that allows users to enter an address or ZIP code and receive weather forecasts. The app integrates external geocoding and weather services, caches results with Redis, and applies per-IP rate limiting on the forecast submission endpoint—all without relying on external gems like rack-attack.
Features

    User-friendly web interface with form input for address or ZIP code

    Geocoding and weather forecast data fetched from external APIs

    Redis caching of forecast results for 30 minutes to optimize performance

    Per-IP rate limiting (50 requests per hour) on the forecast submission route

    Graceful error handling with flash messages and redirects

    Displays forecast results in a dedicated view

    MVC architecture with clean separation of concerns
  Requirements

    Ruby 3.3.x

    Rails 7.x

    Redis server running locally or remotely

    Bundler for managing gems

Setup and Installation

    Clone the repository

git clone <your-repo-url>
cd <your-app-directory>

Install dependencies

bundle install

Configure Redis
Create an initializer config/initializers/redis.rb:

$redis = Redis.new(url: ENV.fetch("REDIS_URL", "redis://localhost:6379/1"))

Ensure Redis is installed and running on your machine or server.

Configure external APIs

Add any required API keys or environment variables for your geocoding and weather services.

Database setup

If your app uses a database:

rails db:create
rails db:migrate

Start the Rails server

rails server

Visit the application

Navigate to http://localhost:3000 to access the app.
Usage

    Enter an address or ZIP code in the homepage form.

    Submit to get the weather forecast.

    Forecasts are cached for 30 minutes to reduce API calls.

    If the forecast for the ZIP code is cached, it will be retrieved instantly.

    The app limits the number of forecast requests per IP to 50 per hour to prevent abuse.

    Rate limit violations show an error message informing users of the limit.
Running Tests

Tests are written with RSpec:

bundle exec rspec
