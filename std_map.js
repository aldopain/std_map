// Generated by CoffeeScript 1.12.7
(function() {
  var Drw1, Jimp, K, Promise, arr, colors, f1, fraction, fs, init, itCount, mod2Pi, pi, ranges, rgbToInt, round, run, setColor, show, size, step;

  Jimp = require('Jimp');

  fs = require('fs');

  Promise = require('bluebird');

  pi = Math.PI;

  K = 1;

  step = 0.1;

  size = 500;

  ranges = [10, 20, 50, 100, 250, 500];

  colors = [0xAADCFAFF, 0xE4F0DAFF, 0xE4F0BEFF, 0xE4F08CFF, 0xE4F064FF, 0xE4F04BFF, 0xE4F032FF, 0xE4F000FF];

  itCount = 100000;

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
    var i, l, ref;
    if (v === void 0) {
      return colors[0];
    }
    for (i = l = 0, ref = ranges.length; 0 <= ref ? l < ref : l > ref; i = 0 <= ref ? ++l : --l) {
      if (v < ranges[i]) {
        return colors[i + 1];
      }
    }
    return colors[colors.length - 1];
  };

  show = function(name) {
    return new Promise(function(resolve, reject) {
      var img;
      return img = new Jimp(size, size, function(error, img) {
        var color, i, j, l, m, ref, ref1;
        if (error) {
          reject(error);
        } else {
          resolve(0);
        }
        for (i = l = 0, ref = size; 0 <= ref ? l < ref : l > ref; i = 0 <= ref ? ++l : --l) {
          for (j = m = 0, ref1 = size; 0 <= ref1 ? m < ref1 : m > ref1; j = 0 <= ref1 ? ++m : --m) {
            color = setColor(arr[i][j]);
            img.setPixelColor(color, j, i);
          }
        }
        return img.write("./files/" + name + ".jpg", function(error) {
          if (error) {
            return reject(error);
          } else {
            return resolve(0);
          }
        });
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
    return Math.round(x * (size - 1) / (2 * pi));
  };

  Drw1 = function(x, y) {
    var i, l, ref, results, tmp;
    results = [];
    for (i = l = 0, ref = itCount; 0 <= ref ? l < ref : l > ref; i = 0 <= ref ? ++l : --l) {
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

  run = function(t0, max, d) {
    var results;
    arr = [];
    init();
    results = [];
    while (t0 <= max) {
      Drw1(t0, d);
      Drw1(d, t0);
      results.push(t0 += step);
    }
    return results;
  };

  module.exports = f1 = function(k, st, sz, c, r, runSettings, name) {
    return new Promise(function(resolve) {
      var runEnd, start;
      K = k;
      step = st;
      size = sz;
      colors = c;
      ranges = r;
      if (!(K > 0) || !(step > 0) || !(size > 0)) {
        return "error";
      }
      start = new Date().getTime();
      run(runSettings.t0, runSettings.max, runSettings.d);
      runEnd = new Date().getTime();
      console.log("run time = " + (runEnd - start));
      return show(name).then(function() {
        var showEnd;
        showEnd = new Date().getTime();
        console.log("show time = " + (showEnd - runEnd));
        console.log("total time = " + (showEnd - start));
        return resolve(0);
      })["catch"](function(err) {
        return console.log(err);
      });
    });
  };

  f1(1, 0.1, 2000, colors, ranges, {
    t0: 0,
    max: 2 * pi,
    d: 0
  }, "test21").then(function() {
    return f1(1, 0.1, 2000, colors, ranges, {
      t0: pi,
      max: 3 * pi,
      d: pi
    }, "test22");
  }).then(function() {
    return f1(1, 0.1, 2000, colors, ranges, {
      t0: pi,
      max: pi + 0.5,
      d: pi
    }, "test23");
  });

}).call(this);
