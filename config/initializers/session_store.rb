# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :session_key => '_factualfacts_session',
  :secret      => '8acf07797855107512f6e99e49435757c5f81b1898bd7d84f4791c8a8a482883d434f6e7ed80af53d835e6bbb187a7a5ec9484df7afc2808ee7d2d5fd04d34b4'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
