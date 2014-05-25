define(['jquery', 'base', 'hbs!/modules/logmodel_form'], function($, base, formTpl) {
	$('.container').on('click', '.create_logmodel', function() {
		if (confirm('确定创建日志模型？')) {
			var url = '/logmodel';
			var appID = $('#app select').val(),
				nSelectIndex = $("#app select").get(0).selectedIndex,
				token = $('#app select option').eq(nSelectIndex).attr('token'),
				type = $('#sLogModelName').val(),
				attributes = [];
			$('#attributes .form-group').each(function() {
				var key = $(this).find('.key').val(),
					value = $(this).find('.value').val();
				if (key) {
					attributes.push({
						key: key,
						value: value
					})
				}
			});
			$.post(url, {
				appID: appID,
				token: token,
				type: type,
				attributes: attributes
			}, function(data) {
				if (data.status) {
					base.show_success('日志模型创建成功')
					setTimeout(function() {
						location.reload()
					}, 100)
				} else {
					base.show_error(data.message)
				}
			});
		}
	});
	$('.container').on('click', '.show_logmodel_form', function() {
		$('.logmodel_form').slideToggle();
	});
	$('.container').on('click', '.add_attr', function() {
		nAttr = $('#attributes .form-group').length
		nIndex = $(this).parent('.form-group').index() + 1
		if (nAttr == nIndex) {
			$attr = $(this).parent('.form-group').clone()
			$attr.find('label').empty();
			var html = $attr[0].outerHTML;
			$('#attributes').append(html)
		}
	});
	$('.container').on('click', '.del_attr', function() {
		nIndex = $(this).parent().parent().index()
		console.log(nIndex)
		$('#attributes .form-group').eq(nIndex).remove()
	});
	$('.container').on('click', '.edit_logmodel', function() {
		var $tr = $(this).parent().parent(),
			$app = $tr.find('td').eq(0),
			appName = $app.text(),
			appID = $app.attr('appID'),
			token = $app.attr('token'),
			sLogModelName = $tr.find('td').eq(1).text();
		$.get('/logmodel/?appID=' + appID + '&type=' + sLogModelName, function(data) {
			if (data.status) {
				var aAttributes = data.message.attributes,
					attrValue = $('.value').eq(0)[0].outerHTML,
					edit_form = formTpl({
						appName: appName,
						appID: appID,
						token: token,
						sLogModelName: sLogModelName,
						aAttributes: aAttributes,
						attrValue: attrValue
					});
				$('.content').empty();
				$('.content').append(edit_form);
			}
		});
	});
	$('.container').on('click', '.update_logmodel', function() {
		if (confirm('确定保存日志模型？')) {
			var url = '/logmodel';
			var appName = $('#appName').val(),
				appID = $('#appName').attr('appID'),
				token = $('#appName').attr('token'),
				type = $('#sLogModelName').val(),
				attributes = [];
			$('#attributes .form-group').each(function() {
				var key = $(this).find('.key').val(),
					value = $(this).find('.value').val();
				if (key) {
					attributes.push({
						key: key,
						value: value
					})
				}
			});
			$.ajax({
				url: url,
				type: 'PUT',
				data: {
					appID: appID,
					token: token,
					type: type,
					attributes: attributes
				},
				success: function(data) {
					base.show_error(data.message)
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