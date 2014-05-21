kue = require('kue')
jobs = kue.createQueue()

# email = jobs.create('email', {
# 	title: 'Account renewal required'
# 	to: 'tj@learnboost.com'
# 	template: 'renewal-email'
# })
# .delay(400)
# .priority('high')
# .save();

# email.on('complete', ()->
# 	console.log("Job complete");
# ).on('promotion', ()->
#     console.log('renewal job promoted');
# )

# jobs.create('email', {
# 	title: 'Account renewal required'
# 	to: 'tj@learnboost.com'
# 	template: 'renewal-email'
# })
# .delay(300)
# .priority('high')
# .save();

# jobs.promote();

# jobs.process('email', 20, (job, done)->
# 	done();
#     # setTimeout(()->
#     #     done();
#     # Math.random() * 5000);
# );


# jobs.process('email', (job, done)->
# 	console.log job.data;
# 	done(null, null)
# )

# }).on('failed', function(){
#   console.log("Job failed");
# }).on('progress', function(progress){
#   process.stdout.write('\r  job #' + job.id + ' ' + progress + '% complete');
# });
# jobs.process('email', (job, done)->
# 	console.log job.data
# 	done(null,null)
# 	# email(job.data.to, done);
# )