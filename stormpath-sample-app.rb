if ENV['STORMPATH_API_KEY_FILE_LOCATION'].nil? && ENV['STORMPATH_APPLICATION_URL'].nil?
  raise 'Both STORMPATH_API_KEY_FILE_LOCATION and STORMPATH_APPLICATION_URL must be set'
end

require 'sinatra'
require 'rack-flash'
require 'stormpath-sdk'
require 'cgi'
require 'pry'

require_relative 'helpers'
require_relative 'routes/init'

class SampleApp < Sinatra::Base

  set :root, File.dirname(__FILE__)

  set :client, Stormpath::Client.new({ api_key_file_location: ENV['STORMPATH_API_KEY_FILE_LOCATION'] })
  set :application, settings.client.applications.get(ENV['STORMPATH_APPLICATION_URL'])

  enable :sessions
  enable :method_override

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
end
