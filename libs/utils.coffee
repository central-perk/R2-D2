path 	= require('path')
fs 		= require('fs-extra')
_ 		= require('lodash')
moment 	= require('moment')
crypto 	= require('crypto')
pm2 	= require('pm2')


getUTC = (date)->
	moment(date).utc().zone(-8)

# 校验长度必须等于
validateLength = (fieldValue)->
	(val)->
		val.length == fieldValue.length

# 校验长度必须处于
validateMaxMinLength = (fieldValue)->
	minLength = fieldValue.minLength
	maxLength = fieldValue.maxLength
	(val)->
		minLength < val.length < maxLength

# 校验长度必须大于
validateMinLength = (fieldValue)->
	minLength = fieldValue.minLength
	(val)->
		minLength < val.length

# 校验长度必须小于
validateMaxLength = (fieldValue)->
	maxLength = fieldValue.maxLength
	(val)->
		val.length < maxLength


module.exports = {
	# 设置全局上下文
	setG: (rootPath)->
		self = this
		app 	= path.join(rootPath, 'app')
		config 	= path.join(rootPath, 'config')
		libs 	= path.join(rootPath, 'libs')
		pub 	= path.join(rootPath, 'pub')
		process.g = {
			config: require(config),
			utils: self,
			path: {
				root: rootPath,
				app,
				config,
				libs,
				pub
			}
		}

		# app文件夹下子文件夹路径
		_.each(fs.readdirSync(app), (dir, index)->
			dirPath = path.join(app, dir)
			process.g.path[dir] = dirPath
		)
		
		# libs文件夹下子文件路径
		_.each(fs.readdirSync(libs), (file, index)->
			if ~file.indexOf('.js')
				fileName = file.replace('.js', '')
				process.g.path[fileName] = path.join(libs, file)
		)
		packageJSON = require(path.join(rootPath, 'package.json'))
		process.g.packageJSON = packageJSON

	# 读取scheme的配置文件
	getSchemaConfig: (schemaName)->
		config = process.g.config
		FIELD_TYPE_MAP = config.FIELD_TYPE_MAP

		schemaFileName = schemaName + '.json'
		modelsPath = process.g.path.models;
		schemaConfigFilePath = path.join(modelsPath, 'config', schemaFileName)
		schemaConfig = JSON.parse(fs.readFileSync(schemaConfigFilePath, 'utf8'))
		_.forEach(schemaConfig, (fieldValue, fieldKey)->
			# 类型转换
			fieldValue.type = FIELD_TYPE_MAP[fieldValue.type]
			
			if fieldValue.required
				fieldValue.required = "#{fieldValue.label}不能为空"

			# 校验
			validate = []
			if fieldValue.length
				validate.push({
					validator: validateLength(fieldValue),
					msg: "#{fieldValue.label}长度必须为#{fieldValue.length}"
				})

			if fieldValue.minLength and fieldValue.maxLength
				validate.push({
					validator: validateMaxMinLength(fieldValue),
					msg: "#{fieldValue.label}长度必须为#{fieldValue.minLength}-#{fieldValue.maxLength}"
				})
			else if fieldValue.minLength
				validate.push({
					validator: validateMinLength(fieldValue),
					msg: "#{fieldValue.label}长度必须大于#{fieldValue.minLength}"
				})
			else if fieldValue.maxLength
				validate.push({
					validator: validateMaxLength(fieldValue),
					msg: "#{fieldValue.label}长度必须小于#{fieldValue.minLength}"
				})

			# 将验证条件加入
			if validate.length
				fieldValue.validate = validate

			# 删除不必要的字段
			delete fieldValue.label
			delete fieldValue.minLength
			delete fieldValue.maxLength
		)
		return schemaConfig
	dateTimeFormat: (date)->
		getUTC(date).format("YYYY-MM-DD HH:mm")
	tsFormat: (date)->
		getUTC(date).format("YYYYMMDDHHmmss")
	md5: (text)->
		crypto.createHash('md5').update(text).digest('hex')
	createToken: (text)->
		randomNumber = Math.random()
		text = text + String(randomNumber)
		this.md5(text)
	createID: (length)->
		length = length || 8
		chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXTZabcdefghiklmnopqrstuvwxyz'.split('')
		str = ''
		for i in [1..length]
			str += chars[Math.floor(Math.random() * chars.length)]
		return str
	getCtrl: (ctrlName)->
		return require(path.join(process.g.path.controllers, 'mapping', ctrlName))
	getDao: (daoName)->
		return require(process.g.path.daos)[daoName]
	restart: ()->
		processName = process.g.packageJSON.name
		pm2.restart(processName)

	# 暂时未用到
	walk: (rootPath, include, exclude, removePath)->
		output = []
		directories = []
		include = include or /(.*)\.js$/

		_.each(fs.readdirSync(rootPath), (file, index)->
			newRootPath = path.join(rootPath, file)
			stat = fs.statSync(newRootPath)
			if stat.isFile()
				if include.test(file) and (!exclude or !exclude.test(file))
					output.push(newRootPath.replace(removePath, ''))
			else if stat.isDirectory()
				if !exclude or !exclude.test(file)		
					directories.push(newRootPath)
		)
		_.each(directories, (dir, index)->
			output = output.concat(walk(dir, include, exclude, removePath))
		)
		return output
}