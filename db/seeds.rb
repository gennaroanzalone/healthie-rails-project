# Seed data for the pairing session. Idempotent: safe to run repeatedly.
#
# Shape:
#   - 2 providers (a dietitian and a coach)
#   - 3 clients, with overlapping memberships and mixed plans
#   - a handful of journal entries with varied timestamps
#
# After seeding, all four required queries return non-trivial, ordered results.

dietitian = Provider.find_or_create_by!(email: "dietitian@example.com") do |p|
  p.name = "Dr. Dana Diet"
end

coach = Provider.find_or_create_by!(email: "coach@example.com") do |p|
  p.name = "Coach Casey"
end

ann = Client.find_or_create_by!(email: "ann@example.com")   { |c| c.name = "Ann Apple" }
bob = Client.find_or_create_by!(email: "bob@example.com")   { |c| c.name = "Bob Berry" }
cleo = Client.find_or_create_by!(email: "cleo@example.com") { |c| c.name = "Cleo Cherry" }

# Ann sees both providers — on different plans (the key per-relationship plan behavior).
Membership.find_or_create_by!(provider: dietitian, client: ann)  { |m| m.plan = "basic" }
Membership.find_or_create_by!(provider: coach,     client: ann)  { |m| m.plan = "premium" }
# Bob is premium with the dietitian only.
Membership.find_or_create_by!(provider: dietitian, client: bob)  { |m| m.plan = "premium" }
# Cleo is basic with the coach only.
Membership.find_or_create_by!(provider: coach,     client: cleo) { |m| m.plan = "basic" }

journal = {
  ann  => [ [ "Started a new meal plan today.", 5.days.ago ],
           [ "Energy is up this week.",        1.day.ago ] ],
  bob  => [ [ "Skipped breakfast, felt sluggish.", 3.days.ago ] ],
  cleo => [ [ "First workout done!",               2.days.ago ],
           [ "Sore but motivated.",               6.hours.ago ] ]
}

journal.each do |client, entries|
  entries.each do |body, at|
    client.journal_entries.find_or_create_by!(body: body) { |e| e.created_at = at }
  end
end

puts "Seeded: #{Provider.count} providers, #{Client.count} clients, " \
     "#{Membership.count} memberships, #{JournalEntry.count} journal entries."
