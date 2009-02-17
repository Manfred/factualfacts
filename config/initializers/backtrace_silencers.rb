Rails.backtrace_cleaner.add_silencer { |line| line =~ %r{test/spec} }

# You can also remove all the silencers if you're trying do debug a problem that might steem from framework code.
# Rails.backtrace_cleaner.remove_silencers!