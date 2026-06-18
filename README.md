# Healthie Rails — Provider / Client Data Model

A small Rails app modeling **providers** (e.g. dietitians), their **clients**, and the
**health journal entries** clients post. Built as the foundation for a backend pairing
session focused on the data model.

## Domain model

- A **Provider** and a **Client** each have a `name` and `email`.
- Providers and clients have a **many-to-many** relationship through **`Membership`**.
- The **plan** (`basic` / `premium`) lives on the `Membership`, not the client — because a
  client can be on a different plan with each provider they're signed up with.
- A **JournalEntry** belongs to a client (freeform `body` text). A provider reaches a
  client's entries *through* their memberships.

```
Provider ──< Membership >── Client ──< JournalEntry
                 │
              plan (basic | premium)
```

## The required queries

| Question | How |
| --- | --- |
| All clients for a provider | `provider.clients` |
| All providers for a client | `client.providers` |
| A client's journal entries, by date | `client.journal_entries.oldest_first` |
| All entries across a provider's clients, by date | `provider.client_journal_entries` |

`JournalEntry.oldest_first` orders by `created_at` ascending (with `id` as a tiebreaker). `Provider#client_journal_entries`
aggregates across every client via a single subquery on the join table (no N+1) — see
[`app/models/provider.rb`](app/models/provider.rb).

## Getting started

Requires Ruby 3.3.6 (see `.ruby-version`). Uses SQLite — no external services needed.

```bash
bin/setup --skip-server   # install gems, prepare the database
bin/rails db:seed         # load demo providers, clients, memberships, and entries
bundle exec rspec         # run the test suite (23 examples)
bin/rails console         # try the queries interactively
```

Example in the console after seeding:

```ruby
dietitian = Provider.find_by!(email: "dietitian@example.com")
dietitian.clients.pluck(:name)            # => ["Ann Apple", "Bob Berry"]
dietitian.client_journal_entries.pluck(:body)

ann = Client.find_by!(email: "ann@example.com")
ann.providers.pluck(:name)                # => ["Dr. Dana Diet", "Coach Casey"]
ann.memberships.map { |m| [m.provider.name, m.plan] }
# => [["Dr. Dana Diet", "basic"], ["Coach Casey", "premium"]]  ← plan is per relationship
```

## Layout

```
app/models/        Provider, Client, Membership, JournalEntry
db/migrate/        schema migrations
db/seeds.rb        demo data
spec/              model specs + FactoryBot factories
```

This is a backend-only data-model foundation: no views, assets, or API layer yet —
`ApplicationController` is kept so an endpoint can be added during the session.
