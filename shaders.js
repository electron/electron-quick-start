module.exports.lightInfo = function() {
    
    this.lightPosition = [5.0,5.0,5.0];
    this.depth_tex = {};
    this.depth_tex_debug = {};

    this.initFramebuffer = function(gl) 
    {        
        const targetTextureWidth  = 512;
        const targetTextureHeight = 512;
        const targetTexture = gl.createTexture();
        gl.bindTexture(gl.TEXTURE_2D, targetTexture);
        this.depth_tex = targetTexture;
        
        // define size and format
        const level = 3;
        const internalFormat = gl.R32F;                                
        gl.texStorage2D(gl.TEXTURE_2D, level, internalFormat,
                        targetTextureWidth, targetTextureHeight);
        //api ref: 
        // void gl.texStorage2D(target, levels, internalformat, width, height);
        
        // set the filtering so we don't need mips
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER,   gl.LINEAR);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER,   gl.LINEAR);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_COMPARE_MODE, 
                         gl.COMPARE_REF_TO_TEXTURE);
        gl.texParameteri(gl.TEXTURE_2D, 
                         gl.TEXTURE_COMPARE_FUNC, gl.LEQUAL);

        // create a framebuffer for light grbg.
        this.lightFramebuffer = gl.createFramebuffer();
        gl.bindFramebuffer(gl.FRAMEBUFFER, this.lightFramebuffer);

        // attach the texture as the first color attachment        
        gl.framebufferTexture2D(gl.FRAMEBUFFER, gl.DEPTH_ATTACHMENT,
                                gl.TEXTURE_2D, this.depth_tex, 0);

        {
            const debugTexture = gl.createTexture();
            gl.bindTexture(gl.TEXTURE_2D, debugTexture);
            this.depth_debug_tex = debugTexture;            
            gl.texStorage2D(gl.TEXTURE_2D, 1, gl.R32F,
                            targetTextureWidth, targetTextureHeight);            
            gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER,   gl.LINEAR);
            gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER,   gl.LINEAR);            
            gl.framebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, 
                                    gl.TEXTURE_2D, this.depth_debug_tex, 0);
        }
        
    }


    
}

module.exports.screenQuadShaders = function() {
    return { 
        vs : `#version 300 es

        layout(location = 0) in vec4 position;
        layout(location = 1) in vec2 texcoord;

        out vec2 UV;

        void main() {
        gl_Position = position;
        UV = texcoord;
        }`,
        fs :
        `#version 300 es

        precision mediump float;

        in vec2 UV;

        uniform sampler2D u_texture;

        out vec4 fragColor;

        void main() {
            fragColor = texture(u_texture, UV);
        }`
        };
}

module.exports.floorShaders = function() {
    return { 
        vs : 
        `#version 300 es

        layout(location = 0) in vec3 position;
        
        uniform mat4 uMVMatrix;
        uniform mat4 uPMatrix;

        out vec2 UV;

        void main() {
        gl_Position = uPMatrix * uMVMatrix * vec4(position, 1.0);
        UV = (position.xy*0.5) + vec2(0.5);
        }`,
        fs :
        `#version 300 es

        precision mediump float;

        in vec2 UV;

        //uniform sampler2D u_texture;

        out vec4 fragColor;

        void main() {
            fragColor = vec4(UV.x, UV.y, 1.0, 1.0);
                 //texture(u_texture, UV);
        }`
        };
}