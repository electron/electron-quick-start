module.exports = {
    Models: function(gl) {
        
        this.gl = gl;
        this.pyramidVertexPositionBuffer = 0;
        this.pyramidVertexColorBuffer = 0;
        this.cubeVertexPositionBuffer = 0;
        this.cubeVertexColorBuffer = 0;
        this.cubeVertexIndexBuffer = 0;
        
        this.floorVertexPositionBuffer = 0;
        this.floorVertexColorBuffer    = 0;
        
        this.pyramidModelMatrix        = mat4.create(); 
        this.cubeModelMatrix           = mat4.create();
        this.floorModelMatrix          = mat4.create();

        this.resetModelMatrices = function() {
             mat4.identity(this.pyramidModelMatrix);
             mat4.identity(this.cubeModelMatrix   );
             mat4.identity(this.floorModelMatrix  );
        }

        this.setPyramidModelMatrix = function(rads) {
            mat4.identity(this.pyramidModelMatrix);
            mat4.translate(this.pyramidModelMatrix, [-2.0, 0.0, 0.0]);
            mat4.rotate(this.pyramidModelMatrix, degToRad(20), [1, 0, 0]);
            mat4.rotate(this.pyramidModelMatrix, rads, [0, 1, 0]);
        }

        this.setCubeModelMatrix = function(rads) {
            mat4.identity(this.cubeModelMatrix);
            mat4.translate(this.cubeModelMatrix, [2.0, 0.0, 0.0]);
            mat4.rotate(this.cubeModelMatrix, rads, [1, 0, 0]);
            mat4.rotate(this.cubeModelMatrix, rads, [0, 1, 0]);            
        }
        
        this.resetModelMatrices();
        
        this.initBuffers = function(gl) {
            this.gl = gl;
            console.log(gl);

            this.floorVertexPositionBuffer = gl.createBuffer();
            gl.bindBuffer(gl.ARRAY_BUFFER, this.floorVertexPositionBuffer);
            {
                let vertices = [
                    -9.0, -9.0, -4.0,
                     9.0, -9.0, -4.0,
                    -9.0,  9.0, -4.0, 
                     9.0,  9.0, -4.0,
                    -9.0,  9.0, -4.0,
                     9.0, -9.0, -4.0 
                ]
                gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(vertices), gl.STATIC_DRAW);
            }
            
            this.floorVertexPositionBuffer.itemSize = 3;
            this.floorVertexPositionBuffer.numItems = 6;

            {
                this.floorVertexColorBuffer = gl.createBuffer();
                gl.bindBuffer(gl.ARRAY_BUFFER, this.floorVertexColorBuffer);
                let colors = [
                    //  face 1
                    0.0, 0.5, 0.5, 1.0,
                    0.0, 1.0, 0.0, 1.0,
                    0.0, 0.0, 1.0, 1.0,
            
                    //  face 2
                    1.0, 1.0, 1.0, 1.0,
                    0.0, 0.0, 1.0, 1.0,
                    0.0, 1.0, 0.0, 1.0,            
                ];
                gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(colors), gl.STATIC_DRAW);
                this.floorVertexColorBuffer.itemSize = 4;
                this.floorVertexColorBuffer.numItems = 6;
            }
        

            this.pyramidVertexPositionBuffer = gl.createBuffer();
            gl.bindBuffer(gl.ARRAY_BUFFER, this.pyramidVertexPositionBuffer);
            {
                let vertices = [
                // Front face
                0.0, 1.0, 0.0,
                -1.0, -1.0, 1.0,
                1.0, -1.0, 1.0,
        
                // Right face
                0.0, 1.0, 0.0,
                1.0, -1.0, 1.0,
                1.0, -1.0, -1.0,
        
                // Back face
                0.0, 1.0, 0.0,
                1.0, -1.0, -1.0,
                -1.0, -1.0, -1.0,
        
                // Left face
                0.0, 1.0, 0.0,
                -1.0, -1.0, -1.0,
                -1.0, -1.0, 1.0
                ];
                gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(vertices), gl.STATIC_DRAW);
            }
            this.pyramidVertexPositionBuffer.itemSize = 3;
            this.pyramidVertexPositionBuffer.numItems = 12;
        
            this.pyramidVertexColorBuffer = gl.createBuffer();
            gl.bindBuffer(gl.ARRAY_BUFFER, this.pyramidVertexColorBuffer);
            let colors = [
                // Front face
                1.0, 0.0, 0.0, 1.0,
                0.0, 1.0, 0.0, 1.0,
                0.0, 0.0, 1.0, 1.0,
        
                // Right face
                1.0, 0.0, 0.0, 1.0,
                0.0, 0.0, 1.0, 1.0,
                0.0, 1.0, 0.0, 1.0,
        
                // Back face
                1.0, 0.0, 0.0, 1.0,
                0.0, 1.0, 0.0, 1.0,
                0.0, 0.0, 1.0, 1.0,
        
                // Left face
                1.0, 0.0, 0.0, 1.0,
                0.0, 0.0, 1.0, 1.0,
                0.0, 1.0, 0.0, 1.0
            ];
            gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(colors), gl.STATIC_DRAW);
            this.pyramidVertexColorBuffer.itemSize = 4;
            this.pyramidVertexColorBuffer.numItems = 12;
        
        
            this.cubeVertexPositionBuffer = gl.createBuffer();
            gl.bindBuffer(gl.ARRAY_BUFFER, this.cubeVertexPositionBuffer);
            vertices = [
                // Front face
                -1.0, -1.0, 1.0,
                1.0, -1.0, 1.0,
                1.0, 1.0, 1.0,
                -1.0, 1.0, 1.0,
        
                // Back face
                -1.0, -1.0, -1.0,
                -1.0, 1.0, -1.0,
                1.0, 1.0, -1.0,
                1.0, -1.0, -1.0,
        
                // Top face
                -1.0, 1.0, -1.0,
                -1.0, 1.0, 1.0,
                1.0, 1.0, 1.0,
                1.0, 1.0, -1.0,
        
                // Bottom face
                -1.0, -1.0, -1.0,
                1.0, -1.0, -1.0,
                1.0, -1.0, 1.0,
                -1.0, -1.0, 1.0,
        
                // Right face
                1.0, -1.0, -1.0,
                1.0, 1.0, -1.0,
                1.0, 1.0, 1.0,
                1.0, -1.0, 1.0,
        
                // Left face
                -1.0, -1.0, -1.0,
                -1.0, -1.0, 1.0,
                -1.0, 1.0, 1.0,
                -1.0, 1.0, -1.0
            ];
            gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(vertices), gl.STATIC_DRAW);
            this.cubeVertexPositionBuffer.itemSize = 3;
            this.cubeVertexPositionBuffer.numItems = 24;
        
            this.cubeVertexColorBuffer = gl.createBuffer();
            gl.bindBuffer(gl.ARRAY_BUFFER, this.cubeVertexColorBuffer);
            colors = [
                [0.5, 0.6, 0.8, 1.0], // Front face
                [1.0, 1.0, 0.0, 1.0], // Back face
                [0.0, 1.0, 0.0, 1.0], // Top face
                [1.0, 0.5, 0.5, 1.0], // Bottom face
                [1.0, 0.0, 1.0, 1.0], // Right face
                [0.0, 0.0, 1.0, 1.0]  // Left face
            ];
            var unpackedColors = [];
            for (var i in colors) {
                var color = colors[i];
                for (var j = 0; j < 4; j++) {
                    unpackedColors = unpackedColors.concat(color);
                }
            }
            gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(unpackedColors), gl.STATIC_DRAW);
            this.cubeVertexColorBuffer.itemSize = 4;
            this.cubeVertexColorBuffer.numItems = 24;
        
            this.cubeVertexIndexBuffer = gl.createBuffer();
            gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, this.cubeVertexIndexBuffer);
            var cubeVertexIndices = [
                0, 1, 2, 0, 2, 3,    // Front face
                4, 5, 6, 4, 6, 7,    // Back face
                8, 9, 10, 8, 10, 11,  // Top face
                12, 13, 14, 12, 14, 15, // Bottom face
                16, 17, 18, 16, 18, 19, // Right face
                20, 21, 22, 20, 22, 23  // Left face
            ];
            gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, new Uint16Array(cubeVertexIndices), gl.STATIC_DRAW);
            this.cubeVertexIndexBuffer.itemSize = 1;
            this.cubeVertexIndexBuffer.numItems = 36;
        }     
    }
};