(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){

},{}],2:[function(require,module,exports){
/* MIT license */

module.exports = {
  rgb2hsl: rgb2hsl,
  rgb2hsv: rgb2hsv,
  rgb2hwb: rgb2hwb,
  rgb2cmyk: rgb2cmyk,
  rgb2keyword: rgb2keyword,
  rgb2xyz: rgb2xyz,
  rgb2lab: rgb2lab,
  rgb2lch: rgb2lch,

  hsl2rgb: hsl2rgb,
  hsl2hsv: hsl2hsv,
  hsl2hwb: hsl2hwb,
  hsl2cmyk: hsl2cmyk,
  hsl2keyword: hsl2keyword,

  hsv2rgb: hsv2rgb,
  hsv2hsl: hsv2hsl,
  hsv2hwb: hsv2hwb,
  hsv2cmyk: hsv2cmyk,
  hsv2keyword: hsv2keyword,

  hwb2rgb: hwb2rgb,
  hwb2hsl: hwb2hsl,
  hwb2hsv: hwb2hsv,
  hwb2cmyk: hwb2cmyk,
  hwb2keyword: hwb2keyword,

  cmyk2rgb: cmyk2rgb,
  cmyk2hsl: cmyk2hsl,
  cmyk2hsv: cmyk2hsv,
  cmyk2hwb: cmyk2hwb,
  cmyk2keyword: cmyk2keyword,

  keyword2rgb: keyword2rgb,
  keyword2hsl: keyword2hsl,
  keyword2hsv: keyword2hsv,
  keyword2hwb: keyword2hwb,
  keyword2cmyk: keyword2cmyk,
  keyword2lab: keyword2lab,
  keyword2xyz: keyword2xyz,

  xyz2rgb: xyz2rgb,
  xyz2lab: xyz2lab,
  xyz2lch: xyz2lch,

  lab2xyz: lab2xyz,
  lab2rgb: lab2rgb,
  lab2lch: lab2lch,

  lch2lab: lch2lab,
  lch2xyz: lch2xyz,
  lch2rgb: lch2rgb
}


function rgb2hsl(rgb) {
  var r = rgb[0]/255,
      g = rgb[1]/255,
      b = rgb[2]/255,
      min = Math.min(r, g, b),
      max = Math.max(r, g, b),
      delta = max - min,
      h, s, l;

  if (max == min)
    h = 0;
  else if (r == max)
    h = (g - b) / delta;
  else if (g == max)
    h = 2 + (b - r) / delta;
  else if (b == max)
    h = 4 + (r - g)/ delta;

  h = Math.min(h * 60, 360);

  if (h < 0)
    h += 360;

  l = (min + max) / 2;

  if (max == min)
    s = 0;
  else if (l <= 0.5)
    s = delta / (max + min);
  else
    s = delta / (2 - max - min);

  return [h, s * 100, l * 100];
}

function rgb2hsv(rgb) {
  var r = rgb[0],
      g = rgb[1],
      b = rgb[2],
      min = Math.min(r, g, b),
      max = Math.max(r, g, b),
      delta = max - min,
      h, s, v;

  if (max == 0)
    s = 0;
  else
    s = (delta/max * 1000)/10;

  if (max == min)
    h = 0;
  else if (r == max)
    h = (g - b) / delta;
  else if (g == max)
    h = 2 + (b - r) / delta;
  else if (b == max)
    h = 4 + (r - g) / delta;

  h = Math.min(h * 60, 360);

  if (h < 0)
    h += 360;

  v = ((max / 255) * 1000) / 10;

  return [h, s, v];
}

function rgb2hwb(rgb) {
  var r = rgb[0],
      g = rgb[1],
      b = rgb[2],
      h = rgb2hsl(rgb)[0],
      w = 1/255 * Math.min(r, Math.min(g, b)),
      b = 1 - 1/255 * Math.max(r, Math.max(g, b));

  return [h, w * 100, b * 100];
}

function rgb2cmyk(rgb) {
  var r = rgb[0] / 255,
      g = rgb[1] / 255,
      b = rgb[2] / 255,
      c, m, y, k;

  k = Math.min(1 - r, 1 - g, 1 - b);
  c = (1 - r - k) / (1 - k) || 0;
  m = (1 - g - k) / (1 - k) || 0;
  y = (1 - b - k) / (1 - k) || 0;
  return [c * 100, m * 100, y * 100, k * 100];
}

function rgb2keyword(rgb) {
  return reverseKeywords[JSON.stringify(rgb)];
}

function rgb2xyz(rgb) {
  var r = rgb[0] / 255,
      g = rgb[1] / 255,
      b = rgb[2] / 255;

  // assume sRGB
  r = r > 0.04045 ? Math.pow(((r + 0.055) / 1.055), 2.4) : (r / 12.92);
  g = g > 0.04045 ? Math.pow(((g + 0.055) / 1.055), 2.4) : (g / 12.92);
  b = b > 0.04045 ? Math.pow(((b + 0.055) / 1.055), 2.4) : (b / 12.92);

  var x = (r * 0.4124) + (g * 0.3576) + (b * 0.1805);
  var y = (r * 0.2126) + (g * 0.7152) + (b * 0.0722);
  var z = (r * 0.0193) + (g * 0.1192) + (b * 0.9505);

  return [x * 100, y *100, z * 100];
}

function rgb2lab(rgb) {
  var xyz = rgb2xyz(rgb),
        x = xyz[0],
        y = xyz[1],
        z = xyz[2],
        l, a, b;

  x /= 95.047;
  y /= 100;
  z /= 108.883;

  x = x > 0.008856 ? Math.pow(x, 1/3) : (7.787 * x) + (16 / 116);
  y = y > 0.008856 ? Math.pow(y, 1/3) : (7.787 * y) + (16 / 116);
  z = z > 0.008856 ? Math.pow(z, 1/3) : (7.787 * z) + (16 / 116);

  l = (116 * y) - 16;
  a = 500 * (x - y);
  b = 200 * (y - z);

  return [l, a, b];
}

function rgb2lch(args) {
  return lab2lch(rgb2lab(args));
}

function hsl2rgb(hsl) {
  var h = hsl[0] / 360,
      s = hsl[1] / 100,
      l = hsl[2] / 100,
      t1, t2, t3, rgb, val;

  if (s == 0) {
    val = l * 255;
    return [val, val, val];
  }

  if (l < 0.5)
    t2 = l * (1 + s);
  else
    t2 = l + s - l * s;
  t1 = 2 * l - t2;

  rgb = [0, 0, 0];
  for (var i = 0; i < 3; i++) {
    t3 = h + 1 / 3 * - (i - 1);
    t3 < 0 && t3++;
    t3 > 1 && t3--;

    if (6 * t3 < 1)
      val = t1 + (t2 - t1) * 6 * t3;
    else if (2 * t3 < 1)
      val = t2;
    else if (3 * t3 < 2)
      val = t1 + (t2 - t1) * (2 / 3 - t3) * 6;
    else
      val = t1;

    rgb[i] = val * 255;
  }

  return rgb;
}

function hsl2hsv(hsl) {
  var h = hsl[0],
      s = hsl[1] / 100,
      l = hsl[2] / 100,
      sv, v;

  if(l === 0) {
      // no need to do calc on black
      // also avoids divide by 0 error
      return [0, 0, 0];
  }

  l *= 2;
  s *= (l <= 1) ? l : 2 - l;
  v = (l + s) / 2;
  sv = (2 * s) / (l + s);
  return [h, sv * 100, v * 100];
}

function hsl2hwb(args) {
  return rgb2hwb(hsl2rgb(args));
}

function hsl2cmyk(args) {
  return rgb2cmyk(hsl2rgb(args));
}

function hsl2keyword(args) {
  return rgb2keyword(hsl2rgb(args));
}


function hsv2rgb(hsv) {
  var h = hsv[0] / 60,
      s = hsv[1] / 100,
      v = hsv[2] / 100,
      hi = Math.floor(h) % 6;

  var f = h - Math.floor(h),
      p = 255 * v * (1 - s),
      q = 255 * v * (1 - (s * f)),
      t = 255 * v * (1 - (s * (1 - f))),
      v = 255 * v;

  switch(hi) {
    case 0:
      return [v, t, p];
    case 1:
      return [q, v, p];
    case 2:
      return [p, v, t];
    case 3:
      return [p, q, v];
    case 4:
      return [t, p, v];
    case 5:
      return [v, p, q];
  }
}

function hsv2hsl(hsv) {
  var h = hsv[0],
      s = hsv[1] / 100,
      v = hsv[2] / 100,
      sl, l;

  l = (2 - s) * v;
  sl = s * v;
  sl /= (l <= 1) ? l : 2 - l;
  sl = sl || 0;
  l /= 2;
  return [h, sl * 100, l * 100];
}

function hsv2hwb(args) {
  return rgb2hwb(hsv2rgb(args))
}

function hsv2cmyk(args) {
  return rgb2cmyk(hsv2rgb(args));
}

function hsv2keyword(args) {
  return rgb2keyword(hsv2rgb(args));
}

// http://dev.w3.org/csswg/css-color/#hwb-to-rgb
function hwb2rgb(hwb) {
  var h = hwb[0] / 360,
      wh = hwb[1] / 100,
      bl = hwb[2] / 100,
      ratio = wh + bl,
      i, v, f, n;

  // wh + bl cant be > 1
  if (ratio > 1) {
    wh /= ratio;
    bl /= ratio;
  }

  i = Math.floor(6 * h);
  v = 1 - bl;
  f = 6 * h - i;
  if ((i & 0x01) != 0) {
    f = 1 - f;
  }
  n = wh + f * (v - wh);  // linear interpolation

  switch (i) {
    default:
    case 6:
    case 0: r = v; g = n; b = wh; break;
    case 1: r = n; g = v; b = wh; break;
    case 2: r = wh; g = v; b = n; break;
    case 3: r = wh; g = n; b = v; break;
    case 4: r = n; g = wh; b = v; break;
    case 5: r = v; g = wh; b = n; break;
  }

  return [r * 255, g * 255, b * 255];
}

function hwb2hsl(args) {
  return rgb2hsl(hwb2rgb(args));
}

function hwb2hsv(args) {
  return rgb2hsv(hwb2rgb(args));
}

function hwb2cmyk(args) {
  return rgb2cmyk(hwb2rgb(args));
}

function hwb2keyword(args) {
  return rgb2keyword(hwb2rgb(args));
}

function cmyk2rgb(cmyk) {
  var c = cmyk[0] / 100,
      m = cmyk[1] / 100,
      y = cmyk[2] / 100,
      k = cmyk[3] / 100,
      r, g, b;

  r = 1 - Math.min(1, c * (1 - k) + k);
  g = 1 - Math.min(1, m * (1 - k) + k);
  b = 1 - Math.min(1, y * (1 - k) + k);
  return [r * 255, g * 255, b * 255];
}

function cmyk2hsl(args) {
  return rgb2hsl(cmyk2rgb(args));
}

function cmyk2hsv(args) {
  return rgb2hsv(cmyk2rgb(args));
}

function cmyk2hwb(args) {
  return rgb2hwb(cmyk2rgb(args));
}

function cmyk2keyword(args) {
  return rgb2keyword(cmyk2rgb(args));
}


function xyz2rgb(xyz) {
  var x = xyz[0] / 100,
      y = xyz[1] / 100,
      z = xyz[2] / 100,
      r, g, b;

  r = (x * 3.2406) + (y * -1.5372) + (z * -0.4986);
  g = (x * -0.9689) + (y * 1.8758) + (z * 0.0415);
  b = (x * 0.0557) + (y * -0.2040) + (z * 1.0570);

  // assume sRGB
  r = r > 0.0031308 ? ((1.055 * Math.pow(r, 1.0 / 2.4)) - 0.055)
    : r = (r * 12.92);

  g = g > 0.0031308 ? ((1.055 * Math.pow(g, 1.0 / 2.4)) - 0.055)
    : g = (g * 12.92);

  b = b > 0.0031308 ? ((1.055 * Math.pow(b, 1.0 / 2.4)) - 0.055)
    : b = (b * 12.92);

  r = Math.min(Math.max(0, r), 1);
  g = Math.min(Math.max(0, g), 1);
  b = Math.min(Math.max(0, b), 1);

  return [r * 255, g * 255, b * 255];
}

function xyz2lab(xyz) {
  var x = xyz[0],
      y = xyz[1],
      z = xyz[2],
      l, a, b;

  x /= 95.047;
  y /= 100;
  z /= 108.883;

  x = x > 0.008856 ? Math.pow(x, 1/3) : (7.787 * x) + (16 / 116);
  y = y > 0.008856 ? Math.pow(y, 1/3) : (7.787 * y) + (16 / 116);
  z = z > 0.008856 ? Math.pow(z, 1/3) : (7.787 * z) + (16 / 116);

  l = (116 * y) - 16;
  a = 500 * (x - y);
  b = 200 * (y - z);

  return [l, a, b];
}

function xyz2lch(args) {
  return lab2lch(xyz2lab(args));
}

function lab2xyz(lab) {
  var l = lab[0],
      a = lab[1],
      b = lab[2],
      x, y, z, y2;

  if (l <= 8) {
    y = (l * 100) / 903.3;
    y2 = (7.787 * (y / 100)) + (16 / 116);
  } else {
    y = 100 * Math.pow((l + 16) / 116, 3);
    y2 = Math.pow(y / 100, 1/3);
  }

  x = x / 95.047 <= 0.008856 ? x = (95.047 * ((a / 500) + y2 - (16 / 116))) / 7.787 : 95.047 * Math.pow((a / 500) + y2, 3);

  z = z / 108.883 <= 0.008859 ? z = (108.883 * (y2 - (b / 200) - (16 / 116))) / 7.787 : 108.883 * Math.pow(y2 - (b / 200), 3);

  return [x, y, z];
}

function lab2lch(lab) {
  var l = lab[0],
      a = lab[1],
      b = lab[2],
      hr, h, c;

  hr = Math.atan2(b, a);
  h = hr * 360 / 2 / Math.PI;
  if (h < 0) {
    h += 360;
  }
  c = Math.sqrt(a * a + b * b);
  return [l, c, h];
}

function lab2rgb(args) {
  return xyz2rgb(lab2xyz(args));
}

function lch2lab(lch) {
  var l = lch[0],
      c = lch[1],
      h = lch[2],
      a, b, hr;

  hr = h / 360 * 2 * Math.PI;
  a = c * Math.cos(hr);
  b = c * Math.sin(hr);
  return [l, a, b];
}

function lch2xyz(args) {
  return lab2xyz(lch2lab(args));
}

function lch2rgb(args) {
  return lab2rgb(lch2lab(args));
}

function keyword2rgb(keyword) {
  return cssKeywords[keyword];
}

function keyword2hsl(args) {
  return rgb2hsl(keyword2rgb(args));
}

function keyword2hsv(args) {
  return rgb2hsv(keyword2rgb(args));
}

function keyword2hwb(args) {
  return rgb2hwb(keyword2rgb(args));
}

function keyword2cmyk(args) {
  return rgb2cmyk(keyword2rgb(args));
}

function keyword2lab(args) {
  return rgb2lab(keyword2rgb(args));
}

function keyword2xyz(args) {
  return rgb2xyz(keyword2rgb(args));
}

var cssKeywords = {
  aliceblue:  [240,248,255],
  antiquewhite: [250,235,215],
  aqua: [0,255,255],
  aquamarine: [127,255,212],
  azure:  [240,255,255],
  beige:  [245,245,220],
  bisque: [255,228,196],
  black:  [0,0,0],
  blanchedalmond: [255,235,205],
  blue: [0,0,255],
  blueviolet: [138,43,226],
  brown:  [165,42,42],
  burlywood:  [222,184,135],
  cadetblue:  [95,158,160],
  chartreuse: [127,255,0],
  chocolate:  [210,105,30],
  coral:  [255,127,80],
  cornflowerblue: [100,149,237],
  cornsilk: [255,248,220],
  crimson:  [220,20,60],
  cyan: [0,255,255],
  darkblue: [0,0,139],
  darkcyan: [0,139,139],
  darkgoldenrod:  [184,134,11],
  darkgray: [169,169,169],
  darkgreen:  [0,100,0],
  darkgrey: [169,169,169],
  darkkhaki:  [189,183,107],
  darkmagenta:  [139,0,139],
  darkolivegreen: [85,107,47],
  darkorange: [255,140,0],
  darkorchid: [153,50,204],
  darkred:  [139,0,0],
  darksalmon: [233,150,122],
  darkseagreen: [143,188,143],
  darkslateblue:  [72,61,139],
  darkslategray:  [47,79,79],
  darkslategrey:  [47,79,79],
  darkturquoise:  [0,206,209],
  darkviolet: [148,0,211],
  deeppink: [255,20,147],
  deepskyblue:  [0,191,255],
  dimgray:  [105,105,105],
  dimgrey:  [105,105,105],
  dodgerblue: [30,144,255],
  firebrick:  [178,34,34],
  floralwhite:  [255,250,240],
  forestgreen:  [34,139,34],
  fuchsia:  [255,0,255],
  gainsboro:  [220,220,220],
  ghostwhite: [248,248,255],
  gold: [255,215,0],
  goldenrod:  [218,165,32],
  gray: [128,128,128],
  green:  [0,128,0],
  greenyellow:  [173,255,47],
  grey: [128,128,128],
  honeydew: [240,255,240],
  hotpink:  [255,105,180],
  indianred:  [205,92,92],
  indigo: [75,0,130],
  ivory:  [255,255,240],
  khaki:  [240,230,140],
  lavender: [230,230,250],
  lavenderblush:  [255,240,245],
  lawngreen:  [124,252,0],
  lemonchiffon: [255,250,205],
  lightblue:  [173,216,230],
  lightcoral: [240,128,128],
  lightcyan:  [224,255,255],
  lightgoldenrodyellow: [250,250,210],
  lightgray:  [211,211,211],
  lightgreen: [144,238,144],
  lightgrey:  [211,211,211],
  lightpink:  [255,182,193],
  lightsalmon:  [255,160,122],
  lightseagreen:  [32,178,170],
  lightskyblue: [135,206,250],
  lightslategray: [119,136,153],
  lightslategrey: [119,136,153],
  lightsteelblue: [176,196,222],
  lightyellow:  [255,255,224],
  lime: [0,255,0],
  limegreen:  [50,205,50],
  linen:  [250,240,230],
  magenta:  [255,0,255],
  maroon: [128,0,0],
  mediumaquamarine: [102,205,170],
  mediumblue: [0,0,205],
  mediumorchid: [186,85,211],
  mediumpurple: [147,112,219],
  mediumseagreen: [60,179,113],
  mediumslateblue:  [123,104,238],
  mediumspringgreen:  [0,250,154],
  mediumturquoise:  [72,209,204],
  mediumvioletred:  [199,21,133],
  midnightblue: [25,25,112],
  mintcream:  [245,255,250],
  mistyrose:  [255,228,225],
  moccasin: [255,228,181],
  navajowhite:  [255,222,173],
  navy: [0,0,128],
  oldlace:  [253,245,230],
  olive:  [128,128,0],
  olivedrab:  [107,142,35],
  orange: [255,165,0],
  orangered:  [255,69,0],
  orchid: [218,112,214],
  palegoldenrod:  [238,232,170],
  palegreen:  [152,251,152],
  paleturquoise:  [175,238,238],
  palevioletred:  [219,112,147],
  papayawhip: [255,239,213],
  peachpuff:  [255,218,185],
  peru: [205,133,63],
  pink: [255,192,203],
  plum: [221,160,221],
  powderblue: [176,224,230],
  purple: [128,0,128],
  rebeccapurple: [102, 51, 153],
  red:  [255,0,0],
  rosybrown:  [188,143,143],
  royalblue:  [65,105,225],
  saddlebrown:  [139,69,19],
  salmon: [250,128,114],
  sandybrown: [244,164,96],
  seagreen: [46,139,87],
  seashell: [255,245,238],
  sienna: [160,82,45],
  silver: [192,192,192],
  skyblue:  [135,206,235],
  slateblue:  [106,90,205],
  slategray:  [112,128,144],
  slategrey:  [112,128,144],
  snow: [255,250,250],
  springgreen:  [0,255,127],
  steelblue:  [70,130,180],
  tan:  [210,180,140],
  teal: [0,128,128],
  thistle:  [216,191,216],
  tomato: [255,99,71],
  turquoise:  [64,224,208],
  violet: [238,130,238],
  wheat:  [245,222,179],
  white:  [255,255,255],
  whitesmoke: [245,245,245],
  yellow: [255,255,0],
  yellowgreen:  [154,205,50]
};

var reverseKeywords = {};
for (var key in cssKeywords) {
  reverseKeywords[JSON.stringify(cssKeywords[key])] = key;
}

},{}],3:[function(require,module,exports){
var conversions = require("./conversions");

var convert = function() {
   return new Converter();
}

for (var func in conversions) {
  // export Raw versions
  convert[func + "Raw"] =  (function(func) {
    // accept array or plain args
    return function(arg) {
      if (typeof arg == "number")
        arg = Array.prototype.slice.call(arguments);
      return conversions[func](arg);
    }
  })(func);

  var pair = /(\w+)2(\w+)/.exec(func),
      from = pair[1],
      to = pair[2];

  // export rgb2hsl and ["rgb"]["hsl"]
  convert[from] = convert[from] || {};

  convert[from][to] = convert[func] = (function(func) { 
    return function(arg) {
      if (typeof arg == "number")
        arg = Array.prototype.slice.call(arguments);
      
      var val = conversions[func](arg);
      if (typeof val == "string" || val === undefined)
        return val; // keyword

      for (var i = 0; i < val.length; i++)
        val[i] = Math.round(val[i]);
      return val;
    }
  })(func);
}


/* Converter does lazy conversion and caching */
var Converter = function() {
   this.convs = {};
};

/* Either get the values for a space or
  set the values for a space, depending on args */
Converter.prototype.routeSpace = function(space, args) {
   var values = args[0];
   if (values === undefined) {
      // color.rgb()
      return this.getValues(space);
   }
   // color.rgb(10, 10, 10)
   if (typeof values == "number") {
      values = Array.prototype.slice.call(args);        
   }

   return this.setValues(space, values);
};
  
/* Set the values for a space, invalidating cache */
Converter.prototype.setValues = function(space, values) {
   this.space = space;
   this.convs = {};
   this.convs[space] = values;
   return this;
};

/* Get the values for a space. If there's already
  a conversion for the space, fetch it, otherwise
  compute it */
Converter.prototype.getValues = function(space) {
   var vals = this.convs[space];
   if (!vals) {
      var fspace = this.space,
          from = this.convs[fspace];
      vals = convert[fspace][space](from);

      this.convs[space] = vals;
   }
  return vals;
};

["rgb", "hsl", "hsv", "cmyk", "keyword"].forEach(function(space) {
   Converter.prototype[space] = function(vals) {
      return this.routeSpace(space, arguments);
   }
});

module.exports = convert;
},{"./conversions":2}],4:[function(require,module,exports){
module.exports = {
	"aliceblue": [240, 248, 255],
	"antiquewhite": [250, 235, 215],
	"aqua": [0, 255, 255],
	"aquamarine": [127, 255, 212],
	"azure": [240, 255, 255],
	"beige": [245, 245, 220],
	"bisque": [255, 228, 196],
	"black": [0, 0, 0],
	"blanchedalmond": [255, 235, 205],
	"blue": [0, 0, 255],
	"blueviolet": [138, 43, 226],
	"brown": [165, 42, 42],
	"burlywood": [222, 184, 135],
	"cadetblue": [95, 158, 160],
	"chartreuse": [127, 255, 0],
	"chocolate": [210, 105, 30],
	"coral": [255, 127, 80],
	"cornflowerblue": [100, 149, 237],
	"cornsilk": [255, 248, 220],
	"crimson": [220, 20, 60],
	"cyan": [0, 255, 255],
	"darkblue": [0, 0, 139],
	"darkcyan": [0, 139, 139],
	"darkgoldenrod": [184, 134, 11],
	"darkgray": [169, 169, 169],
	"darkgreen": [0, 100, 0],
	"darkgrey": [169, 169, 169],
	"darkkhaki": [189, 183, 107],
	"darkmagenta": [139, 0, 139],
	"darkolivegreen": [85, 107, 47],
	"darkorange": [255, 140, 0],
	"darkorchid": [153, 50, 204],
	"darkred": [139, 0, 0],
	"darksalmon": [233, 150, 122],
	"darkseagreen": [143, 188, 143],
	"darkslateblue": [72, 61, 139],
	"darkslategray": [47, 79, 79],
	"darkslategrey": [47, 79, 79],
	"darkturquoise": [0, 206, 209],
	"darkviolet": [148, 0, 211],
	"deeppink": [255, 20, 147],
	"deepskyblue": [0, 191, 255],
	"dimgray": [105, 105, 105],
	"dimgrey": [105, 105, 105],
	"dodgerblue": [30, 144, 255],
	"firebrick": [178, 34, 34],
	"floralwhite": [255, 250, 240],
	"forestgreen": [34, 139, 34],
	"fuchsia": [255, 0, 255],
	"gainsboro": [220, 220, 220],
	"ghostwhite": [248, 248, 255],
	"gold": [255, 215, 0],
	"goldenrod": [218, 165, 32],
	"gray": [128, 128, 128],
	"green": [0, 128, 0],
	"greenyellow": [173, 255, 47],
	"grey": [128, 128, 128],
	"honeydew": [240, 255, 240],
	"hotpink": [255, 105, 180],
	"indianred": [205, 92, 92],
	"indigo": [75, 0, 130],
	"ivory": [255, 255, 240],
	"khaki": [240, 230, 140],
	"lavender": [230, 230, 250],
	"lavenderblush": [255, 240, 245],
	"lawngreen": [124, 252, 0],
	"lemonchiffon": [255, 250, 205],
	"lightblue": [173, 216, 230],
	"lightcoral": [240, 128, 128],
	"lightcyan": [224, 255, 255],
	"lightgoldenrodyellow": [250, 250, 210],
	"lightgray": [211, 211, 211],
	"lightgreen": [144, 238, 144],
	"lightgrey": [211, 211, 211],
	"lightpink": [255, 182, 193],
	"lightsalmon": [255, 160, 122],
	"lightseagreen": [32, 178, 170],
	"lightskyblue": [135, 206, 250],
	"lightslategray": [119, 136, 153],
	"lightslategrey": [119, 136, 153],
	"lightsteelblue": [176, 196, 222],
	"lightyellow": [255, 255, 224],
	"lime": [0, 255, 0],
	"limegreen": [50, 205, 50],
	"linen": [250, 240, 230],
	"magenta": [255, 0, 255],
	"maroon": [128, 0, 0],
	"mediumaquamarine": [102, 205, 170],
	"mediumblue": [0, 0, 205],
	"mediumorchid": [186, 85, 211],
	"mediumpurple": [147, 112, 219],
	"mediumseagreen": [60, 179, 113],
	"mediumslateblue": [123, 104, 238],
	"mediumspringgreen": [0, 250, 154],
	"mediumturquoise": [72, 209, 204],
	"mediumvioletred": [199, 21, 133],
	"midnightblue": [25, 25, 112],
	"mintcream": [245, 255, 250],
	"mistyrose": [255, 228, 225],
	"moccasin": [255, 228, 181],
	"navajowhite": [255, 222, 173],
	"navy": [0, 0, 128],
	"oldlace": [253, 245, 230],
	"olive": [128, 128, 0],
	"olivedrab": [107, 142, 35],
	"orange": [255, 165, 0],
	"orangered": [255, 69, 0],
	"orchid": [218, 112, 214],
	"palegoldenrod": [238, 232, 170],
	"palegreen": [152, 251, 152],
	"paleturquoise": [175, 238, 238],
	"palevioletred": [219, 112, 147],
	"papayawhip": [255, 239, 213],
	"peachpuff": [255, 218, 185],
	"peru": [205, 133, 63],
	"pink": [255, 192, 203],
	"plum": [221, 160, 221],
	"powderblue": [176, 224, 230],
	"purple": [128, 0, 128],
	"rebeccapurple": [102, 51, 153],
	"red": [255, 0, 0],
	"rosybrown": [188, 143, 143],
	"royalblue": [65, 105, 225],
	"saddlebrown": [139, 69, 19],
	"salmon": [250, 128, 114],
	"sandybrown": [244, 164, 96],
	"seagreen": [46, 139, 87],
	"seashell": [255, 245, 238],
	"sienna": [160, 82, 45],
	"silver": [192, 192, 192],
	"skyblue": [135, 206, 235],
	"slateblue": [106, 90, 205],
	"slategray": [112, 128, 144],
	"slategrey": [112, 128, 144],
	"snow": [255, 250, 250],
	"springgreen": [0, 255, 127],
	"steelblue": [70, 130, 180],
	"tan": [210, 180, 140],
	"teal": [0, 128, 128],
	"thistle": [216, 191, 216],
	"tomato": [255, 99, 71],
	"turquoise": [64, 224, 208],
	"violet": [238, 130, 238],
	"wheat": [245, 222, 179],
	"white": [255, 255, 255],
	"whitesmoke": [245, 245, 245],
	"yellow": [255, 255, 0],
	"yellowgreen": [154, 205, 50]
};
},{}],5:[function(require,module,exports){
/* MIT license */
var colorNames = require('color-name');

module.exports = {
   getRgba: getRgba,
   getHsla: getHsla,
   getRgb: getRgb,
   getHsl: getHsl,
   getHwb: getHwb,
   getAlpha: getAlpha,

   hexString: hexString,
   rgbString: rgbString,
   rgbaString: rgbaString,
   percentString: percentString,
   percentaString: percentaString,
   hslString: hslString,
   hslaString: hslaString,
   hwbString: hwbString,
   keyword: keyword
}

function getRgba(string) {
   if (!string) {
      return;
   }
   var abbr =  /^#([a-fA-F0-9]{3})$/,
       hex =  /^#([a-fA-F0-9]{6})$/,
       rgba = /^rgba?\(\s*([+-]?\d+)\s*,\s*([+-]?\d+)\s*,\s*([+-]?\d+)\s*(?:,\s*([+-]?[\d\.]+)\s*)?\)$/,
       per = /^rgba?\(\s*([+-]?[\d\.]+)\%\s*,\s*([+-]?[\d\.]+)\%\s*,\s*([+-]?[\d\.]+)\%\s*(?:,\s*([+-]?[\d\.]+)\s*)?\)$/,
       keyword = /(\D+)/;

   var rgb = [0, 0, 0],
       a = 1,
       match = string.match(abbr);
   if (match) {
      match = match[1];
      for (var i = 0; i < rgb.length; i++) {
         rgb[i] = parseInt(match[i] + match[i], 16);
      }
   }
   else if (match = string.match(hex)) {
      match = match[1];
      for (var i = 0; i < rgb.length; i++) {
         rgb[i] = parseInt(match.slice(i * 2, i * 2 + 2), 16);
      }
   }
   else if (match = string.match(rgba)) {
      for (var i = 0; i < rgb.length; i++) {
         rgb[i] = parseInt(match[i + 1]);
      }
      a = parseFloat(match[4]);
   }
   else if (match = string.match(per)) {
      for (var i = 0; i < rgb.length; i++) {
         rgb[i] = Math.round(parseFloat(match[i + 1]) * 2.55);
      }
      a = parseFloat(match[4]);
   }
   else if (match = string.match(keyword)) {
      if (match[1] == "transparent") {
         return [0, 0, 0, 0];
      }
      rgb = colorNames[match[1]];
      if (!rgb) {
         return;
      }
   }

   for (var i = 0; i < rgb.length; i++) {
      rgb[i] = scale(rgb[i], 0, 255);
   }
   if (!a && a != 0) {
      a = 1;
   }
   else {
      a = scale(a, 0, 1);
   }
   rgb[3] = a;
   return rgb;
}

function getHsla(string) {
   if (!string) {
      return;
   }
   var hsl = /^hsla?\(\s*([+-]?\d+)(?:deg)?\s*,\s*([+-]?[\d\.]+)%\s*,\s*([+-]?[\d\.]+)%\s*(?:,\s*([+-]?[\d\.]+)\s*)?\)/;
   var match = string.match(hsl);
   if (match) {
      var alpha = parseFloat(match[4]);
      var h = scale(parseInt(match[1]), 0, 360),
          s = scale(parseFloat(match[2]), 0, 100),
          l = scale(parseFloat(match[3]), 0, 100),
          a = scale(isNaN(alpha) ? 1 : alpha, 0, 1);
      return [h, s, l, a];
   }
}

function getHwb(string) {
   if (!string) {
      return;
   }
   var hwb = /^hwb\(\s*([+-]?\d+)(?:deg)?\s*,\s*([+-]?[\d\.]+)%\s*,\s*([+-]?[\d\.]+)%\s*(?:,\s*([+-]?[\d\.]+)\s*)?\)/;
   var match = string.match(hwb);
   if (match) {
    var alpha = parseFloat(match[4]);
      var h = scale(parseInt(match[1]), 0, 360),
          w = scale(parseFloat(match[2]), 0, 100),
          b = scale(parseFloat(match[3]), 0, 100),
          a = scale(isNaN(alpha) ? 1 : alpha, 0, 1);
      return [h, w, b, a];
   }
}

function getRgb(string) {
   var rgba = getRgba(string);
   return rgba && rgba.slice(0, 3);
}

function getHsl(string) {
  var hsla = getHsla(string);
  return hsla && hsla.slice(0, 3);
}

function getAlpha(string) {
   var vals = getRgba(string);
   if (vals) {
      return vals[3];
   }
   else if (vals = getHsla(string)) {
      return vals[3];
   }
   else if (vals = getHwb(string)) {
      return vals[3];
   }
}

// generators
function hexString(rgb) {
   return "#" + hexDouble(rgb[0]) + hexDouble(rgb[1])
              + hexDouble(rgb[2]);
}

function rgbString(rgba, alpha) {
   if (alpha < 1 || (rgba[3] && rgba[3] < 1)) {
      return rgbaString(rgba, alpha);
   }
   return "rgb(" + rgba[0] + ", " + rgba[1] + ", " + rgba[2] + ")";
}

function rgbaString(rgba, alpha) {
   if (alpha === undefined) {
      alpha = (rgba[3] !== undefined ? rgba[3] : 1);
   }
   return "rgba(" + rgba[0] + ", " + rgba[1] + ", " + rgba[2]
           + ", " + alpha + ")";
}

function percentString(rgba, alpha) {
   if (alpha < 1 || (rgba[3] && rgba[3] < 1)) {
      return percentaString(rgba, alpha);
   }
   var r = Math.round(rgba[0]/255 * 100),
       g = Math.round(rgba[1]/255 * 100),
       b = Math.round(rgba[2]/255 * 100);

   return "rgb(" + r + "%, " + g + "%, " + b + "%)";
}

function percentaString(rgba, alpha) {
   var r = Math.round(rgba[0]/255 * 100),
       g = Math.round(rgba[1]/255 * 100),
       b = Math.round(rgba[2]/255 * 100);
   return "rgba(" + r + "%, " + g + "%, " + b + "%, " + (alpha || rgba[3] || 1) + ")";
}

function hslString(hsla, alpha) {
   if (alpha < 1 || (hsla[3] && hsla[3] < 1)) {
      return hslaString(hsla, alpha);
   }
   return "hsl(" + hsla[0] + ", " + hsla[1] + "%, " + hsla[2] + "%)";
}

function hslaString(hsla, alpha) {
   if (alpha === undefined) {
      alpha = (hsla[3] !== undefined ? hsla[3] : 1);
   }
   return "hsla(" + hsla[0] + ", " + hsla[1] + "%, " + hsla[2] + "%, "
           + alpha + ")";
}

// hwb is a bit different than rgb(a) & hsl(a) since there is no alpha specific syntax
// (hwb have alpha optional & 1 is default value)
function hwbString(hwb, alpha) {
   if (alpha === undefined) {
      alpha = (hwb[3] !== undefined ? hwb[3] : 1);
   }
   return "hwb(" + hwb[0] + ", " + hwb[1] + "%, " + hwb[2] + "%"
           + (alpha !== undefined && alpha !== 1 ? ", " + alpha : "") + ")";
}

function keyword(rgb) {
  return reverseNames[rgb.slice(0, 3)];
}

// helpers
function scale(num, min, max) {
   return Math.min(Math.max(min, num), max);
}

function hexDouble(num) {
  var str = num.toString(16).toUpperCase();
  return (str.length < 2) ? "0" + str : str;
}


//create a list of reverse color names
var reverseNames = {};
for (var name in colorNames) {
   reverseNames[colorNames[name]] = name;
}

},{"color-name":4}],6:[function(require,module,exports){
/* MIT license */
var convert = require("color-convert"),
    string = require("color-string");

var Color = function(obj) {
  if (obj instanceof Color) return obj;
  if (! (this instanceof Color)) return new Color(obj);

   this.values = {
      rgb: [0, 0, 0],
      hsl: [0, 0, 0],
      hsv: [0, 0, 0],
      hwb: [0, 0, 0],
      cmyk: [0, 0, 0, 0],
      alpha: 1
   }

   // parse Color() argument
   if (typeof obj == "string") {
      var vals = string.getRgba(obj);
      if (vals) {
         this.setValues("rgb", vals);
      }
      else if(vals = string.getHsla(obj)) {
         this.setValues("hsl", vals);
      }
      else if(vals = string.getHwb(obj)) {
         this.setValues("hwb", vals);
      }
      else {
        throw new Error("Unable to parse color from string \"" + obj + "\"");
      }
   }
   else if (typeof obj == "object") {
      var vals = obj;
      if(vals["r"] !== undefined || vals["red"] !== undefined) {
         this.setValues("rgb", vals)
      }
      else if(vals["l"] !== undefined || vals["lightness"] !== undefined) {
         this.setValues("hsl", vals)
      }
      else if(vals["v"] !== undefined || vals["value"] !== undefined) {
         this.setValues("hsv", vals)
      }
      else if(vals["w"] !== undefined || vals["whiteness"] !== undefined) {
         this.setValues("hwb", vals)
      }
      else if(vals["c"] !== undefined || vals["cyan"] !== undefined) {
         this.setValues("cmyk", vals)
      }
      else {
        throw new Error("Unable to parse color from object " + JSON.stringify(obj));
      }
   }
}

Color.prototype = {
   rgb: function (vals) {
      return this.setSpace("rgb", arguments);
   },
   hsl: function(vals) {
      return this.setSpace("hsl", arguments);
   },
   hsv: function(vals) {
      return this.setSpace("hsv", arguments);
   },
   hwb: function(vals) {
      return this.setSpace("hwb", arguments);
   },
   cmyk: function(vals) {
      return this.setSpace("cmyk", arguments);
   },

   rgbArray: function() {
      return this.values.rgb;
   },
   hslArray: function() {
      return this.values.hsl;
   },
   hsvArray: function() {
      return this.values.hsv;
   },
   hwbArray: function() {
      if (this.values.alpha !== 1) {
        return this.values.hwb.concat([this.values.alpha])
      }
      return this.values.hwb;
   },
   cmykArray: function() {
      return this.values.cmyk;
   },
   rgbaArray: function() {
      var rgb = this.values.rgb;
      return rgb.concat([this.values.alpha]);
   },
   hslaArray: function() {
      var hsl = this.values.hsl;
      return hsl.concat([this.values.alpha]);
   },
   alpha: function(val) {
      if (val === undefined) {
         return this.values.alpha;
      }
      this.setValues("alpha", val);
      return this;
   },

   red: function(val) {
      return this.setChannel("rgb", 0, val);
   },
   green: function(val) {
      return this.setChannel("rgb", 1, val);
   },
   blue: function(val) {
      return this.setChannel("rgb", 2, val);
   },
   hue: function(val) {
      return this.setChannel("hsl", 0, val);
   },
   saturation: function(val) {
      return this.setChannel("hsl", 1, val);
   },
   lightness: function(val) {
      return this.setChannel("hsl", 2, val);
   },
   saturationv: function(val) {
      return this.setChannel("hsv", 1, val);
   },
   whiteness: function(val) {
      return this.setChannel("hwb", 1, val);
   },
   blackness: function(val) {
      return this.setChannel("hwb", 2, val);
   },
   value: function(val) {
      return this.setChannel("hsv", 2, val);
   },
   cyan: function(val) {
      return this.setChannel("cmyk", 0, val);
   },
   magenta: function(val) {
      return this.setChannel("cmyk", 1, val);
   },
   yellow: function(val) {
      return this.setChannel("cmyk", 2, val);
   },
   black: function(val) {
      return this.setChannel("cmyk", 3, val);
   },

   hexString: function() {
      return string.hexString(this.values.rgb);
   },
   rgbString: function() {
      return string.rgbString(this.values.rgb, this.values.alpha);
   },
   rgbaString: function() {
      return string.rgbaString(this.values.rgb, this.values.alpha);
   },
   percentString: function() {
      return string.percentString(this.values.rgb, this.values.alpha);
   },
   hslString: function() {
      return string.hslString(this.values.hsl, this.values.alpha);
   },
   hslaString: function() {
      return string.hslaString(this.values.hsl, this.values.alpha);
   },
   hwbString: function() {
      return string.hwbString(this.values.hwb, this.values.alpha);
   },
   keyword: function() {
      return string.keyword(this.values.rgb, this.values.alpha);
   },

   rgbNumber: function() {
      return (this.values.rgb[0] << 16) | (this.values.rgb[1] << 8) | this.values.rgb[2];
   },

   luminosity: function() {
      // http://www.w3.org/TR/WCAG20/#relativeluminancedef
      var rgb = this.values.rgb;
      var lum = [];
      for (var i = 0; i < rgb.length; i++) {
         var chan = rgb[i] / 255;
         lum[i] = (chan <= 0.03928) ? chan / 12.92
                  : Math.pow(((chan + 0.055) / 1.055), 2.4)
      }
      return 0.2126 * lum[0] + 0.7152 * lum[1] + 0.0722 * lum[2];
   },

   contrast: function(color2) {
      // http://www.w3.org/TR/WCAG20/#contrast-ratiodef
      var lum1 = this.luminosity();
      var lum2 = color2.luminosity();
      if (lum1 > lum2) {
         return (lum1 + 0.05) / (lum2 + 0.05)
      };
      return (lum2 + 0.05) / (lum1 + 0.05);
   },

   level: function(color2) {
     var contrastRatio = this.contrast(color2);
     return (contrastRatio >= 7.1)
       ? 'AAA'
       : (contrastRatio >= 4.5)
        ? 'AA'
        : '';
   },

   dark: function() {
      // YIQ equation from http://24ways.org/2010/calculating-color-contrast
      var rgb = this.values.rgb,
          yiq = (rgb[0] * 299 + rgb[1] * 587 + rgb[2] * 114) / 1000;
      return yiq < 128;
   },

   light: function() {
      return !this.dark();
   },

   negate: function() {
      var rgb = []
      for (var i = 0; i < 3; i++) {
         rgb[i] = 255 - this.values.rgb[i];
      }
      this.setValues("rgb", rgb);
      return this;
   },

   lighten: function(ratio) {
      this.values.hsl[2] += this.values.hsl[2] * ratio;
      this.setValues("hsl", this.values.hsl);
      return this;
   },

   darken: function(ratio) {
      this.values.hsl[2] -= this.values.hsl[2] * ratio;
      this.setValues("hsl", this.values.hsl);
      return this;
   },

   saturate: function(ratio) {
      this.values.hsl[1] += this.values.hsl[1] * ratio;
      this.setValues("hsl", this.values.hsl);
      return this;
   },

   desaturate: function(ratio) {
      this.values.hsl[1] -= this.values.hsl[1] * ratio;
      this.setValues("hsl", this.values.hsl);
      return this;
   },

   whiten: function(ratio) {
      this.values.hwb[1] += this.values.hwb[1] * ratio;
      this.setValues("hwb", this.values.hwb);
      return this;
   },

   blacken: function(ratio) {
      this.values.hwb[2] += this.values.hwb[2] * ratio;
      this.setValues("hwb", this.values.hwb);
      return this;
   },

   greyscale: function() {
      var rgb = this.values.rgb;
      // http://en.wikipedia.org/wiki/Grayscale#Converting_color_to_grayscale
      var val = rgb[0] * 0.3 + rgb[1] * 0.59 + rgb[2] * 0.11;
      this.setValues("rgb", [val, val, val]);
      return this;
   },

   clearer: function(ratio) {
      this.setValues("alpha", this.values.alpha - (this.values.alpha * ratio));
      return this;
   },

   opaquer: function(ratio) {
      this.setValues("alpha", this.values.alpha + (this.values.alpha * ratio));
      return this;
   },

   rotate: function(degrees) {
      var hue = this.values.hsl[0];
      hue = (hue + degrees) % 360;
      hue = hue < 0 ? 360 + hue : hue;
      this.values.hsl[0] = hue;
      this.setValues("hsl", this.values.hsl);
      return this;
   },

   mix: function(color2, weight) {
      weight = 1 - (weight == null ? 0.5 : weight);

      // algorithm from Sass's mix(). Ratio of first color in mix is
      // determined by the alphas of both colors and the weight
      var t1 = weight * 2 - 1,
          d = this.alpha() - color2.alpha();

      var weight1 = (((t1 * d == -1) ? t1 : (t1 + d) / (1 + t1 * d)) + 1) / 2;
      var weight2 = 1 - weight1;

      var rgb = this.rgbArray();
      var rgb2 = color2.rgbArray();

      for (var i = 0; i < rgb.length; i++) {
         rgb[i] = rgb[i] * weight1 + rgb2[i] * weight2;
      }
      this.setValues("rgb", rgb);

      var alpha = this.alpha() * weight + color2.alpha() * (1 - weight);
      this.setValues("alpha", alpha);

      return this;
   },

   toJSON: function() {
     return this.rgb();
   },

   clone: function() {
     return new Color(this.rgb());
   }
}


Color.prototype.getValues = function(space) {
   var vals = {};
   for (var i = 0; i < space.length; i++) {
      vals[space.charAt(i)] = this.values[space][i];
   }
   if (this.values.alpha != 1) {
      vals["a"] = this.values.alpha;
   }
   // {r: 255, g: 255, b: 255, a: 0.4}
   return vals;
}

Color.prototype.setValues = function(space, vals) {
   var spaces = {
      "rgb": ["red", "green", "blue"],
      "hsl": ["hue", "saturation", "lightness"],
      "hsv": ["hue", "saturation", "value"],
      "hwb": ["hue", "whiteness", "blackness"],
      "cmyk": ["cyan", "magenta", "yellow", "black"]
   };

   var maxes = {
      "rgb": [255, 255, 255],
      "hsl": [360, 100, 100],
      "hsv": [360, 100, 100],
      "hwb": [360, 100, 100],
      "cmyk": [100, 100, 100, 100]
   };

   var alpha = 1;
   if (space == "alpha") {
      alpha = vals;
   }
   else if (vals.length) {
      // [10, 10, 10]
      this.values[space] = vals.slice(0, space.length);
      alpha = vals[space.length];
   }
   else if (vals[space.charAt(0)] !== undefined) {
      // {r: 10, g: 10, b: 10}
      for (var i = 0; i < space.length; i++) {
        this.values[space][i] = vals[space.charAt(i)];
      }
      alpha = vals.a;
   }
   else if (vals[spaces[space][0]] !== undefined) {
      // {red: 10, green: 10, blue: 10}
      var chans = spaces[space];
      for (var i = 0; i < space.length; i++) {
        this.values[space][i] = vals[chans[i]];
      }
      alpha = vals.alpha;
   }
   this.values.alpha = Math.max(0, Math.min(1, (alpha !== undefined ? alpha : this.values.alpha) ));
   if (space == "alpha") {
      return;
   }

   // cap values of the space prior converting all values
   for (var i = 0; i < space.length; i++) {
      var capped = Math.max(0, Math.min(maxes[space][i], this.values[space][i]));
      this.values[space][i] = Math.round(capped);
   }

   // convert to all the other color spaces
   for (var sname in spaces) {
      if (sname != space) {
         this.values[sname] = convert[space][sname](this.values[space])
      }

      // cap values
      for (var i = 0; i < sname.length; i++) {
         var capped = Math.max(0, Math.min(maxes[sname][i], this.values[sname][i]));
         this.values[sname][i] = Math.round(capped);
      }
   }
   return true;
}

Color.prototype.setSpace = function(space, args) {
   var vals = args[0];
   if (vals === undefined) {
      // color.rgb()
      return this.getValues(space);
   }
   // color.rgb(10, 10, 10)
   if (typeof vals == "number") {
      vals = Array.prototype.slice.call(args);
   }
   this.setValues(space, vals);
   return this;
}

Color.prototype.setChannel = function(space, index, val) {
   if (val === undefined) {
      // color.red()
      return this.values[space][index];
   }
   // color.red(100)
   this.values[space][index] = val;
   this.setValues(space, this.values[space]);
   return this;
}

module.exports = Color;

},{"color-convert":3,"color-string":5}],7:[function(require,module,exports){
module.exports = require('./lib/geocrunch');
},{"./lib/geocrunch":12}],8:[function(require,module,exports){
// distance.js - Distance mixins for Paths

var _ = require('underscore');

var R = require('./constants').EARTHRADIUS;
var units = require('./units');
var flipCoords = require('./flipcoords');

// Area conversions (from sqmeters)
var convertFuncs = {
  sqmeters: function (a) {
    return a;
  },
  sqmiles: function (a) {
    return units.sqMeters.toSqMiles(a);
  },
  acres: function (a) {
    return units.sqMeters.toAcres(a);
  }
};

// Calculates area in square meters
// Method taken from OpenLayers API, https://github.com/openlayers/openlayers/blob/master/lib/OpenLayers/Geometry/LinearRing.js#L270
var calcArea = function (coordArray) {
  var area = 0, i, l, c1, c2;
  for (i = 0, l = coordArray.length; i < l; i += 1) {
    c1 = coordArray[i];
    c2 = coordArray[(i + 1) % coordArray.length]; // Access next item in array until last item is i, then accesses first (0)
    area = area + units.degrees.toRadians(c2[0] - c1[0]) * (2 + Math.sin(units.degrees.toRadians(c1[1])) + Math.sin(units.degrees.toRadians(c2[1])));
  }
  return Math.abs(area * R * R / 2);
};

var calcCenter = function (coordArray) {
  var offset = coordArray[0], twiceArea = 0, x = 0, y = 0, i, l, c1, c2, f;
  if (coordArray.length === 1) {
    return coordArray[0];
  }
  for (i = 0, l = coordArray.length; i < l; i += 1) {
    c1 = coordArray[i];
    c2 = coordArray[(i + 1) % coordArray.length]; // Access next item in array until last item is i, then accesses first (0)
    f = (c1[1] - offset[1]) * (c2[0] - offset[0]) - (c2[1] - offset[1]) * (c1[0] - offset[0]);
    twiceArea = twiceArea + f;
    x = x + ((c1[0] + c2[0] - 2 * offset[0]) * f);
    y = y + ((c1[1] + c2[1] - 2 * offset[1]) * f);
  }
  f = twiceArea * 3;
  return [x / f + offset[0], y / f + offset[1]];
};

module.exports = {
  _internalAreaCalc: function () {
    // If not set, set this._calcedArea to total area in UNITS
    // Checks for cache to prevent additional unnecessary calcs
    if (!this._calcedArea) {
      if (this._coords.length < 3) {
        this._calcedArea = 0;
      } else {
        this._calcedArea = calcArea(this._coords);
      }
    }
  },
  _internalCenterCalc: function () {
    if (!this._calcedCenter && this._coords.length) {
      this._calcedCenter = calcCenter(this._coords);
    }
  },
  area: function (options) {
    var opts = _.extend({
      units: 'sqmeters'
    }, options);
    this._internalAreaCalc();
    if (_.isFunction(convertFuncs[opts.units])) {
      return convertFuncs[opts.units](this._calcedArea);
    }
    // TODO. Handle non-matching units
  },
  center: function () {
    this._internalCenterCalc();
    return this._options.imBackwards === true ? flipCoords(this._calcedCenter) : this._calcedCenter;
  }
};
},{"./constants":9,"./flipcoords":11,"./units":14,"underscore":15}],9:[function(require,module,exports){
// utils/constants.js

module.exports = {
  EARTHRADIUS: 6371000 // R in meters
};
},{}],10:[function(require,module,exports){
// distance.js - Distance mixins for Paths

var _ = require('underscore');

var R = require('./constants').EARTHRADIUS;
var units = require('./units');

// Distance conversions (from meters)
var convertFuncs = {
  meters: function (d) {
    return d;
  },
  kilometers: function (d) {
    return units.meters.toKilometers(d);
  },
  feet: function (d) {
    return units.meters.toFeet(d);
  },
  miles: function (d) {
    return units.meters.toMiles(d);
  }
};

// Distance in meters
// Always positive regardless of direction
// Calculation based on Haversine Formula http://en.wikipedia.org/wiki/Haversine_formula
// Another method is @ http://www.movable-type.co.uk/scripts/latlong-vincenty.html but seems way overcomplicated
var calcDistance = function (coord1, coord2) {
  var deltaLng = units.degrees.toRadians(coord1[0] - coord2[0]),
      deltaLat = units.degrees.toRadians(coord1[1] - coord2[1]),
      lat1 = units.degrees.toRadians(coord1[1]),
      lat2 = units.degrees.toRadians(coord2[1]),
      hvsLng = Math.sin(deltaLng / 2),
      hvsLat = Math.sin(deltaLat / 2);

  var a = hvsLat * hvsLat + hvsLng * hvsLng * Math.cos(lat1) * Math.cos(lat2);
  return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
};

module.exports = {
  _internalDistanceCalc: function () {
    // If not set, set this._calcedDistance to total distance in meters
    // Checks for cache to prevent additional unnecessary calcs
    var distance = 0, i, l;
    if (!this._calcedDistance) {
      for (i = 0, l = this._coords.length; i < l; i += 1) {
        if (i > 0) {
          distance = distance + calcDistance(this._coords[i - 1], this._coords[i]);
        }
      }
      this._calcedDistance = distance;
    }
  },
  distance: function (options) {
    var opts = _.extend({
      units: 'meters'
    }, options);
    this._internalDistanceCalc();
    if (_.isFunction(convertFuncs[opts.units])) {
      return convertFuncs[opts.units](this._calcedDistance);
    }
    // TODO. Handle non-matching units
  }
};
},{"./constants":9,"./units":14,"underscore":15}],11:[function(require,module,exports){
// utils/flipcoords.js - Util functions for working with backwards coordinates [lat, lng]

var _ = require('underscore');

module.exports = function (backwardsCoordArray) {
  return _.map(backwardsCoordArray, function (backwardsCoord) {
    return [backwardsCoord[1], backwardsCoord[0]];
  });
};
},{"underscore":15}],12:[function(require,module,exports){
// geocrunch.js

var _ = require('underscore');

var Path = require('./path');
var distanceMixins = require('./distance'),
    areaMixins = require('./area');

_.extend(Path.prototype, distanceMixins, areaMixins);

exports.path = function (coords, options) {
  return new Path(coords, options);
};
},{"./area":8,"./distance":10,"./path":13,"underscore":15}],13:[function(require,module,exports){
// path.js - Object for working with a linear path of coordinates

var flipCoords = require('./flipcoords');

var Path = function (coords, options) {
  this._options = options || {};

  // Set this._coords... Think about flipping at time of calcs for less iterations/better perf. May risk code clarity and mixin ease.
  coords = coords || [];
  this._coords = this._options.imBackwards === true ? flipCoords(coords) : coords;
};

module.exports = Path;

},{"./flipcoords":11}],14:[function(require,module,exports){
// units.js - Standard unit conversions

exports.meters = {
  toFeet: function (m) {
    return m * 3.28084;
  },
  toKilometers: function (m) {
    return m * 0.001;
  },
  toMiles: function (m) {
    return m * 0.000621371;
  }
};

exports.sqMeters = {
  toSqMiles: function (m) {
    return m * 0.000000386102;
  },
  toAcres: function (m) {
    return m * 0.000247105;
  }
};

exports.degrees = {
  toRadians: function (d) {
    return d * Math.PI / 180;
  }
};
},{}],15:[function(require,module,exports){
//     Underscore.js 1.5.2
//     http://underscorejs.org
//     (c) 2009-2013 Jeremy Ashkenas, DocumentCloud and Investigative Reporters & Editors
//     Underscore may be freely distributed under the MIT license.

(function() {

  // Baseline setup
  // --------------

  // Establish the root object, `window` in the browser, or `exports` on the server.
  var root = this;

  // Save the previous value of the `_` variable.
  var previousUnderscore = root._;

  // Establish the object that gets returned to break out of a loop iteration.
  var breaker = {};

  // Save bytes in the minified (but not gzipped) version:
  var ArrayProto = Array.prototype, ObjProto = Object.prototype, FuncProto = Function.prototype;

  // Create quick reference variables for speed access to core prototypes.
  var
    push             = ArrayProto.push,
    slice            = ArrayProto.slice,
    concat           = ArrayProto.concat,
    toString         = ObjProto.toString,
    hasOwnProperty   = ObjProto.hasOwnProperty;

  // All **ECMAScript 5** native function implementations that we hope to use
  // are declared here.
  var
    nativeForEach      = ArrayProto.forEach,
    nativeMap          = ArrayProto.map,
    nativeReduce       = ArrayProto.reduce,
    nativeReduceRight  = ArrayProto.reduceRight,
    nativeFilter       = ArrayProto.filter,
    nativeEvery        = ArrayProto.every,
    nativeSome         = ArrayProto.some,
    nativeIndexOf      = ArrayProto.indexOf,
    nativeLastIndexOf  = ArrayProto.lastIndexOf,
    nativeIsArray      = Array.isArray,
    nativeKeys         = Object.keys,
    nativeBind         = FuncProto.bind;

  // Create a safe reference to the Underscore object for use below.
  var _ = function(obj) {
    if (obj instanceof _) return obj;
    if (!(this instanceof _)) return new _(obj);
    this._wrapped = obj;
  };

  // Export the Underscore object for **Node.js**, with
  // backwards-compatibility for the old `require()` API. If we're in
  // the browser, add `_` as a global object via a string identifier,
  // for Closure Compiler "advanced" mode.
  if (typeof exports !== 'undefined') {
    if (typeof module !== 'undefined' && module.exports) {
      exports = module.exports = _;
    }
    exports._ = _;
  } else {
    root._ = _;
  }

  // Current version.
  _.VERSION = '1.5.2';

  // Collection Functions
  // --------------------

  // The cornerstone, an `each` implementation, aka `forEach`.
  // Handles objects with the built-in `forEach`, arrays, and raw objects.
  // Delegates to **ECMAScript 5**'s native `forEach` if available.
  var each = _.each = _.forEach = function(obj, iterator, context) {
    if (obj == null) return;
    if (nativeForEach && obj.forEach === nativeForEach) {
      obj.forEach(iterator, context);
    } else if (obj.length === +obj.length) {
      for (var i = 0, length = obj.length; i < length; i++) {
        if (iterator.call(context, obj[i], i, obj) === breaker) return;
      }
    } else {
      var keys = _.keys(obj);
      for (var i = 0, length = keys.length; i < length; i++) {
        if (iterator.call(context, obj[keys[i]], keys[i], obj) === breaker) return;
      }
    }
  };

  // Return the results of applying the iterator to each element.
  // Delegates to **ECMAScript 5**'s native `map` if available.
  _.map = _.collect = function(obj, iterator, context) {
    var results = [];
    if (obj == null) return results;
    if (nativeMap && obj.map === nativeMap) return obj.map(iterator, context);
    each(obj, function(value, index, list) {
      results.push(iterator.call(context, value, index, list));
    });
    return results;
  };

  var reduceError = 'Reduce of empty array with no initial value';

  // **Reduce** builds up a single result from a list of values, aka `inject`,
  // or `foldl`. Delegates to **ECMAScript 5**'s native `reduce` if available.
  _.reduce = _.foldl = _.inject = function(obj, iterator, memo, context) {
    var initial = arguments.length > 2;
    if (obj == null) obj = [];
    if (nativeReduce && obj.reduce === nativeReduce) {
      if (context) iterator = _.bind(iterator, context);
      return initial ? obj.reduce(iterator, memo) : obj.reduce(iterator);
    }
    each(obj, function(value, index, list) {
      if (!initial) {
        memo = value;
        initial = true;
      } else {
        memo = iterator.call(context, memo, value, index, list);
      }
    });
    if (!initial) throw new TypeError(reduceError);
    return memo;
  };

  // The right-associative version of reduce, also known as `foldr`.
  // Delegates to **ECMAScript 5**'s native `reduceRight` if available.
  _.reduceRight = _.foldr = function(obj, iterator, memo, context) {
    var initial = arguments.length > 2;
    if (obj == null) obj = [];
    if (nativeReduceRight && obj.reduceRight === nativeReduceRight) {
      if (context) iterator = _.bind(iterator, context);
      return initial ? obj.reduceRight(iterator, memo) : obj.reduceRight(iterator);
    }
    var length = obj.length;
    if (length !== +length) {
      var keys = _.keys(obj);
      length = keys.length;
    }
    each(obj, function(value, index, list) {
      index = keys ? keys[--length] : --length;
      if (!initial) {
        memo = obj[index];
        initial = true;
      } else {
        memo = iterator.call(context, memo, obj[index], index, list);
      }
    });
    if (!initial) throw new TypeError(reduceError);
    return memo;
  };

  // Return the first value which passes a truth test. Aliased as `detect`.
  _.find = _.detect = function(obj, iterator, context) {
    var result;
    any(obj, function(value, index, list) {
      if (iterator.call(context, value, index, list)) {
        result = value;
        return true;
      }
    });
    return result;
  };

  // Return all the elements that pass a truth test.
  // Delegates to **ECMAScript 5**'s native `filter` if available.
  // Aliased as `select`.
  _.filter = _.select = function(obj, iterator, context) {
    var results = [];
    if (obj == null) return results;
    if (nativeFilter && obj.filter === nativeFilter) return obj.filter(iterator, context);
    each(obj, function(value, index, list) {
      if (iterator.call(context, value, index, list)) results.push(value);
    });
    return results;
  };

  // Return all the elements for which a truth test fails.
  _.reject = function(obj, iterator, context) {
    return _.filter(obj, function(value, index, list) {
      return !iterator.call(context, value, index, list);
    }, context);
  };

  // Determine whether all of the elements match a truth test.
  // Delegates to **ECMAScript 5**'s native `every` if available.
  // Aliased as `all`.
  _.every = _.all = function(obj, iterator, context) {
    iterator || (iterator = _.identity);
    var result = true;
    if (obj == null) return result;
    if (nativeEvery && obj.every === nativeEvery) return obj.every(iterator, context);
    each(obj, function(value, index, list) {
      if (!(result = result && iterator.call(context, value, index, list))) return breaker;
    });
    return !!result;
  };

  // Determine if at least one element in the object matches a truth test.
  // Delegates to **ECMAScript 5**'s native `some` if available.
  // Aliased as `any`.
  var any = _.some = _.any = function(obj, iterator, context) {
    iterator || (iterator = _.identity);
    var result = false;
    if (obj == null) return result;
    if (nativeSome && obj.some === nativeSome) return obj.some(iterator, context);
    each(obj, function(value, index, list) {
      if (result || (result = iterator.call(context, value, index, list))) return breaker;
    });
    return !!result;
  };

  // Determine if the array or object contains a given value (using `===`).
  // Aliased as `include`.
  _.contains = _.include = function(obj, target) {
    if (obj == null) return false;
    if (nativeIndexOf && obj.indexOf === nativeIndexOf) return obj.indexOf(target) != -1;
    return any(obj, function(value) {
      return value === target;
    });
  };

  // Invoke a method (with arguments) on every item in a collection.
  _.invoke = function(obj, method) {
    var args = slice.call(arguments, 2);
    var isFunc = _.isFunction(method);
    return _.map(obj, function(value) {
      return (isFunc ? method : value[method]).apply(value, args);
    });
  };

  // Convenience version of a common use case of `map`: fetching a property.
  _.pluck = function(obj, key) {
    return _.map(obj, function(value){ return value[key]; });
  };

  // Convenience version of a common use case of `filter`: selecting only objects
  // containing specific `key:value` pairs.
  _.where = function(obj, attrs, first) {
    if (_.isEmpty(attrs)) return first ? void 0 : [];
    return _[first ? 'find' : 'filter'](obj, function(value) {
      for (var key in attrs) {
        if (attrs[key] !== value[key]) return false;
      }
      return true;
    });
  };

  // Convenience version of a common use case of `find`: getting the first object
  // containing specific `key:value` pairs.
  _.findWhere = function(obj, attrs) {
    return _.where(obj, attrs, true);
  };

  // Return the maximum element or (element-based computation).
  // Can't optimize arrays of integers longer than 65,535 elements.
  // See [WebKit Bug 80797](https://bugs.webkit.org/show_bug.cgi?id=80797)
  _.max = function(obj, iterator, context) {
    if (!iterator && _.isArray(obj) && obj[0] === +obj[0] && obj.length < 65535) {
      return Math.max.apply(Math, obj);
    }
    if (!iterator && _.isEmpty(obj)) return -Infinity;
    var result = {computed : -Infinity, value: -Infinity};
    each(obj, function(value, index, list) {
      var computed = iterator ? iterator.call(context, value, index, list) : value;
      computed > result.computed && (result = {value : value, computed : computed});
    });
    return result.value;
  };

  // Return the minimum element (or element-based computation).
  _.min = function(obj, iterator, context) {
    if (!iterator && _.isArray(obj) && obj[0] === +obj[0] && obj.length < 65535) {
      return Math.min.apply(Math, obj);
    }
    if (!iterator && _.isEmpty(obj)) return Infinity;
    var result = {computed : Infinity, value: Infinity};
    each(obj, function(value, index, list) {
      var computed = iterator ? iterator.call(context, value, index, list) : value;
      computed < result.computed && (result = {value : value, computed : computed});
    });
    return result.value;
  };

  // Shuffle an array, using the modern version of the 
  // [Fisher-Yates shuffle](http://en.wikipedia.org/wiki/Fisher–Yates_shuffle).
  _.shuffle = function(obj) {
    var rand;
    var index = 0;
    var shuffled = [];
    each(obj, function(value) {
      rand = _.random(index++);
      shuffled[index - 1] = shuffled[rand];
      shuffled[rand] = value;
    });
    return shuffled;
  };

  // Sample **n** random values from an array.
  // If **n** is not specified, returns a single random element from the array.
  // The internal `guard` argument allows it to work with `map`.
  _.sample = function(obj, n, guard) {
    if (arguments.length < 2 || guard) {
      return obj[_.random(obj.length - 1)];
    }
    return _.shuffle(obj).slice(0, Math.max(0, n));
  };

  // An internal function to generate lookup iterators.
  var lookupIterator = function(value) {
    return _.isFunction(value) ? value : function(obj){ return obj[value]; };
  };

  // Sort the object's values by a criterion produced by an iterator.
  _.sortBy = function(obj, value, context) {
    var iterator = lookupIterator(value);
    return _.pluck(_.map(obj, function(value, index, list) {
      return {
        value: value,
        index: index,
        criteria: iterator.call(context, value, index, list)
      };
    }).sort(function(left, right) {
      var a = left.criteria;
      var b = right.criteria;
      if (a !== b) {
        if (a > b || a === void 0) return 1;
        if (a < b || b === void 0) return -1;
      }
      return left.index - right.index;
    }), 'value');
  };

  // An internal function used for aggregate "group by" operations.
  var group = function(behavior) {
    return function(obj, value, context) {
      var result = {};
      var iterator = value == null ? _.identity : lookupIterator(value);
      each(obj, function(value, index) {
        var key = iterator.call(context, value, index, obj);
        behavior(result, key, value);
      });
      return result;
    };
  };

  // Groups the object's values by a criterion. Pass either a string attribute
  // to group by, or a function that returns the criterion.
  _.groupBy = group(function(result, key, value) {
    (_.has(result, key) ? result[key] : (result[key] = [])).push(value);
  });

  // Indexes the object's values by a criterion, similar to `groupBy`, but for
  // when you know that your index values will be unique.
  _.indexBy = group(function(result, key, value) {
    result[key] = value;
  });

  // Counts instances of an object that group by a certain criterion. Pass
  // either a string attribute to count by, or a function that returns the
  // criterion.
  _.countBy = group(function(result, key) {
    _.has(result, key) ? result[key]++ : result[key] = 1;
  });

  // Use a comparator function to figure out the smallest index at which
  // an object should be inserted so as to maintain order. Uses binary search.
  _.sortedIndex = function(array, obj, iterator, context) {
    iterator = iterator == null ? _.identity : lookupIterator(iterator);
    var value = iterator.call(context, obj);
    var low = 0, high = array.length;
    while (low < high) {
      var mid = (low + high) >>> 1;
      iterator.call(context, array[mid]) < value ? low = mid + 1 : high = mid;
    }
    return low;
  };

  // Safely create a real, live array from anything iterable.
  _.toArray = function(obj) {
    if (!obj) return [];
    if (_.isArray(obj)) return slice.call(obj);
    if (obj.length === +obj.length) return _.map(obj, _.identity);
    return _.values(obj);
  };

  // Return the number of elements in an object.
  _.size = function(obj) {
    if (obj == null) return 0;
    return (obj.length === +obj.length) ? obj.length : _.keys(obj).length;
  };

  // Array Functions
  // ---------------

  // Get the first element of an array. Passing **n** will return the first N
  // values in the array. Aliased as `head` and `take`. The **guard** check
  // allows it to work with `_.map`.
  _.first = _.head = _.take = function(array, n, guard) {
    if (array == null) return void 0;
    return (n == null) || guard ? array[0] : slice.call(array, 0, n);
  };

  // Returns everything but the last entry of the array. Especially useful on
  // the arguments object. Passing **n** will return all the values in
  // the array, excluding the last N. The **guard** check allows it to work with
  // `_.map`.
  _.initial = function(array, n, guard) {
    return slice.call(array, 0, array.length - ((n == null) || guard ? 1 : n));
  };

  // Get the last element of an array. Passing **n** will return the last N
  // values in the array. The **guard** check allows it to work with `_.map`.
  _.last = function(array, n, guard) {
    if (array == null) return void 0;
    if ((n == null) || guard) {
      return array[array.length - 1];
    } else {
      return slice.call(array, Math.max(array.length - n, 0));
    }
  };

  // Returns everything but the first entry of the array. Aliased as `tail` and `drop`.
  // Especially useful on the arguments object. Passing an **n** will return
  // the rest N values in the array. The **guard**
  // check allows it to work with `_.map`.
  _.rest = _.tail = _.drop = function(array, n, guard) {
    return slice.call(array, (n == null) || guard ? 1 : n);
  };

  // Trim out all falsy values from an array.
  _.compact = function(array) {
    return _.filter(array, _.identity);
  };

  // Internal implementation of a recursive `flatten` function.
  var flatten = function(input, shallow, output) {
    if (shallow && _.every(input, _.isArray)) {
      return concat.apply(output, input);
    }
    each(input, function(value) {
      if (_.isArray(value) || _.isArguments(value)) {
        shallow ? push.apply(output, value) : flatten(value, shallow, output);
      } else {
        output.push(value);
      }
    });
    return output;
  };

  // Flatten out an array, either recursively (by default), or just one level.
  _.flatten = function(array, shallow) {
    return flatten(array, shallow, []);
  };

  // Return a version of the array that does not contain the specified value(s).
  _.without = function(array) {
    return _.difference(array, slice.call(arguments, 1));
  };

  // Produce a duplicate-free version of the array. If the array has already
  // been sorted, you have the option of using a faster algorithm.
  // Aliased as `unique`.
  _.uniq = _.unique = function(array, isSorted, iterator, context) {
    if (_.isFunction(isSorted)) {
      context = iterator;
      iterator = isSorted;
      isSorted = false;
    }
    var initial = iterator ? _.map(array, iterator, context) : array;
    var results = [];
    var seen = [];
    each(initial, function(value, index) {
      if (isSorted ? (!index || seen[seen.length - 1] !== value) : !_.contains(seen, value)) {
        seen.push(value);
        results.push(array[index]);
      }
    });
    return results;
  };

  // Produce an array that contains the union: each distinct element from all of
  // the passed-in arrays.
  _.union = function() {
    return _.uniq(_.flatten(arguments, true));
  };

  // Produce an array that contains every item shared between all the
  // passed-in arrays.
  _.intersection = function(array) {
    var rest = slice.call(arguments, 1);
    return _.filter(_.uniq(array), function(item) {
      return _.every(rest, function(other) {
        return _.indexOf(other, item) >= 0;
      });
    });
  };

  // Take the difference between one array and a number of other arrays.
  // Only the elements present in just the first array will remain.
  _.difference = function(array) {
    var rest = concat.apply(ArrayProto, slice.call(arguments, 1));
    return _.filter(array, function(value){ return !_.contains(rest, value); });
  };

  // Zip together multiple lists into a single array -- elements that share
  // an index go together.
  _.zip = function() {
    var length = _.max(_.pluck(arguments, "length").concat(0));
    var results = new Array(length);
    for (var i = 0; i < length; i++) {
      results[i] = _.pluck(arguments, '' + i);
    }
    return results;
  };

  // Converts lists into objects. Pass either a single array of `[key, value]`
  // pairs, or two parallel arrays of the same length -- one of keys, and one of
  // the corresponding values.
  _.object = function(list, values) {
    if (list == null) return {};
    var result = {};
    for (var i = 0, length = list.length; i < length; i++) {
      if (values) {
        result[list[i]] = values[i];
      } else {
        result[list[i][0]] = list[i][1];
      }
    }
    return result;
  };

  // If the browser doesn't supply us with indexOf (I'm looking at you, **MSIE**),
  // we need this function. Return the position of the first occurrence of an
  // item in an array, or -1 if the item is not included in the array.
  // Delegates to **ECMAScript 5**'s native `indexOf` if available.
  // If the array is large and already in sort order, pass `true`
  // for **isSorted** to use binary search.
  _.indexOf = function(array, item, isSorted) {
    if (array == null) return -1;
    var i = 0, length = array.length;
    if (isSorted) {
      if (typeof isSorted == 'number') {
        i = (isSorted < 0 ? Math.max(0, length + isSorted) : isSorted);
      } else {
        i = _.sortedIndex(array, item);
        return array[i] === item ? i : -1;
      }
    }
    if (nativeIndexOf && array.indexOf === nativeIndexOf) return array.indexOf(item, isSorted);
    for (; i < length; i++) if (array[i] === item) return i;
    return -1;
  };

  // Delegates to **ECMAScript 5**'s native `lastIndexOf` if available.
  _.lastIndexOf = function(array, item, from) {
    if (array == null) return -1;
    var hasIndex = from != null;
    if (nativeLastIndexOf && array.lastIndexOf === nativeLastIndexOf) {
      return hasIndex ? array.lastIndexOf(item, from) : array.lastIndexOf(item);
    }
    var i = (hasIndex ? from : array.length);
    while (i--) if (array[i] === item) return i;
    return -1;
  };

  // Generate an integer Array containing an arithmetic progression. A port of
  // the native Python `range()` function. See
  // [the Python documentation](http://docs.python.org/library/functions.html#range).
  _.range = function(start, stop, step) {
    if (arguments.length <= 1) {
      stop = start || 0;
      start = 0;
    }
    step = arguments[2] || 1;

    var length = Math.max(Math.ceil((stop - start) / step), 0);
    var idx = 0;
    var range = new Array(length);

    while(idx < length) {
      range[idx++] = start;
      start += step;
    }

    return range;
  };

  // Function (ahem) Functions
  // ------------------

  // Reusable constructor function for prototype setting.
  var ctor = function(){};

  // Create a function bound to a given object (assigning `this`, and arguments,
  // optionally). Delegates to **ECMAScript 5**'s native `Function.bind` if
  // available.
  _.bind = function(func, context) {
    var args, bound;
    if (nativeBind && func.bind === nativeBind) return nativeBind.apply(func, slice.call(arguments, 1));
    if (!_.isFunction(func)) throw new TypeError;
    args = slice.call(arguments, 2);
    return bound = function() {
      if (!(this instanceof bound)) return func.apply(context, args.concat(slice.call(arguments)));
      ctor.prototype = func.prototype;
      var self = new ctor;
      ctor.prototype = null;
      var result = func.apply(self, args.concat(slice.call(arguments)));
      if (Object(result) === result) return result;
      return self;
    };
  };

  // Partially apply a function by creating a version that has had some of its
  // arguments pre-filled, without changing its dynamic `this` context.
  _.partial = function(func) {
    var args = slice.call(arguments, 1);
    return function() {
      return func.apply(this, args.concat(slice.call(arguments)));
    };
  };

  // Bind all of an object's methods to that object. Useful for ensuring that
  // all callbacks defined on an object belong to it.
  _.bindAll = function(obj) {
    var funcs = slice.call(arguments, 1);
    if (funcs.length === 0) throw new Error("bindAll must be passed function names");
    each(funcs, function(f) { obj[f] = _.bind(obj[f], obj); });
    return obj;
  };

  // Memoize an expensive function by storing its results.
  _.memoize = function(func, hasher) {
    var memo = {};
    hasher || (hasher = _.identity);
    return function() {
      var key = hasher.apply(this, arguments);
      return _.has(memo, key) ? memo[key] : (memo[key] = func.apply(this, arguments));
    };
  };

  // Delays a function for the given number of milliseconds, and then calls
  // it with the arguments supplied.
  _.delay = function(func, wait) {
    var args = slice.call(arguments, 2);
    return setTimeout(function(){ return func.apply(null, args); }, wait);
  };

  // Defers a function, scheduling it to run after the current call stack has
  // cleared.
  _.defer = function(func) {
    return _.delay.apply(_, [func, 1].concat(slice.call(arguments, 1)));
  };

  // Returns a function, that, when invoked, will only be triggered at most once
  // during a given window of time. Normally, the throttled function will run
  // as much as it can, without ever going more than once per `wait` duration;
  // but if you'd like to disable the execution on the leading edge, pass
  // `{leading: false}`. To disable execution on the trailing edge, ditto.
  _.throttle = function(func, wait, options) {
    var context, args, result;
    var timeout = null;
    var previous = 0;
    options || (options = {});
    var later = function() {
      previous = options.leading === false ? 0 : new Date;
      timeout = null;
      result = func.apply(context, args);
    };
    return function() {
      var now = new Date;
      if (!previous && options.leading === false) previous = now;
      var remaining = wait - (now - previous);
      context = this;
      args = arguments;
      if (remaining <= 0) {
        clearTimeout(timeout);
        timeout = null;
        previous = now;
        result = func.apply(context, args);
      } else if (!timeout && options.trailing !== false) {
        timeout = setTimeout(later, remaining);
      }
      return result;
    };
  };

  // Returns a function, that, as long as it continues to be invoked, will not
  // be triggered. The function will be called after it stops being called for
  // N milliseconds. If `immediate` is passed, trigger the function on the
  // leading edge, instead of the trailing.
  _.debounce = function(func, wait, immediate) {
    var timeout, args, context, timestamp, result;
    return function() {
      context = this;
      args = arguments;
      timestamp = new Date();
      var later = function() {
        var last = (new Date()) - timestamp;
        if (last < wait) {
          timeout = setTimeout(later, wait - last);
        } else {
          timeout = null;
          if (!immediate) result = func.apply(context, args);
        }
      };
      var callNow = immediate && !timeout;
      if (!timeout) {
        timeout = setTimeout(later, wait);
      }
      if (callNow) result = func.apply(context, args);
      return result;
    };
  };

  // Returns a function that will be executed at most one time, no matter how
  // often you call it. Useful for lazy initialization.
  _.once = function(func) {
    var ran = false, memo;
    return function() {
      if (ran) return memo;
      ran = true;
      memo = func.apply(this, arguments);
      func = null;
      return memo;
    };
  };

  // Returns the first function passed as an argument to the second,
  // allowing you to adjust arguments, run code before and after, and
  // conditionally execute the original function.
  _.wrap = function(func, wrapper) {
    return function() {
      var args = [func];
      push.apply(args, arguments);
      return wrapper.apply(this, args);
    };
  };

  // Returns a function that is the composition of a list of functions, each
  // consuming the return value of the function that follows.
  _.compose = function() {
    var funcs = arguments;
    return function() {
      var args = arguments;
      for (var i = funcs.length - 1; i >= 0; i--) {
        args = [funcs[i].apply(this, args)];
      }
      return args[0];
    };
  };

  // Returns a function that will only be executed after being called N times.
  _.after = function(times, func) {
    return function() {
      if (--times < 1) {
        return func.apply(this, arguments);
      }
    };
  };

  // Object Functions
  // ----------------

  // Retrieve the names of an object's properties.
  // Delegates to **ECMAScript 5**'s native `Object.keys`
  _.keys = nativeKeys || function(obj) {
    if (obj !== Object(obj)) throw new TypeError('Invalid object');
    var keys = [];
    for (var key in obj) if (_.has(obj, key)) keys.push(key);
    return keys;
  };

  // Retrieve the values of an object's properties.
  _.values = function(obj) {
    var keys = _.keys(obj);
    var length = keys.length;
    var values = new Array(length);
    for (var i = 0; i < length; i++) {
      values[i] = obj[keys[i]];
    }
    return values;
  };

  // Convert an object into a list of `[key, value]` pairs.
  _.pairs = function(obj) {
    var keys = _.keys(obj);
    var length = keys.length;
    var pairs = new Array(length);
    for (var i = 0; i < length; i++) {
      pairs[i] = [keys[i], obj[keys[i]]];
    }
    return pairs;
  };

  // Invert the keys and values of an object. The values must be serializable.
  _.invert = function(obj) {
    var result = {};
    var keys = _.keys(obj);
    for (var i = 0, length = keys.length; i < length; i++) {
      result[obj[keys[i]]] = keys[i];
    }
    return result;
  };

  // Return a sorted list of the function names available on the object.
  // Aliased as `methods`
  _.functions = _.methods = function(obj) {
    var names = [];
    for (var key in obj) {
      if (_.isFunction(obj[key])) names.push(key);
    }
    return names.sort();
  };

  // Extend a given object with all the properties in passed-in object(s).
  _.extend = function(obj) {
    each(slice.call(arguments, 1), function(source) {
      if (source) {
        for (var prop in source) {
          obj[prop] = source[prop];
        }
      }
    });
    return obj;
  };

  // Return a copy of the object only containing the whitelisted properties.
  _.pick = function(obj) {
    var copy = {};
    var keys = concat.apply(ArrayProto, slice.call(arguments, 1));
    each(keys, function(key) {
      if (key in obj) copy[key] = obj[key];
    });
    return copy;
  };

   // Return a copy of the object without the blacklisted properties.
  _.omit = function(obj) {
    var copy = {};
    var keys = concat.apply(ArrayProto, slice.call(arguments, 1));
    for (var key in obj) {
      if (!_.contains(keys, key)) copy[key] = obj[key];
    }
    return copy;
  };

  // Fill in a given object with default properties.
  _.defaults = function(obj) {
    each(slice.call(arguments, 1), function(source) {
      if (source) {
        for (var prop in source) {
          if (obj[prop] === void 0) obj[prop] = source[prop];
        }
      }
    });
    return obj;
  };

  // Create a (shallow-cloned) duplicate of an object.
  _.clone = function(obj) {
    if (!_.isObject(obj)) return obj;
    return _.isArray(obj) ? obj.slice() : _.extend({}, obj);
  };

  // Invokes interceptor with the obj, and then returns obj.
  // The primary purpose of this method is to "tap into" a method chain, in
  // order to perform operations on intermediate results within the chain.
  _.tap = function(obj, interceptor) {
    interceptor(obj);
    return obj;
  };

  // Internal recursive comparison function for `isEqual`.
  var eq = function(a, b, aStack, bStack) {
    // Identical objects are equal. `0 === -0`, but they aren't identical.
    // See the [Harmony `egal` proposal](http://wiki.ecmascript.org/doku.php?id=harmony:egal).
    if (a === b) return a !== 0 || 1 / a == 1 / b;
    // A strict comparison is necessary because `null == undefined`.
    if (a == null || b == null) return a === b;
    // Unwrap any wrapped objects.
    if (a instanceof _) a = a._wrapped;
    if (b instanceof _) b = b._wrapped;
    // Compare `[[Class]]` names.
    var className = toString.call(a);
    if (className != toString.call(b)) return false;
    switch (className) {
      // Strings, numbers, dates, and booleans are compared by value.
      case '[object String]':
        // Primitives and their corresponding object wrappers are equivalent; thus, `"5"` is
        // equivalent to `new String("5")`.
        return a == String(b);
      case '[object Number]':
        // `NaN`s are equivalent, but non-reflexive. An `egal` comparison is performed for
        // other numeric values.
        return a != +a ? b != +b : (a == 0 ? 1 / a == 1 / b : a == +b);
      case '[object Date]':
      case '[object Boolean]':
        // Coerce dates and booleans to numeric primitive values. Dates are compared by their
        // millisecond representations. Note that invalid dates with millisecond representations
        // of `NaN` are not equivalent.
        return +a == +b;
      // RegExps are compared by their source patterns and flags.
      case '[object RegExp]':
        return a.source == b.source &&
               a.global == b.global &&
               a.multiline == b.multiline &&
               a.ignoreCase == b.ignoreCase;
    }
    if (typeof a != 'object' || typeof b != 'object') return false;
    // Assume equality for cyclic structures. The algorithm for detecting cyclic
    // structures is adapted from ES 5.1 section 15.12.3, abstract operation `JO`.
    var length = aStack.length;
    while (length--) {
      // Linear search. Performance is inversely proportional to the number of
      // unique nested structures.
      if (aStack[length] == a) return bStack[length] == b;
    }
    // Objects with different constructors are not equivalent, but `Object`s
    // from different frames are.
    var aCtor = a.constructor, bCtor = b.constructor;
    if (aCtor !== bCtor && !(_.isFunction(aCtor) && (aCtor instanceof aCtor) &&
                             _.isFunction(bCtor) && (bCtor instanceof bCtor))) {
      return false;
    }
    // Add the first object to the stack of traversed objects.
    aStack.push(a);
    bStack.push(b);
    var size = 0, result = true;
    // Recursively compare objects and arrays.
    if (className == '[object Array]') {
      // Compare array lengths to determine if a deep comparison is necessary.
      size = a.length;
      result = size == b.length;
      if (result) {
        // Deep compare the contents, ignoring non-numeric properties.
        while (size--) {
          if (!(result = eq(a[size], b[size], aStack, bStack))) break;
        }
      }
    } else {
      // Deep compare objects.
      for (var key in a) {
        if (_.has(a, key)) {
          // Count the expected number of properties.
          size++;
          // Deep compare each member.
          if (!(result = _.has(b, key) && eq(a[key], b[key], aStack, bStack))) break;
        }
      }
      // Ensure that both objects contain the same number of properties.
      if (result) {
        for (key in b) {
          if (_.has(b, key) && !(size--)) break;
        }
        result = !size;
      }
    }
    // Remove the first object from the stack of traversed objects.
    aStack.pop();
    bStack.pop();
    return result;
  };

  // Perform a deep comparison to check if two objects are equal.
  _.isEqual = function(a, b) {
    return eq(a, b, [], []);
  };

  // Is a given array, string, or object empty?
  // An "empty" object has no enumerable own-properties.
  _.isEmpty = function(obj) {
    if (obj == null) return true;
    if (_.isArray(obj) || _.isString(obj)) return obj.length === 0;
    for (var key in obj) if (_.has(obj, key)) return false;
    return true;
  };

  // Is a given value a DOM element?
  _.isElement = function(obj) {
    return !!(obj && obj.nodeType === 1);
  };

  // Is a given value an array?
  // Delegates to ECMA5's native Array.isArray
  _.isArray = nativeIsArray || function(obj) {
    return toString.call(obj) == '[object Array]';
  };

  // Is a given variable an object?
  _.isObject = function(obj) {
    return obj === Object(obj);
  };

  // Add some isType methods: isArguments, isFunction, isString, isNumber, isDate, isRegExp.
  each(['Arguments', 'Function', 'String', 'Number', 'Date', 'RegExp'], function(name) {
    _['is' + name] = function(obj) {
      return toString.call(obj) == '[object ' + name + ']';
    };
  });

  // Define a fallback version of the method in browsers (ahem, IE), where
  // there isn't any inspectable "Arguments" type.
  if (!_.isArguments(arguments)) {
    _.isArguments = function(obj) {
      return !!(obj && _.has(obj, 'callee'));
    };
  }

  // Optimize `isFunction` if appropriate.
  if (typeof (/./) !== 'function') {
    _.isFunction = function(obj) {
      return typeof obj === 'function';
    };
  }

  // Is a given object a finite number?
  _.isFinite = function(obj) {
    return isFinite(obj) && !isNaN(parseFloat(obj));
  };

  // Is the given value `NaN`? (NaN is the only number which does not equal itself).
  _.isNaN = function(obj) {
    return _.isNumber(obj) && obj != +obj;
  };

  // Is a given value a boolean?
  _.isBoolean = function(obj) {
    return obj === true || obj === false || toString.call(obj) == '[object Boolean]';
  };

  // Is a given value equal to null?
  _.isNull = function(obj) {
    return obj === null;
  };

  // Is a given variable undefined?
  _.isUndefined = function(obj) {
    return obj === void 0;
  };

  // Shortcut function for checking if an object has a given property directly
  // on itself (in other words, not on a prototype).
  _.has = function(obj, key) {
    return hasOwnProperty.call(obj, key);
  };

  // Utility Functions
  // -----------------

  // Run Underscore.js in *noConflict* mode, returning the `_` variable to its
  // previous owner. Returns a reference to the Underscore object.
  _.noConflict = function() {
    root._ = previousUnderscore;
    return this;
  };

  // Keep the identity function around for default iterators.
  _.identity = function(value) {
    return value;
  };

  // Run a function **n** times.
  _.times = function(n, iterator, context) {
    var accum = Array(Math.max(0, n));
    for (var i = 0; i < n; i++) accum[i] = iterator.call(context, i);
    return accum;
  };

  // Return a random integer between min and max (inclusive).
  _.random = function(min, max) {
    if (max == null) {
      max = min;
      min = 0;
    }
    return min + Math.floor(Math.random() * (max - min + 1));
  };

  // List of HTML entities for escaping.
  var entityMap = {
    escape: {
      '&': '&amp;',
      '<': '&lt;',
      '>': '&gt;',
      '"': '&quot;',
      "'": '&#x27;'
    }
  };
  entityMap.unescape = _.invert(entityMap.escape);

  // Regexes containing the keys and values listed immediately above.
  var entityRegexes = {
    escape:   new RegExp('[' + _.keys(entityMap.escape).join('') + ']', 'g'),
    unescape: new RegExp('(' + _.keys(entityMap.unescape).join('|') + ')', 'g')
  };

  // Functions for escaping and unescaping strings to/from HTML interpolation.
  _.each(['escape', 'unescape'], function(method) {
    _[method] = function(string) {
      if (string == null) return '';
      return ('' + string).replace(entityRegexes[method], function(match) {
        return entityMap[method][match];
      });
    };
  });

  // If the value of the named `property` is a function then invoke it with the
  // `object` as context; otherwise, return it.
  _.result = function(object, property) {
    if (object == null) return void 0;
    var value = object[property];
    return _.isFunction(value) ? value.call(object) : value;
  };

  // Add your own custom functions to the Underscore object.
  _.mixin = function(obj) {
    each(_.functions(obj), function(name) {
      var func = _[name] = obj[name];
      _.prototype[name] = function() {
        var args = [this._wrapped];
        push.apply(args, arguments);
        return result.call(this, func.apply(_, args));
      };
    });
  };

  // Generate a unique integer id (unique within the entire client session).
  // Useful for temporary DOM ids.
  var idCounter = 0;
  _.uniqueId = function(prefix) {
    var id = ++idCounter + '';
    return prefix ? prefix + id : id;
  };

  // By default, Underscore uses ERB-style template delimiters, change the
  // following template settings to use alternative delimiters.
  _.templateSettings = {
    evaluate    : /<%([\s\S]+?)%>/g,
    interpolate : /<%=([\s\S]+?)%>/g,
    escape      : /<%-([\s\S]+?)%>/g
  };

  // When customizing `templateSettings`, if you don't want to define an
  // interpolation, evaluation or escaping regex, we need one that is
  // guaranteed not to match.
  var noMatch = /(.)^/;

  // Certain characters need to be escaped so that they can be put into a
  // string literal.
  var escapes = {
    "'":      "'",
    '\\':     '\\',
    '\r':     'r',
    '\n':     'n',
    '\t':     't',
    '\u2028': 'u2028',
    '\u2029': 'u2029'
  };

  var escaper = /\\|'|\r|\n|\t|\u2028|\u2029/g;

  // JavaScript micro-templating, similar to John Resig's implementation.
  // Underscore templating handles arbitrary delimiters, preserves whitespace,
  // and correctly escapes quotes within interpolated code.
  _.template = function(text, data, settings) {
    var render;
    settings = _.defaults({}, settings, _.templateSettings);

    // Combine delimiters into one regular expression via alternation.
    var matcher = new RegExp([
      (settings.escape || noMatch).source,
      (settings.interpolate || noMatch).source,
      (settings.evaluate || noMatch).source
    ].join('|') + '|$', 'g');

    // Compile the template source, escaping string literals appropriately.
    var index = 0;
    var source = "__p+='";
    text.replace(matcher, function(match, escape, interpolate, evaluate, offset) {
      source += text.slice(index, offset)
        .replace(escaper, function(match) { return '\\' + escapes[match]; });

      if (escape) {
        source += "'+\n((__t=(" + escape + "))==null?'':_.escape(__t))+\n'";
      }
      if (interpolate) {
        source += "'+\n((__t=(" + interpolate + "))==null?'':__t)+\n'";
      }
      if (evaluate) {
        source += "';\n" + evaluate + "\n__p+='";
      }
      index = offset + match.length;
      return match;
    });
    source += "';\n";

    // If a variable is not specified, place data values in local scope.
    if (!settings.variable) source = 'with(obj||{}){\n' + source + '}\n';

    source = "var __t,__p='',__j=Array.prototype.join," +
      "print=function(){__p+=__j.call(arguments,'');};\n" +
      source + "return __p;\n";

    try {
      render = new Function(settings.variable || 'obj', '_', source);
    } catch (e) {
      e.source = source;
      throw e;
    }

    if (data) return render(data, _);
    var template = function(data) {
      return render.call(this, data, _);
    };

    // Provide the compiled function source as a convenience for precompilation.
    template.source = 'function(' + (settings.variable || 'obj') + '){\n' + source + '}';

    return template;
  };

  // Add a "chain" function, which will delegate to the wrapper.
  _.chain = function(obj) {
    return _(obj).chain();
  };

  // OOP
  // ---------------
  // If Underscore is called as a function, it returns a wrapped object that
  // can be used OO-style. This wrapper holds altered versions of all the
  // underscore functions. Wrapped objects may be chained.

  // Helper function to continue chaining intermediate results.
  var result = function(obj) {
    return this._chain ? _(obj).chain() : obj;
  };

  // Add all of the Underscore functions to the wrapper object.
  _.mixin(_);

  // Add all mutator Array functions to the wrapper.
  each(['pop', 'push', 'reverse', 'shift', 'sort', 'splice', 'unshift'], function(name) {
    var method = ArrayProto[name];
    _.prototype[name] = function() {
      var obj = this._wrapped;
      method.apply(obj, arguments);
      if ((name == 'shift' || name == 'splice') && obj.length === 0) delete obj[0];
      return result.call(this, obj);
    };
  });

  // Add all accessor Array functions to the wrapper.
  each(['concat', 'join', 'slice'], function(name) {
    var method = ArrayProto[name];
    _.prototype[name] = function() {
      return result.call(this, method.apply(this._wrapped, arguments));
    };
  });

  _.extend(_.prototype, {

    // Start chaining a wrapped Underscore object.
    chain: function() {
      this._chain = true;
      return this;
    },

    // Extracts the result from a wrapped and chained object.
    value: function() {
      return this._wrapped;
    }

  });

}).call(this);

},{}],16:[function(require,module,exports){

(function() {

  // Baseline setup
  // --------------

  // Establish the root object, `window` in the browser, or `global` on the server.
  var root = this;

  // Save the previous value of the `humanize` variable.
  var previousHumanize = root.humanize;

  var humanize = {};

  if (typeof exports !== 'undefined') {
    if (typeof module !== 'undefined' && module.exports) {
      exports = module.exports = humanize;
    }
    exports.humanize = humanize;
  } else {
    if (typeof define === 'function' && define.amd) {
      define('humanize', function() {
        return humanize;
      });
    }
    root.humanize = humanize;
  }

  humanize.noConflict = function() {
    root.humanize = previousHumanize;
    return this;
  };

  humanize.pad = function(str, count, padChar, type) {
    str += '';
    if (!padChar) {
      padChar = ' ';
    } else if (padChar.length > 1) {
      padChar = padChar.charAt(0);
    }
    type = (type === undefined) ? 'left' : 'right';

    if (type === 'right') {
      while (str.length < count) {
        str = str + padChar;
      }
    } else {
      // default to left
      while (str.length < count) {
        str = padChar + str;
      }
    }

    return str;
  };

  // gets current unix time
  humanize.time = function() {
    return new Date().getTime() / 1000;
  };

  /**
   * PHP-inspired date
   */

                        /*  jan  feb  mar  apr  may  jun  jul  aug  sep  oct  nov  dec */
  var dayTableCommon = [ 0,   0,  31,  59,  90, 120, 151, 181, 212, 243, 273, 304, 334 ];
  var dayTableLeap   = [ 0,   0,  31,  60,  91, 121, 152, 182, 213, 244, 274, 305, 335 ];
  // var mtable_common[13] = {  0,  31,  28,  31,  30,  31,  30,  31,  31,  30,  31,  30,  31 };
  // static int ml_table_leap[13]   = {  0,  31,  29,  31,  30,  31,  30,  31,  31,  30,  31,  30,  31 };


  humanize.date = function(format, timestamp) {
    var jsdate = ((timestamp === undefined) ? new Date() : // Not provided
                  (timestamp instanceof Date) ? new Date(timestamp) : // JS Date()
                  new Date(timestamp * 1000) // UNIX timestamp (auto-convert to int)
                 );

    var formatChr = /\\?([a-z])/gi;
    var formatChrCb = function (t, s) {
      return f[t] ? f[t]() : s;
    };

    var shortDayTxt = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    var monthTxt = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

    var f = {
      /* Day */
      // Day of month w/leading 0; 01..31
      d: function () { return humanize.pad(f.j(), 2, '0'); },

      // Shorthand day name; Mon..Sun
      D: function () { return f.l().slice(0, 3); },

      // Day of month; 1..31
      j: function () { return jsdate.getDate(); },

      // Full day name; Monday..Sunday
      l: function () { return shortDayTxt[f.w()]; },

      // ISO-8601 day of week; 1[Mon]..7[Sun]
      N: function () { return f.w() || 7; },

      // Ordinal suffix for day of month; st, nd, rd, th
      S: function () {
        var j = f.j();
        return j > 4 && j < 21 ? 'th' : {1: 'st', 2: 'nd', 3: 'rd'}[j % 10] || 'th';
      },

      // Day of week; 0[Sun]..6[Sat]
      w: function () { return jsdate.getDay(); },

      // Day of year; 0..365
      z: function () {
        return (f.L() ? dayTableLeap[f.n()] : dayTableCommon[f.n()]) + f.j() - 1;
      },

      /* Week */
      // ISO-8601 week number
      W: function () {
        // days between midweek of this week and jan 4
        // (f.z() - f.N() + 1 + 3.5) - 3
        var midWeekDaysFromJan4 = f.z() - f.N() + 1.5;
        // 1 + number of weeks + rounded week
        return humanize.pad(1 + Math.floor(Math.abs(midWeekDaysFromJan4) / 7) + (midWeekDaysFromJan4 % 7 > 3.5 ? 1 : 0), 2, '0');
      },

      /* Month */
      // Full month name; January..December
      F: function () { return monthTxt[jsdate.getMonth()]; },

      // Month w/leading 0; 01..12
      m: function () { return humanize.pad(f.n(), 2, '0'); },

      // Shorthand month name; Jan..Dec
      M: function () { return f.F().slice(0, 3); },

      // Month; 1..12
      n: function () { return jsdate.getMonth() + 1; },

      // Days in month; 28..31
      t: function () { return (new Date(f.Y(), f.n(), 0)).getDate(); },

      /* Year */
      // Is leap year?; 0 or 1
      L: function () { return new Date(f.Y(), 1, 29).getMonth() === 1 ? 1 : 0; },

      // ISO-8601 year
      o: function () {
        var n = f.n();
        var W = f.W();
        return f.Y() + (n === 12 && W < 9 ? -1 : n === 1 && W > 9);
      },

      // Full year; e.g. 1980..2010
      Y: function () { return jsdate.getFullYear(); },

      // Last two digits of year; 00..99
      y: function () { return (String(f.Y())).slice(-2); },

      /* Time */
      // am or pm
      a: function () { return jsdate.getHours() > 11 ? 'pm' : 'am'; },

      // AM or PM
      A: function () { return f.a().toUpperCase(); },

      // Swatch Internet time; 000..999
      B: function () {
        var unixTime = jsdate.getTime() / 1000;
        var secondsPassedToday = unixTime % 86400 + 3600; // since it's based off of UTC+1
        if (secondsPassedToday < 0) { secondsPassedToday += 86400; }
        var beats = ((secondsPassedToday) / 86.4) % 1000;
        if (unixTime < 0) {
          return Math.ceil(beats);
        }
        return Math.floor(beats);
      },

      // 12-Hours; 1..12
      g: function () { return f.G() % 12 || 12; },

      // 24-Hours; 0..23
      G: function () { return jsdate.getHours(); },

      // 12-Hours w/leading 0; 01..12
      h: function () { return humanize.pad(f.g(), 2, '0'); },

      // 24-Hours w/leading 0; 00..23
      H: function () { return humanize.pad(f.G(), 2, '0'); },

      // Minutes w/leading 0; 00..59
      i: function () { return humanize.pad(jsdate.getMinutes(), 2, '0'); },

      // Seconds w/leading 0; 00..59
      s: function () { return humanize.pad(jsdate.getSeconds(), 2, '0'); },

      // Microseconds; 000000-999000
      u: function () { return humanize.pad(jsdate.getMilliseconds() * 1000, 6, '0'); },

      // Whether or not the date is in daylight savings time
      /*
      I: function () {
        // Compares Jan 1 minus Jan 1 UTC to Jul 1 minus Jul 1 UTC.
        // If they are not equal, then DST is observed.
        var Y = f.Y();
        return 0 + ((new Date(Y, 0) - Date.UTC(Y, 0)) !== (new Date(Y, 6) - Date.UTC(Y, 6)));
      },
      */

      // Difference to GMT in hour format; e.g. +0200
      O: function () {
        var tzo = jsdate.getTimezoneOffset();
        var tzoNum = Math.abs(tzo);
        return (tzo > 0 ? '-' : '+') + humanize.pad(Math.floor(tzoNum / 60) * 100 + tzoNum % 60, 4, '0');
      },

      // Difference to GMT w/colon; e.g. +02:00
      P: function () {
        var O = f.O();
        return (O.substr(0, 3) + ':' + O.substr(3, 2));
      },

      // Timezone offset in seconds (-43200..50400)
      Z: function () { return -jsdate.getTimezoneOffset() * 60; },

      // Full Date/Time, ISO-8601 date
      c: function () { return 'Y-m-d\\TH:i:sP'.replace(formatChr, formatChrCb); },

      // RFC 2822
      r: function () { return 'D, d M Y H:i:s O'.replace(formatChr, formatChrCb); },

      // Seconds since UNIX epoch
      U: function () { return jsdate.getTime() / 1000 || 0; }
    };    

    return format.replace(formatChr, formatChrCb);
  };


  /**
   * format number by adding thousands separaters and significant digits while rounding
   */
  humanize.numberFormat = function(number, decimals, decPoint, thousandsSep) {
    decimals = isNaN(decimals) ? 2 : Math.abs(decimals);
    decPoint = (decPoint === undefined) ? '.' : decPoint;
    thousandsSep = (thousandsSep === undefined) ? ',' : thousandsSep;

    var sign = number < 0 ? '-' : '';
    number = Math.abs(+number || 0);

    var intPart = parseInt(number.toFixed(decimals), 10) + '';
    var j = intPart.length > 3 ? intPart.length % 3 : 0;

    return sign + (j ? intPart.substr(0, j) + thousandsSep : '') + intPart.substr(j).replace(/(\d{3})(?=\d)/g, '$1' + thousandsSep) + (decimals ? decPoint + Math.abs(number - intPart).toFixed(decimals).slice(2) : '');
  };


  /**
   * For dates that are the current day or within one day, return 'today', 'tomorrow' or 'yesterday', as appropriate.
   * Otherwise, format the date using the passed in format string.
   *
   * Examples (when 'today' is 17 Feb 2007):
   * 16 Feb 2007 becomes yesterday.
   * 17 Feb 2007 becomes today.
   * 18 Feb 2007 becomes tomorrow.
   * Any other day is formatted according to given argument or the DATE_FORMAT setting if no argument is given.
   */
  humanize.naturalDay = function(timestamp, format) {
    timestamp = (timestamp === undefined) ? humanize.time() : timestamp;
    format = (format === undefined) ? 'Y-m-d' : format;

    var oneDay = 86400;
    var d = new Date();
    var today = (new Date(d.getFullYear(), d.getMonth(), d.getDate())).getTime() / 1000;

    if (timestamp < today && timestamp >= today - oneDay) {
      return 'yesterday';
    } else if (timestamp >= today && timestamp < today + oneDay) {
      return 'today';
    } else if (timestamp >= today + oneDay && timestamp < today + 2 * oneDay) {
      return 'tomorrow';
    }

    return humanize.date(format, timestamp);
  };

  /**
   * returns a string representing how many seconds, minutes or hours ago it was or will be in the future
   * Will always return a relative time, most granular of seconds to least granular of years. See unit tests for more details
   */
  humanize.relativeTime = function(timestamp) {
    timestamp = (timestamp === undefined) ? humanize.time() : timestamp;

    var currTime = humanize.time();
    var timeDiff = currTime - timestamp;

    // within 2 seconds
    if (timeDiff < 2 && timeDiff > -2) {
      return (timeDiff >= 0 ? 'just ' : '') + 'now';
    }

    // within a minute
    if (timeDiff < 60 && timeDiff > -60) {
      return (timeDiff >= 0 ? Math.floor(timeDiff) + ' seconds ago' : 'in ' + Math.floor(-timeDiff) + ' seconds');
    }

    // within 2 minutes
    if (timeDiff < 120 && timeDiff > -120) {
      return (timeDiff >= 0 ? 'about a minute ago' : 'in about a minute');
    }

    // within an hour
    if (timeDiff < 3600 && timeDiff > -3600) {
      return (timeDiff >= 0 ? Math.floor(timeDiff / 60) + ' minutes ago' : 'in ' + Math.floor(-timeDiff / 60) + ' minutes');
    }

    // within 2 hours
    if (timeDiff < 7200 && timeDiff > -7200) {
      return (timeDiff >= 0 ? 'about an hour ago' : 'in about an hour');
    }

    // within 24 hours
    if (timeDiff < 86400 && timeDiff > -86400) {
      return (timeDiff >= 0 ? Math.floor(timeDiff / 3600) + ' hours ago' : 'in ' + Math.floor(-timeDiff / 3600) + ' hours');
    }

    // within 2 days
    var days2 = 2 * 86400;
    if (timeDiff < days2 && timeDiff > -days2) {
      return (timeDiff >= 0 ? '1 day ago' : 'in 1 day');
    }

    // within 29 days
    var days29 = 29 * 86400;
    if (timeDiff < days29 && timeDiff > -days29) {
      return (timeDiff >= 0 ? Math.floor(timeDiff / 86400) + ' days ago' : 'in ' + Math.floor(-timeDiff / 86400) + ' days');
    }

    // within 60 days
    var days60 = 60 * 86400;
    if (timeDiff < days60 && timeDiff > -days60) {
      return (timeDiff >= 0 ? 'about a month ago' : 'in about a month');
    }

    var currTimeYears = parseInt(humanize.date('Y', currTime), 10);
    var timestampYears = parseInt(humanize.date('Y', timestamp), 10);
    var currTimeMonths = currTimeYears * 12 + parseInt(humanize.date('n', currTime), 10);
    var timestampMonths = timestampYears * 12 + parseInt(humanize.date('n', timestamp), 10);

    // within a year
    var monthDiff = currTimeMonths - timestampMonths;
    if (monthDiff < 12 && monthDiff > -12) {
      return (monthDiff >= 0 ? monthDiff + ' months ago' : 'in ' + (-monthDiff) + ' months');
    }

    var yearDiff = currTimeYears - timestampYears;
    if (yearDiff < 2 && yearDiff > -2) {
      return (yearDiff >= 0 ? 'a year ago' : 'in a year');
    }

    return (yearDiff >= 0 ? yearDiff + ' years ago' : 'in ' + (-yearDiff) + ' years');
  };

  /**
   * Converts an integer to its ordinal as a string.
   *
   * 1 becomes 1st
   * 2 becomes 2nd
   * 3 becomes 3rd etc
   */
  humanize.ordinal = function(number) {
    number = parseInt(number, 10);
    number = isNaN(number) ? 0 : number;
    var sign = number < 0 ? '-' : '';
    number = Math.abs(number);
    var tens = number % 100;

    return sign + number + (tens > 4 && tens < 21 ? 'th' : {1: 'st', 2: 'nd', 3: 'rd'}[number % 10] || 'th');
  };

  /**
   * Formats the value like a 'human-readable' file size (i.e. '13 KB', '4.1 MB', '102 bytes', etc).
   *
   * For example:
   * If value is 123456789, the output would be 117.7 MB.
   */
  humanize.filesize = function(filesize, kilo, decimals, decPoint, thousandsSep, suffixSep) {
    kilo = (kilo === undefined) ? 1024 : kilo;
    if (filesize <= 0) { return '0 bytes'; }
    if (filesize < kilo && decimals === undefined) { decimals = 0; }
    if (suffixSep === undefined) { suffixSep = ' '; }
    return humanize.intword(filesize, ['bytes', 'KB', 'MB', 'GB', 'TB', 'PB'], kilo, decimals, decPoint, thousandsSep, suffixSep);
  };

  /**
   * Formats the value like a 'human-readable' number (i.e. '13 K', '4.1 M', '102', etc).
   *
   * For example:
   * If value is 123456789, the output would be 117.7 M.
   */
  humanize.intword = function(number, units, kilo, decimals, decPoint, thousandsSep, suffixSep) {
    var humanized, unit;

    units = units || ['', 'K', 'M', 'B', 'T'],
    unit = units.length - 1,
    kilo = kilo || 1000,
    decimals = isNaN(decimals) ? 2 : Math.abs(decimals),
    decPoint = decPoint || '.',
    thousandsSep = thousandsSep || ',',
    suffixSep = suffixSep || '';

    for (var i=0; i < units.length; i++) {
      if (number < Math.pow(kilo, i+1)) {
        unit = i;
        break;
      }
    }
    humanized = number / Math.pow(kilo, unit);

    var suffix = units[unit] ? suffixSep + units[unit] : '';
    return humanize.numberFormat(humanized, decimals, decPoint, thousandsSep) + suffix;
  };

  /**
   * Replaces line breaks in plain text with appropriate HTML
   * A single newline becomes an HTML line break (<br />) and a new line followed by a blank line becomes a paragraph break (</p>).
   * 
   * For example:
   * If value is Joel\nis a\n\nslug, the output will be <p>Joel<br />is a</p><p>slug</p>
   */
  humanize.linebreaks = function(str) {
    // remove beginning and ending newlines
    str = str.replace(/^([\n|\r]*)/, '');
    str = str.replace(/([\n|\r]*)$/, '');

    // normalize all to \n
    str = str.replace(/(\r\n|\n|\r)/g, "\n");

    // any consecutive new lines more than 2 gets turned into p tags
    str = str.replace(/(\n{2,})/g, '</p><p>');

    // any that are singletons get turned into br
    str = str.replace(/\n/g, '<br />');
    return '<p>' + str + '</p>';
  };

  /**
   * Converts all newlines in a piece of plain text to HTML line breaks (<br />).
   */
  humanize.nl2br = function(str) {
    return str.replace(/(\r\n|\n|\r)/g, '<br />');
  };

  /**
   * Truncates a string if it is longer than the specified number of characters.
   * Truncated strings will end with a translatable ellipsis sequence ('…').
   */
  humanize.truncatechars = function(string, length) {
    if (string.length <= length) { return string; }
    return string.substr(0, length) + '…';
  };

  /**
   * Truncates a string after a certain number of words.
   * Newlines within the string will be removed.
   */
  humanize.truncatewords = function(string, numWords) {
    var words = string.split(' ');
    if (words.length < numWords) { return string; }
    return words.slice(0, numWords).join(' ') + '…';
  };

}).call(this);

},{}],17:[function(require,module,exports){
(function (process){
/**
 * @author  John Resig <jeresig@gmail.com>
 * @author  Originally by Marcus Spiegel <marcus.spiegel@gmail.com>
 * @link    https://github.com/jeresig/i18n-node
 * @license http://opensource.org/licenses/MIT
 *
 * @version 0.4.7
 */

// dependencies
var vsprintf = require("sprintf").vsprintf,
		fs = require("fs"),
		path = require("path");


function dotNotation (obj, is, value) {
	if (obj.hasOwnProperty(is)) {
		return obj[is];
	}

	if (typeof is === 'string') {
		return dotNotation(obj, is.split('.'), value);
	} else if (is.length === 1 && value !== undefined) {
		return obj[is[0]] = value;
	} else if (is.length === 0) {
		return obj;
	} else {
		if (obj.hasOwnProperty(is[0])) {
			return dotNotation(obj[is[0]], is.slice(1), value);
		} else {
			return obj[is.join('.')] = is.join('.');
		}
	}
}

var i18n = module.exports = function (opt) {
	var self = this;

	// Put into dev or production mode
	this.devMode = process.env.NODE_ENV !== "production";

	// Copy over options
	for (var prop in opt) {
		this[prop] = opt[prop];
	}

	// you may register helpers in global scope, up to you
	if (typeof this.register === "object") {
		i18n.resMethods.forEach(function (method) {
			self.register[method] = self[method].bind(self);
		});
	}

	// implicitly read all locales
	// if it's an array of locale names, read in the data
	if (opt.locales && opt.locales.forEach) {
		this.locales = {};

		opt.locales.forEach(function (locale) {
			self.readFile(locale);
		});

		this.defaultLocale = opt.locales[0];
	}

	// Set the locale to the default locale
	this.setLocale(this.defaultLocale);

	// Check the defaultLocale
	if (!this.locales[this.defaultLocale]) {
		console.error("Not a valid default locale.");
	}

	if (this.request) {
		if (this.subdomain) {
			this.setLocaleFromSubdomain(this.request);
		}

		if (this.query !== false) {
			this.setLocaleFromQuery(this.request);
		}

		if (this.session !== false) {
			this.setLocaleFromSessionVar(this.request);
		}

		this.prefLocale = this.preferredLocale();

		if (this.prefLocale !== false && this.prefLocale !== this.locale) {
			this.setLocale(this.prefLocale);
		}
	}
};

i18n.version = "0.4.7";

i18n.localeCache = {};
i18n.resMethods = ["__", "__n", "getLocale", "isPreferredLocale"];

i18n.expressBind = function (app, opt) {
	if (!app) {
		return;
	}

	app.use(function (req, res, next) {
		opt.request = req;
		req.i18n = new i18n(opt);

		// Express 3
		if (res.locals) {
			i18n.registerMethods(res.locals, req)
		}

		next();
	});

	// Express 2
	if (app.dynamicHelpers) {
		app.dynamicHelpers(i18n.registerMethods({}));
	}
};

i18n.registerMethods = function (helpers, req) {
	i18n.resMethods.forEach(function (method) {
		if (req) {
			helpers[method] = req.i18n[method].bind(req.i18n);
		} else {
			helpers[method] = function (req) {
				return req.i18n[method].bind(req.i18n);
			};
		}

	});

	return helpers;
};

i18n.prototype = {
	defaultLocale: "en",
	extension: ".js",
	directory: "./locales",
	cookieName: "lang",
	sessionVarName: "locale",
	indent: "\t",

	parse: JSON.parse,

	dump: function (data, indent) {
	  return JSON.stringify(data, null, indent);
	},

	__: function () {
		var msg = this.translate(this.locale, arguments[0]);

		if (arguments.length > 1) {
			msg = vsprintf(msg, Array.prototype.slice.call(arguments, 1));
		}

		return msg;
	},

	__n: function (pathOrSingular, countOrPlural, additionalOrCount) {
		var msg;
		if (typeof countOrPlural === 'number') {
			var path = pathOrSingular;
			var count = countOrPlural;
			msg = this.translate(this.locale, path);

			msg = vsprintf(parseInt(count, 10) > 1 ? msg.other : msg.one, Array.prototype.slice.call(arguments, 1));
		} else {
			var singular = pathOrSingular;
			var plural = countOrPlural;
			var count = additionalOrCount;
			msg = this.translate(this.locale, singular, plural);

			msg = vsprintf(parseInt(count, 10) > 1 ? msg.other : msg.one, [count]);

			if (arguments.length > 3) {
				msg = vsprintf(msg, Array.prototype.slice.call(arguments, 3));
			}
		}

		return msg;
	},

	setLocale: function (locale) {

		if (!locale) return;

		if (!this.locales[locale]) {
			if (this.devMode) {
				console.warn("Locale (" + locale + ") not found.");
			}

			locale = this.defaultLocale;
		}

		return (this.locale = locale);
	},

	getLocale: function () {
		return this.locale;
	},

	isPreferredLocale: function () {
		return !this.prefLocale ||
				this.prefLocale === this.getLocale();
	},

	setLocaleFromSessionVar: function (req) {
		req = req || this.request;

		if (!req || !req.session || !req.session[this.sessionVarName]) {		
			return;
		}

		var locale = req.session[this.sessionVarName];

		if (this.locales[locale]) {
			if (this.devMode) {
				console.log("Overriding locale from query: " + locale);
			}
			this.setLocale(locale);
		}

	},

	setLocaleFromQuery: function (req) {
		req = req || this.request;

		if (!req || !req.query || !req.query.lang) {
			return;
		}

		var locale = (req.query.lang+'').toLowerCase();

		if (this.locales[locale]) {
			if (this.devMode) {
				console.log("Overriding locale from query: " + locale);
			}

			this.setLocale(locale);
		}
	},

	setLocaleFromSubdomain: function (req) {
		req = req || this.request;

		if (!req || !req.headers || !req.headers.host) {
			return;
		}

		if (/^([^.]+)/.test(req.headers.host) && this.locales[RegExp.$1]) {
			if (this.devMode) {
				console.log("Overriding locale from host: " + RegExp.$1);
			}

			this.setLocale(RegExp.$1);
		}
	},

	setLocaleFromCookie: function (req) {
		req = req || this.request;

		if (!req || !req.cookies || !this.cookieName || !req.cookies[this.cookieName]) {
			return;
		}

		var locale = req.cookies[this.cookieName].toLowerCase();

		if (this.locales[locale]) {
			if (this.devMode) {
				console.log("Overriding locale from cookie: " + locale);
			}

			this.setLocale(locale);
		}
	},

	setLocaleFromEnvironmentVariable: function () {
		if (!process.env.LANG) {
			return;
		}
		var locale = process.env.LANG.split("_")[0];
		if (this.locales[locale]) {
			if (this.devMode) {
				console.log("Overriding locale from environment variable: " + locale);
			}

			this.setLocale(locale);
		}
	},

	preferredLocale: function (req) {
		req = req || this.request;

		if (!req || !req.headers) {
			return;
		}

		var accept = req.headers["accept-language"] || "",
				regExp = /(^|,\s*)([a-z0-9-]+)/gi,
				self = this,
				prefLocale;

		while (!prefLocale && (match = regExp.exec(accept))) {
			var locale = match[2].toLowerCase();
			var parts = locale.split("-");

			if (self.locales[locale]) {
				prefLocale = locale;
			} else if (parts.length > 1 && self.locales[parts[0]]) {
				prefLocale = parts[0];
			}
		}

		return prefLocale || this.defaultLocale;
	},

	// read locale file, translate a msg and write to fs if new
	translate: function (locale, singular, plural) {
		if (!locale || !this.locales[locale]) {
			if (this.devMode) {
				console.warn("WARN: No locale found. Using the default (" +
						this.defaultLocale + ") as current locale");
			}

			locale = this.defaultLocale;

			this.initLocale(locale, {});
		}

		if (!this.locales[locale][singular]) {
			if (this.devMode) {
				dotNotation(this.locales[locale], singular, plural ? { one: singular, other: plural } : undefined);
				this.writeFile(locale);
			}
		}

		return dotNotation(this.locales[locale], singular, plural ? { one: singular, other: plural } : undefined);
	},

	// try reading a file
	readFile: function (locale) {
		var file = this.locateFile(locale);

		if (!this.devMode && i18n.localeCache[file]) {
			this.initLocale(locale, i18n.localeCache[file]);
			return;
		}

		try {
			var localeFile = fs.readFileSync(file);
			var base;

			// reading base file if 'base' provided
			if (typeof this.base === "function") {
				var baseFilename;

				try {
					baseFilename = this.base(locale);
				} catch (e) {
					console.error('base function threw exception for locale %s', locale, e);
				}

				if (typeof baseFilename === "string") {
					try {
						base = this.parse(fs.readFileSync(this.locateFile(baseFilename)));
					} catch (e) {
						console.error('unable to read or parse base file %s for locale %s', baseFilename, locale, e);
					}
				}
			}

			try {
				// parsing file content
				var content = this.parse(localeFile);

				if (base) {
					// writing content to the base and swapping
					for (var prop in content) {
						base[prop] = content[prop];
					}
					content = base;
				}

				// putting content to locales[locale]
				this.initLocale(locale, content);
			} catch (e) {
				console.error('unable to parse locales from file (maybe ' + file +
						' is empty or invalid ' + this.extension + '?): ', e);
			}

		} catch (e) {
			// unable to read, so intialize that file
			// locales[locale] are already set in memory, so no extra read required
			// or locales[locale] are empty, which initializes an empty locale.json file
			if (!fs.existsSync(file)) {
				this.writeFile(locale);
			}
		}
	},

	// try writing a file in a created directory
	writeFile: function (locale) {
		// don't write new locale information to disk if we're not in dev mode
		if (!this.devMode) {
			// Initialize the locale if didn't exist already
			this.initLocale(locale, {});
			return;
		}

		// creating directory if necessary
		try {
			fs.lstatSync(this.directory);

		} catch (e) {
			if (this.devMode) {
				console.log('creating locales dir in: ' + this.directory);
			}

			fs.mkdirSync(this.directory, 0755);
		}

		// Initialize the locale if didn't exist already
		this.initLocale(locale, {});

		// writing to tmp and rename on success
		try {
			var target = this.locateFile(locale),
					tmp = target + ".tmp";

			fs.writeFileSync(tmp,
							 this.dump(this.locales[locale], this.indent),
							 "utf8");

			if (fs.statSync(tmp).isFile()) {
				fs.renameSync(tmp, target);

			} else {
				console.error('unable to write locales to file (either ' + tmp +
						' or ' + target + ' are not writeable?): ');
			}

		} catch (e) {
			console.error('unexpected error writing files (either ' + tmp +
					' or ' + target + ' are not writeable?): ', e);
		}
	},

	// basic normalization of filepath
	locateFile: function (locale) {
		return path.normalize(this.directory + '/' + locale + this.extension);
	},

	initLocale: function (locale, data) {
		if (!this.locales[locale]) {
			this.locales[locale] = data;

			// Only cache the files when we're not in dev mode
			if (!this.devMode) {
				var file = this.locateFile(locale);
				if (!i18n.localeCache[file]) {
					i18n.localeCache[file] = data;
				}
			}
		}
	}
};

}).call(this,require('_process'))
},{"_process":20,"fs":1,"path":19,"sprintf":21}],18:[function(require,module,exports){
module.exports = require('./i18n');

},{"./i18n":17}],19:[function(require,module,exports){
(function (process){
// Copyright Joyent, Inc. and other Node contributors.
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to permit
// persons to whom the Software is furnished to do so, subject to the
// following conditions:
//
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
// NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
// USE OR OTHER DEALINGS IN THE SOFTWARE.

// resolves . and .. elements in a path array with directory names there
// must be no slashes, empty elements, or device names (c:\) in the array
// (so also no leading and trailing slashes - it does not distinguish
// relative and absolute paths)
function normalizeArray(parts, allowAboveRoot) {
  // if the path tries to go above the root, `up` ends up > 0
  var up = 0;
  for (var i = parts.length - 1; i >= 0; i--) {
    var last = parts[i];
    if (last === '.') {
      parts.splice(i, 1);
    } else if (last === '..') {
      parts.splice(i, 1);
      up++;
    } else if (up) {
      parts.splice(i, 1);
      up--;
    }
  }

  // if the path is allowed to go above the root, restore leading ..s
  if (allowAboveRoot) {
    for (; up--; up) {
      parts.unshift('..');
    }
  }

  return parts;
}

// Split a filename into [root, dir, basename, ext], unix version
// 'root' is just a slash, or nothing.
var splitPathRe =
    /^(\/?|)([\s\S]*?)((?:\.{1,2}|[^\/]+?|)(\.[^.\/]*|))(?:[\/]*)$/;
var splitPath = function(filename) {
  return splitPathRe.exec(filename).slice(1);
};

// path.resolve([from ...], to)
// posix version
exports.resolve = function() {
  var resolvedPath = '',
      resolvedAbsolute = false;

  for (var i = arguments.length - 1; i >= -1 && !resolvedAbsolute; i--) {
    var path = (i >= 0) ? arguments[i] : process.cwd();

    // Skip empty and invalid entries
    if (typeof path !== 'string') {
      throw new TypeError('Arguments to path.resolve must be strings');
    } else if (!path) {
      continue;
    }

    resolvedPath = path + '/' + resolvedPath;
    resolvedAbsolute = path.charAt(0) === '/';
  }

  // At this point the path should be resolved to a full absolute path, but
  // handle relative paths to be safe (might happen when process.cwd() fails)

  // Normalize the path
  resolvedPath = normalizeArray(filter(resolvedPath.split('/'), function(p) {
    return !!p;
  }), !resolvedAbsolute).join('/');

  return ((resolvedAbsolute ? '/' : '') + resolvedPath) || '.';
};

// path.normalize(path)
// posix version
exports.normalize = function(path) {
  var isAbsolute = exports.isAbsolute(path),
      trailingSlash = substr(path, -1) === '/';

  // Normalize the path
  path = normalizeArray(filter(path.split('/'), function(p) {
    return !!p;
  }), !isAbsolute).join('/');

  if (!path && !isAbsolute) {
    path = '.';
  }
  if (path && trailingSlash) {
    path += '/';
  }

  return (isAbsolute ? '/' : '') + path;
};

// posix version
exports.isAbsolute = function(path) {
  return path.charAt(0) === '/';
};

// posix version
exports.join = function() {
  var paths = Array.prototype.slice.call(arguments, 0);
  return exports.normalize(filter(paths, function(p, index) {
    if (typeof p !== 'string') {
      throw new TypeError('Arguments to path.join must be strings');
    }
    return p;
  }).join('/'));
};


// path.relative(from, to)
// posix version
exports.relative = function(from, to) {
  from = exports.resolve(from).substr(1);
  to = exports.resolve(to).substr(1);

  function trim(arr) {
    var start = 0;
    for (; start < arr.length; start++) {
      if (arr[start] !== '') break;
    }

    var end = arr.length - 1;
    for (; end >= 0; end--) {
      if (arr[end] !== '') break;
    }

    if (start > end) return [];
    return arr.slice(start, end - start + 1);
  }

  var fromParts = trim(from.split('/'));
  var toParts = trim(to.split('/'));

  var length = Math.min(fromParts.length, toParts.length);
  var samePartsLength = length;
  for (var i = 0; i < length; i++) {
    if (fromParts[i] !== toParts[i]) {
      samePartsLength = i;
      break;
    }
  }

  var outputParts = [];
  for (var i = samePartsLength; i < fromParts.length; i++) {
    outputParts.push('..');
  }

  outputParts = outputParts.concat(toParts.slice(samePartsLength));

  return outputParts.join('/');
};

exports.sep = '/';
exports.delimiter = ':';

exports.dirname = function(path) {
  var result = splitPath(path),
      root = result[0],
      dir = result[1];

  if (!root && !dir) {
    // No dirname whatsoever
    return '.';
  }

  if (dir) {
    // It has a dirname, strip trailing slash
    dir = dir.substr(0, dir.length - 1);
  }

  return root + dir;
};


exports.basename = function(path, ext) {
  var f = splitPath(path)[2];
  // TODO: make this comparison case-insensitive on windows?
  if (ext && f.substr(-1 * ext.length) === ext) {
    f = f.substr(0, f.length - ext.length);
  }
  return f;
};


exports.extname = function(path) {
  return splitPath(path)[3];
};

function filter (xs, f) {
    if (xs.filter) return xs.filter(f);
    var res = [];
    for (var i = 0; i < xs.length; i++) {
        if (f(xs[i], i, xs)) res.push(xs[i]);
    }
    return res;
}

// String.prototype.substr - negative index don't work in IE8
var substr = 'ab'.substr(-1) === 'b'
    ? function (str, start, len) { return str.substr(start, len) }
    : function (str, start, len) {
        if (start < 0) start = str.length + start;
        return str.substr(start, len);
    }
;

}).call(this,require('_process'))
},{"_process":20}],20:[function(require,module,exports){
// shim for using process in browser
var process = module.exports = {};

// cached from whatever global is present so that test runners that stub it
// don't break things.  But we need to wrap it in a try catch in case it is
// wrapped in strict mode code which doesn't define any globals.  It's inside a
// function because try/catches deoptimize in certain engines.

var cachedSetTimeout;
var cachedClearTimeout;

function defaultSetTimout() {
    throw new Error('setTimeout has not been defined');
}
function defaultClearTimeout () {
    throw new Error('clearTimeout has not been defined');
}
(function () {
    try {
        if (typeof setTimeout === 'function') {
            cachedSetTimeout = setTimeout;
        } else {
            cachedSetTimeout = defaultSetTimout;
        }
    } catch (e) {
        cachedSetTimeout = defaultSetTimout;
    }
    try {
        if (typeof clearTimeout === 'function') {
            cachedClearTimeout = clearTimeout;
        } else {
            cachedClearTimeout = defaultClearTimeout;
        }
    } catch (e) {
        cachedClearTimeout = defaultClearTimeout;
    }
} ())
function runTimeout(fun) {
    if (cachedSetTimeout === setTimeout) {
        //normal enviroments in sane situations
        return setTimeout(fun, 0);
    }
    // if setTimeout wasn't available but was latter defined
    if ((cachedSetTimeout === defaultSetTimout || !cachedSetTimeout) && setTimeout) {
        cachedSetTimeout = setTimeout;
        return setTimeout(fun, 0);
    }
    try {
        // when when somebody has screwed with setTimeout but no I.E. maddness
        return cachedSetTimeout(fun, 0);
    } catch(e){
        try {
            // When we are in I.E. but the script has been evaled so I.E. doesn't trust the global object when called normally
            return cachedSetTimeout.call(null, fun, 0);
        } catch(e){
            // same as above but when it's a version of I.E. that must have the global object for 'this', hopfully our context correct otherwise it will throw a global error
            return cachedSetTimeout.call(this, fun, 0);
        }
    }


}
function runClearTimeout(marker) {
    if (cachedClearTimeout === clearTimeout) {
        //normal enviroments in sane situations
        return clearTimeout(marker);
    }
    // if clearTimeout wasn't available but was latter defined
    if ((cachedClearTimeout === defaultClearTimeout || !cachedClearTimeout) && clearTimeout) {
        cachedClearTimeout = clearTimeout;
        return clearTimeout(marker);
    }
    try {
        // when when somebody has screwed with setTimeout but no I.E. maddness
        return cachedClearTimeout(marker);
    } catch (e){
        try {
            // When we are in I.E. but the script has been evaled so I.E. doesn't  trust the global object when called normally
            return cachedClearTimeout.call(null, marker);
        } catch (e){
            // same as above but when it's a version of I.E. that must have the global object for 'this', hopfully our context correct otherwise it will throw a global error.
            // Some versions of I.E. have different rules for clearTimeout vs setTimeout
            return cachedClearTimeout.call(this, marker);
        }
    }



}
var queue = [];
var draining = false;
var currentQueue;
var queueIndex = -1;

function cleanUpNextTick() {
    if (!draining || !currentQueue) {
        return;
    }
    draining = false;
    if (currentQueue.length) {
        queue = currentQueue.concat(queue);
    } else {
        queueIndex = -1;
    }
    if (queue.length) {
        drainQueue();
    }
}

function drainQueue() {
    if (draining) {
        return;
    }
    var timeout = runTimeout(cleanUpNextTick);
    draining = true;

    var len = queue.length;
    while(len) {
        currentQueue = queue;
        queue = [];
        while (++queueIndex < len) {
            if (currentQueue) {
                currentQueue[queueIndex].run();
            }
        }
        queueIndex = -1;
        len = queue.length;
    }
    currentQueue = null;
    draining = false;
    runClearTimeout(timeout);
}

process.nextTick = function (fun) {
    var args = new Array(arguments.length - 1);
    if (arguments.length > 1) {
        for (var i = 1; i < arguments.length; i++) {
            args[i - 1] = arguments[i];
        }
    }
    queue.push(new Item(fun, args));
    if (queue.length === 1 && !draining) {
        runTimeout(drainQueue);
    }
};

// v8 likes predictible objects
function Item(fun, array) {
    this.fun = fun;
    this.array = array;
}
Item.prototype.run = function () {
    this.fun.apply(null, this.array);
};
process.title = 'browser';
process.browser = true;
process.env = {};
process.argv = [];
process.version = ''; // empty string to avoid regexp issues
process.versions = {};

function noop() {}

process.on = noop;
process.addListener = noop;
process.once = noop;
process.off = noop;
process.removeListener = noop;
process.removeAllListeners = noop;
process.emit = noop;

process.binding = function (name) {
    throw new Error('process.binding is not supported');
};

process.cwd = function () { return '/' };
process.chdir = function (dir) {
    throw new Error('process.chdir is not supported');
};
process.umask = function() { return 0; };

},{}],21:[function(require,module,exports){
/**
sprintf() for JavaScript 0.7-beta1
http://www.diveintojavascript.com/projects/javascript-sprintf

Copyright (c) Alexandru Marasteanu <alexaholic [at) gmail (dot] com>
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of sprintf() for JavaScript nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Alexandru Marasteanu BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


Changelog:
2010.11.07 - 0.7-beta1-node
  - converted it to a node.js compatible module

2010.09.06 - 0.7-beta1
  - features: vsprintf, support for named placeholders
  - enhancements: format cache, reduced global namespace pollution

2010.05.22 - 0.6:
 - reverted to 0.4 and fixed the bug regarding the sign of the number 0
 Note:
 Thanks to Raphael Pigulla <raph (at] n3rd [dot) org> (http://www.n3rd.org/)
 who warned me about a bug in 0.5, I discovered that the last update was
 a regress. I appologize for that.

2010.05.09 - 0.5:
 - bug fix: 0 is now preceeded with a + sign
 - bug fix: the sign was not at the right position on padded results (Kamal Abdali)
 - switched from GPL to BSD license

2007.10.21 - 0.4:
 - unit test and patch (David Baird)

2007.09.17 - 0.3:
 - bug fix: no longer throws exception on empty paramenters (Hans Pufal)

2007.09.11 - 0.2:
 - feature: added argument swapping

2007.04.03 - 0.1:
 - initial release
**/

var sprintf = (function() {
	function get_type(variable) {
		return Object.prototype.toString.call(variable).slice(8, -1).toLowerCase();
	}
	function str_repeat(input, multiplier) {
		for (var output = []; multiplier > 0; output[--multiplier] = input) {/* do nothing */}
		return output.join('');
	}

	var str_format = function() {
		if (!str_format.cache.hasOwnProperty(arguments[0])) {
			str_format.cache[arguments[0]] = str_format.parse(arguments[0]);
		}
		return str_format.format.call(null, str_format.cache[arguments[0]], arguments);
	};

	// convert object to simple one line string without indentation or
	// newlines. Note that this implementation does not print array
	// values to their actual place for sparse arrays. 
	//
	// For example sparse array like this
	//    l = []
	//    l[4] = 1
	// Would be printed as "[1]" instead of "[, , , , 1]"
	// 
	// If argument 'seen' is not null and array the function will check for 
	// circular object references from argument.
	str_format.object_stringify = function(obj, depth, maxdepth, seen) {
		var str = '';
		if (obj != null) {
			switch( typeof(obj) ) {
			case 'function': 
				return '[Function' + (obj.name ? ': '+obj.name : '') + ']';
			    break;
			case 'object':
				if ( obj instanceof Error) { return '[' + obj.toString() + ']' };
				if (depth >= maxdepth) return '[Object]'
				if (seen) {
					// add object to seen list
					seen = seen.slice(0)
					seen.push(obj);
				}
				if (obj.length != null) { //array
					str += '[';
					var arr = []
					for (var i in obj) {
						if (seen && seen.indexOf(obj[i]) >= 0) arr.push('[Circular]');
						else arr.push(str_format.object_stringify(obj[i], depth+1, maxdepth, seen));
					}
					str += arr.join(', ') + ']';
				} else if ('getMonth' in obj) { // date
					return 'Date(' + obj + ')';
				} else { // object
					str += '{';
					var arr = []
					for (var k in obj) { 
						if(obj.hasOwnProperty(k)) {
							if (seen && seen.indexOf(obj[k]) >= 0) arr.push(k + ': [Circular]');
							else arr.push(k +': ' +str_format.object_stringify(obj[k], depth+1, maxdepth, seen)); 
						}
					}
					str += arr.join(', ') + '}';
				}
				return str;
				break;
			case 'string':				
				return '"' + obj + '"';
				break
			}
		}
		return '' + obj;
	}

	str_format.format = function(parse_tree, argv) {
		var cursor = 1, tree_length = parse_tree.length, node_type = '', arg, output = [], i, k, match, pad, pad_character, pad_length;
		for (i = 0; i < tree_length; i++) {
			node_type = get_type(parse_tree[i]);
			if (node_type === 'string') {
				output.push(parse_tree[i]);
			}
			else if (node_type === 'array') {
				match = parse_tree[i]; // convenience purposes only
				if (match[2]) { // keyword argument
					arg = argv[cursor];
					for (k = 0; k < match[2].length; k++) {
						if (!arg.hasOwnProperty(match[2][k])) {
							throw new Error(sprintf('[sprintf] property "%s" does not exist', match[2][k]));
						}
						arg = arg[match[2][k]];
					}
				}
				else if (match[1]) { // positional argument (explicit)
					arg = argv[match[1]];
				}
				else { // positional argument (implicit)
					arg = argv[cursor++];
				}

				if (/[^sO]/.test(match[8]) && (get_type(arg) != 'number')) {
					throw new Error(sprintf('[sprintf] expecting number but found %s "' + arg + '"', get_type(arg)));
				}
				switch (match[8]) {
					case 'b': arg = arg.toString(2); break;
					case 'c': arg = String.fromCharCode(arg); break;
					case 'd': arg = parseInt(arg, 10); break;
					case 'e': arg = match[7] ? arg.toExponential(match[7]) : arg.toExponential(); break;
					case 'f': arg = match[7] ? parseFloat(arg).toFixed(match[7]) : parseFloat(arg); break;
				    case 'O': arg = str_format.object_stringify(arg, 0, parseInt(match[7]) || 5); break;
					case 'o': arg = arg.toString(8); break;
					case 's': arg = ((arg = String(arg)) && match[7] ? arg.substring(0, match[7]) : arg); break;
					case 'u': arg = Math.abs(arg); break;
					case 'x': arg = arg.toString(16); break;
					case 'X': arg = arg.toString(16).toUpperCase(); break;
				}
				arg = (/[def]/.test(match[8]) && match[3] && arg >= 0 ? '+'+ arg : arg);
				pad_character = match[4] ? match[4] == '0' ? '0' : match[4].charAt(1) : ' ';
				pad_length = match[6] - String(arg).length;
				pad = match[6] ? str_repeat(pad_character, pad_length) : '';
				output.push(match[5] ? arg + pad : pad + arg);
			}
		}
		return output.join('');
	};

	str_format.cache = {};

	str_format.parse = function(fmt) {
		var _fmt = fmt, match = [], parse_tree = [], arg_names = 0;
		while (_fmt) {
			if ((match = /^[^\x25]+/.exec(_fmt)) !== null) {
				parse_tree.push(match[0]);
			}
			else if ((match = /^\x25{2}/.exec(_fmt)) !== null) {
				parse_tree.push('%');
			}
			else if ((match = /^\x25(?:([1-9]\d*)\$|\(([^\)]+)\))?(\+)?(0|'[^$])?(-)?(\d+)?(?:\.(\d+))?([b-fosOuxX])/.exec(_fmt)) !== null) {
				if (match[2]) {
					arg_names |= 1;
					var field_list = [], replacement_field = match[2], field_match = [];
					if ((field_match = /^([a-z_][a-z_\d]*)/i.exec(replacement_field)) !== null) {
						field_list.push(field_match[1]);
						while ((replacement_field = replacement_field.substring(field_match[0].length)) !== '') {
							if ((field_match = /^\.([a-z_][a-z_\d]*)/i.exec(replacement_field)) !== null) {
								field_list.push(field_match[1]);
							}
							else if ((field_match = /^\[(\d+)\]/.exec(replacement_field)) !== null) {
								field_list.push(field_match[1]);
							}
							else {
								throw new Error('[sprintf] ' + replacement_field);
							}
						}
					}
					else {
                        throw new Error('[sprintf] ' + replacement_field);
					}
					match[2] = field_list;
				}
				else {
					arg_names |= 2;
				}
				if (arg_names === 3) {
					throw new Error('[sprintf] mixing positional and named placeholders is not (yet) supported');
				}
				parse_tree.push(match);
			}
			else {
				throw new Error('[sprintf] ' + _fmt);
			}
			_fmt = _fmt.substring(match[0].length);
		}
		return parse_tree;
	};

	return str_format;
})();

var vsprintf = function(fmt, argv) {
	var argvClone = argv.slice();
	argvClone.unshift(fmt);
	return sprintf.apply(null, argvClone);
};

module.exports = sprintf;
sprintf.sprintf = sprintf;
sprintf.vsprintf = vsprintf;

},{}],22:[function(require,module,exports){
//     Underscore.js 1.8.3
//     http://underscorejs.org
//     (c) 2009-2015 Jeremy Ashkenas, DocumentCloud and Investigative Reporters & Editors
//     Underscore may be freely distributed under the MIT license.

(function() {

  // Baseline setup
  // --------------

  // Establish the root object, `window` in the browser, or `exports` on the server.
  var root = this;

  // Save the previous value of the `_` variable.
  var previousUnderscore = root._;

  // Save bytes in the minified (but not gzipped) version:
  var ArrayProto = Array.prototype, ObjProto = Object.prototype, FuncProto = Function.prototype;

  // Create quick reference variables for speed access to core prototypes.
  var
    push             = ArrayProto.push,
    slice            = ArrayProto.slice,
    toString         = ObjProto.toString,
    hasOwnProperty   = ObjProto.hasOwnProperty;

  // All **ECMAScript 5** native function implementations that we hope to use
  // are declared here.
  var
    nativeIsArray      = Array.isArray,
    nativeKeys         = Object.keys,
    nativeBind         = FuncProto.bind,
    nativeCreate       = Object.create;

  // Naked function reference for surrogate-prototype-swapping.
  var Ctor = function(){};

  // Create a safe reference to the Underscore object for use below.
  var _ = function(obj) {
    if (obj instanceof _) return obj;
    if (!(this instanceof _)) return new _(obj);
    this._wrapped = obj;
  };

  // Export the Underscore object for **Node.js**, with
  // backwards-compatibility for the old `require()` API. If we're in
  // the browser, add `_` as a global object.
  if (typeof exports !== 'undefined') {
    if (typeof module !== 'undefined' && module.exports) {
      exports = module.exports = _;
    }
    exports._ = _;
  } else {
    root._ = _;
  }

  // Current version.
  _.VERSION = '1.8.3';

  // Internal function that returns an efficient (for current engines) version
  // of the passed-in callback, to be repeatedly applied in other Underscore
  // functions.
  var optimizeCb = function(func, context, argCount) {
    if (context === void 0) return func;
    switch (argCount == null ? 3 : argCount) {
      case 1: return function(value) {
        return func.call(context, value);
      };
      case 2: return function(value, other) {
        return func.call(context, value, other);
      };
      case 3: return function(value, index, collection) {
        return func.call(context, value, index, collection);
      };
      case 4: return function(accumulator, value, index, collection) {
        return func.call(context, accumulator, value, index, collection);
      };
    }
    return function() {
      return func.apply(context, arguments);
    };
  };

  // A mostly-internal function to generate callbacks that can be applied
  // to each element in a collection, returning the desired result — either
  // identity, an arbitrary callback, a property matcher, or a property accessor.
  var cb = function(value, context, argCount) {
    if (value == null) return _.identity;
    if (_.isFunction(value)) return optimizeCb(value, context, argCount);
    if (_.isObject(value)) return _.matcher(value);
    return _.property(value);
  };
  _.iteratee = function(value, context) {
    return cb(value, context, Infinity);
  };

  // An internal function for creating assigner functions.
  var createAssigner = function(keysFunc, undefinedOnly) {
    return function(obj) {
      var length = arguments.length;
      if (length < 2 || obj == null) return obj;
      for (var index = 1; index < length; index++) {
        var source = arguments[index],
            keys = keysFunc(source),
            l = keys.length;
        for (var i = 0; i < l; i++) {
          var key = keys[i];
          if (!undefinedOnly || obj[key] === void 0) obj[key] = source[key];
        }
      }
      return obj;
    };
  };

  // An internal function for creating a new object that inherits from another.
  var baseCreate = function(prototype) {
    if (!_.isObject(prototype)) return {};
    if (nativeCreate) return nativeCreate(prototype);
    Ctor.prototype = prototype;
    var result = new Ctor;
    Ctor.prototype = null;
    return result;
  };

  var property = function(key) {
    return function(obj) {
      return obj == null ? void 0 : obj[key];
    };
  };

  // Helper for collection methods to determine whether a collection
  // should be iterated as an array or as an object
  // Related: http://people.mozilla.org/~jorendorff/es6-draft.html#sec-tolength
  // Avoids a very nasty iOS 8 JIT bug on ARM-64. #2094
  var MAX_ARRAY_INDEX = Math.pow(2, 53) - 1;
  var getLength = property('length');
  var isArrayLike = function(collection) {
    var length = getLength(collection);
    return typeof length == 'number' && length >= 0 && length <= MAX_ARRAY_INDEX;
  };

  // Collection Functions
  // --------------------

  // The cornerstone, an `each` implementation, aka `forEach`.
  // Handles raw objects in addition to array-likes. Treats all
  // sparse array-likes as if they were dense.
  _.each = _.forEach = function(obj, iteratee, context) {
    iteratee = optimizeCb(iteratee, context);
    var i, length;
    if (isArrayLike(obj)) {
      for (i = 0, length = obj.length; i < length; i++) {
        iteratee(obj[i], i, obj);
      }
    } else {
      var keys = _.keys(obj);
      for (i = 0, length = keys.length; i < length; i++) {
        iteratee(obj[keys[i]], keys[i], obj);
      }
    }
    return obj;
  };

  // Return the results of applying the iteratee to each element.
  _.map = _.collect = function(obj, iteratee, context) {
    iteratee = cb(iteratee, context);
    var keys = !isArrayLike(obj) && _.keys(obj),
        length = (keys || obj).length,
        results = Array(length);
    for (var index = 0; index < length; index++) {
      var currentKey = keys ? keys[index] : index;
      results[index] = iteratee(obj[currentKey], currentKey, obj);
    }
    return results;
  };

  // Create a reducing function iterating left or right.
  function createReduce(dir) {
    // Optimized iterator function as using arguments.length
    // in the main function will deoptimize the, see #1991.
    function iterator(obj, iteratee, memo, keys, index, length) {
      for (; index >= 0 && index < length; index += dir) {
        var currentKey = keys ? keys[index] : index;
        memo = iteratee(memo, obj[currentKey], currentKey, obj);
      }
      return memo;
    }

    return function(obj, iteratee, memo, context) {
      iteratee = optimizeCb(iteratee, context, 4);
      var keys = !isArrayLike(obj) && _.keys(obj),
          length = (keys || obj).length,
          index = dir > 0 ? 0 : length - 1;
      // Determine the initial value if none is provided.
      if (arguments.length < 3) {
        memo = obj[keys ? keys[index] : index];
        index += dir;
      }
      return iterator(obj, iteratee, memo, keys, index, length);
    };
  }

  // **Reduce** builds up a single result from a list of values, aka `inject`,
  // or `foldl`.
  _.reduce = _.foldl = _.inject = createReduce(1);

  // The right-associative version of reduce, also known as `foldr`.
  _.reduceRight = _.foldr = createReduce(-1);

  // Return the first value which passes a truth test. Aliased as `detect`.
  _.find = _.detect = function(obj, predicate, context) {
    var key;
    if (isArrayLike(obj)) {
      key = _.findIndex(obj, predicate, context);
    } else {
      key = _.findKey(obj, predicate, context);
    }
    if (key !== void 0 && key !== -1) return obj[key];
  };

  // Return all the elements that pass a truth test.
  // Aliased as `select`.
  _.filter = _.select = function(obj, predicate, context) {
    var results = [];
    predicate = cb(predicate, context);
    _.each(obj, function(value, index, list) {
      if (predicate(value, index, list)) results.push(value);
    });
    return results;
  };

  // Return all the elements for which a truth test fails.
  _.reject = function(obj, predicate, context) {
    return _.filter(obj, _.negate(cb(predicate)), context);
  };

  // Determine whether all of the elements match a truth test.
  // Aliased as `all`.
  _.every = _.all = function(obj, predicate, context) {
    predicate = cb(predicate, context);
    var keys = !isArrayLike(obj) && _.keys(obj),
        length = (keys || obj).length;
    for (var index = 0; index < length; index++) {
      var currentKey = keys ? keys[index] : index;
      if (!predicate(obj[currentKey], currentKey, obj)) return false;
    }
    return true;
  };

  // Determine if at least one element in the object matches a truth test.
  // Aliased as `any`.
  _.some = _.any = function(obj, predicate, context) {
    predicate = cb(predicate, context);
    var keys = !isArrayLike(obj) && _.keys(obj),
        length = (keys || obj).length;
    for (var index = 0; index < length; index++) {
      var currentKey = keys ? keys[index] : index;
      if (predicate(obj[currentKey], currentKey, obj)) return true;
    }
    return false;
  };

  // Determine if the array or object contains a given item (using `===`).
  // Aliased as `includes` and `include`.
  _.contains = _.includes = _.include = function(obj, item, fromIndex, guard) {
    if (!isArrayLike(obj)) obj = _.values(obj);
    if (typeof fromIndex != 'number' || guard) fromIndex = 0;
    return _.indexOf(obj, item, fromIndex) >= 0;
  };

  // Invoke a method (with arguments) on every item in a collection.
  _.invoke = function(obj, method) {
    var args = slice.call(arguments, 2);
    var isFunc = _.isFunction(method);
    return _.map(obj, function(value) {
      var func = isFunc ? method : value[method];
      return func == null ? func : func.apply(value, args);
    });
  };

  // Convenience version of a common use case of `map`: fetching a property.
  _.pluck = function(obj, key) {
    return _.map(obj, _.property(key));
  };

  // Convenience version of a common use case of `filter`: selecting only objects
  // containing specific `key:value` pairs.
  _.where = function(obj, attrs) {
    return _.filter(obj, _.matcher(attrs));
  };

  // Convenience version of a common use case of `find`: getting the first object
  // containing specific `key:value` pairs.
  _.findWhere = function(obj, attrs) {
    return _.find(obj, _.matcher(attrs));
  };

  // Return the maximum element (or element-based computation).
  _.max = function(obj, iteratee, context) {
    var result = -Infinity, lastComputed = -Infinity,
        value, computed;
    if (iteratee == null && obj != null) {
      obj = isArrayLike(obj) ? obj : _.values(obj);
      for (var i = 0, length = obj.length; i < length; i++) {
        value = obj[i];
        if (value > result) {
          result = value;
        }
      }
    } else {
      iteratee = cb(iteratee, context);
      _.each(obj, function(value, index, list) {
        computed = iteratee(value, index, list);
        if (computed > lastComputed || computed === -Infinity && result === -Infinity) {
          result = value;
          lastComputed = computed;
        }
      });
    }
    return result;
  };

  // Return the minimum element (or element-based computation).
  _.min = function(obj, iteratee, context) {
    var result = Infinity, lastComputed = Infinity,
        value, computed;
    if (iteratee == null && obj != null) {
      obj = isArrayLike(obj) ? obj : _.values(obj);
      for (var i = 0, length = obj.length; i < length; i++) {
        value = obj[i];
        if (value < result) {
          result = value;
        }
      }
    } else {
      iteratee = cb(iteratee, context);
      _.each(obj, function(value, index, list) {
        computed = iteratee(value, index, list);
        if (computed < lastComputed || computed === Infinity && result === Infinity) {
          result = value;
          lastComputed = computed;
        }
      });
    }
    return result;
  };

  // Shuffle a collection, using the modern version of the
  // [Fisher-Yates shuffle](http://en.wikipedia.org/wiki/Fisher–Yates_shuffle).
  _.shuffle = function(obj) {
    var set = isArrayLike(obj) ? obj : _.values(obj);
    var length = set.length;
    var shuffled = Array(length);
    for (var index = 0, rand; index < length; index++) {
      rand = _.random(0, index);
      if (rand !== index) shuffled[index] = shuffled[rand];
      shuffled[rand] = set[index];
    }
    return shuffled;
  };

  // Sample **n** random values from a collection.
  // If **n** is not specified, returns a single random element.
  // The internal `guard` argument allows it to work with `map`.
  _.sample = function(obj, n, guard) {
    if (n == null || guard) {
      if (!isArrayLike(obj)) obj = _.values(obj);
      return obj[_.random(obj.length - 1)];
    }
    return _.shuffle(obj).slice(0, Math.max(0, n));
  };

  // Sort the object's values by a criterion produced by an iteratee.
  _.sortBy = function(obj, iteratee, context) {
    iteratee = cb(iteratee, context);
    return _.pluck(_.map(obj, function(value, index, list) {
      return {
        value: value,
        index: index,
        criteria: iteratee(value, index, list)
      };
    }).sort(function(left, right) {
      var a = left.criteria;
      var b = right.criteria;
      if (a !== b) {
        if (a > b || a === void 0) return 1;
        if (a < b || b === void 0) return -1;
      }
      return left.index - right.index;
    }), 'value');
  };

  // An internal function used for aggregate "group by" operations.
  var group = function(behavior) {
    return function(obj, iteratee, context) {
      var result = {};
      iteratee = cb(iteratee, context);
      _.each(obj, function(value, index) {
        var key = iteratee(value, index, obj);
        behavior(result, value, key);
      });
      return result;
    };
  };

  // Groups the object's values by a criterion. Pass either a string attribute
  // to group by, or a function that returns the criterion.
  _.groupBy = group(function(result, value, key) {
    if (_.has(result, key)) result[key].push(value); else result[key] = [value];
  });

  // Indexes the object's values by a criterion, similar to `groupBy`, but for
  // when you know that your index values will be unique.
  _.indexBy = group(function(result, value, key) {
    result[key] = value;
  });

  // Counts instances of an object that group by a certain criterion. Pass
  // either a string attribute to count by, or a function that returns the
  // criterion.
  _.countBy = group(function(result, value, key) {
    if (_.has(result, key)) result[key]++; else result[key] = 1;
  });

  // Safely create a real, live array from anything iterable.
  _.toArray = function(obj) {
    if (!obj) return [];
    if (_.isArray(obj)) return slice.call(obj);
    if (isArrayLike(obj)) return _.map(obj, _.identity);
    return _.values(obj);
  };

  // Return the number of elements in an object.
  _.size = function(obj) {
    if (obj == null) return 0;
    return isArrayLike(obj) ? obj.length : _.keys(obj).length;
  };

  // Split a collection into two arrays: one whose elements all satisfy the given
  // predicate, and one whose elements all do not satisfy the predicate.
  _.partition = function(obj, predicate, context) {
    predicate = cb(predicate, context);
    var pass = [], fail = [];
    _.each(obj, function(value, key, obj) {
      (predicate(value, key, obj) ? pass : fail).push(value);
    });
    return [pass, fail];
  };

  // Array Functions
  // ---------------

  // Get the first element of an array. Passing **n** will return the first N
  // values in the array. Aliased as `head` and `take`. The **guard** check
  // allows it to work with `_.map`.
  _.first = _.head = _.take = function(array, n, guard) {
    if (array == null) return void 0;
    if (n == null || guard) return array[0];
    return _.initial(array, array.length - n);
  };

  // Returns everything but the last entry of the array. Especially useful on
  // the arguments object. Passing **n** will return all the values in
  // the array, excluding the last N.
  _.initial = function(array, n, guard) {
    return slice.call(array, 0, Math.max(0, array.length - (n == null || guard ? 1 : n)));
  };

  // Get the last element of an array. Passing **n** will return the last N
  // values in the array.
  _.last = function(array, n, guard) {
    if (array == null) return void 0;
    if (n == null || guard) return array[array.length - 1];
    return _.rest(array, Math.max(0, array.length - n));
  };

  // Returns everything but the first entry of the array. Aliased as `tail` and `drop`.
  // Especially useful on the arguments object. Passing an **n** will return
  // the rest N values in the array.
  _.rest = _.tail = _.drop = function(array, n, guard) {
    return slice.call(array, n == null || guard ? 1 : n);
  };

  // Trim out all falsy values from an array.
  _.compact = function(array) {
    return _.filter(array, _.identity);
  };

  // Internal implementation of a recursive `flatten` function.
  var flatten = function(input, shallow, strict, startIndex) {
    var output = [], idx = 0;
    for (var i = startIndex || 0, length = getLength(input); i < length; i++) {
      var value = input[i];
      if (isArrayLike(value) && (_.isArray(value) || _.isArguments(value))) {
        //flatten current level of array or arguments object
        if (!shallow) value = flatten(value, shallow, strict);
        var j = 0, len = value.length;
        output.length += len;
        while (j < len) {
          output[idx++] = value[j++];
        }
      } else if (!strict) {
        output[idx++] = value;
      }
    }
    return output;
  };

  // Flatten out an array, either recursively (by default), or just one level.
  _.flatten = function(array, shallow) {
    return flatten(array, shallow, false);
  };

  // Return a version of the array that does not contain the specified value(s).
  _.without = function(array) {
    return _.difference(array, slice.call(arguments, 1));
  };

  // Produce a duplicate-free version of the array. If the array has already
  // been sorted, you have the option of using a faster algorithm.
  // Aliased as `unique`.
  _.uniq = _.unique = function(array, isSorted, iteratee, context) {
    if (!_.isBoolean(isSorted)) {
      context = iteratee;
      iteratee = isSorted;
      isSorted = false;
    }
    if (iteratee != null) iteratee = cb(iteratee, context);
    var result = [];
    var seen = [];
    for (var i = 0, length = getLength(array); i < length; i++) {
      var value = array[i],
          computed = iteratee ? iteratee(value, i, array) : value;
      if (isSorted) {
        if (!i || seen !== computed) result.push(value);
        seen = computed;
      } else if (iteratee) {
        if (!_.contains(seen, computed)) {
          seen.push(computed);
          result.push(value);
        }
      } else if (!_.contains(result, value)) {
        result.push(value);
      }
    }
    return result;
  };

  // Produce an array that contains the union: each distinct element from all of
  // the passed-in arrays.
  _.union = function() {
    return _.uniq(flatten(arguments, true, true));
  };

  // Produce an array that contains every item shared between all the
  // passed-in arrays.
  _.intersection = function(array) {
    var result = [];
    var argsLength = arguments.length;
    for (var i = 0, length = getLength(array); i < length; i++) {
      var item = array[i];
      if (_.contains(result, item)) continue;
      for (var j = 1; j < argsLength; j++) {
        if (!_.contains(arguments[j], item)) break;
      }
      if (j === argsLength) result.push(item);
    }
    return result;
  };

  // Take the difference between one array and a number of other arrays.
  // Only the elements present in just the first array will remain.
  _.difference = function(array) {
    var rest = flatten(arguments, true, true, 1);
    return _.filter(array, function(value){
      return !_.contains(rest, value);
    });
  };

  // Zip together multiple lists into a single array -- elements that share
  // an index go together.
  _.zip = function() {
    return _.unzip(arguments);
  };

  // Complement of _.zip. Unzip accepts an array of arrays and groups
  // each array's elements on shared indices
  _.unzip = function(array) {
    var length = array && _.max(array, getLength).length || 0;
    var result = Array(length);

    for (var index = 0; index < length; index++) {
      result[index] = _.pluck(array, index);
    }
    return result;
  };

  // Converts lists into objects. Pass either a single array of `[key, value]`
  // pairs, or two parallel arrays of the same length -- one of keys, and one of
  // the corresponding values.
  _.object = function(list, values) {
    var result = {};
    for (var i = 0, length = getLength(list); i < length; i++) {
      if (values) {
        result[list[i]] = values[i];
      } else {
        result[list[i][0]] = list[i][1];
      }
    }
    return result;
  };

  // Generator function to create the findIndex and findLastIndex functions
  function createPredicateIndexFinder(dir) {
    return function(array, predicate, context) {
      predicate = cb(predicate, context);
      var length = getLength(array);
      var index = dir > 0 ? 0 : length - 1;
      for (; index >= 0 && index < length; index += dir) {
        if (predicate(array[index], index, array)) return index;
      }
      return -1;
    };
  }

  // Returns the first index on an array-like that passes a predicate test
  _.findIndex = createPredicateIndexFinder(1);
  _.findLastIndex = createPredicateIndexFinder(-1);

  // Use a comparator function to figure out the smallest index at which
  // an object should be inserted so as to maintain order. Uses binary search.
  _.sortedIndex = function(array, obj, iteratee, context) {
    iteratee = cb(iteratee, context, 1);
    var value = iteratee(obj);
    var low = 0, high = getLength(array);
    while (low < high) {
      var mid = Math.floor((low + high) / 2);
      if (iteratee(array[mid]) < value) low = mid + 1; else high = mid;
    }
    return low;
  };

  // Generator function to create the indexOf and lastIndexOf functions
  function createIndexFinder(dir, predicateFind, sortedIndex) {
    return function(array, item, idx) {
      var i = 0, length = getLength(array);
      if (typeof idx == 'number') {
        if (dir > 0) {
            i = idx >= 0 ? idx : Math.max(idx + length, i);
        } else {
            length = idx >= 0 ? Math.min(idx + 1, length) : idx + length + 1;
        }
      } else if (sortedIndex && idx && length) {
        idx = sortedIndex(array, item);
        return array[idx] === item ? idx : -1;
      }
      if (item !== item) {
        idx = predicateFind(slice.call(array, i, length), _.isNaN);
        return idx >= 0 ? idx + i : -1;
      }
      for (idx = dir > 0 ? i : length - 1; idx >= 0 && idx < length; idx += dir) {
        if (array[idx] === item) return idx;
      }
      return -1;
    };
  }

  // Return the position of the first occurrence of an item in an array,
  // or -1 if the item is not included in the array.
  // If the array is large and already in sort order, pass `true`
  // for **isSorted** to use binary search.
  _.indexOf = createIndexFinder(1, _.findIndex, _.sortedIndex);
  _.lastIndexOf = createIndexFinder(-1, _.findLastIndex);

  // Generate an integer Array containing an arithmetic progression. A port of
  // the native Python `range()` function. See
  // [the Python documentation](http://docs.python.org/library/functions.html#range).
  _.range = function(start, stop, step) {
    if (stop == null) {
      stop = start || 0;
      start = 0;
    }
    step = step || 1;

    var length = Math.max(Math.ceil((stop - start) / step), 0);
    var range = Array(length);

    for (var idx = 0; idx < length; idx++, start += step) {
      range[idx] = start;
    }

    return range;
  };

  // Function (ahem) Functions
  // ------------------

  // Determines whether to execute a function as a constructor
  // or a normal function with the provided arguments
  var executeBound = function(sourceFunc, boundFunc, context, callingContext, args) {
    if (!(callingContext instanceof boundFunc)) return sourceFunc.apply(context, args);
    var self = baseCreate(sourceFunc.prototype);
    var result = sourceFunc.apply(self, args);
    if (_.isObject(result)) return result;
    return self;
  };

  // Create a function bound to a given object (assigning `this`, and arguments,
  // optionally). Delegates to **ECMAScript 5**'s native `Function.bind` if
  // available.
  _.bind = function(func, context) {
    if (nativeBind && func.bind === nativeBind) return nativeBind.apply(func, slice.call(arguments, 1));
    if (!_.isFunction(func)) throw new TypeError('Bind must be called on a function');
    var args = slice.call(arguments, 2);
    var bound = function() {
      return executeBound(func, bound, context, this, args.concat(slice.call(arguments)));
    };
    return bound;
  };

  // Partially apply a function by creating a version that has had some of its
  // arguments pre-filled, without changing its dynamic `this` context. _ acts
  // as a placeholder, allowing any combination of arguments to be pre-filled.
  _.partial = function(func) {
    var boundArgs = slice.call(arguments, 1);
    var bound = function() {
      var position = 0, length = boundArgs.length;
      var args = Array(length);
      for (var i = 0; i < length; i++) {
        args[i] = boundArgs[i] === _ ? arguments[position++] : boundArgs[i];
      }
      while (position < arguments.length) args.push(arguments[position++]);
      return executeBound(func, bound, this, this, args);
    };
    return bound;
  };

  // Bind a number of an object's methods to that object. Remaining arguments
  // are the method names to be bound. Useful for ensuring that all callbacks
  // defined on an object belong to it.
  _.bindAll = function(obj) {
    var i, length = arguments.length, key;
    if (length <= 1) throw new Error('bindAll must be passed function names');
    for (i = 1; i < length; i++) {
      key = arguments[i];
      obj[key] = _.bind(obj[key], obj);
    }
    return obj;
  };

  // Memoize an expensive function by storing its results.
  _.memoize = function(func, hasher) {
    var memoize = function(key) {
      var cache = memoize.cache;
      var address = '' + (hasher ? hasher.apply(this, arguments) : key);
      if (!_.has(cache, address)) cache[address] = func.apply(this, arguments);
      return cache[address];
    };
    memoize.cache = {};
    return memoize;
  };

  // Delays a function for the given number of milliseconds, and then calls
  // it with the arguments supplied.
  _.delay = function(func, wait) {
    var args = slice.call(arguments, 2);
    return setTimeout(function(){
      return func.apply(null, args);
    }, wait);
  };

  // Defers a function, scheduling it to run after the current call stack has
  // cleared.
  _.defer = _.partial(_.delay, _, 1);

  // Returns a function, that, when invoked, will only be triggered at most once
  // during a given window of time. Normally, the throttled function will run
  // as much as it can, without ever going more than once per `wait` duration;
  // but if you'd like to disable the execution on the leading edge, pass
  // `{leading: false}`. To disable execution on the trailing edge, ditto.
  _.throttle = function(func, wait, options) {
    var context, args, result;
    var timeout = null;
    var previous = 0;
    if (!options) options = {};
    var later = function() {
      previous = options.leading === false ? 0 : _.now();
      timeout = null;
      result = func.apply(context, args);
      if (!timeout) context = args = null;
    };
    return function() {
      var now = _.now();
      if (!previous && options.leading === false) previous = now;
      var remaining = wait - (now - previous);
      context = this;
      args = arguments;
      if (remaining <= 0 || remaining > wait) {
        if (timeout) {
          clearTimeout(timeout);
          timeout = null;
        }
        previous = now;
        result = func.apply(context, args);
        if (!timeout) context = args = null;
      } else if (!timeout && options.trailing !== false) {
        timeout = setTimeout(later, remaining);
      }
      return result;
    };
  };

  // Returns a function, that, as long as it continues to be invoked, will not
  // be triggered. The function will be called after it stops being called for
  // N milliseconds. If `immediate` is passed, trigger the function on the
  // leading edge, instead of the trailing.
  _.debounce = function(func, wait, immediate) {
    var timeout, args, context, timestamp, result;

    var later = function() {
      var last = _.now() - timestamp;

      if (last < wait && last >= 0) {
        timeout = setTimeout(later, wait - last);
      } else {
        timeout = null;
        if (!immediate) {
          result = func.apply(context, args);
          if (!timeout) context = args = null;
        }
      }
    };

    return function() {
      context = this;
      args = arguments;
      timestamp = _.now();
      var callNow = immediate && !timeout;
      if (!timeout) timeout = setTimeout(later, wait);
      if (callNow) {
        result = func.apply(context, args);
        context = args = null;
      }

      return result;
    };
  };

  // Returns the first function passed as an argument to the second,
  // allowing you to adjust arguments, run code before and after, and
  // conditionally execute the original function.
  _.wrap = function(func, wrapper) {
    return _.partial(wrapper, func);
  };

  // Returns a negated version of the passed-in predicate.
  _.negate = function(predicate) {
    return function() {
      return !predicate.apply(this, arguments);
    };
  };

  // Returns a function that is the composition of a list of functions, each
  // consuming the return value of the function that follows.
  _.compose = function() {
    var args = arguments;
    var start = args.length - 1;
    return function() {
      var i = start;
      var result = args[start].apply(this, arguments);
      while (i--) result = args[i].call(this, result);
      return result;
    };
  };

  // Returns a function that will only be executed on and after the Nth call.
  _.after = function(times, func) {
    return function() {
      if (--times < 1) {
        return func.apply(this, arguments);
      }
    };
  };

  // Returns a function that will only be executed up to (but not including) the Nth call.
  _.before = function(times, func) {
    var memo;
    return function() {
      if (--times > 0) {
        memo = func.apply(this, arguments);
      }
      if (times <= 1) func = null;
      return memo;
    };
  };

  // Returns a function that will be executed at most one time, no matter how
  // often you call it. Useful for lazy initialization.
  _.once = _.partial(_.before, 2);

  // Object Functions
  // ----------------

  // Keys in IE < 9 that won't be iterated by `for key in ...` and thus missed.
  var hasEnumBug = !{toString: null}.propertyIsEnumerable('toString');
  var nonEnumerableProps = ['valueOf', 'isPrototypeOf', 'toString',
                      'propertyIsEnumerable', 'hasOwnProperty', 'toLocaleString'];

  function collectNonEnumProps(obj, keys) {
    var nonEnumIdx = nonEnumerableProps.length;
    var constructor = obj.constructor;
    var proto = (_.isFunction(constructor) && constructor.prototype) || ObjProto;

    // Constructor is a special case.
    var prop = 'constructor';
    if (_.has(obj, prop) && !_.contains(keys, prop)) keys.push(prop);

    while (nonEnumIdx--) {
      prop = nonEnumerableProps[nonEnumIdx];
      if (prop in obj && obj[prop] !== proto[prop] && !_.contains(keys, prop)) {
        keys.push(prop);
      }
    }
  }

  // Retrieve the names of an object's own properties.
  // Delegates to **ECMAScript 5**'s native `Object.keys`
  _.keys = function(obj) {
    if (!_.isObject(obj)) return [];
    if (nativeKeys) return nativeKeys(obj);
    var keys = [];
    for (var key in obj) if (_.has(obj, key)) keys.push(key);
    // Ahem, IE < 9.
    if (hasEnumBug) collectNonEnumProps(obj, keys);
    return keys;
  };

  // Retrieve all the property names of an object.
  _.allKeys = function(obj) {
    if (!_.isObject(obj)) return [];
    var keys = [];
    for (var key in obj) keys.push(key);
    // Ahem, IE < 9.
    if (hasEnumBug) collectNonEnumProps(obj, keys);
    return keys;
  };

  // Retrieve the values of an object's properties.
  _.values = function(obj) {
    var keys = _.keys(obj);
    var length = keys.length;
    var values = Array(length);
    for (var i = 0; i < length; i++) {
      values[i] = obj[keys[i]];
    }
    return values;
  };

  // Returns the results of applying the iteratee to each element of the object
  // In contrast to _.map it returns an object
  _.mapObject = function(obj, iteratee, context) {
    iteratee = cb(iteratee, context);
    var keys =  _.keys(obj),
          length = keys.length,
          results = {},
          currentKey;
      for (var index = 0; index < length; index++) {
        currentKey = keys[index];
        results[currentKey] = iteratee(obj[currentKey], currentKey, obj);
      }
      return results;
  };

  // Convert an object into a list of `[key, value]` pairs.
  _.pairs = function(obj) {
    var keys = _.keys(obj);
    var length = keys.length;
    var pairs = Array(length);
    for (var i = 0; i < length; i++) {
      pairs[i] = [keys[i], obj[keys[i]]];
    }
    return pairs;
  };

  // Invert the keys and values of an object. The values must be serializable.
  _.invert = function(obj) {
    var result = {};
    var keys = _.keys(obj);
    for (var i = 0, length = keys.length; i < length; i++) {
      result[obj[keys[i]]] = keys[i];
    }
    return result;
  };

  // Return a sorted list of the function names available on the object.
  // Aliased as `methods`
  _.functions = _.methods = function(obj) {
    var names = [];
    for (var key in obj) {
      if (_.isFunction(obj[key])) names.push(key);
    }
    return names.sort();
  };

  // Extend a given object with all the properties in passed-in object(s).
  _.extend = createAssigner(_.allKeys);

  // Assigns a given object with all the own properties in the passed-in object(s)
  // (https://developer.mozilla.org/docs/Web/JavaScript/Reference/Global_Objects/Object/assign)
  _.extendOwn = _.assign = createAssigner(_.keys);

  // Returns the first key on an object that passes a predicate test
  _.findKey = function(obj, predicate, context) {
    predicate = cb(predicate, context);
    var keys = _.keys(obj), key;
    for (var i = 0, length = keys.length; i < length; i++) {
      key = keys[i];
      if (predicate(obj[key], key, obj)) return key;
    }
  };

  // Return a copy of the object only containing the whitelisted properties.
  _.pick = function(object, oiteratee, context) {
    var result = {}, obj = object, iteratee, keys;
    if (obj == null) return result;
    if (_.isFunction(oiteratee)) {
      keys = _.allKeys(obj);
      iteratee = optimizeCb(oiteratee, context);
    } else {
      keys = flatten(arguments, false, false, 1);
      iteratee = function(value, key, obj) { return key in obj; };
      obj = Object(obj);
    }
    for (var i = 0, length = keys.length; i < length; i++) {
      var key = keys[i];
      var value = obj[key];
      if (iteratee(value, key, obj)) result[key] = value;
    }
    return result;
  };

   // Return a copy of the object without the blacklisted properties.
  _.omit = function(obj, iteratee, context) {
    if (_.isFunction(iteratee)) {
      iteratee = _.negate(iteratee);
    } else {
      var keys = _.map(flatten(arguments, false, false, 1), String);
      iteratee = function(value, key) {
        return !_.contains(keys, key);
      };
    }
    return _.pick(obj, iteratee, context);
  };

  // Fill in a given object with default properties.
  _.defaults = createAssigner(_.allKeys, true);

  // Creates an object that inherits from the given prototype object.
  // If additional properties are provided then they will be added to the
  // created object.
  _.create = function(prototype, props) {
    var result = baseCreate(prototype);
    if (props) _.extendOwn(result, props);
    return result;
  };

  // Create a (shallow-cloned) duplicate of an object.
  _.clone = function(obj) {
    if (!_.isObject(obj)) return obj;
    return _.isArray(obj) ? obj.slice() : _.extend({}, obj);
  };

  // Invokes interceptor with the obj, and then returns obj.
  // The primary purpose of this method is to "tap into" a method chain, in
  // order to perform operations on intermediate results within the chain.
  _.tap = function(obj, interceptor) {
    interceptor(obj);
    return obj;
  };

  // Returns whether an object has a given set of `key:value` pairs.
  _.isMatch = function(object, attrs) {
    var keys = _.keys(attrs), length = keys.length;
    if (object == null) return !length;
    var obj = Object(object);
    for (var i = 0; i < length; i++) {
      var key = keys[i];
      if (attrs[key] !== obj[key] || !(key in obj)) return false;
    }
    return true;
  };


  // Internal recursive comparison function for `isEqual`.
  var eq = function(a, b, aStack, bStack) {
    // Identical objects are equal. `0 === -0`, but they aren't identical.
    // See the [Harmony `egal` proposal](http://wiki.ecmascript.org/doku.php?id=harmony:egal).
    if (a === b) return a !== 0 || 1 / a === 1 / b;
    // A strict comparison is necessary because `null == undefined`.
    if (a == null || b == null) return a === b;
    // Unwrap any wrapped objects.
    if (a instanceof _) a = a._wrapped;
    if (b instanceof _) b = b._wrapped;
    // Compare `[[Class]]` names.
    var className = toString.call(a);
    if (className !== toString.call(b)) return false;
    switch (className) {
      // Strings, numbers, regular expressions, dates, and booleans are compared by value.
      case '[object RegExp]':
      // RegExps are coerced to strings for comparison (Note: '' + /a/i === '/a/i')
      case '[object String]':
        // Primitives and their corresponding object wrappers are equivalent; thus, `"5"` is
        // equivalent to `new String("5")`.
        return '' + a === '' + b;
      case '[object Number]':
        // `NaN`s are equivalent, but non-reflexive.
        // Object(NaN) is equivalent to NaN
        if (+a !== +a) return +b !== +b;
        // An `egal` comparison is performed for other numeric values.
        return +a === 0 ? 1 / +a === 1 / b : +a === +b;
      case '[object Date]':
      case '[object Boolean]':
        // Coerce dates and booleans to numeric primitive values. Dates are compared by their
        // millisecond representations. Note that invalid dates with millisecond representations
        // of `NaN` are not equivalent.
        return +a === +b;
    }

    var areArrays = className === '[object Array]';
    if (!areArrays) {
      if (typeof a != 'object' || typeof b != 'object') return false;

      // Objects with different constructors are not equivalent, but `Object`s or `Array`s
      // from different frames are.
      var aCtor = a.constructor, bCtor = b.constructor;
      if (aCtor !== bCtor && !(_.isFunction(aCtor) && aCtor instanceof aCtor &&
                               _.isFunction(bCtor) && bCtor instanceof bCtor)
                          && ('constructor' in a && 'constructor' in b)) {
        return false;
      }
    }
    // Assume equality for cyclic structures. The algorithm for detecting cyclic
    // structures is adapted from ES 5.1 section 15.12.3, abstract operation `JO`.

    // Initializing stack of traversed objects.
    // It's done here since we only need them for objects and arrays comparison.
    aStack = aStack || [];
    bStack = bStack || [];
    var length = aStack.length;
    while (length--) {
      // Linear search. Performance is inversely proportional to the number of
      // unique nested structures.
      if (aStack[length] === a) return bStack[length] === b;
    }

    // Add the first object to the stack of traversed objects.
    aStack.push(a);
    bStack.push(b);

    // Recursively compare objects and arrays.
    if (areArrays) {
      // Compare array lengths to determine if a deep comparison is necessary.
      length = a.length;
      if (length !== b.length) return false;
      // Deep compare the contents, ignoring non-numeric properties.
      while (length--) {
        if (!eq(a[length], b[length], aStack, bStack)) return false;
      }
    } else {
      // Deep compare objects.
      var keys = _.keys(a), key;
      length = keys.length;
      // Ensure that both objects contain the same number of properties before comparing deep equality.
      if (_.keys(b).length !== length) return false;
      while (length--) {
        // Deep compare each member
        key = keys[length];
        if (!(_.has(b, key) && eq(a[key], b[key], aStack, bStack))) return false;
      }
    }
    // Remove the first object from the stack of traversed objects.
    aStack.pop();
    bStack.pop();
    return true;
  };

  // Perform a deep comparison to check if two objects are equal.
  _.isEqual = function(a, b) {
    return eq(a, b);
  };

  // Is a given array, string, or object empty?
  // An "empty" object has no enumerable own-properties.
  _.isEmpty = function(obj) {
    if (obj == null) return true;
    if (isArrayLike(obj) && (_.isArray(obj) || _.isString(obj) || _.isArguments(obj))) return obj.length === 0;
    return _.keys(obj).length === 0;
  };

  // Is a given value a DOM element?
  _.isElement = function(obj) {
    return !!(obj && obj.nodeType === 1);
  };

  // Is a given value an array?
  // Delegates to ECMA5's native Array.isArray
  _.isArray = nativeIsArray || function(obj) {
    return toString.call(obj) === '[object Array]';
  };

  // Is a given variable an object?
  _.isObject = function(obj) {
    var type = typeof obj;
    return type === 'function' || type === 'object' && !!obj;
  };

  // Add some isType methods: isArguments, isFunction, isString, isNumber, isDate, isRegExp, isError.
  _.each(['Arguments', 'Function', 'String', 'Number', 'Date', 'RegExp', 'Error'], function(name) {
    _['is' + name] = function(obj) {
      return toString.call(obj) === '[object ' + name + ']';
    };
  });

  // Define a fallback version of the method in browsers (ahem, IE < 9), where
  // there isn't any inspectable "Arguments" type.
  if (!_.isArguments(arguments)) {
    _.isArguments = function(obj) {
      return _.has(obj, 'callee');
    };
  }

  // Optimize `isFunction` if appropriate. Work around some typeof bugs in old v8,
  // IE 11 (#1621), and in Safari 8 (#1929).
  if (typeof /./ != 'function' && typeof Int8Array != 'object') {
    _.isFunction = function(obj) {
      return typeof obj == 'function' || false;
    };
  }

  // Is a given object a finite number?
  _.isFinite = function(obj) {
    return isFinite(obj) && !isNaN(parseFloat(obj));
  };

  // Is the given value `NaN`? (NaN is the only number which does not equal itself).
  _.isNaN = function(obj) {
    return _.isNumber(obj) && obj !== +obj;
  };

  // Is a given value a boolean?
  _.isBoolean = function(obj) {
    return obj === true || obj === false || toString.call(obj) === '[object Boolean]';
  };

  // Is a given value equal to null?
  _.isNull = function(obj) {
    return obj === null;
  };

  // Is a given variable undefined?
  _.isUndefined = function(obj) {
    return obj === void 0;
  };

  // Shortcut function for checking if an object has a given property directly
  // on itself (in other words, not on a prototype).
  _.has = function(obj, key) {
    return obj != null && hasOwnProperty.call(obj, key);
  };

  // Utility Functions
  // -----------------

  // Run Underscore.js in *noConflict* mode, returning the `_` variable to its
  // previous owner. Returns a reference to the Underscore object.
  _.noConflict = function() {
    root._ = previousUnderscore;
    return this;
  };

  // Keep the identity function around for default iteratees.
  _.identity = function(value) {
    return value;
  };

  // Predicate-generating functions. Often useful outside of Underscore.
  _.constant = function(value) {
    return function() {
      return value;
    };
  };

  _.noop = function(){};

  _.property = property;

  // Generates a function for a given object that returns a given property.
  _.propertyOf = function(obj) {
    return obj == null ? function(){} : function(key) {
      return obj[key];
    };
  };

  // Returns a predicate for checking whether an object has a given set of
  // `key:value` pairs.
  _.matcher = _.matches = function(attrs) {
    attrs = _.extendOwn({}, attrs);
    return function(obj) {
      return _.isMatch(obj, attrs);
    };
  };

  // Run a function **n** times.
  _.times = function(n, iteratee, context) {
    var accum = Array(Math.max(0, n));
    iteratee = optimizeCb(iteratee, context, 1);
    for (var i = 0; i < n; i++) accum[i] = iteratee(i);
    return accum;
  };

  // Return a random integer between min and max (inclusive).
  _.random = function(min, max) {
    if (max == null) {
      max = min;
      min = 0;
    }
    return min + Math.floor(Math.random() * (max - min + 1));
  };

  // A (possibly faster) way to get the current timestamp as an integer.
  _.now = Date.now || function() {
    return new Date().getTime();
  };

   // List of HTML entities for escaping.
  var escapeMap = {
    '&': '&amp;',
    '<': '&lt;',
    '>': '&gt;',
    '"': '&quot;',
    "'": '&#x27;',
    '`': '&#x60;'
  };
  var unescapeMap = _.invert(escapeMap);

  // Functions for escaping and unescaping strings to/from HTML interpolation.
  var createEscaper = function(map) {
    var escaper = function(match) {
      return map[match];
    };
    // Regexes for identifying a key that needs to be escaped
    var source = '(?:' + _.keys(map).join('|') + ')';
    var testRegexp = RegExp(source);
    var replaceRegexp = RegExp(source, 'g');
    return function(string) {
      string = string == null ? '' : '' + string;
      return testRegexp.test(string) ? string.replace(replaceRegexp, escaper) : string;
    };
  };
  _.escape = createEscaper(escapeMap);
  _.unescape = createEscaper(unescapeMap);

  // If the value of the named `property` is a function then invoke it with the
  // `object` as context; otherwise, return it.
  _.result = function(object, property, fallback) {
    var value = object == null ? void 0 : object[property];
    if (value === void 0) {
      value = fallback;
    }
    return _.isFunction(value) ? value.call(object) : value;
  };

  // Generate a unique integer id (unique within the entire client session).
  // Useful for temporary DOM ids.
  var idCounter = 0;
  _.uniqueId = function(prefix) {
    var id = ++idCounter + '';
    return prefix ? prefix + id : id;
  };

  // By default, Underscore uses ERB-style template delimiters, change the
  // following template settings to use alternative delimiters.
  _.templateSettings = {
    evaluate    : /<%([\s\S]+?)%>/g,
    interpolate : /<%=([\s\S]+?)%>/g,
    escape      : /<%-([\s\S]+?)%>/g
  };

  // When customizing `templateSettings`, if you don't want to define an
  // interpolation, evaluation or escaping regex, we need one that is
  // guaranteed not to match.
  var noMatch = /(.)^/;

  // Certain characters need to be escaped so that they can be put into a
  // string literal.
  var escapes = {
    "'":      "'",
    '\\':     '\\',
    '\r':     'r',
    '\n':     'n',
    '\u2028': 'u2028',
    '\u2029': 'u2029'
  };

  var escaper = /\\|'|\r|\n|\u2028|\u2029/g;

  var escapeChar = function(match) {
    return '\\' + escapes[match];
  };

  // JavaScript micro-templating, similar to John Resig's implementation.
  // Underscore templating handles arbitrary delimiters, preserves whitespace,
  // and correctly escapes quotes within interpolated code.
  // NB: `oldSettings` only exists for backwards compatibility.
  _.template = function(text, settings, oldSettings) {
    if (!settings && oldSettings) settings = oldSettings;
    settings = _.defaults({}, settings, _.templateSettings);

    // Combine delimiters into one regular expression via alternation.
    var matcher = RegExp([
      (settings.escape || noMatch).source,
      (settings.interpolate || noMatch).source,
      (settings.evaluate || noMatch).source
    ].join('|') + '|$', 'g');

    // Compile the template source, escaping string literals appropriately.
    var index = 0;
    var source = "__p+='";
    text.replace(matcher, function(match, escape, interpolate, evaluate, offset) {
      source += text.slice(index, offset).replace(escaper, escapeChar);
      index = offset + match.length;

      if (escape) {
        source += "'+\n((__t=(" + escape + "))==null?'':_.escape(__t))+\n'";
      } else if (interpolate) {
        source += "'+\n((__t=(" + interpolate + "))==null?'':__t)+\n'";
      } else if (evaluate) {
        source += "';\n" + evaluate + "\n__p+='";
      }

      // Adobe VMs need the match returned to produce the correct offest.
      return match;
    });
    source += "';\n";

    // If a variable is not specified, place data values in local scope.
    if (!settings.variable) source = 'with(obj||{}){\n' + source + '}\n';

    source = "var __t,__p='',__j=Array.prototype.join," +
      "print=function(){__p+=__j.call(arguments,'');};\n" +
      source + 'return __p;\n';

    try {
      var render = new Function(settings.variable || 'obj', '_', source);
    } catch (e) {
      e.source = source;
      throw e;
    }

    var template = function(data) {
      return render.call(this, data, _);
    };

    // Provide the compiled source as a convenience for precompilation.
    var argument = settings.variable || 'obj';
    template.source = 'function(' + argument + '){\n' + source + '}';

    return template;
  };

  // Add a "chain" function. Start chaining a wrapped Underscore object.
  _.chain = function(obj) {
    var instance = _(obj);
    instance._chain = true;
    return instance;
  };

  // OOP
  // ---------------
  // If Underscore is called as a function, it returns a wrapped object that
  // can be used OO-style. This wrapper holds altered versions of all the
  // underscore functions. Wrapped objects may be chained.

  // Helper function to continue chaining intermediate results.
  var result = function(instance, obj) {
    return instance._chain ? _(obj).chain() : obj;
  };

  // Add your own custom functions to the Underscore object.
  _.mixin = function(obj) {
    _.each(_.functions(obj), function(name) {
      var func = _[name] = obj[name];
      _.prototype[name] = function() {
        var args = [this._wrapped];
        push.apply(args, arguments);
        return result(this, func.apply(_, args));
      };
    });
  };

  // Add all of the Underscore functions to the wrapper object.
  _.mixin(_);

  // Add all mutator Array functions to the wrapper.
  _.each(['pop', 'push', 'reverse', 'shift', 'sort', 'splice', 'unshift'], function(name) {
    var method = ArrayProto[name];
    _.prototype[name] = function() {
      var obj = this._wrapped;
      method.apply(obj, arguments);
      if ((name === 'shift' || name === 'splice') && obj.length === 0) delete obj[0];
      return result(this, obj);
    };
  });

  // Add all accessor Array functions to the wrapper.
  _.each(['concat', 'join', 'slice'], function(name) {
    var method = ArrayProto[name];
    _.prototype[name] = function() {
      return result(this, method.apply(this._wrapped, arguments));
    };
  });

  // Extracts the result from a wrapped and chained object.
  _.prototype.value = function() {
    return this._wrapped;
  };

  // Provide unwrapping proxy for some methods used in engine operations
  // such as arithmetic and JSON stringification.
  _.prototype.valueOf = _.prototype.toJSON = _.prototype.value;

  _.prototype.toString = function() {
    return '' + this._wrapped;
  };

  // AMD registration happens at the end for compatibility with AMD loaders
  // that may not enforce next-turn semantics on modules. Even though general
  // practice for AMD registration is to be anonymous, underscore registers
  // as a named module because, like jQuery, it is a base library that is
  // popular enough to be bundled in a third party lib, but not be part of
  // an AMD load request. Those cases could generate an error when an
  // anonymous define() is called outside of a loader request.
  if (typeof define === 'function' && define.amd) {
    define('underscore', [], function() {
      return _;
    });
  }
}.call(this));

},{}],23:[function(require,module,exports){
// calc.js
// measure calculations

var _ = require('underscore');
var geocrunch = require('geocrunch');

var pad = function (num) {
  return num < 10 ? '0' + num.toString() : num.toString();
};

var ddToDms = function (coordinate, posSymbol, negSymbol) {
  var dd = Math.abs(coordinate),
      d = Math.floor(dd),
      m = Math.floor((dd - d) * 60),
      s = Math.round((dd - d - (m/60)) * 3600 * 100)/100,
      directionSymbol = dd === coordinate ? posSymbol : negSymbol;
  return pad(d) + '&deg; ' + pad(m) + '\' ' + pad(s) + '" ' + directionSymbol;
};

var measure = function (latlngs) {
  var last = _.last(latlngs);
  var path = geocrunch.path(_.map(latlngs, function (latlng) {
    return [latlng.lng, latlng.lat];
  }));

  var meters = path.distance({
    units: 'meters'
  });
  var sqMeters = path.area({
    units: 'sqmeters'
  });

  return {
    lastCoord: {
      dd: {
        x: last.lng,
        y: last.lat
      },
      dms: {
        x: ddToDms(last.lng, 'E', 'W'),
        y: ddToDms(last.lat, 'N', 'S')
      }
    },
    length: meters,
    area: sqMeters
  };
};

module.exports = {
  measure: measure // `measure(latLngArray)` - returns object with calced measurements for passed points
};
},{"geocrunch":7,"underscore":22}],24:[function(require,module,exports){
// dom.js
// utility functions for managing DOM elements

var selectOne = function (selector, el) {
  if (!el) {
    el = document;
  }
  return el.querySelector(selector);
};

var selectAll = function (selector, el) {
  if (!el) {
    el = document;
  }
  return Array.prototype.slice.call(el.querySelectorAll(selector));
};

var hide = function (el) {
  if (el) {
    el.setAttribute('style', 'display:none;');
    return el;
  }
};

var show = function (el) {
  if (el) {
    el.removeAttribute('style');
    return el;
  }
};

module.exports = {
  $: selectOne,  // `$('.myclass', baseElement)` - returns selected element or undefined
  $$: selectAll, // `$$('.myclass', baseElement)` - returns array of selected elements
  hide: hide,    // `hide(someElement)` - hide passed dom element
  show: show     // `show(someElement)` - show passed dom element
};
},{}],25:[function(require,module,exports){
// cn.js
// Chinese i18n translations

module.exports = {
  'measure': '测量',
  'measureDistancesAndAreas': '同时测量距离和面积',
  'createNewMeasurement': '开始一次新的测量',
  'startCreating': '点击地图加点以开始创建测量',
  'finishMeasurement': '完成测量',
  'lastPoint': '最后点的坐标',
  'area': '面积',
  'perimeter': '周长',
  'pointLocation': '点的坐标',
  'areaMeasurement': '面积测量',
  'linearMeasurement': '距离测量',
  'pathDistance': '路径长度',
  'centerOnArea': '该面积居中',
  'centerOnLine': '该线段居中',
  'centerOnLocation': '该位置居中',
  'cancel': '取消',
  'delete': '删除',
  'acres': '公亩',
  'feet': '英尺',
  'kilometers': '公里',
  'hectares': '公顷',
  'meters': '米',
  'miles': '英里',
  'sqfeet': '平方英尺',
  'sqmeters': '平方米',
  'sqmiles': '平方英里',
  'decPoint': '.',
  'thousandsSep': ','
};

},{}],26:[function(require,module,exports){
// de.js
// German i18n translations

module.exports = {
  'measure': 'Messung',
  'measureDistancesAndAreas': 'Messung von Abständen und Flächen',
  'createNewMeasurement': 'Eine neue Messung durchführen',
  'startCreating': 'Führen Sie die Messung durch, indem Sie der Karte Punkte hinzufügen.',
  'finishMeasurement': 'Messung beenden',
  'lastPoint': 'Letzter Punkt',
  'area': 'Fläche',
  'perimeter': 'Rand',
  'pointLocation': 'Lage des Punkts',
  'areaMeasurement': 'Gemessene Fläche',
  'linearMeasurement': 'Gemessener Abstand',
  'pathDistance': 'Abstand entlang des Pfads',
  'centerOnArea': 'Auf diese Fläche zentrieren',
  'centerOnLine': 'Auf diesen Linienzug zentrieren',
  'centerOnLocation': 'Auf diesen Ort zentrieren',
  'cancel': 'Abbrechen',
  'delete': 'Löschen',
  'acres': 'Morgen',
  'feet': 'Fuß',
  'kilometers': 'Kilometer',
  'hectares': 'Hektar',
  'meters': 'Meter',
  'miles': 'Meilen',
  'sqfeet': 'Quadratfuß',
  'sqmeters': 'Quadratmeter',
  'sqmiles': 'Quadratmeilen',
  'decPoint': ',',
  'thousandsSep': '.'
};

},{}],27:[function(require,module,exports){
// en.js
// English i18n translations

module.exports = {
  'measure': 'Measure',
  'measureDistancesAndAreas': 'Measure distances and areas',
  'createNewMeasurement': 'Create a new measurement',
  'startCreating': 'Start creating a measurement by adding points to the map',
  'finishMeasurement': 'Finish measurement',
  'lastPoint': 'Last point',
  'area': 'Area',
  'perimeter': 'Perimeter',
  'pointLocation': 'Point location',
  'areaMeasurement': 'Area measurement',
  'linearMeasurement': 'Linear measurement',
  'pathDistance': 'Path distance',
  'centerOnArea': 'Center on this area',
  'centerOnLine': 'Center on this line',
  'centerOnLocation': 'Center on this location',
  'cancel': 'Cancel',
  'delete': 'Delete',
  'acres': 'Acres',
  'feet': 'Feet',
  'kilometers': 'Kilometers',
  'hectares': 'Hectares',
  'meters': 'Meters',
  'miles': 'Miles',
  'sqfeet': 'Sq Feet',
  'sqmeters': 'Sq Meters',
  'sqmiles': 'Sq Miles',
  'decPoint': '.',
  'thousandsSep': ','
};

},{}],28:[function(require,module,exports){
// es.js
// Spanish i18n translations

module.exports = {
  'measure': 'Medición',
  'measureDistancesAndAreas': 'Mida distancias y áreas',
  'createNewMeasurement': 'Crear nueva medición',
  'startCreating': 'Empiece a crear la medición añadiendo puntos al mapa',
  'finishMeasurement': 'Terminar medición',
  'lastPoint': 'Último punto',
  'area': 'Área',
  'perimeter': 'Perímetro',
  'pointLocation': 'Localización del punto',
  'areaMeasurement': 'Medición de área',
  'linearMeasurement': 'Medición linear',
  'pathDistance': 'Distancia de ruta',
  'centerOnArea': 'Centrar en este área',
  'centerOnLine': 'Centrar en esta línea',
  'centerOnLocation': 'Centrar en esta localización',
  'cancel': 'Cancelar',
  'delete': 'Eliminar',
  'acres': 'Acres',
  'feet': 'Pies',
  'kilometers': 'Kilómetros',
  'hectares': 'Hectáreas',
  'meters': 'Metros',
  'miles': 'Millas',
  'sqfeet': 'Pies cuadrados',
  'sqmeters': 'Metros cuadrados',
  'sqmiles': 'Millas cuadradas',
  'decPoint': '.',
  'thousandsSep': ' '
};

},{}],29:[function(require,module,exports){
// fr.js
// French i18n translations

module.exports = {
  'measure': 'Mesure',
  'measureDistancesAndAreas': 'Mesurer les distances et superficies',
  'createNewMeasurement': 'Créer une nouvelle mesure',
  'startCreating': 'Débuter la création d\'une nouvelle mesure en ajoutant des points sur la carte',
  'finishMeasurement': 'Finir la mesure',
  'lastPoint': 'Dernier point',
  'area': 'Superficie',
  'perimeter': 'Périmètre',
  'pointLocation': 'Placement du point',
  'areaMeasurement': 'Mesure de superficie',
  'linearMeasurement': 'Mesure linéaire',
  'pathDistance': 'Distance du chemin',
  'centerOnArea': 'Centrer sur cette zone',
  'centerOnLine': 'Centrer sur cette ligne',
  'centerOnLocation': 'Centrer à cet endroit',
  'cancel': 'Annuler',
  'delete': 'Supprimer',
  'acres': 'Acres',
  'feet': 'Pieds',
  'kilometers': 'Kilomètres',
  'hectares': 'Hectares',
  'meters': 'Mètres',
  'miles': 'Miles',
  'sqfeet': 'Pieds carrés',
  'sqmeters': 'Mètres carrés',
  'sqmiles': 'Miles carrés',
  'decPoint': ',',
  'thousandsSep': ' '
};

},{}],30:[function(require,module,exports){
// it.js
// Italian i18n translations

module.exports = {
  'measure': 'Misura',
  'measureDistancesAndAreas': 'Misura distanze e aree',
  'createNewMeasurement': 'Crea una nuova misurazione',
  'startCreating': 'Comincia a creare una misurazione aggiungendo punti alla mappa',
  'finishMeasurement': 'Misurazione conclusa',
  'lastPoint': 'Ultimo punto',
  'area': 'Area',
  'perimeter': 'Perimetro',
  'pointLocation': 'Posizione punto',
  'areaMeasurement': 'Misura area',
  'linearMeasurement': 'Misura lineare',
  'pathDistance': 'Distanza percorso',
  'centerOnArea': 'Centra su questa area',
  'centerOnLine': 'Centra su questa linea',
  'centerOnLocation': 'Centra su questa posizione',
  'cancel': 'Annulla',
  'delete': 'Cancella',
  'acres': 'Acri',
  'feet': 'Piedi',
  'kilometers': 'Chilometri',
  'hectares': 'Ettari',
  'meters': 'Metri',
  'miles': 'Miglia',
  'sqfeet': 'Piedi quadri',
  'sqmeters': 'Metri quadri',
  'sqmiles': 'Miglia quadre',
  'decPoint': '.',
  'thousandsSep': ','
};

},{}],31:[function(require,module,exports){
// nl.js
// Dutch i18n translations

module.exports = {
  'measure': 'Meet',
  'measureDistancesAndAreas': 'Meet afstanden en oppervlakten',
  'createNewMeasurement': 'Maak een nieuwe meting',
  'startCreating': 'Begin een meting door punten toe te voegen aan de kaart',
  'finishMeasurement': 'Beëindig meting',
  'lastPoint': 'Laatste punt',
  'area': 'Oppervlakte',
  'perimeter': 'Omtrek',
  'pointLocation': 'Locatie punt',
  'areaMeasurement': 'Oppervlakte meting',
  'linearMeasurement': 'Gemeten afstand',
  'pathDistance': 'Afstand over de lijn',
  'centerOnArea': 'Centreer op dit gebied',
  'centerOnLine': 'Centreer op deze lijn',
  'centerOnLocation': 'Centreer op deze locatie',
  'cancel': 'Annuleer',
  'delete': 'Wis',
  'acres': 'are',
  'feet': 'Voet',
  'kilometers': 'km',
  'hectares': 'ha',
  'meters': 'm',
  'miles': 'Mijl',
  'sqfeet': 'Vierkante Feet',
  'sqmeters': 'm2',
  'sqmiles': 'Vierkante Mijl',
  'decPoint': ',',
  'thousandsSep': '.'
};

},{}],32:[function(require,module,exports){
// pt_BR.js
// portuguese brazillian i18n translations

module.exports = {
  'measure': 'Medidas',
  'measureDistancesAndAreas': 'Mede distâncias e áreas',
  'createNewMeasurement': 'Criar nova medida',
  'startCreating': 'Comece criando uma medida, adicionando pontos no mapa',
  'finishMeasurement': 'Finalizar medida',
  'lastPoint': 'Último ponto',
  'area': 'Área',
  'perimeter': 'Perímetro',
  'pointLocation': 'Localização do ponto',
  'areaMeasurement': 'Medida de área',
  'linearMeasurement': 'Medida linear',
  'pathDistance': 'Distância',
  'centerOnArea': 'Centralizar nesta área',
  'centerOnLine': 'Centralizar nesta linha',
  'centerOnLocation': 'Centralizar nesta localização',
  'cancel': 'Cancelar',
  'delete': 'Excluir',
  'acres': 'Acres',
  'feet': 'Pés',
  'kilometers': 'Quilômetros',
  'hectares': 'Hectares',
  'meters': 'Metros',
  'miles': 'Milhas',
  'sqfeet': 'Pés²',
  'sqmeters': 'Metros²',
  'sqmiles': 'Milhas²',
  'decPoint': ',',
  'thousandsSep': '.'
};

},{}],33:[function(require,module,exports){
// en.js
// portuguese i18n translations

module.exports = {
  'measure': 'Medições',
  'measureDistancesAndAreas': 'Medir distâncias e áreas',
  'createNewMeasurement': 'Criar uma nova medição',
  'startCreating': 'Adicione pontos no mapa, para criar uma nova medição',
  'finishMeasurement': 'Finalizar medição',
  'lastPoint': 'Último ponto',
  'area': 'Área',
  'perimeter': 'Perímetro',
  'pointLocation': 'Localização do ponto',
  'areaMeasurement': 'Medição da área',
  'linearMeasurement': 'Medição linear',
  'pathDistance': 'Distância',
  'centerOnArea': 'Centrar nesta área',
  'centerOnLine': 'Centrar nesta linha',
  'centerOnLocation': 'Centrar nesta localização',
  'cancel': 'Cancelar',
  'delete': 'Eliminar',
  'acres': 'Acres',
  'feet': 'Pés',
  'kilometers': 'Kilômetros',
  'hectares': 'Hectares',
  'meters': 'Metros',
  'miles': 'Milhas',
  'sqfeet': 'Pés²',
  'sqmeters': 'Metros²',
  'sqmiles': 'Milhas²',
  'decPoint': ',',
  'thousandsSep': '.'
};


},{}],34:[function(require,module,exports){
// ru.js
// Russian i18n translations

module.exports = {
  'measure': 'Измерение',
  'measureDistancesAndAreas': 'Измерение расстояний и площади',
  'createNewMeasurement': 'Создать новое измерение',
  'startCreating': 'Для начала измерения добавьте точку на карту',
  'finishMeasurement': 'Закончить измерение',
  'lastPoint': 'Последняя точка',
  'area': 'Область',
  'perimeter': 'Периметр',
  'pointLocation': 'Местоположение точки',
  'areaMeasurement': 'Измерение области',
  'linearMeasurement': 'Линейное измерение',
  'pathDistance': 'Расстояние',
  'centerOnArea': 'Сфокусироваться на данной области',
  'centerOnLine': 'Сфокусироваться на данной линии',
  'centerOnLocation': 'Сфокусироваться на данной местности',
  'cancel': 'Отменить',
  'delete': 'Удалить',
  'acres': 'акры',
  'feet': 'фут',
  'kilometers': 'км',
  'hectares': 'га',
  'meters': 'м',
  'miles': 'миль',
  'sqfeet': 'футов²',
  'sqmeters': 'м²',
  'sqmiles': 'миль²',
  'decPoint': '.',
  'thousandsSep': ','
};

},{}],35:[function(require,module,exports){
// tr.js
// Turkish i18n translations

module.exports = {
  'measure': 'Hesapla',
  'measureDistancesAndAreas': 'Uzaklık ve alan hesapla',
  'createNewMeasurement': 'Yeni hesaplama',
  'startCreating': 'Yeni nokta ekleyerek hesaplamaya başla',
  'finishMeasurement': 'Hesaplamayı bitir',
  'lastPoint': 'Son nokta',
  'area': 'Alan',
  'perimeter': 'Çevre uzunluğu',
  'pointLocation': 'Nokta yeri',
  'areaMeasurement': 'Alan hesaplaması',
  'linearMeasurement': 'Doğrusal hesaplama',
  'pathDistance': 'Yol uzunluğu',
  'centerOnArea': 'Bu alana odaklan',
  'centerOnLine': 'Bu doğtuya odaklan',
  'centerOnLocation': 'Bu yere odaklan',
  'cancel': 'Çıkış',
  'delete': 'Sil',
  'acres': 'Dönüm',
  'feet': 'Feet',
  'kilometers': 'Kilometre',
  'hectares': 'Hektar',
  'meters': 'Metre',
  'miles': 'Mil',
  'sqfeet': 'Feet kare',
  'sqmeters': 'Metre kare',
  'sqmiles': 'Mil kare',
  'decPoint': '.',
  'thousandsSep': ','
};

},{}],36:[function(require,module,exports){
(function (global){
// leaflet-measure.js

var _ = require('underscore');
var L = (typeof window !== "undefined" ? window['L'] : typeof global !== "undefined" ? global['L'] : null);
var humanize = require('humanize');

var units = require('./units');
var calc = require('./calc');
var dom = require('./dom');
var $ = dom.$;

var Symbology = require('./mapsymbology');


var controlTemplate = _.template("<a class=\"<%= model.className %>-toggle js-toggle\" href=\"#\" title=\"<%= i18n.__('measureDistancesAndAreas') %>\"><%= i18n.__('measure') %></a>\n<div class=\"<%= model.className %>-interaction js-interaction\">\n  <div class=\"js-startprompt startprompt\">\n    <h3><%= i18n.__('measureDistancesAndAreas') %></h3>\n    <ul class=\"tasks\">\n      <a href=\"#\" class=\"js-start start\"><%= i18n.__('createNewMeasurement') %></a>\n    </ul>\n  </div>\n  <div class=\"js-measuringprompt\">\n    <h3><%= i18n.__('measureDistancesAndAreas') %></h3>\n    <p class=\"js-starthelp\"><%= i18n.__('startCreating') %></p>\n    <div class=\"js-results results\"></div>\n    <ul class=\"js-measuretasks tasks\">\n      <li><a href=\"#\" class=\"js-cancel cancel\"><%= i18n.__('cancel') %></a></li>\n      <li><a href=\"#\" class=\"js-finish finish\"><%= i18n.__('finishMeasurement') %></a></li>\n    </ul>\n  </div>\n</div>");
var resultsTemplate = _.template("<div class=\"group\">\n<p class=\"lastpoint heading\"><%= i18n.__('lastPoint') %></p>\n<p><%= model.lastCoord.dms.y %> <span class=\"coorddivider\">/</span> <%= model.lastCoord.dms.x %></p>\n<p><%= humanize.numberFormat(model.lastCoord.dd.y, 6) %> <span class=\"coorddivider\">/</span> <%= humanize.numberFormat(model.lastCoord.dd.x, 6) %></p>\n</div>\n<% if (model.pointCount > 1) { %>\n<div class=\"group\">\n<p><span class=\"heading\"><%= i18n.__('pathDistance') %></span> <%= model.lengthDisplay %></p>\n</div>\n<% } %>\n<% if (model.pointCount > 2) { %>\n<div class=\"group\">\n<p><span class=\"heading\"><%= i18n.__('area') %></span> <%= model.areaDisplay %></p>\n</div>\n<% } %>");
var pointPopupTemplate = _.template("<h3><%= i18n.__('pointLocation') %></h3>\n<p><%= model.lastCoord.dms.y %> <span class=\"coorddivider\">/</span> <%= model.lastCoord.dms.x %></p>\n<p><%= humanize.numberFormat(model.lastCoord.dd.y, 6) %> <span class=\"coorddivider\">/</span> <%= humanize.numberFormat(model.lastCoord.dd.x, 6) %></p>\n<ul class=\"tasks\">\n  <li><a href=\"#\" class=\"js-zoomto zoomto\"><%= i18n.__('centerOnLocation') %></a></li>\n  <li><a href=\"#\" class=\"js-deletemarkup deletemarkup\"><%= i18n.__('delete') %></a></li>\n</ul>");
var linePopupTemplate = _.template("<h3><%= i18n.__('linearMeasurement') %></h3>\n<p><%= model.lengthDisplay %></p>\n<ul class=\"tasks\">\n  <li><a href=\"#\" class=\"js-zoomto zoomto\"><%= i18n.__('centerOnLine') %></a></li>\n  <li><a href=\"#\" class=\"js-deletemarkup deletemarkup\"><%= i18n.__('delete') %></a></li>\n</ul>");
var areaPopupTemplate = _.template("<h3><%= i18n.__('areaMeasurement') %></h3>\n<p><%= model.areaDisplay %></p>\n<p><%= model.lengthDisplay %> <%= i18n.__('perimeter') %></p>\n<ul class=\"tasks\">\n  <li><a href=\"#\" class=\"js-zoomto zoomto\"><%= i18n.__('centerOnArea') %></a></li>\n  <li><a href=\"#\" class=\"js-deletemarkup deletemarkup\"><%= i18n.__('delete') %></a></li>\n</ul>");

var i18n = new (require('i18n-2'))({
  devMode: false,
  locales: {
    'cn': require('./i18n/cn'),
    'de': require('./i18n/de'),
    'en': require('./i18n/en'),
    'es': require('./i18n/es'),
    'fr': require('./i18n/fr'),
    'it': require('./i18n/it'),
    'nl': require('./i18n/nl'),
    'pt_BR': require('./i18n/pt_BR'),
    'pt_PT': require('./i18n/pt_PT'),
    'ru': require('./i18n/ru'),
    'tr': require('./i18n/tr')
  }
});

L.Control.Measure = L.Control.extend({
  _className: 'leaflet-control-measure',
  options: {
    units: {},
    position: 'topright',
    primaryLengthUnit: 'feet',
    secondaryLengthUnit: 'miles',
    primaryAreaUnit: 'acres',
    activeColor: '#ABE67E',     // base color for map features while actively measuring
    completedColor: '#C8F2BE',  // base color for permenant features generated from completed measure
    captureZIndex: 10000,       // z-index of the marker used to capture measure events
    popupOptions: {             // standard leaflet popup options http://leafletjs.com/reference.html#popup-options
      className: 'leaflet-measure-resultpopup',
      autoPanPadding: [10, 10]
    }
  },
  initialize: function (options) {
    L.setOptions(this, options);
    this.options.units = L.extend({}, units, this.options.units);
    this._symbols = new Symbology(_.pick(this.options, 'activeColor', 'completedColor'));
    i18n.setLocale(this.options.localization);
  },
  onAdd: function (map) {
    this._map = map;
    this._latlngs = [];
    this._initLayout();
    map.on('click', this._collapse, this);
    this._layer = L.layerGroup().addTo(map);
    return this._container;
  },
  onRemove: function (map) {
    map.off('click', this._collapse, this);
    map.removeLayer(this._layer);
  },
  _initLayout: function () {
    var className = this._className, container = this._container = L.DomUtil.create('div', className);
    var $toggle, $start, $cancel, $finish;

    container.innerHTML = controlTemplate({
      model: {
        className: className
      },
      i18n: i18n
    });

    // copied from leaflet
    // https://bitbucket.org/ljagis/js-mapbootstrap/src/4ab1e9e896c08bdbc8164d4053b2f945143f4f3a/app/components/measure/leaflet-measure-control.js?at=master#cl-30
    container.setAttribute('aria-haspopup', true);
    if (!L.Browser.touch) {
      L.DomEvent.disableClickPropagation(container);
      L.DomEvent.disableScrollPropagation(container);
    } else {
      L.DomEvent.on(container, 'click', L.DomEvent.stopPropagation);
    }

    $toggle = this.$toggle = $('.js-toggle', container);         // collapsed content
    this.$interaction = $('.js-interaction', container);         // expanded content
    $start = $('.js-start', container);                          // start button
    $cancel = $('.js-cancel', container);                        // cancel button
    $finish = $('.js-finish', container);                        // finish button
    this.$startPrompt = $('.js-startprompt', container);         // full area with button to start measurment
    this.$measuringPrompt = $('.js-measuringprompt', container); // full area with all stuff for active measurement
    this.$startHelp = $('.js-starthelp', container);             // "Start creating a measurement by adding points"
    this.$results = $('.js-results', container);                 // div with coordinate, linear, area results
    this.$measureTasks = $('.js-measuretasks', container);       // active measure buttons container

    this._collapse();
    this._updateMeasureNotStarted();

    if (!L.Browser.android) {
      L.DomEvent.on(container, 'mouseenter', this._expand, this);
      L.DomEvent.on(container, 'mouseleave', this._collapse, this);
    }
    L.DomEvent.on($toggle, 'click', L.DomEvent.stop);
    if (L.Browser.touch) {
      L.DomEvent.on($toggle, 'click', this._expand, this);
    } else {
      L.DomEvent.on($toggle, 'focus', this._expand, this);
    }
    L.DomEvent.on($start, 'click', L.DomEvent.stop);
    L.DomEvent.on($start, 'click', this._startMeasure, this);
    L.DomEvent.on($cancel, 'click', L.DomEvent.stop);
    L.DomEvent.on($cancel, 'click', this._finishMeasure, this);
    L.DomEvent.on($finish, 'click', L.DomEvent.stop);
    L.DomEvent.on($finish, 'click', this._handleMeasureDoubleClick, this);
  },
  _expand: function () {
    dom.hide(this.$toggle);
    dom.show(this.$interaction);
  },
  _collapse: function () {
    if (!this._locked) {
      dom.hide(this.$interaction);
      dom.show(this.$toggle);
    }
  },
  // move between basic states:
  // measure not started, started/in progress but no points added, in progress and with points
  _updateMeasureNotStarted: function () {
    dom.hide(this.$startHelp);
    dom.hide(this.$results);
    dom.hide(this.$measureTasks);
    dom.hide(this.$measuringPrompt);
    dom.show(this.$startPrompt);
  },
  _updateMeasureStartedNoPoints: function () {
    dom.hide(this.$results);
    dom.show(this.$startHelp);
    dom.show(this.$measureTasks);
    dom.hide(this.$startPrompt);
    dom.show(this.$measuringPrompt);
  },
  _updateMeasureStartedWithPoints: function () {
    dom.hide(this.$startHelp);
    dom.show(this.$results);
    dom.show(this.$measureTasks);
    dom.hide(this.$startPrompt);
    dom.show(this.$measuringPrompt);
  },
  // get state vars and interface ready for measure
  _startMeasure: function () {
    this._locked = true;
    this._measureVertexes = L.featureGroup().addTo(this._layer);
    this._captureMarker = L.marker(this._map.getCenter(), {
      clickable: true,
      zIndexOffset: this.options.captureZIndex,
      opacity: 0
    }).addTo(this._layer);
    this._setCaptureMarkerIcon();

    this._captureMarker
      .on('mouseout', this._handleMapMouseOut, this)
      .on('dblclick', this._handleMeasureDoubleClick, this)
      .on('click', this._handleMeasureClick, this);

    this._map
      .on('mousemove', this._handleMeasureMove, this)
      .on('mouseout', this._handleMapMouseOut, this)
      .on('move', this._centerCaptureMarker, this)
      .on('resize', this._setCaptureMarkerIcon, this);

    L.DomEvent.on(this._container, 'mouseenter', this._handleMapMouseOut, this);

    this._updateMeasureStartedNoPoints();

    this._map.fire('measurestart', null, false);
  },
  // return to state with no measure in progress, undo `this._startMeasure`
  _finishMeasure: function () {
    var model = _.extend({}, this._resultsModel, {
      points: this._latlngs
    });

    this._locked = false;

    L.DomEvent.off(this._container, 'mouseover', this._handleMapMouseOut, this);

    this._clearMeasure();

    this._captureMarker
      .off('mouseout', this._handleMapMouseOut, this)
      .off('dblclick', this._handleMeasureDoubleClick, this)
      .off('click', this._handleMeasureClick, this);

    this._map
      .off('mousemove', this._handleMeasureMove, this)
      .off('mouseout', this._handleMapMouseOut, this)
      .off('move', this._centerCaptureMarker, this)
      .off('resize', this._setCaptureMarkerIcon, this);

    this._layer
      .removeLayer(this._measureVertexes)
      .removeLayer(this._captureMarker);
    this._measureVertexes = null;

    this._updateMeasureNotStarted();
    this._collapse();

    this._map.fire('measurefinish', model, false);
  },
  // clear all running measure data
  _clearMeasure: function () {
    this._latlngs = [];
    this._resultsModel = null;
    this._measureVertexes.clearLayers();
    if (this._measureDrag) {
      this._layer.removeLayer(this._measureDrag);
    }
    if (this._measureArea) {
      this._layer.removeLayer(this._measureArea);
    }
    if (this._measureBoundary) {
      this._layer.removeLayer(this._measureBoundary);
    }
    this._measureDrag = null;
    this._measureArea = null;
    this._measureBoundary = null;
  },
  // centers the event capture marker
  _centerCaptureMarker: function () {
    this._captureMarker.setLatLng(this._map.getCenter());
  },
  // set icon on the capture marker
  _setCaptureMarkerIcon: function () {
    this._captureMarker.setIcon(L.divIcon({
      iconSize: this._map.getSize().multiplyBy(2)
    }));
  },
  // format measurements to nice display string based on units in options
  // `{ lengthDisplay: '100 Feet (0.02 Miles)', areaDisplay: ... }`
  _getMeasurementDisplayStrings: function (measurement) {
    var unitDefinitions = this.options.units;

    return {
      lengthDisplay: buildDisplay(measurement.length, this.options.primaryLengthUnit, this.options.secondaryLengthUnit, this.options.decPoint, this.options.thousandsSep),
      areaDisplay: buildDisplay(measurement.area, this.options.primaryAreaUnit, this.options.secondaryAreaUnit, this.options.decPoint, this.options.thousandsSep)
    };

    function buildDisplay (val, primaryUnit, secondaryUnit, decPoint, thousandsSep) {
      var display;
      if (primaryUnit && unitDefinitions[primaryUnit]) {
        display = formatMeasure(val, unitDefinitions[primaryUnit], decPoint, thousandsSep);
        if (secondaryUnit && unitDefinitions[secondaryUnit]) {
          display = display + ' (' +  formatMeasure(val, unitDefinitions[secondaryUnit], decPoint, thousandsSep) + ')';
        }
      } else {
        display = formatMeasure(val, null, decPoint, thousandsSep);
      }
      return display;
    }

    function formatMeasure (val, unit, decPoint, thousandsSep) {
      return unit && unit.factor && unit.display ?
        humanize.numberFormat(val * unit.factor, unit.decimals || 0, decPoint || i18n.__('decPoint'), thousandsSep || i18n.__('thousandsSep')) + ' ' + i18n.__([unit.display]) || unit.display :
        humanize.numberFormat(val, 0, decPoint || i18n.__('decPoint'), thousandsSep || i18n.__('thousandsSep'));
    }
  },
  // update results area of dom with calced measure from `this._latlngs`
  _updateResults: function () {
    var calced = calc.measure(this._latlngs);
    var resultsModel = this._resultsModel = _.extend({}, calced, this._getMeasurementDisplayStrings(calced), {
      pointCount: this._latlngs.length
    });
    this.$results.innerHTML = resultsTemplate({
      model: resultsModel,
      humanize: humanize,
      i18n: i18n
    });
  },
  // mouse move handler while measure in progress
  // adds floating measure marker under cursor
  _handleMeasureMove: function (evt) {
    if (!this._measureDrag) {
      this._measureDrag = L.circleMarker(evt.latlng, this._symbols.getSymbol('measureDrag')).addTo(this._layer);
    } else {
      this._measureDrag.setLatLng(evt.latlng);
    }
    this._measureDrag.bringToFront();
  },
  // handler for both double click and clicking finish button
  // do final calc and finish out current measure, clear dom and internal state, add permanent map features
  _handleMeasureDoubleClick: function () {
    var latlngs = this._latlngs, calced, resultFeature, popupContainer, popupContent, zoomLink, deleteLink;

    this._finishMeasure();

    if (!latlngs.length) {
      return;
    }

    if (latlngs.length > 2) {
      latlngs.push(_.first(latlngs)); // close path to get full perimeter measurement for areas
    }

    calced = calc.measure(latlngs);

    if (latlngs.length === 1) {
      resultFeature = L.circleMarker(latlngs[0], this._symbols.getSymbol('resultPoint'));
      popupContent = pointPopupTemplate({
        model: calced,
        humanize: humanize,
        i18n: i18n
      });
    } else if (latlngs.length === 2) {
      resultFeature = L.polyline(latlngs, this._symbols.getSymbol('resultLine'));
      popupContent = linePopupTemplate({
        model: _.extend({}, calced, this._getMeasurementDisplayStrings(calced)),
        humanize: humanize,
        i18n: i18n
      });
    } else {
      resultFeature = L.polygon(latlngs, this._symbols.getSymbol('resultArea'));
      popupContent = areaPopupTemplate({
        model: _.extend({}, calced, this._getMeasurementDisplayStrings(calced)),
        humanize: humanize,
        i18n: i18n
      });
    }

    popupContainer = L.DomUtil.create('div', '');
    popupContainer.innerHTML = popupContent;

    zoomLink = $('.js-zoomto', popupContainer);
    if (zoomLink) {
      L.DomEvent.on(zoomLink, 'click', L.DomEvent.stop);
      L.DomEvent.on(zoomLink, 'click', function () {
        this._map.fitBounds(resultFeature.getBounds(), {
          padding: [20, 20],
          maxZoom: 17
        });
      }, this);
    }

    deleteLink = $('.js-deletemarkup', popupContainer);
    if (deleteLink) {
      L.DomEvent.on(deleteLink, 'click', L.DomEvent.stop);
      L.DomEvent.on(deleteLink, 'click', function () {
        // TODO. maybe remove any event handlers on zoom and delete buttons?
        this._layer.removeLayer(resultFeature);
      }, this);
    }

    resultFeature.addTo(this._layer);
    resultFeature.bindPopup(popupContainer, this.options.popupOptions);
    resultFeature.openPopup(resultFeature.getBounds().getCenter());
  },
  // handle map click during ongoing measurement
  // add new clicked point, update measure layers and results ui
  _handleMeasureClick: function (evt) {
    var latlng = this._map.mouseEventToLatLng(evt.originalEvent), // get actual latlng instead of the marker's latlng from originalEvent
      lastClick = _.last(this._latlngs),
      vertexSymbol = this._symbols.getSymbol('measureVertex');

    if (!lastClick || !latlng.equals(lastClick)) { // skip if same point as last click, happens on `dblclick`
      this._latlngs.push(latlng);
      this._addMeasureArea(this._latlngs);
      this._addMeasureBoundary(this._latlngs);

      this._measureVertexes.eachLayer(function (layer) {
        layer.setStyle(vertexSymbol);
        // reset all vertexes to non-active class - only last vertex is active
        // `layer.setStyle({ className: 'layer-measurevertex'})` doesn't work. https://github.com/leaflet/leaflet/issues/2662
        // set attribute on path directly
        layer._path.setAttribute('class', vertexSymbol.className);
      });

      this._addNewVertex(latlng);

      if (this._measureBoundary) {
        this._measureBoundary.bringToFront();
      }
      this._measureVertexes.bringToFront();
    }

    this._updateResults();
    this._updateMeasureStartedWithPoints();
  },
  // handle map mouse out during ongoing measure
  // remove floating cursor vertex from map
  _handleMapMouseOut: function () {
    if (this._measureDrag) {
      this._layer.removeLayer(this._measureDrag);
      this._measureDrag = null;
    }
  },
  // add various measure graphics to map - vertex, area, boundary
  _addNewVertex: function (latlng) {
    L.circleMarker(latlng, this._symbols.getSymbol('measureVertexActive')).addTo(this._measureVertexes);
  },
  _addMeasureArea: function (latlngs) {
    if (latlngs.length < 3) {
      if (this._measureArea) {
        this._layer.removeLayer(this._measureArea);
        this._measureArea = null;
      }
      return;
    }
    if (!this._measureArea) {
      this._measureArea = L.polygon(latlngs, this._symbols.getSymbol('measureArea')).addTo(this._layer);
    } else {
      this._measureArea.setLatLngs(latlngs);
    }
  },
  _addMeasureBoundary: function (latlngs) {
    if (latlngs.length < 2) {
      if (this._measureBoundary) {
        this._layer.removeLayer(this._measureBoundary);
        this._measureBoundary = null;
      }
      return;
    }
    if (!this._measureBoundary) {
      this._measureBoundary = L.polyline(latlngs, this._symbols.getSymbol('measureBoundary')).addTo(this._layer);
    } else {
      this._measureBoundary.setLatLngs(latlngs);
    }
  }
});

L.Map.mergeOptions({
  measureControl: false
});

L.Map.addInitHook(function () {
  if (this.options.measureControl) {
    this.measureControl = (new L.Control.Measure()).addTo(this);
  }
});

L.control.measure = function (options) {
  return new L.Control.Measure(options);
};

}).call(this,typeof global !== "undefined" ? global : typeof self !== "undefined" ? self : typeof window !== "undefined" ? window : {})
},{"./calc":23,"./dom":24,"./i18n/cn":25,"./i18n/de":26,"./i18n/en":27,"./i18n/es":28,"./i18n/fr":29,"./i18n/it":30,"./i18n/nl":31,"./i18n/pt_BR":32,"./i18n/pt_PT":33,"./i18n/ru":34,"./i18n/tr":35,"./mapsymbology":37,"./units":38,"humanize":16,"i18n-2":18,"underscore":22}],37:[function(require,module,exports){
// mapsymbology.js

var _ = require('underscore');

var color = require('color');

var Symbology = function (options) {
  this.setOptions(options);
};

Symbology.DEFAULTS = {
  activeColor: '#ABE67E',    // base color for map features while actively measuring
  completedColor: '#C8F2BE'  // base color for permenant features generated from completed measure
};

_.extend(Symbology.prototype, {
  setOptions: function (options) {
    this._options = _.extend({}, Symbology.DEFAULTS, this._options, options);
    return this;
  },
  getSymbol: function (name) {
    var symbols = {
      measureDrag: {
        clickable: false,
        radius: 4,
        color: this._options.activeColor,
        weight: 2,
        opacity: 0.7,
        fillColor: this._options.activeColor,
        fillOpacity: 0.5,
        className: 'layer-measuredrag'
      },
      measureArea: {
        clickable: false,
        stroke: false,
        fillColor: this._options.activeColor,
        fillOpacity: 0.2,
        className: 'layer-measurearea'
      },
      measureBoundary: {
        clickable: false,
        color: this._options.activeColor,
        weight: 2,
        opacity: 0.9,
        fill: false,
        className: 'layer-measureboundary'
      },
      measureVertex: {
        clickable: false,
        radius: 4,
        color: this._options.activeColor,
        weight: 2,
        opacity: 1,
        fillColor: this._options.activeColor,
        fillOpacity: 0.7,
        className: 'layer-measurevertex'
      },
      measureVertexActive: {
        clickable: false,
        radius: 4,
        color: this._options.activeColor,
        weight: 2,
        opacity: 1,
        fillColor: color(this._options.activeColor).darken(0.15),
        fillOpacity: 0.7,
        className: 'layer-measurevertex active'
      },
      resultArea: {
        clickable: true,
        color: this._options.completedColor,
        weight: 2,
        opacity: 0.9,
        fillColor: this._options.completedColor,
        fillOpacity: 0.2,
        className: 'layer-measure-resultarea'
      },
      resultLine: {
        clickable: true,
        color: this._options.completedColor,
        weight: 3,
        opacity: 0.9,
        fill: false,
        className: 'layer-measure-resultline'
      },
      resultPoint: {
        clickable: true,
        radius: 4,
        color: this._options.completedColor,
        weight: 2,
        opacity: 1,
        fillColor: this._options.completedColor,
        fillOpacity: 0.7,
        className: 'layer-measure-resultpoint'
      }
    };
    return symbols[name];
  }
});

module.exports = Symbology;
},{"color":6,"underscore":22}],38:[function(require,module,exports){
// units.js
// Unit configurations
// Factor is with respect to meters/sqmeters

module.exports = {
  acres: {
    factor: 0.00024711,
    display: 'acres',
    decimals: 2
  },
  feet: {
    factor: 3.2808,
    display: 'feet',
    decimals: 0
  },
  kilometers: {
    factor: 0.001,
    display: 'kilometers',
    decimals: 2
  },
  hectares: {
    factor: 0.0001,
    display: 'hectares',
    decimals: 2
  },
  meters: {
    factor: 1,
    display: 'meters',
    decimals: 0
  },
  miles: {
    factor: 3.2808 / 5280,
    display: 'miles',
    decimals: 2
  },
  sqfeet: {
    factor: 10.7639,
    display: 'sqfeet',
    decimals: 0
  },
  sqmeters: {
    factor: 1,
    display: 'sqmeters',
    decimals: 0
  },
  sqmiles: {
    factor: 0.000000386102,
    display: 'sqmiles',
    decimals: 2
  }
};
},{}]},{},[36]);
