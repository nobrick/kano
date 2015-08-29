RSpec.configure do |config|
  config.use_transactional_examples = false
  config.use_transactional_fixtures = false

  # TRUNCATE is not necessarily slower than DELETE for PostgreSQL, so we use :deletion strategy for cleaning up before entire test suite.
  # See http://stackoverflow.com/questions/11419536/postgresql-truncation-speed/11423886#11423886
  config.before(:suite) do
    DatabaseCleaner.clean_with :deletion
  end

  config.before(:each) do |example|
    # TRANSACTION may result in undesirable behaviors for JavaScript tests. Use :deletion instead.
    DatabaseCleaner.strategy = example.metadata[:js] ? :deletion : :transaction

    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
    Redis::Objects.redis.flushdb
  end
end
