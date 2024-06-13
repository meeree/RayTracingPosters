#version 330 core
in vec2 UV;
uniform sampler2D tex;
uniform float time;
uniform ivec2 resolution;

layout(location = 0) out vec3 color;
float sdf( in vec3 pos)
{
    vec3 c = pos;
    vec3 z = pos;


    // full derivatives version
    
    // (x,y,z)^2 := (x^2-2yz, 2xy+y^2, 2xz+z^2).
    int i = 0;
	for( ; i<4096; i++ )
	{
		//dz = 2.0*vec2(z.x*dz.x-z.y*dz.y, z.x*dz.y + z.y*dz.x )+1.;
        z = vec3( z.x*z.x-2.*z.y*z.z, 2.*z.x*z.y+z.y*z.y, 2.*z.x*z.z+z.z*z.z ) + c;
		if( dot(z,z)>100.0 ) break;
	}
    return 1. - float(i) / 4096.;
}

vec2 raycast( in vec3 ro, in vec3 rd, in float tmin, in float tmax )
{
    float t = tmin;
    float id = 0.;
    int sharpness = 1;
	for( int i=0; i<sharpness*4096; i++ )
	{
        vec3 pos = ro + t*rd;
		float h = sdf(pos);
		if( abs(h)<.001 || t>tmax ) 
            break;
		t += .005 / float(sharpness);
	}

	return vec2(t, 0.);
}

vec3 normal ( in vec3 pos )
{
    vec2 d = vec2(0.005, 0.);
    return normalize( vec3( sdf(pos + d.xyy) - sdf(pos - d.xyy),
                            sdf(pos + d.yxy) - sdf(pos - d.yxy),
                            sdf(pos + d.yyx) - sdf(pos - d.yyx)));
}

float average ( in vec3 pos )
{
    vec2 d = vec2(0.01, 0.);
    return 1. / 7. * (sdf(pos) + sdf(pos + d.xyy) + sdf(pos - d.xyy) 
                    + sdf(pos + d.yxy) + sdf(pos - d.yxy) 
                    + sdf(pos + d.yyx) - sdf(pos - d.yyx));
}

// https://iquilezles.org/articles/rmshadows
float calcSoftshadow( in vec3 ro, in vec3 rd, in float mint, in float tmax )
{
    // bounding volume
    float tp = (0.8-ro.y)/rd.y; if( tp>0.0 ) tmax = min( tmax, tp );

    float res = 1.0;
    float t = mint;
    for( int i=0; i<24; i++ )
    {
		float h = sdf( ro + rd*t );
        float s = clamp(8.0*h/t,0.0,1.0);
        res = min( res, s );
        t += clamp( h, 0.01, 0.2 );
        if( res<0.004 || t>tmax ) break;
    }
    res = clamp( res, 0.0, 1.0 );
    return res*res*(3.0-2.0*res);
}
// https://iquilezles.org/articles/nvscene2008/rwwtt.pdf
float calcAO( in vec3 pos, in vec3 nor )
{
	float occ = 0.0;
    float sca = 1.0;
    for( int i=0; i<5; i++ )
    {
        float h = 0.01 + 0.12*float(i)/4.0;
        float d = sdf( pos + h*nor );
        occ += (h-d)*sca;
        sca *= 0.95;
        if( occ>0.35 ) break;
    }
    return clamp( 1.0 - 3.0*occ, 0.0, 1.0 ) * (0.5+0.5*nor.y);
}


vec3 render( in vec3 ro, in vec3 rd )
{
    float tmax = 15.;
    vec3 col = vec3(0.0);
    vec2 pair = raycast(ro, rd, 0., tmax);
    float t = pair.x;
    float id = pair.y;

    if(t < tmax)
    {
        vec3 pos = ro + rd*t;
        vec3 nor = normal(pos);
        float val = sdf(pos);
       
//        col = 2.5 * vec3(36., 30., 78.) / 255.;
        col = .2 * vec3(237., 222., 164.) / 255.;
        col *= nor * .4 + .6;
//        col = col * (1. - val);
        float ks = 1.0;

        // lighting
        float occ = calcAO( pos, nor );
        
		vec3 lin = vec3(0.0);

        // sun
        {
            vec3  lig = normalize( vec3(-0.5, 0.4, -0.6) );
            vec3  hal = normalize( lig-rd );
            float dif = clamp( dot( nor, lig ), 0.0, 1.0 );
          //if( dif>0.0001 )
        	      dif *= calcSoftshadow( pos, lig, 0.02, 2.5 );
			float spe = pow( clamp( dot( nor, hal ), 0.0, 1.0 ),16.0);
                  spe *= dif;
                  spe *= 0.04+0.96*pow(clamp(1.0-dot(hal,lig),0.0,1.0),5.0);
                //spe *= 0.04+0.96*pow(clamp(1.0-sqrt(0.5*(1.0-dot(rd,lig))),0.0,1.0),5.0);
            lin += col*2.20*dif*vec3(1.30,1.00,0.70);
            lin +=     5.00*spe*vec3(1.30,1.00,0.70)*ks;
        }
        // sky
        {
            float dif = sqrt(clamp( 0.5+0.5*nor.y, 0.0, 1.0 ));
                  dif *= occ;
            lin += col*0.60*dif*vec3(0.40,0.60,1.15);
        }
        // back
        {
        	float dif = clamp( dot( nor, normalize(vec3(0.5,0.0,0.6))), 0.0, 1.0 )*clamp( 1.0-pos.y,0.0,1.0);
                  dif *= occ;
        	lin += col*0.55*dif*vec3(0.25,0.25,0.25);
        }
        // sss
        {
            float dif = pow(clamp(1.0+dot(nor,rd),0.0,1.0),2.0);
                  dif *= occ;
        	lin += col*0.25*dif*vec3(1.00,1.00,1.00);
        }
        
		col = lin;

        col = mix( col, vec3(0.7,0.7,0.9), 1.0-exp( -0.0001*t*t*t ) );
    }
    else
    {
         col = vec3(.96, .96, .96);
    }
    
    col = pow(col, vec3(.4545)); // Gamma correct.
    return col;
}
void main()
{
    // pixel
    vec2 p = UV * 2. - 1.;
    p = (-vec2(resolution) + 2.0*gl_FragCoord.xy) / float(resolution.y);
   // p.x = p.x / 2.; // OPTIONAL: Stretch screen.

    // camera ray    
    vec3 ro = vec3(0., 0., 1.9);
    vec3 rd = normalize(vec3(p,-.8));
    
    // Position Camera.
//    float t = 4. * 3.1415 * iMouse.x / iResolution.x;
    float t = 1.4;
    float c = cos(t);
    float s = sin(t);
    mat3 m = mat3(c, 0., s, 0., 1., 0., -s, 0., c);
    ro = m * ro;
    rd = m * rd;
    
    ro.z += .4;
    ro.y += .2;
    
    rd /= 4.;
    color = render( ro, rd );

    // vignetting	
//	color *= pow( 16.0*UV.x*UV.y*(1.0-UV.x)*(1.0-UV.y), 0.8);

    color = clamp(color,0.0,1.0);
    color.g *= 1.2;
    color.b *= 1.2; // Filter colors.
    color.r *= 1.25;
}
