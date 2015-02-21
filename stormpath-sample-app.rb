if ENV['STORMPATH_API_KEY_FILE_LOCATION'].nil? || ENV['STORMPATH_APPLICATION_URL'].nil?
  raise 'Both STORMPATH_API_KEY_FILE_LOCATION and STORMPATH_APPLICATION_URL must be set'
end

require 'sinatra'
require 'rack-flash'
require 'stormpath-sdk'
require 'cgi'
require 'pry'
require 'omniauth-facebook'
require 'omniauth-google-oauth2'

require_relative 'helpers'
require_relative 'routes/init'

class SampleApp < Sinatra::Base

  set :root, File.dirname(__FILE__)

  set :client, Stormpath::Client.new({ api_key_file_location: ENV['STORMPATH_API_KEY_FILE_LOCATION'] })
  set :application, settings.client.applications.get(ENV['STORMPATH_APPLICATION_URL'])

  enable :method_override

  use Rack::Session::Cookie, key: 'rack.session', path: '/', expire_after: 2592000,
                             secret: '21314124432423423423423423434324234234'
  use Rack::Flash, sweep: true

  helpers Sinatra::SampleApp::Helpers

  register Sinatra::SampleApp::Routing::Accounts
  register Sinatra::SampleApp::Routing::AccountVerifications
  register Sinatra::SampleApp::Routing::Main
  register Sinatra::SampleApp::Routing::PasswordResetTokens
  register Sinatra::SampleApp::Routing::Session
  register Sinatra::SampleApp::Routing::AccountStoreMappings
  register Sinatra::SampleApp::Routing::GroupMemberships
  register Sinatra::SampleApp::Routing::Directories
  register Sinatra::SampleApp::Routing::Groups
  register Sinatra::SampleApp::Routing::Omniauth

  use OmniAuth::Builder do
    if ENV['STORMPATH_SINATRA_FACEBOOK_ID'] and ENV['STORMPATH_SINATRA_FACEBOOK_SECRET']
      provider :facebook, ENV['STORMPATH_SINATRA_FACEBOOK_ID'], ENV['STORMPATH_SINATRA_FACEBOOK_SECRET']
    end
    if ENV['STORMPATH_SINATRA_GOOGLE_ID'] and ENV['STORMPATH_SINATRA_GOOGLE_SECRET']
      provider :google_oauth2, ENV['STORMPATH_SINATRA_GOOGLE_ID'], ENV['STORMPATH_SINATRA_GOOGLE_SECRET']
    end
  end
end
