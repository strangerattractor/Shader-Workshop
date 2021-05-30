Shader "Hidden/Shader/Outline"
{
    HLSLINCLUDE

    #pragma target 4.5
    #pragma only_renderers d3d11 ps4 xboxone vulkan metal switch

    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"
    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/PostProcessing/Shaders/FXAA.hlsl"
    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/PostProcessing/Shaders/RTUpscale.hlsl"

    struct Attributes
    {
        uint vertexID : SV_VertexID;
        UNITY_VERTEX_INPUT_INSTANCE_ID
    };

    struct Varyings
    {
        float4 positionCS : SV_POSITION;
        float2 texcoord   : TEXCOORD0;
        UNITY_VERTEX_OUTPUT_STEREO
    };

    Varyings Vert(Attributes input)
    {
        Varyings output;
        UNITY_SETUP_INSTANCE_ID(input);
        UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
        output.positionCS = GetFullScreenTriangleVertexPosition(input.vertexID);
        output.texcoord = GetFullScreenTriangleTexCoord(input.vertexID);
        return output;
    }

    // List of properties to control your post process effect
    float _Distance;
	float _Mix;

	int _Thickness;
	float _Edge;
	float _TransitionSmoothness;
	float4 _Color;

    TEXTURE2D_X(_InputTexture);

    float4 CustomPostProcess(Varyings input) : SV_Target
    {
		float2 offset = _Thickness / _ScreenParams;

		uint2 positionSS = input.texcoord * _ScreenSize.xy;

		float4 outColor = LOAD_TEXTURE2D_X(_InputTexture, positionSS);

		uint2 positionL = input.texcoord + float2(-offset.x, 0) * _ScreenSize.xy;
		uint2 positionR = input.texcoord + float2(offset.x, 0) * _ScreenSize.xy;
		uint2 positionT = input.texcoord + float2(0, -offset.y) * _ScreenSize.xy;
		uint2 positionB = input.texcoord + float2(0, offset.y) * _ScreenSize.xy;

		float left = LoadCameraDepth(positionSS + positionL);
		float right = LoadCameraDepth(positionSS + positionR);
		float top = LoadCameraDepth(positionSS + positionT);
		float bottom = LoadCameraDepth(positionSS + positionB);

		float delta = sqrt(pow(right - left, 2) + pow(top - bottom, 2)) * _Distance;

		float t = smoothstep(_Edge, _Edge + _TransitionSmoothness, delta);

		float4 color = lerp(outColor, _Color, _Color.a);

		//float4 output = lerp(outColor, _Color, step(_TransitionSmoothness, delta));
		float4 output = lerp(outColor, _Color, t);

		output = lerp(outColor, output, _Mix);

		return output;

    }

    ENDHLSL

    SubShader
    {
        Pass
        {
            Name "Outline"

            ZWrite Off
            ZTest Always
            Blend Off
            Cull Off

            HLSLPROGRAM
                #pragma fragment CustomPostProcess
                #pragma vertex Vert
            ENDHLSL
        }
    }
    Fallback Off
}
