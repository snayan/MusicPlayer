/*
   $$mp$$bridge$$.callHandler('cmd', params, (error, data) => {

   })
*/

(function(w, d) {
  // 已经注入了$$mp$$bridge$$
  if (w.$$mp$$bridge$$) {
    return;
  }

  // response id
  var id = 0;
  var callHandlerPrefix = 'callHandler';
  var registerHandlerPrefix = 'registerHandler';

  // message data
  var callbackMap = {};

  var communicator = (function() {
    var iframe = d.createElement('iframe');
    iframe.hidden = true;
    d.body.appendChild(iframe);
    return iframe;
  })();

  // helper
  var helper = {
    // scheme 和 host 可以在webView中注入，不需要显示在这里声明
    scheme: 'mpwvscm',
    host: '_mpwvhost_',

    _triggerSendNative: function(message) {
      var src = helper.scheme + '://' + helper.host;
      if (message != undefined) {
        src += '/' + message.name;
        src += '?callbackId=' + message.callbackId + '&params=' + decodeURIComponent(JSON.stringify(message.params));
      }
      communicator.src = src;
    },

    _invokeCallback: function(callbackId, data) {
      var callback = callbackMap[callbackId];
      if (typeof callback === 'function') {
        callback(JSON.parse(data));
      }
      callbackMap[callbackId] = null;
    },

    _nativeConsumeMessage: function() {
      var message;
      for (var i = 0; i < queue.length; i++) {
        message = queue[i];
        helper._triggerSendNative(message);
      }
      queue = [];
    },

    _invokeRegisterHandler: function(name) {
      var event = generateRegisterHandlerName(name);
      var callback = callbackMap[event];
      if (typeof callback === 'function') {
        return callback();
      }
    },
  };

  function generateCallHandlerName(name) {
    return callHandlerPrefix + '/' + name;
  }

  function generateRegisterHandlerName(name) {
    return registerHandlerPrefix + '/' + name;
  }

  function callHandler(name, params, callback) {
    var name = generateCallHandlerName(name);
    id = id + 1;
    var callbackId = '';
    if (typeof callback === 'function') {
      callbackId = name + id + new Date().valueOf();
      callbackMap[callbackId] = callback;
    }
    helper._triggerSendNative({ name: name, params: params, callbackId: callbackId });
  }

  function registerHandler(name, callback) {
    if (typeof callback === 'function') {
      var nativeCallback = function() {
        var single = true;
        callback(function(result) {
          single = Boolean(result);
        });
        return single;
      };
      var name = generateRegisterHandlerName(name);
      callbackMap[name] = nativeCallback;
    }
  }

  window.$$mp$$bridge$$ = {
    callHandler: callHandler,
    registerHandler: registerHandler,
    _intel_helper_: helper,
  };

  // 告诉sdk，bridge初始化完成了
  if (w.mpBridge && typeof w.mpBridge._initialize === 'function') {
    w.mpBridge._initialize();
  }
})(window, document);
