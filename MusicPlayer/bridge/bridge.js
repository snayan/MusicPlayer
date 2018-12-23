/*
   ClientBridge.callHandler('cmd', params, (error, data) => {

   })
*/

(function(w, d) {
  // 已经注入了ClientBridge
  if (w.ClientBridge) {
    return;
  }

  var uid = 0;
  var messageQueue = [];
  var callbacksMap = {};

  var scheme = 'https';
  var messageHost = 'bridgemessage';
  var messageUrl = scheme + '://' + messageHost;
  var iframe = (function() {
    var i = d.createElement('iframe');
    i.hidden = true;
    d.body.appendChild(i);
    return i;
  })();

  function _noop() {}

  function _handlerMessageFromNative(dataString) {
    console.log('receive message from native: ' + dataString);
    let data = JSON.parse(dataString);
    if (data.responseId) {
      // callback after web call native
      var callback = callbacksMap[data.responseId];
      if (typeof callback === 'function') {
        callback(data.responseData);
      }
      callbacksMap[data.responseId] = null;
    } else {
      // native call web
      var callback;
      if (data.callbackId) {
        // 如果有callbackId，则要回发结果
        callback = function(res) {
          _doSend({ responseId: data.callbackId, responseData: res });
        };
      } else {
        // 否则，不处理
        callback = _noop;
      }
      var handler = callbacksMap[data.handlerName];
      if (typeof handler === 'function') {
        handler(data.data, callback);
      } else {
        console.warn('receive unknown message from native:' + dataString);
      }
    }
  }

  function _fetchQueue() {
    var message = JSON.stringify(messageQueue);
    messageQueue = [];
    console.log('send message to native : ' + message);
    return message;
  }

  function _doSend(message) {
    messageQueue.push(message);
    iframe.src = messageUrl;
  }

  function callHandler(name, data, callback) {
    uid = uid + 1;
    if (typeof data === 'function') {
      callback = data;
      data = null;
    }
    if (typeof callback !== 'function') {
      callback = _noop;
    }
    var callbackId = 'callback_' + uid + new Date().valueOf();
    callbacksMap[callbackId] = callback;
    _doSend({ handlerName: name, data: data, callbackId: callbackId });
  }

  function registerHandler(name, callback) {
    callbacksMap[name] = callback;
  }

  w.ClientBridge = {
    callHandler: callHandler,
    registerHandler: registerHandler,
    _fetchQueue: _fetchQueue,
    _handlerMessageFromNative: _handlerMessageFromNative,
  };

  if (w.mpBridge) {
    w.mpBridge._initialize();
  }
})(window, document);
