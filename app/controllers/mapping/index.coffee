fs = require('fs')
path = require('path')
_ = require('lodash')
mongoose = require('mongoose')
config = process.g.config
utils = process.g.utils
logger = require(path.join(__dirname, 'log'))
storage = require(path.join(__dirname, 'storage'))

require(process.g.modelsPath)

module.exports = {
	fWriteLog: (req, res)->
		sModel = req.type
		if !require('mongoose').models[sModel] # 模型不存在
			res.error('日志类型不存在，请先创建')
		fWriteLog = new logger(sModel)
		fWriteLog(req.query, (err)->
			if !err
				res.success('数据提交成功')
			else
				res.error('数据提交失败')
		)
	storage: (req, res)->
		storage((err)->
			if !err
				res.success('数据已经被更新')
			else
				res.error('数据更新失败')
		, true)
	list: (model)->
		return (req, res)->
			page = if (req.param('page') or 0) > 0 then req.param('page') else 1
			perPage = config.PERPAGE
			criteria = {
				query: {},
				options: {
					page: page - 1,
					perPage: perPage
				}
			}
			Model = mongoose.model(model)
			Model.find({}, (err, logs)->
				if !err
					res.success(logs);
				else
					res.error('获取列表失败');
			)


			# Model = mongoose
			# Dao = require(process.g.daoPath)[model]

			# Dao.count(criteria, (err, count)->
			# 	Dao.list(criteria, {'timestamp': -1}, (err, docs)->
			# 		if !err
			# 			documents = []
			# 			if docs.length
			# 				keys = _.keys(docs[0]._doc)
			# 				_.each(docs, (doc, index)->
			# 					documents[index] = {}
			# 					for key in keys
			# 						if key != 'timestamp'
			# 							documents[index][key] = doc[key]
			# 						else
			# 							documents[index]['timestamp'] = utils.formatTime(doc.timestamp)
			# 				)
			# 			data = {}
			# 			data[model + 's'] = documents
			# 			data['pagination'] = utils.pagination(page, perPage, count)
			# 			res.success(data || null);
			# 		else
			# 			res.error('获取列表失败');
			# 	)
			# )
}