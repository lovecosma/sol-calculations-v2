# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

### Development server
```bash
foreman start   # starts Rails, ESBuild, Tailwind, and Solid Queue together
```

### Tests
```bash
bundle exec rspec                          # all Ruby specs
bundle exec rspec spec/path/to/spec.rb     # single file
bundle exec rspec spec/path/to/spec.rb:42  # single example

npm test                   # all Jest specs
npm run test:e2e           # Playwright E2E (requires server on port 3001)
npm run test:e2e:ui        # Playwright with interactive UI
```

### Linting
```bash
bundle exec rubocop        # Ruby (rubocop-rails-omakase rules)
```

## Architecture

### What the app does
A numerology chart calculator. Users can generate personal charts; a public celebrity chart database can be browsed and filtered. Numerology numbers (Life Path, Expression, Soul Urge, Personality, Birthday) are calculated from names and birthdates.

### Models
Charts use STI: `UserChart < Chart` (owned by a user) and `CelebrityChart < Chart` (public, paired with a `Celebrity`). The numerology data model is:

```
Chart → ChartNumber → NumerologyNumber → Number (value 1–33)
                                       → NumberType (life_path, expression, soul_urge, personality, birthday)
```

`Number` and `NumberType` rows are shared across all charts. `NumerologyNumber` is the intersection — it holds content (descriptions, titles) for a specific number+type combination.

### Business logic
Domain logic lives in `app/domain/`, not in models or controllers:
- `Charts::Numbers::Builder` — orchestrates chart number creation
- `Numbers::Calculators::*` — one calculator per number type
- `CelebrityCharts::Creator` / `PeopleFetcher` / `API` — celebrity data pipeline
- `NumerologyNumbers::Descriptions::Builder` — AI-generated descriptions via OpenAI

### Frontend
- **Slim** templates throughout (`*.html.slim`)
- **Tailwind CSS** built via `@tailwindcss/cli` to `app/assets/builds/`
- **ESBuild** bundles `app/javascript/` to `app/assets/builds/`
- **Turbo** (Hotwire) for frame-based page updates; forms target named turbo frames via `data: { turbo_frame: "frame_id" }`
- **Stimulus** controllers in `app/javascript/controllers/`; must be manually registered in `index.js`
- **ViewComponent** for reusable UI (`app/components/`)

### Testing patterns
- Controller specs use `type: :controller` with Devise test helpers
- Factories use `find_or_create_by` for lookup tables (`Number`, `NumberType`, `NumerologyNumber`) to avoid uniqueness conflicts
- Stimulus controllers have Jest unit tests in `spec/javascript/controllers/`; complex interaction tests use Playwright in `e2e/`
- E2E tests authenticate once via global setup and reuse `e2e/.auth-state.json`
- Prefer using factories when there is no strong tradeoff.
- Prefer one assertion per test.