varying vec3 v_ray_dir;
varying vec3 v_ray_origin;

void main() {

    // local space ray
    v_ray_origin = vec3( inverse( modelMatrix ) * vec4( cameraPosition, 1.0 ) ).xyz;
    v_ray_dir = position - v_ray_origin;

    vec4 worldPosition = modelMatrix * vec4( position, 1.0 );

    // world space ray
    // v_ray_dir = worldPosition.xyz - cameraPosition;

    vec4 viewPosition = viewMatrix * vec4(position, 1.0);
    gl_Position = projectionMatrix * viewPosition;

}
