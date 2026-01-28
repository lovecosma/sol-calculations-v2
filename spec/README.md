# RSpec Test Suite

This directory contains the RSpec test suite for the Sol Calculations application.

## Setup

The following gems have been added to your `Gemfile`:

```ruby
group :development, :test do
  gem "rspec-rails", "~> 7.0"
  gem "factory_bot_rails", "~> 6.4"
  gem "faker", "~> 3.2"
end
```

### Installation

1. Install the gems:
   ```bash
   bundle install
   ```

2. Initialize the test database:
   ```bash
   rails db:test:prepare
   ```

## Running Tests

### Run all specs
```bash
bundle exec rspec
```

### Run a specific spec file
```bash
bundle exec rspec spec/controllers/charts_controller_spec.rb
```

### Run a specific test
```bash
bundle exec rspec spec/controllers/charts_controller_spec.rb:15
```

### Run with documentation format
```bash
bundle exec rspec --format documentation
```

## Directory Structure

```
spec/
├── controllers/
│   ├── charts_controller_spec.rb              # Main controller specs
│   └── charts_controller_with_factories_spec.rb  # Alternative using FactoryBot
├── factories/
│   ├── charts.rb           # Chart factory definitions
│   ├── chart_numbers.rb    # ChartNumber factory definitions
│   └── users.rb            # User factory definitions
├── support/
│   └── factory_bot.rb      # FactoryBot configuration
├── rails_helper.rb         # Rails-specific test configuration
├── spec_helper.rb          # General RSpec configuration
└── README.md               # This file
```

## Test Files

### ChartsController Specs

Two versions of the controller specs are provided:

1. **charts_controller_spec.rb** - Uses manual object creation (no factories required)
2. **charts_controller_with_factories_spec.rb** - Uses FactoryBot factories (cleaner, more maintainable)

You can rename `charts_controller_with_factories_spec.rb` to `charts_controller_spec.rb` once you've confirmed FactoryBot is working correctly.

### Factories

Factories are defined using FactoryBot and Faker for generating test data:

- **Users**: Creates test users with unique emails
- **Charts**: Creates charts with realistic names and birthdates
- **ChartNumbers**: Creates chart numbers with various types

### Using Factories

```ruby
# Create a user
user = create(:user)

# Create a user with charts
user = create(:user, :with_charts)

# Create a chart
chart = create(:chart, user: user)

# Create a chart with middle name
chart = create(:chart, :with_middle_name, user: user)

# Create attributes without saving
attributes = attributes_for(:chart)

# Build without saving
chart = build(:chart, user: user)
```

## What's Tested

The ChartsController specs test:

- ✅ **GET #index** - Lists user's charts in reverse chronological order
- ✅ **GET #show** - Displays a specific chart
- ✅ **GET #new** - Shows the new chart form
- ✅ **POST #create** - Creates new charts (valid and invalid cases)
- ✅ **GET #edit** - Shows the edit chart form
- ✅ **PATCH/PUT #update** - Updates charts (valid and invalid cases)
- ✅ **DELETE #destroy** - Deletes charts and associated records
- ✅ **Authentication** - Ensures users must be logged in
- ✅ **Authorization** - Users only see their own charts
- ✅ **Strong Parameters** - Only permitted attributes are accepted

## Coverage Areas

### Happy Paths
- Successful CRUD operations
- Proper redirects and responses
- Correct associations with users

### Edge Cases
- Invalid data handling
- Missing records (404 errors)
- Name format validation (too many names, whitespace-only)
- Associated records deletion (chart_numbers)

### Security
- Authentication requirements
- User data isolation (can't access other users' charts)
- Strong parameter filtering

## Next Steps

1. Run the specs to ensure they pass: `bundle exec rspec`
2. Add more specs for:
   - Model validations (spec/models/chart_spec.rb)
   - Service objects (spec/services/)
   - Request specs (spec/requests/)
   - Feature specs (spec/features/)
3. Consider adding code coverage with SimpleCov
4. Set up CI/CD to run tests automatically

## Troubleshooting

### Database Issues
```bash
rails db:test:prepare
rails db:drop db:create db:migrate RAILS_ENV=test
```

### FactoryBot Not Found
Make sure you've run `bundle install` after adding the gems to your Gemfile.

### Devise Test Helpers Not Working
The `rails_helper.rb` includes Devise test helpers. Make sure you're requiring `rails_helper` in your specs.
