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