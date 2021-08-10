const path = require('path');

module.exports = {
	entry: {
		paywall: './src/paywall.js',
	},
	output: {
		path: path.resolve(__dirname, 'public/dist'),
		filename: '[name].min.js',
	},
	module: {
		rules: [
			{
				test: /\.scss$/,
				use: [
					"style-loader",
					"css-loader",
					"sass-loader",
				],
			}
		]
	},
};
