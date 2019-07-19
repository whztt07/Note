# Create A Fog Shader

http://in2gpu.com/2014/07/22/create-fog-shader/

## Clear color

clear color 同于雾色。如下图 a

![img](assets/color-comparation1.jpg)

## 标准方程

三种

### Linear fog

雾参数 $\text{fogFactor}\in[0,1]$，公式如下
$$
\text{fogFactor}=\frac{\text {fogEnd - vertexViewDistance}}{\text {fogEnd - fogStart }}
$$
颜色公式为

```c++
finalColor = lerp(fogColor, originalColor, fogFactor)
```

![img](assets/linearExplination-1563270176499-1563270177953.jpg)

### Expnential fog

基于物理
$$
f=e^{-d * b}=\frac{1}{e^{d * b}}
$$
其中 d 是距离，b 是吸收因子或雾浓度

![img](assets/exponentialResult.jpg)

下降速度比 linear fog 快

### Exponential square fog

近处更清晰
$$
f=e^{-(d * b)^{2}}=\frac{1}{e^{(d * b)^{2}}}
$$
![img](assets/exponential-square-fog.jpg)

## 获取深度

### Plane-based fog

```c++
dist = abs(VP.z); //where VP is a vec4 var computed in vertex shader
                  //to get vertex position;
                  // VP = View*Model* vec4(in_position,1)
//other way
dist = gl_FragCoord.z / gl_FragCoord.w; // dependence to current camera gl_Position
                                         //works only in fragment shader
```

![Plane-based Fog](assets/plane-based.jpg)

### Range-based fog

这个距离不是真的距离，应该要用

```c++
sqrt(dot(viewPos, viewPos))
```

![img](assets/fog-3.jpg)

### 对比

plane-based fog

![Planar fog z depth view](assets/planar-based.jpg)

range-based fog

![Range base fog](assets/ranged-based.jpg)

## Fog in vertex shader v.s. Fog in fragment shader

看情况

下边给出 fog in fragment shader 的 glsl 实现

```c++
//********************
// fog vertex shader
//*******************
#version 330
 
layout(location = 0) in vec3 in_position;
layout(location = 1) in vec3 in_normal;
layout(location = 2) in vec2 in_texcoord;
 
uniform mat4 model_matrix, view_matrix, projection_matrix;
 
out vec3 world_pos;
out vec3 world_normal;
out vec2 texcoord;
out vec4 viewSpace;
 
void main(){
    //used for lighting models
    world_pos = (model_matrix * vec4(in_position,1)).xyz;
    world_normal = normalize(mat3(model_matrix) * in_normal);
    texcoord = in_texcoord;

    //send it to fragment shader
    viewSpace = view_matrix * model_matrix * vec4(in_position,1);
    gl_Position = projection_matrix * viewSpace;
}
```

```c++
//fog fragment shader
//................!!!.......................
//if you decided how to compute fog distance
//and you want to use only one fog equation
//you don't have to use those if statements
//Here is a tutorial and I want to show
//different possibilities
//.........................................
#version 330
layout(location = 0) out vec4 out_color;
 
uniform vec3 light_position;
uniform vec3 eye_position;
 
uniform sampler2D texture1;
 
//0 linear; 1 exponential; 2 exponential square
uniform int fogSelector;
//0 plane based; 1 range based
uniform int depthFog;
 
//can pass them as uniforms
const vec3 DiffuseLight = vec3(0.15, 0.05, 0.0);
const vec3 RimColor = vec3(0.2, 0.2, 0.2);
 
//from vertex shader
in vec3 world_pos;
in vec3 world_normal;
in vec4 viewSpace;
in vec2 texcoord;
 
const vec3 fogColor = vec3(0.5, 0.5,0.5);
const float FogDensity = 0.05;
 
void main(){
    vec3 tex1 = texture(texture1, texcoord).rgb;

    //get light an view directions
    vec3 L = normalize( light_position - world_pos);
    vec3 V = normalize( eye_position - world_pos);

    //diffuse lighting
    vec3 diffuse = DiffuseLight * max(0, dot(L,world_normal));

    //rim lighting
    float rim = 1 - max(dot(V, world_normal), 0.0);
    rim = smoothstep(0.6, 1.0, rim);
    vec3 finalRim = RimColor * vec3(rim, rim, rim);
    //get all lights and texture
    vec3 lightColor = finalRim + diffuse + tex1;

    vec3 finalColor = vec3(0, 0, 0);

    //distance
    float dist = 0;
    float fogFactor = 0;

    //compute distance used in fog equations
    if(depthFog == 0)//select plane based vs range based
    {
		//plane based
		dist = abs(viewSpace.z);
		//dist = (gl_FragCoord.z / gl_FragCoord.w);
    }
    else
    {
		//range based
		dist = length(viewSpace);
    }

    if(fogSelector == 0)//linear fog
    {
// 20 - fog starts; 80 - fog ends
fogFactor = (80 - dist)/(80 - 20);
		fogFactor = clamp( fogFactor, 0.0, 1.0 );

		//if you inverse color in glsl mix function you have to
		//put 1.0 - fogFactor
		finalColor = mix(fogColor, lightColor, fogFactor);
    }
    else if( fogSelector == 1)// exponential fog
    {
		fogFactor = 1.0 /exp(dist * FogDensity);
		fogFactor = clamp( fogFactor, 0.0, 1.0 );

		// mix function fogColor⋅(1−fogFactor) + lightColor⋅fogFactor
		finalColor = mix(fogColor, lightColor, fogFactor);
    }
    else if( fogSelector == 2)
    {
		fogFactor = 1.0 /exp( (dist * FogDensity)* (dist * FogDensity));
		fogFactor = clamp( fogFactor, 0.0, 1.0 );

		finalColor = mix(fogColor, lightColor, fogFactor);
    }

    //show fogFactor depth(gray levels)
    //fogFactor = 1 - fogFactor;
    //out_color = vec4( fogFactor, fogFactor, fogFactor,1.0 );
    out_color = vec4(finalColor, 1);
 
}
```

## Beautiful fog with atmospheric effects

exponential fog 是简化物理模型

光与介质的交互有三种

- Emission
- Absorption
- Scattering

![img](assets/scattering.jpg)

```c++
finalColor = (1 - in_scattering) * fogColor + extinction * lightColor;
```

相应的代码

```c++
//fog fragment shader

#version 330
layout(location = 0) out vec4 out_color;

uniform vec3 light_position;
uniform vec3 eye_position;

uniform sampler2D texture1;

//0 linear; 1 exponential; 2 exponential square
uniform int fogSelector;
//0 plane based; 1 range based
uniform int depthFog;

//can pass them as uniforms
const vec3 DiffuseLight = vec3(0.15, 0.05, 0.0);
const vec3 RimColor = vec3(0.2, 0.2, 0.2);

//from vertex shader
in vec3 world_pos;
in vec3 world_normal;
in vec4 viewSpace;
in vec2 texcoord;

const vec3 fogColor = vec3(0.5, 0.5,0.5);

void main(){
    vec3 tex1 = texture(texture1, texcoord).rgb;

    //get light an view directions
    vec3 L = normalize( light_position - world_pos);
    vec3 V = normalize( eye_position - world_pos);

    //diffuse lighting
    vec3 diffuse = DiffuseLight * max(0, dot(L,world_normal));

    //rim lighting
    float rim = 1 - max(dot(V, world_normal), 0.0);
    rim = smoothstep(0.6, 1.0, rim);
    vec3 finalRim = RimColor * vec3(rim, rim, rim);
    //get all lights and texture
    vec3 lightColor = finalRim + diffuse + tex1;

    vec3 finalColor = vec3(0, 0, 0);

    //compute range based distance
    float dist = length(viewSpace);

    //my camera y is 10.0. you can change it or pass it as a uniform
    float be = (10.0 - viewSpace.y) * 0.004;//0.004 is just a factor; change it if you want
    float bi = (10.0 - viewSpace.y) * 0.001;//0.001 is just a factor; change it if you want

    //OpenGL SuperBible 6th edition uses a smoothstep function to get
    //a nice cutoff here
    //You have to tweak this values
    // float be = 0.025 * smoothstep(0.0, 6.0, 32.0 - viewSpace.y);
    // float bi = 0.075* smoothstep(0.0, 80, 10.0 - viewSpace.y);

    float ext = exp(-dist * be);
    float insc = exp(-dist * bi);

    finalColor = lightColor * ext + fogColor * (1 - insc);

    out_color = vec4(finalColor, 1);
}
```

