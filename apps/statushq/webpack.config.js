'use strict';

const webpack = require('webpack');
const path = require('path');
const ExtractTextPlugin = require("extract-text-webpack-plugin");
const CopyWebpackPlugin = require("copy-webpack-plugin");
const CompressionPlugin = require('compression-webpack-plugin');

const production = process.env.NODE_ENV === 'production';
const BUILD_DIR = path.resolve(__dirname, 'priv/static');

const config = {
  mode: production ? 'production' : 'development',
  devtool: process.env.DEBUG ? 'source-map' : undefined,
  entry: {
    app: ['./lib/statushq_web/static/app/css/app.scss', './lib/statushq_web/static/app/js/app.js'],
    admin: ['./lib/statushq_web/static/admin/js/app.js', './lib/statushq_web/static/admin/css/app.scss'],
    status_page: ['./lib/statushq_web/static/status_page/js/app.js', './lib/statushq_web/static/status_page/css/app.scss'],
  },
  output: {
    path: BUILD_DIR,
    filename: 'js/[name].js',
    chunkFilename: 'js/[id].bundle.js',
    publicPath: '/'
  },
  module: {
    rules: [
      { test: /\.(js)$/, loader: 'babel-loader', exclude: /node_modules/ },
      { test: /\.scss$/, use: ExtractTextPlugin.extract({fallback: 'style-loader', use: ['css-loader', 'sass-loader']}) },
      { test: /\.css$/, use: ExtractTextPlugin.extract({fallback: 'style-loader', use: 'css-loader'}) },
      // { test: /\.(png|gif|ttf|otf|jpe?g|svg|eot|woff|woff2)$/i, loader: 'url-loader?limit=10000' },
    ],
  },
  node: { console: true, fs: 'empty', net: 'empty', tls: 'empty', },

  plugins: [
    // This plugins optimizes chunks and modules by
    // how much they are used in your app
    new webpack.optimize.OccurrenceOrderPlugin(),
    new ExtractTextPlugin('css/[name].css'),
    new CopyWebpackPlugin([{ from: "./lib/statushq_web/static/app/assets" }]),
    new CopyWebpackPlugin([
      { from: "../../node_modules/bootstrap-sass/assets/fonts/bootstrap", to: 'fonts' },
    ]),
    new webpack.DefinePlugin({
      'process.env': {
        NODE_ENV: JSON.stringify(process.env.NODE_ENV),
        DEBUG: process.env.DEBUG,
      },
    }),
    new webpack.ProvidePlugin({
      $: "jquery",
      jQuery: "jquery",
      "window.jQuery": "jquery"
    })
  ],
  'resolve': {
    'alias': {
      'react': 'preact-compat',
      'react-dom': 'preact-compat'
    }
  }
};

if (production) {
  config.plugins = config.plugins.concat([
    // This plugin prevents Webpack from creating chunks
    // that would be too small to be worth loading separately
    new webpack.optimize.MinChunkSizePlugin({
      minChunkSize: 51200, // ~50kb
    }),
    // Generate .gzip version of the bundle
    new CompressionPlugin({
      asset: '[path].gz[query]',
      algorithm: 'gzip',
      test: /\.js$|\.css$|\.html$/,
      threshold: 10240,
      minRatio: 0.8,
    }),
  ]);
}

if (process.env.ANALYZE) {
  config.plugins = config.plugins.concat([
    new (require('webpack-bundle-analyzer').BundleAnalyzerPlugin)(),
  ]);
}

module.exports = config;
