(function () {

  var Categories, Color, ColorScale, chromato, CSSColors, Ramp, root, type, _ref, _ref2, _ref3;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  root = typeof exports !== 'undefined' && exports !== null ? exports : this;

  chromato = (_ref = root.chromato) != null ? _ref : root.chromato = {};

  if (typeof module !== 'undefined' && module !== null) module.exports = chromato;

  Color = (function() {
    function Color(x, y, z, m) {
      var me, _ref2;
      me = this;
      if (!(x != null) && !(y != null) && !(z != null) && !(m != null)) {
        x = [255, 0, 255];
      }
      if (type(x) === 'array' && x.length === 3) {
        if (m == null) m = y;
        _ref2 = x, x = _ref2[0], y = _ref2[1], z = _ref2[2];
      }
      if (type(x) === 'string') {
        m = 'hex';
      } else {
        if (m == null) m = 'rgb';
      }
      if (m === 'rgb') {
        me.rgb = [x, y, z];
      } else if (m === 'hsl') {
        me.rgb = Color.hsl2rgb(x, y, z);
      } else if (m === 'hsv') {
        me.rgb = Color.hsv2rgb(x, y, z);
      } else if (m === 'hex') {
        me.rgb = Color.hex2rgb(x);
      } else if (m === 'lab') {
        me.rgb = Color.lab2rgb(x, y, z);
      } else if (m === 'hcl') {
        me.rgb = Color.hcl2rgb(x, y, z);
      } else if (m === 'hsi') {
        me.rgb = Color.hsi2rgb(x, y, z);
      }
    }

    Color.prototype.hex = function() {
      return Color.rgb2hex(this.rgb);
    };

    Color.prototype.toString = function() {
      return this.hex();
    };

    Color.prototype.hsl = function() {
      return Color.rgb2hsl(this.rgb);
    };

    Color.prototype.hsv = function() {
      return Color.rgb2hsv(this.rgb);
    };

    Color.prototype.lab = function() {
      return Color.rgb2lab(this.rgb);
    };

    Color.prototype.hcl = function() {
      return Color.rgb2hcl(this.rgb);
    };

    Color.prototype.hsi = function() {
      return Color.rgb2hsi(this.rgb);
    };

    Color.prototype.interpolate = function(f, col, m) {
      var dh, hue, hue0, hue1, lbv, lbv0, lbv1, me, sat, sat0, sat1, xyz0, xyz1;
      me = this;
      if (m == null) m = 'rgb';
      if (type(col) === 'string') col = new Color(col);
      if (m === 'hsl' || m === 'hsv' || m === 'hcl' || m === 'hsi') {
        if (m === 'hsl') {
          xyz0 = me.hsl();
          xyz1 = col.hsl();
        } else if (m === 'hsv') {
          xyz0 = me.hsv();
          xyz1 = col.hsv();
        } else if (m === 'hcl') {
          xyz0 = me.hcl();
          xyz1 = col.hcl();
        } else if (m === 'hsi') {
          xyz0 = me.hsi();
          xyz1 = col.hsi();
        }
        hue0 = xyz0[0], sat0 = xyz0[1], lbv0 = xyz0[2];
        hue1 = xyz1[0], sat1 = xyz1[1], lbv1 = xyz1[2];
        if (!isNaN(hue0) && !isNaN(hue1)) {
          if (hue1 > hue0 && hue1 - hue0 > 180) {
            dh = hue1 - (hue0 + 360);
          } else if (hue1 < hue0 && hue0 - hue1 > 180) {
            dh = hue1 + 360 - hue0;
          } else {
            dh = hue1 - hue0;
          }
          hue = hue0 + f * dh;
        } else if (!isNaN(hue0)) {
          hue = hue0;
          if (lbv1 === 1 || lbv1 === 0) sat = sat0;
        } else if (!isNaN(hue1)) {
          hue = hue1;
          if (lbv0 === 1 || lbv0 === 0) sat = sat1;
        } else {
          hue = void 0;
        }
        if (sat == null) sat = sat0 + f * (sat1 - sat0);
        lbv = lbv0 + f * (lbv1 - lbv0);
        return new Color(hue, sat, lbv, m);
      } else if (m === 'rgb') {
        xyz0 = me.rgb;
        xyz1 = col.rgb;
        return new Color(xyz0[0] + f * (xyz1[0] - xyz0[0]), xyz0[1] + f * (xyz1[1] - xyz0[1]), xyz0[2] + f * (xyz1[2] - xyz0[2]), m);
      } else if (m === 'lab') {
        xyz0 = me.lab();
        xyz1 = col.lab();
        return new Color(xyz0[0] + f * (xyz1[0] - xyz0[0]), xyz0[1] + f * (xyz1[1] - xyz0[1]), xyz0[2] + f * (xyz1[2] - xyz0[2]), m);
      } else {
        throw m + ' is not supported as a color mode';
      }
    };
    return Color;
  })();

  Color.hex2rgb = function(hex) {
    var b, g, r, u;
    if (!hex.match(/^#?([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$/)) {
      if ((chromato.colors != null) && chromato.colors[hex]) {
        hex = chromato.colors[hex];
      } else {
        throw 'This color format is unknown: ' + hex;
      }
    }
    if (hex.length === 4 || hex.length === 7) hex = hex.substr(1);
    if (hex.length === 3) {
      hex = hex[0] + hex[0] + hex[1] + hex[1] + hex[2] + hex[2];
    }
    u = parseInt(hex, 16);
    r = u >> 16;
    g = u >> 8 & 0xFF;
    b = u & 0xFF;
    return [r, g, b];
  };

  Color.rgb2hex = function(r, g, b) {
    var str, u, _ref2;
    if (r !== void 0 && r.length === 3) {
      _ref2 = r, r = _ref2[0], g = _ref2[1], b = _ref2[2];
    }
    u = r << 16 | g << 8 | b;
    str = '000000' + u.toString(16).toUpperCase();
    return '#' + str.substr(str.length - 6);
  };

  Color.hsv2rgb = function(h, s, v) {
    var b, f, g, i, l, p, q, r, t, _ref2, _ref3, _ref4, _ref5, _ref6, _ref7, _ref8;
    if (type(h) === 'array' && h.length === 3) {
      _ref2 = h, h = _ref2[0], s = _ref2[1], l = _ref2[2];
    }
    v *= 255;
    if (s === 0 && isNaN(h)) {
      r = g = b = v;
    } else {
      if (h === 360) h = 0;
      if (h > 360) h -= 360;
      if (h < 0) h += 360;
      h /= 60;
      i = Math.floor(h);
      f = h - i;
      p = v * (1 - s);
      q = v * (1 - s * f);
      t = v * (1 - s * (1 - f));
      switch (i) {
        case 0:
          _ref3 = [v, t, p], r = _ref3[0], g = _ref3[1], b = _ref3[2];
          break;
        case 1:
          _ref4 = [q, v, p], r = _ref4[0], g = _ref4[1], b = _ref4[2];
          break;
        case 2:
          _ref5 = [p, v, t], r = _ref5[0], g = _ref5[1], b = _ref5[2];
          break;
        case 3:
          _ref6 = [p, q, v], r = _ref6[0], g = _ref6[1], b = _ref6[2];
          break;
        case 4:
          _ref7 = [t, p, v], r = _ref7[0], g = _ref7[1], b = _ref7[2];
          break;
        case 5:
          _ref8 = [v, p, q], r = _ref8[0], g = _ref8[1], b = _ref8[2];
      }
    }
    r = Math.round(r);
    g = Math.round(g);
    b = Math.round(b);
    return [r, g, b];
  };

  Color.rgb2hsv = function(r, g, b) {
    var delta, h, max, min, s, v, _ref2;
    if (r !== void 0 && r.length === 3) {
      _ref2 = r, r = _ref2[0], g = _ref2[1], b = _ref2[2];
    }
    min = Math.min(r, g, b);
    max = Math.max(r, g, b);
    delta = max - min;
    v = max / 255.0;
    s = delta / max;
    if (s === 0) {
      h = void 0;
      s = 0;
    } else {
      if (r === max) h = (g - b) / delta;
      if (g === max) h = 2 + (b - r) / delta;
      if (b === max) h = 4 + (r - g) / delta;
      h *= 60;
      if (h < 0) h += 360;
    }
    return [h, s, v];
  };

  Color.hsl2rgb = function(h, s, l) {
    var b, c, g, i, r, t1, t2, t3, _ref2, _ref3;
    if (h !== void 0 && h.length === 3) {
      _ref2 = h, h = _ref2[0], s = _ref2[1], l = _ref2[2];
    }
    if (s === 0) {
      r = g = b = l * 255;
    } else {
      t3 = [0, 0, 0];
      c = [0, 0, 0];
      t2 = l < 0.5 ? l * (1 + s) : l + s - l * s;
      t1 = 2 * l - t2;
      h /= 360;
      t3[0] = h + 1 / 3;
      t3[1] = h;
      t3[2] = h - 1 / 3;
      for (i = 0; i <= 2; i++) {
        if (t3[i] < 0) t3[i] += 1;
        if (t3[i] > 1) t3[i] -= 1;
        if (6 * t3[i] < 1) {
          c[i] = t1 + (t2 - t1) * 6 * t3[i];
        } else if (2 * t3[i] < 1) {
          c[i] = t2;
        } else if (3 * t3[i] < 2) {
          c[i] = t1 + (t2 - t1) * ((2 / 3) - t3[i]) * 6;
        } else {
          c[i] = t1;
        }
      }
      _ref3 = [Math.round(c[0] * 255), Math.round(c[1] * 255), Math.round(c[2] * 255)], r = _ref3[0], g = _ref3[1], b = _ref3[2];
    }
    return [r, g, b];
  };

  Color.rgb2hsl = function(r, g, b) {
    var h, l, max, min, s, _ref2;
    if (r !== void 0 && r.length === 3) {
      _ref2 = r, r = _ref2[0], g = _ref2[1], b = _ref2[2];
    }
    r /= 255;
    g /= 255;
    b /= 255;
    min = Math.min(r, g, b);
    max = Math.max(r, g, b);
    l = (max + min) / 2;
    if (max === min) {
      s = 0;
      h = void 0;
    } else {
      s = l < 0.5 ? (max - min) / (max + min) : (max - min) / (2 - max - min);
    }
    if (r === max) {
      h = (g - b) / (max - min);
    } else if (g === max) {
      h = 2 + (b - r) / (max - min);
    } else if (b === max) {
      h = 4 + (r - g) / (max - min);
    }
    h *= 60;
    if (h < 0) h += 360;
    return [h, s, l];
  };

  Color.lab2xyz = function(l, a, b) {
    var finv, ill, sl, x, y, z, _ref2;
    if (type(l) === 'array' && l.length === 3) {
      _ref2 = l, l = _ref2[0], a = _ref2[1], b = _ref2[2];
    }
    finv = function(t) {
      if (t > (6.0 / 29.0)) {
        return t * t * t;
      } else {
        return 3 * (6.0 / 29.0) * (6.0 / 29.0) * (t - 4.0 / 29.0);
      }
    };
    sl = (l + 0.16) / 1.16;
    ill = [0.96421, 1.00000, 0.82519];
    y = ill[1] * finv(sl);
    x = ill[0] * finv(sl + (a / 5.0));
    z = ill[2] * finv(sl - (b / 2.0));
    return [x, y, z];
  };

  Color.xyz2rgb = function(x, y, z) {
    var b, bl, clip, correct, g, gl, r, rl, _ref2, _ref3;
    if (type(x) === 'array' && x.length === 3) {
      _ref2 = x, x = _ref2[0], y = _ref2[1], z = _ref2[2];
    }
    rl = 3.2406 * x - 1.5372 * y - 0.4986 * z;
    gl = -0.9689 * x + 1.8758 * y + 0.0415 * z;
    bl = 0.0557 * x - 0.2040 * y + 1.0570 * z;
    clip = Math.min(rl, gl, bl) < -0.001 || Math.max(rl, gl, bl) > 1.001;
    if (clip) {
      rl = rl < 0.0 ? 0.0 : rl > 1.0 ? 1.0 : rl;
      gl = gl < 0.0 ? 0.0 : gl > 1.0 ? 1.0 : gl;
      bl = bl < 0.0 ? 0.0 : bl > 1.0 ? 1.0 : bl;
    }
    if (clip) {
      _ref3 = [void 0, void 0, void 0], rl = _ref3[0], gl = _ref3[1], bl = _ref3[2];
    }
    correct = function(cl) {
      var a;
      a = 0.055;
      if (cl <= 0.0031308) {
        return 12.92 * cl;
      } else {
        return (1 + a) * Math.pow(cl, 1 / 2.4) - a;
      }
    };
    r = Math.round(255.0 * correct(rl));
    g = Math.round(255.0 * correct(gl));
    b = Math.round(255.0 * correct(bl));
    return [r, g, b];
  };

  Color.lab2rgb = function(l, a, b) {
    var x, y, z, _ref2, _ref3, _ref4;
    if (l !== void 0 && l.length === 3) {
      _ref2 = l, l = _ref2[0], a = _ref2[1], b = _ref2[2];
    }
    if (l !== void 0 && l.length === 3) {
      _ref3 = l, l = _ref3[0], a = _ref3[1], b = _ref3[2];
    }
    _ref4 = Color.lab2xyz(l, a, b), x = _ref4[0], y = _ref4[1], z = _ref4[2];
    return Color.xyz2rgb(x, y, z);
  };

  Color.hcl2lab = function(c, s, l) {
    var L, tau_const, a, angle, b, r, _ref2;
    if (type(c) === 'array' && c.length === 3) {
      _ref2 = c, c = _ref2[0], s = _ref2[1], l = _ref2[2];
    }
    c /= 360.0;
    tau_const = 6.283185307179586476925287;
    L = l * 0.61 + 0.09;
    angle = tau_const / 6.0 - c * tau_const;
    r = (l * 0.311 + 0.125) * s;
    a = Math.sin(angle) * r;
    b = Math.cos(angle) * r;
    return [L, a, b];
  };

  Color.hcl2rgb = function(c, s, l) {
    var L, a, b, _ref2;
    _ref2 = Color.hcl2lab(c, s, l), L = _ref2[0], a = _ref2[1], b = _ref2[2];
    return Color.lab2rgb(L, a, b);
  };

  Color.rgb2xyz = function(r, g, b) {
    var bl, correct, gl, rl, x, y, z, _ref2;
    if (r !== void 0 && r.length === 3) {
      _ref2 = r, r = _ref2[0], g = _ref2[1], b = _ref2[2];
    }
    correct = function(c) {
      var a;
      a = 0.055;
      if (c <= 0.04045) {
        return c / 12.92;
      } else {
        return Math.pow((c + a) / (1 + a), 2.4);
      }
    };
    rl = correct(r / 255.0);
    gl = correct(g / 255.0);
    bl = correct(b / 255.0);
    x = 0.4124 * rl + 0.3576 * gl + 0.1805 * bl;
    y = 0.2126 * rl + 0.7152 * gl + 0.0722 * bl;
    z = 0.0193 * rl + 0.1192 * gl + 0.9505 * bl;
    return [x, y, z];
  };

  Color.xyz2lab = function(x, y, z) {
    var a, b, f, ill, l, _ref2;
    if (x !== void 0 && x.length === 3) {
      _ref2 = x, x = _ref2[0], y = _ref2[1], z = _ref2[2];
    }
    ill = [0.96421, 1.00000, 0.82519];
    f = function(t) {
      if (t > Math.pow(6.0 / 29.0, 3)) {
        return Math.pow(t, 1 / 3);
      } else {
        return (1 / 3) * (29 / 6) * (29 / 6) * t + 4.0 / 29.0;
      }
    };
    l = 1.16 * f(y / ill[1]) - 0.16;
    a = 5 * (f(x / ill[0]) - f(y / ill[1]));
    b = 2 * (f(y / ill[1]) - f(z / ill[2]));
    return [l, a, b];
  };

  Color.rgb2lab = function(r, g, b) {
    var x, y, z, _ref2, _ref3;
    if (r !== void 0 && r.length === 3) {
      _ref2 = r, r = _ref2[0], g = _ref2[1], b = _ref2[2];
    }
    _ref3 = Color.rgb2xyz(r, g, b), x = _ref3[0], y = _ref3[1], z = _ref3[2];
    return Color.xyz2lab(x, y, z);
  };

  Color.lab2hcl = function(l, a, b) {
    var L, tau_const, angle, c, r, s, _ref2;
    if (type(l) === 'array' && l.length === 3) {
      _ref2 = l, l = _ref2[0], a = _ref2[1], b = _ref2[2];
    }
    L = l;
    l = (l - 0.09) / 0.61;
    r = Math.sqrt(a * a + b * b);
    s = r / (l * 0.311 + 0.125);
    tau_const = 6.283185307179586476925287;
    angle = Math.atan2(a, b);
    c = (tau_const / 6 - angle) / tau_const;
    c *= 360;
    if (c < 0) c += 360;
    return [c, s, l];
  };

  Color.rgb2hcl = function(r, g, b) {
    var a, l, _ref2, _ref3;
    if (type(r) === 'array' && r.length === 3) {
      _ref2 = r, r = _ref2[0], g = _ref2[1], b = _ref2[2];
    }
    _ref3 = Color.rgb2lab(r, g, b), l = _ref3[0], a = _ref3[1], b = _ref3[2];
    return Color.lab2hcl(l, a, b);
  };

  Color.rgb2hsi = function(r, g, b) {
    var pi_const_x2, h, i, min, s, _ref2;
    if (type(r) === 'array' && r.length === 3) {
      _ref2 = r, r = _ref2[0], g = _ref2[1], b = _ref2[2];
    }
    pi_const_x2 = Math.PI * 2;
    r /= 255;
    g /= 255;
    b /= 255;
    min = Math.min(r, g, b);
    i = (r + g + b) / 3;
    s = 1 - min / i;
    if (s === 0) {
      h = 0;
    } else {
      h = ((r - g) + (r - b)) / 2;
      h /= Math.sqrt((r - g) * (r - g) + (r - b) * (g - b));
      h = Math.acos(h);
      if (b > g) h = pi_const_x2 - h;
      h /= pi_const_x2;
    }
    return [h * 360, s, i];
  };

  Color.hsi2rgb = function(h, s, i) {
    var pi_const_div3, pi_const_x2, b, cos, g, r, _ref2;
    if (type(h) === 'array' && h.length === 3) {
      _ref2 = h, h = _ref2[0], s = _ref2[1], i = _ref2[2];
    }
    pi_const_x2 = Math.PI * 2;
    pi_const_div3 = Math.PI / 3;
    cos = Math.cos;
    if (h < 0) h += 360;
    if (h > 360) h -= 360;
    h /= 360;
    if (h < 1 / 3) {
      b = (1 - s) / 3;
      r = (1 + s * cos(pi_const_x2 * h) / cos(pi_const_div3 - pi_const_x2 * h)) / 3;
      g = 1 - (b + r);
    } else if (h < 2 / 3) {
      h -= 1 / 3;
      r = (1 - s) / 3;
      g = (1 + s * cos(pi_const_x2 * h) / cos(pi_const_div3 - pi_const_x2 * h)) / 3;
      b = 1 - (r + g);
    } else {
      h -= 2 / 3;
      g = (1 - s) / 3;
      b = (1 + s * cos(pi_const_x2 * h) / cos(pi_const_div3 - pi_const_x2 * h)) / 3;
      r = 1 - (g + b);
    }
    r = i * r * 3;
    g = i * g * 3;
    b = i * b * 3;
    return [r * 255, g * 255, b * 255];
  };

  chromato.Color = Color;

  chromato.hsl = function(h, s, l) {
    return new Color(h, s, l, 'hsl');
  };

  chromato.hsv = function(h, s, v) {
    return new Color(h, s, v, 'hsv');
  };

  chromato.rgb = function(r, g, b) {
    return new Color(r, g, b, 'rgb');
  };

  chromato.hex = function(x) {
    return new Color(x);
  };

  chromato.lab = function(l, a, b) {
    return new Color(l, a, b, 'lab');
  };

  chromato.hcl = function(c, s, l) {
    return new Color(c, s, l, 'hcl');
  };

  chromato.hsi = function(h, s, i) {
    return new Color(h, s, i, 'hsi');
  };

  chromato.interpolate = function(a, b, f, m) {
    if (type(a) === 'string') a = new Color(a);
    if (type(b) === 'string') b = new Color(b);
    return a.interpolate(f, b, m);
  };

  ColorScale = (function() {

    function ColorScale(opts) {
      var c, col, cols, me, _ref2, _ref3, _ref4, _ref5, _ref6, _ref7;
      me = this;
      me.colors = cols = (_ref2 = opts.colors) != null ? _ref2 : ['#ddd', '#222'];
      for (c = 0, _ref3 = cols.length - 1; 0 <= _ref3 ? c <= _ref3 : c >= _ref3; 0 <= _ref3 ? c++ : c--) {
        col = cols[c];
        if (type(col) === 'string') cols[c] = new Color(col);
      }
      if (opts.positions != null) {
        me.pos = opts.positions;
      } else {
        me.pos = [];
        for (c = 0, _ref4 = cols.length - 1; 0 <= _ref4 ? c <= _ref4 : c >= _ref4; 0 <= _ref4 ? c++ : c--) {
          me.pos.push(c / (cols.length - 1));
        }
      }
      me.mode = (_ref5 = opts.mode) != null ? _ref5 : 'hsv';
      me.nacol = (_ref6 = opts.nacol) != null ? _ref6 : '#ccc';
      me.setClasses((_ref7 = opts.limits) != null ? _ref7 : [0, 1]);
      me;
    }

    ColorScale.prototype.getColor = function(value) {
      var c, f, f0, me;
      me = this;
      if (isNaN(value)) return me.nacol;
      if (me.classLimits.length > 2) {
        c = me.getClass(value);
        f = c / (me.numClasses - 1);
      } else {
        f = f0 = (value - me.min) / (me.max - me.min);
        f = Math.min(1, Math.max(0, f));
      }
      return me.fColor(f);
    };

    ColorScale.prototype.fColor = function(f) {
      var col, cols, i, me, p, _ref2;
      me = this;
      cols = me.colors;
      for (i = 0, _ref2 = me.pos.length - 1; 0 <= _ref2 ? i <= _ref2 : i >= _ref2; 0 <= _ref2 ? i++ : i--) {
        p = me.pos[i];
        if (f <= p) {
          col = cols[i];
          break;
        }
        if (f >= p && i === me.pos.length - 1) {
          col = cols[i];
          break;
        }
        if (f > p && f < me.pos[i + 1]) {
          f = (f - p) / (me.pos[i + 1] - p);
          col = chromato.interpolate(cols[i], cols[i + 1], f, me.mode);
          break;
        }
      }
      return col;
    };

    ColorScale.prototype.classifyValue = function(value) {
      var i, limits, maxc, minc, n, self;
      self = this;
      limits = self.classLimits;
      if (limits.length > 2) {
        n = limits.length - 1;
        i = self.getClass(value);
        value = limits[i] + (limits[i + 1] - limits[i]) * 0.5;
        minc = limits[0];
        maxc = limits[n - 1];
        value = self.min + ((value - minc) / (maxc - minc)) * (self.max - self.min);
      }
      return value;
    };

    ColorScale.prototype.setClasses = function(limits) {
      var me;
      if (limits == null) limits = [];
      me = this;
      me.classLimits = limits;
      me.min = limits[0];
      me.max = limits[limits.length - 1];
      if (limits.length === 2) {
        return me.numClasses = 0;
      } else {
        return me.numClasses = limits.length - 1;
      }
    };

    ColorScale.prototype.getClass = function(value) {
      var i, limits, n, self;
      self = this;
      limits = self.classLimits;
      if (limits != null) {
        n = limits.length - 1;
        i = 0;
        while (i < n && value >= limits[i]) {
          i++;
        }
        return i - 1;
      }
    };

    ColorScale.prototype.validValue = function(value) {
      return !isNaN(value);
    };
    return ColorScale;
  })();

  chromato.ColorScale = ColorScale;

  Ramp = (function() {
    __extends(Ramp, ColorScale);

    function Ramp(col0, col1, mode) {
      if (col0 == null) col0 = '#fe0000';
      if (col1 == null) col1 = '#feeeee';
      if (mode == null) mode = 'hsl';
      Ramp.__super__.constructor.call(this, [col0, col1], [0, 1], mode);
    }
    return Ramp;
  })();

  chromato.Ramp = Ramp;

  Categories = (function() {
    __extends(Categories, ColorScale);

    function Categories(colors) {
      var me;
      me = this;
      me.colors = colors;
    }

    Categories.prototype.parseData = function(data, data_col) {};

    Categories.prototype.getColor = function(value) {
      var me;
      me = this;
      if (me.colors.hasOwnProperty(value)) {
        return me.colors[value];
      } else {
        return '#cccccc';
      }
    };

    Categories.prototype.validValue = function(value) {
      return this.colors.hasOwnProperty(value);
    };
    return Categories;
  })();

  chromato.Categories = Categories;

  CSSColors = (function() {
    __extends(CSSColors, ColorScale);

    function CSSColors(name) {
      var me;
      me = this;
      me.name = name;
      me.setClasses(7);
      me;
    }

    CSSColors.prototype.getColor = function(value) {
      var c, me;
      me = this;
      c = me.getClass(value);
      return me.name + ' l' + me.numClasses + ' c' + c;
    };

    return CSSColors;
  })();

  chromato.CSSColors = CSSColors;

  if ((_ref2 = chromato.scales) == null) chromato.scales = {};

  chromato.limits = function(data, mode, num, prop) {
    var assignments, best, centroids, cluster, clusterSizes, dist, i, j, k, kClusters, limits, max, min, mindist, n, nb_iters, newCentroids, p, pb, pr, repeat, row, sum, tmpKMeansBreaks, val, value, values, _i, _j, _k, _len, _len2, _len3, _ref10, _ref11, _ref12, _ref13, _ref14, _ref15, _ref16, _ref3, _ref4, _ref5, _ref6, _ref7, _ref8, _ref9;
    if (mode == null) mode = 'equal';
    if (num == null) num = 7;
    if (prop == null) prop = null;
    min = Number.MAX_VALUE;
    max = Number.MAX_VALUE * -1;
    sum = 0;
    values = [];
    if (type(data) === 'array') {
      if (type(data[0]) !== 'object' && type(data[0]) !== 'array') {
        for (_i = 0, _len = data.length; _i < _len; _i++) {
          val = data[_i];
          if (!isNaN(val)) values.push(Number(val));
        }
      } else {
        for (_j = 0, _len2 = data.length; _j < _len2; _j++) {
          row = data[_j];
          values.push(Number(row[prop]));
        }
      }
    } else if (type(data) === 'object') {
      for (k in data) {
        val = data[k];
        if (type(val) === 'object' && type(prop) === 'string') {
          if (!isNaN(val[prop])) values.push(Number(val[prop]));
        } else if (type(val) === 'array' && type(prop) === 'number') {
          if (!isNaN(val[prop])) values.push(Number(val[prop]));
        } else if (type(val) === 'number') {
          if (!isNaN(val)) values.push(Number(val));
        }
      }
    }
    for (_k = 0, _len3 = values.length; _k < _len3; _k++) {
      val = values[_k];
      if (!!isNaN(val)) continue;
      if (val < min) min = val;
      if (val > max) max = val;
      sum += val;
    }
    values = values.sort(function(a, b) {
      return a - b;
    });
    limits = [];
    if (mode.substr(0, 1) === 'c') {
      limits.push(min);
      limits.push(max);
    }
    if (mode.substr(0, 1) === 'e') {
      limits.push(min);
      for (i = 1, _ref3 = num - 1; 1 <= _ref3 ? i <= _ref3 : i >= _ref3; 1 <= _ref3 ? i++ : i--) {
        limits.push(min + (i / num) * (max - min));
      }
      limits.push(max);
    } else if (mode.substr(0, 1) === 'q') {
      limits.push(min);
      for (i = 1, _ref4 = num - 1; 1 <= _ref4 ? i <= _ref4 : i >= _ref4; 1 <= _ref4 ? i++ : i--) {
        p = values.length * i / num;
        pb = Math.floor(p);
        if (pb === p) {
          limits.push(values[pb]);
        } else {
          pr = p - pb;
          limits.push(values[pb] * pr + values[pb + 1] * (1 - pr));
        }
      }
      limits.push(max);
    } else if (mode.substr(0, 1) === 'k') {
      n = values.length;
      assignments = new Array(n);
      clusterSizes = new Array(num);
      repeat = true;
      nb_iters = 0;
      centroids = null;
      centroids = [];
      centroids.push(min);
      for (i = 1, _ref5 = num - 1; 1 <= _ref5 ? i <= _ref5 : i >= _ref5; 1 <= _ref5 ? i++ : i--) {
        centroids.push(min + (i / num) * (max - min));
      }
      centroids.push(max);
      while (repeat) {
        for (j = 0, _ref6 = num - 1; 0 <= _ref6 ? j <= _ref6 : j >= _ref6; 0 <= _ref6 ? j++ : j--) {
          clusterSizes[j] = 0;
        }
        for (i = 0, _ref7 = n - 1; 0 <= _ref7 ? i <= _ref7 : i >= _ref7; 0 <= _ref7 ? i++ : i--) {
          value = values[i];
          mindist = Number.MAX_VALUE;
          for (j = 0, _ref8 = num - 1; 0 <= _ref8 ? j <= _ref8 : j >= _ref8; 0 <= _ref8 ? j++ : j--) {
            dist = Math.abs(centroids[j] - value);
            if (dist < mindist) {
              mindist = dist;
              best = j;
            }
          }
          clusterSizes[best]++;
          assignments[i] = best;
        }
        newCentroids = new Array(num);
        for (j = 0, _ref9 = num - 1; 0 <= _ref9 ? j <= _ref9 : j >= _ref9; 0 <= _ref9 ? j++ : j--) {
          newCentroids[j] = null;
        }
        for (i = 0, _ref10 = n - 1; 0 <= _ref10 ? i <= _ref10 : i >= _ref10; 0 <= _ref10 ? i++ : i--) {
          cluster = assignments[i];
          if (newCentroids[cluster] === null) {
            newCentroids[cluster] = values[i];
          } else {
            newCentroids[cluster] += values[i];
          }
        }
        for (j = 0, _ref11 = num - 1; 0 <= _ref11 ? j <= _ref11 : j >= _ref11; 0 <= _ref11 ? j++ : j--) {
          newCentroids[j] *= 1 / clusterSizes[j];
        }
        repeat = false;
        for (j = 0, _ref12 = num - 1; 0 <= _ref12 ? j <= _ref12 : j >= _ref12; 0 <= _ref12 ? j++ : j--) {
          if (newCentroids[j] !== centroids[i]) {
            repeat = true;
            break;
          }
        }
        centroids = newCentroids;
        nb_iters++;
        if (nb_iters > 200) repeat = false;
      }
      kClusters = {};
      for (j = 0, _ref13 = num - 1; 0 <= _ref13 ? j <= _ref13 : j >= _ref13; 0 <= _ref13 ? j++ : j--) {
        kClusters[j] = [];
      }
      for (i = 0, _ref14 = n - 1; 0 <= _ref14 ? i <= _ref14 : i >= _ref14; 0 <= _ref14 ? i++ : i--) {
        cluster = assignments[i];
        kClusters[cluster].push(values[i]);
      }
      tmpKMeansBreaks = [];
      for (j = 0, _ref15 = num - 1; 0 <= _ref15 ? j <= _ref15 : j >= _ref15; 0 <= _ref15 ? j++ : j--) {
        tmpKMeansBreaks.push(kClusters[j][0]);
        tmpKMeansBreaks.push(kClusters[j][kClusters[j].length - 1]);
      }
      tmpKMeansBreaks = tmpKMeansBreaks.sort(function(a, b) {
        return a - b;
      });
      limits.push(tmpKMeansBreaks[0]);
      for (i = 1, _ref16 = tmpKMeansBreaks.length - 1; i <= _ref16; i += 2) {
        if (!isNaN(tmpKMeansBreaks[i])) limits.push(tmpKMeansBreaks[i]);
      }
    }
    return limits;
  };

  root = typeof exports !== 'undefined' && exports !== null ? exports : this;

  type = (function() {
    var classToType, name, _i, _len, _ref3;
    classToType = {};
    _ref3 = 'Boolean Number String Function Array Date RegExp Undefined Null'.split(' ');
    for (_i = 0, _len = _ref3.length; _i < _len; _i++) {
      name = _ref3[_i];
      classToType['[object ' + name + ']'] = name.toLowerCase();
    }
    return function(obj) {
      var strType;
      strType = Object.prototype.toString.call(obj);
      return classToType[strType] || 'object';
    };
  })();

  if ((_ref3 = root.type) == null) root.type = type;

  Array.max = function(array) {
    return Math.max.apply(Math, array);
  };

  Array.min = function(array) {
    return Math.min.apply(Math, array);
  };

}).call(this);

var createPalette = {
	generate: function(colorsCount, checkColor, forceMode, quality, ultra_precision){
		if(colorsCount === undefined)
			colorsCount = 8;
		if(checkColor === undefined)
			checkColor = function(x){return true;};
		if(forceMode === undefined)
			forceMode = false;
		if(quality === undefined)
			quality = 50;
		ultra_precision = ultra_precision || false

		if(forceMode){
			var colors = [];
			function checkLab(lab){
				var color = chromato.lab(lab[0], lab[1], lab[2]);
				return !isNaN(color.rgb[0]) && color.rgb[0] >= 0 && color.rgb[1] >= 0 && color.rgb[2] >= 0 && color.rgb[0] < 256 && color.rgb[1] < 256 && color.rgb[2] < 256 && checkColor(color);
			}
			
			var vectors = {};
			for(i = 0; i < colorsCount; i++){
				var color = [Math.random(), 2 * Math.random() - 1, 2 * Math.random() - 1];
				while(!checkLab(color)){
					color = [Math.random(), 2 * Math.random() - 1, 2 * Math.random() - 1];
				}
				colors.push(color);
			}

			var repulsion = 0.3;
			var speed = 0.05;
			var steps = quality * 20;
			while(steps-- > 0){
				for(i = 0; i < colors.length; i++){
					vectors[i] = {dl:0, da:0, db:0};
				}
				for(i = 0; i < colors.length; i++){
					var color_a = colors[i];
					for(j = 0; j < i; j++){
						var color_b = colors[j];
						var dl = color_a[0] - color_b[0];
						var da = color_a[1] - color_b[1];
						var db = color_a[2] - color_b[2];
						var d = Math.sqrt(Math.pow(dl, 2) + Math.pow(da, 2) + Math.pow(db, 2));
						if(d > 0){
							var force = repulsion / Math.pow(d, 2);
							vectors[i].dl += dl * force / d;
							vectors[i].da += da * force / d;
							vectors[i].db += db * force / d;
							vectors[j].dl -= dl * force / d;
							vectors[j].da -= da * force / d;
							vectors[j].db -= db * force / d;
						} else {
							vectors[j].dl += 0.02 - 0.04 * Math.random();
							vectors[j].da += 0.02 - 0.04 * Math.random();
							vectors[j].db += 0.02 - 0.04 * Math.random();
						}
					}
				}
				for(i = 0; i < colors.length; i++){
					var color = colors[i];
					var displacement = speed * Math.sqrt(Math.pow(vectors[i].dl, 2) + Math.pow(vectors[i].da, 2) + Math.pow(vectors[i].db, 2));
					if(displacement>0){
						var ratio = speed * Math.min(0.1, displacement)/displacement;
						candidateLab = [color[0] + vectors[i].dl * ratio, color[1] + vectors[i].da * ratio, color[2] + vectors[i].db * ratio];
						if(checkLab(candidateLab)){
							colors[i] = candidateLab;
						}
					}
				}
			}
			return colors.map(function(lab){return chromato.lab(lab[0], lab[1], lab[2]);});
		} else {
			function checkColor2(color){
				var lab = color.lab();
				var hcl = color.hcl();
				return !isNaN(color.rgb[0]) && color.rgb[0] >= 0 && color.rgb[1] >= 0 && color.rgb[2] >= 0 && color.rgb[0]<256 && color.rgb[1]<256 && color.rgb[2]<256 && checkColor(color);
			}
			var kMeans = [];
			for(i = 0; i < colorsCount; i++){
				var lab = [Math.random(), 2 * Math.random() - 1, 2 * Math.random() - 1];
				while(!checkColor2(chromato.lab(lab))){
					lab = [Math.random(), 2 * Math.random() - 1, 2 * Math.random() - 1];
				}
				kMeans.push(lab);
			}
			var colorSamples = [];
			var samplesClosest = [];
			if(ultra_precision){
				for(l = 0; l <= 1; l += 0.01){
					for(a =- 1; a <= 1; a += 0.05){
						for(b =- 1; b <= 1; b += 0.05){
							if(checkColor2(chromato.lab(l, a, b))){
								colorSamples.push([l, a, b]);
								samplesClosest.push(null);
							}
						}
					}
				}
			} else {
				for(l = 0; l <= 1; l += 0.05){
					for(a =- 1; a <= 1; a += 0.1){
						for(b =- 1; b <= 1; b += 0.1){
							if(checkColor2(chromato.lab(l, a, b))){
								colorSamples.push([l, a, b]);
								samplesClosest.push(null);
							}
						}
					}
				}
			}
			var steps = quality;
			while(steps-- > 0){
				for(i = 0; i < colorSamples.length; i++){
					var lab = colorSamples[i];
					var min_dist = 1000000;
					for(j = 0; j < kMeans.length; j++){
						var kMean = kMeans[j];
						var distance = Math.sqrt(Math.pow(lab[0] - kMean[0], 2) + Math.pow(lab[1]-kMean[1], 2) + Math.pow(lab[2] - kMean[2], 2));
						if(distance < min_dist){
							min_dist = distance;
							samplesClosest[i] = j;
						}
					}
				}
				var freeColorSamples = colorSamples.slice(0);
				for(j = 0; j < kMeans.length; j++){
					var count = 0;
					var candidateKMean = [0, 0, 0];
					for(i = 0; i < colorSamples.length; i++){
						if(samplesClosest[i] == j){
							count++;
							candidateKMean[0] += colorSamples[i][0];
							candidateKMean[1] += colorSamples[i][1];
							candidateKMean[2] += colorSamples[i][2];
						}
					}
					if(count != 0){
						candidateKMean[0] /= count;
						candidateKMean[1] /= count;
						candidateKMean[2] /= count;
					}
					if(count != 0 && checkColor2(chromato.lab(candidateKMean[0], candidateKMean[1], candidateKMean[2])) && candidateKMean){
						kMeans[j] = candidateKMean;
					} else {
						if(freeColorSamples.length>0){
							var min_dist = 10000000000;
							var closest = -1;
							for(i = 0; i<freeColorSamples.length; i++){
								var distance = Math.sqrt(Math.pow(freeColorSamples[i][0] - candidateKMean[0], 2) + Math.pow(freeColorSamples[i][1] - candidateKMean[1], 2) + Math.pow(freeColorSamples[i][2] - candidateKMean[2], 2));
								if(distance < min_dist){
									min_dist = distance;
									closest = i;
								}
							}
							kMeans[j] = colorSamples[closest];
						} else {
							var min_dist = 10000000000;
							var closest = -1;
							for(i = 0; i < colorSamples.length; i++){
								var distance = Math.sqrt(Math.pow(colorSamples[i][0] - candidateKMean[0], 2) + Math.pow(colorSamples[i][1]-candidateKMean[1], 2) + Math.pow(colorSamples[i][2] - candidateKMean[2], 2));
								if(distance < min_dist){
									min_dist = distance;
									closest = i;
								}
							}
							kMeans[j] = colorSamples[closest];
						}
					}
					freeColorSamples = freeColorSamples.filter(function(color){
						return color[0] != kMeans[j][0]
							|| color[1] != kMeans[j][1]
							|| color[2] != kMeans[j][2];
					});
				}
			}
			return kMeans.map(function(lab){return chromato.lab(lab[0], lab[1], lab[2]);});
		}
	},

	diffSort: function(colorsToSort){
		var diffColors = [colorsToSort.shift()];
		while(colorsToSort.length > 0){
			var index = -1;
			var maxDistance = -1;
			for(candidate_index = 0; candidate_index < colorsToSort.length; candidate_index++){
				var d = 1000000000;
				for(i = 0; i < diffColors.length; i++){
					var color_a = colorsToSort[candidate_index].lab();
					var color_b = diffColors[i].lab();
					var dl = color_a[0] - color_b[0];
					var da = color_a[1] - color_b[1];
					var db = color_a[2] - color_b[2];
					d = Math.min(d, Math.sqrt(Math.pow(dl, 2)+Math.pow(da, 2)+Math.pow(db, 2)));
				}
				if(d > maxDistance){
					maxDistance = d;
					index = candidate_index;
				}
			}
			var color = colorsToSort[index];
			diffColors.push(color);
			colorsToSort = colorsToSort.filter(function(c,i){return i != index;});
		}
		return diffColors;
	}
}
