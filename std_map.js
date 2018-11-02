// Generated by CoffeeScript 1.12.7
(function() {
  var Drw1, Jimp, K, arr, fraction, fs, init, mod2Pi, pi, rgbToInt, round, run, setColor, show, size, step, t0;

  Jimp = require('Jimp');

  fs = require('fs');

  K = 1;

  t0 = 0;

  pi = Math.PI;

  step = 0.1;

  size = 500;

  arr = [];

  init = function() {
    var i, l, ref, results;
    results = [];
    for (i = l = 0, ref = size; 0 <= ref ? l < ref : l > ref; i = 0 <= ref ? ++l : --l) {
      results.push(arr.push([]));
    }
    return results;
  };

  setColor = function(v) {
    switch (false) {
      case v !== void 0:
        return 0xAADCFAFF;
      case !(v < 10):
        return 0xE4F0DAFF;
      case !(v < 20):
        return 0xE4F0BEFF;
      case !(v < 50):
        return 0xE4F08CFF;
      case !(v < 100):
        return 0xE4F064FF;
      case !(v < 250):
        return 0xE4F04BFF;
      case !(v < 500):
        return 0xE4F032FF;
      default:
        return 0xE4F000FF;
    }
  };

  show = function() {
    var img;
    return img = new Jimp(size, size, function(error, img) {
      var i, j, l, m, ref, ref1;
      if (error) {
        throw error;
      }
      for (i = l = 0, ref = size; 0 <= ref ? l < ref : l > ref; i = 0 <= ref ? ++l : --l) {
        for (j = m = 0, ref1 = size; 0 <= ref1 ? m < ref1 : m > ref1; j = 0 <= ref1 ? ++m : --m) {
          img.setPixelColor(setColor(arr[i][j]), j, i);
        }
      }
      return img.write('./files/test1.jpg', function(error) {
        arr = [];
        return console.log(error ? error : "done");
      });
    });
  };

  rgbToInt = function(r, g, b) {
    return (r << 24) + (g << 16) + (b << 8);
  };

  fraction = function(x) {
    return x - Math.trunc(x);
  };

  mod2Pi = function(x) {
    if (x < 0) {
      x += 2 * pi;
    }
    return (fraction(x / (2 * pi))) * 2 * pi;
  };

  round = function(x) {
    return Math.round((x * (size - 11) / (2 * pi)) + 10);
  };

  Drw1 = function(x, y) {
    var i, l, results, tmp;
    results = [];
    for (i = l = 0; l < 100000; i = ++l) {
      tmp = x;
      x = mod2Pi(x + K * Math.sin(y));
      y = mod2Pi(y + x);
      if (arr[round(x)][round(y)] === void 0) {
        results.push(arr[round(x)][round(y)] = 1);
      } else {
        results.push(arr[round(x)][round(y)] += 1);
      }
    }
    return results;
  };

  run = function() {
    var results;
    init();
    results = [];
    while (t0 <= 2 * pi) {
      Drw1(t0, 0);
      Drw1(0, t0);
      results.push(t0 += step);
    }
    return results;
  };

  module.exports = function(k, st, sz) {
    K = k;
    step = st;
    size = sz;
    if (!(K > 0) || !(step > 0) || !(size > 0)) {
      return "error";
    }
    run();
    show();
    return null;
  };

}).call(this);
