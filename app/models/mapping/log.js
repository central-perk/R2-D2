var path = require('path'),
	fs = require('fs-extra'),
	mongoose = require('mongoose'),
	Schema = mongoose.Schema,
	_ = require('lodash');

var config = process.g.config,
	utils = process.g.utils,
	filePath = process.g.path,
	modelName = path.basename(__filename, '.js');

// 必须是同步的，否则无法在index中exports
var schemaConfig = utils.getSchemaConfig(modelName),
	schemaObj = {
		attrs: [{
			fieldName: String, // 字段中文名
			labelName: String, // 字段英文名
			fieldType: String  // 字段类型
		}],
		ts: {
			get: utils.dateTimeFormat,
			default: Date.now
		}
	};

schemaObj = _.merge(schemaConfig, schemaObj);
var schema = new Schema(schemaObj);
mongoose.model(modelName, schema);
