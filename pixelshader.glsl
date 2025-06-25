extern number time;

vec4 effect(vec4 color, Image tex, vec2 tex_coords, vec2 screen_coords)
{
    // color.r: red tint (toward), color.b: blue tint (away)
    float intensity = max(color.r, color.b);

    // Pulse effect based on time and intensity
    float pulse = 0.5 + 0.5 * sin(time * 4.0 + intensity * 6.28);
    pulse = 1.0;

    // Glow: stronger for higher intensity
    float glow = smoothstep(0.0, 1.0, intensity) * 0.5 + 0.5 * pulse * intensity;

    // Final color: mix original color with white for glow
    vec3 finalColor = mix(color.rgb, vec3(1.0, 1.0, 1.0), glow * 0.5);

    return vec4(finalColor, color.a);
}