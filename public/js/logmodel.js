define(['jquery', 'base', 'hbs!/modules/logmodel_form'], function($, base, formTpl) {
	$('.container').on('click', '.create_logmodel', function() {
		if (confirm('确定创建日志模型？')) {
			var url = '/logmodel';
			var appID = $('#app select').val(),
				nSelectIndex = $("#app select").get(0).selectedIndex,
				token = $('#app select option').eq(nSelectIndex).attr('token'),
				name = $('#sLogModelName').val(),
				cname = $('#sLogModelCname').val(),
				attr = [];
			$('#attributes .form-group').each(function() {
				var name = $(this).find('.name').val(),
					cname = $(this).find('.cname').val(),
					dataType = $(this).find('.data-type').val();
				if (name) {
					attr.push({
						name: name,
						cname: cname,
						dataType: dataType
					})
				}
			});
			$.post(url, {
				appID: appID,
				token: token,
				name: name,
				cname: cname,
				attr: attr
			}, function(data) {
				if (data.code === 200) {
					base.show_success('日志模型创建成功')
					setTimeout(function() {
						location.reload()
					}, 100)
				} else {
					base.show_error(data.msg)
				}
			});
		}
	});
	$('.container').on('click', '.show_logmodel_form', function() {
		$('.logmodel_form').slideToggle();
	});
	// 添加参数
	$('.container').on('click', '.add_attr', function() {
		var $attr = $('.form-horizontal>.attr_tpl').clone();
		$('#attributes').append($attr[0].outerHTML)
	});
	// 删除参数
	$('.container').on('click', '.del_attr', function() {
		nIndex = $(this).parent().parent().index()
		$('#attributes .form-group').eq(nIndex).remove()
	});
	// 编辑日志
	$('.container').on('click', '.edit_logmodel', function() {
		var $tr = $(this).parent().parent(),
			$app = $tr.find('td').eq(0),
			appName = $app.text(),
			appID = $app.attr('appID'),
			token = $app.attr('token'),
			sName = $tr.find('td').eq(1).attr('name');
		$.get('/logmodel/?appID=' + appID + '&name=' + sName, function(data) {
			if (data.code === 200) {
				var oMsg = data.msg,
					sName = oMsg.name,
					sCname = oMsg.cname,
					aAttr = oMsg.attr,
					sDataType = $('.data-type').eq(0)[0].outerHTML,
					edit_form = formTpl({
						appName: appName,
						appID: appID,
						token: token,
						name: sName,
						cname: sCname,
						attr: aAttr,
						sDataType: sDataType
					});
				$('.content').empty();
				$('.content').append(edit_form);
			}
		});
	});
	// 更新日志
	$('.container').on('click', '.update_logmodel', function() {
		if (confirm('确定保存日志模型？')) {
			var url = '/logmodel';
			var appName = $('#appName').val(),
				appID = $('#appName').attr('appID'),
				token = $('#appName').attr('token'),
				name = $('#sLogModelName').val(),
				cname = $('#sLogModelCname').val(),
				attr = [];
			$('#attributes .form-group').each(function() {
				var name = $(this).find('.name').val(),
					cname = $(this).find('.cname').val(),
					dataType = $(this).find('.data-type').val();
				if (name) {
					attr.push({
						name: name,
						cname: cname,
						dataType: dataType
					})
				}
			});
			$.ajax({
				url: url,
				type: 'PUT',
				data: {
					appID: appID,
					token: token,
					name: name,
					cname: cname,
					attr: attr
				},
				success: function(data) {
					base.show_error(data.msg)
					setTimeout(function() {
						location.reload()
					}, 1500)
				}
			});
		}
	});
	$('.container').on('click', '.cancel_logmodel', function() {
		location.reload()
	});
})