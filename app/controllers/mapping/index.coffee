path = require('path')
fs = require('fs')
_ = require('lodash')
config = process.g.config
utils = process.g.utils
logger = require(path.join(__dirname, 'log'))
storage = require(path.join(__dirname, 'storage'))
modelsPath = path.join(process.g.modelsPath , 'mapping')



module.exports = {
	storage: (req, res)->
		storage((err)->
			if !err
				res.requestSucceed('数据已经被更新')
			else
				res.requestError('数据更新失败')
		, true)
	openLogin: (req, res)->
		log = new logger('login')
		log(req.query, (err)->
			if !err
				res.requestSucceed('数据提交成功')
			else
				res.requestError('fail')
		)
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
			Dao = require(process.g.daoPath)[model]

			Dao.count(criteria, (err, count)->
				Dao.list(criteria, {'timestamp': -1}, (err, docs)->
					if !err
						documents = []
						if docs.length
							keys = _.keys(docs[0]._doc)
							_.each(docs, (doc, index)->
								documents[index] = {}
								for key in keys
									if key != 'timestamp'
										documents[index][key] = doc[key]
									else
										documents[index]['timestamp'] = utils.formatTime(doc.timestamp)
							)
						data = {}
						data[model + 's'] = documents
						data['pagination'] = utils.pagination(page, perPage, count)
						res.requestSucceed(data || null);
					else
						res.requestError('获取列表失败');
				)
			)
}