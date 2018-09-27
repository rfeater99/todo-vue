## 入れたいもの
1. rails
2. mysql2
    - mysqlはdockerを利用
3. rspec
4. devise
5. haml
7. webpack4
    - entryを複数指定する
8. babel7
9. vue
10. vuex
11. element-ui

## 使いたいサービス
1. なんかロゴつくってくれるやつ
    - たしか何日か前のgigazineの記事にのってた
    - https://gigazine.net/news/20180827-hatchful/

## scaffolding
1. install rails
    - Gemfileを作成

    ```ruby :Gemfile
    source 'https://rubygems.org'
    gem 'rails', '~> 5.2.1'
    ```

    - bundle install --path vendor/bundle

2. rails scaffolding
    - rails new

    ```sh
    bundle exec rails new ./ -d mysql --skip-test-unit
    ```

    - bundle install

    ```sh
    bundle install
    ```
3. mysqlセッティング
    - `docker-compose.yml`作成

    ``` yaml :docker-compose.yml
    version: '3'

    services:
      database:
        image: mysql:5.7.22
        ports:
          - "3306:3306"
        environment:
          - MYSQL_USER=root
          - MYSQL_PASSWORD=root
          - MYSQL_DATABASE=${APP_NAME}_development
          - MYSQL_ROOT_PASSWORD=root
        volumes:
          - db-data:/var/lib/mysql

    volumes:
      db-data:
    ```

    - `docker-compose up -d`
    - `database.yml`修正

    ``` yaml
    - password:
    - host: localhost
    + password: root
    + host: 127.0.0.1
    ```

4. rspec setting
    - Gemfile追記

    ```ruby :Gemfile
    group :development, :test do
      gem 'rspec-rails'
      gem 'factory_bot_rails'
    end
    ```

    - bundle install
    - rspec install

    ```sh
    bundle exec rails g rspec:install
    ```

    - Factory botセッティング`spec/rails_helper.rb`に以下を追記

    ```ruby :spec/rails_helper.rb
    RSpec.configure do |config|
      # 色々な記述があるので、一番下に追記する
      config.include FactoryBot::Syntax::Methods
    end
    ```

5. devise setting
    - Gemfile追記

    ```ruby :Gemfile
    # Devise
    gem 'devise'
    ```

    - bundle install
    - deviseインストール

    ```sh
    bundle exec rails g devise:install
    ```

    - `config/environments/development.rb`の最後に以下を追記

    ```ruby :config/environments/development.rb
    # mailer setting
    config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
    ```

    - `Home#index`を追加

    ```sh
    bundle exec rails g controller Home index
    ```

    - `routes.rb`に以下を記載

    ```ruby :routes.rb
    root 'home#index'
    ```

    - `views/layouts/application.html.erb`にflashメッセージの表示設定
    ``` erb :view/layouts/application.html.erb
      <body>
        <p class="notice"><%= notice %></p> <!-- 追記 -->
        <p class="alert"><%= alert %></p> <!-- 追記 -->

        <%= yield %>
      </body>
    ```

    - deviseのviewを作成

    ```sh
    bundle exec rails g devise:views
    ```

    - devise userモデルの生成

    ```sh
    bundle exec rails g devise user
    ```
    
    - モデルにusernameを追加

    ```sh
    bundle exec rails g migration add_columns_to_users username
    ```

    - DBマイグレート実行

    ```sh
    bundle exec rake db:migrate
    ```

    - 追加したusernameが登録されるように`controllers/application_controller.rb`に`before_action`を追加

    ```ruby :controllers/application_controller.rb
    class ApplicationController < ActionController::Base
      before_action :confiture_permit_params, if: :devise_controller?
    
      protected
    
      def confiture_permit_params
        added_attrs = [ :username ]
        devise_parameter_sanitizer.permit :sign_up, keys: added_attrs
        devise_parameter_sanitizer.permit :account_update, keys: added_attrs
        devise_parameter_sanitizer.permit :sign_in, keys: added_attrs
      end
    end
    ```

5. hamlを使えるようにする

    - `Gemfile`に追記

    ```ruby :Gemfile
    gem 'haml-rails'
    group :development do
      gem 'erb2haml'
    end
    ```

    - `bundle install`
    - `erb`を`haml`に変換する
    ```sh
    bundle exec rake haml:replace_erbs
    ```
7. webpack4とbabel7を導入する.
    - 必要なモジュールをインストール
    ```sh
    yarn add --dev webpack webpack-cli babel-loader @babel/core @babel/preset-env @babel/polyfill glob path webpack-manifest-plugin vue-loader css-loader file-loader vue-template-compiler webpack-dev-server
    ```

    - `package.json`にコンパイルの設定を追加

    ```json :package.json
    "scripts": {
      "build": "webpack",
      "watch": "webpack -w"
    },
    ```

    - `app/javascropt/pack`以下のファイルをentryポイントとして、`public/pack`以下に出力するように`webpack.config.js`を作成

    ```javascript
    const glob = require('glob')
    const path = require('path')
    const manifestPlugin = require('webpack-manifest-plugin')

    const packs = path.join(__dirname, 'app', 'javascript', 'packs')

    const targets = glob.sync(path.join(packs, '**/*.{js,jsx,ts,tsx}'))
    const entry = targets.reduce((entry, target) => {
      const bundle = path.relative(packs, target)
      const ext = path.extname(bundle)

      return Object.assign({}, entry, {
        // Input: "application.js"
        // Output: { "application": "./application.js" }
        [bundle.replace(ext, '')]: './' + bundle,
      })
    }, {})

    module.exports = {
      // モード値を production に設定すると最適化された状態で、
      // development に設定するとソースマップ有効でJSファイルが出力される
      mode: 'production',

      context: packs,
      entry,
      output: {
        filename: '[name]-[hash].js',
        chunkFilename: '[name].bundle-[hash].js',
        path: path.resolve(__dirname, 'public', 'packs'),
        publicPath: '/packs/',
      },
      plugins: [
        new manifestPlugin({
          fileName: 'manifest.json',
          publicPath: '/packs/',
          writeToFileEmit: true,
        })
      ],
      module: {
        rules: [
          {
            // 拡張子 .js の場合
            test: /\.js$/,
            use: [
              {
                // Babel を利用する
                loader: 'babel-loader',
                // Babel のオプションを指定する
                options: {
                  presets: [
                    // プリセットを指定することで、ES2018 を ES5 に変換
                    '@babel/preset-env',
                  ]
                }
              }
            ]
          }
        ]
      }
    };
    ```

1. `webpack-dev-server`と`rails`を連携する
    - `rack-proxy`を`Gemfile`に追加
    - `bundle install`実行
    - `lib/dev_server_proxy.rb`の作成

    ``` ruby
    require 'rack/proxy'

    # webpack-dev-serverからのアセット取得をプロキシする -> localhost以外からもdev環境を見れるようにするため
    class DevServerProxy < Rack::Proxy

      def perform_request(env)
        if env['PATH_INFO'].start_with?('/packs/')
          env['HTTP_HOST'] = dev_server_host
          env['HTTP_X_FORWARDED_HOST'] = dev_server_host
          env['HTTP_X_FORWARDED_SERVER'] = dev_server_host
          super
        else
          @app.call(env)
        end
      end

      private

        def dev_server_host
          Rails.application.config.dev_server_host
        end
    end
    ```

    - `config/environment/development.rb`に以下を追加

    ```ruby
    config.middleware.use DevServerProxy, ssl_verify_none: true
    config.dev_server_host = 'localhost:3035'
    ```

1. foremanを設定
    - `foreman`を`Gemfile`に追加

    ```ruby :Gemfile
    gem 'foreman'
    ```