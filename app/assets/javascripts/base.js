'use strict';

// TODO: namespace.
$.fn.serializeObject = function()
{
  var o = {};
  var a = this.serializeArray();
  $.each(a, function() {
    if (o[this.name] !== undefined) {
      if (!o[this.name].push) {
        o[this.name] = [o[this.name]];
      }
      o[this.name].push(this.value || '');
    } else {
      o[this.name] = this.value || '';
    }
  });
  return o;
};

if (typeof String.prototype.startsWith != 'function') {
  String.prototype.startsWith = function (str){
    return this.slice(0, str.length) == str;
  };
}

if (typeof String.prototype.endsWith != 'function') {
  String.prototype.endsWith = function (str){
    return this.slice(-str.length) == str;
  };
}

if (typeof String.prototype.replaceAll !== 'function') {
  String.prototype.replaceAll = function (find, replacement){
    var v = this, u;
    while (true) {
      u = v.replace(find, replacement);
      if (u === v) return v;
      v = u;
    }
  };
}

Float32Array.prototype.toJSON = function() {
    var arr = [];
    for (var i=0; i < this.length; i++) arr.push(this[i]);
    return arr;
};

Float32Array.fromJSON = function(json) {
    return new Float32Array(JSON.parse(json));
};

// Javascript mod on negative numbers keep number negative
if (typeof Number.prototype.mod != 'function') {
  Number.prototype.mod = function(n) { return ((this%n)+n)%n; };
}

function clamp(val, minVal, maxVal) {
  return (val < minVal) ? minVal : ((val > maxVal) ? maxVal : val);
}

// DOM.

function id(id) {
  return document.getElementById(id);
}

// CSRF authenticity token for AJAX requests to Rails
$.ajaxSetup({
  headers: {
    'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
  }
});

// Utility functions for working with the canvas

// Function to get a potentially resized canvas with a given maxWidth and maxHeight
// while retaining the aspect ratio of the original canvas
// The quality of the resized image is probably not great
function getResizedCanvas(canvas, maxWidth, maxHeight)
{
  var scale = 1.0;
  if (maxWidth && canvas.width > maxWidth) {
    scale = Math.min(scale, maxWidth/canvas.width);
  }
  if (maxHeight && canvas.height > maxHeight) {
    scale = Math.min(scale, maxHeight/canvas.height);
  }
  if (scale != 1.0) {
    var newCanvas = document.createElement("canvas");
    newCanvas.width = scale*canvas.width;
    newCanvas.height = scale*canvas.height;
    var ctx = newCanvas.getContext("2d");
    ctx.drawImage(canvas, 0, 0, canvas.width, canvas.height, 0, 0, newCanvas.width, newCanvas.height);
    return newCanvas;
  } else {
    return canvas;
  }
}

// Copies the image contents of the canvas
function copyCanvas(canvas) {
  var c = document.createElement('canvas');
  c.width = canvas.width;
  c.height = canvas.height;
  var ctx = c.getContext('2d');
  ctx.drawImage(canvas, 0, 0);
  return c;
}

// Trims the canvas to non-transparent pixels?
// Taken from https://gist.github.com/remy/784508
function trimCanvas(c) {
  var ctx = c.getContext('2d');
  var copy = document.createElement('canvas').getContext('2d');
  var pixels = ctx.getImageData(0, 0, c.width, c.height);
  var l = pixels.data.length;
  var bound = {
    top: null,
    left: null,
    right: null,
    bottom: null
  };
  var i, x, y;

  for (i = 0; i < l; i += 4) {
    if (pixels.data[i+3] !== 0) {
      x = (i / 4) % c.width;
      y = ~~((i / 4) / c.width);

      if (bound.top === null) {
        bound.top = y;
      }

      if (bound.left === null) {
        bound.left = x;
      } else if (x < bound.left) {
        bound.left = x;
      }

      if (bound.right === null) {
        bound.right = x;
      } else if (bound.right < x) {
        bound.right = x;
      }

      if (bound.bottom === null) {
        bound.bottom = y;
      } else if (bound.bottom < y) {
        bound.bottom = y;
      }
    }
  }

  var trimHeight = bound.bottom - bound.top + 1;
  var trimWidth = bound.right - bound.left + 1;
  if (trimHeight > 0 && trimWidth > 0) {
    if (trimHeight === c.height && trimWidth === c.width) {
      // No need to trim, just return original
      return c;
    } else {
      var trimmed = ctx.getImageData(bound.left, bound.top, trimWidth, trimHeight);

      copy.canvas.width = trimWidth;
      copy.canvas.height = trimHeight;
      copy.putImageData(trimmed, 0, 0);

      // open new window with trimmed image:
      return copy.canvas;
    }
  } else {
    console.error("Invalid trimmed height or width, returning original canvas");
    return c;
  }
}

function getTrimmedCanvasDataUrl(canvas,maxWidth,maxHeight) {
  var copy = copyCanvas(canvas);
  var trimmed = trimCanvas(copy);
  var newCanvas = getResizedCanvas(trimmed, maxWidth, maxHeight);
  return newCanvas.toDataURL();
}

// UI functions using JQuery
function showLarge(elem) {
  var url = elem.attr("src");
  elem.addClass("enlarged");
  var align = elem.attr("enlarge_align");
  if (!align) {
    align = "center";
  }
  $('#large img').show();
  $('#large img').attr("src", url);
  $('#large img').position({
    my: align,
    at: align,
    of: elem
  });
  $('#large img').hover(function(){
  },function(){
    $(this).hide();
    elem.removeClass("enlarged");
  });
}

function showAlert(message, style, timeout) {
  window.setTimeout(function() { hideAlert(); }, timeout || 5000);
  $('#alertMessage').html(message);
  var alert = $('#alert');
  alert.attr('class', 'alert');
  alert.addClass(style);
  alert.css('font-size', '18pt');
  alert.show();
}

function hideAlert() {
  $('#alert').hide();
}
