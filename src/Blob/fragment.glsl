#define PI 3.14

varying vec3 v_ray_dir;
varying vec3 v_ray_origin;

uniform float u_time;
uniform float u_morph_sphere; 
uniform float u_morph_cube; 
uniform float u_morph_torus;

const int MAX_STEPS = 50;
const float EPSILON = 0.001;

float opSmoothUnion( float d1, float d2, float k ) {
    float h = clamp( 0.5 + 0.5*(d2-d1)/k, 0.0, 1.0 );
    return mix( d2, d1, h ) - k*h*(1.0-h); 
}

float opSmoothSubtraction( float d1, float d2, float k ) {
    float h = clamp( 0.5 - 0.5*(d2+d1)/k, 0.0, 1.0 );
    return mix( d2, -d1, h ) + k*h*(1.0-h); 
}


float sphereSDF( vec3 p, float sRadius ) {
    return length(p) - sRadius;
}

float roundBoxSDF( vec3 p, vec3 b, float r ) {
    vec3 q = (abs(p) - b);
    return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0) - r;
}

float boxFrameSDF( vec3 p, vec3 b, float e ){
    p = abs(p  )-b;
    vec3 q = abs(p+e)-e;
    return min(min(
        length(max(vec3(p.x,q.y,q.z),0.0))+min(max(p.x,max(q.y,q.z)),0.0),
        length(max(vec3(q.x,p.y,q.z),0.0))+min(max(q.x,max(p.y,q.z)),0.0)),
        length(max(vec3(q.x,q.y,p.z),0.0))+min(max(q.x,max(q.y,p.z)),0.0)
    );
}

float torusSDF( vec3 p, vec2 t ){
    vec2 q = vec2(length(p.xz)-t.x,p.y);
    return length(q)-t.y;
}

float sceneSDF( vec3 samplePos ) {

    float frame = boxFrameSDF( samplePos, vec3( 0.5 ), 0.02 );
    float sphere = sphereSDF( vec3(samplePos.x + sin(u_time * PI * 0.33), samplePos.y, samplePos.z), 0.1 );
    float box = roundBoxSDF( vec3(samplePos.x, samplePos.y + sin(u_time * PI * 0.214), samplePos.z), vec3( 0.1 ), 0.0 );
    float torus = torusSDF( vec3(samplePos.x, samplePos.y, samplePos.z + sin(u_time * PI * 0.125)), vec2(0.1, 0.05) );

    float s1 = opSmoothUnion( frame, sphere, u_morph_sphere );
    float s2 = opSmoothUnion( s1, box,  u_morph_cube );
    float s3 = opSmoothUnion( s2, torus,  u_morph_torus );

    return s3;
}

vec3 estimateNormal( vec3 p ) {
    return normalize(vec3(
        sceneSDF(vec3(p.x + EPSILON, p.y, p.z)) - sceneSDF(vec3(p.x - EPSILON, p.y, p.z)),
        sceneSDF(vec3(p.x, p.y + EPSILON, p.z)) - sceneSDF(vec3(p.x, p.y - EPSILON, p.z)),
        sceneSDF(vec3(p.x, p.y, p.z  + EPSILON)) - sceneSDF(vec3(p.x, p.y, p.z - EPSILON))
    ));
}

vec3 toonShade ( vec3 pos ) {
    vec3 n = estimateNormal( pos );
    float NdotL = dot( n, vec3( 0.0, 0.0, -1.0 ) );
    float lightIntensity = smoothstep( 0.0, 0.08, NdotL );
    return vec3(pos.z, pos.z, pos.x) * lightIntensity;
}

vec4 rayMarchSDF( vec3 rayOrigin, vec3 rayDir ){

    vec3 col = vec3( 0.0 );
    float alpha = 0.0;
    float dist = 0.0;

    for ( int i = 0; i < MAX_STEPS; i++ ){
        vec3 samplePos = rayOrigin + ( rayDir * dist );
        float sdf = sceneSDF( samplePos );

        if ( sdf < EPSILON ) {

            col = toonShade( samplePos ) + vec3( 1.0, 0.2, 0.6 );
            alpha = 1.0;
            return vec4 ( col, alpha );
        }

        dist += sdf;
    }


    return vec4( col, alpha );
}

void main () {
    
    vec3 rayOrigin = v_ray_origin;
    vec3 rayDir = normalize(v_ray_dir);
    
    vec4 color = rayMarchSDF( rayOrigin, rayDir );
    gl_FragColor = color;
}