/*------------------.
| :: Description :: |
'-------------------/

	Splitscreen (version 2.0)

	Author: CeeJay.dk
	License: MIT

	About:
	Displays the image before and after it has been modified by effects using a splitscreen
    

	Ideas for future improvement:
    *

	History:
	(*) Feature (+) Improvement (x) Bugfix (-) Information (!) Compatibility
	
	Version 1.0
    * Does a splitscreen before/after view
    
	Version 2.0
    * Ported to Reshade 3.x
    * Added UI settings.
    * Added Diagonal split mode
    - Removed curvy mode. I didn't like how it looked.
    - Threatened other modes to behave or they would be next.


	The MIT License (MIT)

	Copyright (c) 2014 CeeJayDK

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.
*/

/*------------------.
| :: UI Settings :: |
'------------------*/

uniform int splitscreen_mode <
    ui_type = "combo";
    ui_label = "Mode";
    ui_tooltip = "Choose a mode";
    //ui_category = "";
    ui_items = 
    "Vertical 50/50 split\0"
    "Vertical 25/50/25 split\0"
    "Angled 50/50 split\0"
    "Angled 25/50/25 split\0"
    "Horizontal 50/50 split\0"
    "Horizontal 25/50/25 split\0"
    "Diagonal split\0"
    ;
> = 0;

/*---------------.
| :: Includes :: |
'---------------*/

#include "ReShade.fxh"


/*-------------------------.
| :: Texture and sampler:: |
'-------------------------*/

texture Before { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; };
sampler Before_sampler { Texture = Before; };


/*-------------.
| :: Effect :: |
'-------------*/

float4 PS_Before(float4 pos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
    return tex2D(ReShade::BackBuffer, texcoord);
}

float4 PS_After(float4 pos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
    float4 color; 

    // -- Vertical 50/50 split --
    [branch] if (splitscreen_mode == 0)
        color = (texcoord.x < 0.5 ) ? tex2D(Before_sampler, texcoord) : tex2D(ReShade::BackBuffer, texcoord);

    // -- Vertical 25/50/25 split --
    [branch] if (splitscreen_mode == 1)
    {
        //Calculate the distance from center
        float dist = abs(texcoord.x - 0.5);
        
        //Further than 1/4 away from center?
        dist = saturate(dist - 0.25);
        
        color = dist ? tex2D(Before_sampler, texcoord) : tex2D(ReShade::BackBuffer, texcoord);
	}

    // -- Angled 50/50 split --
    [branch] if (splitscreen_mode == 2)
    {
        //Calculate the distance from center
        float dist = ((texcoord.x - 3.0/8.0) + (texcoord.y * 0.25));

        //Further than 1/4 away from center?
        dist = saturate(dist - 0.25);

        color = dist ? tex2D(ReShade::BackBuffer, texcoord) : tex2D(Before_sampler, texcoord);
    }

    // -- Angled 25/50/25 split --
    [branch] if (splitscreen_mode == 3)
    {
        //Calculate the distance from center
        float dist = ((texcoord.x - 3.0/8.0) + (texcoord.y * 0.25));

        dist = abs(dist - 0.25);

        //Further than 1/4 away from center?
        dist = saturate(dist - 0.25);

        color = dist ? tex2D(Before_sampler, texcoord) : tex2D(ReShade::BackBuffer, texcoord);
    }
  
    // -- Horizontal 50/50 split --
    [branch] if (splitscreen_mode == 4)
	    color =  (texcoord.y < 0.5) ? tex2D(Before_sampler, texcoord) : tex2D(ReShade::BackBuffer, texcoord);
	
    // -- Horizontal 25/50/25 split --
    [branch] if (splitscreen_mode == 5)
    {
        //Calculate the distance from center
        float dist = abs(texcoord.y - 0.5);
        
        //Further than 1/4 away from center?
        dist = saturate(dist - 0.25);
        
        color = dist ? tex2D(Before_sampler, texcoord) : tex2D(ReShade::BackBuffer, texcoord);
    }

    // -- Diagonal split --
    [branch] if (splitscreen_mode == 6)
    {
        //Calculate the distance from center
        float dist = (texcoord.x + texcoord.y);
        
        //Further than 1/2 away from center?
        //dist = saturate(dist - 1.0);
        
        color = (dist < 1.0) ? tex2D(Before_sampler, texcoord) : tex2D(ReShade::BackBuffer, texcoord);
    }

    return color;
}


/*-----------------.
| :: Techniques :: |
'-----------------*/

technique Before
{
    pass
    {
        VertexShader = PostProcessVS;
        PixelShader = PS_Before;
        RenderTarget = Before;
    }
}

technique After
{
    pass
    {
        VertexShader = PostProcessVS;
        PixelShader = PS_After;
    }
}
