fs         = require('fs')
path       = require('path')
_          = require('lodash')
mongoose   = require('mongoose')
Schema     = mongoose.Schema
modelsPath = path.join(__dirname , 'mapping')
utils      = process.g.utils
oAttrValueMap = {
	String: String,
	Date: Date,
}




# 注册静态模型
_.each(fs.readdirSync(modelsPath), (file, index)->
	require(path.join(modelsPath, file))
	sModel = file.replace('.js', '')
	module.exports[sModel] = mongoose.model(sModel)
	return
)

# # # 注册动态模型
# logModel = mongoose.model('logModel')

# logModel.find({}, (err, oLogModels)->
# 	_.each(oLogModels, (oLogModel)->
# 		oSchema = {}
# 		sModel = oLogModel.type
# 		aAttributes = oLogModel.attributes
# 		_.each(aAttributes, (oAttribute)->
# 			key = oAttribute.key
# 			value = oAttribute.value
# 			oSchema[key] = oAttrValueMap[value]
# 		)
# 		oSchema.timestamp = {
# 			type: Date,
# 			get: utils.formatTime
# 		}
# 		schema = new Schema(oSchema)
# 		mongoose.model(sModel, schema)
# 	)
# )

