module Sinatra
  module SampleApp
    module Routing
      module Accounts

        def self.registered(app)

          app.get '/accounts' do
            require_logged_in

            accounts = settings.application.accounts.map do |account|
              {
                :username => account.username,
                :email => account.email,
                :edit_route => "/accounts/#{CGI.escape(account.href)}/edit",
                :delete_route => "/accounts/#{CGI.escape(account.href)}",
                :manage_group_memberships => "/accounts/#{CGI.escape(account.href)}/group_memberships",
                :deletable => is_admin?
              }
            end

            render_view :accounts, { :accounts => accounts }
          end

          app.get '/accounts/:account_url/edit' do
            require_logged_in

            account = settings.client.accounts.get CGI.unescape(params[:account_url])

            render_view :accounts_edit, { :account => account }
          end

          app.patch '/accounts/:account_url' do
            require_logged_in

            account = settings.client.accounts.get CGI.unescape(params[:account_url])
            account.given_name = params[:given_name]
            account.surname = params[:surname]
            account.email = params[:email]
            account.custom_data[:favorite_color] = params[:custom_data][:favorite_color]
            account.save

            flash[:notice] = 'Account edited successfully.'

            redirect '/accounts'
          end

          app.delete '/accounts/:account_url' do
            require_logged_in

            account = settings.client.accounts.get CGI.unescape(params[:account_url])
            account.delete

            flash[:notice] = 'Account deleted successfully'

            redirect '/accounts'
          end

          app.get '/accounts/new' do
            account = Stormpath::Resource::Account.new({})

            render_view :accounts_new, { :account => account }
          end

          app.post '/accounts' do
            account_params  = params.select do |k, v|
              %W[given_name surname email username password].include?(k)
            end

            account = Stormpath::Resource::Account.new account_params

            begin
              account = settings.application.accounts.create account
              account.custom_data[:favorite_color] = params[:custom_data][:favorite_color]
              account.save
              flash[:notice] = 'Your account was created successfully. Depending on directory configuration, you may need to validate account-creation through email.'
              redirect '/session/new'
            rescue Stormpath::Error => error
              flash[:notice] = error.message
              render_view :accounts_new, { :account => account }
            end
          end

        end

      end
    end
  end
end
