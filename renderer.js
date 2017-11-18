// This file is required by the index.html file and will
// be executed in the renderer process for that window.
// All of the Node.js APIs are available in this process.

var fb_size = { x: 1000, y: 1000 };

var gl;

function initGL(canvas) {
    try {
        // Disable default framebuffer's AA because we will do MSAA on a separate framebuffer, 
        //  then blit it over to default. The 'blit' requires destination to be not multisampled.
        gl = canvas.getContext("webgl2", { antialias: false });        
        gl.viewportWidth = canvas.width;
        gl.viewportHeight = canvas.height;
        fb_size.x = canvas.width;
        fb_size.y = canvas.height;
    } catch (e) {
    }
    if (!gl) {
        alert("GRBG: could not initialise WebGL2. ");
    }
    console.log(gl);
    const ext = gl.getExtension("EXT_color_buffer_float");
    if (!ext) {
      alert("need EXT_color_buffer_float");
      return;
    }
    const ext2 = gl.getExtension("OES_texture_float_linear");
    if(!ext) { 
        alert("grbg, cannot filter textures....") }
}

function checkShaderCompileStatus(shader)
{
    if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
        alert(gl.getShaderInfoLog(shader));
        return null;
    }
    return shader;
}

function getShader(gl, id) {
    var shaderScript = document.getElementById(id);
    if (!shaderScript) {
        return null;
    }

    var str = "";
    var k = shaderScript.firstChild;
    while (k) {
        if (k.nodeType == 3) {
            str += k.textContent;
        }
        k = k.nextSibling;
    }

    var shader;
    if (shaderScript.type == "x-shader/x-fragment") {
        shader = gl.createShader(gl.FRAGMENT_SHADER);
    } else if (shaderScript.type == "x-shader/x-vertex") {
        shader = gl.createShader(gl.VERTEX_SHADER);
    } else {
        return null;
    }

    gl.shaderSource(shader, str);
    gl.compileShader(shader);

    return checkShaderCompileStatus(shader);
}

var shaderProgram_Light;

var Shaderz = require('./shaders.js');
let LightInfo = new Shaderz.lightInfo();

function initAdvancedShaders()
{    
    var fs = gl.createShader(gl.FRAGMENT_SHADER);
    var vs = gl.createShader(gl.VERTEX_SHADER);

    var src = Shaderz.lightShaders();

    LightInfo.initFramebuffer(gl);

    gl.shaderSource(fs, src.fs);
    gl.compileShader(fs);
    checkShaderCompileStatus(fs);
    
    gl.shaderSource(vs, src.vs);
    gl.compileShader(vs);
    checkShaderCompileStatus(vs);
    
    shaderProgram_Light = gl.createProgram();
    gl.attachShader(shaderProgram_Light, vs);
    gl.attachShader(shaderProgram_Light, fs);
    gl.linkProgram(shaderProgram_Light);

    if (!gl.getProgramParameter(shaderProgram_Light, gl.LINK_STATUS)) {
        alert("Could not initialise shaders");
    }
    gl.useProgram(shaderProgram_Light);
    
    shaderProgram_Light.vertexPositionAttribute = gl.getAttribLocation(shaderProgram_Light, "position");
    console.log(shaderProgram_Light.vertexPositionAttribute);
    gl.enableVertexAttribArray(shaderProgram_Light.vertexPositionAttribute);

    shaderProgram_Light.pMatrixUniform = gl.getUniformLocation(shaderProgram_Light, "vp_matrix");
    shaderProgram_Light.mMatrixUniform = gl.getUniformLocation(shaderProgram_Light, "model");
}

var shaderProgram;

function initShaders() 
{
    // TODO: separate shaders for 'ground' with just vertex positions as input,
    // and possibly something with light position.

    var fragmentShader = getShader(gl, "shader-fs");
    var vertexShader = getShader(gl, "shader-vs");

    shaderProgram = gl.createProgram();
    gl.attachShader(shaderProgram, vertexShader);
    gl.attachShader(shaderProgram, fragmentShader);
    gl.linkProgram(shaderProgram);

    if (!gl.getProgramParameter(shaderProgram, gl.LINK_STATUS)) {
        alert("Could not initialise shaders");
    }

    gl.useProgram(shaderProgram);

    shaderProgram.vertexPositionAttribute = gl.getAttribLocation(shaderProgram, "aVertexPosition");
    gl.enableVertexAttribArray(shaderProgram.vertexPositionAttribute);

    shaderProgram.vertexColorAttribute = gl.getAttribLocation(shaderProgram, "aVertexColor");
    gl.enableVertexAttribArray(shaderProgram.vertexColorAttribute);
    
    shaderProgram.pMatrixUniform      = gl.getUniformLocation(shaderProgram, "uPMatrix");
    shaderProgram.mMatrixUniform      = gl.getUniformLocation(shaderProgram, "uMMatrix");
    shaderProgram.vMatrixUniform      = gl.getUniformLocation(shaderProgram, "uVMatrix");
    shaderProgram.shadowMatrixUniform = gl.getUniformLocation(shaderProgram, "shadow_matrix");
}


let viewMatrix = mat4.create();
let pMatrix = mat4.create();

function setMatrixUniforms(model, view, projection,options) {
    if(!options.fromLight) {
        //console.log("setting non-light matrices...");
        gl.uniformMatrix4fv(shaderProgram.pMatrixUniform, false,  projection);//pMatrix);    
        gl.uniformMatrix4fv(shaderProgram.mMatrixUniform, false,  model);
        gl.uniformMatrix4fv(shaderProgram.vMatrixUniform, false,  view);
    } else {
        gl.uniformMatrix4fv(shaderProgram_Light.mMatrixUniform, false,  model);
        gl.uniformMatrix4fv(shaderProgram_Light.pMatrixUniform, false,  LightInfo.light_vp_matrix);
    }
}


function degToRad(degrees) {
    return degrees * Math.PI / 180;
}




var rPyramid = 0;
var rCube = 0;

const MD = require('./models.js');
console.log(MD);
let mm   = new MD.Models(gl);

function _drawPyramid(options) {        
    setMatrixUniforms(mm.pyramidModelMatrix, viewMatrix, pMatrix, options);
    gl.bindBuffer(gl.ARRAY_BUFFER, mm.pyramidVertexPositionBuffer);
    gl.vertexAttribPointer(shaderProgram.vertexPositionAttribute, mm.pyramidVertexPositionBuffer.itemSize,gl.FLOAT, false, 0, 0);
    gl.bindBuffer(gl.ARRAY_BUFFER, mm.pyramidVertexColorBuffer);
    gl.vertexAttribPointer(shaderProgram.vertexColorAttribute, mm.pyramidVertexColorBuffer.itemSize,gl.FLOAT, false, 0, 0);    
    gl.drawArrays(gl.TRIANGLES, 0, mm.pyramidVertexPositionBuffer.numItems);    
}


function _drawCube(options) {    
    
    setMatrixUniforms(mm.cubeModelMatrix, viewMatrix, pMatrix, options);
    gl.bindBuffer(gl.ARRAY_BUFFER, mm.cubeVertexPositionBuffer);
    gl.vertexAttribPointer(shaderProgram.vertexPositionAttribute, mm.cubeVertexPositionBuffer.itemSize,gl.FLOAT, false, 0, 0);
    gl.bindBuffer(gl.ARRAY_BUFFER, mm.cubeVertexColorBuffer);
    gl.vertexAttribPointer(shaderProgram.vertexColorAttribute, mm.cubeVertexColorBuffer.itemSize,gl.FLOAT, false, 0, 0);
    gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, mm.cubeVertexIndexBuffer);
    gl.drawElements(gl.TRIANGLES, mm.cubeVertexIndexBuffer.numItems, gl.UNSIGNED_SHORT, 0);        
}

function _drawFloor(options) {    
    gl.bindBuffer(gl.ARRAY_BUFFER, mm.floorVertexPositionBuffer);
    gl.vertexAttribPointer(shaderProgram.vertexPositionAttribute, mm.floorVertexPositionBuffer.itemSize, gl.FLOAT, false, 0, 0);
    gl.bindBuffer(gl.ARRAY_BUFFER, mm.floorVertexColorBuffer);
    gl.vertexAttribPointer(shaderProgram.vertexColorAttribute, mm.floorVertexColorBuffer.itemSize,gl.FLOAT, false, 0, 0);    
    setMatrixUniforms(mm.floorModelMatrix, viewMatrix, pMatrix, options);
    gl.drawArrays(gl.TRIANGLES, 0, mm.floorVertexPositionBuffer.numItems);
}

function drawScene(options) {
    
    mm.resetModelMatrices();
    mm.setPyramidModelMatrix(degToRad(rPyramid));                           
    mm.setCubeModelMatrix(degToRad(rCube));

    if(options.fromLight === true) { // Draw from light's point of view, into a depth buffer. 
        //console.log("LIGHT stage ... fb = " + LightInfo.lightFramebuffer);
        gl.bindFramebuffer(gl.FRAMEBUFFER, LightInfo.lightFramebuffer);
        gl.viewport(0, 0, LightInfo.texSize, LightInfo.texSize);        
        gl.useProgram(shaderProgram_Light);        
        gl.uniformMatrix4fv(shaderProgram_Light.pMatrixUniform, false, LightInfo.light_vp_matrix);
    } else {        
        //console.log("VIEW stage ... fb = " + LightInfo.viewFrameBuffer);
        //Wtf, bind FB here doesn't work !? gl.bindFramebuffer(gl.FRAMEBUFFER, LightInfo.viewFramebuffer);
        gl.useProgram(shaderProgram);        
        gl.viewport(0, 0, gl.viewportWidth, gl.viewportHeight);
        pMatrix  = mat4.perspective(45, gl.viewportWidth / gl.viewportHeight, 0.1, 100.0);
        viewMatrix = mat4.lookAt([-0.0, -0.0, 8.0],
                               [0.0,0.0,0.0], [0.0,1.0,0.0]);
        gl.uniformMatrix4fv(shaderProgram.shadowMatrixUniform, false, LightInfo.light_vp_matrix);
        gl.activeTexture(gl.TEXTURE0);
        gl.bindTexture(gl.TEXTURE_2D, LightInfo.depth_tex);
    }
    
    gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);

    _drawFloor(options); 
    
    _drawPyramid(options);

    _drawCube(options);
}


var lastTime = 0;

function animate() {
    var timeNow = new Date().getTime();
    if (lastTime != 0) {
        var elapsed = timeNow - lastTime;
        if ((1 > 0) || elapsed % 5000 < 2500) {
            rPyramid += 0.5;
            rCube -= 0.7;
        }
    } else
        lastTime = timeNow;
}

var tickCount = 0;

function tick() {

    {
        gl.bindFramebuffer(gl.FRAMEBUFFER, LightInfo.lightFrameBuffer);
        gl.enable(gl.DEPTH_TEST);
        gl.clearDepth(1.0);
        gl.clearColor(0.0, 0.0, 0.0, 0.5);
        drawScene({fromLight: true});
    }

    gl.bindFramebuffer(gl.FRAMEBUFFER, LightInfo.viewFrameBuffer);
    if(LightInfo.viewFrameBuffer !== framebuffer_id) {
        alert('invalid framebuffer state!?'); }
        
    gl.enable(gl.DEPTH_TEST);
    gl.clearColor(0.0, 0.0, 0.0, 0.5);
    drawScene({fromLight: false});

    gl.bindFramebuffer(gl.READ_FRAMEBUFFER, framebuffer_id);
    gl.bindFramebuffer(gl.DRAW_FRAMEBUFFER, null);
    gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);

    gl.blitFramebuffer(
        0, 0, fb_size.x, fb_size.y,
        0, 0, fb_size.x, fb_size.y,
        gl.COLOR_BUFFER_BIT, gl.LINEAR);
    gl.blitFramebuffer(
        0, 0, fb_size.x, fb_size.y,
        0, 0, fb_size.x, fb_size.y,
        gl.DEPTH_BUFFER_BIT, gl.NEAREST);


    gl.bindFramebuffer(gl.FRAMEBUFFER, null);


    animate();

    tickCount++;

    requestAnimFrame(tick);
}



var framebuffer_id = null;

function initFramebuffer() {

    // What factor of MSAA we will use. 
    var N_msaa = 8;

    // Create new Renderbuffer and tag it as MSAA
    var colorRenderbuffer = gl.createRenderbuffer();
    gl.bindRenderbuffer(gl.RENDERBUFFER, colorRenderbuffer);
    gl.renderbufferStorageMultisample(gl.RENDERBUFFER, N_msaa, gl.RGBA8, fb_size.x, fb_size.y);

    var depthRenderbuffer = gl.createRenderbuffer();
    gl.bindRenderbuffer(gl.RENDERBUFFER, depthRenderbuffer);
    gl.renderbufferStorageMultisample(gl.RENDERBUFFER, N_msaa, gl.DEPTH24_STENCIL8, fb_size.x, fb_size.y);

    // Create and bind new Framebuffer
    framebuffer_id = gl.createFramebuffer();
    gl.bindFramebuffer(gl.FRAMEBUFFER, framebuffer_id);

    // Slap the MSAA'd Renderbuffer onto the just-made Framebuffer
    gl.framebufferRenderbuffer(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, gl.RENDERBUFFER, colorRenderbuffer);
    gl.framebufferRenderbuffer(gl.FRAMEBUFFER, gl.DEPTH_ATTACHMENT, gl.RENDERBUFFER, depthRenderbuffer);

    // Restore default Framebuffer to not myrus up the state. 
    gl.bindFramebuffer(gl.FRAMEBUFFER, null);

    LightInfo.viewFrameBuffer = framebuffer_id;
}

function webGLStart() {
    var canvas = document.getElementById("lesson04-canvas");
    initGL(canvas);
    initShaders();
    initAdvancedShaders();
    mm.initBuffers(gl);

    initFramebuffer();

    gl.clearColor(0.0, 0.0, 0.0, 1.0);
    gl.enable(gl.DEPTH_TEST);

    console.log("  vendor: ", gl.getParameter(gl.VENDOR),
        "  version: ", gl.getParameter(gl.VERSION),
        "  glsl_version: ", gl.getParameter(gl.SHADING_LANGUAGE_VERSION));

    tick();
}


webGLStart();
