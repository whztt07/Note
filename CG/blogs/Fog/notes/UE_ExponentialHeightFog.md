# UE Exponential Height Fog

## HeightFogCommon.ush

```
FogStruct.ExponentialFogParameters {
    FogDensity * exp2(-FogHeightFalloff * (CameraWorldPosition.z - FogHeight)) in x
    FogHeightFalloff in y
    CosTerminatorAngle in z
    StartDistance in w
}

FogStruct.ExponentialFogParameters2{
    FogDensitySecond * exp2(-FogHeightFalloffSecond * (CameraWorldPosition.z - FogHeightSecond)) in x
    FogHeightFalloffSecond in y
    FogDensitySecond in z
    FogHeightSecond in w
}

FogStruct.ExponentialFogParameters3{
    FogDensity in x
    FogHeight in y
    whether to use cubemap fog color in z
    FogCutoffDistance in w
}
FogStruct.FogInscatteringTextureParameters{
	mip distance scale in x
	bias in y
	num mips in z 
}
```

```c++
// 没有 texture 时就是返回雾色
float3 ComputeInscatteringColor(float3 CameraToReceiver, float CameraToReceiverLength)
{
	half3 Inscattering = FogStruct.ExponentialFogColorParameter.xyz;
	half3 DirectionalInscattering = 0;

#if SUPPORT_FOG_INSCATTERING_TEXTURE
	BRANCH
	if (FogStruct.ExponentialFogParameters3.z > 0)
	{
		float FadeAlpha = saturate(CameraToReceiverLength * FogStruct.FogInscatteringTextureParameters.x + FogStruct.FogInscatteringTextureParameters.y);
		float3 CubemapLookupVector = CameraToReceiver;
		// Rotate around Z axis
		CubemapLookupVector.xy = float2(dot(CubemapLookupVector.xy, float2(FogStruct.SinCosInscatteringColorCubemapRotation.y, -FogStruct.SinCosInscatteringColorCubemapRotation.x)), dot(CubemapLookupVector.xy, FogStruct.SinCosInscatteringColorCubemapRotation.xy));
		float3 DirectionalColor = TextureCubeSampleLevel(FogStruct.FogInscatteringColorCubemap, FogStruct.FogInscatteringColorSampler, CubemapLookupVector, 0).xyz;
		float3 NonDirectionalColor = TextureCubeSampleLevel(FogStruct.FogInscatteringColorCubemap, FogStruct.FogInscatteringColorSampler, CubemapLookupVector, FogStruct.FogInscatteringTextureParameters.z).xyz;
		Inscattering *= lerp(NonDirectionalColor, DirectionalColor, FadeAlpha);
	}
#endif

	return Inscattering;
}
```

```c++
// Calculate the line integral of the ray from the camera to the receiver position through the fog density function
// The exponential fog density function is d = GlobalDensity * exp(-HeightFalloff * z)
float CalculateLineIntegralShared(float FogHeightFalloff, float RayDirectionZ, float RayOriginTerms)
{
	float Falloff = max(-127.0f, FogHeightFalloff * RayDirectionZ);    // if it's lower than -127.0, then exp2() goes crazy in OpenGL's GLSL.
	float LineIntegral = ( 1.0f - exp2(-Falloff) ) / Falloff;
	float LineIntegralTaylor = log(2.0) - ( 0.5 * Pow2( log(2.0) ) ) * Falloff;		// Taylor expansion around 0
	
	return RayOriginTerms * ( abs(Falloff) > FLT_EPSILON2 ? LineIntegral : LineIntegralTaylor );
}
```

$$
\text{shared}\int=\text{rayOriginTerm}\frac{1-2^{-\text{heightFalloff}*\Delta z}}{\text{heightFalloff}*\Delta z}
$$

在分数近 0 时用泰勒展开

```c++
// @param WorldPositionRelativeToCamera = WorldPosition - InCameraPosition
half4 GetExponentialHeightFog(float3 WorldPositionRelativeToCamera, float ExcludeDistance) // ExcludeDistance 是开始距离
{
	const half MinFogOpacity = FogStruct.ExponentialFogColorParameter.w;

	// Receiver 指着色点
	float3 CameraToReceiver = WorldPositionRelativeToCamera;
	float CameraToReceiverLengthSqr = dot(CameraToReceiver, CameraToReceiver);
	float CameraToReceiverLengthInv = rsqrt(CameraToReceiverLengthSqr); // 平方根的倒数
	float CameraToReceiverLength = CameraToReceiverLengthSqr * CameraToReceiverLengthInv;
	half3 CameraToReceiverNormalized = CameraToReceiver * CameraToReceiverLengthInv;
	
    // FogDensity * exp2(-FogHeightFalloff * (CameraWorldPosition.z - FogHeight))
	float RayOriginTerms = FogStruct.ExponentialFogParameters.x;
	float RayOriginTermsSecond = FogStruct.ExponentialFogParameters2.x;
	float RayLength = CameraToReceiverLength;
	float RayDirectionZ = CameraToReceiver.z;

	// Factor in StartDistance
    // FogStruct.ExponentialFogParameters.w 是 StartDistance
    // 取大值
	ExcludeDistance = max(ExcludeDistance, FogStruct.ExponentialFogParameters.w);
	
#if USE_GLOBAL_CLIP_PLANE

	BRANCH
	// While rendering a planar reflection with a clip plane, we must compute analytical fog using a camera path starting from the plane, rather than the virtual camera origin
	if (dot(View.GlobalClippingPlane.xyz, 1) > 0.0f)
	{
		float CameraOriginPlaneDistance = dot(View.GlobalClippingPlane, float4(View.WorldCameraOrigin, 1));
		float PlaneIntersectionTime = -CameraOriginPlaneDistance / dot(CameraToReceiver, View.GlobalClippingPlane.xyz);

		// Only modify the start distance if the reflection plane is between the camera and receiver point
		if (PlaneIntersectionTime > 0 && PlaneIntersectionTime < 1)
		{
			ExcludeDistance = max(ExcludeDistance, PlaneIntersectionTime * CameraToReceiverLength);
		}
	}

#endif

	if (ExcludeDistance > 0)
	{
         // 到相交点所占时间
		float ExcludeIntersectionTime = ExcludeDistance * CameraToReceiverLengthInv;
		// 相机到相交点的 z 偏移
        float CameraToExclusionIntersectionZ = ExcludeIntersectionTime * CameraToReceiver.z;
        // 相交点的 z 坐标
		float ExclusionIntersectionZ = View.WorldCameraOrigin.z + CameraToExclusionIntersectionZ;
        // 相交点到着色点的 z 偏移
		float ExclusionIntersectionToReceiverZ = CameraToReceiver.z - CameraToExclusionIntersectionZ;

		// Calculate fog off of the ray starting from the exclusion distance, instead of starting from the camera
        // 相交点到着色点的距离
		RayLength = (1.0f - ExcludeIntersectionTime) * CameraToReceiverLength;
		// 相交点到着色点的 z 偏移
        RayDirectionZ = ExclusionIntersectionToReceiverZ;
        // FogStruct.ExponentialFogParameters.y : height falloff
        // FogStruct.ExponentialFogParameters3.y ： fog height
		// height falloff * height
		float Exponent = max(-127.0f, FogStruct.ExponentialFogParameters.y * (ExclusionIntersectionZ - FogStruct.ExponentialFogParameters3.y));
        // FogStruct.ExponentialFogParameters3.x : fog density
		RayOriginTerms = FogStruct.ExponentialFogParameters3.x * exp2(-Exponent);
		
        // FogStruct.ExponentialFogParameters2.y : FogHeightFalloffSecond
        // FogStruct.ExponentialFogParameters2.w : fog height second
		float ExponentSecond = max(-127.0f, FogStruct.ExponentialFogParameters2.y * (ExclusionIntersectionZ - FogStruct.ExponentialFogParameters2.w)); 	 
		RayOriginTermsSecond = FogStruct.ExponentialFogParameters2.z * exp2(-ExponentSecond);
	}

	// Calculate the "shared" line integral (this term is also used for the directional light inscattering) by adding the two line integrals together (from two different height falloffs and densities)
    // FogStruct.ExponentialFogParameters.y : fog height falloff
	float ExponentialHeightLineIntegralShared = CalculateLineIntegralShared(FogStruct.ExponentialFogParameters.y, RayDirectionZ, RayOriginTerms) + CalculateLineIntegralShared(FogStruct.ExponentialFogParameters2.y, RayDirectionZ, RayOriginTermsSecond);
	// fog amount，最终的积分值
	float ExponentialHeightLineIntegral = ExponentialHeightLineIntegralShared * RayLength;
	
    // 雾色
	half3 InscatteringColor = ComputeInscatteringColor(CameraToReceiver, CameraToReceiverLength);
	half3 DirectionalInscattering = 0;

#if SUPPORT_FOG_DIRECTIONAL_LIGHT_INSCATTERING
	// if InscatteringLightDirection.w is negative then it's disabled, otherwise it holds directional inscattering start distance
	BRANCH
	if (FogStruct.InscatteringLightDirection.w >= 0
	#if SUPPORT_FOG_INSCATTERING_TEXTURE
		&& FogStruct.ExponentialFogParameters3.z == 0
	#endif
	)
	{
		float DirectionalInscatteringStartDistance = FogStruct.InscatteringLightDirection.w;
		// Setup a cosine lobe around the light direction to approximate inscattering from the directional light off of the ambient haze;
		half3 DirectionalLightInscattering = FogStruct.DirectionalInscatteringColor.xyz * pow(saturate(dot(CameraToReceiverNormalized, FogStruct.InscatteringLightDirection.xyz)), FogStruct.DirectionalInscatteringColor.w);

		// Calculate the line integral of the eye ray through the haze, using a special starting distance to limit the inscattering to the distance
		float DirExponentialHeightLineIntegral = ExponentialHeightLineIntegralShared * max(RayLength - DirectionalInscatteringStartDistance, 0.0f);
		// Calculate the amount of light that made it through the fog using the transmission equation
		half DirectionalInscatteringFogFactor = saturate(exp2(-DirExponentialHeightLineIntegral));
		// Final inscattering from the light
		DirectionalInscattering = DirectionalLightInscattering * (1 - DirectionalInscatteringFogFactor);
	}
#endif

	// Calculate the amount of light that made it through the fog using the transmission equation
    // 最终的系数
	half ExpFogFactor = max(saturate(exp2(-ExponentialHeightLineIntegral)), MinFogOpacity);

    // FogStruct.ExponentialFogParameters3.w : FogCutoffDistance
	FLATTEN
	if (FogStruct.ExponentialFogParameters3.w > 0 && CameraToReceiverLength > FogStruct.ExponentialFogParameters3.w)
	{
		ExpFogFactor = 1;
		DirectionalInscattering = 0;
	}

	// Fog color is unused when additive / modulate blend modes are active.
	#if (MATERIALBLENDING_ADDITIVE || MATERIALBLENDING_MODULATE)
		half3 FogColor = 0.0;
	#else
		half3 FogColor = (InscatteringColor) * (1 - ExpFogFactor) + DirectionalInscattering;
	#endif

	return half4(FogColor, ExpFogFactor);
}
```

$$
\text{rayOriginTerm} = \text{FogDensity} * \text{exp2}\left({-\text{FogHeightFalloff}*(\text{Cam}.z-\text{FogHeight})}\right)
$$

$$
\text{ExponentialHeightLineIntegral} = \text{shared}\int * \text{rayLength}
$$

$$
\text{FogColor} = \text{InscatteringColor} *(1 - \text{ExpFogFactor})+\text{DirectionalInscattering}
$$

$$
\text{FinalColor} = \text{FogColor} + \text{ExpFogFactor} * \text{Color}
$$

## 思考

BasePassVertexShader.usf 调用 `CalculateHeightFog` 

内部基本上直接调用了 `GetExponentialHeightFog`，也就是说默认使用 Exponential Height Fog

只需要动态参数 `WorldPositionRelativeToCamera`，需要准备好静态参数，如下

```c++
FogStruct.ExponentialFogParameters {
    FogDensity * exp2(-FogHeightFalloff * (CameraWorldPosition.z - FogHeight)) in x
    FogHeightFalloff in y
    CosTerminatorAngle in z
    StartDistance in w
}

FogStruct.ExponentialFogParameters3{
    FogDensity in x
    FogHeight in y
    [x] whether to use cubemap fog color in z
    FogCutoffDistance in w
}

FogStruct.DirectionalInscatteringColor.xyz
FogStruct.DirectionalInscatteringColor.w // 指数
FogStruct.InscatteringLightDirection.xyz
FogStruct.InscatteringLightDirection.w // DirectionalInscatteringStartDistance

FogStruct.ExponentialFogColorParameter.xyz // Fog inscattering color
FogStruct.ExponentialFogColorParameter.w // min transparency
```

下表

| **Property**                                | **Description**                                              |
| :------------------------------------------ | :----------------------------------------------------------- |
| **Fog Density**                             | This is the global density factor, which can be thought of as the fog layer's thickness. |
| **Fog Inscattering Color**                  | Sets the inscattering color for the fog. Essentially, this is the fog's primary color. |
| **Fog Height Falloff**                      | Height density factor, controls how the density increases as height decreases. Smaller values make the transition larger. |
| **Fog Max Opacity**                         | This controls the maximum opacity of the fog. A value of 1 means the fog will be completely opaque, while 0 means the fog will be essentially invisible. |
| **Start Distance**                          | Distance from the camera that the fog will start.            |
| **Directional Inscattering Exponent**       | Controls the size of the directional inscattering cone, which is used to approximate inscattering from a directional light source. |
| **Directional Inscattering Start Distance** | Controls the start distance from the viewer of the directional inscattering, which is used to approximate inscattering from a directional light. |
| **Directional Inscattering Color**          | Sets the color for directional inscattering, used to approximate inscattering from a directional light. This is similar to adjusting the simulated color of a directional light source. |

Fog Max Opacity 没找到在哪里用，不过要用的话不难，直接对 `ExpFogFactor` 修改就好了

> 好像跟 MinFogOpacity 反转了

FogHeight 是 fog 这个 object 的世界坐标的 z

