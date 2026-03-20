# Sol Calculations

A numerology chart calculator. Generate personal charts or browse a public celebrity chart database. Numerology numbers (Life Path, Expression, Soul Urge, Personality, Birthday) are calculated from names and birthdates.

**Deployed:** https://sol-calculations-2a5543766a23.herokuapp.com/

## Requirements

- Ruby (see `.ruby-version`)
- Node.js / npm
- PostgreSQL

## Setup

```bash
bundle install
npm install
bin/rails db:setup
```

## Development

```bash
foreman start
```

Starts Rails, ESBuild, Tailwind CSS, and Solid Queue together.

## Tests

```bash
bundle exec rspec                           # Ruby specs
bundle exec rspec spec/path/to/spec.rb:42   # single example

npm test                                    # Jest (JS unit tests)
npm run test:e2e                            # Playwright E2E
```

## Linting

```bash
bundle exec rubocop
```
