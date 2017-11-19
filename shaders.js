let checkStatus = function() 
{
    let status = gl.checkFramebufferStatus(gl.FRAMEBUFFER);
    console.log('fb complete = ' + gl.FRAMEBUFFER_COMPLETE);
    console.log('fb incomplete attachment = ' + gl.FRAMEBUFFER_INCOMPLETE_ATTACHMENT);
    console.log(status);     
    if( status !== gl.FRAMEBUFFER_COMPLETE) {
        alert('framebuffer attachment status is myrus\'d up! '); }
}
    
module.exports.lightInfo = function() {
    
    this.lightPosition = [1.0,1.0,4.0];
    this.depth_tex = {};
    this.depth_tex_debug = {};
    this.light_proj_matrix = {};
    this.light_view_matrix = {};
    this.viewFramebuffer = {}; // the non-"light" framebuffer
    this.lightFramebuffer = {}; // the non-"light" framebuffer
    this.texSize = 1000;

    this.initFramebuffer = function(gl) 
    {        
        const targetTextureWidth  = this.texSize;
        const targetTextureHeight = this.texSize;
        const targetTexture = gl.createTexture();
        gl.bindTexture(gl.TEXTURE_2D, targetTexture);
        this.depth_tex = targetTexture;
        
        {
            const level = 0;
            const internalFormat = gl.DEPTH_COMPONENT32F;
            const width  = targetTextureWidth;
            const height = targetTextureHeight;
            const border = 0;
            const format = gl.DEPTH_COMPONENT;
            const type   = gl.FLOAT;
            const data   = new Float32Array(width*height);
            gl.texImage2D(gl.TEXTURE_2D, level, internalFormat, width, height, border,
                        format, type, data);
        }

        // define size and format
        //const level = 3;
        //const internalFormat = gl.R32F;                                
        //gl.texStorage2D(gl.TEXTURE_2D, level, internalFormat,
        //                targetTextureWidth, targetTextureHeight);
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
        if(1)
            gl.framebufferTexture2D(gl.FRAMEBUFFER, gl.DEPTH_ATTACHMENT,
                                gl.TEXTURE_2D, this.depth_tex, 0);
        
        {
            const debugTexture = gl.createTexture();
            gl.bindTexture(gl.TEXTURE_2D, debugTexture);
            this.depth_debug_tex = debugTexture;            
            {        
                const level = 0;
                const internalFormat = gl.RGBA8;//gl.RGBA32F;
                const width  = targetTextureWidth;
                const height = targetTextureHeight;
                const border = 0;
                const format = gl.RGBA;
                const type   = gl.UNSIGNED_BYTE;//gl.FLOAT;
                const data   = null;//new Float32Array(width*height*4);
                gl.texImage2D(gl.TEXTURE_2D, level, internalFormat, width, height, border,
                            format, type, data);
            }
            /*gl.texStorage2D(gl.TEXTURE_2D, 1, gl.R32F,
                            targetTextureWidth, targetTextureHeight);             */
            gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER,   gl.LINEAR);
            gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER,   gl.LINEAR);            
            gl.framebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, 
                                    gl.TEXTURE_2D, this.depth_debug_tex, 0);
            gl.drawBuffers([gl.COLOR_ATTACHMENT0]);
            checkStatus();            
        }

        {
            this.light_proj_matrix = mat4.frustum(-1.0,1.0,-1.0,1.0,1.0,200.0);
            this.light_view_matrix = mat4.lookAt(this.lightPosition,
                                                 [0.0,0.0,0.0], [0.0,1.0,0.0]);         
            this.light_vp_matrix   = mat4.multiply(this.light_proj_matrix,this.light_view_matrix);
            this.shadow_vp_matrix  = mat4.multiply(this.light_proj_matrix,this.light_view_matrix);
            console.log(this.light_vp_matrix);
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

module.exports.lightShaders = function() {
    return {
        vs: 
        `#version 300 es
        precision mediump float;
        uniform mat4 vp_matrix;
        uniform mat4 model;
        
        layout (location = 0) in vec3 position;
        layout (location = 1) in vec4 color;
        
        void main(void)
        {
            gl_Position = vp_matrix * model * vec4(position,1.0);
        }
        `,
        fs:
        `#version 300 es
        precision mediump float;
        layout (location = 0) out vec4 color;
        
        void main(void)
        {
            // note: for debug purposes, we have also mapped 
            // colorattachment0 to the framebuffer now assumed to be bound.
            float zval = gl_FragCoord.z;
            color = vec4(zval, gl_FragCoord.x,gl_FragCoord.y,1.0);
            
        }`
    };
}