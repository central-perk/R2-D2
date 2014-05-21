fs         = require('fs')
path       = require('path')
_          = require('lodash')
mongoose   = require('mongoose')
modelsPath = path.join(__dirname , 'mapping')

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

# # 注册动态模型
# dataModel = mongoose.model('dataModel')

# dataModel.find({}, (err, oModels)->
# 	_.each(oModels, (oModel)->
# 		oSchema = {}
# 		sModel = oModel.name
# 		aAttributes = oModel.attributes
# 		_.each(aAttributes, (oAttribute)->
# 			oSchema[key] = 
# 		)


# 		oSchema.timestamp = Date
# 		schema = new Schema(oSchema)
# 		mongoose.model(sModelName, schema)
# 	)
# )

