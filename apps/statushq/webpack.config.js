'use strict';

const webpack = require('webpack');
const path = require('path');
const ExtractTextPlugin = require("extract-text-webpack-plugin");
const CopyWebpackPlugin = require("copy-webpack-plugin");

const production = process.env.NODE_ENV === 'production';
const BUILD_DIR = path.resolve(__dirname, 'priv/static');
let entry = ['./lib/statushq_web/static/app/css/app.scss', './lib/statushq_web/static/app/js/app.js'];

const config = {
  devtool: process.env.DEBUG ? 'source-map' : undefined,
  entry: {
    app: entry,
  },
  output: {
    path: BUILD_DIR,
    filename: 'js/app.js',
  },
  module: {
    rules: [
      { test: /\.(js)$/, loader: 'babel-loader', exclude: /node_modules/, query: {presets: ["es2015"]} },
      { test: /\.scss$/, use: ExtractTextPlugin.extract({fallback: 'style-loader', use: ['css-loader', 'sass-loader']}) },
      { test: /\.css$/, use: ExtractTextPlugin.extract({fallback: 'style-loader', use: 'css-loader'}) },
      // { test: /\.(png|gif|ttf|otf|jpe?g|svg|eot|woff|woff2)$/i, loader: 'url-loader?limit=10000' },
    ],
  },

  node: {
    console: true,
    fs: 'empty',
    net: 'empty',
    tls: 'empty',
  },

  plugins: [
    // This plugins optimizes chunks and modules by
    // how much they are used in your app
    new webpack.optimize.OccurrenceOrderPlugin(),
    new ExtractTextPlugin('css/app.css'),
    new CopyWebpackPlugin([{ from: "./lib/statushq_web/static/app/assets" }]),
    new webpack.DefinePlugin({
      'process.env': {
        NODE_ENV: JSON.stringify(process.env.NODE_ENV),
        DEBUG: process.env.DEBUG,
      },
    }),
  ],
};

if (production) {
  config.plugins = config.plugins.concat([
    // This plugin prevents Webpack from creating chunks
    // that would be too small to be worth loading separately
    new webpack.optimize.MinChunkSizePlugin({
      minChunkSize: 51200, // ~50kb
    }),

    // This plugin minifies all the Javascript code of the final bundle
    new webpack.optimize.UglifyJsPlugin({
      mangle: true,
      compress: {
        warnings: false, // Suppress uglification warnings
      },
    }),
  ]);
}

module.exports = config;
