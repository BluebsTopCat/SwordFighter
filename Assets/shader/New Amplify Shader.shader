// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "New Amplify Shader"
{
	Properties
	{
		_Float1("Float 1", Float) = 1
		_Float3("Float 1", Float) = 1
		_foam("foam", Color) = (0,0.7830722,1,0)
		_water1("water1", Color) = (0,0.7830722,1,0)
		_Float4("Float 4", Float) = 0
		_Float5("Float 5", Float) = 0
		_Smoothness("Smoothness", Float) = 0
		_Translusency("Translusency", Float) = 0
		_offset("offset", Vector) = (0,0,0,0)
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		GrabPass{ }
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#pragma target 3.5
		#if defined(UNITY_STEREO_INSTANCING_ENABLED) || defined(UNITY_STEREO_MULTIVIEW_ENABLED)
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex);
		#else
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex)
		#endif
		#pragma surface surf Standard keepalpha noshadow exclude_path:deferred vertex:vertexDataFunc 
		struct Input
		{
			float3 worldPos;
			float4 screenPos;
		};

		uniform float _Float4;
		uniform float _Float5;
		uniform float4 _offset;
		ASE_DECLARE_SCREENSPACE_TEXTURE( _GrabTexture )
		uniform float4 _foam;
		UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
		uniform float4 _CameraDepthTexture_TexelSize;
		uniform float _Float1;
		uniform float _Float3;
		uniform float4 _water1;
		uniform float _Translusency;
		uniform float _Smoothness;


		struct Gradient
		{
			int type;
			int colorsLength;
			int alphasLength;
			float4 colors[8];
			float2 alphas[8];
		};


		Gradient NewGradient(int type, int colorsLength, int alphasLength, 
		float4 colors0, float4 colors1, float4 colors2, float4 colors3, float4 colors4, float4 colors5, float4 colors6, float4 colors7,
		float2 alphas0, float2 alphas1, float2 alphas2, float2 alphas3, float2 alphas4, float2 alphas5, float2 alphas6, float2 alphas7)
		{
			Gradient g;
			g.type = type;
			g.colorsLength = colorsLength;
			g.alphasLength = alphasLength;
			g.colors[ 0 ] = colors0;
			g.colors[ 1 ] = colors1;
			g.colors[ 2 ] = colors2;
			g.colors[ 3 ] = colors3;
			g.colors[ 4 ] = colors4;
			g.colors[ 5 ] = colors5;
			g.colors[ 6 ] = colors6;
			g.colors[ 7 ] = colors7;
			g.alphas[ 0 ] = alphas0;
			g.alphas[ 1 ] = alphas1;
			g.alphas[ 2 ] = alphas2;
			g.alphas[ 3 ] = alphas3;
			g.alphas[ 4 ] = alphas4;
			g.alphas[ 5 ] = alphas5;
			g.alphas[ 6 ] = alphas6;
			g.alphas[ 7 ] = alphas7;
			return g;
		}


		float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }

		float snoise( float2 v )
		{
			const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
			float2 i = floor( v + dot( v, C.yy ) );
			float2 x0 = v - i + dot( i, C.xx );
			float2 i1;
			i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
			float4 x12 = x0.xyxy + C.xxzz;
			x12.xy -= i1;
			i = mod2D289( i );
			float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
			float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
			m = m * m;
			m = m * m;
			float3 x = 2.0 * frac( p * C.www ) - 1.0;
			float3 h = abs( x ) - 0.5;
			float3 ox = floor( x + 0.5 );
			float3 a0 = x - ox;
			m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
			float3 g;
			g.x = a0.x * x0.x + h.x * x0.y;
			g.yz = a0.yz * x12.xz + h.yz * x12.yw;
			return 130.0 * dot( m, g );
		}


		float4 SampleGradient( Gradient gradient, float time )
		{
			float3 color = gradient.colors[0].rgb;
			UNITY_UNROLL
			for (int c = 1; c < 8; c++)
			{
			float colorPos = saturate((time - gradient.colors[c-1].w) / (gradient.colors[c].w - gradient.colors[c-1].w)) * step(c, (float)gradient.colorsLength-1);
			color = lerp(color, gradient.colors[c].rgb, lerp(colorPos, step(0.01, colorPos), gradient.type));
			}
			#ifndef UNITY_COLORSPACE_GAMMA
			color = half3(GammaToLinearSpaceExact(color.r), GammaToLinearSpaceExact(color.g), GammaToLinearSpaceExact(color.b));
			#endif
			float alpha = gradient.alphas[0].x;
			UNITY_UNROLL
			for (int a = 1; a < 8; a++)
			{
			float alphaPos = saturate((time - gradient.alphas[a-1].y) / (gradient.alphas[a].y - gradient.alphas[a-1].y)) * step(a, (float)gradient.alphasLength-1);
			alpha = lerp(alpha, gradient.alphas[a].x, lerp(alphaPos, step(0.01, alphaPos), gradient.type));
			}
			return float4(color, alpha);
		}


		inline float4 ASE_ComputeGrabScreenPos( float4 pos )
		{
			#if UNITY_UV_STARTS_AT_TOP
			float scale = -1.0;
			#else
			float scale = 1.0;
			#endif
			float4 o = pos;
			o.y = pos.w * 0.5f;
			o.y = ( pos.y - o.y ) * _ProjectionParams.x * scale + o.y;
			return o;
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			Gradient gradient218 = NewGradient( 0, 2, 2, float4( 1, 1, 1, 0 ), float4( 0.02352941, 0.02352941, 0.02352941, 1 ), 0, 0, 0, 0, 0, 0, float2( 1, 0 ), float2( 1, 1 ), 0, 0, 0, 0, 0, 0 );
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float simplePerlin2D219 = snoise( float2( 0.1,0.01 )*( ase_worldPos + ( _Time.y / _Float4 ) ).x );
			simplePerlin2D219 = simplePerlin2D219*0.5 + 0.5;
			Gradient gradient245 = NewGradient( 0, 2, 2, float4( 1, 1, 1, 0 ), float4( 0.02352941, 0.02352941, 0.02352941, 1 ), 0, 0, 0, 0, 0, 0, float2( 1, 0 ), float2( 1, 1 ), 0, 0, 0, 0, 0, 0 );
			float simplePerlin2D227 = snoise( float2( -0.1,-0.5 )*( ase_worldPos.x + ( _Time.y / _Float5 ) ) );
			simplePerlin2D227 = simplePerlin2D227*0.5 + 0.5;
			float4 appendResult62 = (float4(SampleGradient( gradient218, simplePerlin2D219 ).r , SampleGradient( gradient245, simplePerlin2D227 ).rgb));
			v.vertex.xyz += ( appendResult62 / _offset ).xyz;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( ase_screenPos );
			float4 screenColor195 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,ase_grabScreenPos.xy/ase_grabScreenPos.w);
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			Gradient gradient218 = NewGradient( 0, 2, 2, float4( 1, 1, 1, 0 ), float4( 0.02352941, 0.02352941, 0.02352941, 1 ), 0, 0, 0, 0, 0, 0, float2( 1, 0 ), float2( 1, 1 ), 0, 0, 0, 0, 0, 0 );
			float3 ase_worldPos = i.worldPos;
			float simplePerlin2D219 = snoise( float2( 0.1,0.01 )*( ase_worldPos + ( _Time.y / _Float4 ) ).x );
			simplePerlin2D219 = simplePerlin2D219*0.5 + 0.5;
			Gradient gradient245 = NewGradient( 0, 2, 2, float4( 1, 1, 1, 0 ), float4( 0.02352941, 0.02352941, 0.02352941, 1 ), 0, 0, 0, 0, 0, 0, float2( 1, 0 ), float2( 1, 1 ), 0, 0, 0, 0, 0, 0 );
			float simplePerlin2D227 = snoise( float2( -0.1,-0.5 )*( ase_worldPos.x + ( _Time.y / _Float5 ) ) );
			simplePerlin2D227 = simplePerlin2D227*0.5 + 0.5;
			float4 appendResult62 = (float4(SampleGradient( gradient218, simplePerlin2D219 ).r , SampleGradient( gradient245, simplePerlin2D227 ).rgb));
			float screenDepth17 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
			float distanceDepth17 = abs( ( screenDepth17 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( ( saturate( ( 1.0 - appendResult62 ) ) * float4(1,1,1,1) ).x ) );
			float clampResult20 = clamp( ( ( 1.0 - distanceDepth17 ) * _Float1 ) , 0.0 , 1.0 );
			float temp_output_248_0 = ( clampResult20 * _Float3 );
			float4 lerpResult194 = lerp( screenColor195 , ( float4( 0,0,0,0 ) + ( _foam * temp_output_248_0 ) + ( ( ( _water1 + float4( 0,0,0,0 ) ) * 1 ) * ( 1.0 - temp_output_248_0 ) ) ) , _Translusency);
			o.Albedo = lerpResult194.rgb;
			o.Smoothness = _Smoothness;
			o.Alpha = 1;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=17101
-170;917;1535;353;518.194;979.5057;1.55343;True;False
Node;AmplifyShaderEditor.RangedFloatNode;221;-2011.018,-678.4486;Inherit;False;Property;_Float4;Float 4;6;0;Create;True;0;0;False;0;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;214;-2017.431,-852.0465;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;234;-2131.521,-1554.418;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;235;-1919.93,-1259.333;Inherit;False;Property;_Float5;Float 5;7;0;Create;True;0;0;False;0;0;4.53;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;215;-1910.101,-1034.499;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleDivideOpNode;216;-1815.22,-729.0025;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;233;-1798.374,-1358.482;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;232;-2024.191,-1736.872;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;231;-1784.525,-1611.409;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;217;-1670.435,-909.0374;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;227;-1531.738,-1605.976;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;-0.1,-0.5;False;1;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GradientNode;218;-1588.493,-1105.634;Inherit;False;0;2;2;1,1,1,0;0.02352941,0.02352941,0.02352941,1;1,0;1,1;0;1;OBJECT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;219;-1472.902,-945.0991;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0.1,0.01;False;1;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GradientNode;245;-1475.002,-1765.241;Inherit;False;0;2;2;1,1,1,0;0.02352941,0.02352941,0.02352941,1;1,0;1,1;0;1;OBJECT;0
Node;AmplifyShaderEditor.GradientSampleNode;226;-1190.84,-1163.804;Inherit;True;2;0;OBJECT;0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GradientSampleNode;220;-1188.751,-956.3036;Inherit;True;2;0;OBJECT;0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;62;-676.3441,-820.0336;Inherit;True;FLOAT4;4;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.OneMinusNode;202;-427.4204,-443.7955;Inherit;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SaturateNode;223;-221.1948,-334.2734;Inherit;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.Vector4Node;224;-117.1185,-107.2877;Inherit;False;Constant;_Vector1;Vector 1;14;0;Create;True;0;0;False;0;1,1,1,1;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;63;9.826232,-253.9105;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DepthFade;17;172.3748,-284.2066;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;18;420.7364,-397.0842;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;28;444.1811,-109.6984;Inherit;True;Property;_Float1;Float 1;0;0;Create;True;0;0;False;0;1;0.57;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;19;670.9156,-443.1601;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;20;893.8788,-445.4562;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;249;1035.235,-266.4815;Inherit;True;Property;_Float3;Float 1;1;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;141;729.7699,-940.9346;Inherit;False;Property;_water1;water1;4;0;Create;True;0;0;False;0;0,0.7830722,1,0;0.4509804,0.6901961,0.7607843,0.5019608;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;248;1176.598,-640.8579;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;144;2183.669,-1845.883;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;31;1234.525,-950.7325;Inherit;False;Property;_foam;foam;2;0;Create;True;0;0;False;0;0,0.7830722,1,0;0.7746084,0.9716981,0.9568948,0.5019608;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScaleNode;246;1767.596,-1101.821;Inherit;True;1;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;33;1297.132,-381.8581;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;35;1688.318,-658.6158;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;36;1684.912,-906.8243;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;193;1873.765,-551.0028;Inherit;False;Property;_Translusency;Translusency;13;0;Create;True;0;0;False;0;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;247;1556.252,-156.4716;Inherit;False;Property;_offset;offset;15;0;Create;True;0;0;False;0;0,0,0,0;50,50,10,50;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;39;1938.552,-785.1011;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ScreenColorNode;195;1922.984,-955.3777;Inherit;False;Global;_GrabScreen0;Grab Screen 0;13;0;Create;True;0;0;False;0;Object;-1;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StepOpNode;181;1220.263,-3009.751;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;-0.9;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;159;965.0876,-2697.925;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StepOpNode;140;823.9526,-1820.707;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0.62;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;34;1003.973,-1968.163;Inherit;False;Property;_water2;water2;3;0;Create;True;0;0;False;0;0,0.7830722,1,0;0.6274511,0.7764707,0.8431373,0.5019608;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldPosInputsNode;162;63.17078,-2883.609;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ColorNode;142;864.8018,-2407.402;Inherit;False;Property;_Color0;Color 0;5;0;Create;True;0;0;False;0;0,0.7830722,1,0;0.2784307,0.5764706,0.6745098,0.4196078;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;143;1257.612,-1842.164;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;151;510.3241,-1736.354;Inherit;False;Property;_Float0;Float 0;8;0;Create;True;0;0;False;0;0;0.19;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;152;224.6763,-2166.549;Inherit;True;Simplex3D;True;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;0.005;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;161;571.8319,-2998.303;Inherit;True;Simplex3D;False;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;11;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;157;398.0002,-2237.855;Inherit;False;Property;_max;max;10;0;Create;True;0;0;False;0;0;0.34;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;153;417.9092,-2304.323;Inherit;False;Property;_min;min;9;0;Create;True;0;0;False;0;0;0.31;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;156;677,-2214.855;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;155;1117.125,-2277.059;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;136;228.1032,-1823.837;Inherit;True;Simplex3D;True;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;201;96.60569,-1939.371;Inherit;True;Property;_Float2;Float 2;14;0;Create;True;0;0;False;0;0.01;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;250;1513.692,-849.0176;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;160;646.2871,-2772.525;Inherit;False;Constant;_Color1;Color 1;11;0;Create;True;0;0;False;0;0.864409,0.990566,0.982479,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;199;15.65363,-1781.954;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;91;1811.083,-228.291;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;50,15,50,50;False;1;FLOAT4;0
Node;AmplifyShaderEditor.Vector4Node;180;157.9676,-2375.484;Inherit;False;Constant;_Vector0;Vector 0;11;0;Create;True;0;0;False;0;0.1,0.1,0.1,0.1;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TimeNode;200;-256.3465,-1688.954;Inherit;True;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;165;1802.719,-2210.975;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;194;2133.984,-663.3776;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;191;1938.706,-477.9226;Inherit;False;Property;_Smoothness;Smoothness;12;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;167;406.6007,-2848.896;Inherit;False;2;2;0;FLOAT;0.1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;190;14.15982,-2538.449;Inherit;False;Constant;_Vector2;Vector 2;11;0;Create;True;0;0;False;0;100,100;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.WorldPosInputsNode;138;-173.0033,-1857.818;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TimeNode;197;-241.8465,-2095.454;Inherit;True;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;158;528.0001,-2560.855;Inherit;True;Property;_triangletexture;triangletexture;11;0;Create;True;0;0;False;0;ba8b8efc69f411142aad67ea4d757ab5;ba8b8efc69f411142aad67ea4d757ab5;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;188;296.8613,-2599.3;Inherit;True;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;198;43.1536,-2095.454;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;2373.589,-649.2829;Float;False;True;3;ASEMaterialInspector;0;0;Standard;New Amplify Shader;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;False;0;False;Opaque;;Geometry;ForwardOnly;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;216;0;214;0
WireConnection;216;1;221;0
WireConnection;233;0;234;0
WireConnection;233;1;235;0
WireConnection;231;0;232;1
WireConnection;231;1;233;0
WireConnection;217;0;215;0
WireConnection;217;1;216;0
WireConnection;227;1;231;0
WireConnection;219;1;217;0
WireConnection;226;0;245;0
WireConnection;226;1;227;0
WireConnection;220;0;218;0
WireConnection;220;1;219;0
WireConnection;62;0;220;0
WireConnection;62;1;226;0
WireConnection;202;0;62;0
WireConnection;223;0;202;0
WireConnection;63;0;223;0
WireConnection;63;1;224;0
WireConnection;17;0;63;0
WireConnection;18;0;17;0
WireConnection;19;0;18;0
WireConnection;19;1;28;0
WireConnection;20;0;19;0
WireConnection;248;0;20;0
WireConnection;248;1;249;0
WireConnection;144;0;141;0
WireConnection;246;0;144;0
WireConnection;33;0;248;0
WireConnection;35;0;246;0
WireConnection;35;1;33;0
WireConnection;36;0;31;0
WireConnection;36;1;248;0
WireConnection;39;1;36;0
WireConnection;39;2;35;0
WireConnection;181;0;161;0
WireConnection;159;0;160;0
WireConnection;159;1;158;0
WireConnection;140;0;136;0
WireConnection;140;1;151;0
WireConnection;143;0;34;0
WireConnection;143;1;140;0
WireConnection;152;0;198;0
WireConnection;161;0;162;0
WireConnection;161;1;167;0
WireConnection;156;0;152;0
WireConnection;156;1;153;0
WireConnection;156;2;157;0
WireConnection;155;0;142;0
WireConnection;155;1;156;0
WireConnection;136;0;199;0
WireConnection;199;0;138;0
WireConnection;199;1;200;1
WireConnection;91;0;62;0
WireConnection;91;1;247;0
WireConnection;165;0;181;0
WireConnection;165;1;159;0
WireConnection;194;0;195;0
WireConnection;194;1;39;0
WireConnection;194;2;193;0
WireConnection;167;1;158;1
WireConnection;158;1;188;0
WireConnection;188;0;190;0
WireConnection;198;0;197;1
WireConnection;198;1;138;0
WireConnection;0;0;194;0
WireConnection;0;4;191;0
WireConnection;0;11;91;0
ASEEND*/
//CHKSM=383641AE6FFFEBB11EB8D944EEBA4600941F982E