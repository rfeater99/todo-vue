const glob = require('glob')
const path = require('path')
const manifestPlugin = require('webpack-manifest-plugin')
const {VueLoaderPlugin} = require('vue-loader')

const packs = path.join(__dirname, 'app', 'javascript', 'packs')

const targets = glob.sync(path.join(packs, '**/*.{js,jsx,ts,tsx,vue}'))
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
    new VueLoaderPlugin(),
    new manifestPlugin({
      fileName: 'manifest.json',
      publicPath: '/packs/',
      writeToFileEmit: true,
    })
  ],
  module: {
    rules: [
      {
        test: /\.css$/,
        use: [
          'vue-style-loader',
          'css-loader'
        ]
      },
      {
        test: /\.vue$/,
        use: [{
          loader: 'vue-loader',
          options: { extractCSS: true }
        }]
      },
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
      },
    ]
  },
  devServer: {
    publicPath: '/packs/',
    contentBase: path.resolve(__dirname, 'public'),
    host: '0.0.0.0',
    port: 3035,
    disableHostCheck: true,
    headers: {
      'Access-Control-Allow-Origin': '*'
    }
  }
};
