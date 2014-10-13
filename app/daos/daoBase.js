// Generated by CoffeeScript 1.7.1
var DaoBase, _;

_ = require('lodash');

DaoBase = (function() {
  var constructor, handleErr, instance, update_option;
  instance = [];
  update_option = {
    upsert: true
  };
  handleErr = function(err, document, callback) {
    var errMsg;
    if (!err) {
      return callback(null, document);
    } else {
      console.log(err);
      errMsg = null;
      _.forEach(err.errors, function(fieldValue, field) {
        return errMsg = errMsg || fieldValue.message;
      });
      return callback(errMsg);
    }
  };
  constructor = function(Model) {
    return {
      Model: Model,
      deleteByID: function(id, callback) {
        return this["delete"]({
          _id: id
        }, callback);
      },
      updateByID: function(id, doc, callback) {
        return this.update({
          _id: id
        }, doc, callback);
      },
      getByID: function(id, callback) {
        return this.getOne({
          _id: id
        }, callback);
      },
      create: function(doc, callback) {
        return Model.create(doc, function(err, raw) {
          return handleErr(err, raw, callback);
        });
      },
      "delete": function(query, callback) {
        return Model.remove(query, function(err, numberAffected) {
          if (numberAffected) {
            return handleErr(err, numberAffected, callback);
          } else {
            return handleErr('元素不存在', numberAffected, callback);
          }
        });
      },
      update: function(query, doc, callback) {
        delete doc._id;
        return Model.update(query, doc, update_option, function(err, numberAffected, raw) {
          return handleErr(err, numberAffected, callback);
        });
      },
      get: function(query, callback) {
        return Model.find(query, function(err, docs) {
          return handleErr(err, docs, callback);
        });
      },
      getOne: function(query, callback) {
        return Model.findOne(query, function(err, docs) {
          return handleErr(err, docs, callback);
        });
      },
      listAll: function(callback) {
        return this.get({}, callback);
      },
      count: function(query, callback) {
        return Model.count(query, function(err, number) {
          return handleErr(err, number, callback);
        });
      },
      list: function(criteria, sort, callback) {
        var options, query;
        query = criteria.query || {};
        options = criteria.options;
        return Model.find(query).sort(sort).limit(options.perPage).skip(options.perPage * options.page).exec(callback);
      },
      listPopulate: function(criteria, sort, populates, callback) {
        var query, temp;
        query = criteria.query || {};
        populates = populates.split(' ');
        temp = Model.find(query);
        _.each(populates, function(populate, index) {
          return temp = temp.populate(populate);
        });
        return temp.sort(sort).limit(options.perPage).skip(options.perPage * options.page).exec(callback);
      },
      listPopulateOne: function(query, populates, callback) {
        var temp;
        populates = populates.split(' ');
        temp = Model.find(query);
        _.each(populates, function(populate, index) {
          return temp = temp.populate(populate);
        });
        return temp.exec(callback);
      },
      listPopulateAll: function(criteria, sort, callback) {
        var populates, query, temp;
        query = criteria.query || {};
        populates = populates.split(' ');
        temp = Model.find(query);
        _.each(populates, function(populate, index) {
          return temp = temp.populate(populate);
        });
        return temp.sort(sort).exec(callback);
      }
    };
  };
  return {
    getInstance: function(Model) {
      var modelName;
      modelName = Model.collection.name;
      if (_.indexOf(instance, modelName) === -1) {
        instance.push(modelName);
      }
      return constructor(Model);
    }
  };
})();

module.exports = DaoBase;

//# sourceMappingURL=daoBase.map