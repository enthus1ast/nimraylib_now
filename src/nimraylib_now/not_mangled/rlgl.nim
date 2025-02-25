import raylib

from os import parentDir, `/`
const rlglHeader = currentSourcePath().parentDir()/"rlgl.h"
## *********************************************************************************************
##
##    rlgl v4.0 - A multi-OpenGL abstraction layer with an immediate-mode style API
##
##    An abstraction layer for multiple OpenGL versions (1.1, 2.1, 3.3 Core, 4.3 Core, ES 2.0)
##    that provides a pseudo-OpenGL 1.1 immediate-mode style API (rlVertex, rlTranslate, rlRotate...)
##
##    When chosing an OpenGL backend different than OpenGL 1.1, some internal buffer are
##    initialized on rlglInit() to accumulate vertex data.
##
##    When an internal state change is required all the stored vertex data is renderer in batch,
##    additioanlly, rlDrawRenderBatchActive() could be called to force flushing of the batch.
##
##    Some additional resources are also loaded for convenience, here the complete list:
##       - Default batch (RLGL.defaultBatch): RenderBatch system to accumulate vertex data
##       - Default texture (RLGL.defaultTextureId): 1x1 white pixel R8G8B8A8
##       - Default shader (RLGL.State.defaultShaderId, RLGL.State.defaultShaderLocs)
##
##    Internal buffer (and additional resources) must be manually unloaded calling rlglClose().
##
##
##    CONFIGURATION:
##
##    #define GRAPHICS_API_OPENGL_11
##    #define GRAPHICS_API_OPENGL_21
##    #define GRAPHICS_API_OPENGL_33
##    #define GRAPHICS_API_OPENGL_43
##    #define GRAPHICS_API_OPENGL_ES2
##        Use selected OpenGL graphics backend, should be supported by platform
##        Those preprocessor defines are only used on rlgl module, if OpenGL version is
##        required by any other module, use rlGetVersion() to check it
##
##    #define RLGL_IMPLEMENTATION
##        Generates the implementation of the library into the included file.
##        If not defined, the library is in header only mode and can be included in other headers
##        or source files without problems. But only ONE file should hold the implementation.
##
##    #define RLGL_RENDER_TEXTURES_HINT
##        Enable framebuffer objects (fbo) support (enabled by default)
##        Some GPUs could not support them despite the OpenGL version
##
##    #define RLGL_SHOW_GL_DETAILS_INFO
##        Show OpenGL extensions and capabilities detailed logs on init
##
##    #define RLGL_ENABLE_OPENGL_DEBUG_CONTEXT
##        Enable debug context (only available on OpenGL 4.3)
##
##    rlgl capabilities could be customized just defining some internal
##    values before library inclusion (default values listed):
##
##    #define RL_DEFAULT_BATCH_BUFFER_ELEMENTS   8192    // Default internal render batch elements limits
##    #define RL_DEFAULT_BATCH_BUFFERS              1    // Default number of batch buffers (multi-buffering)
##    #define RL_DEFAULT_BATCH_DRAWCALLS          256    // Default number of batch draw calls (by state changes: mode, texture)
##    #define RL_DEFAULT_BATCH_MAX_TEXTURE_UNITS    4    // Maximum number of textures units that can be activated on batch drawing (SetShaderValueTexture())
##
##    #define RL_MAX_MATRIX_STACK_SIZE             32    // Maximum size of internal Matrix stack
##    #define RL_MAX_SHADER_LOCATIONS              32    // Maximum number of shader locations supported
##    #define RL_CULL_DISTANCE_NEAR              0.01    // Default projection matrix near cull distance
##    #define RL_CULL_DISTANCE_FAR             1000.0    // Default projection matrix far cull distance
##
##    When loading a shader, the following vertex attribute and uniform
##    location names are tried to be set automatically:
##
##    #define RL_DEFAULT_SHADER_ATTRIB_NAME_POSITION     "vertexPosition"    // Binded by default to shader location: 0
##    #define RL_DEFAULT_SHADER_ATTRIB_NAME_TEXCOORD     "vertexTexCoord"    // Binded by default to shader location: 1
##    #define RL_DEFAULT_SHADER_ATTRIB_NAME_NORMAL       "vertexNormal"      // Binded by default to shader location: 2
##    #define RL_DEFAULT_SHADER_ATTRIB_NAME_COLOR        "vertexColor"       // Binded by default to shader location: 3
##    #define RL_DEFAULT_SHADER_ATTRIB_NAME_TANGENT      "vertexTangent"     // Binded by default to shader location: 4
##    #define RL_DEFAULT_SHADER_ATTRIB_NAME_TEXCOORD2    "vertexTexCoord2"   // Binded by default to shader location: 5
##    #define RL_DEFAULT_SHADER_UNIFORM_NAME_MVP         "mvp"               // model-view-projection matrix
##    #define RL_DEFAULT_SHADER_UNIFORM_NAME_VIEW        "matView"           // view matrix
##    #define RL_DEFAULT_SHADER_UNIFORM_NAME_PROJECTION  "matProjection"     // projection matrix
##    #define RL_DEFAULT_SHADER_UNIFORM_NAME_MODEL       "matModel"          // model matrix
##    #define RL_DEFAULT_SHADER_UNIFORM_NAME_NORMAL      "matNormal"         // normal matrix (transpose(inverse(matModelView))
##    #define RL_DEFAULT_SHADER_UNIFORM_NAME_COLOR       "colDiffuse"        // color diffuse (base tint color, multiplied by texture color)
##    #define RL_DEFAULT_SHADER_SAMPLER2D_NAME_TEXTURE0  "texture0"          // texture0 (texture slot active 0)
##    #define RL_DEFAULT_SHADER_SAMPLER2D_NAME_TEXTURE1  "texture1"          // texture1 (texture slot active 1)
##    #define RL_DEFAULT_SHADER_SAMPLER2D_NAME_TEXTURE2  "texture2"          // texture2 (texture slot active 2)
##
##    DEPENDENCIES:
##
##       - OpenGL libraries (depending on platform and OpenGL version selected)
##       - GLAD OpenGL extensions loading library (only for OpenGL 3.3 Core, 4.3 Core)
##
##
##    LICENSE: zlib/libpng
##
##    Copyright (c) 2014-2021 Ramon Santamaria (@raysan5)
##
##    This software is provided "as-is", without any express or implied warranty. In no event
##    will the authors be held liable for any damages arising from the use of this software.
##
##    Permission is granted to anyone to use this software for any purpose, including commercial
##    applications, and to alter it and redistribute it freely, subject to the following restrictions:
##
##      1. The origin of this software must not be misrepresented; you must not claim that you
##      wrote the original software. If you use this software in a product, an acknowledgment
##      in the product documentation would be appreciated but is not required.
##
##      2. Altered source versions must be plainly marked as such, and must not be misrepresented
##      as being the original software.
##
##      3. This notice may not be removed or altered from any source distribution.
##
## ********************************************************************************************

const
  RLGL_VERSION* = "4.0"

##  Function specifiers in case library is build/used as a shared library (Windows)
##  NOTE: Microsoft specifiers to tell compiler that symbols are imported/exported from a .dll
##  Function specifiers definition
##  Support TRACELOG macros
##  Allow custom memory allocators
##  Security check in case no GRAPHICS_API_OPENGL_* defined
##  Security check in case multiple GRAPHICS_API_OPENGL_* defined
##  OpenGL 2.1 uses most of OpenGL 3.3 Core functionality
##  WARNING: Specific parts are checked with #if defines
##  OpenGL 4.3 uses OpenGL 3.3 Core functionality
##  Support framebuffer objects by default
##  NOTE: Some driver implementation do not support it, despite they should

const
  RLGL_RENDER_TEXTURES_HINT* = true

## ----------------------------------------------------------------------------------
##  Defines and Macros
## ----------------------------------------------------------------------------------
##  Default internal render batch elements limits
##  Internal Matrix stack
##  Shader limits
##  Projection matrix culling
##  Texture parameters (equivalent to OpenGL defines)

const
  TEXTURE_WRAP_S* = 0x00002802
  TEXTURE_WRAP_T* = 0x00002803
  TEXTURE_MAG_FILTER* = 0x00002800
  TEXTURE_MIN_FILTER* = 0x00002801
  NEAREST* = 0x00002600
  LINEAR* = 0x00002601
  MIP_NEAREST* = 0x00002700
  NEAREST_MIP_LINEAR* = 0x00002702
  LINEAR_MIP_NEAREST* = 0x00002701
  MIP_LINEAR* = 0x00002703
  ANISOTROPIC* = 0x00003000
  TEXTURE_WRAP_REPEAT* = 0x00002901
  TEXTURE_WRAP_CLAMP* = 0x0000812F
  TEXTURE_WRAP_MIRROR_REPEAT* = 0x00008370
  TEXTURE_WRAP_MIRROR_CLAMP* = 0x00008742

##  Matrix modes (equivalent to OpenGL)

const
  MODELVIEW* = 0x00001700
  PROJECTION* = 0x00001701
  TEXTURE* = 0x00001702

##  Primitive assembly draw modes

const
  LINES* = 0x00000001
  TRIANGLES* = 0x00000004
  QUADS* = 0x00000007

##  GL equivalent data types

const
  UNSIGNED_BYTE* = 0x00001401
  FLOAT* = 0x00001406

##  Buffer usage hint

const
  STREAM_DRAW* = 0x000088E0
  STREAM_READ* = 0x000088E1
  STREAM_COPY* = 0x000088E2
  STATIC_DRAW* = 0x000088E4
  STATIC_READ* = 0x000088E5
  STATIC_COPY* = 0x000088E6
  DYNAMIC_DRAW* = 0x000088E8
  DYNAMIC_READ* = 0x000088E9
  DYNAMIC_COPY* = 0x000088EA

##  GL Shader type

const
  FRAGMENT_SHADER* = 0x00008B30
  VERTEX_SHADER* = 0x00008B31
  COMPUTE_SHADER* = 0x000091B9

## ----------------------------------------------------------------------------------
##  Types and Structures Definition
## ----------------------------------------------------------------------------------

type
  GlVersion* {.size: sizeof(cint), pure.} = enum
    OPENGL_11 = 1, OPENGL_21, OPENGL_33, OPENGL_43, OPENGL_ES_20
  FramebufferAttachType* {.size: sizeof(cint), pure.} = enum
    ATTACHMENT_COLOR_CHANNEL0 = 0, ATTACHMENT_COLOR_CHANNEL1,
    ATTACHMENT_COLOR_CHANNEL2, ATTACHMENT_COLOR_CHANNEL3,
    ATTACHMENT_COLOR_CHANNEL4, ATTACHMENT_COLOR_CHANNEL5,
    ATTACHMENT_COLOR_CHANNEL6, ATTACHMENT_COLOR_CHANNEL7, ATTACHMENT_DEPTH = 100,
    ATTACHMENT_STENCIL = 200
  FramebufferAttachTextureType* {.size: sizeof(cint), pure.} = enum
    ATTACHMENT_CUBEMAP_POSITIVE_X = 0, ATTACHMENT_CUBEMAP_NEGATIVE_X,
    ATTACHMENT_CUBEMAP_POSITIVE_Y, ATTACHMENT_CUBEMAP_NEGATIVE_Y,
    ATTACHMENT_CUBEMAP_POSITIVE_Z, ATTACHMENT_CUBEMAP_NEGATIVE_Z,
    ATTACHMENT_TEXTURE2D = 100, ATTACHMENT_RENDERBUFFER = 200




##  Dynamic vertex buffers (position + texcoords + colors + indices arrays)

type
  VertexBuffer* {.importc: "rlVertexBuffer", header: rlglHeader, bycopy.} = object
    elementCount* {.importc: "elementCount".}: cint ##  Number of elements in the buffer (QUADS)
    vertices* {.importc: "vertices".}: ptr UncheckedArray[cfloat] ##  Vertex position (XYZ - 3 components per vertex) (shader-location = 0)
    texcoords* {.importc: "texcoords".}: ptr UncheckedArray[cfloat] ##  Vertex texture coordinates (UV - 2 components per vertex) (shader-location = 1)
    colors* {.importc: "colors".}: ptr UncheckedArray[uint8] ##  Vertex colors (RGBA - 4 components per vertex) (shader-location = 3)
    vaoId* {.importc: "vaoId".}: cuint ##  OpenGL Vertex Array Object id
    vboId* {.importc: "vboId".}: array[4, cuint] ##  OpenGL Vertex Buffer Objects id (4 types of vertex data)


##  Draw call type
##  NOTE: Only texture changes register a new draw, other state-change-related elements are not
##  used at this moment (vaoId, shaderId, matrices), raylib just forces a batch draw call if any
##  of those state-change happens (this is done in core module)

type
  DrawCall* {.importc: "rlDrawCall", header: rlglHeader, bycopy.} = object
    mode* {.importc: "mode".}: cint ##  Drawing mode: LINES, TRIANGLES, QUADS
    vertexCount* {.importc: "vertexCount".}: cint ##  Number of vertex of the draw
    vertexAlignment* {.importc: "vertexAlignment".}: cint ##  Number of vertex required for index alignment (LINES, TRIANGLES)
                                                      ## unsigned int vaoId;       // Vertex array id to be used on the draw -> Using RLGL.currentBatch->vertexBuffer.vaoId
                                                      ## unsigned int shaderId;    // Shader id to be used on the draw -> Using RLGL.currentShaderId
    textureId* {.importc: "textureId".}: cuint ##  Texture id to be used on the draw -> Use to create new draw call if changes
                                           ## Matrix projection;      // Projection matrix for this draw -> Using RLGL.projection by default
                                           ## Matrix modelview;       // Modelview matrix for this draw -> Using RLGL.modelview by default


##  rlRenderBatch type

type
  RenderBatch* {.importc: "rlRenderBatch", header: rlglHeader, bycopy.} = object
    bufferCount* {.importc: "bufferCount".}: cint ##  Number of vertex buffers (multi-buffering support)
    currentBuffer* {.importc: "currentBuffer".}: cint ##  Current buffer tracking in case of multi-buffering
    vertexBuffer* {.importc: "vertexBuffer".}: ptr VertexBuffer ##  Dynamic buffer(s) for vertex data
    draws* {.importc: "draws".}: ptr DrawCall ##  Draw calls array, depends on textureId
    drawCounter* {.importc: "drawCounter".}: cint ##  Draw calls counter
    currentDepth* {.importc: "currentDepth".}: cfloat ##  Current depth value for next draw


##  Trace log level
##  NOTE: Organized by priority level

type
  TraceLogLevel* {.size: sizeof(cint), pure.} = enum
    ALL = 0,                    ##  Display all logs
    TRACE,                    ##  Trace logging, intended for internal use only
    DEBUG,                    ##  Debug logging, used for internal debugging, it should be disabled on release builds
    INFO,                     ##  Info logging, used for program execution info
    WARNING,                  ##  Warning logging, used on recoverable failures
    ERROR,                    ##  Error logging, used on unrecoverable failures
    FATAL,                    ##  Fatal logging, used to abort program: exit(EXIT_FAILURE)
    NONE                      ##  Disable logging


##  Texture formats (support depends on OpenGL version)

type
  PixelFormat* {.size: sizeof(cint), pure.} = enum
    UNCOMPRESSED_GRAYSCALE = 1, ##  8 bit per pixel (no alpha)
    UNCOMPRESSED_GRAY_ALPHA,  ##  8*2 bpp (2 channels)
    UNCOMPRESSED_R5G6B5,      ##  16 bpp
    UNCOMPRESSED_R8G8B8,      ##  24 bpp
    UNCOMPRESSED_R5G5B5A1,    ##  16 bpp (1 bit alpha)
    UNCOMPRESSED_R4G4B4A4,    ##  16 bpp (4 bit alpha)
    UNCOMPRESSED_R8G8B8A8,    ##  32 bpp
    UNCOMPRESSED_R32,         ##  32 bpp (1 channel - float)
    UNCOMPRESSED_R32G32B32,   ##  32*3 bpp (3 channels - float)
    UNCOMPRESSED_R32G32B32A32, ##  32*4 bpp (4 channels - float)
    COMPRESSED_DXT1_RGB,      ##  4 bpp (no alpha)
    COMPRESSED_DXT1_RGBA,     ##  4 bpp (1 bit alpha)
    COMPRESSED_DXT3_RGBA,     ##  8 bpp
    COMPRESSED_DXT5_RGBA,     ##  8 bpp
    COMPRESSED_ETC1_RGB,      ##  4 bpp
    COMPRESSED_ETC2_RGB,      ##  4 bpp
    COMPRESSED_ETC2_EAC_RGBA, ##  8 bpp
    COMPRESSED_PVRT_RGB,      ##  4 bpp
    COMPRESSED_PVRT_RGBA,     ##  4 bpp
    COMPRESSED_ASTC_4x4RGBA,  ##  8 bpp
    COMPRESSED_ASTC_8x8RGBA   ##  2 bpp


##  Texture parameters: filter mode
##  NOTE 1: Filtering considers mipmaps if available in the texture
##  NOTE 2: Filter is accordingly set for minification and magnification

type
  TextureFilter* {.size: sizeof(cint), pure.} = enum
    POINT = 0,                  ##  No filter, just pixel aproximation
    BILINEAR,                 ##  Linear filtering
    TRILINEAR,                ##  Trilinear filtering (linear with mipmaps)
    ANISOTROPIC_4X,           ##  Anisotropic filtering 4x
    ANISOTROPIC_8X,           ##  Anisotropic filtering 8x
    ANISOTROPIC_16X           ##  Anisotropic filtering 16x


##  Color blending modes (pre-defined)

type
  BlendMode* {.size: sizeof(cint), pure.} = enum
    ALPHA = 0,                  ##  Blend textures considering alpha (default)
    ADDITIVE,                 ##  Blend textures adding colors
    MULTIPLIED,               ##  Blend textures multiplying colors
    ADD_COLORS,               ##  Blend textures adding colors (alternative)
    SUBTRACT_COLORS,          ##  Blend textures subtracting colors (alternative)
    CUSTOM                    ##  Belnd textures using custom src/dst factors (use SetBlendModeCustom())


##  Shader location point type

type
  ShaderLocationIndex* {.size: sizeof(cint), pure.} = enum
    VERTEX_POSITION = 0,        ##  Shader location: vertex attribute: position
    VERTEX_TEXCOORD01,        ##  Shader location: vertex attribute: texcoord01
    VERTEX_TEXCOORD02,        ##  Shader location: vertex attribute: texcoord02
    VERTEX_NORMAL,            ##  Shader location: vertex attribute: normal
    VERTEX_TANGENT,           ##  Shader location: vertex attribute: tangent
    VERTEX_COLOR,             ##  Shader location: vertex attribute: color
    MATRIX_MVP,               ##  Shader location: matrix uniform: model-view-projection
    MATRIX_VIEW,              ##  Shader location: matrix uniform: view (camera transform)
    MATRIX_PROJECTION,        ##  Shader location: matrix uniform: projection
    MATRIX_MODEL,             ##  Shader location: matrix uniform: model (transform)
    MATRIX_NORMAL,            ##  Shader location: matrix uniform: normal
    VECTOR_VIEW,              ##  Shader location: vector uniform: view
    COLOR_DIFFUSE,            ##  Shader location: vector uniform: diffuse color
    COLOR_SPECULAR,           ##  Shader location: vector uniform: specular color
    COLOR_AMBIENT,            ##  Shader location: vector uniform: ambient color
    MAP_ALBEDO,               ##  Shader location: sampler2d texture: albedo (same as: RL_SHADER_LOC_MAP_DIFFUSE)
    MAP_METALNESS,            ##  Shader location: sampler2d texture: metalness (same as: RL_SHADER_LOC_MAP_SPECULAR)
    MAP_NORMAL,               ##  Shader location: sampler2d texture: normal
    MAP_ROUGHNESS,            ##  Shader location: sampler2d texture: roughness
    MAP_OCCLUSION,            ##  Shader location: sampler2d texture: occlusion
    MAP_EMISSION,             ##  Shader location: sampler2d texture: emission
    MAP_HEIGHT,               ##  Shader location: sampler2d texture: height
    MAP_CUBEMAP,              ##  Shader location: samplerCube texture: cubemap
    MAP_IRRADIANCE,           ##  Shader location: samplerCube texture: irradiance
    MAP_PREFILTER,            ##  Shader location: samplerCube texture: prefilter
    MAP_BRDF                  ##  Shader location: sampler2d texture: brdf


##  Shader uniform data type

type
  ShaderUniformDataType* {.size: sizeof(cint), pure.} = enum
    FLOAT = 0,                  ##  Shader uniform type: float
    VEC2,                     ##  Shader uniform type: vec2 (2 float)
    VEC3,                     ##  Shader uniform type: vec3 (3 float)
    VEC4,                     ##  Shader uniform type: vec4 (4 float)
    INT,                      ##  Shader uniform type: int
    IVEC2,                    ##  Shader uniform type: ivec2 (2 int)
    IVEC3,                    ##  Shader uniform type: ivec3 (3 int)
    IVEC4,                    ##  Shader uniform type: ivec4 (4 int)
    SAMPLER2D                 ##  Shader uniform type: sampler2d


##  Shader attribute data types

type
  ShaderAttributeDataType* {.size: sizeof(cint), pure.} = enum
    FLOAT = 0,                  ##  Shader attribute type: float
    VEC2,                     ##  Shader attribute type: vec2 (2 float)
    VEC3,                     ##  Shader attribute type: vec3 (3 float)
    VEC4                      ##  Shader attribute type: vec4 (4 float)


## ------------------------------------------------------------------------------------
##  Functions Declaration - Matrix operations
## ------------------------------------------------------------------------------------

proc matrixMode*(mode: cint) {.cdecl, importc: "rlMatrixMode", header: rlglHeader.}
##  Choose the current matrix to be transformed

proc pushMatrix*() {.cdecl, importc: "rlPushMatrix", header: rlglHeader.}
##  Push the current matrix to stack

proc popMatrix*() {.cdecl, importc: "rlPopMatrix", header: rlglHeader.}
##  Pop lattest inserted matrix from stack

proc loadIdentity*() {.cdecl, importc: "rlLoadIdentity", header: rlglHeader.}
##  Reset current matrix to identity matrix

proc translatef*(x: cfloat; y: cfloat; z: cfloat) {.cdecl, importc: "rlTranslatef",
    header: rlglHeader.}
##  Multiply the current matrix by a translation matrix

proc rotatef*(angle: cfloat; x: cfloat; y: cfloat; z: cfloat) {.cdecl,
    importc: "rlRotatef", header: rlglHeader.}
##  Multiply the current matrix by a rotation matrix

proc scalef*(x: cfloat; y: cfloat; z: cfloat) {.cdecl, importc: "rlScalef",
    header: rlglHeader.}
##  Multiply the current matrix by a scaling matrix

proc multMatrixf*(matf: ptr cfloat) {.cdecl, importc: "rlMultMatrixf",
                                  header: rlglHeader.}
##  Multiply the current matrix by another matrix

proc frustum*(left: cdouble; right: cdouble; bottom: cdouble; top: cdouble;
             znear: cdouble; zfar: cdouble) {.cdecl, importc: "rlFrustum",
    header: rlglHeader.}
proc ortho*(left: cdouble; right: cdouble; bottom: cdouble; top: cdouble; znear: cdouble;
           zfar: cdouble) {.cdecl, importc: "rlOrtho", header: rlglHeader.}
proc viewport*(x: cint; y: cint; width: cint; height: cint) {.cdecl,
    importc: "rlViewport", header: rlglHeader.}
##  Set the viewport area
## ------------------------------------------------------------------------------------
##  Functions Declaration - Vertex level operations
## ------------------------------------------------------------------------------------

proc begin*(mode: cint) {.cdecl, importc: "rlBegin", header: rlglHeader.}
##  Initialize drawing mode (how to organize vertex)

proc `end`*() {.cdecl, importc: "rlEnd", header: rlglHeader.}
##  Finish vertex providing

proc vertex2i*(x: cint; y: cint) {.cdecl, importc: "rlVertex2i", header: rlglHeader.}
##  Define one vertex (position) - 2 int

proc vertex2f*(x: cfloat; y: cfloat) {.cdecl, importc: "rlVertex2f", header: rlglHeader.}
##  Define one vertex (position) - 2 float

proc vertex3f*(x: cfloat; y: cfloat; z: cfloat) {.cdecl, importc: "rlVertex3f",
    header: rlglHeader.}
##  Define one vertex (position) - 3 float

proc texCoord2f*(x: cfloat; y: cfloat) {.cdecl, importc: "rlTexCoord2f",
                                    header: rlglHeader.}
##  Define one vertex (texture coordinate) - 2 float

proc normal3f*(x: cfloat; y: cfloat; z: cfloat) {.cdecl, importc: "rlNormal3f",
    header: rlglHeader.}
##  Define one vertex (normal) - 3 float

proc color4ub*(r: uint8; g: uint8; b: uint8; a: uint8) {.cdecl, importc: "rlColor4ub",
    header: rlglHeader.}
##  Define one vertex (color) - 4 byte

proc color3f*(x: cfloat; y: cfloat; z: cfloat) {.cdecl, importc: "rlColor3f",
    header: rlglHeader.}
##  Define one vertex (color) - 3 float

proc color4f*(x: cfloat; y: cfloat; z: cfloat; w: cfloat) {.cdecl, importc: "rlColor4f",
    header: rlglHeader.}
##  Define one vertex (color) - 4 float
## ------------------------------------------------------------------------------------
##  Functions Declaration - OpenGL style functions (common to 1.1, 3.3+, ES2)
##  NOTE: This functions are used to completely abstract raylib code from OpenGL layer,
##  some of them are direct wrappers over OpenGL calls, some others are custom
## ------------------------------------------------------------------------------------
##  Vertex buffers state

proc enableVertexArray*(vaoId: cuint): bool {.cdecl, importc: "rlEnableVertexArray",
    header: rlglHeader.}
##  Enable vertex array (VAO, if supported)

proc disableVertexArray*() {.cdecl, importc: "rlDisableVertexArray",
                           header: rlglHeader.}
##  Disable vertex array (VAO, if supported)

proc enableVertexBuffer*(id: cuint) {.cdecl, importc: "rlEnableVertexBuffer",
                                   header: rlglHeader.}
##  Enable vertex buffer (VBO)

proc disableVertexBuffer*() {.cdecl, importc: "rlDisableVertexBuffer",
                            header: rlglHeader.}
##  Disable vertex buffer (VBO)

proc enableVertexBufferElement*(id: cuint) {.cdecl,
    importc: "rlEnableVertexBufferElement", header: rlglHeader.}
##  Enable vertex buffer element (VBO element)

proc disableVertexBufferElement*() {.cdecl,
                                   importc: "rlDisableVertexBufferElement",
                                   header: rlglHeader.}
##  Disable vertex buffer element (VBO element)

proc enableVertexAttribute*(index: cuint) {.cdecl,
    importc: "rlEnableVertexAttribute", header: rlglHeader.}
##  Enable vertex attribute index

proc disableVertexAttribute*(index: cuint) {.cdecl,
    importc: "rlDisableVertexAttribute", header: rlglHeader.}
##  Disable vertex attribute index
##  Textures state

proc activeTextureSlot*(slot: cint) {.cdecl, importc: "rlActiveTextureSlot",
                                   header: rlglHeader.}
##  Select and active a texture slot

proc enableTexture*(id: cuint) {.cdecl, importc: "rlEnableTexture", header: rlglHeader.}
##  Enable texture

proc disableTexture*() {.cdecl, importc: "rlDisableTexture", header: rlglHeader.}
##  Disable texture

proc enableTextureCubemap*(id: cuint) {.cdecl, importc: "rlEnableTextureCubemap",
                                     header: rlglHeader.}
##  Enable texture cubemap

proc disableTextureCubemap*() {.cdecl, importc: "rlDisableTextureCubemap",
                              header: rlglHeader.}
##  Disable texture cubemap

proc textureParameters*(id: cuint; param: cint; value: cint) {.cdecl,
    importc: "rlTextureParameters", header: rlglHeader.}
##  Set texture parameters (filter, wrap)
##  Shader state

proc enableShader*(id: cuint) {.cdecl, importc: "rlEnableShader", header: rlglHeader.}
##  Enable shader program

proc disableShader*() {.cdecl, importc: "rlDisableShader", header: rlglHeader.}
##  Disable shader program
##  Framebuffer state

proc enableFramebuffer*(id: cuint) {.cdecl, importc: "rlEnableFramebuffer",
                                  header: rlglHeader.}
##  Enable render texture (fbo)

proc disableFramebuffer*() {.cdecl, importc: "rlDisableFramebuffer",
                           header: rlglHeader.}
##  Disable render texture (fbo), return to default framebuffer

proc activeDrawBuffers*(count: cint) {.cdecl, importc: "rlActiveDrawBuffers",
                                    header: rlglHeader.}
##  Activate multiple draw color buffers
##  General render state

proc enableColorBlend*() {.cdecl, importc: "rlEnableColorBlend", header: rlglHeader.}
##  Enable color blending

proc disableColorBlend*() {.cdecl, importc: "rlDisableColorBlend", header: rlglHeader.}
##  Disable color blending

proc enableDepthTest*() {.cdecl, importc: "rlEnableDepthTest", header: rlglHeader.}
##  Enable depth test

proc disableDepthTest*() {.cdecl, importc: "rlDisableDepthTest", header: rlglHeader.}
##  Disable depth test

proc enableDepthMask*() {.cdecl, importc: "rlEnableDepthMask", header: rlglHeader.}
##  Enable depth write

proc disableDepthMask*() {.cdecl, importc: "rlDisableDepthMask", header: rlglHeader.}
##  Disable depth write

proc enableBackfaceCulling*() {.cdecl, importc: "rlEnableBackfaceCulling",
                              header: rlglHeader.}
##  Enable backface culling

proc disableBackfaceCulling*() {.cdecl, importc: "rlDisableBackfaceCulling",
                               header: rlglHeader.}
##  Disable backface culling

proc enableScissorTest*() {.cdecl, importc: "rlEnableScissorTest", header: rlglHeader.}
##  Enable scissor test

proc disableScissorTest*() {.cdecl, importc: "rlDisableScissorTest",
                           header: rlglHeader.}
##  Disable scissor test

proc scissor*(x: cint; y: cint; width: cint; height: cint) {.cdecl, importc: "rlScissor",
    header: rlglHeader.}
##  Scissor test

proc enableWireMode*() {.cdecl, importc: "rlEnableWireMode", header: rlglHeader.}
##  Enable wire mode

proc disableWireMode*() {.cdecl, importc: "rlDisableWireMode", header: rlglHeader.}
##  Disable wire mode

proc setLineWidth*(width: cfloat) {.cdecl, importc: "rlSetLineWidth",
                                 header: rlglHeader.}
##  Set the line drawing width

proc getLineWidth*(): cfloat {.cdecl, importc: "rlGetLineWidth", header: rlglHeader.}
##  Get the line drawing width

proc enableSmoothLines*() {.cdecl, importc: "rlEnableSmoothLines", header: rlglHeader.}
##  Enable line aliasing

proc disableSmoothLines*() {.cdecl, importc: "rlDisableSmoothLines",
                           header: rlglHeader.}
##  Disable line aliasing

proc enableStereoRender*() {.cdecl, importc: "rlEnableStereoRender",
                           header: rlglHeader.}
##  Enable stereo rendering

proc disableStereoRender*() {.cdecl, importc: "rlDisableStereoRender",
                            header: rlglHeader.}
##  Disable stereo rendering

proc isStereoRenderEnabled*(): bool {.cdecl, importc: "rlIsStereoRenderEnabled",
                                   header: rlglHeader.}
##  Check if stereo render is enabled

proc clearColor*(r: uint8; g: uint8; b: uint8; a: uint8) {.cdecl,
    importc: "rlClearColor", header: rlglHeader.}
##  Clear color buffer with color

proc clearScreenBuffers*() {.cdecl, importc: "rlClearScreenBuffers",
                           header: rlglHeader.}
##  Clear used screen buffers (color and depth)

proc checkErrors*() {.cdecl, importc: "rlCheckErrors", header: rlglHeader.}
##  Check and log OpenGL error codes

proc setBlendMode*(mode: cint) {.cdecl, importc: "rlSetBlendMode", header: rlglHeader.}
##  Set blending mode

proc setBlendFactors*(glSrcFactor: cint; glDstFactor: cint; glEquation: cint) {.cdecl,
    importc: "rlSetBlendFactors", header: rlglHeader.}
##  Set blending mode factor and equation (using OpenGL factors)
## ------------------------------------------------------------------------------------
##  Functions Declaration - rlgl functionality
## ------------------------------------------------------------------------------------
##  rlgl initialization functions

proc init*(width: cint; height: cint) {.cdecl, importc: "rlglInit", header: rlglHeader.}
##  Initialize rlgl (buffers, shaders, textures, states)

proc close*() {.cdecl, importc: "rlglClose", header: rlglHeader.}
##  De-inititialize rlgl (buffers, shaders, textures)

proc loadExtensions*(loader: pointer) {.cdecl, importc: "rlLoadExtensions",
                                     header: rlglHeader.}
##  Load OpenGL extensions (loader function required)

proc getVersion*(): cint {.cdecl, importc: "rlGetVersion", header: rlglHeader.}
##  Get current OpenGL version

proc getFramebufferWidth*(): cint {.cdecl, importc: "rlGetFramebufferWidth",
                                 header: rlglHeader.}
##  Get default framebuffer width

proc getFramebufferHeight*(): cint {.cdecl, importc: "rlGetFramebufferHeight",
                                  header: rlglHeader.}
##  Get default framebuffer height

proc getTextureIdDefault*(): cuint {.cdecl, importc: "rlGetTextureIdDefault",
                                  header: rlglHeader.}
##  Get default texture id

proc getShaderIdDefault*(): cuint {.cdecl, importc: "rlGetShaderIdDefault",
                                 header: rlglHeader.}
##  Get default shader id

proc getShaderLocsDefault*(): ptr cint {.cdecl, importc: "rlGetShaderLocsDefault",
                                     header: rlglHeader.}
##  Get default shader locations
##  Render batch management
##  NOTE: rlgl provides a default render batch to behave like OpenGL 1.1 immediate mode
##  but this render batch API is exposed in case of custom batches are required

proc loadRenderBatch*(numBuffers: cint; bufferElements: cint): RenderBatch {.cdecl,
    importc: "rlLoadRenderBatch", header: rlglHeader.}
##  Load a render batch system

proc unloadRenderBatch*(batch: RenderBatch) {.cdecl, importc: "rlUnloadRenderBatch",
    header: rlglHeader.}
##  Unload render batch system

proc drawRenderBatch*(batch: ptr RenderBatch) {.cdecl, importc: "rlDrawRenderBatch",
    header: rlglHeader.}
##  Draw render batch data (Update->Draw->Reset)

proc setRenderBatchActive*(batch: ptr RenderBatch) {.cdecl,
    importc: "rlSetRenderBatchActive", header: rlglHeader.}
##  Set the active render batch for rlgl (NULL for default internal)

proc drawRenderBatchActive*() {.cdecl, importc: "rlDrawRenderBatchActive",
                              header: rlglHeader.}
##  Update and draw internal render batch

proc checkRenderBatchLimit*(vCount: cint): bool {.cdecl,
    importc: "rlCheckRenderBatchLimit", header: rlglHeader.}
##  Check internal buffer overflow for a given number of vertex

proc setTexture*(id: cuint) {.cdecl, importc: "rlSetTexture", header: rlglHeader.}
##  Set current texture for render batch and check buffers limits
## ------------------------------------------------------------------------------------------------------------------------
##  Vertex buffers management

proc loadVertexArray*(): cuint {.cdecl, importc: "rlLoadVertexArray",
                              header: rlglHeader.}
##  Load vertex array (vao) if supported

proc loadVertexBuffer*(buffer: pointer; size: cint; dynamic: bool): cuint {.cdecl,
    importc: "rlLoadVertexBuffer", header: rlglHeader.}
##  Load a vertex buffer attribute

proc loadVertexBufferElement*(buffer: pointer; size: cint; dynamic: bool): cuint {.
    cdecl, importc: "rlLoadVertexBufferElement", header: rlglHeader.}
##  Load a new attributes element buffer

proc updateVertexBuffer*(bufferId: cuint; data: pointer; dataSize: cint; offset: cint) {.
    cdecl, importc: "rlUpdateVertexBuffer", header: rlglHeader.}
##  Update GPU buffer with new data

proc unloadVertexArray*(vaoId: cuint) {.cdecl, importc: "rlUnloadVertexArray",
                                     header: rlglHeader.}
proc unloadVertexBuffer*(vboId: cuint) {.cdecl, importc: "rlUnloadVertexBuffer",
                                      header: rlglHeader.}
proc setVertexAttribute*(index: cuint; compSize: cint; `type`: cint; normalized: bool;
                        stride: cint; pointer: pointer) {.cdecl,
    importc: "rlSetVertexAttribute", header: rlglHeader.}
proc setVertexAttributeDivisor*(index: cuint; divisor: cint) {.cdecl,
    importc: "rlSetVertexAttributeDivisor", header: rlglHeader.}
proc setVertexAttributeDefault*(locIndex: cint; value: pointer; attribType: cint;
                               count: cint) {.cdecl,
    importc: "rlSetVertexAttributeDefault", header: rlglHeader.}
##  Set vertex attribute default value

proc drawVertexArray*(offset: cint; count: cint) {.cdecl,
    importc: "rlDrawVertexArray", header: rlglHeader.}
proc drawVertexArrayElements*(offset: cint; count: cint; buffer: pointer) {.cdecl,
    importc: "rlDrawVertexArrayElements", header: rlglHeader.}
proc drawVertexArrayInstanced*(offset: cint; count: cint; instances: cint) {.cdecl,
    importc: "rlDrawVertexArrayInstanced", header: rlglHeader.}
proc drawVertexArrayElementsInstanced*(offset: cint; count: cint; buffer: pointer;
                                      instances: cint) {.cdecl,
    importc: "rlDrawVertexArrayElementsInstanced", header: rlglHeader.}
##  Textures management

proc loadTexture*(data: pointer; width: cint; height: cint; format: cint;
                 mipmapCount: cint): cuint {.cdecl, importc: "rlLoadTexture",
    header: rlglHeader.}
##  Load texture in GPU

proc loadTextureDepth*(width: cint; height: cint; useRenderBuffer: bool): cuint {.cdecl,
    importc: "rlLoadTextureDepth", header: rlglHeader.}
##  Load depth texture/renderbuffer (to be attached to fbo)

proc loadTextureCubemap*(data: pointer; size: cint; format: cint): cuint {.cdecl,
    importc: "rlLoadTextureCubemap", header: rlglHeader.}
##  Load texture cubemap

proc updateTexture*(id: cuint; offsetX: cint; offsetY: cint; width: cint; height: cint;
                   format: cint; data: pointer) {.cdecl, importc: "rlUpdateTexture",
    header: rlglHeader.}
##  Update GPU texture with new data

proc getGlTextureFormats*(format: cint; glInternalFormat: ptr cint;
                         glFormat: ptr cint; glType: ptr cint) {.cdecl,
    importc: "rlGetGlTextureFormats", header: rlglHeader.}
##  Get OpenGL internal formats

proc getPixelFormatName*(format: cuint): cstring {.cdecl,
    importc: "rlGetPixelFormatName", header: rlglHeader.}
##  Get name string for pixel format

proc unloadTexture*(id: cuint) {.cdecl, importc: "rlUnloadTexture", header: rlglHeader.}
##  Unload texture from GPU memory

proc genTextureMipmaps*(id: cuint; width: cint; height: cint; format: cint;
                       mipmaps: ptr cint) {.cdecl, importc: "rlGenTextureMipmaps",
    header: rlglHeader.}
##  Generate mipmap data for selected texture

proc readTexturePixels*(id: cuint; width: cint; height: cint; format: cint): pointer {.
    cdecl, importc: "rlReadTexturePixels", header: rlglHeader.}
##  Read texture pixel data

proc readScreenPixels*(width: cint; height: cint): ptr uint8 {.cdecl,
    importc: "rlReadScreenPixels", header: rlglHeader.}
##  Read screen pixel data (color buffer)
##  Framebuffer management (fbo)

proc loadFramebuffer*(width: cint; height: cint): cuint {.cdecl,
    importc: "rlLoadFramebuffer", header: rlglHeader.}
##  Load an empty framebuffer

proc framebufferAttach*(fboId: cuint; texId: cuint; attachType: cint; texType: cint;
                       mipLevel: cint) {.cdecl, importc: "rlFramebufferAttach",
                                       header: rlglHeader.}
##  Attach texture/renderbuffer to a framebuffer

proc framebufferComplete*(id: cuint): bool {.cdecl, importc: "rlFramebufferComplete",
    header: rlglHeader.}
##  Verify framebuffer is complete

proc unloadFramebuffer*(id: cuint) {.cdecl, importc: "rlUnloadFramebuffer",
                                  header: rlglHeader.}
##  Delete framebuffer from GPU
##  Shaders management

proc loadShaderCode*(vsCode: cstring; fsCode: cstring): cuint {.cdecl,
    importc: "rlLoadShaderCode", header: rlglHeader.}
##  Load shader from code strings

proc compileShader*(shaderCode: cstring; `type`: cint): cuint {.cdecl,
    importc: "rlCompileShader", header: rlglHeader.}
##  Compile custom shader and return shader id (type: RL_VERTEX_SHADER, RL_FRAGMENT_SHADER, RL_COMPUTE_SHADER)

proc loadShaderProgram*(vShaderId: cuint; fShaderId: cuint): cuint {.cdecl,
    importc: "rlLoadShaderProgram", header: rlglHeader.}
##  Load custom shader program

proc unloadShaderProgram*(id: cuint) {.cdecl, importc: "rlUnloadShaderProgram",
                                    header: rlglHeader.}
##  Unload shader program

proc getLocationUniform*(shaderId: cuint; uniformName: cstring): cint {.cdecl,
    importc: "rlGetLocationUniform", header: rlglHeader.}
##  Get shader location uniform

proc getLocationAttrib*(shaderId: cuint; attribName: cstring): cint {.cdecl,
    importc: "rlGetLocationAttrib", header: rlglHeader.}
##  Get shader location attribute

proc setUniform*(locIndex: cint; value: pointer; uniformType: cint; count: cint) {.cdecl,
    importc: "rlSetUniform", header: rlglHeader.}
##  Set shader value uniform

proc setUniformMatrix*(locIndex: cint; mat: Matrix) {.cdecl,
    importc: "rlSetUniformMatrix", header: rlglHeader.}
##  Set shader value matrix

proc setUniformSampler*(locIndex: cint; textureId: cuint) {.cdecl,
    importc: "rlSetUniformSampler", header: rlglHeader.}
##  Set shader value sampler

proc setShader*(id: cuint; locs: ptr cint) {.cdecl, importc: "rlSetShader",
                                       header: rlglHeader.}
##  Set shader currently active (id and locations)
##  Compute shader management

proc loadComputeShaderProgram*(shaderId: cuint): cuint {.cdecl,
    importc: "rlLoadComputeShaderProgram", header: rlglHeader.}
##  Load compute shader program

proc computeShaderDispatch*(groupX: cuint; groupY: cuint; groupZ: cuint) {.cdecl,
    importc: "rlComputeShaderDispatch", header: rlglHeader.}
##  Dispatch compute shader (equivalent to *draw* for graphics pilepine)
##  Shader buffer storage object management (ssbo)

proc loadShaderBuffer*(size: culonglong; data: pointer; usageHint: cint): cuint {.cdecl,
    importc: "rlLoadShaderBuffer", header: rlglHeader.}
##  Load shader storage buffer object (SSBO)

proc unloadShaderBuffer*(ssboId: cuint) {.cdecl, importc: "rlUnloadShaderBuffer",
                                       header: rlglHeader.}
##  Unload shader storage buffer object (SSBO)

proc updateShaderBufferElements*(id: cuint; data: pointer; dataSize: culonglong;
                                offset: culonglong) {.cdecl,
    importc: "rlUpdateShaderBufferElements", header: rlglHeader.}
##  Update SSBO buffer data

proc getShaderBufferSize*(id: cuint): culonglong {.cdecl,
    importc: "rlGetShaderBufferSize", header: rlglHeader.}
##  Get SSBO buffer size

proc readShaderBufferElements*(id: cuint; dest: pointer; count: culonglong;
                              offset: culonglong) {.cdecl,
    importc: "rlReadShaderBufferElements", header: rlglHeader.}
##  Bind SSBO buffer

proc bindShaderBuffer*(id: cuint; index: cuint) {.cdecl,
    importc: "rlBindShaderBuffer", header: rlglHeader.}
##  Copy SSBO buffer data
##  Buffer management

proc copyBuffersElements*(destId: cuint; srcId: cuint; destOffset: culonglong;
                         srcOffset: culonglong; count: culonglong) {.cdecl,
    importc: "rlCopyBuffersElements", header: rlglHeader.}
##  Copy SSBO buffer data

proc bindImageTexture*(id: cuint; index: cuint; format: cuint; readonly: cint) {.cdecl,
    importc: "rlBindImageTexture", header: rlglHeader.}
##  Bind image texture
##  Matrix state management

proc getMatrixModelview*(): Matrix {.cdecl, importc: "rlGetMatrixModelview",
                                  header: rlglHeader.}
##  Get internal modelview matrix

proc getMatrixProjection*(): Matrix {.cdecl, importc: "rlGetMatrixProjection",
                                   header: rlglHeader.}
##  Get internal projection matrix

proc getMatrixTransform*(): Matrix {.cdecl, importc: "rlGetMatrixTransform",
                                  header: rlglHeader.}
##  Get internal accumulated transform matrix

proc getMatrixProjectionStereo*(eye: cint): Matrix {.cdecl,
    importc: "rlGetMatrixProjectionStereo", header: rlglHeader.}
##  Get internal projection matrix for stereo render (selected eye)

proc getMatrixViewOffsetStereo*(eye: cint): Matrix {.cdecl,
    importc: "rlGetMatrixViewOffsetStereo", header: rlglHeader.}
##  Get internal view offset matrix for stereo render (selected eye)

proc setMatrixProjection*(proj: Matrix) {.cdecl, importc: "rlSetMatrixProjection",
                                       header: rlglHeader.}
##  Set a custom projection matrix (replaces internal projection matrix)

proc setMatrixModelview*(view: Matrix) {.cdecl, importc: "rlSetMatrixModelview",
                                      header: rlglHeader.}
##  Set a custom modelview matrix (replaces internal modelview matrix)

proc setMatrixProjectionStereo*(right: Matrix; left: Matrix) {.cdecl,
    importc: "rlSetMatrixProjectionStereo", header: rlglHeader.}
##  Set eyes projection matrices for stereo rendering

proc setMatrixViewOffsetStereo*(right: Matrix; left: Matrix) {.cdecl,
    importc: "rlSetMatrixViewOffsetStereo", header: rlglHeader.}
##  Set eyes view offsets matrices for stereo rendering
##  Quick and dirty cube/quad buffers load->draw->unload

proc loadDrawCube*() {.cdecl, importc: "rlLoadDrawCube", header: rlglHeader.}
##  Load and draw a cube

proc loadDrawQuad*() {.cdecl, importc: "rlLoadDrawQuad", header: rlglHeader.}
##  Load and draw a quad

template begin*(mode: cint; body: untyped) =
  begin(mode)
  block:
    body
  `end`()

